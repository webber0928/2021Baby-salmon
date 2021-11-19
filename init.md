## podman

### 遠程客戶端
Mac 客戶端可通過Homebrew 獲得：
```
brew install podman
```
要啟動 Podman 管理的 VM：
```
podman machine init
podman machine start
```
然後，您可以使用以下方法驗證安裝信息：
```
podman info
```

### 安裝 cenots

下載 cenots images
```
podman pull centos
```

進入 cenots
```
podman run -it centos
```

### 更新 cenots
檢查版本
```
cat /etc/redhat-release
```
安裝更新

```
yum -y update
```

### podman 容器操作
列出所有的容器 ID

```
podman ps -aq
```
停止所有的容器
```
podman stop $(podman ps -aq)
```
删除所有的容器
```
podman rm $(podman ps -aq)
```
删除所有的鏡像
```
podman rmi $(podman images -q)
```
複製文件

```
podman cp mycontainer:/opt/file.txt /opt/local/
podman cp /opt/local/file.txt mycontainer:/opt/
```

删除所有的鏡像
```
podman rmi $(podman images -qa) -f
```
----

### 使用他們的文件

作業系統
* centos7/centos8 stream/Fedora35

軟體套件
* podman

container
* 以最新的 centos8 為基底

下載 centos
```
podman run -i -t -d --net host --cap-add=all -e "container=podman" --restart always --name=aesopowerSdk --device /dev/fuse --entrypoint /sbin/init centos
```

若要模擬 test site 的環境可改用以下腳本執行容器
```
#!/bin/bash
containerName="請輸入容器的名稱";
image="請輸入 image ID 或 名稱";
cpuPoints="1024 代表所有 cpu 資源";
mem="2g 代表 2GB 記憶體";

podman run -i -t -d --net host --cap-add all -e "container=podman" --restart always --name=${containerName} --device /dev/fuse --entrypoint /sbin/init --cpu-shares=${cpuPoints} -m=${mem} ${image}

# 目前 test site 為雙核心 cpu 加上 2GB 記憶體。
```

進入 container
```
podman exec -i -t aesopowerSdk /bin/bash
```

若運行 systemctl 得到失敗的回應，則可能為 selinux 的傑作，可先將其暫時關閉。
```
setenforce 0
```

並且編輯其設定檔，設置為僅提醒的模式
```
vi /etc/selinux/config
```

```
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
# enforcing - SELinux security policy is enforced.
# permissive - SELinux prints warnings instead of enforcing.
# disabled - No SELinux policy is loaded.
#SELINUX=enforcing
SELINUX=permissive
# SELINUXTYPE= can take one of three values:
# targeted - Targeted processes are protected,
# minimum - Modification of targeted policy. Only selected processes are protected.
# mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

將 container 中的 centos8 變成 centos8 stream，以便獲得更長的官方支援。
```
dnf install centos-release-stream
dnf distro-sync --allowerasing --skip-broken --nobest
```

更新系統
```
dnf -y update
```

啟用 epel 套件
```
dnf -y install epel-release
```

安裝套件

[remi-release-8.rpm](http://rpms.remirepo.net/enterprise/remi-release-8.rpm) 不支援 aarch64 架構
```
dnf -y --allowerasing --skip-broken install vim httpd mariadb-server openssh-server openssh-clients mod_ssl glibc-langpack-en langpacks-en glibc-all-langpacks wget unzip sshpass nmap

dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm

dnf -y update

dnf install --allowerasing --skip-broken php56 php56-php php56-php-mcrypt php56-php-mysqlnd php56-php-mbstring php56-php-soap php56-php-json php56-php-xml 
```

安裝 php pdf 函式庫
```
wget https://github.com/tecnickcom/TCPDF/archive/main.zip;
unzip main.zip;
rm main.zip;
mkdir /usr/share/php;
mv TCPDF-main /usr/share/php/tcpdf;
chmod -R 755 /usr/share/php/tcpdf;
```

安裝 qbpwcf 套件

網址 https://sourceforge.net/projects/qbpwc/files/

```
下載跟 php5 有關的: https://phoenixnap.dl.sourceforge.net/project/qbpwc/qbpwcf-alpha-2021-11-08-3%28php5x_CIv2%29.tar.xz
```

```
cd /usr/lib/
wget uri2qbpwcf -O qbpwcf-xxx.tar.xz
tar -x -v -f qbpwcf-xxx.tar.xz
ln -s qbpwcf-xxx trunk
ln -s trunk/qbpwcf
cd /usr/bin/
ln -s php56 php
ln -s /usr/lib/qbpwcf/usr/bin/parse
ln -s /usr/lib/qbpwcf/usr/bin/commit
ln -s /usr/lib/qbpwcf/usr/bin/diff.php
cp /usr/lib/qbpwcf/usr/local/etc/qbpwcf.conf.xml /usr/local/etc/qbpwcf.conf.xml
```

啟用各項服務
```
systemctl enable httpd mariadb sshd
```

編輯各項服務

vim /etc/httpd/conf/httpd.conf;
```
#
# AllowOverride controls what directives may be placed in .htaccess files.
# It can be "All", "None", or any combination of the keywords:
# Options FileInfo AuthConfig Limit
#
AllowOverride All
```

```
cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/aesopower.conf
```

vim /etc/httpd/conf.d/aesopower.conf
```
<VirtualHost *:443>
# General setup for the virtual host, inherited from global configuration
DocumentRoot "/var/www/html/latest"
ServerName aesopower-devel.qbpwcf.org:443
```

vim /etc/my.cnf.d/mariadb-server.cnf
```
# This group is only read by MariaDB servers, not by MySQL.
# If you use the same .cnf file for MySQL and MariaDB,
# you can put MariaDB-only options here
[mariadb]
port=3307
wait_timeout = 300
interactive_timeout = 300
max_allowed_packet = 100M
```

vim /etc/ssh/sshd_config
```
# If you want to change the port on a SELinux system, you have to tell
# SELinux about this change.
# semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
#
Port 2222
```

vim /etc/opt/remi/php56/php.ini
```
; This directive controls whether or not and where PHP will output errors,
; notices and warnings too. Error output is very useful during development, but
; it could be very dangerous in production environments. Depending on the code
; which is triggering the error, sensitive information could potentially leak
; out of your application such as database usernames and passwords or worse.
; For production environments, we recommend logging errors rather than
; sending them to STDOUT.
; Possible Values:
; Off = Do not display any errors
; stderr = Display errors to STDERR (affects only CGI/CLI binaries!)
; On or stdout = Display errors to STDOUT
; Default Value: On
; Development Value: On
; Production Value: Off
; http://php.net/display-errors
display_errors = On
….
[Date]
; Defines the default timezone used by the date functions
; http://php.net/date.timezone
date.timezone = Asia/Taipei
….
; Lifetime in seconds of cookie or, if 0, until browser is restarted.
; http://php.net/session.cookie-lifetime
session.cookie_lifetime = 300
….
```

vim /etc/cron.d/aesopower-cms-devcom 
```
#每天零時清理 14 天前沒有變動過的 Devcom log
0 0 * * * root find /var/log -type f -name "Devcom*" -mtime +14 -exec rm -rf {} \;
#每天零時清理 14 天前沒有變動過的 html log
0 0 * * * root find /var/log/lms -type f -name "*php" -mtime +14 -exec rm -rf {} \;
#每天零時清理 14 天前沒有變動過的 httpd log
0 0 * * * root find /var/log/httpd -type f -name "*_log*" -mtime +14 -exec rm -rf {} \;
#每天零時 5 分清理超過 10MB 的 journactl
5 0 * * * root journalctl --vacuum-size=10240000
#每天零時結算 node 的 power0,power1,usage-time
0 0 * * * root php -f /var/www/html/latest/index.php cron outturnLights
#每天 01 點時，針對每個活着的 gw 發送對時的指令
0 1 * * * root php -f /var/www/html/latest/index.php cron alignTime
```

vim /etc/httpd/conf.d/proxyPass.conf
```
ProxyPass "/wss" "ws://127.0.0.1:8088/"
ProxyPassReverse "/wss" "ws://127.0.0.1:8088/"
```

ssh 一連線就斷線
* 因為給予 container 的權限不夠。

啟動各項服務
```
systemctl start httpd mariadb sshd
```

設定資料密碼
```
mysqladmin -u root password 'password'

# 依照需要安裝 phpMyAdmin
# https://www.phpmyadmin.net/downloads/

# 目前 php56 僅支援 4.9.x 版。
# https://files.phpmyadmin.net/phpMyAdmin/4.9.7/phpMyAdmin-4.9.7-alllanguages.zip
```

```
cd /var/www/html/
wget https://files.phpmyadmin.net/phpMyAdmin/4.9.7/phpMyAdmin-4.9.7-all-languages.zip
unzip phpMyAdmin-4.9.7-all-languages.zip
ln -s phpMyAdmin-4.9.7-all-languages phpMyAdmin
chown -R apache.apache phpMyAdmin
```

svn check out code
▪ 記得安裝 svn 套件

```
dnf install subversion;
```

向管理者取得 host 端的 ssh private key.(id_rsa-jeff)

設置轉 port 的連線，以便我們於 client 端直接進行 svn 操作。

```
vim secure2-mobile.qbpwcf.org.sh
ssh -N -f -L 5956:localhost:59506 jeff@mobile.qbpwcf.org -p 8082 -i id_rsa-jeff
```

html 部分可以用以下操作進行 check out.
```
username=;
sshPort=;
key=;
svn co svn+ssh://${username}@localhost/var/svn/aesopower-cms/trunk --configoption="config:tunnels:ssh=ssh -p ${sshPort} -i ${key}";
```

在/var/www/html 底下 svn check out 完成後,進入 trunk 目錄，運行 createLink.sh 腳本
```
sh createLink.sh
```

在/var/www/html 底下建立設定好的網站目錄/var/www/html/latest
```
ln -s trunk latest 
```

db 部分可以用以下操作進行 check out.
```
username=;
sshPort=;
key=;
svn co svn+ssh://${username}@localhost/var/svn/aesopower-cms-db --configoption="config:tunnels:ssh=ssh -p ${sshPort} -i ${key}";
```

cron 部分可以用以下操作進行 check out.
```
username=;
sshPort=;
key=;
svn co svn+ssh://${username}@localhost/var/svn/aesopower-cms-cron/trunk --config-option="config:tunnels:ssh=ssh -p ${sshPort} -i ${key}";
```

devcom & other service
```
username=;
sshPort=;
key=;
svn co svn+ssh://${username}@localhost/var/svn/aesopower-cms-cmd/trunk --config-option="config:tunnels:ssh=ssh -p ${sshPort} -i ${key}";
```

參考資料
* https://www.cadch.com/modules/news/article.php?storyid=227 => 多種版本 php 支援。
* https://www.tecmint.com/fix-failed-to-set-locale-defaulting-to-c-utf-8-in-centos/ => vim 亂碼問題

------

遇到的問題

在 centos8 使用 systemctrl 卻出現 **Failed to connect to bus: No such file or directory**

解決辦法

https://github.com/geerlingguy/docker-fedora27-ansible/issues/2

------

虛擬機掛載資料夾

在OS X下，設定一個共享資料夾，與VirtualBox中Ubuntu系統共享檔案。

1：在主機中新建一個資料夾，作為存放共享檔案的資料夾。

2：在VirtualBox管理器中，選擇Ubuntu虛擬機器=>設定=>共享資料夾=>新增共享資料夾。
這裡寫圖片描述

在新建面板上，共享資料夾路徑中，選擇主機中共享資料夾。此時會自動生成一個共享資料夾名稱VirtualBox_VMs(可更改)。勾選自動掛載，固定分配選項。
這裡寫圖片描述

3：啟動Ubuntu虛擬機器，開啟終端。

用命令建立名為VMShared(可更改)的資料夾(非root使用者必須使用命令建立)：
```
$ sudo mkdir VMShared
```
然後執行掛載命令：

```
sudo mount -t vboxsf VirtualBox_VMs /home/username/VMShared
```

VMShared：步驟2中生成的共享資料夾名稱

/home/username/VMShared：以命令建立的共享資料夾的路徑

參考網址: https://www.itread01.com/content/1550532444.html

---------

將文件從主機複製到 Docker 容器中

您可以使用以下命令將文件從主機複製到 Docker 容器。Docker cp 示例：

```
# docker cp /host/path/target <containerId>:/file/path/within/container

$ docker cp 1 container_name:/tmp/
```

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

### poman 容器操作
列出所有的容器 ID

```
poman ps -aq
```
停止所有的容器
```
poman stop $(poman ps -aq)
```
删除所有的容器
```
poman rm $(poman ps -aq)
```
删除所有的鏡像
```
poman rmi $(poman images -q)
```
複製文件

```
poman cp mycontainer:/opt/file.txt /opt/local/
poman cp /opt/local/file.txt mycontainer:/opt/
```

----

### 使用他們的文件
下載 centos
```
podman run -i -t -d --net host --cap-add=all -e "container=podman" --restart always --name=aesopowerSdk --device /dev/fuse --entrypoint /sbin/init centos
```


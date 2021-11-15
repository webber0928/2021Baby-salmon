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

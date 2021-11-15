#!/bin/bash
containerName="aesopowerSdk"; #請輸入容器的名稱
image="centos"; #請輸入 image ID 或 名稱
cpuPoints="1024"; #1024 代表所有 cpu 資源
mem="2g"; #2g 代表 2GB 記憶體

podman run -i -t -d --net host --cap-add all -e "container=podman" --restart always --name=${containerName} --device /dev/fuse --entrypoint /sbin/init --cpu-shares=${cpuPoints} -m=${mem} ${image}

---
title: "immich导出相册"
description: ""
date: 2026-04-07T11:01:26+08:00
image: "image.png"
categories:
    - 技术分享
tags:
    - immich
readingTime: true
---


## 前言

之前有了nas后，我把老丈人的以前的硬盘里的照片全部导入immich了。

这里用的是[immich-cli](https://docs.immich.app/features/command-line-interface/)

两个命令就可以上传到immich server了
```
immich login http://192.168.1.216:2283/api HFEJ38DNSDUEG
immich upload --album-name "My summer holiday" --recursive directory/

```
但我家网络是我WireGuard连进内网使用的，老丈人上次听我说照片弄出来了，想弄到他手机上。我想着给他弄个wiregaurd，但是他手机提示不能安装这些，我也就不随意搞了。
想办法下载我手机上，然后面对面快传，或者u盘弄过去都行。

## 导出相册

我打开immich ios app，我之前是看到下载，但是我没看到导出整个相册，大概3000多个照片，手动下载太麻烦了。于是我就想到了immich-cli，看看能不能导出。

然而，immich-cli只有upload。没有download。傻了。

搜索一下，发现一个[immich-go](https://github.com/simulot/immich-go?tab=readme-ov-file)

看着有archive的功能。把immich相册导出到本地挂载的unraid的smb上，然后让手机直接从smb上拉取就行了。

现在挂在smb到本地,这里有个坑unraid好像不支持3.0,vers得是2.1,否则会提示找不到directory
```
mount -t cifs //unraid.lulu/unraid /mnt/nas \\n  -o username=xx,password=xx,vers=2.1
```

然后一行命令即可。

```
 ./immich-go archive from-immich --from-server=http://192.168.31.215:8080 --from-api-key=cCu4rm41ruHaG9Wz --from-albums="home" --write-to-folder=/mnt/nas
```

## immich app
为啥immich app没有全选这个功能啊，奇怪。
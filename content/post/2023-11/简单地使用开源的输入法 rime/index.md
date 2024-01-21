---
title: 简单地使用开源的输入法 rime
description: ""
date: 2023-11-19T21:21:57+08:00
image: https://gcore.jsdelivr.net/gh/shelken/picbed@main/uPic/2023-11/kFmrVz.png
math: 
license: 
hidden: false
comments: true
draft: false
categories:
  - 未分类
tags:
  - rime
  - 开源项目
  - 输入法
  - 多平台
  - git
  - 同步
slug: ""
noteId_x: 91
create_time: 11/19/2023, 9:21:57 PM
update_time: 1/22/2024, 1:46:38 AM
publish_time: 2023/11/19 21:21:57
---


> 这个项目帮助你：不需要配置复杂的配置；使用 git 来同步你的配置；及时地更新社区维护的词库

[仓库地址Rime auto deploy](https://github.com/Mark24Code/rime-auto-deploy) 

可以在项目的 readme 了解基本的用法，例如安装，升级等操作。这里我主要就常用的几个操作进行介绍来快速入门。

# 安装到你的新设备

在进行安装前，你应该将这个项目 fork 下来，方便我们后续的修改配置和同步配置

这里你只需要看项目的操作
- [MacOS/Linux 使用方法](https://github.com/Mark24Code/rime-auto-deploy#macoslinux-%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95) 这里告诉你基本的在新的设备上安装操作。记得 clone 自己的项目地址

# 配置

## 流程

> 当你需要自定义一些配置时，你只需要关注一个目录，那就是 custom 目录

1. 修改在 custom 目录下的配置文件
2. 重新运行 `installer. rb` ，选 2 手动模式，再选 4，复制你的配置到 rime 的配置。
3. 然后重新部署 rime。快捷键 ```alt + ctrl + ` ```
4. git add commit push

## 切换你的输入方案

如果你是个双拼用户，那么可以按  ``` ctrl + ` ``` 来让切换你的双拼方案

## 切换输入法时保存已经输入的字符

有时候，在输入中文时突然想要切换到英文。我的习惯是直接按右 `Shift` 来切换，但是初次使用时发现已经输入的字被清除了，这个时候需要在 `custom/default.custom.yaml` 去修改
在你的 `switch_key.Shift_R` 下，从 `clear` 改为 `commit_code` 

![image.png](https://gcore.jsdelivr.net/gh/shelken/picbed@main/PicGo/2023-11/c76a8a82.png)


## 在不同的应用中自动切换为中文或者英文输入法

在 `custom/squirrel.custom.yaml` 中添加你所安装的应用的配置，如下：

![image.png](https://gcore.jsdelivr.net/gh/shelken/picbed@main/PicGo/2023-11/aec9b6da.png)


## 不同设备同步词库

在你的 `/Users/[yourname]/Library/Rime` 目录下应该有 `installation.yaml` 文件，编辑它，将 `installation_id` 改为你喜欢的任意唯一的名，例如当前设备的名。在文件末尾加上 `sync_dir: "xxxx"` ，xxxx 为你需要存放的目录，例如 iCloud 云目录。保存后，点击同步用户数据，即可在存放的目录下看到 `installation_id` 为名的目录。

![DiQ1mQ](https://gcore.jsdelivr.net/gh/shelken/picbed@main/uPic/2024-01/DiQ1mQ.png)


# 参考

- [我的配置](https://github.com/shelken/rime-auto-deploy)
- [雾凇拼音配置](https://dvel.me/posts/rime-ice/)
️
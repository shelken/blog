---
title: gh/glab 命令快速上手
description: 简单说明 gh 和 glab 的常用命令
date: 2024-01-19T20:05:42+08:00
image: https://gcore.jsdelivr.net/gh/shelken/picbed@main/uPic/2024-01/6hNGCf.png
math: 
license: 
hidden: false
comments: true
draft: false
categories:
  - 教程
tags:
  - git
  - gh
  - glab
  - 命令
  - CheatSheet
slug: gh_glab
noteId_x: 93
create_time: 1/19/2024, 8:05:42 PM
update_time: 1/21/2024, 2:37:28 PM
publish_time: 1/19/2024, 8:05:42 PM
---
# 目的

- 快速创建 github 或者 gitlab 仓库，只使用命令行 gh 和 glab 的官方 cli 工具


# 安装

## macOS

```shell
brew install gh
brew install glab
```

# 命令

## 认证


```shell
gh auth login
```

![iqb5Cp](https://gcore.jsdelivr.net/gh/shelken/picbed@main/uPic/2024-01/iqb5Cp.png)

> 这里去 [token页面](https://github.com/settings/tokens) 创建所需 scopes 的 token

```
glab auth login
```

![oJfKuG](https://gcore.jsdelivr.net/gh/shelken/picbed@main/uPic/2024-01/oJfKuG.png)

> gitlab 如果是自建的可以选择自定义 hostname 
## 显示信息

```shell
# 列出repo信息
gh repo list
glab repo list
## gitlab 如果是自建的，执行前先把host设为你自建的, -g为全局
glab config set -g host xxxx.xxxx.com


# 搜索
## 搜索名为xxx的库
glab repo search -s xxx


# 查看项目的README信息
gh repo view
glab repo view

```


## 创建与变更仓库

```shell
# 克隆下某个仓库

gh repo clone xxx/xxxx 
glab repo clone xxx/xxxx
glab repo clone https://xxxxx
glab repo clone [id]

# 创建
## gh
### 此时目录下有个test-create-repo目录，test-create-repo 已经是个git仓库
### 将 test-create-repo 以私有的形式推送到github，此时gh会在远程创建一个test-create-repo的仓库
gh repo create --private --source=test-create-repo --push

### 创建一个 test-repo-create2 私密仓库，添加readme和描述，如下图。并克隆到本地
gh repo create test-repo-create2 -c --private --add-readme -d "测试远程仓库创建并克隆到本地"

## glab
### 在个人空间下创建私密仓库，create后面为路径以及在当前目录下的目录
glab repo create test-create-repo --private -n test-create-repo -d "测试在个人空间下创建私密仓库"
### 指定 组/空间
glab repo create test-create-repo -n test-create-repo -g xxx -d "测试在xxx组下创建仓库"



# 改变仓库的可见
## 将当前目录对应仓库转为公开
gh repo edit --visibility public
## 将指定仓库的可见性转为私密
gh repo edit shelken/test-create-repo --visibility private


# 删除
gh repo delete --yes
gh repo delete xxx/xxxx --yes

## 指定 空间/repo 删除
glab repo delete xxx/xxxx -y
## 指定 本人/repo 删除
glab repo delete xxxx -y
## 本目录对应repo删除
glab repo delete -y

```

![VdIPIR](https://gcore.jsdelivr.net/gh/shelken/picbed@main/uPic/2024-01/VdIPIR.png)


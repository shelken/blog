---
title: 如果你有一台PVE？怎么使用Terraform快速搭建开发用的云环境？
description: 
date: 2023-12-03T23:13:22+08:00
image: https://assets.shelken.top/ali/PicGo/2023-03/c3471413.jpeg
math: 
license: 
hidden: false
comments: true
draft: true
categories:
  - 开发
tags:
  - 开发
  - terraform
  - pve
  - rocky
  - linux
  - cloud-init
---

# 目的

1. 脱离 PVE WEB-UI 页面，快速创建我们需要的环境。
2. 使用 Terraform 将将流程更加自动化和可复现

# 概述

1. 下载你需要的云镜像。
2. 给镜像装上 qemu-guest-agent, 将镜像转为 template
3. 使用 terraform 快速部署

# 常见问题

## terraform 的 provider（telmate/proxmox）版本选择

建议使用 2.9.11 版本，最新版



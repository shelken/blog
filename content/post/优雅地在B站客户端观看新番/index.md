---
title: 优雅观看新番：B站客户端使用指南
description: 本文介绍了如何使用QuanX自动切换B站番剧代理节点，实现自动观看港澳台番剧的功能。需要修改原有脚本和添加重写与分流引用，并关闭MPM。文章提供了详细步骤和已知问题，适合有一定代码能力的用户使用。
slug: ""
date: 2022-04-01 00:00:00+0000
image: https://public.image.ooooo.space/PicGo/2023-11/bcff2d81.jpg
categories:
  - 追番
tags:
  - QuantumultX
noteId_x: 2
create_time: 3/8/2023, 1:23:56 AM
update_time: 2/2/2024, 8:30:31 PM
publish_time: 2022-04-01 00:00:00
---
## 声明

  不提供涉及 APP 的下载及其他使用教程

## 前提

1. 知道 QuanX 的基本使用逻辑，以及基本的概念
2. 有自我修改部分代码能力和上 github 或者其他托管代码平台的能力

## 学习资源来源

- [脚本原作者仓库](https://github.com/NobyDa/Script "脚本原作者仓库")
- [Bili_Auto_Region 脚本](https://github.com/NobyDa/Script/blob/master/Surge/JS/Bili_Auto_Regions.js "Bili_Auto_Region脚本")

## 效果

### 效果 1

1. 进入 B 站客户端
2. 进入『首页』，点击『追番』
3. 找到番剧『进击的巨人最终季』![19CC3738-4345-4CAB-896F-A21B8B051B7C_1_201_a](https://public.image.ooooo.space/PicGo/2023-11/bcff2d81.jpg)
4. 点击进入，脚本会自动将代理节点切换设置的代理分组![9C12ABCB-933D-4C5D-8660-390BAFF3631B_1_201_a](https://public.image.ooooo.space/PicGo/2023-11/f842d577.jpg)
5. 如果出现『找不到页面』，点击页面的『重新加载』或刷新页面，进入番剧观看页面，正常观看![E0691890-CF30-4798-8B4C-4E3FBD6AB387_1_201_a](https://public.image.ooooo.space/PicGo/2023-11/eba838c0.jpg)
6. 退出观看页，脚本自动切换为直连![3D637A3B-F675-4DA0-B67E-E697B6FB1953_1_201_a](https://public.image.ooooo.space/PicGo/2023-11/24ec06dc.jpg)

### 效果 2

1. 进入 B 站客户端
2. 点击『输入框』
3. 输入『进击的巨人 港』
4. 脚本自动切换代理分组
5. 页面显示『进击的巨人』番剧结果![941D38C8-4229-4899-9A34-9A25D070B229_1_201_a](https://public.image.ooooo.space/PicGo/2023-11/60b7f5f4.jpg)
6. 点击『立即观看』，进入观看页

## 优点

- 不用再每次看港澳台番剧时自己手动切成全局，看完后又切换回规则模式，全自动。

## 实践

### 准备

- 带有 ios 系统的 iPhone
- 一个 QuanX App
- 『Bili_Auto_Region 脚本』

### 修改原有脚本

1. 到『脚本原作者仓库』，fork 该仓库

2. 加入『StreamingSE』规则集（必须）

   ```
   # 绑定相关select或static策略组，并且需要具有相关的区域代理服务器纳入您的子策略中，子策略可以是服务器也可以是其他区域策略组．
   https://raw.githubusercontent.com/DivineEngine/Profiles/master/Quantumult/Filter/StreamingMedia/StreamingSE.list
   ```

3. 设置该规则集的『策略偏好』为自己的『父策略组』（例如我设为 『BiliGroup』）

4. 添加几个子策略组（如台湾 or 香港）（这里涉及到策略组的节点选择策略，自己了解）

5. 修改 **Surge/JS/Bili_Auto_Regions.js**，提交更改

   ```javascript
   //找到如下代码块，删除如下中文，修改成自己创建的策略组名
   	const Group = $.read('BiliArea_Policy') || '你的父策略组（BiliGroup）'; //Your blibli policy group name.
   	const CN = $.read('BiliArea_CN') || 'DIRECT'; //Your China sub-policy name.
   	const TW = $.read('BiliArea_TW') || '台湾子策略组'; //Your Taiwan sub-policy name.
   	const HK = $.read('BiliArea_HK') || '香港子策略组'; //Your HongKong sub-policy name.
   	const DF = $.read('BiliArea_DF') || '请求失败后的策略组'; //Sub-policy name used after region is blocked(e.g. url 404)
   	const off = $.read('BiliArea_disabled') || '在某些wifi下不转换策略组'; //WiFi blacklist(disable region change), separated by commas.
   	const current = await $.getPolicy(Group);
   ```

6. 在 **QuantumultX/** 目录下（或其他目录），新增两个文件，一个『分流』，一个『重写』，举例：

   ```
   #『重写』引用：Bili_Region.conf
   # start-------------
   hostname = ap?.bilibili.com, ap?.biliapi.net
   ^https:\/\/ap(p|i)\.bili(bili|api)\.(com|net)\/(pgc\/view\/v\d\/app\/season|x\/v\d\/search\/defaultwords)\?access_key url script-response-body https://raw.githubusercontent.com/你的用户名/Script/master/Surge/JS/Bili_Auto_Regions.js
   # 适用于搜索指定地区的番剧（该脚本为『效果2』的实现，根据自身需要选择）
   ^https:\/\/ap(p|i)\.bili(bili|api)\.(com|net)\/x\/v\d\/search(\/type)?\?.+?%20(%E6%B8%AF|%E5%8F%B0|%E4%B8%AD)& url script-request-header https://raw.githubusercontent.com/你的用户名/Script/master/Surge/JS/Bili_Auto_Regions.js
   # end--------------

   #『分流』引用：Bili_Region.list
   # start-----------------
   ip-cidr, 203.107.1.1/24, reject
   # end--------------------
   ```

7. 打开 App；将以上两个文件『分流』与『重写』分别引用；

8. 最后，在 QuanX -> 其他设置 -> VPN 中，关闭 MPM（温和策略机制）

9. 至此，所有需要做的都已经完成，此时，进入 B 站客户端，实现以上的效果

## Why？

> 为什么？这部分将对『实践』中的部分操作做解释。

1. 为什么 fork 仓库？

   ```
   因为需要修改原脚本相关分组的名字，这部分由自己定义；而且涉及到『重写』与『分流』引用，虽然不是必须，但是强烈建议这样做；可以方便地管理这些规则的开关；
   ```

2. 为什么关闭 MPM

   ```
   主要是在切换策略时打断之前的连接，让策略生效（个人认为）
   ```

## 已知问题

1. 在长时间使用 B 站一段时间后，会发现脚本有失效情况，这个时候退出 B 站重新进入可以解决。

## 最后

如果有代码方面的时候问题，请到原作者脚本仓库上提 issue。

如果有关于以上实践部分的问题，可以在下方评论提问。本教程也是参考了原脚本的注释部分，自己实践得来，建议在问之前把注释看一遍；不提供除实践部分之外的问题。如果是我知道的，我会提供关键词给你，然后请自己去问谷歌。

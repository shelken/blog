---
title: qBittorrent的RSS订阅下载指南
description: 本文介绍了如何使用 qBittorrent 自动下载订阅的资源，包括开启 rss 订阅、订阅 RSS 链接、定义下载规则等步骤。通过这些操作，用户可以方便地获取自己需要的资源，并节省大量时间和精力。
slug: qBittorrent的RSS的订阅下载指南
date: 2022-05-14 00:00:00+0000
image: cover.png
categories:
    - 追番
tags:
    - qBittorrent
    - RSS
---

# 材料

- qBittorrent（[wiki](https://zh.wikipedia.org/zh-cn/QBittorrent "wiki")）（以下简称 qb）
- 支持 rss 订阅的种子站（e.g. [nyaa](https://nyaa.si/ "nyaa")([wiki](https://zh.wikipedia.org/wiki/Nyaa_Torrents "wiki"))）

# 实现

- 打开 qb 配置页面，我的是部署在群晖的 qb，因此使用 web 页面来管理；如果是程序也一样。将启用 rss 订阅打开，间隔与数目最大值根据自定，然后将下面的「自动下载」打开，打开后我们才能在 rss 订阅更新时自动下载你订阅的资源。

  ![image-20220514141431969](https://assets.shelken.top/gh/PicGo/2023-03/d5a0c33e.png)

- 然后点右侧的 「RSS」

  ![image-20220514142037691](https://assets.shelken.top/gh/PicGo/2023-03/0ca90876.png)

- 然后我们先离开一下 qb，去你需要订阅资源的 bt 下载站。这里以我自己的需求做演示，我们来到「nyaa」;

- 首先，我确定了我需要的订阅的内容：是`喵萌奶茶屋字幕组`翻译的`夏日重现`，并只要 `1080p` 的资源内容。这里我搜索「喵萌奶茶屋 夏日重现 1080p」，可以看到结果非常符合我的预期。因为字幕组的命名基本是固定的，所以这个搜索结果基本是稳定的。

  ![image-20220514142759551](https://assets.shelken.top/gh/PicGo/2023-03/e3e1cde1.png)

- 点击 RSS

![image-20220514143533237](https://assets.shelken.top/gh/PicGo/2023-03/d2fda6bc.png)

- 可以看到地址 url 变了，因此我们知道，只要在原来的内容加上`page=rss`，那么就拿到我们的 `rss` 订阅地址

  ```
  原 url：
  https://nyaa.si/?f=0&c=0_0&q=%E5%96%B5%E8%90%8C%E5%A5%B6%E8%8C%B6%E5%B1%8B+%E5%A4%8F%E6%97%A5%E9%87%8D%E7%8E%B0+1080p
  
  新 url:
  https://nyaa.si/?c=0_0&f=0&q=%E5%96%B5%E8%90%8C%E5%A5%B6%E8%8C%B6%E5%B1%8B+%E5%A4%8F%E6%97%A5%E9%87%8D%E7%8E%B0+1080p&page=rss
  ```

* 回到 qb 界面，订阅 rss

  ![image-20220514150256737](https://assets.shelken.top/gh/PicGo/2023-03/8bc31601.png)

* 然后打开`rss下载器`，新建一个下载规则；这里我讲解一下规则定义。

  ![image-20220514150525225](https://assets.shelken.top/gh/PicGo/2023-03/cb8e6712.png)

 `空格`代表`与`关系，即这些关键词都必须有才匹配上。`|`代表`或`关系，即只要有一个关键词命中就匹配，`?`代表一个字符，`*`代表 0 或多个字符。这里我们甚至可以使用正则表达式，能实现更加复杂的限制。

 这里我的`必须包含`则进一步限制当前规则的下匹配资源的条件。`必须不含`里的`合集`则是考虑到字幕组会在番剧结束后打包一个合集目录，一次我们把带有`合集`字样的资源排除掉。由于我之前下载过这些剧集，因此我把 1-3 的内容也排除掉。`剧集过滤器`在这里是没用的，因为大部分番剧字幕组没有按照欧美剧集的格式来命名（形如：S01E01）。因此这里没有作用。`分类`与`保存目录`可以自定义。可能你的每个规则对应多个 rss 订阅，也可以只对应一个 rss 订阅，这里完全看自己习惯和方式，`添加后不开始下载`这里我选择从不，这样会关联规则和订阅后，自动下载未下载过的匹配的订阅资源。`布局`按全局就行，不是那么重要。

- 然后将你`配置好的规则`和你`订阅的RSS链接`进行关联，保存

  ![image-20220514152624596](https://assets.shelken.top/gh/PicGo/2023-03/b3c9322f.png)

- 至此，你的 qb 每隔 xx 分钟去刷新订阅，当有新资源发布在种子网站时，qb 会自动下载符合你定义的资源，并保存在你定义的目录下。

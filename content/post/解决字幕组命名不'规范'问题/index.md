---
title: 解决字幕组命名不'规范'问题
description: 解决字幕组命名不'规范'问题
slug: 解决字幕组命名不'规范'问题
date: 2022-05-15 00:00:00+0000
image: cover.jpg
categories:
    - 追番
tags:
    - 开源项目
    - qBittorrent
---
# 材料

- [Episode-ReName](https://github.com/Nriver/Episode-ReName "Episode-ReName")（以下简称 er）
- [qBittorrent](https://zh.wikipedia.org/zh-cn/QBittorrent "qBittorrent")（以下简称 qb）

# 背景

 很多字幕组种子的命名格式往往不是按照`SxxExx`的格式来命名的，而 Emby，Plex 等媒体服务器都是以识别`SxxExx`来刮削剧集的元数据。因此为了让这些媒体服务器识别剧集，我们往往需要重命名下载的文件。

# 期望

 qb 下载剧集后，自动将不符合的资源名命名为形如`'剧集名 - SxxExx.mp4'`

# 实践

## 流程

1. 克隆 er 源代码,使用 pyinstaller 将 EpisodeReName.py 编译成可执行程序。（作者在原仓库有提供 windows 的，win 用户可以直接下载使用，我是 linux 环境，因此自己编译）,将可执行程序放到你想要它在的文件夹下面（我直接上传群晖下的文件夹）
2. 设置 qb 下的「Torrent 完成时运行外部程序」，填入程序路径和必要参数

## 编译可执行程序

 win 用户跳过此步骤，直接在原仓库下载作者提供的程序；linux 用户可以直接在本地使用 pyinstaller 来操作编译（docker 也行）。如果是 mac 用户则可以使用 docker 镜像来编译 linux 程序。m1 用户建议换台电脑，目前 docker 镜像编译有问题

```shell
cd /你的工作目录
# 拉取源代码
git clone https://github.com/Nriver/Episode-ReName.git
cd Episode-ReName
# 安装所需 requirements （requirements中包含了pyinstaller，如果是docker编译，可以把pyinstaller去掉）
pip3 install -r requirements.txt
# 编译（非docker方式）
pyinstaller -F EpisodeReName.py
# 编译（docker方式）
docker run -v "$(pwd):/src/" cdrx/pyinstaller-linux
# 移动编译后程序到你想要的文件夹。
mv ./dist/linux/EpisodeReName anywhere
# 我是在mac上编译的，因此把它复制到我的群晖上
scp ./dist/linux/EpisodeReName shelken@192.168.0.80:/volume1/docker/qb-web/script/Episode-ReName/dist/EpisodeReName
```

## 设置 qb 执行程序

 打开工具->选项->下载。开启「Torrent 完成时运行外部程序」，填入你的程序地址

![image-20220515171458914](https://shelken-bucket.oss-cn-hongkong.aliyuncs.com/uPic/image-20220515171458914.png)

 参数解释：

```
qb参数：
%F：如果种子是单文件的，那么输出则为：/保存路径/xxxxx.mp4；如果是多文件。那么则会是: /保存路径/根目录名。
er参数：（这部分详细可以去看原文档，这里只介绍我使用的）
--path：目标路径，可以是单文件，可以是目录，目录会处理所有该目录下文件
--delay: 延迟多久操作，默认为0秒不等待，这个参数主要是配合qbitorrent使用, 避免qb锁定文件导致重命名失败. 一般停止做种15秒后在操作能确保文件被释放
--name_format：自定义重命名格式, 参数需要加引号 默认为 "S{season}E{ep}" 可以选择性加入 series系列名称 如 "{series} - S{season}E{ep}"。这里我使用了第二种格式。
举例:
/volume1/docker/qb-web/script/Episode-ReName/dist/EpisodeReName --path="%F" --delay=15 --name_format="{series} - S{season}E{ep}"
```

# 技巧

## 查看 qb 日志

```shell
# volume1：取决于你套件安装在哪个存储空间
cat /volume1/\@appstore/qBittorrent/qBittorrent_conf/data/logs/qbittorrent.log
```

## 给可执行程序赋权

```shell
# 如果不能执行程序，尝试给EpisodeReName执行程序赋予可执行权限
chmod +x /所在目录/EpisodeReName
#
```

## 多季番剧tmdb集数适配

对于有多季的番剧, 比如鬼灭之刃28集, 在tmdb里没有第28集, 而是第2季第2集, 要正确削刮需要从S02E28改成S02E02.

这时候可以在鬼灭之刃的`Season 2`文件夹中添加一个`all.txt`文件, 里面写上一个数字, 会在自动重命名的时候减掉这个数字. 比如上面的例子就需要在`all.txt`填入26, 自动重命名就会把S02E28改成S02E02, 这样就能正常削刮了.

# 注意

## 文件夹命名格式

剧名和季数是根据文件夹命名来识别的，集数是根据文件名的数字。

### 剧名与季数

形如：/剧集目录/剧名/Season 1/

季数命名格式要求：Season1 / Season 1 / s1 / S1

举例：/volume1/Video/watch/夏日重现/s1

### 集数

形如：/剧集目录/剧名/Season 1/xxxx[01]xxxxxx.mp4

集数命名匹配的正则：会匹配在括号（各种括号）内的数字，数字规则如下，以找到的第一个符合项作为集数

```python
patterns = [
        # 1到4位数字
        '(\d{1,4}(\.5)?)',
        # 特殊文字处理
        '第(\d{1,4}(\.5)?)集',
        '第(\d{1,4}(\.5)?)话',
        '第(\d{1,4}(\.5)?)話',
        '[Ee][Pp](\d{1,4}(\.5 "Ee][Pp")?)',
        '[Ee](\d{1,4}(\.5 "Ee")?)',
        # 兼容SP01等命名
        '[Ss][Pp](\d{1,4}(\.5 "Ss][Pp")?)',
        # 兼容v2命名
        '(\d{1,4}(\.5)?)[Vv]?\d?',
]

```

举例:

```shell
# 输入：/volume1/Video/watch/夏日重现/s1/[Nekomoe kissaten][Summer Time Rendering][05][1080p][JPSC].mp4
# 输出：/volume1/Video/watch/夏日重现/s1/夏日重现 - S01E05.mp4
```

## 做种问题

 qb 的「Torrent 完成时运行外部程序」功能，会在下载完资源的时候，立刻去执行程序，也就是说在下载完之后，我们的文件会被立刻重命名，这导致了我们做种会出现问题，因此我们无法做到下载后再把这个资源分享给其他人。目前也没有好的方式解决。可以考虑不是呀 qb 的这个功能，直接定时任务去执行程序，扫描固定的目录来重命名。

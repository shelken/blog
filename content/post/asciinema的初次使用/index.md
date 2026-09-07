---
title: Asciinema 的初次使用
description: 记录 Asciinema 终端录制工具的使用方法，以及在 Hugo 中使用官方 Standalone 播放器实现本地权威录制嵌入的完整流程。
date: 2023-03-05T03:04:46+08:00
slug: asciinema的初次使用
image: https://cdn.jsdelivr.net/gh/shelken/picbed/uPic/2023-11/hqH7rN.png
math:
license:
hidden: false
comments: true
draft: false
---

## 方案选择

在静态博客中嵌入终端操作录制时，常见方案存在以下差异与权衡：

- **asciinema.org 远程嵌入 (`<script src=".../a/123.js">`)**：依赖远程第三方服务分发，受制于外网连接速度与服务可用性，且受限于远程脚本的样式注入。
- **npm / 打包工具集成**：通过前端构建链引入播放器，对于纯 Hugo 静态博客引入了多余的 Node/Bun 打包流程与依赖开销。
- **第三方 Hugo 模块 (如 `gohugo-asciinema`)**：通常更新滞后，采用模板字符串拼接播放器参数，缺乏 SRI 完整性校验与轻量化的按需加载控制。
- **官方 Standalone 播放器与本地权威（本站方案）**：固定官方 standalone 版本的 JS 和 CSS 在线引入（v3.17.0 固定版本并附带 SRI 完整性校验）；博客文章作为 Leaf Bundle 自包含 `.cast` 文件，确立本地文件为绝对发布权威；不引入多余前端构建链或仓库二进制，仅在含播放器的页面按需注入资源，保持播放器官方默认渲染。

## 安装与检查

在 macOS 上推荐通过 Homebrew 安装：

```bash
brew install asciinema
```

Linux 与其他操作系统的安装方式可参考官方 [CLI Installation](https://docs.asciinema.org/manual/cli/installation/) 指南。

安装后可通过命令检查已安装的 CLI 版本：

```bash
asciinema --version
```

## 录制与本地回放

本站采用 Hugo Leaf Bundle 组织文章，录制文件直接保存在文章目录下，与 `index.md` 相邻。

进入目标文章目录执行录制：

```bash
# 进入文章目录
cd content/post/<文章目录>/

# 开始录制终端操作并保存到 demo.cast
asciinema rec demo.cast
```

终端提示录制已开始后即可执行操作。全部命令完成后，输入 `exit` 或按下 `Ctrl+D` 结束录制。

录制完成后，可以在终端中直接回放确认效果：

```bash
asciinema play demo.cast
```

如果一篇文章包含多个录制片段，应使用能够表达具体操作内容的 kebab-case 命名（例如 `install-docker.cast`、`deploy-cluster.cast`），与文章存放在同一目录下，避免集中堆放到全局静态资源目录。

## 上传分享镜像

本地保存的 `.cast` 文件是博客发布与回放的唯一权威源。如果希望生成一个可在外网独立访问与分享的网页链接，可将其作为镜像上传到 asciinema.org。

首次上传前，建议先绑定个人账号（未绑定账号的匿名上传会在 7 天后自动删除）：

```bash
asciinema auth
```

根据终端输出的认证链接在浏览器中登录并完成绑定。随后上传录制文件：

```bash
asciinema upload demo.cast
```

上传成功后会输出公开分享链接（形如 `https://asciinema.org/a/<id>`）。注意：该远程链接仅作为外部镜像，文章内的播放器始终使用本地 `.cast` 文件。

## 在 Markdown 中嵌入

在文章正文中，使用站内 shortcode 进行单行嵌入：

```markdown
{{</* asciinema src="demo.cast" */>}}
```

对应的 Leaf Bundle 目录结构如下：

```text
content/post/asciinema的初次使用/
├── index.md
└── demo.cast
```

在 Zed 或 Obsidian 中编写文章时，直接编辑上述单行 shortcode 即可。Obsidian 承担文本编辑，不承担播放器预览，无需安装专用播放器插件或维护扩展模板。

## Hugo 预览

在博客仓库根目录下启动本地预览服务器：

```bash
hugo server
```

在浏览器中打开文章页面即可查看播放器渲染效果。站内 shortcode 默认应用以下配置：

- `poster: "npt:0:01"`：截取第 1 秒的终端画面作为封面，避免未播放时黑屏。
- `autoPlay: false`：默认不自动播放，由读者按需点击播放。
- `idleTimeLimit: 2`：限制操作间隔等待时间上限为 2 秒，加快等待过程的回放。
- **录制主题优先**：优先读取 cast 中保存的原生终端主题，未记录时回退至 Monokai。
- **尺寸自适应**：自动读取 cast 保存的实际行列数，无需手动固定 rows 或 cols。

## 字体与图标说明

终端录制文件（`.cast`）仅记录终端输出的原始字符码点，并不包含字体数据。

本站遵循 asciinema 官方设计哲学，不加载、不分发也不假设任何特定字体，播放器直接使用其内置的默认等宽字体栈（如 ui-monospace, SF Mono, Menlo, Consolas 等，与 asciinema.org 行为一致）。终端提示符中的特殊字形（如 Powerline 分隔符、各类 Nerd Font 图标或 Unicode 私有区字符）由读者本机操作系统已安装的终端字体呈现；若读者设备未安装相关字体，则按浏览器默认字符回退显示。

## 示例

以下为当前文章目录下的本地权威 `demo.cast` 实际渲染效果：

{{< asciinema src="demo.cast" >}}

- 远程分享镜像：[https://asciinema.org/a/564652](https://asciinema.org/a/564652)

## 参考资料

- [asciinema Getting Started](https://docs.asciinema.org/getting-started/)
- [asciinema CLI Quick Start](https://docs.asciinema.org/manual/cli/quick-start/)
- [asciinema CLI Installation](https://docs.asciinema.org/manual/cli/installation/)
- [asciinema Player Quick Start](https://docs.asciinema.org/manual/player/quick-start/)
- [asciinema Player Fonts](https://docs.asciinema.org/manual/player/fonts/)
- [asciinema Player Options](https://docs.asciinema.org/manual/player/options/)
- [Hugo Shortcode Templates](https://gohugo.io/templates/shortcode/)

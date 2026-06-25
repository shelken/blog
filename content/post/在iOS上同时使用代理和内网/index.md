---
title: 在 iOS 上同时使用代理和内网
description: iOS 只能同时运行一个 VPN，想代理常驻又内网可达怎么办？这篇文章分享一种思路：借助 Loon/Surge 这类代理软件，在代理隧道里直接回自己的内网。
date: 2026-06-25T00:00:00+08:00
image: https://cdn.jsdelivr.net/gh/shelken/picbed/cover/blogs/2026-06/ios-proxy-internal-network.png
math:
license:
hidden: false
comments: true
draft: false
categories:
  - 网络
tags:
  - Loon
  - iOS
  - Shadowsocks
  - 内网
---

## 问题

iOS 只能同时运行一个 VPN。这意味着如果你全天开着代理（比如 Loon、Surge、Stash），就没法同时挂着 Tailscale 访问家里内网。

一种思路是用 Surge/Stash 配合 WireGuard 配一个 Tailscale 网关节点来访问内网，Surge Mac 也支持内置的 Tailscale 协议。如果用的是 Loon，或者想保持更灵活的控制，可以让代理隧道直接通到内网。

在 VPS 或家里的服务器上搭一个代理服务端（Shadowsocks / Hysteria2 之类），iOS 上的 Loon 连过去，然后在 Loon 里配规则——只有内网域名走这条代理隧道，其余流量照常出站。

这样同时得到了：
- 代理常驻（蜂窝下代理不断）
- 内网可达（DNS 由代理服务端负责解析）
- 不需要额外 VPN 开销

---

## 一、Loon 配置

### 节点

你只需要一个能访问你内网的代理节点。以 Shadowsocks-rust 为例：

```
ss-rust = shadowsocks, <你的IPv6地址>, 55483, "2022-blake3-aes-256-gcm", "<密码>", udp=false
```

如果有多个入口（VPS v4 + 集群 v6），可以配多个节点，但一般用户一个就够了。

### 策略组

关键是用 SSID 策略组。这个策略组能根据当前网络环境切换行为：

- **在常用内网 WiFi 下** → 直连（不需要走代理回内网）
- **默认** → 走代理节点
- **蜂窝数据** → 也走代理节点

示意图：

```
策略组: 内网访问
├── WiFi（内网 SSID） → DIRECT
├── 蜂窝数据 → ss-rust 节点
└── 默认 → ss-rust 节点
```

### 规则

然后配置规则，让内网域名走这个策略组：

```
DOMAIN-SUFFIX, <你的内网域名>, 内网访问
DOMAIN-SUFFIX, lan, 内网访问
DOMAIN-SUFFIX, local, 内网访问
```

这样在蜂窝下访问 `https://<内网服务>.<内网域名>` 时，Loon 把请求发给 ss-rust 节点，服务端解密后去解析域名、建立连接。

> 如果想用 IP 而非域名直接访问，需要检查 Loon 的 `[General]` 中 `bypass-tun` 配置。Loon 默认排除了 `192.168.0.0/16` 等私有 IP 段，这些 IP 不会进入策略引擎。把内网段从 `bypass-tun` 去掉，就能配 `IP-CIDR` 规则走代理了。

---

## 二、服务端部署：Shadowsocks-rust

服务端选 shadowsocks-rust。轻量、稳定，服务端只有一个二进制，2022 AEAD 加密比旧版更安全。

用 Docker Compose 部署。

### 目录结构

```
ss-rust/
├── docker-compose.yml
├── config/
│   └── config.json
```

### config.json

```json
{
  "server": "::",
  "server_port": 55483,
  "method": "2022-blake3-aes-256-gcm",
  "password": "<你的密码>",
  "mode": "tcp_only",
  "fast_open": true
}
```

`server: "::"` 表示绑定双栈，v4 和 v6 都能连。如果你的机器只有 v4，写 `"0.0.0.0"`。

密码由 openssl 生成 32 字节的 Base64 密钥：

```shell
openssl rand -base64 32
```

### docker-compose.yml

```yaml
services:
  ss-rust:
    image: ghcr.io/shadowsocks/ssserver-rust:v1.24.0
    container_name: ss-rust
    restart: always
    ports:
      - "55483:55483/tcp"
    volumes:
      - ./config/config.json:/etc/shadowsocks-rust/config.json:ro
    command:
      - ssserver
      - -c
      - /etc/shadowsocks-rust/config.json
```

启动：

```shell
docker compose up -d
```

### DDNS

如果服务器没有固定 IP，可以用 DDNS 配合 cloudflare-ddns：

```yaml
services:
  # ... ss-rust 同上 ...

  ddns:
    image: docker.io/favonia/cloudflare-ddns:1.16.2
    restart: always
    environment:
      CLOUDFLARE_API_TOKEN: <你的 CF API Token>
      DOMAINS: ss-rust.<你的域名>
      PROXIED: "false"
      IP4_PROVIDER: "none"
      IP6_PROVIDER: "url:https://api6.ipify.org"
      UPDATE_CRON: "@every 5m"
      UPDATE_ON_START: "true"
      QUIET: "true"
```

公网 v6 变化时，`ss-rust.<你的域名>` 自动更新 DNS 记录，Loon 里填域名而非 IP 也能正常连接。

### 防火墙

开端口：

```shell
# ufw
ufw allow 55483/tcp

# firewalld
firewall-cmd --add-port=55483/tcp --permanent
firewall-cmd --reload
```

如果服务跑在路由器后面（比如 OpenWrt），可以在路由器防火墙上用 MAC 地址匹配放行。IPv6 地址经常变更，但接口标识符（EUI-64）来自 MAC 地址保持不变。OpenWrt 的规则写法：

```shell
uci add firewall rule
uci set firewall.@rule[-1].name='ss-rust'
uci set firewall.@rule[-1].family='ipv6'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest='lan'
uci set firewall.@rule[-1].dest_port='55483'
uci set firewall.@rule[-1].proto='tcp' 'udp'
uci set firewall.@rule[-1].dest_ip='::<接口标识符>/::ffff:ffff:ffff:ffff'
uci set firewall.@rule[-1].target='ACCEPT'
uci commit firewall
/etc/init.d/firewall reload
```

接口标识符由设备 MAC 转 EUI-64 得到，比如 MAC `02:2f:3e:e3:c3:b0` 对应 `::2f:3eFF:fee3:c3b0`。这样不管 IPv6 前缀怎么变，路由器的防火墙都能正确放行。

---

## 三、DNS 配置

代理需要知道内网域名对应哪个 IP，分两种情况。

### 情况一：代理服务端在内网（或集群里）

服务端直接能用内网 DNS 解析。比如 Shadowsocks-rust 跑在 Kubernetes 里，Pod 的 CoreDNS 天然能解内网域名。什么都不用配。

### 情况二：代理服务端在 VPS（不在内网）

VPS 上的普通 DNS 解析不到内网域名。需要在 VPS 上配一个内网 DNS 服务器。

我用 Docker dnsmasq 来处理：

```yaml
services:
  dnsmasq:
    image: jpillora/dnsmasq:latest
    container_name: dnsmasq
    restart: always
    ports:
      - "53:53/udp"
      - "53:53/tcp"
    volumes:
      - ./dnsmasq.conf:/etc/dnsmasq.conf:ro
    cap_add:
      - NET_ADMIN
```

dnsmasq.conf：

```
# 内网域名走内网 DNS 服务器
server=/<你的内网域名>/<内网DNS服务器IP>
# 其他域名走公共 DNS
server=1.1.1.1
server=8.8.8.8
```

然后把代理容器（ss-rust、hysteria2 等）的 DNS 指向 dnsmasq：

```yaml
services:
  ss-rust:
    # ... 其他配置 ...
    dns:
      - <dnsmasq 容器 IP>
```

或者在 Docker daemon 层面做全局 split DNS。dnsmasq 容器加 `dns` 字段的方式最灵活，也最容易排查。

---

## 四、局限与后续

- **v6 依赖**：移动网络没 v6 的话，Shadowsocks 走不通。这时需要 v4 入口（比如 VPS 上跑 Hysteria2），VPS 再通过某种连接回内网。本质一样，拓扑多了一跳。
- **IP 直接访问**：Loon 的规则可以用 IP-CIDR 匹配内网段，但需要先从 `bypass-tun` 中移除对应私有 IP 范围。
- **UDP**：本文只处理 TCP，Shadowsocks 配置也用了 `tcp_only`。需要 UDP（比如 DNS 查询），配置更复杂，暂不展开。

Surge Mac 支持内置 Tailscale 协议，Surge/Stash iOS 也可以通过 WireGuard 配置 Tailscale 网关来访问内网。希望 Loon 后续也能加入类似的支持。

---

## 参考

- [shadowsocks-rust GitHub](https://github.com/shadowsocks/shadowsocks-rust)
- [Loon 文档](https://loon.run)
- [cloudflare-ddns](https://github.com/favonia/cloudflare-ddns)
- [home-ops](https://github.com/shelken/home-ops) — 本文涉及的 ss-rust、hysteria2、dnsmasq 等完整部署配置

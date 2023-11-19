---
title: 在不用Tailscale的情况下使用Tailscale
description: 本文介绍了如何利用 Tailscale 的 funnel 功能，将本地部署的 headscale 开放到公网，从而解决 headscale 部署需要公网 IP 的限制。通过这种方式，可以使用 headscale 来让设备加入节点，而不需要使用 Tailscale。
date: 2023-04-05T17:12:29+08:00
image: https://assets.shelken.top/ali/PicGo/2023-03/c3471413.jpeg
math: 
license: 
hidden: false
comments: true
draft: false
categories:
  - 未分类
tags:
  - Tailscale
  - Headscale
---

众所周知，headscale 可以解决 Tailscale 的一些限制，例如设备数。但是 headscale 部署需要一个公网 IP。最近，Tailscale 的 Funnel 进入 beta 测试了，刚好又看到一个大佬写了一篇利用 Tailscale 的 Funnel，将本地部署的 headscale 开放到公网的文章 [Using Tailscale without using Tailscale](https://tailscale.dev/blog/headscale-funnel)。这意味着我们可以使用 Tailscale 让人们通过互联网访问我们搭建的 headscale，并且只使用 headscale 来让设备加入节点。感觉有点像背叛 Tailscale 官方啊，可怜三秒。

接下来简单介绍一下操作步骤。

1. 先在任意一台自己的本地机器起一个最新稳定版 Tailscale。

安装命令

```shell
curl -fsSL https://tailscale.com/install.sh | sh
```

2. 再起一个 headscale，这里我用 docker-compose 部署，这里我大部分参考了官方的[教程](https://github.com/juanfont/headscale/blob/main/docs/running-headscale-container.md)
另外，单独起了一个 [webui](https://github.com/iFargle/headscale-webui/blob/main/SETUP.md#docker-compose) 方便查看

```yml
version: '3.8'
services:
  headscale:
    image: 'headscale/headscale:latest'
    container_name: headscale
    volumes:
      - /data/docker/headscale/config:/etc/headscale/
    environment:
      - TZ=Asia/Shanghai
    ports:
      - '9090:9090'
      - '8080:8080'
    restart: always
    command: headscale serve
  headscale-webui:
    image: ghcr.io/ifargle/headscale-webui:latest
    container_name: headscale-webui
    restart: always
    ports:
      - '8083:5000'
    environment:
      - TZ=Asia/Shanghai
      - COLOR=red                              # Use the base colors (ie, no darken-3, etc) -
      - HS_SERVER=http://headscale:8080    # Reachable endpoint for your Headscale server
      - DOMAIN_NAME=http://headscale-webui:5000  # The base domain name for this container.
      - SCRIPT_NAME=/admin                     # This is your applications base path (wsgi requires the name "SCRIPT_NAME").  Remove if you are hosing at the root /
      - KEY=""             # Generate with "openssl rand -base64 32" - used to encrypt your key on disk.
      - AUTH_TYPE=                         # AUTH_TYPE is either Basic or OIDC.  Empty for no authentication
      - LOG_LEVEL=info                         # Log level.  "DEBUG", "ERROR", "WARNING", or "INFO".  Default "INFO"
      # ENV for Basic Auth (Used only if AUTH_TYPE is "Basic").  Can be omitted if you aren't using Basic Auth
      - BASIC_AUTH_USER=user                   # Used for basic auth
      - BASIC_AUTH_PASS=pass                   # Used for basic auth
      # ENV for OIDC (Used only if AUTH_TYPE is "OIDC").  Can be omitted if you aren't using OIDC
      - OIDC_AUTH_URL=https://auth.$DOMAIN/.well-known/openid-configuration # URL for your OIDC issuer's well-known endpoint
      - OIDC_CLIENT_ID=headscale-webui         # Your OIDC Issuer's Client ID for Headscale-WebUI
      - OIDC_CLIENT_SECRET=YourSecretHere      # Your OIDC Issuer's Secret Key for Headscale-WebUI
    volumes:
      - /data/docker/headscale/web-ui/data:/data                         # Headscale-WebUI's storage.  Make sure ./volume is readable by UID 1000 (chown 1000:1000 ./volume)
      - /data/docker/headscale/config/:/etc/headscale/:ro # Headscale's config storage location.  Used to read your Headscale config.
```

3. 然后执行 Tailscale funnel 命令，将 headscale 开放到公网

```
tailscale serve tls-terminated-tcp:443 tcp://127.0.0.1:8080
tailscale funnel 443 on
# 证书认证
tailscale cert [被分配的domain]
```

4. 其他客户端使用

ios 端现在已经也可以自定义 login-server，在设置里面填入自己的 headscale 地址
其他端直接命令

```
tailscale login --login-server https://xxx.xxx.ts.net
```

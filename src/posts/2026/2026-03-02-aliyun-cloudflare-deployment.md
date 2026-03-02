---
title: "阿里云 + Cloudflare 域名部署指南"
description: "从零开始搭建阿里云轻量服务器 + Cloudflare CDN/SSL 的完整流程"
date: 2026-03-02
tags: ["deployment", "cloudflare", "nginx", "ssl"]
---

**适用场景：** 阿里云境外轻量应用服务器（美国/香港等）+ 自定义域名 + Cloudflare CDN/SSL

---

## 环境信息

| 项目 | 说明 |
|------|------|
| 服务器 | 阿里云轻量应用服务器（美国弗吉尼亚） |
| 公网 IP | 47.85.25.xxx |
| 域名 | ideep.cc |
| 操作系统 | CentOS / Alibaba Cloud Linux |
| 是否需要备案 | **否**（服务器在境外，无需 ICP 备案） |

---

## 第一步：将域名接入 Cloudflare

### 1.1 注册并添加域名

1. 登录 [dash.cloudflare.com](https://dash.cloudflare.com)，注册账号
2. 点击 **Add a Site**，输入域名（如 `ideep.cc`）
3. 选择 **Free 免费套餐**
4. Cloudflare 会分配两个 NS 地址，例如：
   ```
   xxx.ns.cloudflare.com
   xx.ns.cloudflare.com
   ```

### 1.2 修改阿里云域名 NS 服务器

1. 登录 [阿里云域名控制台](https://dc.console.aliyun.com)
2. 找到域名 → 点击**管理** → **DNS 修改**
3. 删除默认 NS，填入 Cloudflare 分配的两个 NS 地址
4. 保存，等待 10 分钟 ~ 24 小时生效

### 1.3 确认激活

回到 Cloudflare 控制台，域名状态变为绿色 **Active** 即表示成功。Cloudflare 同时会发送激活邮件到注册邮箱。

---

## 第二步：在 Cloudflare 添加 DNS 解析记录

进入 Cloudflare → **DNS** → **Records** → 点击 **Add record**，添加以下记录：

| Type | Name | IPv4 Address | Proxy Status |
|------|------|-------------|--------------|
| A | @ | 服务器公网IP | 🟠 Proxied（开启） |
| A | www | 服务器公网IP | 🟠 Proxied（开启） |
| A | app | 服务器公网IP | 🟠 Proxied（开启）（如需子域名） |

> 🟠 橙色云朵（Proxied）表示流量经过 Cloudflare，可享受 CDN 加速、DDoS 防护和免费 SSL。

---

## 第三步：开启 HTTPS（免费）

Cloudflare 提供免费 SSL，无需在服务器安装证书。

1. 进入 Cloudflare → 左侧 **SSL/TLS** → **Overview**
2. 点击 **Configure**，加密模式选择 **Flexible**
3. 保存

此后访问 `https://ideep.cc` 浏览器将显示安全小锁 🔒，无需额外操作。

---

## 第四步：阿里云服务器开放防火墙端口

1. 登录 [阿里云轻量应用服务器控制台](https://swasnext.console.aliyun.com)
2. 点击服务器名称 → 顶部选项卡 **防火墙**
3. 确认以下端口已开放（若没有则点击**添加规则**）：

| 协议 | 端口 | 来源IP | 说明 |
|------|------|--------|------|
| TCP | 80 | 0.0.0.0/0 | HTTP |
| TCP | 443 | 0.0.0.0/0 | HTTPS |
| TCP | xxx | 0.0.0.0/0 | SSH |

---

## 第五步：SSH 登录服务器

### 方式一：浏览器直连（最简单）

在阿里云控制台服务器页面，点击**远程连接**按钮，直接在浏览器中打开终端。

### 方式二：本地终端

先在控制台点击**设置密码**，然后：

```bash
ssh root@47.85.25.xxx
```

输入密码回车即可。

---

## 第六步：安装并配置 Nginx

### 6.1 安装 Nginx

> ⚠️ 系统为 CentOS/Alibaba Cloud Linux，使用 `yum` 而非 `apt`

```bash
# 安装 Nginx
sudo yum install -y nginx

# 启动并设置开机自启
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 6.2 创建网站目录和首页

```bash
sudo mkdir -p /var/www/ideep.cc
echo "<h1>Welcome to ideep.cc</h1>" | sudo tee /var/www/ideep.cc/index.html
```

### 6.3 创建 Nginx 主站配置

```bash
sudo tee /etc/nginx/conf.d/ideep.cc.conf > /dev/null <<EOF
server {
    listen 80;
    server_name ideep.cc www.ideep.cc;

    root /var/www/ideep.cc;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
```

### 6.4 验证配置并重启

```bash
sudo nginx -t
sudo systemctl reload nginx
```

出现 `syntax is ok` 和 `test is successful` 即配置正确。

---

## 第七步：通过子域名反向代理后端服务（可选）

如需将后端服务（如 OpenClaw）通过子域名（如 `app.ideep.cc`）对外访问：

### 7.1 查看后端服务端口

```bash
sudo netstat -tlnp
```

找到目标服务监听的端口（例如 `xxx`），并用 curl 测试确认可访问：

```bash
curl http://127.0.0.1:xxx/
```

### 7.2 在 Cloudflare 添加子域名解析

参考第二步，新增一条 A 记录：

| Type | Name | IPv4 Address | Proxy Status |
|------|------|-------------|--------------|
| A | app | 服务器公网IP | 🟠 Proxied |

### 7.3 配置 Nginx 反向代理

```bash
sudo tee /etc/nginx/conf.d/app.ideep.cc.conf > /dev/null <<EOF
server {
    listen 80;
    server_name app.ideep.cc;

    location / {
        proxy_pass http://127.0.0.1:xxx;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo nginx -t && sudo systemctl reload nginx
```

完成后即可通过 `https://app.ideep.cc` 访问后端服务。

---

## 验证访问

| 地址 | 预期结果 |
|------|----------|
| https://ideep.cc | 主站首页 |
| https://www.ideep.cc | 同上 |
| https://app.ideep.cc | 后端服务（如 OpenClaw） |

---

## 常见问题排查

| 现象 | 可能原因 | 解决方法 |
|------|----------|----------|
| 域名无法访问 | DNS 未生效 | 等待 10~30 分钟再试 |
| 连接被拒绝 | 防火墙未开放端口 | 检查阿里云防火墙规则 |
| Nginx 启动失败 | 配置语法错误 | 运行 `sudo nginx -t` 查看报错 |
| 子域名 404 | Nginx 配置未生效 | 检查 conf.d 文件并 reload |
| HTTPS 不安全提示 | Cloudflare SSL 未开启 | 检查 SSL/TLS 模式是否为 Flexible |
| apt 命令找不到 | 系统是 CentOS | 改用 `yum` 命令 |

---

## 架构示意

```
用户浏览器
│
▼
Cloudflare（CDN + SSL + DDoS防护）
│
▼
阿里云轻量服务器 47.85.25.xxx
├── Nginx（80端口）
│   ├── ideep.cc → /var/www/ideep.cc（静态页面）
│   └── app.ideep.cc → 127.0.0.1:xxx（后端服务反代）
└── 后端服务（如 OpenClaw，端口 xxx）
```

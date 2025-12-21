#!/bin/bash

# From Dockerfile, default to 7777 if not set
HY2_PORT=${HY2_PORT:-7777}

# --- Smart Password Handling ---
EFFECTIVE_PASSWORD=""
if [ -n "$password" ]; then
    EFFECTIVE_PASSWORD="$password"
    PASSWORD_SOURCE_MSG="已使用您通过环境变量提供的自定义密码。"
else
    EFFECTIVE_PASSWORD=$(openssl rand -base64 12)
    PASSWORD_SOURCE_MSG="未提供密码，已为您自动生成一个一次性强密码。请妥善保存！"
fi

# --- Generate Hysteria 2 Config ---
cat > config.yaml <<EOF
listen: :${HY2_PORT}

auth:
  type: password
  password: ${EFFECTIVE_PASSWORD}

tls:
  alpn: h3
  cert: /app/cert.pem
  key: /app/key.pem

# DNS 解析器配置（解决域名解析问题）
resolver:
  type: tcp 
  tcp:
    addr: 8.8.8.8:53 
    timeout: 4s 
  udp:
    addr: 8.8.4.4:53 
    timeout: 4s
  tls:
    addr: 1.1.1.1:853 
    timeout: 10s
    sni: cloudflare-dns.com 
    insecure: false 
  https:
    addr: 1.1.1.1:443 
    timeout: 10s
    sni: cloudflare-dns.com
    insecure: false

# 忽略客户端带宽提示，使用 BBR 拥塞控制算法（更公平）
ignoreClientBandwidth: true

# QUIC 协议优化参数（针对高延迟网络优化）
quic:
  # 初始流接收窗口大小（20MB，针对高延迟网络优化）
  initStreamReceiveWindow: 20971520
  # 最大流接收窗口大小（20MB）
  maxStreamReceiveWindow: 20971520
  # 初始连接接收窗口大小（50MB，保持 2:5 比例，适合高延迟网络）
  initConnReceiveWindow: 52428800
  # 最大连接接收窗口大小（50MB，可处理高延迟连接）
  maxConnReceiveWindow: 52428800
  # 最大空闲超时（120秒，支持长连接如 Apple Push Notification）
  maxIdleTimeout: 120s      
  # KeepAlive 周期（60秒发送一次心跳包，保持长连接活跃）
  keepAlivePeriod: 60s
  # 最大并发入站流数量（增加到 2048，支持更多并发连接）
  maxIncomingStreams: 2048
  # 禁用路径 MTU 发现（在某些网络环境下可能有用）
  disablePathMTUDiscovery: false

# 伪装配置（可选，使服务器看起来像正常的 HTTP/3 服务器）
masquerade:
  type: proxy
  proxy:
    url: https://www.apple.com/
    rewriteHost: true
EOF

# --- Generate Self-Signed Certificate and Key ---
# This is the key fix. We generate a real certificate before starting.
openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /app/key.pem -out /app/cert.pem -subj "/CN=localhost" -days 3650

# --- User Guide Output ---
echo "=================================================="
echo "          Hysteria 2 节点配置向导"
echo "=================================================="
echo ""
echo "--- 步骤 1: 获取你的连接密码 ---"
echo "$PASSWORD_SOURCE_MSG"
echo "你的连接密码是: ${EFFECTIVE_PASSWORD}"
echo ""
echo "--- 步骤 2: 从平台获取你的公共地址和端口 ---"
echo "请前往 run.claw.cloud 的仪表盘，找到为此容器分配的公共地址和端口。"
echo "   它看起来像这样: udp.us-west-1.clawcloudrun.com:XXXXX"
echo ""
echo "--- 步骤 3: 组合成你的最终链接 ---"
echo "请复制下面的【链接模板】，然后将其中 'example.com:7777' 部分替换为"
echo "你在步骤2中获取到的【公共地址和端口】。"
echo ""
echo "链接模板:"
echo "   hy2://${EFFECTIVE_PASSWORD}@example.com:7777?insecure=1&alpn=h3#sevenhy2"
echo ""
echo "=================================================="
echo ""
echo "正在启动 Hysteria 2 服务器... (5秒后将显示服务日志)"
sleep 5

# 启动 Hysteria2 服务器
exec hysteria server -c /app/config.yaml
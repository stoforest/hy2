# 使用官方 Hysteria2 镜像作为基础
FROM tobyxdd/hysteria:latest

# 安装必要的依赖（bash 和 openssl 用于脚本）
RUN apk add --no-cache bash openssl

# 设置工作目录
WORKDIR /app

# 复制启动脚本
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# 暴露默认端口（UDP）
EXPOSE 7777/udp

# 使用自定义启动脚本
ENTRYPOINT ["/app/start.sh"]


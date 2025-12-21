# Hysteria2 Docker 镜像使用说明

这是一个基于 Alpine Linux 的 Hysteria2 代理服务器 Docker 镜像。

## 快速开始

### 方法 1: 使用 Docker Compose（推荐）

```bash
# 构建并启动
docker-compose up -d

# 查看日志（包含连接信息和密码）
docker-compose logs -f
```

### 方法 2: 使用 Docker 命令

```bash
# 构建镜像
docker build -t hysteria2:latest .

# 运行容器
docker run -d \
  --name hysteria2 \
  -p 7777:7777/udp \
  -e HY2_PORT=7777 \
  hysteria2:latest

# 查看日志（包含连接信息和密码）
docker logs -f hysteria2
```

## 配置选项

### 环境变量

- `HY2_PORT`: 服务监听端口（默认: 7777）
- `password`: 自定义连接密码（可选，不设置则自动生成强密码）

### 自定义密码示例

```bash
# Docker Compose
environment:
  - password=MySecurePassword123

# Docker 命令
docker run -d \
  --name hysteria2 \
  -p 7777:7777/udp \
  -e password=MySecurePassword123 \
  hysteria2:latest
```

### 自定义端口示例

```bash
# Docker Compose（记得同时修改 ports 映射）
ports:
  - "8888:8888/udp"
environment:
  - HY2_PORT=8888

# Docker 命令
docker run -d \
  --name hysteria2 \
  -p 8888:8888/udp \
  -e HY2_PORT=8888 \
  hysteria2:latest
```

## 获取连接信息

启动容器后，查看日志即可获取完整的配置向导：

```bash
# Docker Compose
docker-compose logs

# Docker 命令
docker logs hysteria2
```

日志中会显示：
- 连接密码
- 链接模板
- 配置步骤

## 管理命令

```bash
# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看实时日志
docker-compose logs -f

# 删除容器和镜像
docker-compose down
docker rmi hysteria2:latest
```

## 注意事项

1. **端口协议**: Hysteria2 使用 UDP 协议，确保防火墙已开放对应的 UDP 端口
2. **密码安全**: 如使用自动生成的密码，请在首次启动时立即保存
3. **证书**: 镜像会自动生成自签名证书，客户端需使用 `insecure=1` 参数
4. **持久化**: 默认配置不持久化数据，每次重启都会生成新证书

## 客户端配置示例

连接链接格式：
```
hy2://密码@服务器地址:端口?insecure=1&alpn=h3#节点名称
```

实际示例：
```
hy2://MySecurePassword123@example.com:7777?insecure=1&alpn=h3#sevenhy2
```

## 故障排查

### 容器无法启动
```bash
# 查看详细日志
docker logs hysteria2

# 检查端口占用
netstat -ulnp | grep 7777
```

### 无法连接
1. 检查防火墙是否开放 UDP 端口
2. 确认服务器地址和端口正确
3. 验证密码是否匹配
4. 检查客户端是否支持 Hysteria2 协议

## 技术规格

- **基础镜像**: Alpine Linux
- **协议**: QUIC/UDP
- **加密**: TLS 1.3
- **拥塞控制**: BBR
- **伪装**: Apple.com HTTP/3 代理


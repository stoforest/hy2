#!/bin/bash

# Hysteria2 Docker 镜像自动构建并上传到 Docker Hub 脚本
# 使用方法: ./build-and-push.sh [版本号]
# 示例: ./build-and-push.sh 1.0.0

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否在正确的目录
if [ ! -f "Dockerfile" ] || [ ! -f "start.sh" ]; then
    print_error "请在包含 Dockerfile 和 start.sh 的目录中运行此脚本！"
    exit 1
fi

# 获取版本号
VERSION=${1:-$(date +%Y%m%d-%H%M%S)}
print_info "镜像版本: ${VERSION}"

# Docker Hub 配置
echo ""
print_info "请输入你的 Docker Hub 信息："
read -p "Docker Hub 用户名: " DOCKER_USERNAME
read -sp "Docker Hub 密码或访问令牌: " DOCKER_PASSWORD
echo ""

if [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ]; then
    print_error "用户名和密码不能为空！"
    exit 1
fi

# 镜像名称
read -p "镜像名称 (默认: hysteria2): " IMAGE_NAME
IMAGE_NAME=${IMAGE_NAME:-hysteria2}
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}"

print_info "完整镜像名: ${FULL_IMAGE_NAME}"

# 登录 Docker Hub
echo ""
print_info "正在登录 Docker Hub..."
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

if [ $? -eq 0 ]; then
    print_success "登录成功！"
else
    print_error "登录失败！"
    exit 1
fi

# 构建镜像
echo ""
print_info "开始构建 Docker 镜像..."
print_info "构建标签: ${FULL_IMAGE_NAME}:${VERSION} 和 ${FULL_IMAGE_NAME}:latest"

docker build -t "${FULL_IMAGE_NAME}:${VERSION}" -t "${FULL_IMAGE_NAME}:latest" .

if [ $? -eq 0 ]; then
    print_success "镜像构建成功！"
else
    print_error "镜像构建失败！"
    exit 1
fi

# 显示镜像信息
echo ""
print_info "镜像信息:"
docker images | grep "${IMAGE_NAME}"

# 推送镜像
echo ""
print_info "开始推送镜像到 Docker Hub..."

# 推送版本标签
print_info "推送 ${FULL_IMAGE_NAME}:${VERSION}..."
docker push "${FULL_IMAGE_NAME}:${VERSION}"

if [ $? -eq 0 ]; then
    print_success "版本 ${VERSION} 推送成功！"
else
    print_error "版本 ${VERSION} 推送失败！"
    exit 1
fi

# 推送 latest 标签
print_info "推送 ${FULL_IMAGE_NAME}:latest..."
docker push "${FULL_IMAGE_NAME}:latest"

if [ $? -eq 0 ]; then
    print_success "Latest 标签推送成功！"
else
    print_error "Latest 标签推送失败！"
    exit 1
fi

# 清理（可选）
echo ""
read -p "是否删除本地构建的镜像？(y/N): " CLEANUP
if [[ "$CLEANUP" =~ ^[Yy]$ ]]; then
    print_info "清理本地镜像..."
    docker rmi "${FULL_IMAGE_NAME}:${VERSION}" "${FULL_IMAGE_NAME}:latest" || true
    print_success "清理完成！"
fi

# 登出
docker logout

# 完成
echo ""
print_success "======================================"
print_success "  所有操作完成！"
print_success "======================================"
echo ""
print_info "镜像已成功上传到 Docker Hub："
echo "   - ${FULL_IMAGE_NAME}:${VERSION}"
echo "   - ${FULL_IMAGE_NAME}:latest"
echo ""
print_info "其他用户可以使用以下命令拉取镜像："
echo "   docker pull ${FULL_IMAGE_NAME}:latest"
echo ""
print_info "运行镜像："
echo "   docker run -d --name hysteria2 -p 7777:7777/udp ${FULL_IMAGE_NAME}:latest"
echo ""


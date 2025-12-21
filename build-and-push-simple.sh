#!/bin/bash

# Hysteria2 Docker 镜像快速构建上传脚本
# 适用于已经配置好 Docker Hub 凭据的情况

set -e

# 配置（请修改为你的信息）
DOCKER_USERNAME="stoforest"  # 修改这里
IMAGE_NAME="hysteria2"
VERSION=${1:-"latest"}

# 完整镜像名
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}"

echo "=========================================="
echo "  Hysteria2 Docker 镜像构建上传"
echo "=========================================="
echo "用户名: ${DOCKER_USERNAME}"
echo "镜像名: ${FULL_IMAGE_NAME}"
echo "版本号: ${VERSION}"
echo "=========================================="
echo ""

# 检查文件
if [ ! -f "Dockerfile" ]; then
    echo "错误: 找不到 Dockerfile！"
    exit 1
fi

# 构建镜像
echo "正在构建镜像..."
docker build -t "${FULL_IMAGE_NAME}:${VERSION}" .

if [ "${VERSION}" != "latest" ]; then
    docker tag "${FULL_IMAGE_NAME}:${VERSION}" "${FULL_IMAGE_NAME}:latest"
fi

echo "构建完成！"
echo ""

# 推送镜像
echo "正在推送镜像到 Docker Hub..."
docker push "${FULL_IMAGE_NAME}:${VERSION}"

if [ "${VERSION}" != "latest" ]; then
    docker push "${FULL_IMAGE_NAME}:latest"
fi

echo ""
echo "=========================================="
echo "  上传完成！"
echo "=========================================="
echo "镜像地址:"
echo "  - ${FULL_IMAGE_NAME}:${VERSION}"
if [ "${VERSION}" != "latest" ]; then
    echo "  - ${FULL_IMAGE_NAME}:latest"
fi
echo ""
echo "拉取命令:"
echo "  docker pull ${FULL_IMAGE_NAME}:latest"
echo ""


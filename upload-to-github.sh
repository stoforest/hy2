#!/bin/bash

# GitHub 上传助手脚本
# 用于首次将项目上传到 GitHub

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  GitHub 上传助手${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查是否已经是 git 仓库
if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠️  检测到已存在的 Git 仓库${NC}"
    read -p "是否要重新初始化？(y/N): " reinit
    if [[ "$reinit" =~ ^[Yy]$ ]]; then
        rm -rf .git
        echo -e "${GREEN}✓ 已清除旧仓库${NC}"
    else
        echo "使用现有仓库..."
    fi
fi

# 初始化 Git 仓库（如果需要）
if [ ! -d ".git" ]; then
    echo -e "${BLUE}📦 初始化 Git 仓库...${NC}"
    git init
    echo -e "${GREEN}✓ Git 仓库初始化完成${NC}"
    echo ""
fi

# 配置 Git 用户信息（如果未配置）
if [ -z "$(git config user.name)" ]; then
    echo -e "${YELLOW}配置 Git 用户信息${NC}"
    read -p "请输入你的 Git 用户名: " git_username
    read -p "请输入你的 Git 邮箱: " git_email
    git config user.name "$git_username"
    git config user.email "$git_email"
    echo -e "${GREEN}✓ Git 用户信息配置完成${NC}"
    echo ""
fi

# 添加文件
echo -e "${BLUE}📝 添加文件到 Git...${NC}"
git add .
echo -e "${GREEN}✓ 文件添加完成${NC}"
echo ""

# 查看状态
echo -e "${BLUE}📋 当前状态:${NC}"
git status --short
echo ""

# 提交
read -p "请输入提交信息 (默认: Initial commit): " commit_msg
commit_msg=${commit_msg:-"Initial commit - Hysteria2 Docker Image"}
git commit -m "$commit_msg"
echo -e "${GREEN}✓ 提交完成${NC}"
echo ""

# GitHub 仓库配置
echo -e "${BLUE}🔗 配置 GitHub 远程仓库${NC}"
echo ""
echo "请选择方式:"
echo "  1) 我已经在 GitHub 创建了仓库（推荐）"
echo "  2) 我需要先去创建仓库"
echo ""
read -p "请选择 [1-2]: " choice

if [ "$choice" = "2" ]; then
    echo ""
    echo -e "${YELLOW}请按以下步骤创建 GitHub 仓库:${NC}"
    echo ""
    echo "1. 访问: https://github.com/new"
    echo "2. 仓库名称: hysteria2-docker (或其他名称)"
    echo "3. 描述: Hysteria2 Proxy Server Docker Image"
    echo "4. 选择: Public 或 Private"
    echo "5. ⚠️  不要勾选 'Add README' 等选项"
    echo "6. 点击 'Create repository'"
    echo ""
    read -p "创建完成后按 Enter 继续..."
fi

echo ""
read -p "请输入你的 GitHub 用户名: " github_username
read -p "请输入仓库名称 (默认: hysteria2-docker): " repo_name
repo_name=${repo_name:-hysteria2-docker}

# 添加远程仓库
echo ""
echo -e "${BLUE}🔗 添加远程仓库...${NC}"
remote_url="https://github.com/${github_username}/${repo_name}.git"

# 检查是否已有 origin
if git remote | grep -q "origin"; then
    echo -e "${YELLOW}⚠️  已存在 origin，将更新为新地址${NC}"
    git remote set-url origin "$remote_url"
else
    git remote add origin "$remote_url"
fi

echo -e "${GREEN}✓ 远程仓库配置完成${NC}"
echo "   仓库地址: $remote_url"
echo ""

# 推送到 GitHub
echo -e "${BLUE}🚀 推送到 GitHub...${NC}"
echo ""
echo "请选择推送方式:"
echo "  1) HTTPS (需要输入密码或 Token)"
echo "  2) SSH (需要配置 SSH 密钥)"
echo ""
read -p "请选择 [1-2] (默认: 1): " push_method
push_method=${push_method:-1}

if [ "$push_method" = "2" ]; then
    remote_url="git@github.com:${github_username}/${repo_name}.git"
    git remote set-url origin "$remote_url"
    echo "已切换到 SSH: $remote_url"
fi

echo ""
echo -e "${YELLOW}提示: 如果使用 HTTPS，GitHub 现在要求使用 Personal Access Token${NC}"
echo -e "${YELLOW}Token 获取: https://github.com/settings/tokens${NC}"
echo ""
read -p "准备好后按 Enter 开始推送..."

# 推送
echo ""
git branch -M main
if git push -u origin main; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  🎉 上传成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "你的仓库地址:"
    echo "  https://github.com/${github_username}/${repo_name}"
    echo ""
    echo "下一步:"
    echo "  1. 访问仓库页面查看代码"
    echo "  2. 添加 Docker Hub Secrets (用于 GitHub Actions)"
    echo "     Settings → Secrets → New repository secret"
    echo "     - DOCKER_USERNAME: 你的 Docker Hub 用户名"
    echo "     - DOCKER_PASSWORD: 你的 Docker Hub 密码/Token"
    echo "  3. 推送代码时将自动构建 Docker 镜像"
    echo ""
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  ❌ 推送失败${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo "常见问题:"
    echo ""
    echo "1. 认证失败:"
    echo "   - HTTPS: 需要使用 Personal Access Token (不是密码)"
    echo "   - 获取 Token: https://github.com/settings/tokens"
    echo "   - 权限: 勾选 'repo' 权限"
    echo ""
    echo "2. SSH 密钥未配置:"
    echo "   - 生成密钥: ssh-keygen -t ed25519 -C 'your_email@example.com'"
    echo "   - 添加到 GitHub: https://github.com/settings/keys"
    echo ""
    echo "3. 仓库不存在:"
    echo "   - 确认仓库已在 GitHub 创建"
    echo "   - 检查用户名和仓库名是否正确"
    echo ""
    exit 1
fi


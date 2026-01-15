# GitHub 上传指南

本文档详细说明如何将 Hysteria2 Docker 项目上传到 GitHub。

## 🚀 方法一：使用自动化脚本（推荐）

### 快速开始

```bash
# 1. 赋予执行权限
chmod +x upload-to-github.sh

# 2. 运行脚本
./upload-to-github.sh
```

脚本会自动完成：
- ✅ 初始化 Git 仓库
- ✅ 配置 Git 用户信息
- ✅ 添加和提交文件
- ✅ 配置远程仓库
- ✅ 推送到 GitHub

---

## 📝 方法二：手动步骤

### 步骤 1: 在 GitHub 创建仓库

1. 访问 [https://github.com/new](https://github.com/new)
2. 填写仓库信息：
   - **Repository name**: `hysteria2-docker`
   - **Description**: `Hysteria2 Proxy Server Docker Image`
   - **Public** 或 **Private**（自选）
   - ⚠️ **不要勾选** "Add a README file"
3. 点击 **Create repository**

### 步骤 2: 初始化本地仓库

```bash
# 进入项目目录
cd /home/shizesen/下载/hy2

# 初始化 Git 仓库
git init

# 配置用户信息（首次使用）
git config user.name "你的名字"
git config user.email "your_email@example.com"
```

### 步骤 3: 添加并提交文件

```bash
# 添加所有文件
git add .

# 查看状态
git status

# 提交
git commit -m "Initial commit - Hysteria2 Docker Image"
```

### 步骤 4: 关联远程仓库

```bash
# 添加远程仓库（替换 your_username）
git remote add origin https://github.com/your_username/hysteria2-docker.git

# 或使用 SSH
git remote add origin git@github.com:your_username/hysteria2-docker.git

# 设置主分支名称
git branch -M main
```

### 步骤 5: 推送到 GitHub

```bash
# 推送代码
git push -u origin main
```

---

## 🔐 认证方式

### 方式 1: HTTPS + Personal Access Token（推荐）

#### 创建 Token：

1. 访问 [https://github.com/settings/tokens](https://github.com/settings/tokens)
2. 点击 **Generate new token** → **Generate new token (classic)**
3. 设置：
   - **Note**: `Hysteria2 Docker`
   - **Expiration**: 选择有效期
   - **Scopes**: 勾选 `repo` (所有权限)
4. 点击 **Generate token**
5. ⚠️ **立即复制** Token（只显示一次！）

#### 使用 Token：

```bash
# 推送时输入：
# Username: 你的 GitHub 用户名
# Password: 粘贴你的 Token（不是密码！）
git push -u origin main
```

### 方式 2: SSH 密钥

#### 生成 SSH 密钥：

```bash
# 生成密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 查看公钥
cat ~/.ssh/id_ed25519.pub
```

#### 添加到 GitHub：

1. 复制公钥内容
2. 访问 [https://github.com/settings/keys](https://github.com/settings/keys)
3. 点击 **New SSH key**
4. 粘贴公钥，点击 **Add SSH key**

#### 测试连接：

```bash
# 测试 SSH 连接
ssh -T git@github.com

# 应该看到: Hi username! You've successfully authenticated...
```

---

## 🤖 启用 GitHub Actions 自动构建

### 步骤 1: 添加 Docker Hub Secrets

代码推送后，在 GitHub 仓库页面：

1. 进入 **Settings** → **Secrets and variables** → **Actions**
2. 点击 **New repository secret**
3. 添加两个 Secret：

   **Secret 1:**
   - Name: `DOCKER_USERNAME`
   - Value: 你的 Docker Hub 用户名（如 `stoforest`）

   **Secret 2:**
   - Name: `DOCKER_PASSWORD`
   - Value: 你的 Docker Hub 密码或 [Access Token](https://hub.docker.com/settings/security)

### 步骤 2: 触发自动构建

配置完成后，以下操作会自动触发构建：

```bash
# 方式 1: 推送代码
git add .
git commit -m "Update configuration"
git push

# 方式 2: 创建版本标签
git tag v1.0.0
git push origin v1.0.0

# 方式 3: 手动触发
# 在 GitHub 仓库页面: Actions → Build and Push → Run workflow
```

### 步骤 3: 查看构建状态

1. 进入仓库的 **Actions** 标签
2. 查看运行中的工作流
3. 构建完成后，镜像会自动推送到 Docker Hub

---

## 📊 项目结构说明

推送到 GitHub 的文件：

```
hysteria2-docker/
├── .github/
│   └── workflows/
│       └── docker-build.yml      # GitHub Actions 自动构建配置
├── .gitignore                     # Git 忽略文件
├── .dockerignore                  # Docker 忽略文件
├── Dockerfile                     # Docker 镜像定义
├── docker-compose.yml             # Docker Compose 配置
├── start.sh                       # 启动脚本
├── build-and-push.sh             # 交互式构建脚本
├── build-and-push-simple.sh      # 简化构建脚本
├── upload-to-github.sh           # GitHub 上传助手
├── README.md                      # 使用说明
├── DEPLOY.md                      # 部署文档
└── GITHUB.md                      # 本文件
```

**不会推送的文件**（在 .gitignore 中）：
- `config.yaml` - 运行时生成
- `*.pem` - 证书文件
- `*.log` - 日志文件
- `.env` - 环境变量

---

## 🔄 日常维护

### 更新代码

```bash
# 1. 修改代码
nano start.sh

# 2. 提交更改
git add .
git commit -m "优化 DNS 配置"
git push

# GitHub Actions 会自动构建新镜像
```

### 发布新版本

```bash
# 创建并推送标签
git tag v1.0.1
git push origin v1.0.1

# GitHub Actions 会构建并推送:
# - stoforest/hysteria2:v1.0.1
# - stoforest/hysteria2:1.0
# - stoforest/hysteria2:1
# - stoforest/hysteria2:latest
```

### 查看历史

```bash
# 查看提交历史
git log --oneline

# 查看更改
git diff

# 查看状态
git status
```

---

## ❓ 常见问题

### 1. 认证失败

**错误信息：**
```
remote: Support for password authentication was removed
```

**解决方案：**
- GitHub 不再支持密码认证
- 必须使用 Personal Access Token 或 SSH 密钥

### 2. 仓库已存在

**错误信息：**
```
error: remote origin already exists
```

**解决方案：**
```bash
# 删除旧的远程仓库
git remote remove origin

# 添加新的
git remote add origin https://github.com/username/repo.git
```

### 3. 分支名称问题

**错误信息：**
```
error: src refspec main does not match any
```

**解决方案：**
```bash
# 重命名当前分支为 main
git branch -M main

# 然后推送
git push -u origin main
```

### 4. 推送被拒绝

**错误信息：**
```
error: failed to push some refs
```

**解决方案：**
```bash
# 先拉取远程更改
git pull origin main --rebase

# 然后推送
git push -u origin main
```

### 5. GitHub Actions 构建失败

**检查步骤：**
1. 确认 Secrets 已正确配置
2. 查看 Actions 日志找到具体错误
3. 检查 Dockerfile 语法
4. 验证 Docker Hub 登录信息

---

## 🎯 最佳实践

### 1. 提交信息规范

使用清晰的提交信息：

```bash
# 好的例子
git commit -m "优化: 改进 DNS 解析配置"
git commit -m "修复: 解决证书生成问题"
git commit -m "文档: 更新 README 使用说明"

# 避免
git commit -m "update"
git commit -m "fix bug"
```

### 2. 使用 .gitignore

确保敏感信息不会被提交：
- 密码和密钥
- 个人配置
- 临时文件

### 3. 定期推送

```bash
# 养成习惯：修改后及时提交和推送
git add .
git commit -m "描述更改内容"
git push
```

### 4. 版本标签

为重要版本创建标签：

```bash
# 创建带注释的标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

## 📚 扩展阅读

- [GitHub 文档](https://docs.github.com/)
- [Git 基础教程](https://git-scm.com/book/zh/v2)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker Hub 文档](https://docs.docker.com/docker-hub/)

---

## 🆘 获取帮助

如果遇到问题：

1. 查看错误信息
2. 搜索 GitHub/Stack Overflow
3. 查看本文档的常见问题部分
4. 运行 `./upload-to-github.sh` 脚本（有详细的错误提示）

祝你上传顺利！🚀


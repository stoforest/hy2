# Docker Hub 部署指南

本文档说明如何将 Hysteria2 镜像构建并上传到 Docker Hub。

## 方法一：交互式脚本（推荐新手）

使用 `build-and-push.sh` 脚本，会交互式地询问你的 Docker Hub 信息。

```bash
# 赋予执行权限
chmod +x build-and-push.sh

# 运行脚本（自动生成时间戳版本）
./build-and-push.sh

# 或指定版本号
./build-and-push.sh 1.0.0
```

**脚本会询问：**
1. Docker Hub 用户名
2. Docker Hub 密码或访问令牌
3. 镜像名称（默认: hysteria2）

**脚本功能：**
- ✅ 自动登录 Docker Hub
- ✅ 构建镜像（支持多标签）
- ✅ 推送到 Docker Hub
- ✅ 显示详细进度信息
- ✅ 可选清理本地镜像

---

## 方法二：简化脚本（推荐熟练用户）

使用 `build-and-push-simple.sh` 脚本，适合已经配置好 Docker Hub 登录的用户。

### 1. 配置脚本

编辑 `build-and-push-simple.sh`，修改第 7 行：

```bash
DOCKER_USERNAME="your_dockerhub_username"  # 改为你的用户名
```

### 2. 登录 Docker Hub（一次性）

```bash
docker login
```

### 3. 运行脚本

```bash
# 赋予执行权限
chmod +x build-and-push-simple.sh

# 构建并推送（默认 latest）
./build-and-push-simple.sh

# 指定版本号
./build-and-push-simple.sh v1.0.0
```

---

## 方法三：GitHub Actions 自动化（推荐开源项目）

如果你的代码托管在 GitHub 上，可以使用 GitHub Actions 实现自动构建和发布。

### 1. 设置 GitHub Secrets

在 GitHub 仓库中添加以下 Secrets（Settings → Secrets and variables → Actions）：

- `DOCKER_USERNAME`: 你的 Docker Hub 用户名
- `DOCKER_PASSWORD`: 你的 Docker Hub 密码或访问令牌

### 2. 添加 Workflow 文件

文件已创建在 `.github/workflows/docker-build.yml`

### 3. 触发构建

**自动触发：**
- 推送代码到 `main` 或 `master` 分支
- 创建版本标签（如 `v1.0.0`）
- 提交 Pull Request

**手动触发：**
- 在 GitHub 仓库的 Actions 标签页点击 "Run workflow"

### 4. 版本标签

```bash
# 创建版本标签并推送
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions 会自动构建并推送多个标签：
- `your_username/hysteria2:v1.0.0`
- `your_username/hysteria2:1.0`
- `your_username/hysteria2:1`
- `your_username/hysteria2:latest`

---

## 方法四：手动 Docker 命令

如果你喜欢完全手动控制，可以使用以下命令：

```bash
# 1. 登录 Docker Hub
docker login

# 2. 构建镜像
docker build -t your_username/hysteria2:latest .

# 3. 添加版本标签
docker tag your_username/hysteria2:latest your_username/hysteria2:v1.0.0

# 4. 推送到 Docker Hub
docker push your_username/hysteria2:latest
docker push your_username/hysteria2:v1.0.0

# 5. 登出（可选）
docker logout
```

---

## Docker Hub 访问令牌（推荐）

使用访问令牌比密码更安全。

### 创建访问令牌：

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像 → Account Settings
3. 进入 Security → New Access Token
4. 输入描述（如 "Hysteria2 Build"）
5. 选择权限（Read, Write, Delete）
6. 复制生成的令牌（只显示一次！）

### 使用访问令牌：

```bash
# 使用令牌登录
docker login -u your_username -p your_access_token

# 或者在脚本中使用
echo "your_access_token" | docker login -u your_username --password-stdin
```

---

## 验证上传

上传成功后，你和其他用户可以这样使用镜像：

```bash
# 拉取镜像
docker pull your_username/hysteria2:latest

# 运行容器
docker run -d --name hy2 -p 7777:7777/udp your_username/hysteria2:latest

# 查看日志获取密码
docker logs hy2
```

---

## 常见问题

### 1. 认证失败
```
Error response from daemon: Get https://registry-1.docker.io/v2/: unauthorized
```

**解决方法：**
- 检查用户名和密码是否正确
- 确保已运行 `docker login`
- 考虑使用访问令牌代替密码

### 2. 镜像推送超时

**解决方法：**
- 检查网络连接
- 使用国内 Docker Hub 镜像（如果配置了）
- 尝试多次推送

### 3. 权限被拒绝

**解决方法：**
```bash
# 将用户添加到 docker 组
sudo usermod -aG docker $USER
# 重新登录或运行
newgrp docker
```

### 4. 磁盘空间不足

**解决方法：**
```bash
# 清理未使用的镜像
docker system prune -a

# 查看磁盘使用情况
docker system df
```

---

## 最佳实践

1. **使用语义化版本号**：`v1.0.0`, `v1.0.1`, `v2.0.0`
2. **同时推送版本标签和 latest**：方便用户选择
3. **使用访问令牌**：比密码更安全
4. **自动化构建**：使用 GitHub Actions 或其他 CI/CD
5. **多架构支持**：构建 amd64 和 arm64 版本
6. **定期更新**：基础镜像有安全更新时重新构建

---

## 脚本对比

| 特性 | build-and-push.sh | build-and-push-simple.sh | GitHub Actions |
|------|-------------------|-------------------------|----------------|
| 交互式 | ✅ | ❌ | ❌ |
| 自动登录 | ✅ | ❌（需预先登录）| ✅ |
| 彩色输出 | ✅ | ❌ | ✅（GitHub UI） |
| 版本控制 | ✅ | ✅ | ✅（自动） |
| 多架构 | ❌ | ❌ | ✅ |
| 自动触发 | ❌ | ❌ | ✅ |
| 适合场景 | 首次使用 | 日常构建 | 持续集成 |

选择适合你的方法，享受自动化构建的便利！


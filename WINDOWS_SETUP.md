# 🪟 Windows 原生 xv6-riscv 开发指南

本指南帮助你在不使用 WSL 的情况下，在 Windows 上进行 xv6-riscv 的原生开发。

## 🎯 推荐方案对比

| 方案 | 优点 | 缺点 | 推荐指数 |
|------|------|------|----------|
| **MSYS2** | 完整类Unix环境、包管理简单 | 需要学习MSYS2基本命令 | ⭐⭐⭐⭐⭐ |
| **预编译二进制** | 直接Windows原生、性能好 | 手动配置较多 | ⭐⭐⭐⭐ |
| **Chocolatey** | PowerShell原生、包管理方便 | 版本可能不是最新 | ⭐⭐⭐ |
| **WSL2** | 完整Linux环境、最兼容 | 有性能开销、学习成本 | ⭐⭐ |

## 🚀 方案一: MSYS2 (强烈推荐)

### 步骤 1: 安装 MSYS2

1. 访问 [MSYS2 官网](https://www.msys2.org/)
2. 下载并运行安装程序
3. 选择安装路径（建议默认 `C:\msys64`）
4. 完成安装后会弹出 MSYS2 终端

### 步骤 2: 初始化包数据库

```bash
# 在 MSYS2 终端中执行
pacman -Syu
# 如果提示重启终端，关闭并重新打开
pacman -Su
```

### 步骤 3: 安装开发工具

```bash
# 安装 RISC-V 工具链
pacman -S mingw-w64-x86_64-riscv-none-embed-gcc

# 安装 QEMU
pacman -S mingw-w64-x86_64-qemu

# 安装其他必需工具
pacman -S mingw-w64-x86_64-make
pacman -S mingw-w64-x86_64-git
pacman -S mingw-w64-x86_64-gdb

# 可选: 安装文本编辑器和开发工具
pacman -S vim nano
```

### 步骤 4: 验证安装

```bash
# 检查 RISC-V 工具链
riscv-none-embed-gcc --version

# 检查 QEMU
qemu-system-riscv64 --version

# 检查 make
mingw32-make --version
```

### 步骤 5: 配置 xv6 开发环境

```bash
# 克隆项目 (如果还没有)
git clone https://github.com/Desperado1001/xv6-riscv.git
cd xv6-riscv

# 添加上游仓库
git remote add upstream https://github.com/mit-pdos/xv6-riscv.git

# 同步最新代码
git fetch upstream
git checkout riscv
git merge upstream/riscv

# 构建测试
mingw32-make qemu
```

### 步骤 6: 配置 VS Code (可选)

1. 安装 VS Code
2. 安装扩展:
   - C/C++ (Microsoft)
   - Makefile Tools (Microsoft)
   - GitLens (GitKraken)
   - Remote - WSL (为以后备用)

3. 创建 `.vscode/settings.json`:
```json
{
    "terminal.integrated.shell.windows": "C:\\msys64\\usr\\bin\\bash.exe",
    "terminal.integrated.shellArgs.windows": [
        "--login",
        "-i"
    ],
    "files.associations": {
        "*.S": "assembly"
    }
}
```

## 📦 方案二: 预编译二进制文件

### 步骤 1: 下载 RISC-V 工具链

1. 访问 [xPack RISC-V GCC](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases)
2. 下载最新版本的 `xpack-riscv-none-embed-gcc-...-win32-x64.zip`
3. 解压到 `C:\xpack-riscv-none-embed-gcc\`

### 步骤 2: 下载 QEMU

1. 访问 [QEMU Windows 下载](https://qemu.weilnetz.de/w64/)
2. 下载最新的 `qemu-w64-setup-...exe`
3. 运行安装程序，安装到 `C:\Program Files\qemu`

### 步骤 3: 配置环境变量

1. 按 `Win + R`，输入 `sysdm.cpl`
2. 点击"高级" → "环境变量"
3. 在"系统变量"中找到 `Path`，点击"编辑"
4. 添加以下路径:
   ```
   C:\xpack-riscv-none-embed-gcc\bin
   C:\Program Files\qemu
   ```
5. 点击确定保存

### 步骤 4: 安装 Git 和 Make

1. 访问 [Git for Windows](https://git-scm.com/download/win)
2. 下载并安装 Git
3. 下载 [Make for Windows](https://gnuwin32.sourceforge.net/packages/make.htm)
   或使用 Chocolatey: `choco install make`

### 步骤 5: 验证安装

打开 PowerShell 或 CMD:

```powershell
# 检查工具链
riscv-none-embed-gcc --version

# 检查 QEMU
qemu-system-riscv64 --version

# 检查 Git
git --version

# 检查 Make
make --version
```

## 🍫 方案三: Chocolatey

### 步骤 1: 安装 Chocolatey

以管理员身份打开 PowerShell:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### 步骤 2: 安装开发工具

```powershell
# 安装 RISC-V 工具链 (如果可用)
choco install riscv-tools

# 安装 QEMU
choco install qemu

# 安装其他工具
choco install make git
```

## 🛠️ Windows 开发工作流

### 修改 Makefile 以兼容 Windows

由于 Windows 路径分隔符不同，可能需要修改 Makefile:

```makefile
# 在 Makefile 开头添加
ifeq ($(OS),Windows_NT)
    RM = del /Q
    RMDIR = rmdir /S /Q
    CP = copy
    MKDIR = mkdir
else
    RM = rm -f
    RMDIR = rm -rf
    CP = cp
    MKDIR = mkdir -p
endif
```

### 脚本适配 Windows

创建 Windows 版本的脚本:

**windows-sync-upstream.bat:**
```batch
@echo off
echo 🔄 开始同步上游仓库...

git fetch upstream
git checkout riscv
git merge upstream/riscv
git push origin riscv

echo ✅ 同步完成!
pause
```

**windows-build-debug.bat:**
```batch
@echo off
set "COMMAND=%1"
if "%COMMAND%"=="" set "COMMAND=run"

if "%COMMAND%"=="run" (
    echo 🔨 构建并运行 xv6...
    make qemu
) else if "%COMMAND%"=="gdb" (
    echo 🐛 启动调试模式...
    make qemu-gdb
) else if "%COMMAND%"=="clean" (
    echo 🧹 清理构建文件...
    make clean
) else (
    echo ❌ 未知命令: %COMMAND%
)
```

## 🐛 Windows 调试配置

### GDB 调试

```bash
# 启动调试会话
make qemu-gdb

# 在另一个终端中
riscv-none-embed-gdb kernel/kernel
(gdb) target remote localhost:26000
(gdb) break main
(gdb) continue
```

### VS Code 调试配置

创建 `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug xv6",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/kernel/kernel",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": true,
            "MIMode": "gdb",
            "miDebuggerPath": "riscv-none-embed-gdb.exe",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```

## 🚨 常见 Windows 问题解决

### 问题 1: "make: command not found"

**解决方案:**
- 确保安装了 MSYS2 的 make 包
- 使用 `mingw32-make.exe` 代替 `make`
- 添加 make 到 PATH 环境变量

### 问题 2: QEMU 无法启动

**解决方案:**
- 检查 QEMU 安装路径
- 尝试使用完整路径: `C:\Program Files\qemu\qemu-system-riscv64.exe`
- 检查 Windows 防火墙设置

### 问题 3: 路径分隔符问题

**解决方案:**
- 使用 Git Bash 或 MSYS2 终端
- 在 PowerShell 中使用正斜杠路径
- 修改脚本使用 Windows 路径格式

### 问题 4: 权限问题

**解决方案:**
- 以管理员身份运行 PowerShell
- 检查文件和目录的权限
- 确保没有杀毒软件阻止

### 问题 5: 字符编码问题

**解决方案:**
- 在 PowerShell 中设置编码: `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`
- 使用支持 UTF-8 的终端
- 在 Git 中配置: `git config --global core.autocrlf false`

## 🎯 开发建议

### 推荐的 Windows 开发环境

1. **主要终端**: MSYS2 MINGW64 (最兼容)
2. **代码编辑器**: VS Code + 扩展
3. **调试工具**: GDB + QEMU
4. **Git**: Git for Windows
5. **可选**: Windows Terminal (更好的终端体验)

### 开发流程

```powershell
# 每天开始开发前
git fetch upstream
git checkout riscv
git merge upstream/riscv

# 创建功能分支
git checkout -b feature/my-feature

# 开发过程中
make clean && make qemu  # 清理并构建
make qemu-gdb           # 调试模式

# 提交代码
git add .
git commit -m "feat: 添加新功能"
git push origin feature/my-feature
```

### 性能优化

1. 使用 SSD 存储项目文件
2. 增加虚拟内存到 16GB+
3. 关闭不必要的后台程序
4. 使用 Windows Terminal 提升终端性能

---

💡 **提示**: MSYS2 提供了最接近 Linux 的开发体验，强烈推荐使用！如果遇到问题，可以查看 [MSYS2 文档](https://www.msys2.org/docs/) 和 [xv6 官方文档](https://pdos.csail.mit.edu/6.S081/2020/xv6/book/)。
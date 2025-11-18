# 🚀 xv6-riscv 快速开始指南

## 📋 前置要求

### 必需工具
- **RISC-V 工具链**: `riscv64-unknown-elf-gcc` 或 `riscv64-linux-gnu-gcc`
- **QEMU**: `qemu-system-riscv64` (版本 7.0+)
- **Git**: 用于版本控制
- **Make**: 构建工具

### 工具链安装

#### Ubuntu/Debian
```bash
# 安装 RISC-V 工具链
sudo apt update
sudo apt install gcc-riscv64-linux-gnu

# 安装 QEMU
sudo apt install qemu-system-riscv64
```

#### macOS (使用 Homebrew)
```bash
# 安装 RISC-V 工具链
brew install riscv-tools

# 安装 QEMU
brew install qemu
```

#### Windows 原生开发 (推荐)

**方案一: 使用 MSYS2 (最简单)**
```powershell
# 1. 安装 MSYS2: https://www.msys2.org/
# 2. 打开 MSYS2 MINGW64 终端

# 更新包管理器
pacman -Syu

# 安装 RISC-V 工具链
pacman -S mingw-w64-x86_64-riscv-none-embed-gcc

# 安装 QEMU
pacman -S mingw-w64-x86_64-qemu

# 安装其他工具
pacman -S mingw-w64-x86_64-make mingw-w64-x86_64-git
```

**方案二: 使用预编译二进制文件**
```powershell
# 1. 下载 RISC-V 工具链
# 访问: https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases
# 下载最新版本并解压到 C:\xpack-riscv-none-embed-gcc

# 2. 下载 QEMU Windows 版本
# 访问: https://qemu.weilnetz.de/w64/
# 下载 qemu-w64-setup-xxx.exe 并安装

# 3. 添加到环境变量 PATH
# C:\xpack-riscv-none-embed-gcc\bin
# C:\Program Files\qemu
```

**方案三: 使用 Chocolatey**
```powershell
# 安装 Chocolatey (以管理员身份运行 PowerShell)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 安装工具
choco install riscv-tools qemu make git
```

#### Windows (使用 WSL - 备选方案)
```bash
# 在 WSL Ubuntu 中执行
sudo apt update
sudo apt install gcc-riscv64-linux-gnu qemu-system-riscv64
```

## ⚡ 快速开始

### 1. 首次设置
```bash
# 克隆你的 fork (如果还没有)
git clone https://github.com/Desperado1001/xv6-riscv.git
cd xv6-riscv

# 添加上游仓库 (如果还没有)
git remote add upstream https://github.com/mit-pdos/xv6-riscv.git

# 同步最新代码
git fetch upstream
git checkout riscv
git merge upstream/riscv
```

### 2. 构建和运行

**Windows 原生开发:**
```powershell
# 在 MSYS2 MINGW64 或 PowerShell 中执行
cd xv6-riscv

# 构建并运行 xv6
make qemu

# 在 xv6 中试试基本命令
$ echo "Hello xv6!"
$ ls
$ cat README
$ exit  # 退出 QEMU
```

**如果遇到 make 工具问题:**
```powershell
# Windows 可能需要使用不同的 make 命令
mingw32-make.exe qemu
# 或
make.exe qemu
```

### 3. 运行测试
```bash
# 运行用户程序测试
make qemu-usertests

# 运行性能测试
make qemu-test
```

## 🛠️ 开发工作流

### 同步上游仓库
```bash
# 使用提供的脚本
./scripts/sync-upstream.sh

# 或手动执行
git fetch upstream
git checkout riscv
git merge upstream/riscv
git push origin riscv
```

### 创建功能分支
```bash
# 使用脚本创建功能分支
./scripts/create-feature.sh my-new-feature

# 或手动执行
git checkout -b feature/my-new-feature
git push -u origin feature/my-new-feature
```

### 构建和调试
```bash
# 使用脚本
./scripts/build-debug.sh run     # 运行
./scripts/build-debug.sh gdb     # 调试
./scripts/build-debug.sh clean   # 清理
```

## 🔍 代码探索

### 查看启动流程
```bash
# 查看内核启动入口
less kernel/entry.S

# 查看主函数
less kernel/main.c

# 查看进程管理
less kernel/proc.c
```

### 调试技巧
```bash
# 启动调试会话
make qemu-gdb &
gdb-multiarch kernel/kernel

# 在 GDB 中
(gdb) target remote localhost:26000
(gdb) break main
(gdb) continue
```

### 添加调试输出
```c
// 在代码中添加调试信息
printf("DEBUG: pid=%d, function=%s\n", myproc()->pid, __func__);
```

## 🎯 第一个实验：添加系统调用

### 1. 定义系统调用号
编辑 `user/usys.pl`:
```perl
# 添加你的系统调用
printf("sys hello\n");
```

### 2. 实现系统调用
编辑 `kernel/syscall.h`:
```c
#define SYS_hello 23  // 使用下一个可用的系统调用号
```

编辑 `kernel/syscall.c`:
```c
[SYS_hello] sys_hello,
```

### 3. 编写系统调用函数
```c
// 在 kernel/sysproc.c 中添加
uint64
sys_hello(void)
{
  printf("Hello from kernel!\n");
  return 0;
}
```

### 4. 添加用户空间包装
在 `user/user.h` 中:
```c
int hello(void);
```

在 `user/usys.pl` 中已经定义了调用号。

### 5. 测试系统调用
```c
// 创建 user/hello.c
#include "user/user.h"

int main() {
  hello();
  exit(0);
}
```

编译测试：
```bash
make qemu
$ hello
Hello from kernel!
```

## 📚 学习资源

### 推荐阅读顺序
1. **README.md** - 项目概述
2. **WORKFLOW.md** - 详细工作流指南
3. **kernel/main.c** - 内核启动流程
4. **kernel/proc.c** - 进程管理
5. **kernel/vm.c** - 内存管理
6. **kernel/syscall.c** - 系统调用机制

### 官方文档
- [xv6 Book](https://pdos.csail.mit.edu/6.S081/2020/xv6/book/) - 完整教材
- [MIT 6.S1810](https://pdos.csail.mit.edu/6.S081/) - 课程网站

## 🆘 常见问题

### Q: 构建失败，提示找不到工具链？
A: 确保安装了 RISC-V 工具链并在 PATH 中：
```bash
which riscv64-unknown-elf-gcc
# 或
which riscv64-linux-gnu-gcc
```

### Q: QEMU 启动失败？
A: 检查 QEMU 版本：
```bash
qemu-system-riscv64 --version
```

### Q: 如何查看所有系统调用？
A: 查看 `kernel/syscall.h` 中的定义。

### Q: 如何添加新的用户程序？
A: 在 `user/` 目录创建 `.c` 文件，然后在 `Makefile` 的 `UPROGS` 列表中添加。

---

## 🪟 Windows 用户特别说明

### 详细 Windows 安装指南
- **[📖 Windows 完整安装指南](WINDOWS_SETUP.md)** - 原生 Windows 开发环境的详细设置说明

### Windows 脚本工具
```powershell
# 使用 Windows 版本的脚本
scripts\windows-sync-upstream.bat    # 同步上游更新
scripts\windows-create-feature.bat my-feature  # 创建功能分支
scripts\windows-build-debug.bat      # 构建和调试
```

### Windows 兼容性
- 提供了 Windows 原生脚本 (.bat 文件)
- Makefile 兼容性补丁 (Makefile.windows.patch)
- VS Code 开发环境配置建议
- 详细的 Windows 问题解决方案

🎉 **恭喜！** 你现在已经准备好开始探索 xv6 操作系统的世界了！

如有问题，请查看 `WORKFLOW.md` 和 `WINDOWS_SETUP.md` 获取更详细的指南。
# 🔍 如何查看 MSYS2 终端环境类型

## 方法一：查看环境变量 `MSYSTEM`（推荐）

在 MSYS2 终端中运行：

```bash
echo $MSYSTEM
```

**可能的输出值：**
- `MINGW64` - MSYS2 MINGW64 环境（64位 MinGW，推荐用于 xv6）
- `MINGW32` - MSYS2 MINGW32 环境（32位 MinGW）
- `MSYS` - MSYS2 MSYS 环境（纯 MSYS2）
- `UCRT64` - MSYS2 UCRT64 环境（UCRT 版本）
- `CLANG64` - MSYS2 CLANG64 环境（Clang 版本）

## 方法二：查看架构变量

```bash
echo $MSYSTEM_CARCH
```

**可能的输出值：**
- `x86_64` - 64位架构
- `i686` - 32位架构

## 方法三：查看系统信息

```bash
uname -a
```

**输出示例：**
- `MINGW64_NT-10.0-19045` - MINGW64 环境
- `MSYS_NT-10.0-19045` - MSYS 环境

## 方法四：查看编译器路径

```bash
which gcc
```

**输出示例：**
- `/mingw64/bin/gcc` - MINGW64 环境
- `/mingw32/bin/gcc` - MINGW32 环境
- `/usr/bin/gcc` - MSYS 环境

## 方法五：查看提示符

MSYS2 终端的提示符通常包含环境信息：

- `user@hostname MINGW64 /path` - MINGW64 环境
- `user@hostname MINGW32 /path` - MINGW32 环境
- `user@hostname MSYS /path` - MSYS 环境

## 🎯 快速检查脚本

创建一个快速检查脚本：

```bash
#!/bin/bash
echo "=== MSYS2 环境信息 ==="
echo "MSYSTEM: $MSYSTEM"
echo "MSYSTEM_CARCH: $MSYSTEM_CARCH"
echo "PATH 前缀: $(echo $PATH | cut -d: -f1)"
echo "GCC 路径: $(which gcc 2>/dev/null || echo '未找到')"
echo "系统信息: $(uname -a)"
```

## 📝 在 VS Code 中检查

1. **打开集成终端**（`Ctrl+`` 或 ``Ctrl+Shift+``）
2. **确保终端是 MSYS2**（查看终端标签）
3. **运行检查命令**：

```bash
echo "当前环境: $MSYSTEM"
```

## ⚠️ 重要提示

- **xv6-riscv 项目推荐使用 MINGW64 环境**
- 如果环境不对，需要：
  1. 关闭当前终端
  2. 打开正确的 MSYS2 终端（如 "MSYS2 MINGW64"）
  3. 或修改 VS Code 配置中的终端路径

## 🔧 切换环境

如果需要切换环境，可以：

1. **在 VS Code 中**：
   - 点击终端下拉菜单
   - 选择 "MSYS2" 配置
   - 或创建新的终端配置文件

2. **手动启动**：
   - 从开始菜单启动对应的 MSYS2 终端
   - MINGW64: `D:\msys2\mingw64.exe`
   - MINGW32: `D:\msys2\mingw32.exe`
   - MSYS: `D:\msys2\msys2.exe`

## 📚 相关文档

- [MSYS2 官方文档](https://www.msys2.org/docs/environments/)
- `.vscode/README.md` - VS Code 配置说明
- `WINDOWS_SETUP.md` - Windows 环境设置指南


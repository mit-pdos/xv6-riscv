# 🔧 故障排除指南

## ❌ 错误：未找到目标 mingw-w64-x86_64-riscv64-unknown-elf-gdb

### 问题说明
MSYS2 中**没有单独的 GDB 包**。而且，`mingw-w64-x86_64-riscv64-unknown-elf-gcc` 包**可能不包含 GDB 可执行文件**，只包含 GDB Python 脚本。

### 解决方案

**步骤 1：检查 GDB 是否真的存在**
```bash
# 检查 GDB 可执行文件
which riscv64-unknown-elf-gdb

# 如果找不到，搜索所有可能的 GDB
find /mingw64 /ucrt64 -name "*gdb*" -type f 2>/dev/null | grep riscv
```

**步骤 2A：如果 GDB 不存在 - 使用预编译二进制文件（推荐）**

1. **下载 xPack RISC-V 工具链**：
   - 访问：https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases
   - 下载最新 Windows 版本（如 `xpack-riscv-none-embed-gcc-*-win32-x64.zip`）
   - 解压到 `D:\msys2\opt\xpack-riscv-none-embed-gcc\`

2. **添加到 PATH**：
   ```bash
   # 编辑 ~/.bashrc
   echo 'export PATH="/d/msys2/opt/xpack-riscv-none-embed-gcc/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **验证**：
   ```bash
   which riscv64-unknown-elf-gdb
   riscv64-unknown-elf-gdb --version
   ```

**步骤 2B：如果 GDB 已存在但路径不对**

如果 `which riscv64-unknown-elf-gdb` 找到了 GDB，但 VS Code 找不到：
1. 记录完整路径（如 `/mingw64/bin/riscv64-unknown-elf-gdb`）
2. 转换为 Windows 路径：`D:\msys2\mingw64\bin\riscv64-unknown-elf-gdb.exe`
3. 更新 `.vscode/launch.json` 中的 `miDebuggerPath`

**步骤 3：如果仍然找不到 GDB**

1. **检查是否在正确的环境中**：
   ```bash
   echo $MSYSTEM
   # 应该输出 MINGW64 或 UCRT64
   ```

2. **检查 PATH**：
   ```bash
   echo $PATH | grep -E "(mingw64|ucrt64)"
   ```

3. **手动查找 GDB**：
   ```bash
   find /mingw64 /ucrt64 -name "riscv64-unknown-elf-gdb*" 2>/dev/null
   ```

## 🐛 QEMU 运行任务问题

### 问题：任务 "make: 运行 QEMU" 失败

**可能原因和解决方案**：

1. **项目未构建**：
   ```bash
   # 先构建项目
   make
   # 或使用 VS Code 任务：Ctrl+Shift+B
   ```

2. **QEMU 未安装**：
   ```bash
   # 安装 QEMU
   pacman -S mingw-w64-x86_64-qemu
   
   # 验证安装
   qemu-system-riscv64 --version
   ```

3. **工具链未安装**：
   ```bash
   # 安装 RISC-V 工具链
   pacman -S mingw-w64-x86_64-riscv64-unknown-elf-gcc
   
   # 验证
   riscv64-unknown-elf-gcc --version
   ```

4. **Make 未安装**：
   ```bash
   # 安装 make
   pacman -S mingw-w64-x86_64-make
   
   # 或使用 mingw32-make
   pacman -S make
   ```

### 测试 QEMU 运行

**手动测试**（在 MSYS2 终端中）：
```bash
cd /e/system_program/xv6-riscv

# 清理并构建
make clean
make

# 运行 QEMU
make qemu
```

**预期结果**：
- QEMU 窗口应该打开
- 看到 xv6 启动信息
- 可以使用 `Ctrl+A` 然后 `X` 退出

**如果失败**，检查错误信息：
- 找不到 `qemu-system-riscv64` → 安装 QEMU
- 找不到 `riscv64-unknown-elf-gcc` → 安装工具链
- 找不到 `make` → 安装 make
- 构建错误 → 检查 Makefile 和源代码

## 🔍 快速诊断命令

在 MSYS2 终端中运行以下命令进行完整检查：

```bash
echo "=== 环境检查 ==="
echo "MSYSTEM: $MSYSTEM"
echo "PATH: $PATH"

echo ""
echo "=== 工具检查 ==="
which riscv64-unknown-elf-gcc && riscv64-unknown-elf-gcc --version || echo "❌ GCC 未安装"
which riscv64-unknown-elf-gdb && riscv64-unknown-elf-gdb --version || echo "❌ GDB 未安装"
which qemu-system-riscv64 && qemu-system-riscv64 --version || echo "❌ QEMU 未安装"
which make && make --version || echo "❌ Make 未安装"

echo ""
echo "=== 项目检查 ==="
cd /e/system_program/xv6-riscv
test -f Makefile && echo "✅ Makefile 存在" || echo "❌ Makefile 不存在"
test -d kernel && echo "✅ kernel 目录存在" || echo "❌ kernel 目录不存在"
```

## 📝 常见错误代码

### 错误代码 16
通常表示任务执行失败。检查：
1. 终端输出中的具体错误信息
2. 工具是否已安装
3. 路径配置是否正确

### 其他常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `command not found` | 工具未安装 | 使用 `pacman -S` 安装 |
| `No such file or directory` | 路径错误 | 检查配置文件中的路径 |
| `Permission denied` | 权限问题 | 检查文件权限 |
| `Connection refused` | 端口问题 | 检查 GDB 端口配置 |

## 🆘 获取更多帮助

如果问题仍未解决：

1. **查看详细错误信息**：复制完整的错误消息
2. **检查 VS Code 输出**：`Ctrl+Shift+U` → 选择 "Tasks" 或 "Terminal"
3. **手动测试**：在 MSYS2 终端中手动运行命令
4. **查看文档**：
   - `.vscode/README.md` - 配置说明
   - `.vscode/TESTING.md` - 测试指南
   - `WINDOWS_SETUP.md` - Windows 环境设置


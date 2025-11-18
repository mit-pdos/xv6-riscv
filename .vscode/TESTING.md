# 🧪 VS Code 配置测试指南

## 修复内容

已修复 `tasks.json` 中的 shell 配置：
- **移除了 `-i` 参数**：交互模式不适合 VS Code tasks
- **保留 `--login -c`**：确保加载环境变量并执行命令

## 📋 测试步骤

### 1. 测试构建任务

1. 按 `Ctrl+Shift+B` 或 `Ctrl+Shift+P` → "Tasks: Run Build Task"
2. 选择 "make: 构建 xv6"
3. **预期结果**：应该能看到编译输出，没有错误

**如果失败**，检查：
```bash
# 在 MSYS2 终端中手动测试
cd /e/system_program/xv6-riscv
make
```

### 2. 测试清理任务

1. `Ctrl+Shift+P` → "Tasks: Run Task"
2. 选择 "make: 清理构建文件"
3. **预期结果**：清理完成，没有错误

### 3. 测试运行 QEMU（非调试模式）

1. `Ctrl+Shift+P` → "Tasks: Run Task"
2. 选择 "make: 运行 QEMU"
3. **预期结果**：QEMU 启动，xv6 运行
4. **退出**：按 `Ctrl+A` 然后 `X`

**如果失败**，检查：
```bash
# 在 MSYS2 终端中手动测试
cd /e/system_program/xv6-riscv
make qemu
```

### 4. 测试 GDB 调试配置

#### 方法 A：自动调试（推荐）

1. 确保项目已构建：`Ctrl+Shift+B`
2. 在代码中设置断点（例如在 `kernel/main.c` 的 `main` 函数）
3. 按 `F5` 或点击调试按钮
4. 选择 "调试 xv6 (GDB)"
5. **预期结果**：
   - QEMU 在后台启动（GDB 模式）
   - GDB 自动连接
   - 程序停在断点处

#### 方法 B：手动调试

1. **启动 QEMU（GDB 模式）**：
   - `Ctrl+Shift+P` → "Tasks: Run Task"
   - 选择 "make: 启动 QEMU (GDB 模式)"
   - **预期**：看到 "Now run 'gdb' in another window."

2. **查看 GDB 端口**：
   - `Ctrl+Shift+P` → "Tasks: Run Task"
   - 选择 "make: 显示 GDB 端口"
   - **记录端口号**（通常是 26000）

3. **启动调试**：
   - 按 `F5`
   - 选择 "调试 xv6 (附加到运行中的 QEMU)"
   - **预期**：GDB 连接成功

### 5. 验证工具链

在 MSYS2 终端中运行：

```bash
# 检查编译器
riscv64-unknown-elf-gcc --version

# 检查 GDB
riscv64-unknown-elf-gdb --version

# 检查 QEMU
qemu-system-riscv64 --version

# 检查 make
make --version
```

## 🐛 常见错误及解决方案

### 错误 1: "找不到 bash.exe"

**错误信息**：
```
The terminal process failed to launch: Path to shell executable "D:\msys2\usr\bin\bash.exe" does not exist
```

**解决方案**：
1. 确认 MSYS2 安装路径是否正确
2. 检查文件是否存在：`D:\msys2\usr\bin\bash.exe`
3. 如果路径不同，更新 `settings.json` 和 `tasks.json`

### 错误 2: "make: command not found"

**错误信息**：
```
make: command not found
```

**解决方案**：
1. 确保在 MSYS2 环境中运行
2. 安装 make：`pacman -S make`
3. 或使用 `mingw32-make`：修改 Makefile 或使用 `mingw32-make` 命令

### 错误 3: "riscv64-unknown-elf-gcc: command not found"

**错误信息**：
```
riscv64-unknown-elf-gcc: command not found
```

**解决方案**：
1. 安装工具链：`pacman -S mingw-w64-x86_64-riscv64-unknown-elf-gcc`
2. 检查 PATH：`echo $PATH | grep mingw64`
3. 重新加载终端

### 错误 4: GDB 连接失败

**错误信息**：
```
Unable to start debugging. Unable to establish a connection to GDB.
```

**解决方案**：
1. **检查端口**：运行 `make print-gdbport` 查看实际端口
2. **更新 launch.json**：如果端口不是 26000，更新所有 `localhost:26000` 为实际端口
3. **确保 QEMU 已启动**：先运行 "make: 启动 QEMU (GDB 模式)" 任务
4. **检查防火墙**：确保端口未被阻止

### 错误 5: "qemu-system-riscv64: command not found"

**错误信息**：
```
qemu-system-riscv64: command not found
```

**解决方案**：
1. 安装 QEMU：`pacman -S mingw-w64-x86_64-qemu`
2. 检查安装：`which qemu-system-riscv64`

### 错误 6: 任务执行超时或挂起

**可能原因**：
- Shell 参数配置错误（已修复）
- 命令执行时间过长

**解决方案**：
1. 检查 `tasks.json` 中的 shell 配置
2. 对于长时间运行的任务（如 QEMU），确保 `isBackground` 设置为 `true`

## ✅ 验证清单
![1763444815693](image/TESTING/1763444815693.png)![1763444819874](image/TESTING/1763444819874.png)
完成以下检查确保配置正确：

- [ ] MSYS2 路径正确：`D:\msys2\usr\bin\bash.exe` 存在
- [ ] 工具链已安装：`riscv64-unknown-elf-gcc --version` 有输出
- [ ] GDB 已安装：`riscv64-unknown-elf-gdb --version` 有输出
- [ ] QEMU 已安装：`qemu-system-riscv64 --version` 有输出
- [ ] Make 可用：`make --version` 有输出
- [ ] 构建成功：`Ctrl+Shift+B` 无错误
- [ ] QEMU 能启动：运行 "make: 运行 QEMU" 任务成功
- [ ] GDB 端口正确：`make print-gdbport` 显示端口号
- [ ] 调试能连接：按 `F5` 能连接到 GDB

## 📞 获取帮助

如果遇到问题：

1. **查看错误信息**：复制完整的错误消息
2. **检查日志**：查看 VS Code 的输出面板
3. **手动测试**：在 MSYS2 终端中手动运行命令
4. **查看文档**：
   - `.vscode/README.md` - 详细配置说明
   - `.vscode/QUICK_START.md` - 快速开始指南
   - `WINDOWS_SETUP.md` - Windows 环境设置

## 🔧 调试技巧

### 查看任务输出

1. 打开输出面板：`Ctrl+Shift+U`
2. 选择 "Tasks" 或 "Terminal" 输出
3. 查看详细错误信息

### 手动测试命令

在 MSYS2 终端中直接运行：

```bash
# 测试构建
cd /e/system_program/xv6-riscv
make clean
make

# 测试 QEMU
make qemu
# 按 Ctrl+A, X 退出

# 测试 GDB 模式
make qemu-gdb
# 在另一个终端中
riscv64-unknown-elf-gdb kernel/kernel
(gdb) target remote localhost:26000
(gdb) break main
(gdb) continue
```

### 检查配置文件

```bash
# 验证 JSON 语法
cat .vscode/tasks.json | python -m json.tool
cat .vscode/launch.json | python -m json.tool
cat .vscode/settings.json | python -m json.tool
```


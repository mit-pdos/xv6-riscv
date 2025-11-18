# VS Code 配置说明

本目录包含 xv6-riscv 项目的 VS Code 配置文件，专为 Windows + MSYS2 MINGW64 环境优化。

## 📁 配置文件说明

### `settings.json`
- **默认终端**: 配置为 MSYS2 MINGW64 bash
- **编译器路径**: `riscv64-unknown-elf-gcc`
- **文件编码**: UTF-8
- **文件关联**: `.S` 文件识别为汇编，`.ld` 识别为链接脚本

### `tasks.json`
提供以下构建任务：
- **make: 构建 xv6** - 默认构建任务（Ctrl+Shift+B）
- **make: 清理构建文件** - 清理所有构建产物
- **make: 运行 QEMU** - 构建并运行 xv6
- **make: 启动 QEMU (GDB 模式)** - 启动 QEMU 并等待 GDB 连接
- **make: 显示 GDB 端口** - 显示当前 GDB 调试端口

### `launch.json`
提供两种调试配置：
1. **调试 xv6 (GDB)** - 自动启动 QEMU 并连接 GDB（推荐）
2. **调试 xv6 (附加到运行中的 QEMU)** - 连接到已运行的 QEMU 实例

### `c_cpp_properties.json`
- IntelliSense 配置
- 包含路径设置
- 编译器参数配置
- 代码补全和跳转支持

## 🚀 使用方法

### 1. 构建项目
- 按 `Ctrl+Shift+B` 或运行任务 "make: 构建 xv6"

### 2. 运行 xv6
- 运行任务 "make: 运行 QEMU"
- 或按 `F5` 启动调试（会自动构建）

### 3. 调试 xv6
1. 按 `F5` 或点击调试按钮
2. VS Code 会自动：
   - 启动 QEMU（GDB 模式）
   - 连接 GDB
   - 加载符号文件
3. 设置断点并开始调试

### 4. 手动调试流程
如果自动调试不工作，可以手动操作：

1. **启动 QEMU（GDB 模式）**:
   ```bash
   make qemu-gdb
   ```

2. **查看 GDB 端口**:
   ```bash
   make print-gdbport
   ```
   通常端口是 26000（基于用户 ID 计算）

3. **在 VS Code 中启动调试**:
   - 使用 "调试 xv6 (附加到运行中的 QEMU)" 配置
   - 或手动连接 GDB

## ⚙️ 配置调整

### 修改 MSYS2 路径
如果 MSYS2 安装在非默认路径（当前配置为 `D:\msys2`），需要修改：
- `settings.json` 中的 `terminal.integrated.profiles.windows.MSYS2.path`
- `tasks.json` 中所有任务的 `shell.executable`

### 修改 GDB 端口
默认端口通过 `id -u` 计算：`(id -u % 5000) + 25000`，范围通常是 25000-29999。

**重要**: `launch.json` 中硬编码了端口 26000。如果您的实际端口不同：

1. **查看实际端口**:
   ```bash
   make print-gdbport
   ```

2. **更新 launch.json**: 将所有 `localhost:26000` 替换为您的实际端口（如 `localhost:25001`）

或者，您可以在 `Makefile` 中固定端口：
```makefile
GDBPORT = 26000  # 固定端口
```

### 修改编译器路径
如果使用不同的工具链前缀（如 `riscv64-elf-`），需要修改：
- `settings.json` 中的 `C_Cpp.default.compilerPath`
- `c_cpp_properties.json` 中的 `compilerPath`
- `launch.json` 中的 `miDebuggerPath`

## 🐛 常见问题

### Q: 终端无法启动 MSYS2
A: 检查 MSYS2 安装路径是否为 `D:\msys2`（当前配置），如果不是，请修改配置文件中的路径。

### Q: GDB 连接失败
A: 
1. 确保 QEMU 已启动（GDB 模式）
2. 检查端口是否正确：运行 `make print-gdbport`
3. 检查防火墙设置
4. 确保 GDB 路径正确：`which riscv64-unknown-elf-gdb`

### Q: IntelliSense 不工作
A:
1. 重新加载 VS Code 窗口：`Ctrl+Shift+P` → "Reload Window"
2. 检查 `c_cpp_properties.json` 中的路径是否正确
3. 确保安装了 C/C++ 扩展

### Q: 构建任务失败
A:
1. 确保在 MSYS2 终端中运行
2. 检查工具链是否安装：`riscv64-unknown-elf-gcc --version`
3. 检查 QEMU 是否安装：`qemu-system-riscv64 --version`

## 📝 注意事项

1. **终端环境**: 所有任务都在 MSYS2 MINGW64 环境中运行，确保工具链在该环境中可用
2. **路径格式**: MSYS2 使用 Unix 风格路径，但 Windows 路径也可以工作
3. **GDB 端口**: 端口号基于用户 ID 计算，不同用户可能不同
4. **符号文件**: 调试前确保已构建内核：`make` 或 `make qemu-gdb`

## 🔗 相关资源

- [xv6 Book](https://pdos.csail.mit.edu/6.S081/2020/xv6/book/)
- [MSYS2 文档](https://www.msys2.org/docs/)
- [VS Code C/C++ 扩展文档](https://code.visualstudio.com/docs/languages/cpp)


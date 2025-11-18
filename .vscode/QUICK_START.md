# 🚀 快速开始指南

## 一键调试流程

1. **打开 VS Code** 在项目根目录
2. **按 `F5`** 开始调试
   - 自动构建项目
   - 启动 QEMU (GDB 模式)
   - 连接 GDB
   - 加载符号文件
3. **设置断点** 在代码中点击行号左侧
4. **开始调试**！

## 常用快捷键

| 操作 | 快捷键 | 说明 |
|------|--------|------|
| 构建项目 | `Ctrl+Shift+B` | 运行默认构建任务 |
| 开始调试 | `F5` | 启动调试会话 |
| 继续执行 | `F5` | 在调试中继续 |
| 单步跳过 | `F10` | Step over |
| 单步进入 | `F11` | Step into |
| 单步跳出 | `Shift+F11` | Step out |
| 重启调试 | `Ctrl+Shift+F5` | 重新启动调试 |
| 停止调试 | `Shift+F5` | 停止调试会话 |

## 常用任务

按 `Ctrl+Shift+P` 输入 "Tasks: Run Task"，然后选择：

- **make: 构建 xv6** - 编译项目
- **make: 清理构建文件** - 清理所有构建产物
- **make: 运行 QEMU** - 直接运行 xv6（不调试）
- **make: 启动 QEMU (GDB 模式)** - 启动调试服务器
- **make: 显示 GDB 端口** - 查看当前 GDB 端口

## 调试配置

### 配置 1: 调试 xv6 (GDB) ⭐ 推荐
- **自动启动 QEMU**
- **自动连接 GDB**
- **一键调试**

### 配置 2: 附加到运行中的 QEMU
- 手动启动 QEMU: `make qemu-gdb`
- 然后使用此配置连接

## 检查清单

首次使用前，请确认：

- [ ] MSYS2 已安装（当前配置路径：`D:\msys2`）
- [ ] RISC-V 工具链已安装：`riscv64-unknown-elf-gcc --version`
- [ ] QEMU 已安装：`qemu-system-riscv64 --version`
- [ ] GDB 已安装：`riscv64-unknown-elf-gdb --version`
- [ ] VS Code 已安装 C/C++ 扩展
- [ ] 项目已构建：`make` 或 `Ctrl+Shift+B`

## 故障排除

### 问题：终端无法启动
**解决**: 检查 MSYS2 路径是否为 `D:\msys2`（当前配置），如果不是，修改 `settings.json`

### 问题：GDB 连接失败
**解决**: 
1. 运行 `make print-gdbport` 查看端口
2. 如果端口不是 26000，更新 `launch.json` 中的端口号

### 问题：构建失败
**解决**: 
1. 确保在 MSYS2 环境中
2. 检查工具链：`which riscv64-unknown-elf-gcc`
3. 检查 Makefile 是否正确

### 问题：断点不生效
**解决**:
1. 确保已构建调试版本：`make clean && make`
2. 检查符号文件是否存在：`ls kernel/kernel`
3. 重新加载 VS Code 窗口

## 下一步

- 阅读 `.vscode/README.md` 了解详细配置
- 查看 `WINDOWS_SETUP.md` 了解环境配置
- 开始 xv6 学习之旅！


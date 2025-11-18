# 🔧 xPack RISC-V 工具链配置说明

## ✅ 已完成的配置

### 1. Makefile 更新
- ✅ 添加了对 `riscv-none-elf-` 工具链前缀的支持
- ✅ Makefile 会自动检测并使用 xPack 工具链

### 2. VS Code 配置更新

#### `.vscode/c_cpp_properties.json`
- ✅ 编译器路径：`D:\msys2\opt\xpack-riscv-none-elf-gcc-15.2.0-1\bin\riscv-none-elf-gcc.exe`

#### `.vscode/launch.json`
- ✅ GDB 路径：`D:\msys2\opt\xpack-riscv-none-elf-gcc-15.2.0-1\bin\riscv-none-elf-gdb.exe`
- ✅ 两个调试配置都已更新

#### `.vscode/settings.json`
- ✅ 默认编译器路径已更新

### 3. Shell 环境配置
- ✅ 已创建配置脚本：`.vscode/setup-toolchain.sh`
- ✅ 会自动配置 `~/.bashrc` 和 `~/.zshrc`

## 🚀 使用步骤

### 步骤 1: 配置 PATH 环境变量

运行配置脚本（如果还没运行）：
```bash
bash .vscode/setup-toolchain.sh
```

或者手动添加到 shell 配置文件：

**对于 bash**：
```bash
echo 'export PATH="/d/msys2/opt/xpack-riscv-none-elf-gcc-15.2.0-1/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**对于 zsh**：
```bash
echo 'export PATH="/d/msys2/opt/xpack-riscv-none-elf-gcc-15.2.0-1/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 步骤 2: 验证工具链

```bash
# 检查编译器
riscv-none-elf-gcc --version

# 检查 GDB
riscv-none-elf-gdb --version

# 检查工具是否在 PATH 中
which riscv-none-elf-gcc
which riscv-none-elf-gdb
```

### 步骤 3: 测试构建

```bash
# 清理之前的构建
make clean

# 构建项目
make

# 或者使用 VS Code 任务：Ctrl+Shift+B
```

### 步骤 4: 测试运行和调试

1. **运行 QEMU**：
   - `Ctrl+Shift+P` → "Tasks: Run Task" → "make: 运行 QEMU"

2. **调试**：
   - 设置断点（例如在 `kernel/main.c`）
   - 按 `F5` 启动调试
   - 选择 "调试 xv6 (GDB)"

## 📋 工具链信息

- **工具链名称**: xPack GNU RISC-V Embedded GCC
- **版本**: 15.2.0-1
- **安装路径**: `D:\msys2\opt\xpack-riscv-none-elf-gcc-15.2.0-1`
- **工具前缀**: `riscv-none-elf-`
- **GitHub**: https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack

## 🔍 工具链包含的工具

- `riscv-none-elf-gcc` - C/C++ 编译器
- `riscv-none-elf-gdb` - GDB 调试器
- `riscv-none-elf-objdump` - 反汇编工具
- `riscv-none-elf-objcopy` - 对象文件转换工具
- `riscv-none-elf-ld` - 链接器
- 其他 binutils 工具

## ⚠️ 重要提示

1. **工具前缀不同**：
   - xPack 使用：`riscv-none-elf-`
   - MSYS2 包使用：`riscv64-unknown-elf-`
   - Makefile 已更新以支持两种前缀

2. **PATH 配置**：
   - VS Code 任务使用 bash，需要配置 `~/.bashrc`
   - 如果使用 zsh，也需要配置 `~/.zshrc`
   - 建议同时配置两个文件以确保兼容性

3. **VS Code 配置**：
   - 所有配置文件已使用完整路径，不依赖 PATH
   - 但 PATH 配置仍然需要，因为 Makefile 会使用它

## 🐛 故障排除

### 问题：找不到工具链

**检查**：
```bash
# 检查路径是否存在
ls -la /d/msys2/opt/xpack-riscv-none-elf-gcc-15.2.0-1/bin/

# 检查 PATH
echo $PATH | grep xpack

# 重新加载 shell
source ~/.bashrc  # 或 source ~/.zshrc
```

### 问题：Makefile 找不到工具链

**解决**：
```bash
# 手动指定工具前缀
make TOOLPREFIX=riscv-none-elf-

# 或确保 PATH 已配置
export PATH="/d/msys2/opt/xpack-riscv-none-elf-gcc-15.2.0-1/bin:$PATH"
make
```

### 问题：VS Code 找不到编译器/GDB

**检查**：
1. 确认文件路径正确：`D:\msys2\opt\xpack-riscv-none-elf-gcc-15.2.0-1\bin\riscv-none-elf-gcc.exe`
2. 重新加载 VS Code 窗口：`Ctrl+Shift+P` → "Reload Window"
3. 检查文件是否存在：在文件管理器中验证路径

## 📚 相关文档

- `.vscode/README.md` - VS Code 配置说明
- `.vscode/TROUBLESHOOTING.md` - 故障排除指南
- `.vscode/INSTALL_GDB.md` - GDB 安装指南
- `.vscode/TESTING.md` - 测试指南

## ✅ 验证清单

完成以下检查确保配置正确：

- [ ] 工具链已解压到 `D:\msys2\opt\xpack-riscv-none-elf-gcc-15.2.0-1\`
- [ ] PATH 已配置（运行 `setup-toolchain.sh` 或手动配置）
- [ ] `riscv-none-elf-gcc --version` 有输出
- [ ] `riscv-none-elf-gdb --version` 有输出
- [ ] VS Code 配置文件已更新（已自动完成）
- [ ] Makefile 已更新（已自动完成）
- [ ] 项目可以构建：`make clean && make`
- [ ] QEMU 可以运行：运行 "make: 运行 QEMU" 任务
- [ ] 调试可以工作：按 `F5` 启动调试

## 🎉 完成！

配置已完成！现在您可以：
1. 使用 `make` 构建项目
2. 使用 VS Code 任务运行和调试
3. 使用 `F5` 进行调试

如有问题，请查看故障排除文档或运行检查脚本。


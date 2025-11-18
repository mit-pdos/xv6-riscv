#!/bin/bash

# xPack RISC-V 工具链配置脚本
# 使用方法: bash .vscode/setup-toolchain.sh

TOOLCHAIN_PATH="/d/msys2/opt/xpack-riscv-none-elf-gcc-15.2.0-1/bin"
BIN_PATH="${TOOLCHAIN_PATH}"

echo "=========================================="
echo "🔧 配置 xPack RISC-V 工具链"
echo "=========================================="
echo ""

# 检查工具链是否存在
if [ ! -d "$BIN_PATH" ]; then
    echo "❌ 错误: 工具链路径不存在: $BIN_PATH"
    echo "💡 请确认工具链已解压到正确位置"
    exit 1
fi

echo "✅ 工具链路径: $BIN_PATH"
echo ""

# 检查工具是否存在
echo "🔍 检查工具链文件..."
for tool in gcc gdb objdump; do
    if [ -f "${BIN_PATH}/riscv-none-elf-${tool}" ] || [ -f "${BIN_PATH}/riscv-none-elf-${tool}.exe" ]; then
        echo "   ✅ riscv-none-elf-${tool} 存在"
    else
        echo "   ⚠️  riscv-none-elf-${tool} 未找到"
    fi
done

echo ""
echo "📝 配置 PATH 环境变量..."

# 检测当前 shell
CURRENT_SHELL=$(basename "$SHELL" 2>/dev/null || echo "bash")

# 配置 bashrc
if [ -f ~/.bashrc ]; then
    if grep -q "$BIN_PATH" ~/.bashrc; then
        echo "   ⚠️  ~/.bashrc 中已存在 PATH 配置"
    else
        echo "   export PATH=\"${BIN_PATH}:\$PATH\"" >> ~/.bashrc
        echo "   ✅ 已添加到 ~/.bashrc"
    fi
else
    echo "   export PATH=\"${BIN_PATH}:\$PATH\"" > ~/.bashrc
    echo "   ✅ 已创建 ~/.bashrc"
fi

# 配置 zshrc
if [ -f ~/.zshrc ]; then
    if grep -q "$BIN_PATH" ~/.zshrc; then
        echo "   ⚠️  ~/.zshrc 中已存在 PATH 配置"
    else
        echo "   export PATH=\"${BIN_PATH}:\$PATH\"" >> ~/.zshrc
        echo "   ✅ 已添加到 ~/.zshrc"
    fi
else
    echo "   export PATH=\"${BIN_PATH}:\$PATH\"" > ~/.zshrc
    echo "   ✅ 已创建 ~/.zshrc"
fi

echo ""
echo "🔄 更新当前会话的 PATH..."
export PATH="${BIN_PATH}:$PATH"

echo ""
echo "✅ 验证配置..."
if command -v riscv-none-elf-gcc >/dev/null 2>&1; then
    echo "   ✅ riscv-none-elf-gcc: $(which riscv-none-elf-gcc)"
    riscv-none-elf-gcc --version | head -1 | sed 's/^/      /'
else
    echo "   ⚠️  riscv-none-elf-gcc 未在 PATH 中找到"
    echo "   💡 请运行: source ~/.bashrc 或 source ~/.zshrc"
fi

if command -v riscv-none-elf-gdb >/dev/null 2>&1; then
    echo "   ✅ riscv-none-elf-gdb: $(which riscv-none-elf-gdb)"
    riscv-none-elf-gdb --version | head -1 | sed 's/^/      /'
else
    echo "   ⚠️  riscv-none-elf-gdb 未在 PATH 中找到"
    echo "   💡 请运行: source ~/.bashrc 或 source ~/.zshrc"
fi

echo ""
echo "=========================================="
echo "✅ 配置完成！"
echo "=========================================="
echo ""
echo "📋 下一步："
echo "   1. 重新加载 shell: source ~/.bashrc 或 source ~/.zshrc"
echo "   2. 验证工具链: riscv-none-elf-gcc --version"
echo "   3. 测试构建: make clean && make"
echo ""


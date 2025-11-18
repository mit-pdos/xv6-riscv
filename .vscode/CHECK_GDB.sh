#!/bin/bash

# GDB 检查脚本
# 使用方法: bash .vscode/CHECK_GDB.sh

echo "=========================================="
echo "🔍 检查 RISC-V GDB 安装"
echo "=========================================="
echo ""

echo "1️⃣ 检查 GDB 可执行文件："
GDB_PATH=$(which riscv64-unknown-elf-gdb 2>/dev/null)
if [ -n "$GDB_PATH" ]; then
    echo "   ✅ 找到: $GDB_PATH"
    echo "   📝 版本信息:"
    riscv64-unknown-elf-gdb --version 2>&1 | head -1 | sed 's/^/      /'
else
    echo "   ❌ 未找到 riscv64-unknown-elf-gdb"
fi

echo ""
echo "2️⃣ 搜索所有可能的 GDB 位置："
echo "   在 /mingw64 中搜索..."
find /mingw64 -name "*riscv*gdb*" -o -name "*gdb*riscv*" 2>/dev/null | head -10 | sed 's/^/   /'

echo ""
echo "   在 /ucrt64 中搜索..."
find /ucrt64 -name "*riscv*gdb*" -o -name "*gdb*riscv*" 2>/dev/null | head -10 | sed 's/^/   /'

echo ""
echo "3️⃣ 检查已安装的 RISC-V 包："
pacman -Q | grep riscv | sed 's/^/   /'

echo ""
echo "4️⃣ 检查 GCC 包中的 GDB 相关文件："
if pacman -Q mingw-w64-x86_64-riscv64-unknown-elf-gcc >/dev/null 2>&1; then
    echo "   GCC 包已安装，查找 GDB 可执行文件："
    pacman -Ql mingw-w64-x86_64-riscv64-unknown-elf-gcc 2>/dev/null | \
        grep -E "(bin/.*gdb|gdb.*\.exe)" | \
        grep -v "\.py" | \
        sed 's/^/   /' || echo "   ⚠️  未找到 GDB 可执行文件"
else
    echo "   ⚠️  GCC 包未安装"
fi

echo ""
echo "5️⃣ 检查 PATH 环境变量："
echo "   $PATH" | tr ':' '\n' | grep -E "(mingw64|ucrt64)" | sed 's/^/   /'

echo ""
echo "=========================================="
if [ -n "$GDB_PATH" ]; then
    echo "✅ GDB 已安装: $GDB_PATH"
    echo ""
    echo "💡 VS Code 配置路径应该是："
    echo "   $(echo $GDB_PATH | sed 's|^/|D:/msys2/|' | sed 's|/|\\|g').exe"
else
    echo "❌ GDB 未找到"
    echo ""
    echo "💡 建议："
    echo "   1. 下载 xPack RISC-V 工具链"
    echo "   2. 解压到 D:\\msys2\\opt\\xpack-riscv-none-embed-gcc\\"
    echo "   3. 添加到 PATH"
fi
echo "=========================================="


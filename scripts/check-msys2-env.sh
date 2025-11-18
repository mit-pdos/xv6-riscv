#!/bin/bash

# MSYS2 环境检查脚本
# 使用方法: ./scripts/check-msys2-env.sh

echo "=========================================="
echo "🔍 MSYS2 环境信息检查"
echo "=========================================="
echo ""

echo "📌 环境类型 (MSYSTEM):"
if [ -z "$MSYSTEM" ]; then
    echo "   ⚠️  未设置 (可能不在 MSYS2 环境中)"
else
    echo "   ✅ $MSYSTEM"
    case "$MSYSTEM" in
        MINGW64)
            echo "   📝 这是 MINGW64 环境（推荐用于 xv6-riscv）"
            ;;
        MINGW32)
            echo "   📝 这是 MINGW32 环境（32位）"
            ;;
        MSYS)
            echo "   📝 这是 MSYS 环境（纯 MSYS2）"
            ;;
        UCRT64)
            echo "   📝 这是 UCRT64 环境"
            ;;
        CLANG64)
            echo "   📝 这是 CLANG64 环境"
            ;;
        *)
            echo "   ⚠️  未知环境类型"
            ;;
    esac
fi

echo ""
echo "🏗️  架构信息 (MSYSTEM_CARCH):"
if [ -z "$MSYSTEM_CARCH" ]; then
    echo "   ⚠️  未设置"
else
    echo "   ✅ $MSYSTEM_CARCH"
fi

echo ""
echo "💻 系统信息:"
uname -a

echo ""
echo "🔧 编译器路径:"
echo "   GCC: $(which gcc 2>/dev/null || echo '未找到')"
echo "   RISC-V GCC: $(which riscv64-unknown-elf-gcc 2>/dev/null || echo '未找到')"

echo ""
echo "📂 PATH 环境变量前缀:"
echo "   $(echo $PATH | cut -d: -f1-3 | tr ':' '\n' | sed 's/^/   /')"

echo ""
echo "🎯 当前工作目录:"
echo "   $(pwd)"

echo ""
echo "=========================================="
echo "✅ 检查完成"
echo "=========================================="


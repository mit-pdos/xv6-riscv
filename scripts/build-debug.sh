#!/bin/bash

# 构建和调试脚本
# 使用方法: ./scripts/build-debug.sh [clean|run|gdb]

COMMAND=${1:-run}

case $COMMAND in
    "clean")
        echo "🧹 清理构建文件..."
        make clean
        ;;
    "run")
        echo "🔨 构建并运行 xv6..."
        make qemu
        ;;
    "gdb")
        echo "🐛 启动调试模式..."
        echo "💡 在另一个终端运行: gdb-multiarch kernel/kernel"
        echo "💡 然后: (gdb) target remote localhost:26000"
        make qemu-gdb
        ;;
    "test")
        echo "🧪 运行用户测试..."
        make qemu-usertests
        ;;
    "help"|"-h"|"--help")
        echo "使用方法: $0 [命令]"
        echo ""
        echo "可用命令:"
        echo "  clean  - 清理构建文件"
        echo "  run    - 构建并运行 (默认)"
        echo "  gdb    - 启动调试模式"
        echo "  test   - 运行用户测试"
        echo "  help   - 显示此帮助信息"
        ;;
    *)
        echo "❌ 未知命令: $COMMAND"
        echo "💡 运行 '$0 help' 查看可用命令"
        exit 1
        ;;
esac
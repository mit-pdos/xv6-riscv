@echo off
setlocal enabledelayedexpansion

:: 构建和调试脚本 (Windows版本)
:: 使用方法: scripts\windows-build-debug.bat [clean|run|gdb|test|help]

set "COMMAND=%1"
if "%COMMAND%"=="" set "COMMAND=run"

echo 🛠️  xv6 Windows 构建工具
echo.

:: 检查 make 工具
set "MAKE_CMD=make"
where make >nul 2>&1
if errorlevel 1 (
    where mingw32-make >nul 2>&1
    if not errorlevel 1 (
        set "MAKE_CMD=mingw32-make"
        echo 🔧 使用 mingw32-make
    ) else (
        echo ❌ 错误: 未找到 make 或 mingw32-make
        echo 💡 请安装 MSYS2 或其他 make 工具
        pause
        exit /b 1
    )
)

:: 检查 QEMU
where qemu-system-riscv64 >nul 2>&1
if errorlevel 1 (
    where "qemu-system-riscv64.exe" >nul 2>&1
    if errorlevel 1 (
        echo ⚠️  警告: 未找到 qemu-system-riscv64，构建可能会失败
    )
)

if "%COMMAND%"=="clean" (
    echo 🧹 清理构建文件...
    %MAKE_CMD% clean
    if errorlevel 1 (
        echo ❌ 清理失败
    ) else (
        echo ✅ 清理完成
    )

) else if "%COMMAND%"=="run" (
    echo 🔨 构建并运行 xv6...
    echo 💡 提示: 使用 Ctrl+A, X 退出 QEMU
    echo.
    %MAKE_CMD% qemu
    if errorlevel 1 (
        echo ❌ 构建或运行失败
        echo 💡 请检查工具链安装和 Makefile 配置
    )

) else if "%COMMAND%"=="gdb" (
    echo 🐛 启动调试模式...
    echo 💡 在另一个终端运行:
    echo    riscv-none-embed-gdb kernel/kernel
    echo    (gdb) target remote localhost:26000
    echo.
    %MAKE_CMD% qemu-gdb
    if errorlevel 1 (
        echo ❌ 调试模式启动失败
    )

) else if "%COMMAND%"=="test" (
    echo 🧪 运行用户测试...
    %MAKE_CMD% qemu-usertests
    if errorlevel 1 (
        echo ❌ 测试运行失败
    )

) else if "%COMMAND%"=="kernel" (
    echo 🔧 仅构建内核...
    %MAKE_CMD% all
    if errorlevel 1 (
        echo ❌ 内核构建失败
    ) else (
        echo ✅ 内核构建完成
        echo 💡 内核文件: kernel/kernel
    )

) else if "%COMMAND%"=="check" (
    echo 🔍 检查开发环境...

    :: 检查 make
    where make >nul 2>&1
    if not errorlevel 1 (
        echo ✅ make: %~$PATH:make%
    ) else (
        where mingw32-make >nul 2>&1
        if not errorlevel 1 (
            echo ✅ mingw32-make: %~$PATH:mingw32-make%
        ) else (
            echo ❌ make/mingw32-make: 未找到
        )
    )

    :: 检查 RISC-V 工具链
    where riscv-none-embed-gcc >nul 2>&1
    if not errorlevel 1 (
        echo ✅ riscv-none-embed-gcc: 找到
    ) else (
        where riscv64-linux-gnu-gcc >nul 2>&1
        if not errorlevel 1 (
            echo ✅ riscv64-linux-gnu-gcc: 找到
        ) else (
            echo ❌ RISC-V 工具链: 未找到
        )
    )

    :: 检查 QEMU
    where qemu-system-riscv64 >nul 2>&1
    if not errorlevel 1 (
        echo ✅ qemu-system-riscv64: 找到
    ) else (
        where "qemu-system-riscv64.exe" >nul 2>&1
        if not errorlevel 1 (
            echo ✅ qemu-system-riscv64.exe: 找到
        ) else (
            echo ❌ QEMU: 未找到
        )
    )

    :: 检查 Git
    where git >nul 2>&1
    if not errorlevel 1 (
        echo ✅ git: 找到
    ) else (
        echo ❌ Git: 未找到
    )

) else if "%COMMAND%"=="help" goto :show_help
else if "%COMMAND%"=="-h" goto :show_help
else if "%COMMAND%"=="--help" goto :show_help
else (
    echo ❌ 未知命令: %COMMAND%
    goto :show_help
)

goto :end

:show_help
echo 使用方法: %~nx0 [命令]
echo.
echo 可用命令:
echo   clean   - 清理构建文件
echo   run     - 构建并运行 (默认)
echo   gdb     - 启用调试模式
echo   test    - 运行用户测试
echo   kernel  - 仅构建内核
echo   check   - 检查开发环境
echo   help    - 显示此帮助信息
echo.
echo 示例:
echo   %~nx0            # 构建并运行
echo   %~nx0 gdb        # 启动调试
echo   %~nx0 clean      # 清理文件

:end
echo.
if "%COMMAND%" NEQ "help" if "%COMMAND%" NEQ "-h" if "%COMMAND%" NEQ "--help" (
    pause
)
@echo off
setlocal enabledelayedexpansion

:: 同步上游仓库脚本 (Windows版本)
:: 使用方法: scripts\windows-sync-upstream.bat

echo 🔄 开始同步上游仓库...

:: 检查 Git 是否可用
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到 Git，请先安装 Git for Windows
    pause
    exit /b 1
)

:: 检查是否有未提交的更改
for /f "delims=" %%i in ('git status --porcelain') do (
    if not "%%i"=="" (
        echo ⚠️  检测到未提交的更改，请先提交或暂存
        pause
        exit /b 1
    )
)

:: 获取当前分支
for /f "delims=" %%i in ('git branch --show-current') do set "CURRENT_BRANCH=%%i"
echo 📍 当前分支: !CURRENT_BRANCH!

:: 切换到主分支
echo 📂 切换到主分支...
git checkout riscv
if errorlevel 1 (
    echo ❌ 无法切换到 riscv 分支
    pause
    exit /b 1
)

:: 获取上游更新
echo ⬇️  获取上游仓库更新...
git fetch upstream
if errorlevel 1 (
    echo ❌ 获取上游更新失败
    pause
    exit /b 1
)

:: 合并上游更新
echo 🔀 合并上游更新...
git merge upstream/riscv
if errorlevel 1 (
    echo ❌ 合并冲突，请手动解决
    pause
    exit /b 1
)

:: 推送到你的 fork
echo ⬆️  推送更新到你的 fork...
git push origin riscv
if errorlevel 1 (
    echo ⚠️  推送失败，请检查网络连接或权限
)

:: 切换回原分支
if not "!CURRENT_BRANCH!"=="riscv" (
    echo 📂 切换回原分支: !CURRENT_BRANCH!
    git checkout "!CURRENT_BRANCH!"
)

echo ✅ 同步完成！
echo.
echo 💡 下一步:
echo    1. 创建功能分支: git checkout -b feature/your-feature
echo    2. 开始开发...
echo.
pause
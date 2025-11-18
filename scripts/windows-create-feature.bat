@echo off
setlocal enabledelayedexpansion

:: 创建功能分支脚本 (Windows版本)
:: 使用方法: scripts\windows-create-feature.bat <feature-name>

if "%1"=="" (
    echo ❌ 请提供功能名称
    echo 使用方法: %~nx0 ^<feature-name^>
    echo 示例: %~nx0 my-syscall
    pause
    exit /b 1
)

set "FEATURE_NAME=%1"
set "BRANCH_NAME=feature/%FEATURE_NAME%"

echo 🚀 创建功能分支: %BRANCH_NAME%

:: 检查 Git 是否可用
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到 Git，请先安装 Git for Windows
    pause
    exit /b 1
)

:: 检查分支名是否合法
echo %FEATURE_NAME% | findstr /R "[^a-zA-Z0-9_-]" >nul
if not errorlevel 1 (
    echo ❌ 错误: 分支名只能包含字母、数字、连字符和下划线
    pause
    exit /b 1
)

:: 检查是否有未提交的更改
for /f "delims=" %%i in ('git status --porcelain') do (
    if not "%%i"=="" (
        echo ⚠️  检测到未提交的更改，请先提交或暂存
        echo 💡 运行 'git add .' 和 'git commit -m "你的提交信息"'
        pause
        exit /b 1
    )
)

:: 获取当前分支
for /f "delims=" %%i in ('git branch --show-current') do set "CURRENT_BRANCH=%%i"
echo 📍 当前分支: %CURRENT_BRANCH%

:: 检查是否已经存在该分支
git rev-parse --verify "%BRANCH_NAME%" >nul 2>&1
if not errorlevel 1 (
    echo ⚠️  分支 '%BRANCH_NAME%' 已存在
    echo 💡 要切换到现有分支，运行: git checkout %BRANCH_NAME%
    pause
    exit /b 1
)

:: 确保在主分支上
if not "%CURRENT_BRANCH%"=="riscv" (
    echo 📂 切换到主分支...
    git checkout riscv
    if errorlevel 1 (
        echo ❌ 无法切换到 riscv 分支
        pause
        exit /b 1
    )
)

:: 同步上游
echo 🔄 同步上游仓库...
git fetch upstream
if errorlevel 1 (
    echo ⚠️  获取上游更新失败，继续使用本地代码
) else (
    git merge upstream/riscv
    if errorlevel 1 (
        echo ⚠️  合并上游更新失败，请手动解决
    )
)

:: 创建并切换到新分支
echo 🌱 创建功能分支...
git checkout -b "%BRANCH_NAME%"
if errorlevel 1 (
    echo ❌ 无法创建分支 '%BRANCH_NAME%'
    pause
    exit /b 1
)

:: 推送新分支
echo ⬆️  推送新分支到远程...
git push -u origin "%BRANCH_NAME%"
if errorlevel 1 (
    echo ⚠️  推送分支失败，请检查网络连接或权限
    echo 💡 稍后可以手动推送: git push -u origin %BRANCH_NAME%
)

echo.
echo ✅ 功能分支创建成功: %BRANCH_NAME%
echo.
echo 💡 下一步:
echo    1. 开始开发你的功能
echo    2. 添加文件: git add .
echo    3. 提交更改: git commit -m "feat: 描述你的功能"
echo    4. 推送更新: git push
echo    5. 创建 Pull Request (GitHub 上)
echo.
echo 📖 提交信息格式建议:
echo    feat: 新功能
echo    fix: 修复问题
echo    docs: 文档更新
echo    style: 代码格式
echo    refactor: 代码重构
echo    test: 测试相关
echo.
pause
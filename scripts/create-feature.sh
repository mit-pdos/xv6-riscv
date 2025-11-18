#!/bin/bash

# 创建功能分支脚本
# 使用方法: ./scripts/create-feature.sh <feature-name>

if [ -z "$1" ]; then
    echo "❌ 请提供功能名称"
    echo "使用方法: ./scripts/create-feature.sh <feature-name>"
    exit 1
fi

FEATURE_NAME=$1
BRANCH_NAME="feature/$FEATURE_NAME"

echo "🚀 创建功能分支: $BRANCH_NAME"

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  检测到未提交的更改，请先提交或暂存"
    exit 1
fi

# 确保在主分支上
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "riscv" ]; then
    echo "📂 切换到主分支..."
    git checkout riscv
fi

# 同步上游
echo "🔄 同步上游仓库..."
git fetch upstream
git merge upstream/riscv

# 创建并切换到新分支
echo "🌱 创建功能分支..."
git checkout -b "$BRANCH_NAME"

# 推送新分支
echo "⬆️  推送新分支到远程..."
git push -u origin "$BRANCH_NAME"

echo "✅ 功能分支创建成功: $BRANCH_NAME"
echo "💡 现在可以开始开发你的功能了！"
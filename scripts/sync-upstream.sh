#!/bin/bash

# 同步上游仓库脚本
# 使用方法: ./scripts/sync-upstream.sh

echo "🔄 开始同步上游仓库..."

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  检测到未提交的更改，请先提交或暂存"
    exit 1
fi

# 获取当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 当前分支: $CURRENT_BRANCH"

# 切换到主分支
echo "📂 切换到主分支..."
git checkout riscv

# 获取上游更新
echo "⬇️  获取上游仓库更新..."
git fetch upstream

# 合并上游更新
echo "🔀 合并上游更新..."
if git merge upstream/riscv; then
    echo "✅ 成功合并上游更新"
else
    echo "❌ 合并冲突，请手动解决"
    exit 1
fi

# 推送到你的 fork
echo "⬆️  推送更新到你的 fork..."
git push origin riscv

# 切换回原分支
if [ "$CURRENT_BRANCH" != "riscv" ]; then
    echo "📂 切换回原分支: $CURRENT_BRANCH"
    git checkout "$CURRENT_BRANCH"
fi

echo "🎉 同步完成！"
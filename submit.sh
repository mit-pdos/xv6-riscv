#!/bin/bash

# =======================================
# xv6-riscv Submission Script
# =======================================

# 1. Check that we are in the xv6-riscv main directory
if [ ! -f "Makefile" ] || [ ! -d "kernel" ] || [ ! -d "user" ]; then
    echo "Error: This does not appear to be the xv6-riscv main directory."
    echo "Please run this script from the root of your xv6-riscv repository."
    exit 1
fi

# Check Git repository
if [ ! -d ".git" ]; then
    echo "Error: This directory is not a Git repository."
    exit 1
fi

echo "xv6-riscv repository detected."
echo

# 2. Ask for roll number
read -p "Enter your roll number: " ROLLNO

if [ -z "$ROLLNO" ]; then
    echo "Error: Roll number cannot be empty."
    exit 1
fi

# 3. Create submission folder
SUBMISSION_DIR="${ROLLNO}_submission"
ARCHIVE="${SUBMISSION_DIR}.tar.gz"

if [ -e "$SUBMISSION_DIR" ] || [ -e "$ARCHIVE" ]; then
    echo "Error: Submission already exists:"
    echo "  $SUBMISSION_DIR or $ARCHIVE"
    echo
    echo "Remove the previous submission before submitting again."
    exit 1
fi

mkdir "$SUBMISSION_DIR"

# ---------------------------------------
# 4. Record the base commit
# ---------------------------------------

BASE=$(git rev-parse HEAD)

echo "$BASE" > "$SUBMISSION_DIR/base"

echo
echo "Base commit:"
echo "  $BASE"
echo

# ---------------------------------------
# 5. Find new files in kernel/ and user/
# ---------------------------------------

NEW_FILES=$(git status --porcelain --untracked-files=all | \
    awk '$1 == "??" && ($2 ~ /^kernel\// || $2 ~ /^user\//) {print substr($0,4)}')

if [ -n "$NEW_FILES" ]; then
    echo "New files detected:"
    echo "$NEW_FILES"
    echo

    # Tell Git to include new files in the diff
    # without actually staging their contents.
    echo "$NEW_FILES" | while IFS= read -r file; do
        git add -N -- "$file"
    done
fi

# ---------------------------------------
# 6. Generate patch
# ---------------------------------------

git diff HEAD > "$SUBMISSION_DIR/xv6.patch"

# ---------------------------------------
# 7. Restore Git working state
# ---------------------------------------

if [ -n "$NEW_FILES" ]; then
    echo "$NEW_FILES" | while IFS= read -r file; do
        git reset -- "$file" > /dev/null
    done
fi

# ---------------------------------------
# 8. Show patch summary
# ---------------------------------------

echo
echo "Patch summary:"
git --no-pager apply --stat "$SUBMISSION_DIR/xv6.patch"

# ---------------------------------------
# 9. Create tar.gz archive
# ---------------------------------------

echo
echo "Creating submission archive..."

if ! tar -czf "$ARCHIVE" "$SUBMISSION_DIR"; then
    echo "Error: Failed to create submission archive."

    # Remove temporary submission folder
    rm -rf "$SUBMISSION_DIR"

    exit 1
fi

# ---------------------------------------
# 10. Remove temporary submission folder
# ---------------------------------------

rm -rf "$SUBMISSION_DIR"

# ---------------------------------------
# 11. Final message
# ---------------------------------------

echo
echo "======================================"
echo "Submission created successfully!"
echo "======================================"
echo
echo "Submit this file:"
echo "  $ARCHIVE"
echo
echo "Archive contents:"
tar -tzf "$ARCHIVE"
echo
echo "Archive size:"
ls -lh "$ARCHIVE"
echo
echo "IMPORTANT: Do not modify the archive after this."

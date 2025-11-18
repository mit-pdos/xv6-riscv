# xv6-riscv 项目工作流指南

本项目是 MIT 官方 xv6-riscv 仓库的一个 fork，用于学习和操作系统开发。

## 📋 仓库配置

### 当前远程仓库配置
- **origin**: `https://github.com/Desperado1001/xv6-riscv.git` (你的 fork)
- **upstream**: `https://github.com/mit-pdos/xv6-riscv.git` (官方仓库)

### 分支说明
- `riscv`: 主分支，跟踪官方仓库的最新代码
- `my-feature`: 你的功能开发分支

## 🚀 日常工作流程

### 1. 同步上游仓库最新代码

```bash
# 1. 获取上游仓库最新更新
git fetch upstream

# 2. 切换到主分支
git checkout riscv

# 3. 合并上游更新到本地主分支
git merge upstream/riscv

# 4. 推送更新到你的 fork
git push origin riscv
```

### 2. 创建功能开发分支

```bash
# 1. 基于最新的主分支创建功能分支
git checkout -b feature/your-feature-name

# 2. 开发完成后提交
git add .
git commit -m "feat: 添加你的功能描述"

# 3. 推送功能分支到你的 fork
git push origin feature/your-feature-name
```

### 3. 定期同步主分支到功能分支

```bash
# 1. 切换到功能分支
git checkout feature/your-feature-name

# 2. 获取上游更新
git fetch upstream

# 3. 变基合并上游更新（避免合并提交）
git rebase upstream/riscv

# 4. 强制推送（因为 rebase 会重写历史）
git push origin feature/your-feature-name --force-with-lease
```

## 🔄 Git 工作流最佳实践

### 提交信息规范
使用约定式提交格式：

```bash
# 功能添加
git commit -m "feat: 添加新的系统调用"

# 问题修复
git commit -m "fix: 修复内存泄漏问题"

# 文档更新
git commit -m "docs: 更新 README 说明"

# 代码重构
git commit -m "refactor: 重构进程调度逻辑"

# 性能优化
git commit -m "perf: 优化文件系统性能"
```

### 分支命名规范
- `feature/功能名称` - 新功能开发
- `fix/问题描述` - 问题修复
- `docs/文档类型` - 文档更新
- `study/学习主题` - 学习和实验

### 工作流程图
```
upstream/riscv (官方仓库)
    ↑
    | git fetch upstream
    ↓
local/riscv (本地主分支)
    ↑
    | git checkout -b feature/xxx
    ↓
local/feature/xxx (开发分支)
    ↑
    | git push origin feature/xxx
    ↓
origin/feature/xxx (你的 fork)
```

## 🎓 xv6 项目学习指南

### 1. 代码阅读顺序

#### 核心启动流程
```
kernel/entry.S     -> 内核入口点
kernel/start.c     -> 启动初始化
kernel/main.c      -> 主函数
kernel/proc.c      -> 进程管理
kernel/vm.c        -> 虚拟内存
kernel/trap.c      -> 中断处理
```

#### 系统调用机制
```
user/usys.pl       -> 系统调用号定义
kernel/syscall.c   -> 系统调用分发
kernel/sysproc.c   -> 进程相关系统调用
kernel/sysfile.c   -> 文件相关系统调用
user/ulib.c        -> 用户空间系统调用包装
```

#### 文件系统
```
kernel/fs.c        -> 文件系统核心
kernel/bio.c       -> 块I/O缓冲
kernel/file.c      -> 文件描述符
mkfs/mkfs.c        -> 文件系统创建工具
```

### 2. 学习建议

#### 渐进式学习路径
1. **基础概念**: 阅读 README 和 `kernel/proc.h` 理解基本结构
2. **启动流程**: 跟踪从 `entry.S` 到 `main.c` 的启动过程
3. **系统调用**: 理解用户程序如何通过系统调用进入内核
4. **内存管理**: 学习页表和内存分配机制
5. **进程调度**: 理解进程创建、切换和调度
6. **文件系统**: 掌握 VFS 层和设备驱动

#### 实验建议
```bash
# 编译运行
make qemu

# 运行测试
make qemu-usertests

# 调试内核
make qemu-gdb
# 在另一个终端:
gdb-multiarch kernel/kernel
(gdb) target remote localhost:26000
```

#### 代码修改实验
1. 添加新的系统调用
2. 修改调度算法
3. 实现新的内存分配策略
4. 添加简单的文件系统功能

### 3. 有用的调试技巧

#### 内核调试
```bash
# 添加调试输出
printf("debug: pid=%d, sp=%p\n", myproc()->pid, myproc()->context.sp);

# 使用 panic 停止执行
if (condition) panic("发现错误");

# 查看进程状态
ps();  // 需要自己实现
```

#### GDB 调试
```gdb
# 设置断点
b kernel/proc.c:allocproc

# 查看调用栈
bt

# 查看寄存器
info registers

# 查看内存
x/10x 0x80000000
```

## 🔧 常见问题解决

### 1. 合并冲突
```bash
# 解决合并冲突
git checkout riscv
git pull upstream riscv
git checkout feature/your-branch
git rebase riscv
# 手动解决冲突后:
git add .
git rebase --continue
```

### 2. 同步问题
```bash
# 检查仓库状态
git status
git remote -v

# 重置到远程状态
git fetch origin
git reset --hard origin/riscv
```

### 3. 构建问题
```bash
# 清理构建文件
make clean

# 检查工具链
riscv64-unknown-elf-gcc --version
qemu-system-riscv64 --version
```

## 📚 参考资源

### 官方文档
- [xv6 Book](https://pdos.csail.mit.edu/6.S081/2020/xv6/book/) - 完整的教科书
- [MIT 6.S1810 课程](https://pdos.csail.mit.edu/6.S081/) - 官方课程页面
- [RISC-V 文档](https://riscv.org/technical/documents/) - RISC-V 架构文档

### 学习工具
- `qemu-gdb` - 内核调试
- `objdump` - 反汇编工具
- `nm` - 符号表查看
- `strings` - 字符串提取

### 社区资源
- [GitHub Issues](https://github.com/mit-pdos/xv6-riscv/issues) - 官方问题和讨论
- [OS 知识](https://piazza.com/class) - 在线学习社区
- [Stack Overflow](https://stackoverflow.com) - 技术问题解答

## 🎯 项目目标建议

### 初级目标
- [ ] 理解 xv6 启动流程
- [ ] 添加简单的系统调用
- [ ] 修改进程调度策略
- [ ] 实现简单的内存优化

### 中级目标
- [ ] 实现新的 IPC 机制
- [ ] 添加简单的网络支持
- [ ] 优化文件系统性能
- [ ] 实现多线程支持

### 高级目标
- [ ] 移植到新的硬件平台
- [ ] 实现分布式功能
- [ ] 添加安全机制
- [ ] 性能分析和优化

---

💡 **提示**: 这个工作流文档会随着你的学习进度不断更新。记得定期同步上游仓库，保持代码最新！
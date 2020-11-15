# xv6-riscv-win

[ccckmit](https://github.com/ccckmit) fork the project form github.

* https://github.com/mit-pdos/xv6-riscv

However, the original xv6-riscv can only be compiled & run on Linux.

ccckmit port the [mkfs.c](https://github.com/mit-pdos/xv6-riscv/tree/riscv/mkfs/mkfs.c) 
into windows + git bash, and compile it successfully.

## Prerequisites For Windows

Download:

* [git-bash](https://git-scm.com/download/win)
* [FreedomStudio](https://www.sifive.com/software)

After download and extract the FreedomStudio for windows. You have to set the system PATH to the folder of `riscv64-unknown-elf-gcc/bin` and `riscv-qemu/bin`. For example, I set PATH to the following folders. 

```
D:\install\FreedomStudio-2020-06-3-win64\SiFive\riscv64-unknown-elf-gcc-8.3.0-2020.04.1\bin

D:\install\FreedomStudio-2020-06-3-win64\SiFive\riscv-qemu-4.2.0-2020.04.0\bin
```

And you should start your git-bash to build the project. (It works for me in vscode bash terminal)

## Prerequisites For Linux

Just follow the guide of xv6-riscv

* https://github.com/mit-pdos/xv6-riscv/


## Build & Run on Windows 

```
$ cd src

$ make clean

$ make qemu
...
qemu-system-riscv64 -machine virt -bios none -kernel kernel/kernel -m 256M -smp 3 -nographic -drive file=fs.img,if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

xv6 kernel is booting

hart 1 starting
hart 2 starting
init: starting sh
$ ls
.              1 1 1024
..             1 1 1024
README         2 2 2025
cat            2 3 22416
echo           2 4 21264
forktest       2 5 11592
grep           2 6 25736
init           2 7 22016
kill           2 8 21248
ln             2 9 21208
ls             2 10 24648
mkdir          2 11 21344
rm             2 12 21320
sh             2 13 40280
stressfs       2 14 22272
usertests      2 15 119696
wc             2 16 23520
zombie         2 17 20768
console        3 18 0

$ wc README
43 286 2025 README
```

## License

The project was forked from the following github project.

* https://github.com/mit-pdos/xv6-riscv 

You should follow the license if you use it.

* https://github.com/mit-pdos/xv6-riscv/blob/riscv/LICENSE


## Original xv6-riscv README

xv6 is a re-implementation of Dennis Ritchie's and Ken Thompson's Unix
Version 6 (v6).  xv6 loosely follows the structure and style of v6,
but is implemented for a modern RISC-V multiprocessor using ANSI C.

ACKNOWLEDGMENTS

xv6 is inspired by John Lions's Commentary on UNIX 6th Edition (Peer
to Peer Communications; ISBN: 1-57398-013-7; 1st edition (June 14,
2000)). See also https://pdos.csail.mit.edu/6.828/, which
provides pointers to on-line resources for v6.

The following people have made contributions: Russ Cox (context switching,
locking), Cliff Frey (MP), Xiao Yu (MP), Nickolai Zeldovich, and Austin
Clements.

We are also grateful for the bug reports and patches contributed by
Silas Boyd-Wickizer, Anton Burtsev, Dan Cross, Cody Cutler, Mike CAT,
Tej Chajed, eyalz800, Nelson Elhage, Saar Ettinger, Alice Ferrazzi,
Nathaniel Filardo, Peter Froehlich, Yakir Goaron,Shivam Handa, Bryan
Henry, Jim Huang, Alexander Kapshuk, Anders Kaseorg, kehao95, Wolfgang
Keller, Eddie Kohler, Austin Liew, Imbar Marinescu, Yandong Mao, Matan
Shabtay, Hitoshi Mitake, Carmi Merimovich, Mark Morrissey, mtasm, Joel
Nider, Greg Price, Ayan Shafqat, Eldar Sehayek, Yongming Shen, Cam
Tenny, tyfkda, Rafael Ubal, Warren Toomey, Stephen Tu, Pablo Ventura,
Xi Wang, Keiichi Watanabe, Nicolas Wolovick, wxdao, Grant Wu, Jindong
Zhang, Icenowy Zheng, and Zou Chang Wei.

The code in the files that constitute xv6 is
Copyright 2006-2019 Frans Kaashoek, Robert Morris, and Russ Cox.

ERROR REPORTS

Please send errors and suggestions to Frans Kaashoek and Robert Morris
(kaashoek,rtm@mit.edu). The main purpose of xv6 is as a teaching
operating system for MIT's 6.828, so we are more interested in
simplifications and clarifications than new features.

BUILDING AND RUNNING XV6

You will need a RISC-V "newlib" tool chain from
https://github.com/riscv/riscv-gnu-toolchain, and qemu compiled for
riscv64-softmmu. Once they are installed, and in your shell
search path, you can run "make qemu".

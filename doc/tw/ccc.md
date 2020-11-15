# ccc 修改過的 xv6

只有改 mkfs/mkfs.c

將原本的 UNIX open,close,read,write,lseek 改為標準的 fopen,fclose,fread,fwrite,fseek ，然後就可以在 windows 底下的 bash 環境建置 xv6 了。 

```
user@DESKTOP-96FRN6B MINGW64 /d/ccc/ccc109/sp/11-os/xv6/riscv/srcwin (master)
$ make qemu
gcc -Werror -Wall -I. -o mkfs/mkfs mkfs/mkfs.c
mkfs/mkfs fs.img README user/_cat user/_echo user/_forktest user/_grep user/_init user/_kill user/_ln 
user/_ls user/_mkdir user/_rm user/_sh user/_stressfs user/_usertests user/_wc user/_zombie 
nmeta 46 (boot, super, log blocks 30 inode blocks 13, bitmap blocks 1) blocks 954 total 1000
balloc: first 498 blocks have been allocated
balloc: write bitmap block at sector 45
qemu-system-riscv64 -machine virt -bios none -kernel kernel/kernel -m 256M -smp 3 -nographic -drive file=fs.img,if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

xv6 kernel is booting

hart 1 starting
hart 2 starting
init: starting sh
$ ls
.              1 1 1024
..             1 1 1024
README         2 2 2025
cat            2 3 22432
echo           2 4 21280
forktest       2 5 11592
grep           2 6 25752
init           2 7 22032
kill           2 8 21264
ln             2 9 21224
ls             2 10 24664
mkdir          2 11 21368
rm             2 12 21344
sh             2 13 40304
stressfs       2 14 22288
usertests      2 15 119712
wc             2 16 23536
zombie         2 17 20784
console        3 18 0
$ wc README
43 286 2025 README
$ grep "xv6" README
$ grep xv6 README
xv6 is a re-implementation of Dennis Ritchie's and Ken Thompson's Unix
Version 6 (v6).  xv6 loosely follows the structure and style of v6,
xv6 is inspired by John Lions's Commentary on UNIX 6th Edition (Peer
The code in the files that constitute xv6 is
(kaashoek,rtm@mit.edu). The main purpose of xv6 is as a teaching
```

# xv6-riscv Project Setup Guide
 
**Repository:** [https://github.com/YellowAli/xv6-riscv](https://github.com/YellowAli/xv6-riscv)
 
---
 
## Table of Contents
- [Installing on Windows](#installing-on-windows)
- [Installing on Mac — Apple Silicon (M1/M2)](#installing-on-mac--apple-silicon-m1m2----try-this-first)
- [Installing on Mac — Alternative Method](#installing-on-mac--alternative-method-intel-or-if-above-fails)
- [Running User Programs](#running-user-programs-on-xv6)
- [Adding Additional Files into the OS Build](#adding-additional-files-into-the-os-build)
 
---
 
## Installing on Windows
 
Students running Windows are encouraged to either install Linux on their local machine or use **WSL 2** (Windows Subsystem for Linux 2).
 
Students are also encouraged to install the **Windows Terminal** tool instead of using PowerShell or Command Prompt.
 
### Setting up WSL 2
 
To use WSL 2, first ensure that Windows Subsystem for Linux is installed. Then install **Ubuntu 24.04** from the Microsoft Store. After installation, you should be able to launch Ubuntu and interact with the machine.
 
> **IMPORTANT:** Make sure that you are running version 2 of WSL. WSL 1 does not work with the labs. To check your WSL version, run the following command in a Windows terminal:
> ```
> wsl -l -v
> ```
> This confirms that WSL 2 and the correct Ubuntu version are installed.
 
### Installing Required Software (run inside Ubuntu / WSL)
 
```bash
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install git build-essential gdb-multiarch qemu-system-misc \
  gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu
```
 
### Testing your Installation
 
Verify QEMU is installed:
```bash
$ qemu-system-riscv64 --version
QEMU emulator version 7.2.0
```
 
And at least one RISC-V version of GCC:
```bash
$ riscv64-linux-gnu-gcc --version
riscv64-linux-gnu-gcc (Debian 10.3.0-8) 10.3.0
...
 
$ riscv64-unknown-elf-gcc --version
riscv64-unknown-elf-gcc (GCC) 10.1.0
...
```
 
### Clone and Run xv6
 
```bash
git clone https://github.com/YellowAli/xv6-riscv
cd xv6-riscv
make qemu
```
 
You should see xv6 boot and drop into a shell if everything is set up correctly.
 
---
 
## Installing on Mac — Apple Silicon (M1/M2) — Try This First
 
This is the recommended and simpler installation path for Apple Silicon Macs. Try these steps before falling back to the alternative method below.
 
### Step 1 — Install Homebrew (if not installed yet)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
 
### Step 2 — Install RISC-V Tools
> This builds the toolchain from source — be patient, it may take several minutes.
```bash
brew tap riscv-software-src/riscv
brew install riscv-tools
```
 
### Step 3 — Install QEMU
```bash
brew install qemu
```
 
### Step 4 — Clone the Repository
```bash
git clone https://github.com/YellowAli/xv6-riscv.git
```
 
### Step 5 — Build and Run xv6
```bash
cd xv6-riscv
make
make qemu
```
 
> To exit QEMU: press `Ctrl+A` simultaneously, release both keys, then press `X`.
 
---
 
## Installing on Mac — Alternative Method (Intel or if above fails)
 
Use this method if the Apple Silicon steps above did not work, or if you are on an Intel Mac.
 
### Step 1 — Install Homebrew (if not installed yet)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
 
### Step 2 — Install QEMU
```bash
brew install qemu
```
 
### Step 3 — Install dependencies
```bash
brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat texinfo flock libslirp
```
 
### Step 4 — Install RISC-V tools
```bash
brew tap riscv/riscv
brew install riscv-tools
```
 
### Step 5 — Clone the repository
```bash
git clone https://github.com/YellowAli/xv6-riscv.git
```
 
### Step 6 — Navigate into the repo
```bash
cd xv6-riscv
```
 
### Step 7 — Add RISC-V tools to your PATH
```bash
export PATH="/usr/local/opt/riscv-tools/bin:$PATH"
```
 
### Step 8 — Reload your shell config
```bash
source ~/.zshrc
```
 
### Step 9 — Downgrade gcc for xv6 compatibility
 
xv6 requires an older gcc toolchain. Run these commands in order:
 
```bash
brew unlink i386-elf-binutils
brew unlink gcc
brew link --overwrite riscv-gnu-toolchain
brew link --overwrite riscv-gnu-toolchain --dry-run
riscv64-unknown-elf-gcc --version
```
 
> **Note:** Once gcc is downgraded, your code may not run in standard editors. After successfully booting xv6 you can restore it with:
> ```bash
> brew install gcc
> ```
 
### Step 10 — Clean, build, and run
```bash
make clean
make
make qemu
```
 
> To exit QEMU: press `Ctrl+A` simultaneously, release both keys, then press `X`.
 
---
 
## Running User Programs on xv6
 
### Step 1 — Create your source file
 
Create a new C source file inside the `user/` directory of xv6. For example:
```
user/hello_world.c
```
 
### Step 2 — Write your program
 
Write your program using your favourite editor (e.g. VSCode). Important constraints:
- Only include xv6 headers: `kernel/types.h` and `user/user.h`
- Standard C libraries (`stdio.h`, `stdlib.h`, etc.) are **not available**
- You can use xv6 syscalls: `printf`, `exit`, `fork`, etc.
 
### Step 3 — Register your program in the Makefile
 
Edit the xv6 `Makefile` and add your program name (prefixed with `$U/_`) to the `UPROGS` list:
 
```makefile
UPROGS=\
    $U/_cat\
    $U/_echo\
    ...
    $U/_hello_world\
```
 
This tells the Makefile to compile and include your program in the OS image.
 
### Step 4 — Rebuild and run
 
```bash
make clean
make qemu
```
 
### Step 5 — Run your program
 
Once xv6 boots, type your program name at the shell prompt:
```
$ hello_world
```
 
You can verify your program is available by running `ls` before executing it.
 
---
 
## Adding Additional Files into the OS Build
 
Sometimes your program needs to read a file that is not present in xv6 by default (e.g. a `.txt` input file). You can include extra files in the OS image by modifying the Makefile.
 
Add the following line to include all `.txt` files from the `user/` folder:
 
```makefile
TXTFILES=$(wildcard $U/*.txt)
```
 
Then update the `fs.img` target to include those files:
 
```makefile
fs.img: mkfs/mkfs README $(UPROGS) $(TXTFILES)
    mkfs/mkfs fs.img README $(UPROGS) $(TXTFILES)
```
 
After making this change, run `make clean && make qemu` to rebuild the image with your files included.

# Сборка

Устанавливаем Docker с RISC-V утилитами и запускаем сборку:
```bash
docker run --rm -v $(pwd):/project -w /project -it ghcr.io/francisrstokes/rv-toolchain-docker:main make
```

Устанавливаем дополнительные утилиты (для дебага через gdb):
```bash
sudo apt install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf
```
Далее скачиваем пакет утилит под RISC-V. 
Там где возникает ошибка, то скорее всего не хватает каких-то пакетов, догружаем их отдельно.
Список зависимостей прописан в самом репозитории - https://github.com/riscv-collab/riscv-gnu-toolchain
```bash
cd /tmp
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
cd riscv-gnu-toolchain/
./configure --prefix=/opt/riscv
sudo make
```

Запускаем OS в `qemu`:
```bash
make qemu
```

Запускаем OS в режиме дебага:
```bash
make qemu-debug
```

Выходим из `qemu`:
* `Ctrl + a`
* `x`
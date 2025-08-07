# Сборка

Устанавливаем Docker с RISC-V утилитами и переходим в консоль:
```bash
docker compose up -d
docker compose exec -it os /bin/sh
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
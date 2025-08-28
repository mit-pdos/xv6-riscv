# Tarea 0

## Claudio Díaz

## Sistemas Operativos Sec. 2

---

## 1. Objetivo

Instalar y ejecutar xv6-riscv en un entorno Windows mediante WSL, asegurando que funcione correctamente en QEMU y documentar el proceso en GitHub.

## 2. Sistema utilizado

- Windows 10/11
- WSL 2 con Ubuntu 22.04 LTS
- xv6-riscv (última versión del repositorio oficial)
- QEMU 8.x compilado desde fuente
- riscv64-unknown-elf-gcc (toolchain RISC-V)

## 3. Pasos seguidos para la instalación

### 3.1 Instalación de WSL y Ubuntu

1. Ejecutar en PowerShell:

```powershell
wsl --install -d Ubuntu-22.04
```

2. Abrir Ubuntu y actualizar paquetes:

```bash
sudo apt update && sudo apt upgrade -y
```

### 3.2 Instalación de herramientas necesarias

```bash
sudo apt install git build-essential gcc make curl vim python3 python3-pip python3-venv -y
```

### 3.3 Clonar repositorio xv6-riscv

```bash
cd ~
git clone https://github.com/mit-pdos/xv6-riscv.git
cd xv6-riscv
```

### 3.4 Instalación de toolchain RISC-V

```bash
sudo apt install gcc-riscv64-linux-gnu g++-riscv64-linux-gnu -y
```

> Nota: Se resolvió el error de `riscv64-unknown-elf-gcc` asegurando que la herramienta correcta estaba instalada.

### 3.5 Compilación de xv6

```bash
make clean
make
```

> La compilación finalizó correctamente sin errores.

### 3.6 Instalación de QEMU >=7.2

1. El repositorio oficial de Ubuntu tenía QEMU antiguo, se compiló desde fuente:

```bash
sudo apt remove --purge qemu qemu-system-misc -y
sudo apt install -y git build-essential ninja-build pkg-config libglib2.0-dev libpixman-1-dev libssl-dev python3-venv
cd ~
git clone https://gitlab.com/qemu-project/qemu.git
cd qemu
git checkout stable-8.2
mkdir build && cd build
../configure --target-list=riscv64-softmmu --disable-werror
make -j$(nproc)
sudo make install
```

2. Verificación:

```bash
qemu-system-riscv64 --version
```

> Resultado: QEMU 8.x, satisfaciendo el requisito mínimo.

### 3.7 Ejecución de xv6 en QEMU

```bash
cd ~/xv6-riscv
make qemu
```

> xv6 arrancó correctamente mostrando el shell:

```
hart 2 starting
hart 1 starting
init: starting sh
$
```

### 3.8 Pruebas de comandos básicos

Dentro de xv6 se ejecutaron:

```bash
ls
echo "Hola xv6"
cat README
```

> Todos los comandos funcionaron correctamente.

## 4. Problemas encontrados y soluciones

1. \*\*Error \*\*\`\`
   - Solución: Instalación de `gcc-riscv64-linux-gnu` y toolchain RISC-V.
2. **Error ****\`\`**** al compilar QEMU**
   - Solución: Instalación de `python3-venv` y `python3-pip`.
3. \*\*Error \*\*\`\`
   - Solución: Compilar QEMU 8.x desde la fuente.

## 5. Confirmación de que xv6 funciona

- xv6 arranca en QEMU correctamente.
- Los comandos básicos (`ls`, `echo`, `cat`) funcionan.
- Captura de pantalla realizada y guardada para entrega.

## 6. Repositorio GitHub

- Fork del repositorio oficial: `https://github.com/cldiaz21/xv6-riscv`
- Rama creada: `grupo_t0`
- Commit con informe y cambios realizados.


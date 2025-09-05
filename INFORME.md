# Informe de Instalación de xv6

## Pasos Seguidos para Instalar xv6

### 1. Clonar el Repositorio
- El repositorio xv6-riscv ya estaba clonado en: `c:\Users\vduke\OneDrive\Documentos\GitHub\xv6-riscv`
- Rama actual: Valentin_Duke

### 2. Crear una Nueva Rama
- Ya se encuentra en la rama personal: `Valentin_Duke`

### 3. Instalar Dependencias
- **Sistema Operativo**: Windows 10/11 con WSL (Ubuntu)
- **Dependencias instaladas**:
  - WSL con Ubuntu
  - build-essential (make, gcc, etc.)
  - qemu-system-riscv64
  - gcc-riscv64-unknown-elf (toolchain RISC-V)
- **Comando usado**: `apt install -y build-essential qemu-system-riscv64 gcc-riscv64-unknown-elf`

### 4. Compilar xv6
- Ejecutado: `make` en WSL
- Compilación exitosa del kernel y programas de usuario
- Archivos generados: `kernel/kernel`, `fs.img`, etc.

### 5. Ejecutar xv6
- Comando: `make qemu`
- xv6 se ejecuta correctamente en QEMU
- Salida muestra: kernel booting, harts starting, shell iniciado

### 6. Verificar la Instalación
- xv6 está ejecutándose con el prompt `$`
- Comandos probados:
  - `ls` - Lista archivos del directorio raíz
  - `echo "Hola xv6"` - Imprime el mensaje
  - `cat README` - Muestra contenido del README

## Problemas Encontrados y Soluciones

1. **Make no disponible en Windows**: Solución - Usar WSL con Ubuntu
2. **Dependencias faltantes**: Instaladas vía apt en WSL
3. **Toolchain RISC-V**: Instalado correctamente desde repositorios Ubuntu

## Confirmación de que xv6 está Funcionando Correctamente

- ✅ Kernel compila sin errores
- ✅ QEMU ejecuta xv6 correctamente
- ✅ Shell responde a comandos
- ✅ Sistema de archivos montado (fs.img)
- ✅ Programas de usuario compilados y disponibles

## Captura de Pantalla

Se tomó una captura de pantalla mostrando xv6 ejecutándose con los comandos de prueba en el terminal.

## Notas Adicionales

- Todo el proceso se realizó usando WSL para compatibilidad con herramientas Unix
- La instalación fue exitosa y xv6 está listo para desarrollo y experimentación</content>
<parameter name="filePath">c:\Users\vduke\OneDrive\Documentos\GitHub\xv6-riscv\INFORME.md

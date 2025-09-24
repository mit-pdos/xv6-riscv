# INFORME — Tarea 0: Instalación y Prueba de xv6

## Pasos seguidos
- Instalé Ubuntu en WSL2 en Windows.
- Instalé las dependencias: `make`, `qemu-system-misc`, `gcc-riscv64-linux-gnu`, `git`, `build-essential`.
- Hice fork del repositorio `xv6-riscv`, lo cloné y creé mi rama `users/mati/t0`.
- Corrí `make qemu` y ejecuté los comandos `ls`, `echo hola xv6` y `cat README`.

## Problemas y soluciones
- Al principio apareció un error `gcc: No such file or directory`.  
  Lo solucioné instalando el paquete `build-essential`.

## Confirmación
Adjunto en la carpeta `CapturasT0` las imágenes que demuestran el funcionamiento de xv6 con los tres comandos solicitados.

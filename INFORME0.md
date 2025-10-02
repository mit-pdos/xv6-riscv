# INFORME – Tarea 0: Instalación y ejecución de xv6

## Pasos de instalación
1. Fork del repo mit-pdos/xv6-riscv.
2. `git clone ...` y `git checkout -b ...`
3. Dependencias instaladas
# INFORME – Tarea 0: Instalación y Ejecución de xv6

## 1. Entorno
- Sistema operativo: Windows + WSL2 Ubuntu
- QEMU: emulador RISC-V
- Compilador RISC-V: riscv64-unknown-elf-gcc
- Git y editor de texto usados

---

## 2. Pasos de instalación

1. Se hizo un fork del repositorio oficial de xv6-riscv.  
2. Se clonó el fork en la máquina local y se creó una rama para la tarea.  
3. Se instalaron las dependencias necesarias para compilar y ejecutar xv6.  
4. Se compiló xv6 usando `make`.  
5. Se ejecutó xv6 en QEMU para verificar su funcionamiento.

---

## 3. Verificación

Se probaron los siguientes comandos dentro de xv6:

- `ls` → lista de archivos del sistema.  
- `echo "Hola xv6"` → imprime el mensaje en pantalla.  
- `cat README` → muestra el contenido del archivo README.

Todos los comandos funcionaron correctamente.

---

## 4. Confirmación

xv6 se ejecuta correctamente en QEMU y responde a los comandos básicos, lo que confirma que la instalación fue exitosa.

---

## 5. Captura de pantalla

![Ejecución de xv6](docs/Tarea\ 0\ doc.pdf)

---

## 6. Problemas encontrados y soluciones

- Se ajustó el entorno para poder instalar dependencias correctamente.  
- Se configuró Git para subir los archivos al repositorio remoto.

---

## 7. Conclusión


La instalación y ejecución de xv6 fue exitosa, y se verificó que los comandos básicos funcionan correctamente.

4. Compilación: `make`
5. Ejecución: `make qemu`

## Verificación (comandos y salida)
- `ls` → muestra todas las carpetas dentro del so
- `echo Hola xv6` → imprime lo mismo que escribes
- `cat README` → muestra el README

## Confirmación
xv6 ejecuta en QEMU y responde a los comandos solicitados.

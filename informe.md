# Informe de instalación XV6
Paso a paso instalación de XV6
# Ya se tenia git instalado asi que esa parte se va a omitir al igual que ubuntu
En el repositorio original se copia el link del mismo repositorio para utilizar el comando git clone (link) dentro del terminal git bash de manera que se clone el repositorio dentro de mis carpetas.
De utiliza el comando git checkout -b para crear la nueva rama solicitada
Dentro de ubuntu se coloca el espacio de trabajo dentro de la clonación del repositorio.
Posteriormente se instalan las depencias de compilación gcc, make, librerias basicas y git con el comando sudo apt install build-essential git
Despues se instalo RISC-V bare-metal ya que es escencial para compilar xv6.
Para poder ejecutar el sistema operativo se intalo el emulador QEMU, el cual permite ejecutar dentro de ubuntu el xv6
Con esto ya se esta listo para ejecutar xv6, para ello se utiliza make clean (para limpiar cualquier residuo de alguna ejecutción anterior que pudiese ocasionar un error), despues make, para ejecutar el makefile de xv6 y dejarle todo listo al emulador para que pueda ejecutar xv6 sin problema y por último se realiza make qemu para que el emulador pueda arrancar xv6 en una maquina virtual mediante la herramienta RISC-V anteriormente instalada.

# Errores y soluciones

Al ejecutar qemu este tenia cierto error en donde no llegaba a mostrar el prompt que verificaba el correcto funcionamiento de xv6, entonces nunca se llegaba a ejecutar bien el xv6. Para esto se reinstalo qemu para asegurar que fuese la ultima versión de manera que ejecute bien xv6, una vez reinstalado se ejecuto el comando script con la intención de que qemu logre ejecutarse de buena manera en la consola de manera que se pueda manipular xv6 posteriormente. Aparecio que no se tenian una de las herramientas, en concreto bc, por lo mismo se ocupo sudo apt install bc para instalar la herramienta y de esa manera que no falte nada para ejecutar xv6.

# Prueba de funcionamiento. Se muestra lo solicitado en la tarea más lo que muestra la consola en respuesta a los comandos.

xv6 kernel is booting

hart 2 starting
hart 1 starting
init: starting sh
$ ls
.              1 1 1024
..             1 1 1024
README         2 2 2473
cat            2 3 35696
echo           2 4 34584
forktest       2 5 16520
grep           2 6 39040
init           2 7 35016
kill           2 8 34576
ln             2 9 34384
ls             2 10 37608
mkdir          2 11 34648
rm             2 12 34632
sh             2 13 57096
stressfs       2 14 35360
usertests      2 15 185488
grind          2 16 50560
wc             2 17 36696
zombie         2 18 34032
logstress      2 19 36400
forphan        2 20 35328
dorphan        2 21 34808
console        3 22 0
$ echo "Hola xv6
"Hola xv6
$ cat README
xv6 is a re-implementation of Dennis Ritchie's and Ken Thompson's Unix
Version 6 (v6).  xv6 loosely follows the structure and style of v6,
but is implemented for a modern RISC-V multiprocessor using ANSI C.

ACKNOWLEDGMENTS

xv6 is inspired by John Lions's Commentary on UNIX 6th Edition (Peer
to Peer Communications; ISBN: 1-57398-013-7; 1st edition (June 14,
2000)).  See also https://pdos.csail.mit.edu/6.1810/, which provides
pointers to on-line resources for v6.

The following people have made contributions: Russ Cox (context switching,
locking), Cliff Frey (MP), Xiao Yu (MP), Nickolai Zeldovich, and Austin
Clements.

We are also grateful for the bug reports and patches contributed by
Abhinavpatel00, Takahiro Aoyagi, Marcelo Arroyo, Hirbod Behnam, Silas
Boyd-Wickizer, Anton Burtsev, carlclone, Ian Chen, clivezeng, Dan
Cross, Cody Cutler, Mike CAT, Tej Chajed, Asami Doi,Wenyang Duan,
echtwerner, eyalz800, Nelson Elhage, Saar Ettinger, Alice Ferrazzi,
Nathaniel Filardo, flespark, Peter Froehlich, Yakir Goaron, Shivam
Handa, Matt Harvey, Bryan Henry, jaichenhengjie, Jim Huang, Matúš
Jókay, John Jolly, Alexander Kapshuk, Anders Kaseorg, kehao95,
Wolfgang Keller, Jungwoo Kim, Jonathan Kimmitt, Eddie Kohler, Vadim
Kolontsov, Austin Liew, l0stman, Pavan Maddamsetti, Imbar Marinescu,
Yandong Mao, Matan Shabtay, Hitoshi Mitake, Carmi Merimovich,
mes900903, Mark Morrissey, mtasm, Joel Nider, Hayato Ohhashi,
OptimisticSide, papparapa, phosphagos, Harry Porter, Greg Price, Zheng
qhuo, Quancheng, RayAndrew, Jude Rich, segfault, Ayan Shafqat, Eldar
Sehayek, Yongming Shen, Fumiya Shigemitsu, snoire, Taojie, Cam Tenny,
tyfkda, Warren Toomey, Stephen Tu, Alissa Tung, Rafael Ubal, unicornx,
Amane Uehara, Pablo Ventura, Luc Videau, Xi Wang, WaheedHafez, Keiichi
Watanabe, Lucas Wolf, Nicolas Wolovick, wxdao, Grant Wu, x653, Andy
Zhang, Jindong Zhang, Icenowy Zheng, ZhUyU1997, and Zou Chang Wei.

ERROR REPORTS

Please send errors and suggestions to Frans Kaashoek and Robert Morris
(kaashoek,rtm@mit.edu).  The main purpose of xv6 is as a teaching
operating system for MIT's 6.1810, so we are more interested in
simplifications and clarifications than new features.

BUILDING AND RUNNING XV6

You will need a RISC-V "newlib" tool chain from
https://github.com/riscv/riscv-gnu-toolchain, and qemu compiled for
riscv64-softmmu.  Once they are installed, and in your shell
search path, you can run "make qemu".
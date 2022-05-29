#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define LIMIT 1000
#define KEY 20
#define KEY2 26
int
main(void)
{	

    int semid, i=0;

    /*checking for non process sema access*/
    int chk = semup(20);
    if(chk<0)
        printf("Testing non adquired semaphore (up): OK!\n");
    else
        printf("Testing non adquired semaphore (up): FAILED.\n");
    
    chk = semdown(20);
    if(chk<0)
        printf("Testing non adquired semaphore (down): OK!\n");
    else
        printf("Testing non adquired semaphore (down): FAILED.\n");

    /*checking for close non requested semaphore*/
    chk=semclose(8);
    if(chk<0)
        printf("Testing semclose: OK!.\n");
    else
        printf("Testing semclose: FAILED!.\n");
    
    /*checking for getting all the resources*/
    int countsem=0,it;
    chk=0;
    for(it=0 ; it<LIMIT && chk>=0; it++,countsem++){
        chk = semget(KEY,4);   
        printf("semget: %d\n",chk);
    }    
    printf("Testing get all semaphores availables (%d availables?).\n",countsem-1);
    
    /*checking for close: sem 0 was adquired*/
    chk=semclose(0);
    if(chk==0)
        printf("Testing semclose sem 0: OK!.\n");
    else
        printf("Testing semclose sem 0: FAILED!.\n");

    /*checking for close: but not twice!*/
    chk=semclose(0);
    if(chk<0)
        printf("Testing semclose sem 0 (second time): OK!.\n");
    else
        printf("Testing semclose sem 0 (second time): FAILED!.\n");

    /*cheching binary semaphore locking*/


   /*cheching n-ary semaphore*/

   semid=semget(KEY2,2); // CAMBIAMOS DE KEY A KEY2 PORQUE AL HABER UN SEMAFORO CREADO CON KEY Y VALOR 4, NOS ENCONTRABA ESE
   //SEMAFORO Y CAMBIABA EL COMPORTAMIENDO CON RESPECTO A 2 PERMITIENDO QUE ENTREN LOS DOS HIJOS Y EL PADRE A LA ZONA CRITICA AL MISMO TIEMPO
   if(fork()==0){
    //  semget(semid,-1); NOS PARECE QUE EN LUGAR DE SID, DEBERIA IR KEY. DE TODAS FORMAS, COMO DECIDIMOS HEREDAR LOS SEMAFOROS, 
    // NO ES NECESARIO OBTENERLOS NUEVAMENTE SINO QUE PODEMOS USAR EL SID DEL PADRE
     for(i=0;i<10;i++){
       printf("1st child trying... \n");
       for(int j = 0; j < 1000000000 ; j++){
         
       }
       // EN ESTOS CASOS AGREGAMOS LA COMPARACION PORQUE DE ACUERDO AL FUNCIONAMIENTO DE NUESTRO SEMDOWN, NO TENIA SENTIDO NO PREGUNTAR 
       // SI TE DIO O NO ACCESO A LA ZONA CRITICA, ES IMPORTANTE CONTROLAR QUE RETORNA
       if(semdown(semid) == 0){
       printf("1st child in critical region \n");
       for(int j = 0; j < 1000000000 ; j++){
         
       }
       semup(semid);
       printf("1st child out \n");
       }
       
     }
     exit(0);
   }
   /*second child*/
   if(fork()==0){
    //  int semget2 = semget(semid,-1); NOS PARECE QUE EN LUGAR DE SID, DEBERIA IR KEY. DE TODAS FORMAS, COMO DECIDIMOS HEREDAR LOS SEMAFOROS, 
    // NO ES NECESARIO OBTENERLOS NUEVAMENTE SINO QUE PODEMOS USAR EL SID DEL PADRE
    for(i=0;i<10;i++){
      printf("2nd child trying... \n");
      for(int j = 0; j < 1000000000 ; j++){
        
      }
      if(semdown(semid) == 0){
        printf("2nd child in critical region \n");
        for(int j = 0; j < 1000000000 ; j++){
          
        }
        semup(semid);
        printf("2nd child out \n");
      }
    }   
    exit(0);
   }
   /*Parent code*/
   for(i=0;i<10;i++){
     
     printf("Parent trying... \n");
     for(int j = 0; j < 1000000000 ; j++){
         
      }
     if(semdown(semid) == 0){
      printf("Parent in critical region \n");
      for(int j = 0; j < 1000000000 ; j++){
          
        }
      semup(semid);
      printf("Parent out \n");
     }
   }
   wait(0);
   wait(0);
   exit(0);

}

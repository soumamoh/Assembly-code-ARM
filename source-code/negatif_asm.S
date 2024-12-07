                                                                                      
@  Importation des,constantes symboliques WIDTH, HEIGHT, BYTES, BYTES_PER_LINE        
#include "image_bits_include.h"                                                       
										      
                                                                                      
                 .text                                                                
                                                                                      
@ r0 : parametre octet                                                                
@ r0 : valeur de retour de la fonction octet
                                                                                      
#ifndef C_NEG_OCTET                                                                   
                 .global neg_octet                                                    
                                                                                      
neg_octet: push {lr} 
	   mvn r0, r0
	   pop {pc}
                                                                             
                                                                                      
#endif // C_NEG_OCTET                                                                 
                                                                                      
#ifndef C_NEG_IMAGE                                                               
                 .global neg_image                                                    
@ r0 : parametre reçu image                                                           
@ r1 : variable locale de type pointeur (*adr)                                                                                         
@ r3 : BYTES
                                                                           
neg_image:    push {lr}
	ldr r3, adr_bytes
	
	mov r1, r0
	add r4, r0, r3	 @ r4 <- address + BYTES
                                                                                                                                                   
	pour: 	cmp r1, r4
		bge finPour
                ldrb r0, [r1]
		bl neg_octet 
                strb r0, [r1]
		add r1, r1, #1
	        b pour	
	finPour: pop {pc}                                                 
                                                                                      
adr_bytes:	.word BYTES                                                           
#endif // C_NEG_IMAGE                                                                 

                                                                                        
@  Importation des,constantes symboliques WIDTH, HEIGHT, BYTES, BYTES_PER_LINE          
#include "image_bits_include.h"    
	                                                                          
                 .global symetrie_octet                                                 
                 .global permuter_cols                                                  
                 .global symetrie_axe_v                                                 
                 .global permuter_ligne                                                 
                 .global symetrie_axe_h                                                 
                 .global symetrie_axe_h                                                 
                 .global permuter_lignes                                                
                 .global symetrie_axe_v                                                 
                                                                                        
                 .text                                                                  
                                                                                        
@ r0 : parametre reçu adresse                                                           
@ r1 : variable locale octet                                                            
                                                                                        
#ifndef C_SYMETRIE_OCTET                                                                
@#ifndef SYMTAB                                                                          
                                                                                        
@  Version avec opérations bit à bit                                                    
                                                                                        
symetrie_octet:   push {lr}
                  push {r1}
                  sub sp, sp, #8
                  ldrb r1, [r0]
                  strb r1, [sp, #8]

                  @ echange de quartets adjacents
                  and r1, r1, #0xF0
                  mov r1, r1, LSR #4
                  strb r1, [sp, #4]
                  ldrb r1, [sp, #8] @ recuperer la valeur de octet dans la pile
                  and r1, r1, #0x0F
                  mov r1, r1, LSL #4
                  strb r1, [sp]
                  pop {r2}
 		  pop {r1}
                  orr r1, r1, r2
 		  strb r1, [sp]

                  @ echange de doublets adjacents
                  sub sp, sp, #8
                  and r1, r1, #0xCC
                  mov r1, r1, LSR #2
                  strb r1, [sp, #4]
                  ldrb r1, [sp, #8] @ recuperer la valeur de l'octet dans la pile
                  and r1, r1, #0x33
                  mov r1, r1, LSL #2
                  strb r1, [sp]
                  pop {r2}
 		  pop {r1}
                  orr r1, r1, r2
                  strb r1, [sp]

                  @ echange de bits adjacents
                  sub sp, sp, #8
                  and r1, r1, #0xAA
                  mov r1, r1, LSR #1
                  strb r1, [sp, #4]
                  ldrb r1, [sp, #8] @ recuperer la valeur de l'octet dans la pile
                  and r1, r1, #0x55
                  mov r1, r1, LSL #1
                  strb r1, [sp]
                  pop {r2}
 		  pop {r1}
                  orr r1, r1, r2
                 
		  @ liberation de la pile
                  add sp, sp, #4
                  
                  strb r1, [r0]
 fin_symetrie_octet: pop {pc}
                  
                  
                                                                                        
@#else  //SYMTAB                                                                        
                                                                                        
@ Version tabulée                                                                       
@symetrie_octet:	push {lr} 
@                ldr r2, tabsym_octet
@                ldrb r1, [r0]
@                ldrb r1, [r2, r1]
@                strb r1, [r0]
@fin_symetrie_octe: pop {pc}
                     
                                                                                      
@#endif  // SYMTAB                                                                       
#endif  // C_SYMETRIE_OCTET                                                             
@ r0 : parametre tab                                                                    
@ r1 : parametre col                                                                    
#ifndef C_PERMUTER_COLS                                                                  
permuter_cols:   push {lr} @ r2 -> variable locale qui designe "tmp"
                 ldr r3, adr_bytes_per_line
                 sub r3, r3, #1  @ r3 <- BYTES_PER_LINE - 1
                 sub r3, r3, r1  @ r3 <- r3 - col
                 ldrb r2, [r0, r3] @ r2 <- tab[r3]
                 ldrb r4, [r0, r1] @ r2 <- tab[col]
                 strb r4, [r0, r3] @ tab[r3] <- tab[col]
                 strb r2, [r0, r1] @ r4 <- tab[col]
fin_permuer_cols: pop {pc}  @ pc <- lr
                 
                  
              
                                                                                       
#endif // C_PERMUTER_COLS                                                               
                                                                                        
@ r0 : paramètre image                                                                  
                                                                                        
#ifndef  C_SYMETRIE_AXE_V                                                                
symetrie_axe_v:  
                 stmfd sp!, {r4,r3,r2,r1,r0,lr}  @ empilement adr_ret, arg et des variables locales (position -> r1, li -> r2, col -> r3, *adresse -> r4)
                 @ symetriser chaque octet
                 ldr r5, adr_bytes @ r5  <- BYTES
                 mov r1, #0   @ position <- 0
                
            for_1: str r1, [sp, #12]
		   cmp r1, r5
                   bge done_1
                  ldrb r0, [sp, #16]
                  add r0, r0, r1
                   bl symetrie_octet
                   ldr r1, [sp, #12]
                   add r1, r1, #1
                   b for_1
                @ symetrie verticale octet par octet
           done_1: 
	        ldr r5, adr_height @ r5 <- HEIGHT
                ldr r6, adr_bytes_per_line @ r6 <- BYTES_PER_LINE
		mov r2, #0
            for_2_1: str r2, [sp, #8]
		     cmp r2, r5
                     bge done_2_1
                     ldrb r0, [sp, #16]
                     mul r4, r2, r6
                     add r4, r4, r0
                     mov r1, r4
                     strb r4, [sp]
                     mov r3, #0
                     for_2_2: str r3, [sp, #4]
			      cmp r3, r6, LSR #1
                              bge done_2_2
                              ldrb r4, [sp] 
                              mov r0, r4
                              mov r1, r3
                              bl permuter_cols
                              ldr r3, [sp, #4]
                              add r3, r3, #1
                              b for_2_2
                      done_2_2: ldr r2, [sp, #8]
				add r2, r2, #1
                                b for_2_1
            done_2_1: 
fin_symetrie_axe_v: add sp, sp, #20 @ liberation de la pile
                    ldmfd sp!, {pc}
                     
 
                 
                                                                                        
                                                                                        
#endif // C_SYMETRIE_AXE_V                                                              
@ r0 : tab                                                                              
@ r1 : li                                                                               
                                                                                        
#ifndef  C_PERMUTER_LIGNES                                                               
permuter_lignes:    push {lr} @ la variable locale (tmp -> r2)
                    mov r6, #21 
                    mul r5, r1, r6 
                    ldr r2, [r0, r5] @ r3 <- tab[li]
                    @ldrb r2, [r3]    @ r2 <- tab[li][0]
                    ldr r4, adr_height
                    sub r4, r4, #1
                    sub r4, r4, r1 @ r4 <- HEIGHT - 1 - li
                    mul r5, r4, r6
                    ldrb r4, [r0, r5]
                    ldrb r4, [r4]  @ r4 <- tab[HEIGHT-1-li][0]
                    strb r4, [r0, r2]  @ tab[li][0] <- tab[HEIGHT-1-li][0]
                    strb r2, [r0, r5]  @ tab[HEIGHT-1-li][0] <- tmp
fin_permuter_lignes: pop {pc}
                                                                   
                                                                                        
#endif  // C_PERMUTER_LIGNES                                                             
                                                                                        
@ r0 : paramètre image                                                                  
                                                                                        
#ifndef   C_SYMETRIE_AXE_H                                                               
symetrie_axe_h:    stmfd sp!, {r4,r3,r2,r1,r0,lr} empilement de l'adresse de retour, de l'argument (*image -> r0), et des variables locales (li -> r1, col -> r2, HEIGHT -> r3, BYTES_PER_LINES -> r4)
		   ldr r3, adr_height
                   str r3, [sp, #4]
                   ldr r4, adr_bytes_per_line
                   str r4, [sp]
		   mov r1, #0
                   for_a: str r1, [sp, #12]
                          ldr r3, [sp, #4]
                          cmp r1, r3, LSR #1
                          bge done_a
                          mov r2, #0
                          ldr r4, [sp]
                          for_b: str r2, [sp, #8]
				 cmp r2, r4
                                 bge done_b
                                 ldrb r0, [sp, #16]
			 	 add r0, r0, r2
				 ldr r1, [sp, #12]
                                 bl permuter_lignes
   				 ldr r2, [sp, #8]
				 add r2, r2, #1
                		 b for_b
			 done_b: ldr r1, [sp, #12]
			         add r1, r1, #1
				 b for_a
                    done_a: add sp, sp, #20 @ liberation pile
fin_symetrie_axe_h: pop {pc}
                                                                                        
#endif   // C_SYMETRIE_AXE_H

adr_bytes_per_line: .word BYTES_PER_LINE      
adr_bytes: .word BYTES   
adr_height: .word HEIGHT                                           


.i                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            (SEG_6)
	
	
	cmp r1, #7
	moveq r1, #(SEG_7)
	
	cmp r1, #8
	moveq r1, #(SEG_8)

	cmp r1, #9
	moveq r1, #(SEG_9)
	
	mov pc, r14	
	

softirq:


	movs    pc, r14

IRQ_handler:
	subs    pc, r14, #4

data:
		/* sec0, sec1, min0, min1, hour0, hour1, day */
	.word	0,    0,    0,    0,    0,     0,     0

/* No overflow  */
add64_op1:
   .word  0x22223333, 0x44445555
add64_op2:
   .word  0x33332222, 0x66665555
add64_res:
   .word  0x55555555, 0xAAAAAAAA
sub64_res:
   .word  0xEEEF1110, 0xDDDE0000



.align 4
irq_stack:
	.space 1024
sys_stack:
	.space 1024
usr_stack:
	.space 1024


.data
Ask_Input:
	.asciiz "\Please Enter a number\n"
Number:
	.word 4
Prime:
	.asciiz "\Number is Prime\n"
notPrime:
	.asciiz "\Number is not Prime\n"	
.text
.globl main
main:
la $a0, Ask_Input
li $v0,4 #op code to print the value in Ask_Input
syscall
li $v0,5
syscall
move $t1,$v0
li $t2,2
divu $t1,$t2  
mfhi $t7
mflo $t3
li $t4,3
beqz $t7,printnp
bge $t4,$t3,printp
loop:
bge $t4,$t3,printp
divu $t1,$t4
mfhi $t7
beqz $t7,printnp
addi $t4,$t4,2
j loop

exit:
li $v0,10
syscall
printp:
la $a0, Prime
li $v0,4 #op code to print the value in Ask_Input
syscall
j exit
printnp:
la $a0, notPrime
li $v0,4 #op code to print the value in Ask_Input
syscall
j exit

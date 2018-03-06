.data
prompt: .asciiz "Enter a Prime Number"
msg1: .asciiz "The Numbered entered is Prime"
msg2: .asciiz "The Numbered entered is not a Prime"
.text

# Optional: user inputs the number to test if prime
pr:   la   $a0, prompt      # load address of prompt for syscall
      li   $v0, 4           # specify Print String service
      syscall               # print the prompt string
      li   $v0, 5           # specify Read Integer service
      syscall               # Read the number. After this instruction, the number read is in $v0.
      add  $s5, $v0, $zero  # transfer the number to the desired register
      
      #First we test if the Number is Even , so it is not a Prime Number -->Optimization
      #Check the first bit if Zero then Even number & not prime 
      andi $t1,$s5,1
      beq $t1,$zero, print_not_prime
      
#Use Carmichael number resources as insurance. Knowing which numbers are Carmichael numbers 
#ahead of time can save you the headache of worrying about whether your number is actually prime or not. 
#In general, Carmichael numbers are of the form (6k + 1)(12k + 1)(18k + 1) for integer values of k when each 
#of the factors are prime.Online lists of Carmichael numbers can be extremely useful when using
# Fermat's Little Theorem to determine a number's primality.

# this test will be the first test , because the Carmichael numbers under 2^32 = 4294967296  , we can test them independently \
      # test  Carmichael numbers , they all not primes which make Feramt little Fails
      
      xor $t0,$t0,$t0
      addiu $t0,$t0,561
      beq $s5,$t0, print_not_prime
      
      xor $t0,$t0,$t0
      addiu $t0,$t0,1105
      beq $s5,$t0, print_not_prime
      
      xor $t0,$t0,$t0
      addiu $t0,$t0,1729
      beq $s5,$t0, print_not_prime
      
      xor $t0,$t0,$t0
      addiu $t0,$t0,2465
      beq $s5,$t0, print_not_prime
      
       xor $t0,$t0,$t0
      addiu $t0,$t0,2821
      beq $s5,$t0, print_not_prime
      
      xor $t0,$t0,$t0
      addiu $t0,$t0,6601
      beq $s5,$t0, print_not_prime
      
      xor $t0,$t0,$t0
      addiu $t0,$t0,8911
      beq $s5,$t0, print_not_prime
      
      xor $t0,$t0,$t0
      addiu $t0,$t0,10585
      beq $s5,$t0, print_not_prime 
      
      addiu $t2,$t2,41041
      beq $s5,$t2,print_not_prime
      
      addiu $t3,$t3,825265
      beq $s5, $t3 , print_not_prime
      
      addiu $t4,$t4,321197185 
      beq $s5,$t4, print_not_prime
      
     # Check whether an (mod n) = a (mod n). If not, n is composite. If true, n is likely,
     # (but not certainly) prime. Repeating the test with different values for a can increase your confidence in the outcome
     # make a copy of the number on $s0 for later use 
      
      move $s1,$s5
      
      #Little Fermat , Pick a number between 2 and n-1 inclusive
      #Compute a^n (mod n) 
      #Rather than use the 48-digit answer for 3100, 
      #let's instead represent it in exponent notation as (((((((32)*3)2)2)2)*3)2)2. 
      # i will encode the power using 1's & 0's
      # Even =0 , Odd = 1 from inside to out side 00100010 this represents the power in exponent notaion 
      
      #so we will do it as follow , if the number is even outmost bit is 0 , divide the number by 2 , if it is odd , reducde the number 
      #by one , and make the bit =1 , and so on until we reach Zero 
      
      # so now after generating the bit String we wil start working 
      
     # $t2 will hold the value of the exponent
     xor $t2,$t2,$t2
     # $3 will hold the length of the exponent
     xor $t3,$t3,$t3
     
     # test if even , --> add zero and shift by one , and we need a counter to count the length of exponent
     xor $t4,$t4,$t4
     addiu $t4,$t4,2 
     
     
loop_exponent:
     andi $t1,$s5,1       #test if the exponent is even add 0 if odd add 1
     beq $t1,$zero, even_exponent
     #if odd exponent
     subiu $s5,$s5,1
     
     sll $t2,$t2,1   
     addiu $t2,$t2,1   

     j next_iteration   
even_exponent:
	sll $t2,$t2,1
	srl $s5,$s5,1
	#divu $s5,$t4
	#mflo $s5      # move the quotient to $s5 again 
next_iteration:
     addiu $t3,$t3,1   #incement the size of the exponent by one      
     bne $s5,$t4, loop_exponent      # repeat while not finished
     
     #when finished the last value should be 2 then we should shift the exponent by one 
     sll $t2,$t2,1
     addiu $t3,$t3,1   #incement the size of the exponent by one
    
     #Function tested 
 
     #let the base number that we divide by is 3 for now 
     xor $t5,$t5,$t5
     addiu $t5,$t5,3
     
     xor $t6,$t6,$t6
     addiu $t6,$t6,3
     # now we should check each bit in exponent $t2
     # until the size is equal to zero in $t3
     
     # value of power alwats inside $t5
     #Compute Mod
 loop_compute_mod:
     andi $t1,$t2,1       #test if the exponent is even  0 if odd 1
     beq $t1,$zero, even
     
     # multiply it by 3 and continue the same way
     multu $t5,$t6
     mflo $t5
     divu $t5,$s1
      # always take the remainder as new $t5 value then continue 
     mfhi $t5
     j next_exponent_bit
 even:
 	multu $t5,$t5
 	mflo $t5
 	divu $t5,$s1
 	# always take the remainder as new $t5 value then continue 
 	mfhi $t5
 
 next_exponent_bit:
     # after we finish testing each exponent bit we go to next bit
    subiu $t3,$t3,1
    srl $t2,$t2,1
    bgtz $t3, loop_compute_mod     # repeat while not finished
     
     # once we finish the result of a^n mod n will be inside $t5
     # now we should compute 	
     
     divu $t6,$s1
     mfhi $t6
     
     beq $t5,$t6,print_prime
     j print_not_prime



 finish:
      # The program is finished. Exit.
      li   $v0, 10          # system call for exit
      syscall               # Exit!
      
 print_prime:
 	la $a0,msg1
 	li $v0,4
 	syscall
 	j finish
 
 print_not_prime:
  	la $a0,msg2
 	li $v0,4
 	syscall
 	j finish
      

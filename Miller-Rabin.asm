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
      
      xor $t0,$t0,$t0
      addiu $t0,$t0,3      
      div $s5,$t0
      mfhi $t2
      beqz $t2,print_not_prime
   
      xor $t0,$t0,$t0
      addiu $t0,$t0,5
      beq $s5,$t0, print_prime
      
      

      move $s1,$s5      #Save the original value for later use 
      
      # Step 1:Express n-1 in the form 2s × d where d is odd
      # subtract 1 from the number , check if the number is even and divide by 2 , until you got an odd number
      # save the number of division in a counter :) then you have the exponent
      # the rest are the Odd number d , so we are done from Step 1 , go to step 2 

     xor $t2,$t2,$t2       #$t2 will hold the exponent of 2 , which is s
     xor $t3,$t3,$t3       # will hold the odd number d     
     subiu $s5,$s5,1       # make the number even on the form n-1
     
     xor $t7,$t7,$t7
     ori $t7,2
   
loop_exponent_odd:
     andi $t1,$s5,1       #test if the number is even or odd , if even continue the loop , if odd Break
     bne $t1,$zero,d_value_found
     #if even exponent
     addiu $t2,$t2,1    # increase the value of s by 1 
     srl $s5,$s5,1
     bgtz $s5, loop_exponent_odd      # Repeat until the number is not zero in $s5 or there is no odd 
     
d_value_found:

move $t3,$s5

# s value in $t2 , d value in $t3
move $s7,$t2
#subiu $s7,$s7,1
#until here we can say that we have found the value of s & the value of d , so we can continue the Miller -Rabin Test

#Step 2: Pick a random number a between 2 and n-1.
# prime number should pass the test for any value of a ( randomly selected)

xor $t5,$t5,$t5   # use it for the random number
addiu $t5,$t5,3   # must be less than n ( 2   n-1 )

# value of n in $s1
move $s4,$t3
move $s2,$t3   # value of d
move $s3,$t5   # value of a


loop_miller_test:

#step 3: Compute a^d (mod n). If a^d = 1 or -1 (mod n), then n passes the Miller-Rabin test and is probably prime.

  #Little Fermat , Pick a number between 2 and n-1 inclusive , we have it inside $t5
  #Compute a^n (mod n) using the same way
  #let's instead represent it in exponent notation as (((((((32)*3)2)2)2)*3)2)2. 
  # i will encode the power using 1's & 0's again 
  # Even =0 , Odd = 1 from inside to out side 00100010 this represents the power in exponent notaion 
  #so we will do it as follow , if the number is even outmost bit is 0 , divide the number by 2 , if it is odd , reducde the number 
  #by one , and make the bit =1 , and so on until we reach Zero     
  # so now after generating the bit String we wil start working 
  
     #$t2 will hold the value of the exponent
     xor $t2,$t2,$t2
     #$3 will hold the length of the exponent
     xor $t3,$t3,$t3
     #test if even , --> add zero and shift by one , and we need a counter to count the length of exponent
     xor $t4,$t4,$t4
     addiu $t4,$t4,2 
     
     
     ori $t2,1
     beq $t2,$s2,power_one 
     ori $t3,2
     beq $t3,$s2,power_two
     
     xor $t2,$t2,$t2
     xor $t3,$t3,$t3
    
 loop_exponent:
     andi $t1,$s2,1       #test if the exponent is even add 0 if odd add 1
     beq $t1,$zero, even_exponent
     #if odd exponent
     subiu $s2,$s2,1
     sll $t2,$t2,1   
     addiu $t2,$t2,1   
     j next_iteration   
even_exponent:
	sll $t2,$t2,1
	srl $s2,$s2,1
next_iteration:
     addiu $t3,$t3,1   #incement the size of the exponent by one      
     bne $s2,$t4, loop_exponent      # repeat while not finished
     
     sll $t2,$t2,1
     addiu $t3,$t3,1   #incement the size of the exponent by one
        
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
     
     # once we finish the result of a^d mod n will be inside $t5
     
     j continue_prog
     
     #if d =1 , a^d = a
    power_one:
    move $t5,$t6
    j continue_prog
    
    power_two:
    move $t5,$t6
    multu $t5,$t5
    mflo $t5
 
    continue_prog:
     
     #step 5 Compute ad (mod n). If a^d = 1 or -1 (mod n), then n passes the Miller-Rabin test and is probably prime. Like Fermat's Little Theorem,
     # this test can't pinpoint primes with absolute certainty with only one test. 
	
	xor $t7,$t7,$t7
	addiu $t7,$t7,1
	
   # if a^d mod n = 1 then it is probably a Prime , if not continue to compute a2d, a4d, ... and so on to a^(2s-1) d.
     beq $t5,$t7,print_prime
   # if a^d mod n = -1 mod n then also it is probably a prime --> -1 mod 7 = 7-1 =6 only for this case 
     subiu $t7,$s1,1
     beq $t5,$t7,print_prime
     
     
     sll $s5,$s5,1   # multiply by 2 
     move $s2,$s5   # value of d
     subiu $s7,$s7,1
     
     bgtz $s7,loop_miller_test
     
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
      

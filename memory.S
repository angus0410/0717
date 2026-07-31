@
@ Assembler program to convert a string to
@ all lower case. (Exercise 6-3)
@
@ R0 - string parameter to printf
@ R3 - address of output string
@ R4 - address of input string
@ R5 - current character being processed
@

.thumb_func              @ Necessary because sdk uses BLX
.global main             @ Provide program starting address to linker

main: BL stdio_init_all  @ Initialize uart or usb

      LDR R4, =instr     @ start of input string
      LDR R3, =outstr    @ address of output string

@ The loop is until byte pointed to by R4 is non-zero
loop: LDRB R5, [R4]      @ load character
      ADD R4, #1         @ increment pointer

@ If R5 > 'Z' then goto cont
      CMP R5, #'Z'       @ is letter > 'Z'?
      BGT cont

@ Else if R5 < 'A' then goto cont
      CMP R5, #'A'
      BLT cont           @ goto to end if

@ if we got here then the letter is uppercase, so convert it.
      ADD R5, #('a'-'A') @ 改為加上差值 (轉小寫)

cont: @ end if
      STRB R5, [R3]      @ store character to output str
      ADD R3, #1         @ increment pointer
      CMP R5, #0         @ stop on hitting a null character
      BNE loop           @ loop if character isn't null

@ Setup the parameters to printf our lower case string
loop2: LDR R0, =outstr   @ string to print
       BL printf         @ Call printf to output
       B loop2

.data
instr:  .asciz  "This is our Test String that we will convert.\n"
outstr: .fill   255, 1, 0
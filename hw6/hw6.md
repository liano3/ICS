# ICS hw6

### T1

> The main program below calls a subroutine `F` . The `F` subroutine uses R3 and R4 as input, and produces an output which is placed in R0. The subroutine modifies registers R0, R3, R4, R5, and R6 in order to complete its task. `F` calls two other subroutines, `SaveRegisters` and `RestoreRegisters` , that are intended handle the saving and restoring of the modified registers (although we will see in question (b) that this may not be the best idea!).
>
> ```assembly
> ; Main Program;
> .ORIG x3000
> ...
> JSR F
> ...
> HALT
> ; R3 and R4 are input.
> ; Modifies R0, R3, R4, R5, and R6
> ; R0 is the output
> F
> JSR SaveRegisters
> ...
> JSR RestoreRegisters
> RET
> .END
> ```
>
> (a) Write the two subroutines SaveRegisters and RestoreRegisters . 
>
> (b) When we run the code we notice there is an infinite loop. Why? What small change can we make to our program to correct this error. Please specify both the correction and the subroutine that is being corrected.

##### (a)

```assembly
SaveRegisters
ST R5, SaveR5
ST R6, SaveR6
RET
```

```assembly
RestoreRegisters
LD R5, SaveR5
LD R6, SaveR6
RET
```

##### (b)

JSR 套 JSR，原 R7 的存储的返回地址会被新的覆盖掉，无法正确返回；

在 `JSR SaveRegisters` 之前加入语句 `ST R7, SaveR7`，保存返回地址，在 `RET` 之前加入语句 `LD R7, SaveR7`，恢复返回地址；

```assembly
F
ST R7, SaveR7
JSR SaveRegisters
...
JSR RestoreRegisters
LD R7, SaveR7
RET
```

### T2

> Assume that you have the following table in your program:
> ```assembly
> MASKS
> .FILL x0001
> .FILL x0002
> .FILL x0004
> .FILL x0008
> .FILL x0010
> .FILL x0020
> .FILL x0040
> .FILL x0080
> .FILL x0100
> .FILL x0200
> .FILL x0400
> .FILL x0800
> .FILL x1000
> .FILL x2000
> .FILL x4000
> .FILL x8000
> ```
>
> (a) Write a subroutine `CLEAR` in LC-3 assembly language that clears a bit in R0 using the table above. The index of the bit to clear is specified in R1. R0 and R1 are inputs to the subroutine. 
>
> (b) Write a similar subroutine `SET` that sets the specified bit instead of clearing it. 

##### (a)

在表中找除了目标位置为 1 外，其余位置都为 0 的数，NOT 取反，再 AND R0

```assembly
CLEAR
ST R2, SaveR2
LEA R2, MASKS
AGAIN ADD R2, R2, #1 
ADD R1, R1, #-1
BRp AGAIN
LDR R2, R2, #0
NOT R2, R2
AND R0, R0, R2
LD R2, SaveR2
RET
```

##### (b)

先 `CLEAR`，再加上除了目标位置为 1 外，其余位置都为 0 的数

```assembly
SET
ST R7, SaveR7
JSR CLEAR
LEA R2, MASKS
AGAIN ADD R2, R2, #1 
ADD R1, R1, #-1
BRp AGAIN
LDR R2, R2, #0
ADD R0, R0, R2
LD R7, SaveR7
RET
```

### T3

> The following program needs to be assembled and stored in LC-3 memory
>
> ```assembly
> 	.ORIG x4000
> 	AND R0,R0,#0
> 	ADD R1,R0,#0
> 	ADD R0,R0,#4
> 	LD R2,B
> A 	LDR R3,R2,#0
> 	ADD R1,R1,R3
> 	ADD R2,R2,#1
> 	ADD R0,R0,#-1
> 	BRnp A
> 	JSR SHIFTR
> 	ADD R1,R4,#0
> 	JSR SHIFTR
> 	ST R4,C
> 	TRAP x25
> B 	.BLKW 1
> C 	.BLKW 1
> .END
> ```
>
> (a) How many memory locations are required to store the assembled program?  
>
> (b) What is the address of the location labeled C?  
>
> (c) Before the program can execute, the location labeled B must be loaded by some external means. You can assume that happens before this program starts executing. You can also assume that the subroutine starting at location SHIFTR is available for this program to use. SHIFTR takes the value in R1, shifts it right one bit, and stores the result in R4. 
>
> After the program executes, what is in location C? 

##### (a)

需要 16 行存储

##### (b)

x4015

##### (c)

C 中存储的是 R1 右移两位的结果，$R1=M[B]+M[B+1]+M[B+2]+M[B+3]$

### T4

> Our code to compute n factorial worked for all positive integers n. Augment the iterative solution to FACT to also work for 0!.
>
> ```assembly
> FACT ST R1,SAVE_R1
>  	ADD R1,R0,#0
>  	ADD R0,R0, #-1
>  	BRz DONE
> AGAIN MUL R1,R1,R0
>  	ADD R0,R0,#-1 ; R0 gets next integer for MUL
> 	BRnp AGAIN
> DONE ADD R0,R1,#0 ; Move n! to R0
> 	LD R1,SAVE_R1
> 	RET
> SAVE_R1 .BLKW 1
> ```

```assembly
FACT ST R1,SAVE_R1
 	ADD R1,R0,#0
 	ADD R0,R0, #-1
 	BRnz DONE
AGAIN MUL R1,R1,R0
 	ADD R0,R0,#-1 ; R0 gets next integer for MUL
	BRnp AGAIN
DONE ADD R0,R1,#0 ; Move n! to R0
	BRp SKIP
	ADD R0, R0, #1
SKIP LD R1,SAVE_R1
	RET
SAVE_R1 .BLKW 1
```

### T5

> (a) What problem could occur if a program does not check the Ready bit of the KBSR before reading the KBDR?  
>
> (b) What problem could occur if the keyboard hardware does not check the KBSR before writing to the KBDR?  
>
> (c) Which of the above two problems is more likely to occur? Give your reason

##### (a)

可能读取到上次读入的字符

##### (b)

可能覆盖掉上一次未被读入的字符

##### (c)

第一个问题更可能发生，因为键盘是中断驱动的 I/O，当有新的输入时会自动调用中断服务程序完成读取操作

### T6

> Some computer engineering students decided to revise the LC-3 for their senior project. In designing the LC-4, they decided to conserve on device registers by combining the KBSR and the DSR into one status register: the IOSR (the input/output status register). IOSR[15] is the keyboard device ready bit and IOSR[14] is the display device ready bit. What are the implications for programs wishing to do I/O? Is this a poor design decision?

`Input` 时像 LC-3 一样，直接检测 IOSR 的是否是负数即可；`Output` 时需要检测 IOSR[14] 是否为 1，可以先左移一位，再检测是否为负数；

理论上说，这样的设计多消耗了一个临时寄存器用来存储 IOSR 左移的结果，又多了一个 ADD 指令，使 I/O 不方便不统一，is a poor decision

### T7

> (a) How many `TRAP` service routines can be implemented in the LC-3? Why? 
>
> (b) How many accesses to memory are made during the processing of a `TRAP` instruction?

##### (a)

最多 256 个服务程序，因为 8bit 只能表示 256 个地址

##### (b)

两次，先读取陷入向量表中对应位置存储的服务程序地址，再读取相应地址存储的程序内容

### T8

> The following LC-3 program is assembled and then executed. There are no assemble time or run-time errors. What is the output of this program? Assume all registers are initialized to 0 before the program executes.
>
> ```assembly
> 	.ORIG x3000
>  	LEA R0, LABEL
>  	STR R1, R0, #3
>  	TRAP x22
>  	TRAP x25
> LABEL .STRINGZ "FUNKY"
> LABEL2 .STRINGZ "HELLO WORLD"
>  	.END
> ```

输出结果为：`FUN`

### T9

> Assume that an integer greater than 2 and less than 32,768 is deposited in memory location A by another module before the program below is executed.
>
> ```assembly
> 	.ORIG x3000
>  	AND R4, R4, #0
>  	LD R0, A
>  	NOT R5, R0
>  	ADD R5, R5, #2
>  	ADD R1, R4, #2
>  ;
> REMOD JSR MOD
>  	BRz STORE0
>  ;
>  	ADD R7, R1, R5
>  	BRz STORE1
>  	ADD R1, R1, #1
>  	BR REMOD
>  ;
> STORE1 ADD R4, R4, #1
> STORE0 ST R4, RESULT
>  	TRAP x25
>  ;
> MOD ADD R2, R0, #0
>  	NOT R3, R1
>  	ADD R3, R3, #1
> DEC ADD R2, R2, R3
>  	BRp DEC
>  	RET
>  ;
> A .BLKW 1
> RESULT .BLKW 1
> .END
> ```
> 
> In 25 words or fewer, what does the above program do?

判断 A 是否是素数，如果是，通过 RESULT 输出 1，否则输出 0

### T10

> The program below, when complete, should print the following to the monitor: ABCFGH Insert instructions at (a)–(d) that will complete the program.
>
> ```assembly
> 	.ORIG x3000
>  	LEA R1, TESTOUT
> BACK_1 LDR R0, R1, #0
>  	BRz NEXT_1
>  	TRAP x21
>  ------------ (a)
>  	BRnzp BACK_1
>  ;
> NEXT_1 LEA R1, TESTOUT
> BACK_2 LDR R0, R1, #0
>  	BRz NEXT_2
>  	JSR SUB_1
>  	ADD R1, R1, #1
>  	BRnzp BACK_2
>  ;
> NEXT_2 ------------ (b)
>  ;
> SUB_1 ------------ (c)
> K LDI R2, DSR
>  ------------ (d)
>  	STI R0, DDR
>  	RET
> DSR .FILL xFE04
> DDR .FILL xFE06
> TESTOUT .STRINGZ "ABC"
>  .END
> ```

- (a): `ADD R1, R1, #1`
- (b): `HALT`
- (c): `ADD R0, R0, #5`
- (d): `BRzp K`

### T11

> nterrupt-driven I/O:  
>
> (a) What does the following LC-3 program do? 
>
> ```assembly
> 	.ORIG x3000
>  	LD R3, A
>  	STI R3, KBSR
>  AGAIN LD R0, B
>  	TRAP x21
>  	BRnzp AGAIN
> A .FILL x4000
> B .FILL x0032
> KBSR .FILL xFE00
>  	.END
> ```
>
> (b) If someone strikes a key, the program will be interrupted and the keyboard interrupt service routine will be executed as shown below. What does the keyboard interrupt service routine do? 
>
> ```assembly
> 	.ORIG x1000
>  	LDI R0, KBDR
>  	TRAP x21
>  	TRAP x21
>  	RTI
> KBDR .FILL xFE02
>  	.END
> ```
>
> (c) Finally, suppose the program of part a started executing, and someone sitting at the keyboard struck a key. What would you see on the screen? 
>
> (d) In part c, how many times is the digit typed shown on the screen? Why is the correct answer: "I cannot say for sure."

##### (a)

循环打印字符 ‘2’

##### (b)

回显两次键盘输入

##### (c)

先回显两次键盘输入，然后继续循环打印 ‘2’

##### (d)

两次或三次，因为在中断服务程序中没有保存和回复 R0，的值，如果是在 `LD R0, B`  之后 `TRAP x21` 之前中断的，那么会输出三次键盘输入字符；否则只会输出两次

### T12

> Two students wrote interrupt service routines for an assignment. Both service routines did exactly the same work, but the first student accidentally used RET at the end of his routine, while the second student correctly used RTI. There are three errors that arose in the first student’s program due to his mistake. Describe any two of them.

PSR 寄存器无法恢复；PC 寄存器无法恢复；

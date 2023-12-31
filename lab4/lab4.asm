.ORIG x3000
LD R6, COUNT	;剩余未排序个数
ADD R3, R3, #-1	;下界设为-1
LD R1, ANS		;指向排序后数组的指针
;初始化
AGAIN LD R0, ARRAY	;指向原数组的指针
LD R2, MAX		;最小值设为100 
LD R5, COUNT	;剩余未扫描个数
;扫描原数组
SUBAGAIN LDR R4, R0, #0		;R4=M[R0]
ADD R0, R0, #1	;R0++
;判断是否取过
AND R7, R7, #0
NOT R7, R3
ADD R7, R7, #1
ADD R7, R4, R7	;R7=R4-R3
BRnz SKIP
;判断是否小于最小值
AND R7, R7, #0
NOT R7, R2
ADD R7, R7, #1
ADD R7, R4, R7	;R7=R4-R2
BRzp SKIP
;更新最小值
AND R2, R2, #0
ADD R2, R2, R4
SKIP ADD R5, R5, #-1
BRp SUBAGAIN
;存储最小值，更新下界
STR R2, R1, #0	;M[R1]=R2
ADD R1, R1, #1	;R1++
AND R3, R3, #0
ADD R3, R3, R2	;R3=R2
ADD R6, R6, #-1	;R6--
BRp AGAIN
;计算A的个数
LD R5, ACONST	;R5= -85
LD R6, BCONST	;R6= -75
AND R2, R2, #0
AND R3, R3, #0
AGAIN1 ADD R1, R1, #-1	;R1--
LDR R4, R1, #0	;R4=M[R1]
ADD R7, R4, R5
BRn SKIP1
ADD R2, R2, #1	;R2++
ADD R7, R2, #-4	;判断优秀率是否超了
BRzp SKIP2
BRnzp AGAIN1
;计算B的个数，同理
SKIP1 ADD R1, R1, #1
SKIP2 ADD R3, R3, R2; 
SKIP3 ADD R1, R1, #-1
LDR R4, R1, #0
ADD R7, R4, R6
BRn THEND
ADD R3, R3, #1
ADD R7, R3, #-8
BRzp THEND
BRnzp SKIP3
;存储结果
THEND NOT R7, R2
ADD R7, R7, #1
ADD R3, R3, R7; 
STI R2, NUMA
STI R3, NUMB
HALT
;占位
ARRAY .FILL x4000
ANS .FILL x5000
NUMA .FILL x5100
NUMB .FILL x5101
MAX .FILL #100
COUNT .FILL #16
ACONST .FILL #-85
BCONST .FILL #-75
.END
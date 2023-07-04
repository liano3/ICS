        .ORIG x800
        ; 将中断服务程序x1000装入陷入矢量表
        LD R0, VEC
        LD R1, ISR
        STR R1, R0, #0
        ; 设置KBSR中断使能为1
        LDI R0, KBSR
        LD R1, MASK
        NOT R1, R1
        AND R0, R0, R1
        NOT R1, R1
        ADD R0, R0, R1
        STI R0, KBSR
        ; 保存用户程序（被中断程序）的状态PSR
        LD R0, PSR
        ADD R6, R6, #-1
        STR R0, R6, #0
        LD R0, PC
        ADD R6, R6, #-1
        STR R0, R6, #0
        ;进入用户程序
        RTI
VEC     .FILL x0180
ISR     .FILL x1000
KBSR    .FILL xFE00
MASK    .FILL x4000
PSR     .FILL x8002
PC      .FILL x3000
        .END

;用户程序，不断输出学号，直到N为有效值（非xFFFF），停止输出，调用HONOI，输出结果
        .ORIG x3000
Loop    LDI R1, HONOI_N
        ADD R2, R1, #1
        BRz SKIP
        LD R6, R6INIT
        ;输出"Tower of honoi needs "
        LEA R0, String1
        Trap x22
        JSR HONOI	;N为有效值，调用HONOI子程序
        ;输出计算结果，分别求出各位的数字，再转为ascii码输出
        LD R3, Const1
        LD R4, ASCII
        ADD R2, R0, #0  ;结果由R0转存至R2
        ADD R0, R2, R3
        BRn SKIP1
        AND R0, R0, #0
AGAIN1  ADD R0, R0, #1  ;减法求余
        ADD R2, R2, R3
        BRzp AGAIN1
        LD R3, Const2
        ADD R2, R2, R3
        ADD R0, R0, #-1
        ADD R0, R0, R4
        Trap x21;百位
SKIP1   ADD R0, R2, #-10
        BRn SKIP2
        AND R0, R0, #0
AGAIN2  ADD R0, R0, #1
        ADD R2, R2, #-10
        BRzp AGAIN2
        ADD R2, R2, #10
        ADD R0, R0, #-1
        ADD R0, R0, R4
        Trap x21;十位
SKIP2   ADD R0, R2, R4
        Trap x21;个位
        ;输出" moves."
        LEA R0, String2
        Trap x22
        HALT    ;结束程序
	   ;循环输出学号
SKIP    LEA R0, Prompt
        Trap x22
        JSR DELAY	;延迟输出
        BRnzp Loop

        ;Delay子程序，延迟输出
DELAY   ST R1, SaveR1 
        LD R1, COUNT 
REP     ADD R1, R1, #-1 
        BRp REP 
        LD R1, SaveR1 
        RET
        
        ;HONOI子程序，R1为参数，计算并返回结果R0
HONOI   ADD R6, R6, #-1
        STR R7, R6, #0
        ADD R1, R1, #-1
        BRzp REC
        ; if(n=0) return 0
        AND R0, R0, #0
        LDR R7, R6, #0
        ADD R6, R6, #1
        RET
        ; else return 2*f(n-1)+1
REC     JSR HONOI
        ADD R0, R0, R0
        ADD R0, R0, #1
        LDR R7, R6, #0
        ADD R6, R6, #1
        RET

String1 .STRINGZ "Tower of honoi needs "
String2 .STRINGZ " moves"
Prompt  .STRINGZ "PB21111715 "
Const1  .FILL #-100
Const2  .FILL #100
ASCII   .FILL #48
COUNT   .FILL #8888
HONOI_N .FILL x3FFF
R6INIT  .FILL xFDFF
SaveR1  .BLKW 1
        .END

        .ORIG x3FFF
        ; 初始化的数据xFFFF
INIT_N .FILL xFFFF
        .END

;中断服务程序，检测N的合法性，最终存储N
        .ORIG x1000
        ST R0, Save0
        ST R1, Save1
        ST R2, Save2
        LD R1, Newline
        ADD R0, R1, #0
        Trap x21	;输出换行符
        Trap x20    ;GETC
        Trap x21    ;回显输入字符
        LD R2, MIN
        ADD R2, R0, R2
        BRn ERROR	;N<0
        LD R2, MAX
        ADD R2, R0, R2
        BRp ERROR	;N>9
        ;保存N值
        LD R2, MIN
        ADD R0, R0, R2 
        STI R0, NSTP
        LEA R0, Str2
        BRnzp Loop1
ERROR   LEA R0, Str1
        ;输出提示信息
Loop1   Trap x22
        ;输出换行符
        ADD R0, R1, #0
        Trap x21
        ST R0, Save0
        ST R1, Save1
        ST R2, Save2
        RTI
        
Str1    .STRINGZ " is not a decimal digit."
Str2    .STRINGZ " is a decimal digit."
Newline .FILL x000A ;换行的ascii码
NSTP    .FILL x3FFF ;N的存储位置
MIN     .FILL #-48 ;0的ascii码的相反数
MAX     .FILL #-57 ;9的ascii码的相反数
Save0   .BLKW 1
Save1   .BLKW 1
Save2   .BLKW 1
        .END
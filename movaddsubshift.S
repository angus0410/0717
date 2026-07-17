@
@ 64-bit Subtraction (Reversing 64-bit Addition)
@

.thumb_func         @ Necessary because sdk uses BLX
.global main        @ Provide program starting address to linker

main:   BL  stdio_init_all  @ initialize uart or usb

@ ----------------------------------------------------
@ 1. 設定減法的輸入值 (將加法結果扣掉第二個加數)
@ ----------------------------------------------------
@ 被減數 (加法算出的總和: 0x67 0x02345678)
@ 我們使用 R2 (高位組) 與 R3 (低位組)
    MOV R2, #0x67
    
    @ 透過移位組合出 R3 = 0x02345678 (全使用低暫存器 R0-R3)
    MOV R3, #0x02
    LSL R3, #24
    MOV R1, #0x34
    LSL R1, #16
    ADD R3, R1
    MOV R1, #0x56
    LSL R1, #8
    ADD R3, R1
    MOV R1, #0x78
    ADD R3, R1

@ 減數 (原本加法中的第二個加數: 0x54 0xF0000000)
@ 我們使用 R0 (高位組) 與 R1 (低位組)
    MOV R0, #0x54
    MOV R1, #0xF0
    LSL R1, #24

@ ----------------------------------------------------
@ 2. 進行 64 位元減法 (R2 R3 = R2 R3 - R0 R1)
@ ----------------------------------------------------
@ 為了完全符合 Thumb 16-bit 規範：
@ 我們必須使用「2 運算元」格式，即：Rd = Rd - Rm

@ A. 低位組相減：R3 = R3 - R1 (0x02345678 - 0xF0000000)
@ 這會更新旗標並產生借位 (C = 0)
    SUB R3, R1

@ B. 高位組相減：R2 = R2 - R0 - 借位 (0x67 - 0x54 - 1)
@ 使用最安全的 SBC 2 運算元格式
    SBC R2, R0

@ 此時結果在：
@ R2 = 原本的第一個高位加數 (0x12)
@ R3 = 原本的第一個低位加數 (0x12345678)

@ ----------------------------------------------------
@ 3. 將結果印出
@ ----------------------------------------------------
@ 複製結果到 R6, R7 避開 printf 覆寫
    MOV R6, R2      @ R6 = R2 (0x12)
    MOV R7, R3      @ R7 = R3 (0x12345678)

@ 進入無窮迴圈列印結果
loop:   MOV R1, R6      @ 參數 2: 高位字組
    MOV R2, R7      @ 參數 3: 低位字組
    LDR R0, =sumstr @ 參數 1: 格式化字串
    BL  printf      @ 呼叫 printf
    B   loop        @ 重新迴圈

.data
    .align  4       @ 記憶體對齊
sumstr: .asciz   "The subtracted result is %x %x\n"
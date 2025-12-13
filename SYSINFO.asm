; =========================================
; Complete System Information Viewer - Polished
; 16-bit Assembly (MASM)
; Target: DOSBox 0.74-3
; =========================================

.8086
.MODEL SMALL
.STACK 100h

; -----------------------------------------
; DATA SEGMENT
; -----------------------------------------
.DATA
titleMsg DB 'COMPLETE SYSTEM INFORMATION VIEWER$'

menuMsg  DB 13,10
         DB '1. CPU Information',13,10
         DB '2. Memory Information',13,10
         DB '3. Disk Information',13,10
         DB '4. Video Information',13,10
         DB '5. Keyboard Status',13,10
         DB '6. Date & Time',13,10
         DB '7. DOS Version',13,10
         DB '0. Exit',13,10
         DB 'Select Option: $'

; CPU messages
cpu8086Msg DB 'CPU Type: 8086 / 8088$'
cpu286Msg  DB 'CPU Type: 80286$'
cpu386Msg  DB 'CPU Type: 80386 or higher$'

; Memory
memMsgHeader DB 'Conventional Memory Size (GB): $'

; Disk
diskMsgHeader DB 'C: Drive Free Space (KB): $'
diskValMsg DB 'Free Space: $'

; Video
videoMsgHeader DB 'Video Mode Info:$'

; Keyboard
keyMsgHeader DB 'Keyboard Status: $'
capsMsg      DB 'Caps Lock ON$',0
numMsg       DB 'Num Lock ON$',0
scrollMsg    DB 'Scroll Lock ON$',0

; Date & Time
dateMsg DB 'Date: $'
timeMsgHeader DB 'Time: $'


; DOS Version
dosMsg DB 'DOS Version$'
dosMsgHeader DB 'DOS Version: $'
dotChar      DB '.'

; Temporary buffers
numBuffer DB 6 DUP(0)    ; For number display

; -----------------------------------------
; CODE SEGMENT
; -----------------------------------------
.CODE

; -----------------------------------------
; MAIN PROCEDURE
; -----------------------------------------
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
MainLoopCall:
    CALL MainLoop
    ; Program exit
    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; -----------------------------------------
; Main Loop Procedure
; -----------------------------------------
MainLoop PROC
    CALL ClearScreen
    CALL ShowMenu

    MOV AH, 00h
    INT 16h            ; Read key (AL)

    CMP AL, '0'
    JE MainLoop_Exit

    CMP AL, '1'
    JE CPU_Info

    CMP AL, '2'
    JE Memory_Info

    CMP AL, '3'
    JE Disk_Info

    CMP AL, '4'
    JE Video_Info

    CMP AL, '5'
    JE Keyboard_Info

    CMP AL, '6'
    JE DateTime_Info

    CMP AL, '7'
    JE DOS_Info

    JMP MainLoop       ; Invalid key → back to menu

MainLoop_Exit:
    RET
MainLoop ENDP

; -----------------------------------------
; Clear Screen Procedure
; -----------------------------------------
ClearScreen PROC
    MOV AX, 0003h      ; Reset text mode
    INT 10h

    MOV AX, 0600h
    MOV BH, 1Fh        ; White on Blue
    MOV CX, 0000h
    MOV DX, 184Fh
    INT 10h
    RET
ClearScreen ENDP

; -----------------------------------------
; Show Menu Procedure
; -----------------------------------------
ShowMenu PROC
    MOV DX, OFFSET titleMsg
    CALL PrintString

    MOV DX, OFFSET menuMsg
    CALL PrintString
    RET
ShowMenu ENDP

; -----------------------------------------
; Print String Procedure
; DS:DX -> '$' terminated string
; -----------------------------------------
PrintString PROC
    MOV AH, 09h
    INT 21h
    RET
PrintString ENDP

; -----------------------------------------
; Wait for Key Procedure
; -----------------------------------------
WaitKey PROC
    MOV AH, 00h
    INT 16h
    RET
WaitKey ENDP

; -----------------------------------------
; CPU Info Procedure
; -----------------------------------------
CPU_Info PROC
    CALL ClearScreen
    MOV DX, OFFSET cpuHeadMsg
    CALL PrintString

    PUSHF
    POP AX
    MOV CX, AX
    XOR AX, 0F000h
    PUSH AX
    POPF
    PUSHF
    POP AX
    XOR AX, CX
    AND AX, 0F000h
    JZ CPU_8086

    ; 80286 or higher
    PUSHF
    POP AX
    MOV CX, AX
    XOR AX, 040000h
    PUSH AX
    POPF
    PUSHF
    POP AX
    XOR AX, CX
    AND AX, 040000h
    JZ CPU_286

    ; 80386+
    MOV DX, OFFSET cpu386Msg
    CALL PrintString
    ; CPUID check skipped: PUSHFD/POPFD not available in 16-bit real mode
    CALL WaitKey
    JMP MainLoop

CPU_286:
    MOV DX, OFFSET cpu286Msg
    CALL PrintString
    CALL WaitKey
    JMP MainLoop

CPU_8086:
    MOV DX, OFFSET cpu8086Msg
    CALL PrintString
    CALL WaitKey
    JMP MainLoop
CPU_Info ENDP

; -----------------------------------------
; Memory Info Procedure
; -----------------------------------------
Memory_Info PROC
    CALL ClearScreen
    MOV DX, OFFSET memHeadMsg
    CALL PrintString

    MOV DX, OFFSET memMsgHeader
    CALL PrintString

    ; Get conventional memory in KB
    INT 12h         ; AX = memory in KB
    MOV BX, AX
    CALL PrintNumber
    MOV DX, OFFSET kbMsg
    CALL PrintString

    ; Get extended memory (if available)
    MOV AH, 88h
    INT 15h         ; AX = KB of extended memory
    CMP AX, 0
    JE NoExtMem
    MOV DX, OFFSET extMemMsg
    CALL PrintString
    CALL PrintNumber
    MOV DX, OFFSET kbMsg
    CALL PrintString
NoExtMem:
    CALL WaitKey
    JMP MainLoop
Memory_Info ENDP

; -----------------------------------------
; Disk Info Procedure
; -----------------------------------------

; -----------------------------------------
; Video Info Procedure
; -----------------------------------------
Video_Info PROC
    CALL ClearScreen
    MOV DX, OFFSET videoMsgHeader
    CALL PrintString

    MOV AH, 0Fh
    INT 10h         ; Get video mode

    ; Display Mode
    MOV AL, AL
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    MOV DL, 13
    MOV AH, 02h
    INT 21h
    MOV DL, 10
    INT 21h

    ; Display Columns (AH)
    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    ; Display Rows (25 default for DOSBox)
    MOV AL, 25
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    CALL WaitKey
    JMP MainLoop
Video_Info ENDP

; -----------------------------------------
; Keyboard Info Procedure
; -----------------------------------------
Keyboard_Info PROC
    CALL ClearScreen
    ; ...existing code for Keyboard_Info...
    CALL PrintString
    CALL WaitKey
    JMP MainLoop
Keyboard_Info ENDP

; -----------------------------------------
; DateTime Info Procedure
; ----------------------------------------- 
DateTime_Info PROC
    CALL ClearScreen
    MOV DX, OFFSET dtHeadMsg
    CALL PrintString

    ; Date
    MOV AH, 2Ah
    INT 21h
    MOV DX, OFFSET dateMsg
    CALL PrintString
    MOV AX, CX
    CALL PrintNumber4
    MOV DL, '/'
    MOV AH, 02h
    INT 21h
    MOV AL, DH
    CALL PrintNumber2
    MOV DL, '/'
    MOV AH, 02h
    INT 21h
    MOV AL, DL
    CALL PrintNumber2

    ; Show day of week
    MOV DX, OFFSET dowMsg
    CALL PrintString
    MOV AL, AL
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    ; Time
    MOV AH, 2Ch
    INT 21h
    MOV DX, OFFSET timeMsgHeader
    CALL PrintString
    MOV AL, CH
    CALL PrintNumber2
    MOV DL, ':'
    MOV AH, 02h
    INT 21h
    MOV AL, CL
    CALL PrintNumber2
    MOV DL, ':'
    MOV AH, 02h
    INT 21h
    MOV AL, DH
    CALL PrintNumber2

    CALL WaitKey
    JMP MainLoop
DateTime_Info ENDP
    ; -----------------------------------------
    ; ASCII Headings and Extra Messages
    ; -----------------------------------------
    cpuHeadMsg DB 13,10,'==== CPU INFORMATION ====',13,10,'$'
    cpuidYesMsg DB 13,10,'CPUID Supported',13,10,'$'
    cpuidNoMsg  DB 13,10,'CPUID Not Supported',13,10,'$'
    memHeadMsg  DB 13,10,'==== MEMORY INFORMATION ====',13,10,'$'
    extMemMsg   DB 13,10,'Extended Memory: ','$'
    kbMsg       DB ' KB',13,10,'$'
    diskHeadMsg DB 13,10,'==== DISK INFORMATION ====',13,10,'$'
    totalMsg    DB 13,10,'Total Space: ','$'
    freeMsg     DB 13,10,'Free Space: ','$'
    dtHeadMsg   DB 13,10,'==== DATE & TIME INFORMATION ====',13,10,'$'
    dowMsg      DB '  DayOfWeek: ','$'
    MOV BX, AX        ; save clusters
Disk_Info PROC
    MOV AX, CX        ; clusters
    MOV CX, AX        ; clusters
    MOV AX, AX        ; clusters

    ; To simplify, use this formula: Free KB = CX * AX * BX / 1024
    ; Use 16-bit multiply: AX * AX -> DX:AX
    MOV AX, CX        ; AX = clusters
    MOV BX, AX        ; BX = sectors/cluster (AX returned from AH=36h)
    MUL BX            ; DX:AX = AX * BX
    MOV BX, AX        ; save lower word
    ; Multiply by bytes per sector
    MOV AX, BX
    MOV BX, DX        ; previous DX
    MOV SI, AX
    ; Divide by 1024
    MOV AX, SI
    MOV DX, 0
    MOV BX, 1024
    DIV BX            ; AX = Free KB

    ; Print value
    MOV AX, AX
    CALL PrintNumber

    ; New line
    MOV DL, 13
    MOV AH, 02h
    INT 21h
    MOV DL, 10
    INT 21h

    CALL WaitKey
    JMP MainLoop

Disk_Info ENDP

; ----------------------------------------- 
; DOS Info Procedure (Stub)
; ----------------------------------------- 
DOS_Info PROC
    CALL ClearScreen
    MOV DX, OFFSET dosMsg
    CALL PrintString
    CALL WaitKey
    JMP MainLoop
DOS_Info ENDP


; -----------------------------------------
; Helper Procedures
; -----------------------------------------
PrintNumber2 PROC
    ; Input AL = number 0-99
    MOV AH, 0
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    ADD AH, 0
    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    RET
PrintNumber2 ENDP

PrintNumber4 PROC
    ; Input AX = number 0-9999
    MOV BX, 1000
    DIV BX
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    MOV AX, DX
    MOV BX, 100
    DIV BX
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    MOV AX, DX
    MOV BX, 10
    DIV BX
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    RET
PrintNumber4 ENDP

PrintNumber PROC
    ; Simple number printer for AX
    ; Converts 0-65535 to decimal (max 5 digits)
    ; Uses numBuffer
    PUSH AX
    MOV CX, 0
    MOV SI, OFFSET numBuffer+5
    MOV BX, 10
PNLoop:
    XOR DX, DX
    DIV BX
    DEC SI
    ADD DL, '0'
    MOV [SI], DL
    INC CX
    CMP AX, 0
    JNZ PNLoop
    MOV DI, SI
PrintPNLoop:
    MOV DL, [DI]
    MOV AH, 02h
    INT 21h
    INC DI
    LOOP PrintPNLoop
    POP AX
    RET
PrintNumber ENDP

END MAIN

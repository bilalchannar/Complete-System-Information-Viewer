.MODEL SMALL
.STACK 100h

.DATA
    title_str       DB 'SYSTEM INFORMATION VIEWER v1.0$'
    menu_title      DB 'SELECT INFORMATION TO VIEW:$'
    opt1            DB '1. CPU Type$'
    opt2            DB '2. Memory Information$'
    opt3            DB '3. Video Card Type$'
    opt4            DB '4. DOS Version$'
    opt5            DB '5. System Date$'
    opt6            DB '6. View All$'
    opt0            DB '0. Exit$'
    prompt_str      DB 'Choice: $'
    press_key       DB 'Press any key...$'
    
    cpu_lbl         DB 'CPU Type    : $'
    mem_lbl         DB 'Base Memory : $'
    ext_lbl         DB 'Extended Memory  : $'
    vid_lbl         DB 'Video Card  : $'
    dos_lbl         DB 'DOS Version : $'
    date_lbl        DB 'Date        : $'
    
    cpu_8088        DB '8088/8086$'
    cpu_286         DB '80286$'
    cpu_386         DB '80386+$'
    vid_vga         DB 'VGA$'
    vid_ega         DB 'EGA$'
    vid_cga         DB 'CGA$'
    
    num_buf         DB 10 DUP('$')
    kb_str          DB ' KB$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    
menu_loop:
    CALL DRAW_MENU
    MOV AH, 01h
    INT 21h
    
    CMP AL, '0'
    JE exit_prog
    CMP AL, '1'
    JE opt_cpu
    CMP AL, '2'
    JE opt_mem
    CMP AL, '3'
    JE opt_vid
    CMP AL, '4'
    JE opt_dos
    CMP AL, '5'
    JE opt_dt
    CMP AL, '6'
    JE opt_all
    JMP menu_loop

opt_cpu:
    CALL CLEAR_SCR
    MOV DH, 10
    MOV DL, 10
    CALL SET_CUR
    LEA DX, cpu_lbl
    CALL PRINT_STR
    CALL GET_CPU
    CALL WAIT_KEY
    JMP menu_loop

opt_mem:
    CALL CLEAR_SCR
    MOV DH, 9
    MOV DL, 10
    CALL SET_CUR
    LEA DX, mem_lbl
    CALL PRINT_STR
    CALL GET_MEM
    MOV DH, 11
    MOV DL, 10
    CALL SET_CUR
    LEA DX, ext_lbl
    CALL PRINT_STR
    CALL GET_EXT
    CALL WAIT_KEY
    JMP menu_loop

opt_vid:
    CALL CLEAR_SCR
    MOV DH, 10
    MOV DL, 10
    CALL SET_CUR
    LEA DX, vid_lbl
    CALL PRINT_STR
    CALL GET_VID
    CALL WAIT_KEY
    JMP menu_loop

opt_dos:
    CALL CLEAR_SCR
    MOV DH, 10
    MOV DL, 10
    CALL SET_CUR
    LEA DX, dos_lbl
    CALL PRINT_STR
    CALL GET_DOS
    CALL WAIT_KEY
    JMP menu_loop

opt_dt:
    CALL CLEAR_SCR
    MOV DH, 10
    MOV DL, 10
    CALL SET_CUR
    LEA DX, date_lbl
    CALL PRINT_STR
    CALL GET_DATE
    CALL WAIT_KEY
    JMP menu_loop

opt_all:
    CALL CLEAR_SCR
    MOV DH, 4
    MOV DL, 10
    CALL SET_CUR
    LEA DX, cpu_lbl
    CALL PRINT_STR
    CALL GET_CPU
    
    MOV DH, 5
    MOV DL, 10
    CALL SET_CUR
    LEA DX, mem_lbl
    CALL PRINT_STR
    CALL GET_MEM
    
    MOV DH, 6
    MOV DL, 10
    CALL SET_CUR
    LEA DX, ext_lbl
    CALL PRINT_STR
    CALL GET_EXT
    
    MOV DH, 7
    MOV DL, 10
    CALL SET_CUR
    LEA DX, vid_lbl
    CALL PRINT_STR
    CALL GET_VID
    
    MOV DH, 8
    MOV DL, 10
    CALL SET_CUR
    LEA DX, dos_lbl
    CALL PRINT_STR
    CALL GET_DOS
    
    MOV DH, 9
    MOV DL, 10
    CALL SET_CUR
    LEA DX, date_lbl
    CALL PRINT_STR
    CALL GET_DATE
    
    CALL WAIT_KEY
    JMP menu_loop

exit_prog:
    MOV AH, 06h
    MOV AL, 00h
    MOV BH, 07h       
    MOV CX, 0000h
    MOV DX, 184Fh
    INT 10h

    MOV AH, 02h
    MOV BH, 0
    MOV DH, 0
    MOV DL, 0
    INT 10h
    MOV AH, 4Ch
    INT 21h
MAIN ENDP

DRAW_MENU PROC
    CALL CLEAR_SCR
    MOV DH, 2
    MOV DL, 20
    CALL SET_CUR
    LEA DX, title_str
    CALL PRINT_STR
    
    MOV DH, 5
    MOV DL, 25
    CALL SET_CUR
    LEA DX, opt1
    CALL PRINT_STR
    
    MOV DH, 6
    MOV DL, 25
    CALL SET_CUR
    LEA DX, opt2
    CALL PRINT_STR
    
    MOV DH, 7
    MOV DL, 25
    CALL SET_CUR
    LEA DX, opt3
    CALL PRINT_STR
    
    MOV DH, 8
    MOV DL, 25
    CALL SET_CUR
    LEA DX, opt4
    CALL PRINT_STR
    
    MOV DH, 9
    MOV DL, 25
    CALL SET_CUR
    LEA DX, opt5
    CALL PRINT_STR
    
    MOV DH, 10
    MOV DL, 25
    CALL SET_CUR
    LEA DX, opt6
    CALL PRINT_STR
    
    MOV DH, 12
    MOV DL, 25
    CALL SET_CUR
    LEA DX, opt0
    CALL PRINT_STR
    
    MOV DH, 15
    MOV DL, 25
    CALL SET_CUR
    LEA DX, prompt_str
    CALL PRINT_STR
    RET
DRAW_MENU ENDP

GET_CPU PROC
    PUSHF
    POP AX
    AND AX, 0FFFh
    PUSH AX
    POPF
    PUSHF
    POP BX
    AND BX, 0F000h
    CMP BX, 0F000h
    JE is_8086
    MOV AX, 0F000h
    PUSH AX
    POPF
    PUSHF
    POP BX
    AND BX, 0F000h
    JZ is_286
    LEA DX, cpu_386
    JMP print_cpu
is_286:
    LEA DX, cpu_286
    JMP print_cpu
is_8086:
    LEA DX, cpu_8088
print_cpu:
    CALL PRINT_STR
    RET
GET_CPU ENDP

GET_MEM PROC
    INT 12h
    CALL NUM_TO_STR
    LEA DX, num_buf
    CALL PRINT_STR
    LEA DX, kb_str
    CALL PRINT_STR
    RET
GET_MEM ENDP

GET_EXT PROC
    MOV AH, 88h
    INT 15h
    JC no_ext
    CALL NUM_TO_STR
    LEA DX, num_buf
    CALL PRINT_STR
    LEA DX, kb_str
    CALL PRINT_STR
    RET
no_ext:
    MOV AH, 02h
    MOV DL, '0'
    INT 21h
    LEA DX, kb_str
    CALL PRINT_STR
    RET
GET_EXT ENDP

GET_VID PROC
    MOV AH, 12h
    MOV BL, 10h
    INT 10h
    CMP BL, 10h
    JNE has_ega_vga
    LEA DX, vid_cga
    JMP print_vid
has_ega_vga:
    MOV AX, 1A00h
    INT 10h
    CMP AL, 1Ah
    JNE is_ega
    LEA DX, vid_vga
    JMP print_vid
is_ega:
    LEA DX, vid_ega
print_vid:
    CALL PRINT_STR
    RET
GET_VID ENDP

GET_DOS PROC
    MOV AH, 30h
    INT 21h
    PUSH AX
    XOR AH, AH
    CALL NUM_TO_STR
    LEA DX, num_buf
    CALL PRINT_STR
    MOV AH, 02h
    MOV DL, '.'
    INT 21h
    POP AX
    MOV AL, AH
    XOR AH, AH
    CALL NUM_TO_STR
    LEA DX, num_buf
    CALL PRINT_STR
    RET
GET_DOS ENDP

GET_DATE PROC
    MOV AH, 2Ah
    INT 21h
    PUSH CX
    PUSH DX
    MOV AL, DL
    XOR AH, AH
    CALL NUM_TO_STR
    LEA DX, num_buf
    CALL PRINT_STR
    MOV AH, 02h
    MOV DL, '-'
    INT 21h
    POP DX
    PUSH DX
    MOV AL, DH
    XOR AH, AH
    CALL NUM_TO_STR
    LEA DX, num_buf
    CALL PRINT_STR
    MOV AH, 02h
    MOV DL, '-'
    INT 21h
    POP DX
    POP CX
    MOV AX, CX
    CALL NUM_TO_STR
    LEA DX, num_buf
    CALL PRINT_STR
    RET
GET_DATE ENDP

WAIT_KEY PROC
    MOV DH, 20
    MOV DL, 20
    CALL SET_CUR
    LEA DX, press_key
    CALL PRINT_STR
    MOV AH, 00h
    INT 16h
    RET
WAIT_KEY ENDP

CLEAR_SCR PROC
    MOV AH, 06h
    MOV AL, 00h
    MOV BH, 3Fh
    MOV CX, 0000h
    MOV DX, 184Fh
    INT 10h
    RET
CLEAR_SCR ENDP

SET_CUR PROC
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    RET
SET_CUR ENDP

PRINT_STR PROC
    MOV AH, 09h
    INT 21h
    RET
PRINT_STR ENDP

NUM_TO_STR PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    LEA DI, num_buf
    MOV CX, 0
    MOV BX, 10
conv_loop:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE conv_loop
store_loop:
    POP DX
    ADD DL, '0'
    MOV [DI], DL
    INC DI
    LOOP store_loop
    MOV BYTE PTR [DI], '$'
    POP DX
    POP CX
    POP BX
    POP AX
    RET
NUM_TO_STR ENDP

END MAIN
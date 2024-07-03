section .data
    newline db 10, 0
    getArgvErrorIndexOutOfRange db "<ERROR>:(getArgvErrorIndexOutOfRange)", 10, 0

section .bss
    digitSpace resb 100
    digitSpacePos resb 8
    printSpace resb 8

    argc resb 8
    argv resb 8

%macro print 1
    mov rax, %1
    mov [printSpace], rax
    mov rbx, 0
%%printLoop:
    mov cl, [rax]
    cmp cl, 0
    je %%endPrintLoop
    inc rbx
    inc rax
    jmp %%printLoop
%%endPrintLoop:
    mov rax, 1
    mov rdi, 1
    mov rsi, [printSpace]
    mov rdx, rbx
    syscall
%endmacro
 
%macro printVal 1
    mov rax, %1
%%printRAX:
    mov rcx, digitSpace
    mov rbx, 10
    mov [rcx], rbx
    inc rcx
    mov [digitSpacePos], rcx
 
%%printRAXLoop:
    mov rdx, 0
    mov rbx, 10
    div rbx
    push rax
    add rdx, 48
 
    mov rcx, [digitSpacePos]
    mov [rcx], dl
    inc rcx
    mov [digitSpacePos], rcx
    
    pop rax
    cmp rax, 0
    jne %%printRAXLoop
 
%%printRAXLoop2:
    mov rcx, [digitSpacePos]
 
    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    mov rdx, 1
    syscall
 
    mov rcx, [digitSpacePos]
    dec rcx
    mov [digitSpacePos], rcx
 
    cmp rcx, digitSpace
    jge %%printRAXLoop2
 
%endmacro

%macro printError 1
    mov rax, %1
    mov [printSpace], rax
    mov rbx, 0
%%printLoop:
    mov cl, [rax]
    cmp cl, 0
    je %%endPrintLoop
    inc rbx
    inc rax
    jmp %%printLoop
%%endPrintLoop:
    mov rax, 1
    mov rdi, 2
    mov rsi, [printSpace]
    mov rdx, rbx
    syscall
%endmacro

%macro exit 1
    mov rax, 60
    mov rdi, %1
    syscall
%endmacro

%macro setArgcArgv 0
    mov rax, [rsp]
    mov [argc], rax

    mov rax, rsp
    add rax, 8
    mov [argv], rax
%endmacro

%macro getArgv 1
    mov rax, %1
    cmp rax, [argc]
    jge %%getArgvErrorIndexOutOfRange
    cmp rax, 0
    jl %%getArgvErrorIndexOutOfRange

    mov rbx, rsp
    mov rsp, [argv]
    mov rax, %1
    mov rcx, 8
    mul rcx
    add rax, rsp
    mov rsp, rax
    mov rax, [rsp]
    mov rsp, rbx
    jmp %%getArgvEnd

    %%getArgvErrorIndexOutOfRange:

    printError getArgvErrorIndexOutOfRange
    exit 1

    %%getArgvEnd:
%endmacro
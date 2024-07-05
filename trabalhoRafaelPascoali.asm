; nasm -f elf64 trabalhoRafaelPascoali.asm ; gcc -m64 -no-pie trabalhoRafaelPascoali.o -o trabalhoRafaelPascoali.x
section .data
    section .data
    strCtrl2: db "%f",10,0
    strCtrl: db "%f %c %f",10,0
    strOla: db "insira a operação desejada: (formato x op y)", 10,0
    strOla2: db "operações: a - Adição, s - subtração, m - multiplicação,  d - divisão, e - exponenciação (insira 2 vezes)", 10,0
    strError: db "%lf %c %lf = Funcionalidade não disponível", 10, 0 ; 
    strSuccess: db "%lf %c %lf = %lf",10,0
    strArqv: db "saida.txt",0
    strModo: db "a",0

section .bss
    x : resd 1
    op : resb 1
    y : resd 1
    resultado: resd 1
    fileH : resd 1

section .text
    global main
    extern printf
    extern scanf
    extern fopen
    extern fprintf
    extern fclose

main:
    push rbp
    mov rbp, rsp ;StackFrame   

    xor rax, rax
    mov rdi, strOla ;printf("insira a operação desejada: (formato x op y)")
    call printf 
    
    xor rdi, rdi ;limpar rdi
    mov rdi, strOla2   ;printf("operações: a - Adição, s - subtração, m - multiplicação,  d - divisão, e - exponenciação")
    call printf
    xor rdi, rdi
  
    xor rax, rax
    mov rdi, strCtrl
    lea rsi, [x] ;passar parametros
    lea rdx, [op]
    lea rcx, [y]
    call scanf ;pede do teclado 2 vezes por algum motivo, o que conta é o primeiro
         
    movss xmm0, [x]  ;guarda cada variável em xmm0 e xmm1
    movss xmm1, [y]
    mov bl, [op] ;guarda caracter em bl
    
    ; identificar operação
    cmp bl, 0x61;= a , 0x2b = +
    je funcsoma 
    cmp bl, 0x73;= s , 0x2d = -
    je funcsub
    cmp bl, 0x6d;= m , 0x2a = *
    je funcmul
    cmp bl, 0x64;= d , 0x2f = /
    je funcdiv
    cmp bl, 0x65;= e , 0x5e = ^
    je funcexpo
    jmp funcerro ; se não for nenhum, erro

funcsoma:
    mov word [op], 0x2b
    call adicao
    jmp funcsuccess ;pula para printar retorno da função

funcsub:
    mov word [op], 0x2d
    call subtracao
    jmp funcsuccess

funcmul:
    mov word [op], 0x2a
    call multiplicacao
    jmp funcsuccess

funcdiv:
    mov word [op], 0x2f
    cvtss2si r9, xmm1
    cmp r9, 0 ;checa se a divisão é por 0
    je funcerro ;se sim, erro
    call divisao
    jmp funcsuccess

funcexpo:
    mov word [op], 0x5e
    cvtss2si r9, xmm1 ;converte expoente para inteiro e manda para r9
    cmp r9, 0 ;compara expoente com 0
    jl funcerro ;se expoente for menor que 0, erro
    je funcexpo0 ; se expoente for igual a 0, retorna 1
    cmp r9, 1 ; se expoente for igual a 1, retorna base
    je funcsuccess
    call exponenciacao
    jmp funcsuccess

funcexpo0:
    inc r9 ; add +1 para r9, que é 0
    cvtsi2ss xmm0, r9 ;converte para float e manda para xmm0
    jmp funcsuccess ;printa
    
funcsuccess:
    movss [resultado], xmm0 ;retorno vai para a variável resultado
b1: 
    mov rdi, strArqv
    mov rsi, strModo ;fopen("saida.txt","a")
    call fopen
    mov [fileH], rax
b2:
    movss xmm2, [resultado] ;manda retorno da funções para xmm2 
    movss xmm0, [x]  ;guarda cada variável em xmm0 e xmm1
    movss xmm1, [y]
b3:
    mov rdi, op
    lea rsi, [fileH]
    call escrevesolucaoOK
    jmp fim

funcerro:
 
    mov rdi, strArqv
    mov rsi, strModo ;fopen("saida.txt","a")
    call fopen
    mov [fileH], rax
    movss xmm0, [x]  ;guarda cada variável em xmm0 e xmm1
    movss xmm1, [y]
    mov rdi, op
    lea rsi, [fileH]
    call escrevesolucaoNOTOK
    
fim:
    mov rsp, rbp
    pop rbp ;DestackFrame

    mov rax, 60   
    mov rdi, 0
    syscall

adicao:

    push rbp
    mov rbp, rsp ;StackFrame   
    
    addss xmm0, xmm1

    mov rsp, rbp
    pop rbp ;DestackFrame
    
    ret

multiplicacao:

    push rbp
    mov rbp, rsp

    mulss xmm0, xmm1

    mov rsp, rbp
    pop rbp ;DestackFrame
    
    ret

subtracao:
    push rbp
    mov rbp, rsp
 
    subss xmm0, xmm1
    
    mov rsp, rbp
    pop rbp

    ret

divisao:
    push rbp
    mov rbp, rsp
 
    divss xmm0, xmm1
    
    mov rsp, rbp
    pop rbp

    ret

exponenciacao:
    push rbp
    mov rbp, rsp

    xor r9, r9
    xor r8, r8 ; índice
    mov r8, 1 ;indice começa em 1, porque ja tratamos expoentes iguais a 1 
    movss xmm2, xmm0 ;auxiliar
    cvtss2si r9, xmm1 ;expoente
loop:
   
    mulss xmm0, xmm2
    inc r8
    cmp r8,r9 ;compara indice atual com expoente
    jl loop ;se for menor, multiplica de novo
   
    mov rsp, rbp
    pop rbp

    ret

escrevesolucaoOK:
    push rbp
    mov rbp, rsp
b4:    
    cvtss2sd xmm0, xmm0 ;conversão de parametros para double
    cvtss2sd xmm1, xmm1
    cvtss2sd xmm2, xmm2

    mov rax, 3 ; 3 floats a serem escritos 
    mov rdi, [fileH] 
    mov rsi, strSuccess
    mov rdx, [op]
b5:
    call fprintf ; fprinf(arquivo, "%f %c %f = %f", x, op, y, resultado)
b6:
    mov rdi, [fileH]
    call fclose    ;fclose(arquivo)

    mov rsp, rbp
    pop rbp

    ret

escrevesolucaoNOTOK:
    push rbp
    mov rbp, rsp

    cvtss2sd xmm0, xmm0 ;conversão de parametros para double
    cvtss2sd xmm1, xmm1

    mov rax, 2 ;2 floats a serem impressos
    mov rdi, [fileH]
    mov rsi, strError
    mov rdx, [op]
    call fprintf ;fprintf(arquivo,"%f %C %f = funcionalidade não disponível",x,op,y)

    mov rdi, [fileH]
    call fclose

    mov rsp, rbp
    pop rbp

    ret

        


section .text 
global _main 
extern _printf


_main: 
  
  mov rsi, qword msg
  mov rdx, len
  call sysout

  call print_timestamp
  times 1000000 call parse
  call print_timestamp
  call print_parsed
 
  call exit





parse:
  xor rax,rax ;state: 0 - in tag, 1 - in value
  mov rsi, qword msg ; current offset
  mov rdi, rsi ;begging token offset
  mov r8, '='  ; sep 1
  mov r9, 1    ; sep 2
  xor r10,r10  ; current tag

  start:
    inc rsi
    cmp byte [rsi], 0
    je end

    cmp byte [rsi], r8b
    jne not_eq
      ; this is '='
      mov  rax, 1
      ;curr tag is between rdi and rsi
      ;calc tag, in is an integer and store in r10
      call atoi
      mov  rdi, rsi
      inc  rdi
      jmp start

    not_eq:
      cmp byte[rsi], 1
      jne not_sep
        ; this is 0x01
        mov rax, 0
        ;curr value is between rdi and rsi
        ;save value
        ;empty tag


        ;push rsi
        ;mov  rsi, r10
        ;call print_number
        ;pop  rsi

        ;push rsi
        ;push rdi
        ;sub  rsi, rdi
        ;call print_number
        ;pop  rdi
        ;pop  rsi

        ;push rsi
        ;push rdi
        ;mov  rsi, rdi
        ;call print_string
        ;pop  rdi
        ;pop  rsi

        lea r13, [parsed_message wrt rip]
        imul r10, 16
        add r13, r10
        mov [r13], rdi
        mov [r13+8], rsi

        mov  rdi, rsi
        inc  rdi
        jmp start

    not_sep:
      ;continue scan

      jmp start
  end:
    ;end of msg processing
  ret

print_parsed:
  push rsi
  push r12
  push r13
  
  lea r13, [parsed_message wrt rip]
  xor r12, r12

  ploop:
    mov rsi, r12
    call print_number
    mov rsi, [r13]
    call print_number

    add r13, 16
    add r12, 1
    cmp r12, 1000
    jl  ploop

  pop r13
  pop r12
  pop rsi
  ret


;
;
;

atoi:
  xor r10, r10; result will be in r10
  xor r12, r12; current byte

atoi_start:
  mov r12b, byte [rdi]
  sub r12b, 0x30

  imul r10, 10
  add  r10, r12

  inc rdi
  cmp rdi, rsi
  jne atoi_start

  ret

exit:
   mov    rdi,0 
   mov    rax,0x2000001 
   syscall 
   ret


timestamp:
  cpuid
  rdtsc
  shl rdx, 32
  or rax, rdx
  ret

;rdx - length
;rsi - buffer for mac, rcx for linux
sysout:
  push rdi
  push rax
  mov rdi, 1
  mov rax, 0x2000004
  syscall
  pop rax
  pop rdi
  ret


;rsi - number
print_number:
  push rax
  push rcx
  push rdi
  push rsi
  push rdx
  push r8
  push r9
  push r10
  push r12

  xor  rax, rax
  mov  rdi,  qword num_format
  call _printf
  
  pop  r12
  pop  r10
  pop  r9
  pop  r8
  pop  rdx
  pop  rsi
  pop  rdi
  pop  rcx
  pop  rax

  ret


;rsi - string
print_string:
  push rax
  push rcx
  push rdi
  push rsi
  push rdx
  push r8
  push r9
  push r10
  push r12

  xor  rax, rax
  mov  rdi,  qword str_format
  call _printf
  
  pop  r12
  pop  r10
  pop  r9
  pop  r8
  pop  rdx
  pop  rsi
  pop  rdi
  pop  rcx
  pop  rax

  ret


print_timestamp:
  call timestamp
  mov  rsi, rax
  call print_number
  ret


section .data
found   db      "found",0xa 
msg     db      "8=FIX.4.2",1,"35=D",1,"38=100", 1, "44=12.135", 1, "18=1", 1, "49=ABC",1 , "56=DEF",1, "115=BUBU", 1, "998=HA", 1, 0 , 0x0a
len     equ     $ - msg 
num_format db   "%ld", 0x0a, 0
str_format db   "%s" , 0x0a, 0
parsed_message  times 16000 db 0

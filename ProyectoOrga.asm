; =========================================================
; PROYECTO ORGANIZACION DEL COMPUTADOR
; Integrantes : Sebastianno Verrocchi, Luis Maduro 
; Seccion 002 / NRC: 26009
; =========================================================

.model small
.stack 100h

.data
    ; Mensajes de encabezado
    msgB    db 'Matriz B:', 13, 10, '$'
    msgAB   db 13, 10, 'Matriz A + B:', 13, 10, '$'
    msgABT  db 13, 10, 'Matriz A + B (traspuesto):', 13, 10, '$'
    newline db 13, 10, '$'

; DATOS INICIALES 
    N dw 8
    
    A dw 1, 0, 0, 0, 0, 0, 0, 0
      dw 2, 2, 0, 0, 0, 0, 0, 0
      dw 3, 3, 3, 0, 0, 0, 0, 0
      dw 4, 4, 4, 4, 0, 0, 0, 0
      dw 5, 5, 5, 5, 5, 0, 0, 0
      dw 6, 6, 6, 6, 6, 6, 0, 0
      dw 7, 7, 7, 7, 7, 7, 7, 0
      dw 8, 8, 8, 8, 8, 8, 8, 8

    B dw 0, 0, 0, 0, 0, 0, 0, 0
      dw 0, 0, 0, 0, 0, 0, 0, 0
      dw 0, 0, 0, 0, 0, 0, 0, 0
      dw 0, 0, 0, 0, 0, 0, 0, 0
      dw 0, 0, 0, 0, 0, 0, 0, 0
      dw 0, 0, 0, 0, 0, 0, 0, 0
      dw 0, 0, 0, 0, 0, 0, 0, 0
      dw 0, 0, 0, 0, 0, 0, 0, 0

.code
start:
    ; Inicializar segmento de datos
    mov ax, @data
    mov ds, ax

    ; ---------------------------------------------------------
    ; 1. Calcular B = -1 * Traspuesta(A)
    ; ---------------------------------------------------------
    xor si, si          ; SI = Fila (row) = 0
row_loop_1:
    cmp si, [N]
    jge end_calc_B
    xor di, di          ; DI = Columna (col) = 0
col_loop_1:
    cmp di, [N]
    jge end_col_loop_1

    ; Obtener A[col][row] (Traspuesta)
    ; Índice = (col * N + row) * 2
    mov ax, di
    imul [N]
    add ax, si
    shl ax, 1           ; Multiplicar por 2 (words)
    mov bx, ax
    mov ax, A[bx]       ; AX = A[col][row]
    neg ax              ; AX = -A[col][row] (Multiplicar por -1)

    ; Guardar en B[row][col]
    ; Índice = (row * N + col) * 2
    push ax
    mov ax, si
    imul [N]
    add ax, di
    shl ax, 1
    mov bx, ax
    pop ax
    mov B[bx], ax       ; B[row][col] = AX

    inc di
    jmp col_loop_1
end_col_loop_1:
    inc si
    jmp row_loop_1
end_calc_B:

    ; ---------------------------------------------------------
    ; 2. Imprimir Matriz B y Pausar
    ; ---------------------------------------------------------
    lea dx, msgB
    mov ah, 09h
    int 21h

    xor si, si
print_b_row:
    cmp si, [N]
    jge print_b_done
    xor di, di
print_b_col:
    cmp di, [N]
    jge print_b_next
    
    ; Leer B[row][col]
    mov ax, si
    imul [N]
    add ax, di
    shl ax, 1
    mov bx, ax
    mov ax, B[bx]
    call PRINT_NUM
    
    call PRINT_SPACE
    inc di
    jmp print_b_col
print_b_next:
    call PRINT_NEWLINE
    inc si
    jmp print_b_row
print_b_done:
    call PAUSE          ; Pausa luego de imprimir B

    ; ---------------------------------------------------------
    ; 3. Imprimir Matriz A + B y Pausar
    ; ---------------------------------------------------------
    lea dx, msgAB
    mov ah, 09h
    int 21h

    xor si, si
print_ab_row:
    cmp si, [N]
    jge print_ab_done
    xor di, di
print_ab_col:
    cmp di, [N]
    jge print_ab_next
    
    ; Índice = (row * N + col) * 2
    mov ax, si
    imul [N]
    add ax, di
    shl ax, 1
    mov bx, ax
    
    mov ax, A[bx]
    add ax, B[bx]       ; A[row][col] + B[row][col]
    call PRINT_NUM
    
    call PRINT_SPACE
    inc di
    jmp print_ab_col
print_ab_next:
    call PRINT_NEWLINE
    inc si
    jmp print_ab_row
print_ab_done:
    call PAUSE          ; Pausa luego de imprimir A + B

    ; ---------------------------------------------------------
    ; 4. Imprimir Matriz A + Traspuesta(B) y Pausar
    ; ---------------------------------------------------------
    lea dx, msgABT
    mov ah, 09h
    int 21h

    xor si, si
print_abt_row:
    cmp si, [N]
    jge print_abt_done
    xor di, di
print_abt_col:
    cmp di, [N]
    jge print_abt_next
    
    ; Índice A[row][col]
    mov ax, si
    imul [N]
    add ax, di
    shl ax, 1
    mov bx, ax
    mov ax, A[bx]       ; AX = A[row][col]
    
    ; Índice B[col][row] (Traspuesta de B)
    push ax
    mov ax, di
    imul [N]
    add ax, si
    shl ax, 1
    mov bx, ax
    pop ax
    
    add ax, B[bx]       ; AX = A[row][col] + B[col][row]
    call PRINT_NUM
    
    call PRINT_SPACE
    inc di
    jmp print_abt_col
print_abt_next:
    call PRINT_NEWLINE
    inc si
    jmp print_abt_row
print_abt_done:
    call PAUSE          ; Pausa final esperando tecla

    ; Finalizar programa
    mov ax, 4c00h
    int 21h

; =========================================================
; PROCEDIMIENTOS AUXILIARES
; =========================================================

; Pausar ejecucion hasta pulsar una tecla
PAUSE PROC
    push ax
    mov ah, 00h
    int 16h
    pop ax
    ret
PAUSE ENDP

; Imprimir un espacio
PRINT_SPACE PROC
    push ax
    push dx
    mov ah, 02h
    mov dl, ' '
    int 21h
    pop dx
    pop ax
    ret
PRINT_SPACE ENDP

; Imprimir un salto de línea
PRINT_NEWLINE PROC
    push ax
    push dx
    lea dx, newline
    mov ah, 09h
    int 21h
    pop dx
    pop ax
    ret
PRINT_NEWLINE ENDP

; Imprimir un número con signo de 16-bits almacenado en AX
PRINT_NUM PROC
    push ax
    push bx
    push cx
    push dx

    ; Verificar si es negativo
    cmp ax, 0
    jge es_positivo
    push ax
    mov ah, 02h
    mov dl, '-'         ; Imprimir signo negativo
    int 21h
    pop ax
    neg ax              ; Convertir a positivo para extraer dígitos
es_positivo:
    mov cx, 0
    mov bx, 10
extraer_digitos:
    xor dx, dx
    div bx              ; AX = cociente, DX = residuo
    push dx             ; Guardar dígito en pila
    inc cx
    cmp ax, 0
    jne extraer_digitos
imprimir_digitos:
    pop dx
    add dl, '0'         ; Convertir a ASCII
    mov ah, 02h
    int 21h
    loop imprimir_digitos

    pop dx
    pop cx
    pop bx
    pop ax
    ret
PRINT_NUM ENDP

end start
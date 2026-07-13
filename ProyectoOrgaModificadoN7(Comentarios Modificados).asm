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
    msgPause db 13, 10, '<pulse cualquier tecla>', 13, 10, '$'  

    ; DATOS INICIALES
    N dw 7
    
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
    mov ax, @data
    mov ds, ax

    ; ---------------------------------------------------------
    ; 1. Calcular B = -1 * Traspuesta(A)
    ; ---------------------------------------------------------
    xor si, si          ; SI = Fila (row) = 0
row_loop_1:
    cmp si, [N]
    jg end_calc_B       ; CAMBIO: JG en lugar de JGE para incluir N=7
    xor di, di          ; DI = Columna (col) = 0
col_loop_1:
    cmp di, [N]
    jg end_col_loop_1   ; CAMBIO: JG

    ; Obtener A[col][row] (Traspuesta)
    ; Índice = (col * (N+1) + row) * 2
    mov ax, di
    mov cx, [N]
    inc cx              ; CX = 8 (Ancho real de la matriz)
    imul cx
    add ax, si
    shl ax, 1           ; Multiplicar por 2 (words)
    mov bx, ax
    mov ax, A[bx]       ; AX = A[col][row]
    neg ax              ; Multiplicar por -1

    ; Guardar en B[row][col]
    push ax
    mov ax, si
    mov cx, [N]
    inc cx              ; CX = 8
    imul cx
    add ax, di
    shl ax, 1
    mov bx, ax
    pop ax
    mov B[bx], ax

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
    jg print_b_done
    xor di, di
print_b_col:
    cmp di, [N]
    jg print_b_next
    
    mov ax, si
    mov cx, [N]
    inc cx
    imul cx
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
    call PAUSE

    ; ---------------------------------------------------------
    ; 3. Imprimir Matriz A + B y Pausar
    ; ---------------------------------------------------------
    lea dx, msgAB
    mov ah, 09h
    int 21h

    xor si, si
print_ab_row:
    cmp si, [N]
    jg print_ab_done
    xor di, di
print_ab_col:
    cmp di, [N]
    jg print_ab_next
    
    mov ax, si
    mov cx, [N]
    inc cx
    imul cx
    add ax, di
    shl ax, 1
    mov bx, ax
    
    mov ax, A[bx]
    add ax, B[bx]
    call PRINT_NUM
    
    call PRINT_SPACE
    inc di
    jmp print_ab_col
print_ab_next:
    call PRINT_NEWLINE
    inc si
    jmp print_ab_row
print_ab_done:
    call PAUSE

    ; ---------------------------------------------------------
    ; 4. Imprimir Matriz A + Traspuesta(B) y Pausar
    ; ---------------------------------------------------------
    lea dx, msgABT
    mov ah, 09h
    int 21h

    xor si, si
print_abt_row:
    cmp si, [N]
    jg print_abt_done
    xor di, di
print_abt_col:
    cmp di, [N]
    jg print_abt_next
    
    ; ÍIndice A[row][col]
    mov ax, si
    mov cx, [N]
    inc cx
    imul cx
    add ax, di
    shl ax, 1
    mov bx, ax
    mov ax, A[bx]
    
    ; ÍIndice B[col][row] (Traspuesta de B)
    push ax
    mov ax, di
    mov cx, [N]
    inc cx
    imul cx
    add ax, si
    shl ax, 1
    mov bx, ax
    pop ax
    
    add ax, B[bx]
    call PRINT_NUM
    
    call PRINT_SPACE
    inc di
    jmp print_abt_col
print_abt_next:
    call PRINT_NEWLINE
    inc si
    jmp print_abt_row
print_abt_done:
    call PAUSE

    ; Finalizar programa
    mov ax, 4c00h
    int 21h

; =========================================================
; PROCEDIMIENTOS AUXILIARES
; =========================================================

PAUSE PROC
    push ax
    push dx
    
    ; Imprimir mensaje "<pulse cualquier tecla>"
    lea dx, msgPause
    mov ah, 09h
    int 21h
    
    ; Esperar tecla
    mov ah, 00h
    int 16h
    
    pop dx
    pop ax
    ret
PAUSE ENDP

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

PRINT_NUM PROC
    push ax
    push bx
    push cx
    push dx

    cmp ax, 0
    jge es_positivo
    push ax
    mov ah, 02h
    mov dl, '-'
    int 21h
    pop ax
    neg ax
es_positivo:
    mov cx, 0
    mov bx, 10
extraer_digitos:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne extraer_digitos
imprimir_digitos:
    pop dx
    add dl, '0'
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
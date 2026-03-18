; =============================================================================
; ARCHIVO: conversiones.asm
; DESCRIPCION: Modulos de transformacion, formateo y validacion de datos numericos.
;              Implementa aritmetica de 32 bits y simulacion de Punto Fijo.
; =============================================================================

; -----------------------------------------------------------------------------
; PROCEDIMIENTO: LeerYFormatearSaldo
; DESCRIPCION:   Captura la entrada estandar, valida la integridad de los 
;                caracteres (rechazando alfanumericos no validos) y estandariza
;                la cadena eliminando el separador decimal.
; POSTCONDICION: Genera una cadena numerica pura en 'buffer_limpio' con relleno
;                de ceros (padding) a la derecha para garantizar 4 decimales.
;                Activa 'error_entrada' en caso de detectar formato invalido.
; -----------------------------------------------------------------------------
LeerYFormatearSaldo proc
    
    ; Inicializacion de estado y contadores
    mov error_entrada, 0         
    mov len_limpio, 0

    ; Captura de cadena mediante servicios de DOS
    mov ah, 0Ah
    lea dx, buffer_teclado
    int 21h

    ; Verificacion de entrada nula (presionar Enter sin datos)
    mov cl,[buffer_teclado + 1] 
    mov ch, 0
    cmp cx, 0
    je ocurrio_error_formateo    

    lea si, buffer_teclado + 2   
    lea di, buffer_limpio        
    mov bh, 255                  ; Bandera de control: 255 indica ausencia de separador decimal

ciclo_filtrado:
    mov al, [si]
    
    ; Flexibilidad de interfaz: Aceptar estandar americano (.) o europeo (,)
    cmp al, '.'                  
    je encontro_punto
    cmp al, ','                  
    je encontro_punto
    
    ; Filtro de seguridad: Restriccion estricta a caracteres numericos
    cmp al, '0'
    jb ocurrio_error_formateo    ; Rechaza caracteres de control, espacios o signos
    cmp al, '9'
    ja ocurrio_error_formateo    ; Rechaza caracteres alfabeticos y simbolos especiales
    
    ; Almacenamiento del digito validado
    mov [di], al
    inc di
    inc len_limpio
    
    ; Control de longitud de la parte fraccionaria
    cmp bh, 255
    je siguiente_char
    inc bh                       
    cmp bh, 4                    ; Truncamiento automatico despues del cuarto decimal
    je fin_lectura_str
    jmp siguiente_char

encontro_punto:
    ; Prevencion de multiples separadores (ej. "15.5.0")
    cmp bh, 255
    jne ocurrio_error_formateo   
    mov bh, 0                    

siguiente_char:
    inc si
    loop ciclo_filtrado

fin_lectura_str:
    ; Evaluacion de necesidad de relleno de ceros (ej. entero puro "15")
    cmp bh, 255                  
    jne verificar_ceros
    mov bh, 0

verificar_ceros:
    ; Aplicacion de padding de ceros hasta completar la escala de Punto Fijo
    cmp bh, 4                    
    jge fin_formateo
    mov al, '0'
    mov [di], al                 
    inc di
    inc len_limpio
    inc bh
    jmp verificar_ceros

ocurrio_error_formateo:
    mov error_entrada, 1         ; Dispara excepcion de validacion

fin_formateo:
    ret
LeerYFormatearSaldo endp


; -----------------------------------------------------------------------------
; PROCEDIMIENTO: ConvertirCadenaA32Bits
; DESCRIPCION:   Transforma el buffer estandarizado en un valor matematico 
;                binario utilizando registros emparejados.
; VALIDACIONES:  Implementa verificacion de Carry Flag para prevenir y atajar 
;                desbordamientos de enteros (Integer Overflow).
; POSTCONDICION: Resultado absoluto almacenado en 'val_alto' y 'val_bajo'.
; -----------------------------------------------------------------------------
ConvertirCadenaA32Bits proc
    
    ; Interrupcion del flujo si el modulo previo reporto anomalias
    cmp error_entrada, 1
    je fin_conversion

    mov val_alto, 0
    mov val_bajo, 0

    mov cl, len_limpio
    mov ch, 0
    cmp cx, 0
    je fin_conversion
    
    ; Proteccion de hardware: Un DWord sin signo soporta un maximo de 10 digitos
    cmp cx, 10
    jg ocurrio_error_mate

    lea si, buffer_limpio

ciclo_matematico:
    mov bl, [si]
    sub bl, 30h                  ; Conversion logica de ASCII a digito binario
    mov bh, 0
    
    ; Desplazamiento posicional (multiplicacion por 10) de la parte baja
    mov ax, val_bajo
    mov dx, 10
    mul dx
    mov val_bajo, ax
    push dx                      ; Preservacion del acarreo saliente
    
    ; Desplazamiento posicional de la parte alta
    mov ax, val_alto
    mov dx, 10
    mul dx
    
    ; Verificacion de perdida de datos por rebase de capacidad
    cmp dx, 0
    jne sacar_pila_y_error       
    
    pop dx
    add ax, dx
    jc ocurrio_error_mate        ; Excepcion por desbordamiento en suma de acarreo
    mov val_alto, ax
    
    ; Adicion del nuevo digito con propagacion al registro superior
    mov al, bl
    mov ah, 0
    add val_bajo, ax
    adc val_alto, 0
    jc ocurrio_error_mate        ; Excepcion por desbordamiento critico final
    
    inc si
    loop ciclo_matematico
    jmp fin_conversion

sacar_pila_y_error:
    pop dx                       ; Restauracion de la pila previo al aborto de rutina

ocurrio_error_mate:
    mov error_entrada, 1         ; Disparo de excepcion de sobrepaso de limite 
    mov val_alto, 0              ; Limpieza de memoria para evitar estados corruptos
    mov val_bajo, 0

fin_conversion:
    ret
ConvertirCadenaA32Bits endp


; -----------------------------------------------------------------------------
; PROCEDIMIENTO: ImprimirSaldo
; DESCRIPCION:   Convierte el registro binario segmentado en caracteres ASCII 
;                imprimibles, inyectando el separador decimal en la posicion 
;                correspondiente para mantener la ilusion visual de Punto Fijo.
; -----------------------------------------------------------------------------
ImprimirSaldo proc
    
    mov cx, 0                    ; Inicializacion del contador de pila

ciclo_extraccion:
    ; Division sucesiva por 10 sobre estructura de 32 bits simulada
    mov ax, val_alto
    mov dx, 0
    mov bx, 10
    div bx
    mov val_alto, ax
    
    mov ax, val_bajo
    div bx
    mov val_bajo, ax
    
    push dx                      ; Almacenamiento del residuo (digito extraido)
    inc cx
    
    ; Evaluacion logica para determinar si el cociente total es cero
    mov ax, val_alto
    mov bx, val_bajo
    or ax, bx
    jnz ciclo_extraccion
    
    ; Verificacion de formato: Se requiere un minimo de 5 digitos para "0.xxxx"
    cmp cx, 5
    jge ciclo_impresion
    
rellenar_ceros_pila:
    ; Inyeccion de ceros a la izquierda para montos inferiores a 1 unidad
    mov dx, 0
    push dx                      
    inc cx
    cmp cx, 5
    jl rellenar_ceros_pila

ciclo_impresion:
    ; Formateo visual de salida: Inyeccion del punto decimal
    cmp cx, 4                    
    jne imprimir_digito
    
    mov ah, 02h
    mov dl, '.'
    int 21h

imprimir_digito:
    ; Transcripcion de la pila a pantalla estandar
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop ciclo_impresion

    ret
ImprimirSaldo endp

; -----------------------------------------------------------------------------
; PROCEDIMIENTO: ImprimirNumero16
; DESCRIPCION:   Imprime un numero de 16 bits en decimal.
; PARAMETROS:    AX = numero a imprimir
; -----------------------------------------------------------------------------
ImprimirNumero16 proc
    push ax
    push bx
    push cx
    push dx

    mov bx, 10                   ; Divisor
    mov cx, 0                    ; Contador de digitos

    cmp ax, 0
    jne dividir
    ; Si es 0, imprimir 0
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp fin_imprimir_num

dividir:
    mov dx, 0
    div bx                       ; AX / 10, cociente en AX, residuo en DX
    push dx                      ; Guardar residuo
    inc cx
    cmp ax, 0
    jne dividir

imprimir_digitos:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop imprimir_digitos

fin_imprimir_num:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ImprimirNumero16 endp       

; -----------------------------------------------------------------------------
; PROCEDIMIENTO: LeerCadenaEntera
; DESCRIPCION:   Lee un numero entero (como un ID).
; -----------------------------------------------------------------------------
LeerCadenaEntera proc
    mov error_entrada, 0
    
    mov ah, 0Ah
    lea dx, buffer_teclado
    int 21h
    
    mov cl,[buffer_teclado + 1]
    mov ch, 0
    cmp cx, 0
    je ocurrio_error_entero
    
    lea si, buffer_teclado + 2
    lea di, buffer_limpio
    mov len_limpio, cl
    
ciclo_entero:
    mov al, [si]
    cmp al, '0'
    jb ocurrio_error_entero
    cmp al, '9'
    ja ocurrio_error_entero
    mov [di], al
    inc si
    inc di
    loop ciclo_entero
    ret
    
ocurrio_error_entero:
    mov error_entrada, 1
    ret
LeerCadenaEntera endp
; =============================================================================
; MODULOS DE PROCESAMIENTO
; =============================================================================
; Contiene las implementaciones estructurales de la logica de negocio.
; Nota: Este componente no debe definir segmentos (.data o .code) para evitar 
; colisiones de memoria durante la inclusion en el archivo principal.

; -----------------------------------------------------------------------------
; PROCEDIMIENTO: CrearCuenta
; DESCRIPCION:   Registra una nueva cuenta bancaria en la estructura de memoria.
; VALIDACIONES:  
;                - Comprueba disponibilidad de espacio (maximo 10 cuentas).
;                - Verifica mediante busqueda lineal que el numero no exista.
;                - Asegura que el saldo inicial sea mayor o igual a cero.
; POSTCONDICION: La cuenta queda almacenada y su estado se inicializa como Activa.
; -----------------------------------------------------------------------------
CrearCuenta proc
    ; 1. Pedir el numero de cuenta al usuario
    mov ah, 09h
    lea dx, msgPedirCuenta
    int 21h
    
    call LeerYFormatearSaldo
    call ConvertirCadenaA32Bits
    
    cmp error_entrada, 1
    je error_formato_cuenta
    
    ; Guardamos el numero digitado en DX para usarlo de referencia
    mov dx, val_bajo
    push dx ; Protegemos el numero en la pila

    ; 2. Verificar que la cuenta no exista previamente
    lea bx, db_cuentas
    mov cx, MAX_CUENTAS
check_existe:
    mov al, [bx + OFS_ESTADO]
    cmp al, 1
    jne skip_check
    mov ax, [bx + OFS_NUMERO]
    cmp ax, dx
    je error_existe
skip_check:
    add bx, TAMANO_REGISTRO
    loop check_existe

    ; 3. Buscar espacio libre (OFS_ESTADO == 0)
    lea bx, db_cuentas
    mov cx, MAX_CUENTAS
buscar_espacio:
    mov al, [bx + OFS_ESTADO]
    cmp al, 0
    je pedir_nombre_y_saldo
    add bx, TAMANO_REGISTRO
    loop buscar_espacio

    ; Si llega aqui, no hay espacio (Retornamos)
    pop dx
    mov ah, 09h
    lea dx, msgErrLleno
    int 21h
    ret

error_existe:
    pop dx
    mov ah, 09h
    lea dx, msgErrExiste
    int 21h
    ret

pedir_nombre_y_saldo:
    mov ah, 09h
    lea dx, msgPedirNombre
    int 21h

    push bx ; Proteger puntero de la cuenta actual
    lea di, [bx + OFS_NOMBRE] ; DI apuntara al offset del nombre en el arreglo
    mov cx, 20 ; Limite de 20 caracteres

leer_char:
    mov ah, 01h
    int 21h
    cmp al, 0Dh
    je fin_nombre
    mov [di], al ; Guardar la letra en el arreglo
    inc di
    loop leer_char

fin_nombre:
    mov byte ptr [di], '$' ; Agregar el terminador de cadena para imprimirlo despues
    pop bx
    
    ; 4. Pedir el saldo inicial
    push bx ; Protegemos la direccion de memoria encontrada
    
    mov ah, 09h
    lea dx, msgPedirMonto
    int 21h
    
    call LeerYFormatearSaldo
    call ConvertirCadenaA32Bits
    
    pop bx ; Recuperamos la direccion de memoria
    pop dx ; Recuperamos el ID de la cuenta

    cmp error_entrada, 1
    je error_monto_crear

    ; 5. Guardar todo en memoria
    mov byte ptr [bx + OFS_ESTADO], 1  ; Activar
    mov word ptr [bx + OFS_NUMERO], dx ; Guardar ID
    
    mov ax, val_bajo                   ; Guardar saldo (32 bits)
    mov word ptr [bx + OFS_SALDO], ax
    mov ax, val_alto
    mov word ptr [bx + OFS_SALDO + 2], ax
    
    mov ah, 09h
    lea dx, msgExito
    int 21h
    ret

error_monto_crear:
    mov ah, 09h
    lea dx, msgErrMonto
    int 21h
    ret
    
error_formato_cuenta:
    mov ah, 09h
    lea dx, msgErrFormato
    int 21h
    ret    
CrearCuenta endp

; -----------------------------------------------------------------------------
; PROCEDIMIENTO: DepositarDinero
; DESCRIPCION:   Incrementa el saldo de una cuenta existente.
; VALIDACIONES:  
;                - Localiza la cuenta ingresada por el usuario.
;                - Verifica que el estado de la cuenta sea Activa.
;                - Garantiza que el monto a depositar sea estrictamente positivo.
; POSTCONDICION: El saldo de la cuenta especifica se actualiza sumando el monto.
; -----------------------------------------------------------------------------
DepositarDinero proc
    ; 1. Pedir cuenta
    mov ah, 09h
    lea dx, msgPedirCuenta
    int 21h
    call LeerYFormatearSaldo
    call ConvertirCadenaA32Bits
    cmp error_entrada, 1
    je error_formato_cuenta_dep
    mov dx, val_bajo

    ; 2. Buscar cuenta
    lea bx, db_cuentas
    mov cx, MAX_CUENTAS
buscar_deposito:
    mov ax, [bx + OFS_NUMERO]
    cmp ax, dx
    je verificar_estado_dep
    add bx, TAMANO_REGISTRO
    loop buscar_deposito

    ; Si no encuentra el numero de cuenta
    mov ah, 09h
    lea dx, msgErrCuenta
    int 21h
    ret

verificar_estado_dep:
    mov al, [bx + OFS_ESTADO]
    cmp al, 1
    je cuenta_hallada_deposito
    
    ; Si existe pero esta inactiva (estado = 0)
    mov ah, 09h
    lea dx, msgErrInact
    int 21h
    ret

cuenta_hallada_deposito:
    ; 3. Pedir monto
    push bx ; Proteger memoria
    mov ah, 09h
    lea dx, msgPedirMonto
    int 21h
    call LeerYFormatearSaldo
    call ConvertirCadenaA32Bits
    pop bx  ; Recuperar memoria
    
    cmp error_entrada, 1
    je error_monto_dep
    
    ; 4. Sumar validando el desbordamiento de 32 bits (Carry Flag)
    mov ax, word ptr [bx + OFS_SALDO]
    mov cx, word ptr [bx + OFS_SALDO + 2] 

    add ax, val_bajo
    adc cx, val_alto
    
    jc error_overflow_deposito ; Si la bandera de acarreo se enciende, abortar

    ; Si no hay desbordamiento, guardamos los nuevos valores en la memoria
    mov word ptr [bx + OFS_SALDO], ax
    mov word ptr [bx + OFS_SALDO + 2], cx
    
    mov ah, 09h
    lea dx, msgExito
    int 21h
    ret
    
error_overflow_deposito:
    mov ah, 09h
    lea dx, msgErrOverflow
    int 21h
    ret
    
error_monto_dep:
    mov ah, 09h
    lea dx, msgErrMonto
    int 21h
    ret
    
error_formato_cuenta_dep:
    mov ah, 09h
    lea dx, msgErrFormato
    int 21h
    ret
DepositarDinero endp

; -----------------------------------------------------------------------------
; PROCEDIMIENTO: RetirarDinero
; DESCRIPCION:   Disminuye el saldo de una cuenta especifica.
; VALIDACIONES:  
;                - Localiza la cuenta ingresada por el usuario.
;                - Verifica que el estado de la cuenta sea Activa.
;                - Previene el sobregiro comprobando que el saldo actual sea 
;                  mayor o igual al monto solicitado.
; POSTCONDICION: El saldo se reduce. Despliega notificacion en caso de rechazo 
;                por fondos insuficientes.
; -----------------------------------------------------------------------------
RetirarDinero proc
    ; 1. Pedir cuenta
    mov ah, 09h
    lea dx, msgPedirCuenta
    int 21h
    call LeerYFormatearSaldo
    call ConvertirCadenaA32Bits
    cmp error_entrada, 1
    je error_formato_cuenta_ret
    mov dx, val_bajo

    ; 2. Buscar cuenta
    lea bx, db_cuentas
    mov cx, MAX_CUENTAS
buscar_retiro:
    mov ax, [bx + OFS_NUMERO]
    cmp ax, dx
    je verificar_estado_ret
    add bx, TAMANO_REGISTRO
    loop buscar_retiro

    mov ah, 09h
    lea dx, msgErrCuenta
    int 21h
    ret

verificar_estado_ret:
    mov al, [bx + OFS_ESTADO]
    cmp al, 1
    je cuenta_hallada_retiro
    
    mov ah, 09h
    lea dx, msgErrInact
    int 21h
    ret

cuenta_hallada_retiro:
    ; 3. Pedir monto
    push bx 
    mov ah, 09h
    lea dx, msgPedirMonto
    int 21h
    call LeerYFormatearSaldo
    call ConvertirCadenaA32Bits
    pop bx  
    
    cmp error_entrada, 1
    je error_monto_ret
    
    ; 4. Validar fondos (Comparar 32 bits)
    mov ax, word ptr [bx + OFS_SALDO + 2]
    cmp ax, val_alto
    jb fondos_insuficientes
    ja realizar_retiro
    
    mov ax, word ptr [bx + OFS_SALDO]
    cmp ax, val_bajo
    jb fondos_insuficientes

realizar_retiro:
    ; 5. Restar (SUB y SBB)
    mov ax, word ptr [bx + OFS_SALDO]
    sub ax, val_bajo
    mov word ptr [bx + OFS_SALDO], ax
    
    mov ax, word ptr [bx + OFS_SALDO + 2]
    sbb ax, val_alto
    mov word ptr [bx + OFS_SALDO + 2], ax
    
    mov ah, 09h
    lea dx, msgExito
    int 21h
    ret

fondos_insuficientes:
    mov ah, 09h
    lea dx, msgErrFondos
    int 21h
    ret

error_monto_ret:
    mov ah, 09h
    lea dx, msgErrMonto
    int 21h
    ret
    
error_formato_cuenta_ret:
    mov ah, 09h
    lea dx, msgErrFormato
    int 21h
    ret
RetirarDinero endp

; -----------------------------------------------------------------------------
; PROCEDIMIENTO: ConsultarSaldo
; DESCRIPCION:   Ejecuta una busqueda en memoria para localizar una cuenta 
;                mediante su numero identificador.
; POSTCONDICION: Despliega en pantalla el nombre del titular y el saldo actual 
;                formateado correctamente (incluyendo la simulacion de decimales).
; -----------------------------------------------------------------------------
ConsultarSaldo proc
    ; 1. Pedir cuenta
    mov ah, 09h
    lea dx, msgPedirCuenta
    int 21h
    call LeerYFormatearSaldo
    call ConvertirCadenaA32Bits
    cmp error_entrada, 1
    je error_formato_cuenta_cons
    mov dx, val_bajo

    ; 2. Buscar cuenta
    lea bx, db_cuentas
    mov cx, MAX_CUENTAS
buscar_consulta:
    mov ax, [bx + OFS_NUMERO]
    cmp ax, dx
    je verificar_estado_cons
    add bx, TAMANO_REGISTRO
    loop buscar_consulta

    ; Si no se encuentra
    mov ah, 09h
    lea dx, msgErrCuenta
    int 21h
    ret

verificar_estado_cons:
    mov al, [bx + OFS_ESTADO]
    cmp al, 1
    je cuenta_hallada_consulta
    
    mov ah, 09h
    lea dx, msgErrInact
    int 21h
    ret

cuenta_hallada_consulta:
    mov ah, 09h
    lea dx, msgNombreEs
    int 21h
    
    lea dx, [bx + OFS_NOMBRE]
    mov ah, 09h
    int 21h
    
    ; 3. Imprimir texto "El saldo es..."
    mov ah, 09h
    lea dx, msgSaldoEs
    int 21h

    ; 4. Preparar variables para ImprimirSaldo
    mov ax, word ptr [bx + OFS_SALDO]
    mov val_bajo, ax
    mov ax, word ptr [bx + OFS_SALDO + 2]
    mov val_alto, ax
    
    call ImprimirSaldo
    ret
    
error_formato_cuenta_cons:
    mov ah, 09h
    lea dx, msgErrFormato
    int 21h
    ret
ConsultarSaldo endp

; -----------------------------------------------------------------------------
; PROCEDIMIENTO: MostrarReporte
; DESCRIPCION:   Recorre la totalidad del arreglo de cuentas en memoria para 
;                generar estadisticas globales del sistema bancario.
; POSTCONDICION: Imprime en pantalla los siguientes metricas:
;                - Total de cuentas en estado Activa.
;                - Total de cuentas en estado Inactiva.
;                - Sumatoria del saldo de todas las cuentas registradas.
;                - Identificador de la cuenta con el saldo mas alto.
;                - Identificador de la cuenta con el saldo mas bajo.
; -----------------------------------------------------------------------------
MostrarReporte proc
    mov ah, 09h
    lea dx, msgConstruccion
    int 21h
    ret
MostrarReporte endp

; -----------------------------------------------------------------------------
; PROCEDIMIENTO: DesactivarCuenta
; DESCRIPCION:   Modifica el estado operativo de una cuenta especifica.
; VALIDACIONES:  
;                - Localiza la cuenta ingresada por el usuario.
;                - Bloquea la operacion si la cuenta ya se encuentra Inactiva.
; POSTCONDICION: El byte de estado de la cuenta en memoria cambia a Inactiva.
; -----------------------------------------------------------------------------
DesactivarCuenta proc
    mov ah, 09h
    lea dx, msgConstruccion
    int 21h
    ret
DesactivarCuenta endp
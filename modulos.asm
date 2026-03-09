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
    mov ah, 09h
    lea dx, msgConstruccion
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
    mov ah, 09h
    lea dx, msgConstruccion
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
    mov ah, 09h
    lea dx, msgConstruccion
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
    mov ah, 09h
    lea dx, msgConstruccion
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
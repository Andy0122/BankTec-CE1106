.model small
.stack 100h

.data
    ; =================================================================
    ; INCLUSION DE VARIABLES Y TEXTOS GLOBALES
    ; =================================================================
    include interfaz.asm    ; <-- Aqui se cargan todos los textos del menu
    
    include vars.asm        ; <-- Aqui se cargan las estructuras de memoria  
    
    
.code
main:
    ; Inicializacion del segmento de datos.
    mov ax, @data
    mov ds, ax

ciclo_principal: 
    push ax          ; Proteger el registro AX
    
    mov ax, 0003h    ; AH = 00h (Establecer modo de video)
    int 10h          ; Llamada a la interrupcion de video del BIOS
    
    pop ax           ; Restaurar el registro AX
    
    
    ; Despliegue del encabezado y opciones disponibles.
    mov ah, 09h
    lea dx, msgLogo
    int 21h

    mov ah, 09h
    lea dx, msgMenu
    int 21h

    ; Captura de entrada del usuario (caracter individual).
    mov ah, 01h
    int 21h
    
    ; Enrutamiento de ejecucion segun la seleccion.
    cmp al, '1'
    je op_crear
    cmp al, '2'
    je op_depositar
    cmp al, '3'
    je op_retirar
    cmp al, '4'
    je op_consultar
    cmp al, '5'
    je op_reporte
    cmp al, '6'
    je op_desactivar
    cmp al, '7'
    je op_salir  

    ; Manejo de excepcion para selecciones fuera de rango.
    mov ah, 09h
    lea dx, msgError
    int 21h
    jmp pausa_menu

; =====================================================================
; DELEGACION DE OPERACIONES
; =====================================================================
; Llamadas a los modulos especificos de logica de negocio.

op_crear:
    call CrearCuenta
    jmp pausa_menu 

op_depositar:
    call DepositarDinero
    jmp pausa_menu

op_retirar:
    call RetirarDinero
    jmp pausa_menu

op_consultar:
    call ConsultarSaldo
    jmp pausa_menu

op_reporte:
    call MostrarReporte
    jmp pausa_menu

op_desactivar:
    call DesactivarCuenta
    jmp pausa_menu

op_salir:
    ; Rutina de finalizacion y liberacion de control al sistema operativo.
    mov ah, 09h
    lea dx, msgDespedida
    int 21h

    mov ah, 4Ch
    int 21h
             
; =====================================================================
; UTILIDADES DE INTERFAZ
; =====================================================================
pausa_menu:
    ; Interrupcion temporal del flujo para permitir visualizacion de resultados.
    mov ah, 09h
    lea dx, msgPausa
    int 21h
    
    ; Espera de pulsacion de tecla sin eco en pantalla.
    mov ah, 07h  
    int 21h
    
    jmp ciclo_principal

; =============================================================================
; INCLUSION DE DEPENDENCIAS
; =============================================================================
; Incorporacion de la logica de negocio externa en tiempo de ensamblado.
include modulos.asm
include conversiones.asm   

end main
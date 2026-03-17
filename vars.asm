; =============================================================================
; ARCHIVO: vars.asm
; DESCRIPCION: Define la estructura de datos simulada y asigna los bloques de 
;              memoria global requeridos por los modulos del sistema.
; =============================================================================

; -------------------------------------------------------------------------
; DEFINICION DE ESTRUCTURA: Cuenta Bancaria
; Los offsets representan el desplazamiento en bytes desde la direccion 
; base de un registro para acceder a un campo especifico.
; -------------------------------------------------------------------------
OFS_ESTADO      equ 0   ; 1 byte.  Valores: 0 = Inactiva/Vacia, 1 = Activa.
OFS_NUMERO      equ 1   ; 2 bytes. Identificador numerico (Word).
OFS_SALDO       equ 3   ; 4 bytes. Saldo ampliado para simulacion de 4 decimales (DWord).
OFS_NOMBRE      equ 7   ; 20 bytes. Cadena de caracteres para el titular.

TAMANO_REGISTRO equ 28  ; Longitud total en bytes de una cuenta (1+2+4+21).
MAX_CUENTAS     equ 10  ; Limite operativo del sistema segun requerimientos.

; -------------------------------------------------------------------------
; ASIGNACION DE MEMORIA PRINCIPAL
; -------------------------------------------------------------------------
; Arreglo que contiene la totalidad de las cuentas. 
; Se inicializa en 0 para garantizar que todas las posiciones esten 
; marcadas como "Inactivas" o "Vacias" al inicio de la ejecucion.
db_cuentas      db 280 dup(0) 

; -------------------------------------------------------------------------
; VARIABLES GLOBALES PARA MANEJO DE MATEMATICA DE 32 BITS
; Se utilizan para almacenar los resultados de las conversiones numericas
; dado que los registros convencionales (AX, BX) sufren desbordamiento.
; -------------------------------------------------------------------------
val_alto        dw 0    ; Almacena los 16 bits mas significativos.
val_bajo        dw 0    ; Almacena los 16 bits menos significativos.

; -------------------------------------------------------------------------
; BUFFER DE ENTRADA ESTANDAR                                                                                                
; Requerido por la interrupcion 21h (Funcion 0Ah) para capturar cadenas.
; -------------------------------------------------------------------------
buffer_teclado  db 20        ; Capacidad maxima de lectura.
                db 0         ; Longitud real capturada por el sistema.
                db 20 dup(0) ; Espacio de almacenamiento de caracteres.   
                
; -------------------------------------------------------------------------
; VARIABLES TEMPORALES PARA FORMATEO DE ENTRADA
; -------------------------------------------------------------------------
buffer_limpio   db 20 dup(0) ; Almacena la cadena procesada sin punto decimal.
len_limpio      db 0         ; Cantidad de digitos validos en buffer_limpio.   
error_entrada   db 0         ; Bandera de validacion. 0 = Exito, 1 = Desbordamiento/Error

; ------------------------------------------------------------------------- 
; VARIABLES TEMPORALES PARA REPORTE
; -------------------------------------------------------------------------
temp_max_alto   dw 0
temp_max_bajo   dw 0
temp_max_num    dw 0
temp_min_alto   dw 0FFFFh
temp_min_bajo   dw 0FFFFh
temp_min_num    dw 0
temp_flag       db 0

; ------------------------------------------------------------------------- 
; CONTADORES GLOBALES PARA REPORTE
; -------------------------------------------------------------------------
total_inactivas dw 0

; ------------------------------------------------------------------------- 
; SALDO TOTAL GLOBAL
; -------------------------------------------------------------------------
saldo_total_alto dw 0
saldo_total_bajo dw 0
; =============================================================================
; ARCHIVO: interfaz.asm
; Contiene todos los mensajes y textos de la interfaz de usuario (UI).
; =============================================================================

    msgLogo      db 0Dh, 0Ah, "======================================="
                 db 0Dh, 0Ah, "          SISTEMA BANKTEC 2026         "
                 db 0Dh, 0Ah, "=======================================$"
    
    msgMenu      db 0Dh, 0Ah, "1. Crear cuenta"
                 db 0Dh, 0Ah, "2. Depositar dinero"
                 db 0Dh, 0Ah, "3. Retirar dinero"
                 db 0Dh, 0Ah, "4. Consultar saldo"
                 db 0Dh, 0Ah, "5. Mostrar reporte general"
                 db 0Dh, 0Ah, "6. Desactivar cuenta"
                 db 0Dh, 0Ah, "7. Salir"
                 db 0Dh, 0Ah, "---------------------------------------"
                 db 0Dh, 0Ah, "Seleccione una opcion: $" 

    msgError     db 0Dh, 0Ah, ">> ERROR: Opcion invalida. Intente de nuevo.", 0Dh, 0Ah, "$"
    msgDespedida db 0Dh, 0Ah, ">> Gracias por usar BankTec. Cerrando sistema...$"
    msgPausa     db 0Dh, 0Ah, 0Dh, 0Ah, "Presione cualquier tecla para continuar...$"
      
    msgConstruccion db 0Dh, 0Ah, 0Dh, 0Ah, ">> FUNCION EN CONSTRUCCION <<", 0Dh, 0Ah, "$"      
    

    
    ; ---MENSAJES DE ERROR ESPECIFICOS ---
    msgErrMonto  db 0Dh, 0Ah, ">> ERROR: Monto invalido. Contiene letras o excede el limite de 429,496.7295", 0Dh, 0Ah, "$"
    msgErrFormato  db 0Dh, 0Ah, ">> ERROR: Formato invalido. Ingrese unicamente numeros.", 0Dh, 0Ah, "$"
    msgErrCuenta db 0Dh, 0Ah, ">> ERROR: Numero de cuenta inexistente en el sistema.", 0Dh, 0Ah, "$"
    msgErrInact  db 0Dh, 0Ah, ">> ERROR: La operacion no se puede realizar. La cuenta esta inactiva.", 0Dh, 0Ah, "$"
    msgErrFondos db 0Dh, 0Ah, ">> ERROR: Fondos insuficientes para realizar el retiro.", 0Dh, 0Ah, "$"
    msgErrExiste db 0Dh, 0Ah, ">> ERROR: El numero de cuenta ya se encuentra registrado.", 0Dh, 0Ah, "$"
    msgErrLleno    db 0Dh, 0Ah, ">> ERROR: Sistema lleno. Limite de 10 cuentas alcanzado.", 0Dh, 0Ah, "$"
    msgErrOverflow db 0Dh, 0Ah, ">> ERROR: La operacion excede el limite maximo de los 32 bits.", 0Dh, 0Ah, "$"
    msgErrBanco db 0Dh, 0Ah, ">> ERROR: La sumatoria total excede el limite de 32 bits.$"
    
    ; --- MENSAJES DE INTERACCION ---
    msgPedirCuenta db 0Dh, 0Ah, ">> Ingrese el numero de cuenta: $"
    msgPedirNombre db 0Dh, 0Ah, ">> Ingrese el nombre del titular (max 20 caracteres): $"
    msgPedirMonto  db 0Dh, 0Ah, ">> Ingrese el monto: $"
    msgExito       db 0Dh, 0Ah, ">> Operacion realizada con exito.", 0Dh, 0Ah, "$"
    msgNombreEs    db 0Dh, 0Ah, ">> Titular: $"
    msgSaldoEs     db 0Dh, 0Ah, ">> El saldo actual de la cuenta es: $"
    
    ; --- MENSAJES PARA REPORTE ---
    msgReporteTitulo db 0Dh, 0Ah, "========== REPORTE GENERAL ==========", 0Dh, 0Ah, "$"
    msgTotalActivas  db 0Dh, 0Ah, "Total de cuentas activas: $"
    msgTotalInactivas db 0Dh, 0Ah, "Total de cuentas inactivas: $"
    msgSaldoTotal    db 0Dh, 0Ah, "Saldo total del banco: $"
    msgCuentaMayor   db 0Dh, 0Ah, "Saldo mayor: $"
    msgCuentaMenor   db 0Dh, 0Ah, "Saldo menor: $"
    msgNoCuentas     db " (No hay cuentas activas)$"
    msgIDParentesis  db " (ID: $"
    msgCerrarParentesis db ")$"
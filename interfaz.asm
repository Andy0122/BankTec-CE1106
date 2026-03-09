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
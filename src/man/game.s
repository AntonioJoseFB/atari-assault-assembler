.include "cpctelera.h.s"

.area DATA
.area CODE

;; manager methods
.globl man_entity_init
.globl man_entity_update

;; system methods
.globl sys_render_init
.globl sys_physics_update
.globl sys_render_update

;;cpctelera utilities
.globl cpct_waitVSYNC_asm
.globl cpct_waitHalts_asm

man_game_wait:
    ;;a contains the number of times to do this
    while_remain_halts:
        ;;TODO --> buscar que registro usa para cargar el numero de halts
        ;;call cpct_waitHalts_asm
        halt
        halt
        call cpct_waitVSYNC_asm
        dec a
        jr nz, while_remain_halts
    ret
man_game_init::
    call man_entity_init
    call sys_render_init
    ret

man_game_play::
    game_loop:
        call sys_physics_update
        call sys_render_update
        call man_entity_update
        call cpct_waitVSYNC_asm
    jr game_loop
    ret 
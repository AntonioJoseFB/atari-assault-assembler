.include "cpctelera.h.s"

.area DATA
.area CODE

;; manager methods
.globl man_entity_init
.globl man_entity_update
.globl man_entity_create

;; system methods
.globl sys_render_init
.globl sys_physics_update
.globl sys_render_update

;;cpctelera utilities
.globl cpct_waitVSYNC_asm
.globl cpct_waitHalts_asm
.globl cpct_memcpy_asm

;;Global variables references
.globl entity_size

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Sprite:
;;  - 4 width, 6 height
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
e_sprite::
    .db #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Entity struct:
;;  - type, x, y, w, h, vx, vy, sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_e::
    .db #0x03   ;; entity_type_movable | entity_type_render
    .db 38      ;; x
    .db 96      ;; y
    .db #0x04   ;; w
    .db #0x06   ;; h
    .db #0xFF   ;; vx = -1
    .db #0x00   ;; vy = 0
    .db #0xFF, #0xFF, #0xFF, #0xFF ;;content of the sprite --> se supone que ahi podria poner (sprite), pero no los carga
    .db #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF

man_game_wait:
    ;;a contains the number of times to do this
    while_remain_halts:
        ;;TODO --> buscar que registro usa para cargar el numero de halts
        ;;call cpct_waitHalts_asm
        halt ;;placeholder
        halt ;;placeholder
        call cpct_waitVSYNC_asm
        dec a 
        jr nz, while_remain_halts
    ret
man_game_init::
    call man_entity_init
    call sys_render_init

    call man_entity_create ;; de contains the direction of the entity created
    ld hl, #init_e
    ld bc, #entity_size
    call cpct_memcpy_asm

    ret

man_game_play::
    game_loop:
        call sys_physics_update
        call sys_render_update
        call man_entity_update
        ;;ld a, #0x05
        ;;call man_game_wait
        call cpct_waitVSYNC_asm
    jr game_loop
    ret 
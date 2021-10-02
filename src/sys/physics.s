.include "cpctelera.h.s"

.area _DATA

m_left_key:: .db #0x69
m_right_key:: .db #0x61

.area _CODE
.globl man_entity_forall
.globl man_entity_set4destruction

;;Maths utilities
.globl inc_hl_number
.globl dec_hl_number

;;cpc_telera
.globl  cpct_scanKeyboard_f_asm
.globl cpct_isKeyPressed_asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the render
;; Objetive: Update the render for one entity
;; Modifies: a, bc, (hl no se si lo modifica)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_physics_update_one_entity::

    ;;Check if the entity has type input
    ld a, #0x04 ;;TODO: deberiamos poner la referencia a entity_type_input
    and (hl)
    jr nz, entity_has_input ;;TODO: ¡cuidado con esto!

    ;;B is the current entity pos_x
    inc hl
    ld b, (hl)

    calculate_new_pos:
    ;;C is the current entity vel_x
    ld a, #0x04
    call inc_hl_number
    ld c, (hl)

    ;;Pos_x + Vel_x to know the new position of the entity
    ld a, #0x00
    add a, b
    add a, c

    push af

    ;;Coming back to the pos_x memory direction fo the entity to modify it
    ld a, #0x04
    call dec_hl_number

    pop af

    ld (hl), a 
    dec hl

    jr end_update_one_entity

    entity_has_input: ;;TODO: esto no funciona
        push hl
        call sys_physics_check_input
        pop hl
        jr calculate_new_pos
    end_update_one_entity:

ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the render
;; Objetive: Check if a key is pressed
;; Modifies: AF, BC, DE, HL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_physics_check_input::
    push hl ;;save hl in the stack
    call cpct_scanKeyboard_f_asm
    ;;Check if left_key is pressed
    ld hl, (m_left_key)
    call cpct_isKeyPressed_asm
    jr  nz, left_key_pressed
    ;;Check if right_key is pressed
    ld hl, (m_right_key)
    call cpct_isKeyPressed_asm
    jr  nz, right_key_pressed
    ;;No key is pressed
    ld b, #0x00
    jr end_check_keyboard

    left_key_pressed:
    ld b, #0xFF
    jr end_check_keyboard
    right_key_pressed:
    ld b, #0x01

    end_check_keyboard:
    pop hl
    ld a, #0x05
    call inc_hl_number
    ld (hl), b

    ;;TODO: probar si haciendo push y pop antes de llamar a este metodo funciona, sino cambiar por esto
    ;;return hl to the beginning of the pointer
    ;;ld a, #0x05
    ;;call dec_hl_number
    ;;push hl ;;TODO: no se si este push hace falta

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the physics for all the entities
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_physics_update::
    ld de, #sys_physics_update_one_entity
    call man_entity_forall

ret
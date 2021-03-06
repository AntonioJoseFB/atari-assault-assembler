.include "cpctelera.h.s"

.area _DATA

;;m_left_key:: .db #0x69
;;m_right_key:: .db #0x61

.area _CODE
.globl man_entity_forall_matching

;;Maths utilities
.globl inc_hl_number
.globl dec_hl_number

.globl entity_type_movable
.globl entity_type_render
.globl entity_type_ai

.globl man_game_create_enemy

m_function_given_ai:: .dw #0x0000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to check left/right move
;; Objetive: Update the direction for one ai entity
;; Modifies: a, bc, (hl no se si lo modifica)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_behaviour_left_right::
    ;;right_bound = 80 - e->w
    ld a, #0x03
    call inc_hl_number ;;hl points to the w

    ld a, #0x50        ;;loads 80(dec) to a
    sub (hl)           ;;80 - w

    push af             ;;a contains righ_bound

    ;;if( e-> x == 0) e -> vx = 1
    ld a, #0x00
    dec hl
    dec hl              ;;hl points to pos_x
    sub (hl)
    jr z, right_collision

    ;;else if(e->x == right-bound) e -> vx = -1
    pop af
    sub (hl)
    jr z, left_collision

    ;;else, nothing happens
    dec hl
    jr end_ai_update

    right_collision:
    pop af
    ld b, #0x01
    jr apply_ai_update

    left_collision:
    ld b, #0xFF

    apply_ai_update:
    ;;set vel_x
    ld a, #0x04
    call inc_hl_number
    ld (hl), b
    ;;return hl to the beginning of the entity
    ld a, #0x05
    call dec_hl_number

    end_ai_update:
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to check left/right move
;; Objetive: Make that the AI mothershp entity behaves as we have defined
;; Modifies: a, bc, (hl no se si lo modifica)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_behaviour_mothership::
    
    ld a, #0x14
    inc hl
    sub (hl)
    jr nz, no_spawn_entity
    
    dec hl
    call man_game_create_enemy
    jr end_of_ai_behaviour

    no_spawn_entity:
    dec hl

    end_of_ai_behaviour:

    call sys_ai_behaviour_left_right
ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the ai
;; Objetive: Update the ai for one entity
;; Modifies: a, bc, (hl no se si lo modifica)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_update_one_entity::
    
    ld a, #0x0A
    call inc_hl_number ;;hl points to the behaviour function

    ;;Save the memory direction of the behaviour function in de 
    ;;TODO: revisar como me guardo en de la direccionde memoria de la funcion a llamar para la AI
    ld a, (hl)
    ld d, a
    dec hl
    ld a, (hl)
    ld e, a
    ld (#m_function_given_ai), de

    ld a, #0x09
    call dec_hl_number ;;hl points to the beginnign of the entity

	ld ix, (#m_function_given_ai)
	jp (ix)
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the ai for all the entities matching
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_update::
    ld de, #sys_ai_update_one_entity
    
    ;;bc will contain the signature
    ld bc, #0x0000

    ld a, #entity_type_movable
    add a, #entity_type_render
    add a, #entity_type_ai
    ld c, a

    call man_entity_forall_matching

ret
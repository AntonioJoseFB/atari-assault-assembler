.include "cpctelera.h.s"

.area _DATA

.area _CODE

;;entity_types
.globl entity_type_animated
.globl entity_type_render

;;man_entity
.globl man_entity_forall_matching

;;math utils
.globl inc_hl_number
.globl dec_hl_number 

sys_animations_update_one_entity::
    ;;if (-- (e->anim_counter) == 0)
    ld a, #0x0D
    call inc_hl_number ;;hl points to the anim_counter

    ld a, (hl)
    dec (hl)
    jr z, zero_anim_counter

    ;;No change animation
    ld a, #0x0D
    call dec_hl_number ;;hl points to the beginning of the animation

    ret

    ;;anim_counter is 0 -> change animation
    zero_anim_counter:
    dec hl
    dec hl
    ld e, (hl)
    inc hl
    ld d, (hl) ;;ahora tengo en DE --> 4195 --> direccion de memoria del anim
    dec hl ;;hl points to the 11th position of memory of the array

    
    


ret
sys_animations_update::
    ld de, #sys_animations_update_one_entity
    
    ;;BC will contain the signature for the man_entity_forall_matching
	ld bc, #0x0000
	ld a, #entity_type_animated
	add a, #entity_type_render
	ld c, a

    call man_entity_forall_matching
    ret
.include "cpctelera.h.s"

.area _DATA

.area _CODE

;;entity_types
.globl entity_type_animated

;;man_entity
.globl man_entity_forall_matching

sys_animations_update_one_entity::
    ;;if (-- (e->anim_counter) == 0)
    ld a, #0x0D
    call inc_hl_number ;;hl points to the anim_counter

    ld a, #0x01
    sub (hl)
    jr nz, no_zero_anim_counter

        ;;anim_counter is 0
        ;;++e->anim

        ;;if(e->anim->time == 0){
        ;;e->anim = e->anim->val.next ;; Change the sprite of the animation
        ;;}

        ;;e->sprite = e->anim->val.sprite
        ;;e->anim_counter = e->anim->time


    ;;anim_counter is not 0
    no_zero_anim_counter:

    ret
sys_animations_update::
    ld de, #sys_animations_update_one_entity
    
    ;;bc will contain the signature
    ld bc, #0x0000
    ld c, #entity_type_animated

    call man_entity_forall_matching
    ret
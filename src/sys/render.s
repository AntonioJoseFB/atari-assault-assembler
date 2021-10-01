.include "cpctelera.h.s"

.area _DATA
.area _CODE

.globl _cpct_setPALColour
.globl _cpct_setVideoMode
.globl _cpct_setPalette
.globl man_entity_forall
.globl cpct_getScreenPtr_asm
.globl cpct_drawSprite_asm

;;States of an entity
.globl entity_type_dead

;;Maths utilities
.globl inc_hl_number
.globl dec_hl_number

palette::
    .db #0x14	; 20
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11
	.db #0x0b	; 11

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Initialize cpctelera render and screen settings
;; Modifies: Probably all the registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_render_init::
	ld l, #0x00
   	call	_cpct_setVideoMode

	;;set border
	ld hl, #0x1410
	push    hl 
	call	_cpct_setPALColour

	ld hl, #0x0010
	push    hl 
    ld hl, #palette
    push hl
    call _cpct_setPalette
ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the render
;; Objetive: Update the render for one entity
;; Modifies: a, bc, de, (hl no se si lo modifica)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_render_one_entity:
    ;;Now, we should check if the start is dead, hl is pointing to the beginning of the entity

    ;;Type of the star
    ld a, (hl)           
    ld b, #entity_type_dead 

    and b
    
    jr nz, star_dead_no_render

    ;;The star is alive, we should render it
    ld de, #0xC000

    inc hl
    ld c, (hl)
    inc hl
    ld b, (hl)

    dec hl
    dec hl

    push hl

    call cpct_getScreenPtr_asm
    
    ;;Save in bc pvmem
    ld c, l
    ld b, h

    ;;point hl to the beginning of the entity
    pop hl
    push hl

    ;;We are going to get the pvmem, w, h, sprite
    ld e, c
    ld d, b
    push de

    inc hl
    inc hl
    inc hl
    ld c, (hl) ;; load in c --> width
    inc hl
    ld b, (hl) ;; load in b --> height
    inc hl
    inc hl
    inc hl
    ;; load in hl --> the sprite
    ld e, (hl) 
    inc hl
    ld d, (hl)
    ld l, e
    ld h, d

    pop de ;;de contains the pvmem again

    call cpct_drawSprite_asm

    pop hl ;;hl points to the beginnign of the entity

    star_dead_no_render:
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the render for all the entities
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_render_update::
    ld de, #sys_render_one_entity
    call man_entity_forall
ret
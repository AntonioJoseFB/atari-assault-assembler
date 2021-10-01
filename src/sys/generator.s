.globl man_entity_free_space
.globl man_entity_create
.globl cpct_memcpy_asm
.globl cpct_getRandom_mxor_u8_asm
.globl __moduchar

.globl entity_size

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Default initialization of an entity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_e:
	.db #0x01	; 1 ;type
	.db #0x4f	; 79	'O' ;pos_x
	.db #0x01	; 1	;pos_y
	.db #0xff	; -1 ;vel_x
	.db #0xff	; 255 ;color
	.dw #0x0000	;previous ptr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - 
;; Objetive: Update the generator and creates new stars if there are
;; free espace available
;; Modifies: a, b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_generator_update::
    
    ;;How many stars are we allow to create?
    call man_entity_free_space

    ;;A contains the free space 0, 1 , 2 o >2

    push af 

    ;;Is free space 0?
    dec a
    ld b, #0xFF
    sub b
    jr z, was_cero  

    pop af

    ;;Is free space 1?
    dec a
    jr z, was_one
    
    ;;freespace is 2 or more
    call generate_new_star
    was_one:
        call generate_new_star
        jr final
    was_cero:
        pop af

    final:
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - 
;; Objetive: Generates a new star
;; Modifies: a, b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_new_star::  

    call man_entity_create
    
    ;; After call man_entity_create, de has the next free entity memory direction 

    push de

    ;; Initializing the new entity created
	ld hl, #init_e
	ld bc, #entity_size

	call cpct_memcpy_asm

    pop de

    ;; De still has the entity memory direction

    ;; Changing the entity pos_y randomly
	inc	de
	inc	de
	push	bc
	push	de
	call    cpct_getRandom_mxor_u8_asm
	ld	h, l
	ld	a, #0xc8
	push	af
	inc	sp
	push	hl
	inc	sp
	call	__moduchar
	pop	af
	ld	a, l
	pop	de
	pop	bc
	ld	(de), a

    ;; Changing the entity vel_x position randomly
    inc de

    call cpct_getRandom_mxor_u8_asm

    ld a, #0x03
    and l

    ld b, #0xFE
    
    or b

    dec a

    ld (de), a 

    pop bc

ret
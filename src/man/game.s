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
.globl sys_animations_update

;;AI system
.globl sys_ai_update
.globl sys_ai_behaviour_left_right
.globl sys_ai_behaviour_mothership

;;cpctelera utilities
.globl cpct_waitVSYNC_asm
.globl cpct_waitHalts_asm
.globl cpct_memcpy_asm

;;Global variables references
.globl entity_size
.globl entity_type_render
.globl entity_type_movable

;;math utils
.globl inc_de_number
.globl dec_de_number
.globl inc_hl_number
.globl dec_hl_number

;;animation structs
.globl man_anim_enemy1

m_enemy_on_lane:: .db #0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Sprite:
;;  - 4 width, 6 height = 24bytes, TODO: cada sprite tendra sus dimensiones y tamanyo en memoria
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spr_mothership::
    .db #0x00, #0x0F, #0x0F, #0x00 ;; TODO: Tenemos que hacer lo de la lectura de sprites, conversion y setear la paleta
    .db #0x00, #0x0F, #0x0F, #0x00
    .db #0x00, #0x0F, #0x0F, #0x00
    .db #0x00, #0x0F, #0x0F, #0x00
    .db #0x00, #0x0F, #0x0F, #0x00
    .db #0x00, #0x0F, #0x0F, #0x00

;;Enmey alive sprite
spr_enemy1_0::
    .db #0x00, #0xF0, #0xF0, #0x00 ;; TODO: Tenemos que hacer lo de la lectura de sprites, conversion y setear la paleta
    .db #0x00, #0xF0, #0xF0, #0x00
    .db #0x00, #0xF0, #0xF0, #0x00
    .db #0x00, #0xF0, #0xF0, #0x00
    .db #0x00, #0xF0, #0xF0, #0x00
    .db #0x00, #0xF0, #0xF0, #0x00

;;Enmey alive sprite
spr_enemy1_1::
    .db #0x00, #0xF0, #0xF0, #0x00 ;; TODO: Tenemos que hacer lo de la lectura de sprites, conversion y setear la paleta
    .db #0x00, #0xF8, #0xF8, #0x00
    .db #0x00, #0xF8, #0xF8, #0x00
    .db #0x00, #0xF8, #0xF8, #0x00
    .db #0x00, #0xF8, #0xF8, #0x00
    .db #0x00, #0xF8, #0xF8, #0x00

spr_playership::
    .db #0x00, #0xFF, #0xFF, #0x00 ;; TODO: Tenemos que hacer lo de la lectura de sprites, conversion y setear la paleta
    .db #0x00, #0xFF, #0xFF, #0x00
    .db #0x00, #0xFF, #0xFF, #0x00
    .db #0x00, #0xFF, #0xFF, #0x00
    .db #0x00, #0xFF, #0xFF, #0x00
    .db #0x00, #0xFF, #0xFF, #0x00

spr_player::
    .db #0x00, #0x88, #0x88, #0x00 ;; TODO: Tenemos que hacer lo de la lectura de sprites, conversion y setear la paleta
    .db #0x00, #0x88, #0x88, #0x00
    .db #0x00, #0x88, #0x88, #0x00
    .db #0x00, #0x88, #0x88, #0x00
    .db #0x00, #0x88, #0x88, #0x00
    .db #0x00, #0x88, #0x88, #0x00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Entity struct:
;;  - type, x, y, w, h, vx, vy, sprite, ai_behaviour, AnimFrame_t, anim_counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mothership_template::
    .db #0x0B   ;; TODO:poner como entity_type_movable | entity_type_render | entity_type_ai
    .db 38      ;; x
    .db 10      ;; y
    .db #0x04   ;; w ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x06   ;; h ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0xFF   ;; vx = -1
    .db #0x00   ;; vy = 0
    .dw spr_mothership
    .dw #sys_ai_behaviour_mothership ;;ai_behaviour function
    .dw #0x0000 ;; Doesnt have animation
    .db #0x00   ;;Anim_counter

enemy1_template::
    .db #0x1B  ;; TODO:poner como entity_type_movable | entity_type_render | entity_type_ai | entity_type_anim
    .db 0      ;; x
    .db 40      ;; y
    .db #0x04   ;; w ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x06   ;; h ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x00   ;; vx = -1
    .db #0x00   ;; vy = 0
    .dw spr_enemy1_0
    .dw #sys_ai_behaviour_left_right ;;ai_behaviour function
    .dw man_anim_enemy1
    .db #0x0C   ;;Anim_counter

playership_template::
    .db #0x01   ;; entity_type_render
    .db 0       ;; x
    .db 192     ;; y
    .db #0x04   ;; w ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x06   ;; h ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x00   ;; vx = 0 TODO: acordarme de ponerle velocidad 0
    .db #0x00   ;; vy = 0
    .dw spr_playership
    .dw #0x0000 ;;Doesnt have ai_behviour
    .dw #0x0000 ;; Doesnt have animation
    .db #0x00   ;;Anim_counter

player_template::
    .db #0x07  ;; entity_type_render | entity_type_movable | entity_type_input
    .db 38      ;; x
    .db 180     ;; y
    .db #0x04   ;; w ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x06   ;; h ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x00  ;; vx = 0 TODO: acordarme de ponerle velocidad 0, este se va a mover por los inputs
    .db #0x00   ;; vy = 0
    .dw spr_player
    .dw #0x0000 ;;Doesnt have ai_behviour
    .dw #0x0000 ;; Doesnt have animation
    .db #0x00   ;;Anim_counter


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;MAN_GAME_WAIT 
;;Pre requirements
;;  - a: should contain the times to execute the loop
;; Objetive: make VSYNC slower
;; Modifies: a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;man_game_create_template_entity
;;Pre requirements
;;  - hl: contains the template direction to be used
;;  - bc contains the size of the entity to be created
;; Objetive: create an entity in fucntion of the template it is
;; Modifies: hl, bc, de
;; Returns: de contains the direction of the entity created
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_game_create_template_entity::
    ;;hl contains the template direction to be used
    ;;bc contains the size of the entity to be created
    push hl
    push bc
    call man_entity_create
    pop bc
    pop hl

    push de ;;contains the direction of the entity created
    call cpct_memcpy_asm
    pop de
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;man_game_create_enemy
;;Pre requirements
;;  - hl: contains the direction fo the mothership
;; Objetive: create an enemy
;; Modifies: hl, bc, de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_game_create_enemy::
    ;;if there is an enemy alredy on lane, do not create enemy
    ld a, (#m_enemy_on_lane)
    dec a
    jr z, no_create_enemy

    ;;creating an enemy
    push hl ;;save direction of the mothership

    ld hl, #enemy1_template
    ld bc, #entity_size
    call man_game_create_template_entity

    pop hl

    ;;save in a mothership_x
    inc hl
    ld a, #0x04
    add a, (hl)
    inc de
    ld (de), a

    ;; hl points to the vel_x of the mothership
    ld a, #0x04
    call inc_hl_number

    ;; de points to the vel_x of the enemy
    ld a, #0x04
    call inc_de_number

    ;;take the vel_x of the mothership and set it as the vel_x of the enemy
    ld a, (hl)
    ld (de), a
    
    ;; hl points to the beginning of the mothership
    ld a, #0x05
    call dec_hl_number

    ;; de points to the beginning of the enemy
    ld a, #0x05
    call dec_de_number

    ;;Mark that there is an enemy on lane
    ld a, #0x01
    ld (#m_enemy_on_lane), a

    no_create_enemy:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;man_game_init
;;Pre requirements
;;  -
;; Objetive: initialize all necessary entities
;; Modifies: hl, bc, de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_game_init::
    call man_entity_init
    call sys_render_init

    ;;creating the mothership
    ld hl, #mothership_template
    ld bc, #entity_size
    call man_game_create_template_entity


    ;;This is the scoreboard
    ;;creating the playerships
    ;;TODO: meter esto en un bucle y crear 3 playership en diferentes posiciones
    ld hl, #playership_template
    ld bc, #entity_size
    call man_game_create_template_entity
    
    ld hl, #playership_template
    ld bc, #entity_size
    call man_game_create_template_entity
    inc de
    ld a, #10
    ld (de), a
    dec de

    ld hl, #playership_template
    ld bc, #entity_size
    call man_game_create_template_entity
    inc de
    ld a, #20
    ld (de), a
    dec de


    ;;Creating the player
    ld hl, #player_template
    ld bc, #entity_size
    call man_game_create_template_entity



    ret

man_game_play::
    game_loop:
        call sys_ai_update
        call sys_physics_update
        ;;call sys_animations_update ;;TODO: descomentar
        call sys_render_update
        call man_entity_update
        ;;ld a, #0x05
        ;;call man_game_wait
        call cpct_waitVSYNC_asm
    jr game_loop
    ret 
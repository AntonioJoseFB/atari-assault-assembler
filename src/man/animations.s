.include "cpctelera.h.s"

.area _DATA

.area _CODE

.globl spr_enemy1_0
.globl spr_enemy1_1

man_anim_enemy1::
    .db #0x0C
    .dw spr_enemy1_0
    .db #0x0C
    .dw spr_enemy1_1
    .db#0x00
    .dw #man_anim_enemy1
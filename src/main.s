.include "cpctelera.h.s"

.area _DATA
.area _CODE

;;Cpctelera video functions
.globl _cpct_disableFirmware
.globl cpct_waitVSYNC_asm

;;Managers
.globl man_entity_init
.globl man_entity_update

;;Systems
.globl sys_physics_update
.globl sys_render_init
.globl sys_render_update
.globl sys_generator_update


_main::
	;;Initialize cpctelera render setting
	call    _cpct_disableFirmware

	call man_entity_init
	call sys_render_init

game_loop:
	call sys_physics_update
	call sys_generator_update
	call sys_render_update

	call man_entity_update
	call cpct_waitVSYNC_asm
jr game_loop
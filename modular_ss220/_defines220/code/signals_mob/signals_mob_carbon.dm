// Signals for /mob/living/carbon
/// called by /mob/equip_to_slot() : (/datum/component/mob_overlay_shift)
#define COMSIG_MOB_ON_EQUIP "mob_on_equip"

/// called by /mob/ClickOn() : (/datum/component/mob_overlay_shift)
#define COMSIG_MOB_ON_CLICK "mob_on_click"

/// called by /datum/species/spec_attack_hand() /mob/living/carbon/human/MouseDrop_T() /mob/MouseDrop() : (/datum/component/gadom_cargo) (/datum/component/gadom_living)
#define COMSIG_GADOM_CAN_GRAB "gadom_can_grab"
	#define GADOM_CAN_GRAB (1 << 0)

/// called by datum/component/gadom_living/proc/try_load_mob()  : (/datum/component/gadom_cargo)
/// called by datum/component/gadom_cargo/proc/try_load_cargo() : (/datum/component/gadom_living)
#define COMSIG_GADOM_LOAD "gadom_load"

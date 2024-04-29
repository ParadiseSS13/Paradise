
/datum/spell/touch/paradox_spell/microcircuit_disorder
	name = "Microcircuit Disorder"
	desc = "Make a system failure and some short circuit causes silicon (and machinery) to disable. Need physical contact."
	action_icon_state = "microcircuit_disorder"
	base_cooldown = 70 SECONDS
	hand_path = /obj/item/melee/touch_attack/paradox_emp

/obj/item/melee/touch_attack/paradox_emp
	name = "paradox hand"
	desc = "A sinister looking aura that distorts the flow of reality around it. Makes EMP. Can affect silicons and machinery, headsets, energy weapons and etc."
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"
	color = COLOR_GRAY
	invisibility = SEE_INVISIBLE_LIVING
	flags = ABSTRACT | DROPDEL
	catchphrase = null
	w_class = WEIGHT_CLASS_HUGE

/obj/item/melee/touch_attack/paradox_emp/afterattack(mob/living/silicon/target, mob/living/carbon/user)
	. = ..()
	if(istype(target))
		target.flash_eyes(1, TRUE, type = /atom/movable/screen/fullscreen/flash/noise)

	target.emp_act(EMP_HEAVY)
	playsound(get_turf(target), 'sound/effects/paradox_emp.ogg', 80, TRUE)

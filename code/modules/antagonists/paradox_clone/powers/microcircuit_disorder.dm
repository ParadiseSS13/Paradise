/datum/spell/touch/paradox_spell/microcircuit_disorder
	name = "Microcircuit Disorder"
	desc = "Make systems fail and short circuit, causing electronics to disable. Need physical contact."
	action_icon_state = "microcircuit_disorder"
	base_cooldown = 60 SECONDS
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

/obj/item/melee/touch_attack/paradox_emp/afterattack(mob/living/target, mob/living/carbon/user)
	. = ..()

	if(is_paradox_clone(target))
		attached_spell.revert_cast()
		to_chat(user, "<span class='warning'>Useless. [target.name] is from our kin.</span>")
		return

	if(istype(target, /mob/living/silicon))
		var/mob/living/silicon/S = target
		S.flash_eyes(40, 1, 1)

	target.emp_act(EMP_HEAVY)
	playsound(get_turf(target), 'sound/effects/paradox_emp.ogg', 80, TRUE)

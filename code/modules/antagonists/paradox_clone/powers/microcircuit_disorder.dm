
/datum/spell/paradox/self/microcircuit_disorder
	name = "Microcircuit Disorder"
	desc = "Make a system failure and some short circuit causes silicon (and machinery) to disable. Need physical contact."
	action_icon_state = "microcircuit_disorder"
	base_cooldown = 70 SECONDS

/datum/spell/paradox/self/microcircuit_disorder/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/H = user

	revert_cast()
	var/obj/item/melee/paradox_emp/emp = new /obj/item/melee/paradox_emp(H)
	if(!H.put_in_hands(emp))
		to_chat(H, "<span class='warning'>You have no empty hand for invoking [src.name]!</span>")
		qdel(emp)

/obj/item/melee/paradox_emp
	name = "paradox hand"
	desc = "A sinister looking aura that distorts the flow of reality around it. Makes EMP. Can affect silicons and machinery, headsets, energy weapons and etc."
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"
	color = COLOR_GRAY
	invisibility = SEE_INVISIBLE_LIVING
	flags = ABSTRACT | DROPDEL

	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
/*
/obj/item/melee/paradox_emp/pre_attack(atom/A, mob/living/user, params)
	..()

	if(!in_range(A, user))
		return
*/
/obj/item/melee/paradox_emp/attack(mob/living/M, mob/living/carbon/user)
	add_attack_logs(user, M, "(Paradox Clone) Microcircuit Disordered")
	M.lastattacker = user.real_name
	user.do_attack_animation(M)

/obj/item/melee/paradox_emp/attack_obj(obj/O, mob/living/user, params)
	var/mob/living/carbon/H = user
	O.emp_act(EMP_HEAVY)
	make_cooldown(H)
	user.do_attack_animation(O)
	add_attack_logs(user, O, "(Paradox Clone) Microcircuit Disordered")

/obj/item/melee/paradox_emp/afterattack(mob/living/M, mob/living/carbon/user)
	var/mob/living/carbon/H = user
	if(istype(M, /mob/living/silicon))
		M.flash_eyes(1, TRUE)

	M.emp_act(EMP_HEAVY)
	make_cooldown(H)

/obj/item/melee/paradox_emp/attack_self(mob/user)
	..()
	var/mob/living/carbon/human/H = user
	empulse(get_turf(user), 1, 2, log = FALSE, cause = "Microcircuit Disorder")
	make_cooldown(H)

/obj/item/melee/paradox_emp/proc/make_cooldown(mob/living/carbon/human/H)
	qdel(src)
	var/datum/spell/paradox/self/microcircuit_disorder/emp = locate() in H.mind.spell_list
	playsound(H, 'sound/effects/paradox_emp.ogg', 80, TRUE)

	emp.cooldown_handler.start_recharge(emp.base_cooldown)
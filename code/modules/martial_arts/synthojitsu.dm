/datum/martial_art/synthojitsu
	name = "Synthojitsu"
	block_chance = 0
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/synthojitsu/lock, /datum/martial_combo/synthojitsu/overload, /datum/martial_combo/synthojitsu/reanimate)

/datum/martial_art/synthojitsu/can_use(mob/living/carbon/human/H)
	if(!ismachineperson(H) || H.nutrition == 0)
		return FALSE
	return ..()

/datum/martial_art/synthojitsu/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	A.do_attack_animation(D)
	D.apply_damage(5, BURN)
	objective_damage(A, D, 5, BURN)
	D.apply_damage(5, BRUTE)
	objective_damage(A, D, 5, BRUTE)
	A.adjust_nutrition(-10)
	playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] electrocuted [D]!</span>", \
					  "<span class='userdanger'>[A] elecrtrocuted you!</span>")
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	return TRUE

/datum/martial_art/synthojitsu/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D)
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	D.apply_damage(30, STAMINA)
	A.adjust_nutrition(-10)
	playsound(get_turf(D), 'sound/weapons/contractorbatonhit.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] tapped [D]!</span>", \
				  "<span class='userdanger'>[A] tapped you!</span>")
	return TRUE

/obj/item/ipc_combat_upgrade
	name = "IPC combat upgrade"
	desc = "Advanced data storage designed to be compatible with positronic systems.This one include melee algorithms along with overwritten microbattery safety protocols."
	icon = 'icons/obj/ipc_module.dmi'
	icon_state ="viable"
	var/is_used = FALSE

/obj/item/ipc_combat_upgrade/attack_self(mob/user as mob)
	if(!ismachineperson(user) || is_used == TRUE)
		return
	to_chat(user, "<span class='notice'>Installation sequence initialized. It will take some time...</span>")
	if(do_after(user, 100))
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/synthojitsu/F = new/datum/martial_art/synthojitsu(null)
		F.teach(H)
		H.adjustBrainLoss(50)
		H.Weaken(5)
		to_chat(H, "<span class='boldannounce'>Melee algorithms installed. Safety disabled.</span>")
		is_used = TRUE
		desc = "Advanced data storage designed to be compatible with positronic systems.This one include melee algorithms along with overwritten microbattery safety protocols.It's hardlocked"
		name = "IPC combat upgrade"
		icon_state = "unviable"

/datum/martial_art/synthojitsu/explaination_header(user)
	to_chat(user, "<b><i>You reapload some of the basics of synthojitsu.</i></b>")

/datum/martial_art/synthojitsu/explaination_footer(user)
	to_chat(user, "<b><i>In addition, your attacks will deal additional burn damage. Your disarm attempts will exhaust opponent. All attacks and combos will draw your internal battery.</i></b>")

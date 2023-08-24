#define INJECT_LARVA_COOLDOWN 10 MINUTES
#define IMPREGNATION_PROCESS_TIME 5 SECONDS

/obj/effect/proc_holder/spell/alien_spell/impregnate
	name = "Inject Embryo"
	desc = "Impregnate your victim with Alien Embryo."
	action_icon_state = "alien_hide"
	plasma_cost = 0
	base_cooldown = INJECT_LARVA_COOLDOWN

/obj/effect/proc_holder/spell/alien_spell/impregnate/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new
	T.selection_type = SPELL_SELECTION_RANGE
	T.random_target = FALSE
	T.range = 1
	T.use_turf_of_user = TRUE
	T.allowed_type = /mob/living/carbon/human
	return T

/obj/effect/proc_holder/spell/alien_spell/impregnate/valid_target(target, user)
	if(ishuman(target))
		var/mob/living/carbon/human/human = target
		for(var/obj/item/grab/grab in human.grabbed_by)
			if(grab.assailant == user)
				if(human.is_mouth_covered())
					to_chat(user, span_warning("Victim's mouth is obstructed!"))
					return FALSE
				if(!human.check_has_mouth())
					to_chat(user, span_warning("It appears victim doesn't have mouth..."))
					return FALSE
				if(human.is_dead())
					to_chat(user, span_warning("Victim is dead!"))
					return FALSE
				else
					return TRUE
	return FALSE

/obj/effect/proc_holder/spell/alien_spell/impregnate/cast(list/targets, mob/user)
	var/mob/living/carbon/human = targets[1]
	if(!human)
		to_chat(user, span_warning("No victims found"))
		revert_cast(user)
		return

	if(!do_after_once(user, IMPREGNATION_PROCESS_TIME, target = human))
		to_chat(user, span_danger("Victim managed to escape!"))
		revert_cast(user)
		return

	if(!human.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo))
		new /obj/item/organ/internal/body_egg/alien_embryo(human)
		to_chat(user, span_notice("You have impregnated your victim."))
		to_chat(human, span_danger("You feel something is wrong..."))
		return
	else
		to_chat(user, span_danger("Impregnation failed!"))
		revert_cast(user)
		return

#undef INJECT_LARVA_COOLDOWN
#undef IMPREGNATION_PROCESS_TIME

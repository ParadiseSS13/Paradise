/obj/effect/proc_holder/spell/bloodcrawl
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	charge_max = 0
	clothes_req = 0
	cooldown_min = 0
	should_recharge_after_cast = FALSE
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	panel = "Demon"
	var/phased = 0

/obj/effect/proc_holder/spell/bloodcrawl/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.allowed_type = /obj/effect/decal/cleanable
	T.random_target = TRUE
	T.range = 1
	T.use_turf_of_user = TRUE
	return T

/obj/effect/proc_holder/spell/bloodcrawl/valid_target(obj/effect/decal/cleanable/target, user)
	return target.can_bloodcrawl_in()

/obj/effect/proc_holder/spell/bloodcrawl/can_cast(mob/living/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(!isliving(user))
		return FALSE

/obj/effect/proc_holder/spell/bloodcrawl/cast(list/targets, mob/living/user)
	var/obj/effect/decal/cleanable/target = targets[1] // TODO Test this spell
	if(phased)
		if(user.phasein(target))
			phased = 0
	else
		if(user.phaseout(target))
			phased = 1
	start_recharge()

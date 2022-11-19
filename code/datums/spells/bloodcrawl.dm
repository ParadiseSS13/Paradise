/obj/effect/proc_holder/spell/bloodcrawl
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	base_cooldown = 0
	clothes_req = FALSE
	cooldown_min = 0
	should_recharge_after_cast = FALSE
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	panel = "Demon"
	var/allowed_type = /obj/effect/decal/cleanable
	var/phased = FALSE

/obj/effect/proc_holder/spell/bloodcrawl/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.allowed_type = allowed_type
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
	var/atom/target = targets[1]
	if(phased)
		if(user.phasein(target))
			phased = FALSE
	else
		if(user.phaseout(target))
			phased = TRUE
	cooldown_handler.start_recharge()

/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl
	name = "Shadow Crawl"
	desc = "Use darkness to phase out of existence."
	allowed_type = /turf

/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/valid_target(turf/target, user)
	return target.get_lumcount() < 0.2

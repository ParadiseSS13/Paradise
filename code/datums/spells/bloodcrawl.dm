/obj/effect/proc_holder/spell/bloodcrawl
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	charge_max = 0
	clothes_req = 0
	cooldown_min = 0
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	panel = "Demon"
	var/phased = 0

/obj/effect/proc_holder/spell/bloodcrawl/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.allowed_type = /obj/effect/decal/cleanable
	T.range = 1
	return T

/obj/effect/proc_holder/spell/bloodcrawl/valid_target(obj/effect/decal/cleanable/target, user)
	return target.can_bloodcrawl_in()

/obj/effect/proc_holder/spell/bloodcrawl/perform(obj/effect/decal/cleanable/target, recharge = 1, mob/living/user = usr)
	if(istype(user))
		if(phased)
			if(user.phasein(target))
				phased = 0
		else
			if(user.phaseout(target))
				phased = 1
		start_recharge()
		return
	revert_cast()
	to_chat(user, "<span class='warning'>You are unable to blood crawl!</span>")

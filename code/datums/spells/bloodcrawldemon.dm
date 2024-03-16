/obj/effect/proc_holder/spell/bloodcrawldemon
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	base_cooldown = 5 SECONDS
	clothes_req = FALSE
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	panel = "Demon"
	var/allowed_type = /obj/effect/decal/cleanable

/obj/effect/proc_holder/spell/bloodcrawldemon/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.allowed_type = allowed_type
	T.random_target = TRUE
	T.range = 1
	T.use_turf_of_user = TRUE
	return T

/obj/effect/proc_holder/spell/bloodcrawldemon/valid_target(obj/effect/decal/cleanable/target, user)
	return target.can_bloodcrawl_in()

/obj/effect/proc_holder/spell/bloodcrawldemon/cast(list/targets, mob/living/user)
	var/atom/target = targets[1]
	if(isslaughterdemon(user))
		var/mob/living/simple_animal/demon/slaughter_demon/D = user
		if(D.channeling)
			to_chat(D, "You are currently channeling!")
			return
		if(D.phased)
			to_chat(user, "CALLED THE PHASED PROC")
			D.channel_target = get_turf(target)
			ADD_TRAIT(D, TRAIT_IMMOBILIZED, "channelingblood")
			D.phaseoutchaneltime = world.time + 20
			D.channeling = TRUE
			D.icon_state = "daemonchannelling"
			cooldown_handler.recharge_duration = 5 SECONDS
			cooldown_handler.start_recharge(5 SECONDS)
			return
		if(!D.phased)
			to_chat(D, "You begin to channel back into reality!")
			D.channel_target = get_turf(target)
			ADD_TRAIT(D, TRAIT_IMMOBILIZED, "channelingblood")
			D.channeling = TRUE
			new /obj/effect/temp_visual/bloodstorm(get_turf(target))
			D.phaseinchaneltime = world.time + 50
			cooldown_handler.recharge_duration = 20 SECONDS
			cooldown_handler.start_recharge(20 SECONDS)
			return


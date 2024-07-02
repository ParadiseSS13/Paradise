/datum/spell/bloodcrawldemon
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	base_cooldown = 5 SECONDS
	clothes_req = FALSE
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	var/allowed_type = /obj/effect/decal/cleanable

/datum/spell/bloodcrawldemon/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.allowed_type = allowed_type
	T.random_target = TRUE
	T.range = 1
	T.use_turf_of_user = TRUE
	return T

/datum/spell/bloodcrawldemon/valid_target(obj/effect/decal/cleanable/target, user)
	return target.can_bloodcrawl_in()

/datum/spell/bloodcrawldemon/cast(list/targets, mob/living/user)
	var/atom/target = targets[1]
	if(!isslaughterdemon(user))
		return
	var/mob/living/simple_animal/demon/slaughter_demon/D = user
	if(D.channeling)
		return
	if(D.phased)
		to_chat(D, "<span class='notice'>You begin to channel yourself into the blood!</span>")
		D.channel_target = get_turf(target)
		ADD_TRAIT(D, TRAIT_IMMOBILIZED, "channelingblood")
		D.phase_out_chanel_time = world.time + 2 SECONDS
		D.channeling = TRUE
		D.icon_state = "daemonchanneling"
		cooldown_handler.recharge_duration = 5 SECONDS
		cooldown_handler.start_recharge(5 SECONDS)
	else
		to_chat(D, "<span class='notice'>You begin to channel back into reality!</span>")
		D.channel_target = get_turf(target)
		ADD_TRAIT(D, TRAIT_IMMOBILIZED, "channelingblood")
		D.channeling = TRUE
		new /obj/effect/temp_visual/bloodstorm(get_turf(target))
		D.phase_in_chanel_time = world.time + 5 SECONDS
		cooldown_handler.recharge_duration = 20 SECONDS
		cooldown_handler.start_recharge(20 SECONDS)


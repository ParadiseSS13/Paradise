/datum/vampire_passive/increment_thrall_cap/on_apply(datum/antagonist/vampire/V)
	V.subclass.thrall_cap++
	gain_desc = "You can now thrall one more person, up to a maximum of [V.subclass.thrall_cap]"


/datum/vampire_passive/increment_thrall_cap/two


/datum/vampire_passive/increment_thrall_cap/three


/obj/effect/proc_holder/spell/vampire/enthrall
	name = "Enthrall"
	desc = "You use a large portion of your power to sway those loyal to none to be loyal to you only."
	gain_desc = "You have gained the ability to thrall people to your will."
	action_icon_state = "vampire_enthrall"
	required_blood = 150
	deduct_blood_on_cast = FALSE


/obj/effect/proc_holder/spell/vampire/enthrall/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 1
	T.click_radius = 0
	return T


/obj/effect/proc_holder/spell/vampire/enthrall/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/mob/living/target = targets[1]
	user.visible_message(span_warning("[user] bites [target]'s neck!"), \
						span_warning("You bite [target]'s neck and begin the flow of power."))
	to_chat(target, span_warning("You feel the tendrils of evil invade your mind."))
	if(do_mob(user, target, 15 SECONDS))
		if(can_enthrall(user, target))
			handle_enthrall(user, target)
			var/datum/spell_handler/vampire/V = custom_handler
			var/blood_cost = V.calculate_blood_cost(vampire)
			vampire.bloodusable -= blood_cost //we take the blood after enthralling, not before
	else
		revert_cast(user)
		to_chat(user, span_warning("You or your target moved."))


/obj/effect/proc_holder/spell/vampire/enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/C)
	. = FALSE
	if(!C)
		CRASH("target was null while trying to vampire enthrall, attacker is [user] [user.key] \ref[user]")

	if(!user.mind.som)
		CRASH("Dantalion Thrall datum ended up null.")

	if(!ishuman(C))
		to_chat(user, span_warning("You can only enthrall sentient humanoids!"))
		return

	if(!C.mind)
		to_chat(user, span_warning("[C.name]'s mind is not there for you to enthrall."))
		return

	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V.subclass.thrall_cap <= length(user.mind.som.serv))
		to_chat(user, span_warning("You don't have enough power to enthrall any more people!"))
		return

	if(ismindshielded(C) || isvampire(C) || isvampirethrall(C) || C.mind.has_antag_datum(/datum/antagonist/mindslave))
		C.visible_message(span_warning("[C] seems to resist the takeover!"), \
						span_notice("You feel a familiar sensation in your skull that quickly dissipates."))
		return

	if(C.mind.isholy)
		C.visible_message(span_warning("[C] seems to resist the takeover!"), \
						span_notice("Your faith in [SSticker.Bible_deity_name] has kept your mind clear of all evil."))
		return

	return TRUE


/obj/effect/proc_holder/spell/vampire/enthrall/proc/handle_enthrall(mob/living/user, mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE

	var/greet_text = "<b>You have been Enthralled by [user.real_name]. Follow [user.p_their()] every command.</b>"
	H.mind.add_antag_datum(new /datum/antagonist/mindslave/thrall(user.mind, greet_text))
	if(jobban_isbanned(H, ROLE_VAMPIRE))
		SSticker.mode.replace_jobbanned_player(H, SPECIAL_ROLE_VAMPIRE_THRALL)
	H.Stun(4 SECONDS)
	user.create_log(CONVERSION_LOG, "vampire enthralled", H)
	H.create_log(CONVERSION_LOG, "was vampire enthralled", user)


/obj/effect/proc_holder/spell/vampire/thrall_commune
	name = "Commune"
	desc = "Talk to your thralls telepathically."
	gain_desc = "You have gained the ability to commune with your thralls."
	action_icon_state = "vamp_communication"
	create_attack_logs = FALSE
	base_cooldown = 2 SECONDS


/obj/effect/proc_holder/spell/vampire/thrall_commune/create_new_handler() //so thralls can use it
	return


/datum/spell_targeting/select_vampire_network/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom) // Returns the vampire and their thralls. If user is a thrall then it will look up their master's network
	var/list/mob/living/targets = list()
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire) // if the user is a vampire

	if(!V)
		for(var/datum/mind/M in user.mind.som.masters) // if the user is a thrall
			V = M.has_antag_datum(/datum/antagonist/vampire)
			if(V)
				break

	if(!V)
		return

	if(!V.owner.som) // I hate som
		stack_trace("Dantalion Thrall datum ended up null.")
		return

	for(var/datum/mind/thrall in V.owner.som.serv)
		targets += thrall.current

	targets += V.owner.current
	return targets


/obj/effect/proc_holder/spell/vampire/thrall_commune/create_new_targeting()
	var/datum/spell_targeting/select_vampire_network/T = new
	return T


/obj/effect/proc_holder/spell/vampire/thrall_commune/cast(list/targets, mob/user)
	var/input = stripped_input(user, "Enter a message to relay to the other thralls", "Thrall Commune", "")
	if(!input)
		revert_cast(user)
		return

	// if admins give this to a non vampire/thrall it is not my problem
	var/is_thrall = isvampirethrall(user)
	var/title = is_thrall ? "(Vampire Thrall) [user.real_name]" : "<span class='dantalion'><font size='3'>(Vampire Master) [user.real_name]</font></span>"
	var/message = is_thrall ? "<span class='dantalion'>[input]</span>" : "<span class='dantalion'><font size='3'><b>[input]</b></font></span>"

	for(var/mob/player in targets)
		to_chat(player, "<i><span class='game say'>Thrall Commune, <span class='name'>[title]</span> telepathizes, [message]</span><i>")

	for(var/mob/ghost in GLOB.dead_mob_list)
		to_chat(ghost, "<i><span class='game say'>Thrall Commune, <span class='name'>[title]</span> ([ghost_follow_link(user, ghost)]) telepathizes, [message]</span><i>")

	log_say("(DANTALION) [input]", user)
	user.create_log(SAY_LOG, "(DANTALION) [input]")


/obj/effect/proc_holder/spell/vampire/pacify
	name = "Pacify"
	desc = "Pacify a target temporarily, making them unable to cause harm."
	gain_desc = "You have gained the ability to pacify someone's harmful tendencies, preventing them from doing any physical harm to anyone."
	action_icon_state = "pacify"
	base_cooldown = 10 SECONDS
	required_blood = 10
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/vampire/pacify/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 7
	T.click_radius = 1
	T.allowed_type = /mob/living/carbon/human
	return T


/obj/effect/proc_holder/spell/vampire/pacify/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		to_chat(H, span_notice("You suddenly feel very calm..."))
		SEND_SOUND(H, 'sound/hallucinations/i_see_you1.ogg')
		H.apply_status_effect(STATUS_EFFECT_PACIFIED)


/obj/effect/proc_holder/spell/vampire/switch_places
	name = "Subspace Swap"
	desc = "Switch positions with a target. Also slows down the victim and make them hallucinate."
	gain_desc = "You have gained the ability to switch positions with a targeted mob."
	centcom_cancast = FALSE
	action_icon_state = "subspace_swap"
	base_cooldown = 5 SECONDS
	required_blood = 15
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/vampire/switch_places/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 7
	T.click_radius = 1
	T.try_auto_target = FALSE
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/vampire/switch_places/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	target.forceMove(user_turf)
	user.forceMove(target_turf)

	if(target.affects_vampire(user))
		target.Slowed(4 SECONDS)
		SEND_SOUND(target, 'sound/hallucinations/behind_you1.ogg')
		target.flash_eyes(2, TRUE, affect_silicon = TRUE) // flash to give them a second to lose track of who is who
		new /obj/effect/hallucination/delusion(user_turf, target, duration = 15 SECONDS, skip_nearby = FALSE)


/obj/effect/proc_holder/spell/vampire/self/decoy
	name = "Deploy Decoy"
	desc = "Briefly turn invisible and deploy a decoy illusion to fool your prey."
	gain_desc = "You have gained the ability to turn invisible and create decoy illusions."
	action_icon_state = "decoy"
	required_blood = 30
	base_cooldown = 20 SECONDS
	var/duration = 6 SECONDS


/obj/effect/proc_holder/spell/vampire/self/decoy/cast(list/targets, mob/user)
	var/user_turf = get_turf(user)
	var/mob/living/simple_animal/hostile/illusion/escape/E = new(user_turf)
	E.Copy_Parent(user, duration, 20)
	E.GiveTarget(user) //so it starts running right away
	E.Goto(user, E.move_to_delay, E.minimum_distance)
	user.make_invisible()
	playsound(user_turf, 'sound/hallucinations/look_up1.ogg', 50, TRUE)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, reset_visibility)), duration)


/obj/effect/proc_holder/spell/vampire/rally_thralls
	name = "Rally Thralls"
	desc = "Removes all incapacitating effects from your nearby thralls."
	gain_desc = "You have gained the ability to remove all incapacitating effects from nearby thralls."
	action_icon_state = "thralls_up"
	required_blood = 40
	base_cooldown = 30 SECONDS


/obj/effect/proc_holder/spell/vampire/rally_thralls/create_new_targeting()
	var/datum/spell_targeting/aoe/thralls/T = new
	T.allowed_type = /mob/living/carbon/human
	T.range = 7
	return T


/datum/spell_targeting/aoe/thralls/valid_target(target, user, obj/effect/proc_holder/spell/spell, check_if_in_range)
	if(!isvampirethrall(target))
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/rally_thralls/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		var/image/I = image('icons/effects/vampire_effects.dmi', "rallyoverlay", layer = EFFECTS_LAYER)
		playsound(H, 'sound/magic/staff_healing.ogg', 50)
		H.remove_CC()
		H.add_overlay(I)
		addtimer(CALLBACK(H, TYPE_PROC_REF(/atom, cut_overlay), I), 6 SECONDS) // this makes it obvious who your thralls are for a while.


/obj/effect/proc_holder/spell/vampire/self/share_damage
	name = "Blood Bond"
	desc = "Creates a net between you and your nearby thralls that evenly shares all damage received."
	gain_desc = "You have gained the ability to share damage between you and your thralls."
	action_icon_state = "blood_bond"
	required_blood = 5


/obj/effect/proc_holder/spell/vampire/self/share_damage/cast(list/targets, mob/living/user)
	var/datum/status_effect/thrall_net/T = user.has_status_effect(STATUS_EFFECT_THRALL_NET)
	if(!T)
		user.apply_status_effect(STATUS_EFFECT_THRALL_NET, user.mind.has_antag_datum(/datum/antagonist/vampire))
		return
	qdel(T)


/obj/effect/proc_holder/spell/vampire/hysteria
	name = "Mass Hysteria"
	desc = "Casts a powerful illusion to make everyone nearby perceive others to looks like random animals after briefly blinding them. Also slows affected victims."
	gain_desc = "You have gained the ability to make everyone nearby perceive others to looks like random animals after briefly blinding them."
	action_icon_state = "hysteria"
	required_blood = 40
	base_cooldown = 60 SECONDS


/obj/effect/proc_holder/spell/vampire/hysteria/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.range = 8
	T.allowed_type = /mob/living/carbon/human
	return T


/obj/effect/proc_holder/spell/vampire/hysteria/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		if(!H.affects_vampire(user))
			continue

		SEND_SOUND(H, 'sound/hallucinations/over_here1.ogg')
		H.Slowed(4 SECONDS)
		H.flash_eyes(2, TRUE) // flash to give them a second to lose track of who is who
		new /obj/effect/hallucination/delusion(get_turf(user), H, skip_nearby = FALSE)


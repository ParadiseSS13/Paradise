/proc/isvampirethrall(mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/mindslave/thrall)

/datum/vampire_passive/increment_thrall_cap/on_apply(datum/antagonist/vampire/V)
	V.subclass.thrall_cap++
	gain_desc = "You can now thrall one more person, up to a maximum of [V.subclass.thrall_cap]"

/datum/vampire_passive/increment_thrall_cap/two

/datum/vampire_passive/increment_thrall_cap/three

/obj/effect/proc_holder/spell/vampire/enthrall
	name = "Enthrall (150)"
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
	user.visible_message("<span class='warning'>[user] bites [target]'s neck!</span>", "<span class='warning'>You bite [target]'s neck and begin the flow of power.</span>")
	to_chat(target, "<span class='warning'>You feel the tendrils of evil invade your mind.</span>")
	if(do_mob(user, target, 15 SECONDS))
		if(can_enthrall(user, target))
			handle_enthrall(user, target)
			var/datum/spell_handler/vampire/V = custom_handler
			var/blood_cost = V.calculate_blood_cost(vampire)
			vampire.bloodusable -= blood_cost //we take the blood after enthralling, not before
	else
		revert_cast(user)
		to_chat(user, "<span class='warning'>You or your target moved.</span>")

/obj/effect/proc_holder/spell/vampire/enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/C)
	. = FALSE
	if(!C)
		CRASH("target was null while trying to vampire enthrall, attacker is [user] [user.key] \ref[user]")
	if(!user.mind.som)
		CRASH("Dantalion Thrall datum ended up null.")
	if(!ishuman(C))
		to_chat(user, "<span class='warning'>You can only enthrall sentient humanoids!</span>")
		return
	if(!C.mind)
		to_chat(user, "<span class='warning'>[C.name]'s mind is not there for you to enthrall.</span>")
		return

	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V.subclass.thrall_cap <= length(user.mind.som.serv))
		to_chat(user, "<span class='warning'>You don't have enough power to enthrall any more people!</span>")
		return
	if(ismindshielded(C) || C.mind.has_antag_datum(/datum/antagonist/vampire) || C.mind.has_antag_datum(/datum/antagonist/mindslave))
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>", "<span class='notice'>You feel a familiar sensation in your skull that quickly dissipates.</span>")
		return
	if(HAS_MIND_TRAIT(C, TRAIT_HOLY))
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>", "<span class='notice'>Your faith in [SSticker.Bible_deity_name] has kept your mind clear of all evil.</span>")
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
	var/title = isvampirethrall(user) ? "Thrall" : "<b>Vampire Master</b>" // if admins give this to a non vampire/thrall it is not my problem
	var/full_title = "[user.real_name] ([title])"
	for(var/mob/M in targets)
		to_chat(M, "<span class='dantalion'>[full_title]: [input]</span>")
	for(var/mob/M in GLOB.dead_mob_list)
		to_chat(M, "<span class='dantalion'>[full_title] ([ghost_follow_link(user, ghost=M)]): [input] </span>")
	log_say("(DANTALION) [input]", user)
	user.create_log(SAY_LOG, "(DANTALION) [input]")

/obj/effect/proc_holder/spell/vampire/pacify
	name = "Pacify (10)"
	desc = "Pacify a target temporarily, making them unable to cause harm."
	gain_desc = "You have gained the ability to pacify someone's harmful tendencies, preventing them from doing any physical harm to anyone."
	action_icon_state = "pacify"
	base_cooldown = 30 SECONDS
	required_blood = 10

/obj/effect/proc_holder/spell/vampire/pacify/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 7
	T.click_radius = 1
	T.allowed_type = /mob/living/carbon/human
	return T

/obj/effect/proc_holder/spell/vampire/pacify/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		H.apply_status_effect(STATUS_EFFECT_PACIFIED)

/obj/effect/proc_holder/spell/vampire/switch_places
	name = "Subspace Swap (30)"
	desc = "Switch positions with a target."
	gain_desc = "You have gained the ability to switch positions with a targeted mob."
	centcom_cancast = FALSE
	action_icon_state = "subspace_swap"
	base_cooldown = 30 SECONDS
	required_blood = 30

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

/obj/effect/proc_holder/spell/vampire/self/decoy
	name = "Deploy Decoy (30)"
	desc = "Briefly turn invisible and deploy a decoy illusion to fool your prey."
	gain_desc = "You have gained the ability to turn invisible and create decoy illusions."
	action_icon_state = "decoy"
	required_blood = 30
	base_cooldown = 40 SECONDS

/obj/effect/proc_holder/spell/vampire/self/decoy/cast(list/targets, mob/user)
	var/mob/living/simple_animal/hostile/illusion/escape/E = new(get_turf(user))
	E.Copy_Parent(user, 20, 20)
	E.GiveTarget(user) //so it starts running right away
	E.Goto(user, E.move_to_delay, E.minimum_distance)
	user.make_invisible()
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, reset_visibility)), 6 SECONDS)

/obj/effect/proc_holder/spell/vampire/rally_thralls
	name = "Rally Thralls (100)"
	desc = "Removes all incapacitating effects from your nearby thralls."
	gain_desc = "You have gained the ability to remove all incapacitating effects from nearby thralls."
	action_icon_state = "thralls_up"
	required_blood = 100
	base_cooldown = 100 SECONDS

/obj/effect/proc_holder/spell/vampire/rally_thralls/create_new_targeting()
	var/datum/spell_targeting/aoe/thralls/A = new
	A.allowed_type = /mob/living/carbon/human
	A.range = 7
	return A

/datum/spell_targeting/aoe/thralls/valid_target(target, user, obj/effect/proc_holder/spell/spell, check_if_in_range)
	if(!isvampirethrall(target))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/vampire/rally_thralls/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		var/image/I = image('icons/effects/vampire_effects.dmi', "rallyoverlay", layer = EFFECTS_LAYER)
		playsound(H, 'sound/magic/staff_healing.ogg', 30)
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
	name = "Mass Hysteria (70)"
	desc = "Casts a powerful illusion to make everyone nearby perceive others to looks like random animals after briefly blinding them."
	gain_desc = "You have gained the ability to make everyone nearby perceive others to looks like random animals after briefly blinding them."
	action_icon_state = "hysteria"
	required_blood = 70
	base_cooldown = 180 SECONDS

/obj/effect/proc_holder/spell/vampire/hysteria/create_new_targeting()
	var/datum/spell_targeting/aoe/A = new
	A.range = 8
	A.allowed_type = /mob/living/carbon/human
	return A

/obj/effect/proc_holder/spell/vampire/hysteria/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		if(!H.affects_vampire(user))
			continue
		H.flash_eyes(1, TRUE) // flash to give them a second to lose track of who is who
		new /obj/effect/hallucination/delusion/long(get_turf(user), H)

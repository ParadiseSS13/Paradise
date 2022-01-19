/proc/isvampirethrall(mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/mindslave/thrall)

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
	for(var/mob/living/target in targets)
		user.visible_message("<span class='warning'>[user] bites [target]'s neck!</span>", "<span class='warning'>You bite [target]'s neck and begin the flow of power.</span>")
		to_chat(target, "<span class='warning'>You feel the tendrils of evil invade your mind.</span>")
		if(do_mob(user, target, 5 SECONDS))
			if(can_enthrall(user, target))
				handle_enthrall(user, target)
				var/datum/spell_handler/vampire/V = custom_handler
				var/blood_cost = V.calculate_blood_cost(vampire)
				vampire.bloodusable -= blood_cost //we take the blood after enthralling, not before
			else
				revert_cast(user)
				to_chat(user, "<span class='warning'>You or your target either moved or you dont have enough usable blood.</span>")

/obj/effect/proc_holder/spell/vampire/enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/C)
	if(!C)
		log_runtime(EXCEPTION("something bad happened on enthralling a mob, attacker is [user] [user.key] \ref[user]"), user)
		return FALSE
	if(!ishuman(C))
		to_chat(user, "<span class='warning'>You can only enthrall sentient humanoids!</span>")
		return FALSE
	if(!C.mind)
		to_chat(user, "<span class='warning'>[C.name]'s mind is not there for you to enthrall.</span>")
		return FALSE

	var/enthrall_safe = FALSE
	for(var/obj/item/implant/mindshield/L in C)
		if(L && L.implanted)
			enthrall_safe = TRUE
			break

	if(enthrall_safe || C.mind.has_antag_datum(/datum/antagonist/vampire) || C.mind.has_antag_datum(/datum/antagonist/mindslave))
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>", "<span class='notice'>You feel a familiar sensation in your skull that quickly dissipates.</span>")
		return FALSE
	if(C.mind.isholy)
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>", "<span class='notice'>Your faith in [SSticker.Bible_deity_name] has kept your mind clear of all evil.</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/vampire/enthrall/proc/handle_enthrall(mob/living/user, mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE

	var/greet_text = "You have been Enthralled by [user.real_name]. Follow [user.p_their()] every command."
	H.mind.add_antag_datum(new /datum/antagonist/mindslave/thrall(user.mind, greet_text))
	H.Stun(2)
	add_attack_logs(user, H, "Vampire-thralled")

/obj/effect/proc_holder/spell/vampire/thrall_commune
	name = "Commune"
	desc = ":^ Thrall gang lmao"


/datum/spell_targeting/select_vampire_thralls/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	var/list/mob/living/targets = list()
	if(user.mind.has_antag_datum(/datum/antagonist/vampire))
		for(var/datum/mind/M as anything in user.mind.som.serv)
			if(!M.current) // convert to valid_target
				continue
			targets += M.current
	else
		for(var/datum/mind/M as anything in user.mind.som.masters)
			if(!M.current) // convert to valid_target
				continue
			targets += M.current
			for(var/datum/mind/MI as anything in user.mind.som.serv)
				if(!MI.current) // convert to valid_target
					continue
				if(MI.current == user) // convert to valid_target
					continue
				targets += MI.current
	return targets


/obj/effect/proc_holder/spell/vampire/thrall_commune/create_new_targeting()
	var/datum/spell_targeting/select_vampire_thralls/T = new
	T.range = 500
	return T

/obj/effect/proc_holder/spell/vampire/thrall_commune/cast(list/targets, mob/user)
	var/input = stripped_input(user, "Please choose a message to tell to the other thralls.", "Thrall Commune", "")
	if(!input)
		return
	var/message = "[user.real_name]:[input]"

	for(var/mob/M in targets)
		to_chat(M, "<span class='shadowling>[message]</span>")

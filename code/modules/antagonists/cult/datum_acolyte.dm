/datum/antagonist/acolyte
	name = "Cultist Acolyte"
	job_rank = ROLE_ACOLYTE
	special_role = SPECIAL_ROLE_ACOLYTE
	antag_hud_name = "hudacolyte"
	antag_hud_type = ANTAG_HUD_CULT
	clown_gain_text = "A dark power has allowed you to overcome your clownish nature, letting you wield weapons without harming yourself."
	clown_removal_text = "You are free of the dark power suppressing your clownish nature. You are clumsy again! Honk!"
	clown_text_span_class = "cultitalic"
	wiki_page_name = "Cultist"
	boss_title = "Dark Emination"
	/// Number of times the acolyte can use a revive rune to heal.
	var/revives_left = 3

/datum/antagonist/acolyte/on_gain()
	..()
	owner.current.faction |= "cult"
	add_cult_actions()
	SEND_SOUND(owner.current, sound('sound/ambience/antag/bloodcult.ogg'))

	if(!ishuman(owner.current))
		return FALSE
	give_item(/obj/item/melee/cultblade/dagger)

/datum/antagonist/acolyte/detach_from_owner()
	if(!owner.current)
		return ..()
	owner.current.faction -= "cult"
	owner.current.create_log(CONVERSION_LOG, "Deconverted from an acolyte") // Yes, this is its own log, instead of the default MISC_LOG.
	for(var/datum/action/innate/cult/C in owner.current.actions)
		qdel(C)

	if(!ishuman(owner.current))
		return ..()
	var/mob/living/carbon/human/H = owner.current

	for(var/I in H.contents)
		if(is_type_in_list(I, CULT_CLOTHING))
			H.drop_item_to_ground(I)
	return ..()

/datum/antagonist/acolyte/give_objectives()
	add_antag_objective(/datum/objective/acolyte_sacrifice)

	while(length(objective_holder.get_objectives()) < 3)
		var/datum/objective/O = roll_single_human_objective()
		if(ispath(O, /datum/objective/kill_pet) || ispath(O, /datum/objective/protect))
			continue
		if(ispath(O, /datum/objective/assassinate))
			O = /datum/objective/acolyte_sacrifice
		add_antag_objective(O)

	if(prob(20)) // 20% chance of getting survive. 70% chance of getting escape.
		add_antag_objective(/datum/objective/survive)
	else if(prob(10))
		return
	else
		add_antag_objective(/datum/objective/escape)

/datum/antagonist/acolyte/add_owner_to_gamemode()
	SSticker.mode.acolytes |= owner

/datum/antagonist/acolyte/remove_owner_from_gamemode()
	SSticker.mode.acolytes -= owner

/datum/antagonist/acolyte/greet()
	return "<span class='cultlarge'>You catch a glimpse of the Realm of [GET_CULT_DATA(entity_name, "this is a bug at this point")], [GET_CULT_DATA(entity_title3, "I dont know what else to write")]. \
						You now see how flimsy the world is, you see that it should be open to the knowledge of [GET_CULT_DATA(entity_name, "making a bug report")].</span>"

/datum/antagonist/acolyte/farewell()
	if(owner && owner.current)
		owner.current.visible_message(SPAN_CULT("[owner.current] looks like [owner.current.p_they()] just reverted to [owner.current.p_their()] old faith!"),
			SPAN_USERDANGER("An unfamiliar white light flashes through your mind, cleansing the taint of [GET_CULT_DATA(entity_title1, "Nar'Sie")] and the memories of your time as their servant with it."))

/datum/antagonist/acolyte/on_body_transfer(old_body, new_body)
	add_cult_actions()

/datum/antagonist/acolyte/proc/add_cult_actions()
	if(!owner.current)
		return
	if(ishuman(owner.current))
		var/datum/action/innate/cult/blood_magic/magic = new
		var/datum/action/innate/cult/use_dagger/dagger = new
		magic.Grant(owner.current)
		dagger.Grant(owner.current)

	owner.current.update_action_buttons(TRUE)

/datum/antagonist/acolyte/proc/give_item(obj/item/item_path)
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current
	var/list/slots = list(
		"backpack" = ITEM_SLOT_IN_BACKPACK,
		"left pocket" = ITEM_SLOT_LEFT_POCKET,
		"right pocket" = ITEM_SLOT_RIGHT_POCKET
	)

	var/where = H.equip_in_one_of_slots(new item_path(H), slots)
	if(where)
		to_chat(H, SPAN_DANGER("You have \a [initial(item_path.name)] in your [where]."))
		if(H.s_active) // Update whatever inventory they have open.
			H.s_active.orient2hud(H)
			H.s_active.show_to(H)
		return TRUE
	to_chat(H, SPAN_USERDANGER("Unfortunately, you weren't able to get \a [initial(item_path.name)]. This is very bad and you should adminhelp immediately (press F1)."))
	return FALSE

/datum/game_mode/proc/auto_declare_completion_acolyte()
	if(length(acolytes))
		var/list/text = list("<br><font size=3>[SPAN_BOLD("The acolytes were:")]</font>")
		for(var/datum/mind/acolyte in acolytes)
			var/acolyte_win = TRUE

			text += "<br>[acolyte.get_display_key()] was [acolyte.name] and "
			if(acolyte.current)
				if(acolyte.current.stat == DEAD)
					text += "[SPAN_BOLD("died")]!"
				else
					text += SPAN_BOLD("survived!")
				if(acolyte.current.real_name != acolyte.name)
					text += " as [acolyte.current.real_name]"
				else
					text += "!"
			else
				text += SPAN_BOLD("had [acolyte.p_their()] body destroyed!")

			// Removed sanity if(acolyte) because we -want- a runtime to inform us that the acolytes list is incorrect and needs to be fixed.
			var/datum/antagonist/acolyte/A = acolyte.has_antag_datum(/datum/antagonist/acolyte)

			var/list/all_objectives = A.get_antag_objectives(include_team = FALSE)

			if(length(all_objectives))
				var/count = 1
				for(var/datum/objective/objective in all_objectives)
					text += "<br><b>Objective #[count]</b>: [objective.explanation_text]"
					if(objective.check_completion())
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/S = objective
							SSblackbox.record_feedback("nested tally", "acolyte_steal_objective", 1, list("Steal [S.steal_target]", "SUCCESS"))
						else
							SSblackbox.record_feedback("nested tally", "acolyte_objective", 1, list("[objective.type]", "SUCCESS"))
					else
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/S = objective
							SSblackbox.record_feedback("nested tally", "acolyte_steal_objective", 1, list("Steal [S.steal_target]", "FAIL"))
						else
							SSblackbox.record_feedback("nested tally", "acolyte_objective", 1, list("[objective.type]", "FAIL"))
						acolyte_win = FALSE
					count++

			if(acolyte_win)
				SSblackbox.record_feedback("tally", "acolyte_success", 1, "SUCCESS")
			else
				SSblackbox.record_feedback("tally", "acolyte_success", 1, "FAIL")
		return text.Join("")

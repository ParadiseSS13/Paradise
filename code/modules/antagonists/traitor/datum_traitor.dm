#define TRAITOR_HUMAN "human"
#define TRAITOR_AI	  "AI"

// For "Actual traitors"
/datum/antagonist/traitor
	name = "Traitor"
	roundend_category = "traitors"
	job_rank = ROLE_TRAITOR
	var/special_role = SPECIAL_ROLE_TRAITOR
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	var/should_equip = TRUE
	var/traitor_kind = TRAITOR_HUMAN


/datum/antagonist/traitor/on_gain()
	if(owner.current && isAI(owner.current))
		traitor_kind = TRAITOR_AI

	var/datum/mindslaves/slaved = new()
	slaved.masters += owner
	owner.som = slaved //we MIGHT want to mindslave someone
	SSticker.mode.traitors += owner
	owner.special_role = special_role

	if(give_objectives)
		forge_traitor_objectives()
	if(!silent)
		greet()
	apply_innate_effects()
	update_traitor_icons_added()
	finalize_traitor()


/datum/antagonist/traitor/on_removal()
	//Remove malf powers.
	if(traitor_kind == TRAITOR_AI && owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.clear_zeroth_law()
		A.common_radio.channels.Remove("Syndicate")  // De-traitored AIs can still state laws over the syndicate channel without this
		A.laws.sorted_laws = A.laws.inherent_laws.Copy() // AI's 'notify laws' button will still state a law 0 because sorted_laws contains it
		A.show_laws()
		A.remove_malf_abilities()
		QDEL_NULL(A.malf_picker)

	if(owner.som)
		var/datum/mindslaves/slaved = owner.som
		slaved.masters -= owner
		slaved.serv -= owner
		owner.som = null
		slaved.leave_serv_hud(owner)

	SSticker.mode.traitors -= owner
	owner.special_role = null
	remove_innate_effects()
	update_traitor_icons_removed()

	if(!silent && owner.current)
		antag_memory = ""
		to_chat(owner.current,"<span class='userdanger'> You are no longer a [special_role]! </span>")
	..()


/datum/antagonist/traitor/apply_innate_effects()
	. = ..()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			to_chat(traitor_mob, "<span class='warning'>Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.</span>")
			traitor_mob.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(traitor_mob)


/datum/antagonist/traitor/remove_innate_effects()
	. = ..()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			to_chat(traitor_mob, "<span class='warning'>You lose your syndicate training and return to your own clumsy, clownish self.</span>")
			traitor_mob.mutations.Add(CLUMSY)
			for(var/datum/action/innate/A in traitor_mob.actions)
				if(istype(A, /datum/action/innate/toggle_clumsy))
					A.Remove(traitor_mob)

/datum/antagonist/traitor/proc/forge_traitor_objectives()
	switch(traitor_kind)
		if(TRAITOR_AI)
			forge_ai_objectives()
		else
			forge_human_objectives()


/datum/antagonist/traitor/proc/forge_human_objectives()
	var/is_hijacker = prob(10)
	var/martyr_chance = prob(20)
	var/objective_count = is_hijacker 			//Hijacking counts towards number of objectives
	if(!SSticker.mode.exchange_blue && SSticker.mode.traitors.len >= 8) 	//Set up an exchange if there are enough traitors
		if(!SSticker.mode.exchange_red)
			SSticker.mode.exchange_red = owner
		else
			SSticker.mode.exchange_blue = owner
			assign_exchange_role(SSticker.mode.exchange_red)
			assign_exchange_role(SSticker.mode.exchange_blue)
		objective_count += 1					//Exchange counts towards number of objectives


	var/objective_amount = config.traitor_objectives_amount

	if(is_hijacker && objective_count <= objective_amount) //Don't assign hijack if it would exceed the number of objectives set in config.traitor_objectives_amount
		if (!(locate(/datum/objective/hijack) in objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
			return

	// See if they get the global target.
	if(objective_count <= objective_amount && length(SSticker.mode.traitors) >= 3 && SSticker.mode.VIP_target != owner)
		var/assassin_count = length(SSticker.mode.protect_target_assassins)
		var/protector_count = length(SSticker.mode.protect_target_protectors)

		// Make a new protector if there is no target set yet (first protector) or at a 20% chance if there are less or equal protectors compared to assassins
		if(!SSticker.mode.VIP_target || (protector_count <= assassin_count && prob(10)))
			create_objective(/datum/objective/protect/vip)
			objective_count++
		else if(assassin_count < protector_count && prob(50))
			// Create a new assassin
			create_objective(/datum/objective/assassinate/vip)
			objective_count++

	for(var/i = objective_count, i < objective_amount)
		if(forge_single_objective())
			i++ // Increment if the creation of the objective succeeds

	var/martyr_compatibility = 1 //You can't succeed in stealing if you're dead.
	for(var/datum/objective/O in owner.objectives)
		if(!O.martyr_compatible)
			martyr_compatibility = 0
			break

	if(martyr_compatibility && martyr_chance)
		var/datum/objective/die/martyr_objective = new
		martyr_objective.owner = owner
		add_objective(martyr_objective)
		return

	if(!(locate(/datum/objective/escape) in objectives))
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return


/datum/antagonist/traitor/proc/forge_ai_objectives()
	var/objective_count = 0
	var/try_again = TRUE

	if(forge_single_objective())
		objective_count++

	for(var/i = objective_count, i < config.traitor_objectives_amount)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.find_target()
		if("[kill_objective.target]" in assigned_targets)	// In the rare case the game can't find a target for the AI thats not a duplicate
			if(try_again)						            // It will attempt to location another target ONCE
				try_again = FALSE							// This code will really only come into play on lowpop rounds where getting duplicate targets is more common
				continue
		assigned_targets.Add("[kill_objective.target]")
		add_objective(kill_objective)
		i += 1
	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = owner
	add_objective(survive_objective)

/**
 * Tries to create a new objective depending on the traitor_kind
 * Will return the objective if it succeeds. Will return null if it fails
 */
/datum/antagonist/traitor/proc/forge_single_objective()
	switch(traitor_kind)
		if(TRAITOR_AI)
			return forge_single_AI_objective()
		else
			return forge_single_human_objective()

/**
 * Tries to create a random new objective
 * Will return the objective if it succeeds. Will return null if it fails
 */
/datum/antagonist/traitor/proc/forge_single_human_objective()
	var/objective_type
	if(prob(50))
		var/list/active_ais = active_ais()
		if(length(active_ais) && prob(100 / length(GLOB.player_list)))
			objective_type = /datum/objective/destroy
		else if(prob(5))
			objective_type = /datum/objective/debrain
		else if(prob(30))
			objective_type = /datum/objective/maroon
		else
			objective_type = /datum/objective/assassinate
	else
		objective_type = /datum/objective/steal

	return create_objective(objective_type)

/datum/antagonist/traitor/proc/forge_single_AI_objective()
	var/datum/objective/block/block_objective = new
	block_objective.owner = owner
	add_objective(block_objective)
	return block_objective


/datum/antagonist/traitor/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are a [owner.special_role]!</font></B>")
	if(!LAZYLEN(owner.objectives))   // Remove "owner" when objectives are handled in the datum
		to_chat(owner.current, "<span>You don't have any objectives right now.</span>")
	else
		owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()


/datum/antagonist/traitor/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	if(locate(/datum/objective/hijack) in owner.objectives)
		var/datum/atom_hud/antag/hijackhud = GLOB.huds[ANTAG_HUD_TRAITOR]
		hijackhud.join_hud(owner.current, null)
		set_antag_hud(owner.current, "hudhijack")
	else
		var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
		traitorhud.join_hud(owner.current, null)
		set_antag_hud(owner.current, "hudsyndicate")


/datum/antagonist/traitor/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(owner.current, null)
	set_antag_hud(owner.current, null)


/datum/antagonist/traitor/proc/finalize_traitor()
	switch(traitor_kind)
		if(TRAITOR_AI)
			add_law_zero()
			owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE)
			var/mob/living/silicon/ai/A = owner.current
			A.show_laws()
		if(TRAITOR_HUMAN)
			if(should_equip)
				equip_traitor()
			owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)


/datum/antagonist/traitor/proc/give_codewords()
	if(!owner.current)
		return
	var/mob/traitor_mob = owner.current

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	to_chat(traitor_mob, "<U><B>The Syndicate have provided you with the following codewords to identify fellow agents:</B></U>")
	to_chat(traitor_mob, "<B>Code Phrase: <span class='danger'>[phrases]</span></B>")
	to_chat(traitor_mob, "<B>Code Response: <span class='danger'>[responses]</span></B>")

	antag_memory += "<b>Code Phrase</b>: <span class='red'>[phrases]</span><br>"
	antag_memory += "<b>Code Response</b>: <span class='red'>[responses]</span><br>"

	to_chat(traitor_mob, "Use the codewords during regular conversation to identify other agents. Proceed with caution, however, as everyone is a potential foe.")


/datum/antagonist/traitor/proc/add_law_zero()
	var/mob/living/silicon/ai/killer = owner.current
	if(!killer || !istype(killer))
		return
	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	killer.set_zeroth_law(law, law_borg)
	killer.set_syndie_radio()
	to_chat(killer, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	killer.add_malf_picker()


/datum/antagonist/traitor/proc/equip_traitor()

	if(traitor_kind == TRAITOR_HUMAN)
		var/mob/living/carbon/human/traitor_mob = owner.current

		// find a radio! toolbox(es), backpack, belt, headset
		var/obj/item/R = locate(/obj/item/pda) in traitor_mob.contents //Hide the uplink in a PDA if available, otherwise radio
		if(!R)
			R = locate(/obj/item/radio) in traitor_mob.contents

		if(!R)
			to_chat(traitor_mob, "Unfortunately, the Syndicate wasn't able to get you a radio.")
			. = 0
		else
			if(istype(R, /obj/item/radio))
				// generate list of radio freqs
				var/obj/item/radio/target_radio = R
				var/freq = PUBLIC_LOW_FREQ
				var/list/freqlist = list()
				while(freq <= PUBLIC_HIGH_FREQ)
					if(freq < 1451 || freq > 1459)
						freqlist += freq
					freq += 2
					if((freq % 2) == 0)
						freq += 1
				freq = freqlist[rand(1, freqlist.len)]

				var/obj/item/uplink/hidden/T = new(R)
				target_radio.hidden_uplink = T
				T.uplink_owner = "[traitor_mob.key]"
				target_radio.traitor_frequency = freq
				to_chat(traitor_mob, "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features.")
				traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name]).")
			else if(istype(R, /obj/item/pda))
				// generate a passcode if the uplink is hidden in a PDA
				var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

				var/obj/item/uplink/hidden/T = new(R)
				R.hidden_uplink = T
				T.uplink_owner = "[traitor_mob.key]"
				var/obj/item/pda/P = R
				P.lock_code = pda_pass

				to_chat(traitor_mob, "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features.")
				antag_memory += ("<B>Uplink Passcode:</B> [pda_pass] ([R.name].")
	return 1


/datum/antagonist/traitor/proc/assign_exchange_role(var/datum/mind/owner)
	//set faction
	var/faction = "red"
	if(owner == SSticker.mode.exchange_blue)
		faction = "blue"

	//Assign objectives
	var/datum/objective/steal/exchange/exchange_objective = new
	exchange_objective.set_faction(faction,((faction == "red") ? SSticker.mode.exchange_blue : SSticker.mode.exchange_red))
	exchange_objective.owner = owner
	owner.objectives += exchange_objective

	if(prob(20))
		var/datum/objective/steal/exchange/backstab/backstab_objective = new
		backstab_objective.set_faction(faction)
		backstab_objective.owner = owner
		owner.objectives += backstab_objective

	//Spawn and equip documents
	var/mob/living/carbon/human/mob = owner.current

	var/obj/item/folder/syndicate/folder
	if(owner == SSticker.mode.exchange_red)
		folder = new/obj/item/folder/syndicate/red(mob.locs)
	else
		folder = new/obj/item/folder/syndicate/blue(mob.locs)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)

	var/where = "At your feet"
	var/equipped_slot = mob.equip_in_one_of_slots(folder, slots)
	if(equipped_slot)
		where = "In your [equipped_slot]"
	to_chat(mob, "<BR><BR><span class='info'>[where] is a folder containing <b>secret documents</b> that another Syndicate group wants. We have set up a meeting with one of their agents on station to make an exchange. Exercise extreme caution as they cannot be trusted and may be hostile.</span><BR>")
	mob.update_icons()


/datum/antagonist/traitor/roundend_report_footer()
	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	var/message = "<br><b>The code phrases were:</b> <span class='bluetext'>[phrases]</span><br>\
					<b>The code responses were:</b> <span class='redtext'>[responses]</span><br>"

	return message

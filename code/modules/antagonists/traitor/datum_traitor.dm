#define TRAITOR_HUMAN "human"
#define TRAITOR_AI	  "AI"

// For "Actual traitors"
/datum/antagonist/traitor
	name = "Traitdor"
	roundend_category = "traitors"
	job_rank = ROLE_TRAITOR
	var/special_role = SPECIAL_ROLE_TRAITOR
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	var/should_equip = TRUE
	var/traitor_kind = TRAITOR_HUMAN
	var/list/assigned_targets = list() // This includes assassinate as well as steal objectives. prevents duplicate objectives


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
		A.malf_picker.remove_malf_verbs(A)
		A.verbs -= /mob/living/silicon/ai/proc/choose_modules
		qdel(A.malf_picker)

	if(owner.som)
		var/datum/mindslaves/slaved = owner.som
		slaved.masters -= owner
		slaved.serv -= owner
		owner.som = null
		slaved.leave_serv_hud(owner)

	assigned_targets.Cut()
	SSticker.mode.traitors -= owner
	owner.special_role = null
	remove_innate_effects()
	update_traitor_icons_removed()

	if(!silent && owner.current)
		antag_memory = ""
		to_chat(owner.current,"<span class='userdanger'> No eres mas un [special_role]! </span>")
	..()


/datum/antagonist/traitor/apply_innate_effects()
	. = ..()
	if(owner.assigned_role == "Payaso")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			to_chat(traitor_mob, "<span class='warning'>Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.</span>")
			traitor_mob.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(traitor_mob)


/datum/antagonist/traitor/remove_innate_effects()
	. = ..()
	if(owner.assigned_role == "Payaso")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			to_chat(traitor_mob, "<span class='warning'>You lose your syndicate training and return to your own clumsy, clownish self.</span>")
			traitor_mob.mutations.Add(CLUMSY)
			for(var/datum/action/innate/A in traitor_mob.actions)
				if(istype(A, /datum/action/innate/toggle_clumsy))
					A.Remove(traitor_mob)

// Adding/removing objectives in the owner's mind until we can datumize all antags. Then we can use the /datum/antagonist/objectives var to handle them
// Change "owner.objectives" to "objectives" once objectives are handled in antag datums instead of the mind
/datum/antagonist/traitor/proc/add_objective(datum/objective/O)
	owner.objectives += O

/datum/antagonist/traitor/proc/remove_objective(datum/objective/O)
	owner.objectives -= O


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

	for(var/i = objective_count, i < objective_amount)
		i += forge_single_objective()

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

	objective_count += forge_single_objective()

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


/datum/antagonist/traitor/proc/forge_single_objective()
	switch(traitor_kind)
		if(TRAITOR_AI)
			return forge_single_AI_objective()
		else
			return forge_single_human_objective()


/datum/antagonist/traitor/proc/forge_single_human_objective() // Returns how many objectives are added
	. = 1
	if(prob(50))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			if("[destroy_objective]" in assigned_targets)	        // Is this target already in their list of assigned targets? If so, don't add this objective and return
				return 0
			else if(destroy_objective.target)					    // Is the target a real one and not null? If so, add it to our list of targets to avoid duplicate targets
				assigned_targets.Add("[destroy_objective.target]")	// This logic is applied to all traitor objectives including steal objectives
			add_objective(destroy_objective)

		else if(prob(5))
			var/datum/objective/debrain/debrain_objective = new
			debrain_objective.owner = owner
			debrain_objective.find_target()
			if("[debrain_objective]" in assigned_targets)
				return 0
			else if(debrain_objective.target)
				assigned_targets.Add("[debrain_objective.target]")
			add_objective(debrain_objective)

		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			if("[maroon_objective]" in assigned_targets)
				return 0
			else if(maroon_objective.target)
				assigned_targets.Add("[maroon_objective.target]")
			add_objective(maroon_objective)

		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			if("[kill_objective.target]" in assigned_targets)
				return 0
			else if(kill_objective.target)
				assigned_targets.Add("[kill_objective.target]")
			add_objective(kill_objective)

	else
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		if("[steal_objective.steal_target]" in assigned_targets)
			return 0
		else if(steal_objective.steal_target)
			assigned_targets.Add("[steal_objective.steal_target]")
		add_objective(steal_objective)


/datum/antagonist/traitor/proc/forge_single_AI_objective()
	. = 1
	var/datum/objective/block/block_objective = new
	block_objective.owner = owner
	add_objective(block_objective)


/datum/antagonist/traitor/greet()
	to_chat(owner.current, "<B><font size=3 color=red>Haz sido elegido como [owner.special_role]!</font></B>")
	if(!LAZYLEN(owner.objectives))   // Remove "owner" when objectives are handled in the datum
		to_chat(owner.current, "<span>No tienes ningun objetivo por ahora.</span>")
	else
		owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()


/datum/antagonist/traitor/proc/update_traitor_icons_added(datum/mind/traitor_mind)
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

	to_chat(traitor_mob, "<U><B>El Sindicato te provee las siguientes palabras en clave para identificar otros agentes:</B></U>")
	to_chat(traitor_mob, "<B>Codigos Frase: <span class='danger'>[phrases]</span></B>")
	to_chat(traitor_mob, "<B>Codigos Respuesta: <span class='danger'>[responses]</span></B>")

	antag_memory += "<b>Codigos Frase</b>: <span class='red'>[phrases]</span><br>"
	antag_memory += "<b>Codigos Respuesta</b>: <span class='red'>[responses]</span><br>"

	to_chat(traitor_mob, "Usa las palabras claves en conversaciones comunes para identificar otros agentes. Procede con precaucion, despues de todo, todos son potenciales enemigos.")


/datum/antagonist/traitor/proc/add_law_zero()
	var/mob/living/silicon/ai/killer = owner.current
	if(!killer || !istype(killer))
		return
	var/law = "Cumple tus objetivos a cualquier costo."
	var/law_borg = "Cumple los objetivos de tu IA a cualquier costo."
	killer.set_zeroth_law(law, law_borg)
	killer.set_syndie_radio()
	to_chat(killer, "Tu radio ha sido mejorada! Usa :t para hablar en canales encriptados con otros Agentes del Sindicato!")
	killer.add_malf_picker()


/datum/antagonist/traitor/proc/equip_traitor()

	if(traitor_kind == TRAITOR_HUMAN)
		var/mob/living/carbon/human/traitor_mob = owner.current

		// find a radio! toolbox(es), backpack, belt, headset
		var/obj/item/R = locate(/obj/item/pda) in traitor_mob.contents //Hide the uplink in a PDA if available, otherwise radio
		if(!R)
			R = locate(/obj/item/radio) in traitor_mob.contents

		if(!R)
			to_chat(traitor_mob, "Desafortunadamente, el Sindicato no pudo darte una radio.")
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
				to_chat(traitor_mob, "El Sindicato ha disfrazado astutamente un Uplink a [R.name]. Simplemente usa la frecuencia [format_frequency(freq)] en tu radio para desbloquear articulos.")
				traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name]).")
			else if(istype(R, /obj/item/pda))
				// generate a passcode if the uplink is hidden in a PDA
				var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

				var/obj/item/uplink/hidden/T = new(R)
				R.hidden_uplink = T
				T.uplink_owner = "[traitor_mob.key]"
				var/obj/item/pda/P = R
				P.lock_code = pda_pass

				to_chat(traitor_mob, "El Sindicato ha disfrazado astutamente un Uplink a [R.name]. Simplemente ingresa el codigo \"[pda_pass]\" en tu alerta de ringtone para desbloquearlo.")
				antag_memory += ("<B>Codigo Frase:</B> [pda_pass] ([R.name].")
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

	var message = "<br><b>Los codigos frase fueron:</b> <span class='bluetext'>[phrases]</span><br>\
					<b>Los codigos de respuesta fueron:</b> <span class='redtext'>[responses]</span><br>"

	return message

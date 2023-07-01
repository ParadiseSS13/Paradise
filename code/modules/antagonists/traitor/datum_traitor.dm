
// Syndicate Traitors.
/datum/antagonist/traitor
	name = "Traitor"
	roundend_category = "traitors"
	job_rank = ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	give_objectives = TRUE
	antag_hud_name = "hudsyndicate"
	antag_hud_type = ANTAG_HUD_TRAITOR
	clown_gain_text = "Your syndicate training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
	clown_removal_text = "You lose your syndicate training and return to your own clumsy, clownish self."
	wiki_page_name = "Traitor"
	/// Should the traitor get codewords?
	var/give_codewords = TRUE
	/// Should we give the traitor their uplink?
	var/give_uplink = TRUE

/datum/antagonist/traitor/on_gain()
	// Create this in case the traitor wants to mindslaves someone.
	if(!owner.som)
		owner.som = new /datum/mindslaves

	owner.som.masters += owner
	..()

/datum/antagonist/traitor/Destroy(force, ...)
	// Remove all associated malf AI abilities.
	if(isAI(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.clear_zeroth_law()
		var/obj/item/radio/headset/heads/ai_integrated/radio = A.get_radio()
		radio.channels.Remove("Syndicate")  // De-traitored AIs can still state laws over the syndicate channel without this
		A.laws.sorted_laws = A.laws.inherent_laws.Copy() // AI's 'notify laws' button will still state a law 0 because sorted_laws contains it
		A.show_laws()
		A.remove_malf_abilities()
		QDEL_NULL(A.malf_picker)

	// Leave the mindslave hud.
	if(owner.som)
		var/datum/mindslaves/slaved = owner.som
		slaved.masters -= owner
		slaved.serv -= owner
		slaved.leave_serv_hud(owner)
		owner.som = null

	owner.current.client?.chatOutput?.clear_syndicate_codes()

	// Try removing their uplink, check PDA
	var/mob/M = owner.current
	var/obj/item/uplink_holder = locate(/obj/item/pda) in M.contents

	// No PDA or it has no uplink? Check headset
	if(!uplink_holder || !uplink_holder.hidden_uplink)
		uplink_holder = locate(/obj/item/radio) in M.contents

	// If the headset has an uplink, delete it
	if(uplink_holder && uplink_holder.hidden_uplink)
		var/uplink = locate(/obj/item/uplink/hidden) in uplink_holder.contents
		uplink_holder.hidden_uplink = null
		qdel(uplink)

	// Check for an uplink implant
	var/uplink_implant = locate(/obj/item/implant/uplink) in M.contents
	if(uplink_implant)
		qdel(uplink_implant)

	return ..()

/datum/antagonist/traitor/add_owner_to_gamemode()
	SSticker.mode.traitors |= owner

/datum/antagonist/traitor/remove_owner_from_gamemode()
	SSticker.mode.traitors -= owner

/datum/antagonist/traitor/add_antag_hud(mob/living/antag_mob)
	var/is_contractor = LAZYACCESS(GLOB.contractors, owner)
	if(locate(/datum/objective/hijack) in owner.get_all_objectives())
		antag_hud_name = is_contractor ? "hudhijackcontractor" : "hudhijack"
	else
		antag_hud_name = is_contractor ? "hudcontractor" : "hudsyndicate"
	return ..()

/datum/antagonist/traitor/give_objectives()
	if(isAI(owner.current))
		forge_ai_objectives()
	else
		forge_human_objectives()

/**
 * Create and assign a full set of randomized human traitor objectives.
 */
/datum/antagonist/traitor/proc/forge_human_objectives()
	// Hijack objective.
	if(prob(10) && !(locate(/datum/objective/hijack) in owner.get_all_objectives()))
		add_objective(/datum/objective/hijack)
		return // Hijack should be their only objective (normally), so return.

	// Will give normal steal/kill/etc. type objectives.
	for(var/i in 1 to GLOB.configuration.gamemode.traitor_objectives_amount)
		forge_single_human_objective()

	var/can_succeed_if_dead = TRUE
	for(var/objective in owner.get_all_objectives())
		var/datum/objective/O = objective
		if(!O.martyr_compatible) // Check if our current objectives can co-exist with martyr.
			can_succeed_if_dead  = FALSE
			break

	// Give them an escape objective if they don't have one already.
	if(!(locate(/datum/objective/escape) in owner.get_all_objectives()) && (!can_succeed_if_dead || prob(80)))
		add_objective(/datum/objective/escape)

/**
 * Create and assign a full set of AI traitor objectives.
 */
/datum/antagonist/traitor/proc/forge_ai_objectives()
	add_objective(/datum/objective/block)
	add_objective(/datum/objective/assassinate)
	add_objective(/datum/objective/survive)

/**
 * Create and assign a single randomized human traitor objective.
 */
/datum/antagonist/traitor/proc/forge_single_human_objective()
	if(prob(50))
		if(length(active_ais()) && prob(100 / length(GLOB.player_list)))
			add_objective(/datum/objective/destroy)
		else if(prob(5))
			add_objective(/datum/objective/debrain)
		else if(prob(30))
			add_objective(/datum/objective/maroon)
		else
			add_objective(/datum/objective/assassinate)
	else
		add_objective(/datum/objective/steal)

/**
 * Give human traitors their uplink, and AI traitors their law 0. Play the traitor an alert sound.
 */
/datum/antagonist/traitor/finalize_antag()
	if(give_codewords)
		give_codewords()
	if(isAI(owner.current))
		add_law_zero()
		owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
		var/mob/living/silicon/ai/A = owner.current
		A.show_laws()
	else
		if(give_uplink)
			give_uplink()
		owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/**
 * Notify the traitor of their codewords and write them to `antag_memory` (notes).
 */
/datum/antagonist/traitor/proc/give_codewords()
	if(!owner.current)
		return
	var/mob/traitor_mob = owner.current

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	to_chat(traitor_mob, "<U><B>The Syndicate have provided you with the following codewords to identify fellow agents:</B></U>")
	to_chat(traitor_mob, "<span class='bold body'>Code Phrase: <span class='codephrases'>[phrases]</span></span>")
	to_chat(traitor_mob, "<span class='bold body'>Code Response: <span class='coderesponses'>[responses]</span></span>")

	antag_memory += "<b>Code Phrase</b>: <span class='red'>[phrases]</span><br>"
	antag_memory += "<b>Code Response</b>: <span class='red'>[responses]</span><br>"

	to_chat(traitor_mob, "Use the codewords during regular conversation to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
	to_chat(traitor_mob, "<b><font color=red>You memorize the codewords, allowing you to recognize them when heard.</font></b>")

	traitor_mob.client.chatOutput?.notify_syndicate_codes()

/**
 * Gives traitor AIs, and their connected cyborgs, a law 0. Additionally gives the AI their choose modules action button.
 */
/datum/antagonist/traitor/proc/add_law_zero()
	var/mob/living/silicon/ai/killer = owner.current
	killer.set_zeroth_law("Accomplish your objectives at all costs.", "Accomplish your AI's objectives at all costs.")
	killer.set_syndie_radio()
	to_chat(killer, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	killer.add_malf_picker()

/**
 * Gives a traitor human their uplink, and uplink code.
 */
/datum/antagonist/traitor/proc/give_uplink()
	if(isAI(owner.current))
		return FALSE

	var/mob/living/carbon/human/traitor_mob = owner.current

	// Try to find a PDA first. If they don't have one, try to find a radio/headset.
	var/obj/item/R = locate(/obj/item/pda) in traitor_mob.contents
	if(!R)
		R = locate(/obj/item/radio) in traitor_mob.contents

	if(!R)
		to_chat(traitor_mob, "<span class='warning'>Unfortunately, the Syndicate wasn't able to give you an uplink.</span>")
		return FALSE // They had no PDA or radio for whatever reason.

	if(isradio(R))
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
		freq = pick(freqlist)

		var/obj/item/uplink/hidden/T = new(R)
		target_radio.hidden_uplink = T
		T.uplink_owner = "[traitor_mob.key]"
		target_radio.traitor_frequency = freq
		to_chat(traitor_mob, "<span class='notice'>The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features.</span>")
		antag_memory += "<B>Radio Freq:</B> [format_frequency(freq)] ([R.name])."
		return TRUE

	else if(istype(R, /obj/item/pda))
		// generate a passcode if the uplink is hidden in a PDA
		var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

		var/obj/item/uplink/hidden/T = new(R)
		R.hidden_uplink = T
		T.uplink_owner = "[traitor_mob.key]"
		var/obj/item/pda/P = R
		P.lock_code = pda_pass

		to_chat(traitor_mob, "<span class='notice'>The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features.</span>")
		antag_memory += "<B>Uplink Passcode:</B> [pda_pass] ([R.name]."
		return TRUE
	return FALSE

// Curently unused. Look at `/datum/game_mode/proc/auto_declare_completion_traitor()` instead.
/datum/antagonist/traitor/roundend_report_footer()
	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	var/message = "<br><b>The code phrases were:</b> <span class='bluetext'>[phrases]</span><br>\
					<b>The code responses were:</b> <span class='redtext'>[responses]</span><br>"

	return message

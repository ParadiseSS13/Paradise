RESTRICT_TYPE(/datum/antagonist/traitor)

// Syndicate Traitors.
/datum/antagonist/traitor
	name = "Traitor"
	roundend_category = "traitors"
	job_rank = ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	antag_hud_name = "hudsyndicate"
	antag_hud_type = ANTAG_HUD_TRAITOR
	clown_gain_text = "Your syndicate training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
	clown_removal_text = "You lose your syndicate training and return to your own clumsy, clownish self."
	wiki_page_name = "Traitor"
	/// Should the traitor get codewords?
	var/give_codewords = TRUE
	/// Should we give the traitor their uplink?
	var/give_uplink = TRUE
	blurb_r = 200
	blurb_a = 0.75
	boss_title = "Syndicate Operations"

	/// Have we / are we sending a backstab message at this time. If we are, do not send another.
	var/sending_backstab = FALSE

/datum/antagonist/traitor/on_gain()
	// Create this in case the traitor wants to mindslaves someone.
	if(!owner.som)
		owner.som = new /datum/mindslaves

	owner.som.masters += owner
	..()

/datum/antagonist/traitor/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "codephrases", src)
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "coderesponses", src)

/datum/antagonist/traitor/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current
	for(var/datum/component/codeword_hearing/component in datum_owner.GetComponents(/datum/component/codeword_hearing))
		component.delete_if_from_source(src)

/datum/antagonist/traitor/Destroy(force, ...)
	// Remove all associated malf AI abilities.
	if(is_ai(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.clear_zeroth_law()
		var/obj/item/radio/headset/heads/ai_integrated/radio = A.get_radio()
		radio.channels.Remove("Syndicate")  // De-traitored AIs can still state laws over the syndicate channel without this
		A.laws.sorted_laws = A.laws.inherent_laws.Copy() // AI's 'notify laws' button will still state a law 0 because sorted_laws contains it
		A.show_laws()
		A.remove_malf_abilities()
		QDEL_NULL(A.malf_picker)
		var/datum/atom_hud/data/human/malf_ai/H = GLOB.huds[DATA_HUD_MALF_AI]
		H.remove_hud_from(usr)
		for(var/mob/living/silicon/robot/borg in A.connected_robots)
			H.remove_hud_from(borg)

	// Leave the mindslave hud.
	if(owner.som)
		var/datum/mindslaves/slaved = owner.som
		slaved.masters -= owner
		slaved.serv -= owner
		slaved.leave_serv_hud(owner)
		owner.som = null

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
	var/uplink_implant = locate(/obj/item/bio_chip/uplink) in M.contents
	if(uplink_implant)
		qdel(uplink_implant)

	return ..()

/datum/antagonist/traitor/select_organization()
	if(is_ai(owner.current))
		return
	var/chaos = pickweight(list(ORG_CHAOS_HUNTER = ORG_PROB_HUNTER, ORG_CHAOS_MILD = ORG_PROB_MILD, ORG_CHAOS_AVERAGE = ORG_PROB_AVERAGE, ORG_CHAOS_HIJACK = ORG_PROB_HIJACK))
	for(var/org_type in shuffle(subtypesof(/datum/antag_org/syndicate)))
		var/datum/antag_org/org = org_type
		if(initial(org.chaos_level) == chaos)
			organization = new org_type(src)
			return

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
	if(is_ai(owner.current))
		forge_ai_objectives()
	else
		forge_human_objectives()

/datum/antagonist/traitor/exfiltrate(mob/living/carbon/human/extractor, obj/item/radio/radio)
	if(isplasmaman(extractor))
		extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/syndicate/plasmaman)
	else
		extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/syndicate)
	// Remove mindslaves
	var/list/mindslaves = SSticker.mode.implanted
	for(var/datum/mind/possible_slave in mindslaves)
		for(var/datum/antagonist/slavetag in possible_slave.antag_datums)
			if(!istype(slavetag, /datum/antagonist/mindslave))
				continue
			var/datum/antagonist/mindslave/slave = slavetag
			if(slave.master == extractor.mind)
				possible_slave.remove_antag_datum(/datum/antagonist/mindslave/implant)

	radio.autosay("<b>--ZZZT!- Good work, $@gent [extractor.real_name]. Return to -^%&!-ZZT!-</b>", "Syndicate Operations", "Security")
	SSblackbox.record_feedback("tally", "successful_extraction", 1, "Traitor")
/**
 * Create and assign a full set of randomized human traitor objectives.
 */
/datum/antagonist/traitor/proc/forge_human_objectives()
	var/iteration = 1
	var/can_succeed_if_dead = TRUE
	// If our org has forced objectives, give them to us guaranteed.
	if(organization && length(organization.forced_objectives))
		for(var/forced_objectives in organization.forced_objectives)
			var/datum/objective/forced_obj = forced_objectives
			if(!ispath(forced_obj, /datum/objective/hijack) && delayed_objectives) // Hijackers know their objective immediately
				forced_obj = new /datum/objective/delayed(forced_obj)
			add_antag_objective(forced_obj)
			iteration++

	if(locate(/datum/objective/hijack) in owner.get_all_objectives())
		return //Hijackers only get hijack.

	// Will give objectives from our org or random objectives.
	for(var/i in iteration to GLOB.configuration.gamemode.traitor_objectives_amount)
		forge_single_human_objective()

	for(var/objective in owner.get_all_objectives())
		var/datum/objective/O = objective
		if(!O.martyr_compatible) // Check if we need to stay alive in order to accomplish our objectives (Steal item, etc)
			can_succeed_if_dead  = FALSE
			break

	// Give them an escape objective if they don't have one. 20 percent chance not to have escape if we can greentext without staying alive.
	if(!(locate(/datum/objective/escape) in owner.get_all_objectives()) && (!can_succeed_if_dead || prob(80)))
		add_antag_objective(/datum/objective/escape)

/**
 * Create and assign a full set of AI traitor objectives.
 */
/datum/antagonist/traitor/proc/forge_ai_objectives()
	add_antag_objective(/datum/objective/block)
	add_antag_objective(/datum/objective/assassinate)
	add_antag_objective(/datum/objective/survive)


/**
 * Give human traitors their uplink, and AI traitors their law 0. Play the traitor an alert sound.
 */
/datum/antagonist/traitor/finalize_antag()
	var/list/messages = list()
	if(organization)
		antag_memory += "<b>Organization</b>: [organization.name]<br>"
	if(give_codewords)
		messages.Add(give_codewords())
	if(is_ai(owner.current))
		add_law_zero()
		owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
		var/mob/living/silicon/ai/A = owner.current
		A.show_laws()
	else
		if(give_uplink)
			give_uplink()
		owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

	return messages

/**
 * Notify the traitor of their codewords and write them to `antag_memory` (notes).
 */
/datum/antagonist/traitor/proc/give_codewords()
	if(!owner.current)
		return

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")
	var/list/messages = list()
	messages.Add("<u><b>The Syndicate have provided you with the following codewords to identify fellow agents:</b></u>")
	messages.Add("<span class='bold body'>Code Phrase: <span class='codephrases'>[phrases]</span></span>")
	messages.Add("<span class='bold body'>Code Response: <span class='coderesponses'>[responses]</span></span>")

	antag_memory += "<b>Code Phrase</b>: <span class='red'>[phrases]</span><br>"
	antag_memory += "<b>Code Response</b>: <span class='red'>[responses]</span><br>"

	messages.Add("Use the codewords during regular conversation to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
	messages.Add("<b><font color=red>You memorize the codewords, allowing you to recognize them when heard.</font></b>")

	return messages

/**
 * Gives traitor AIs, and their connected cyborgs, a law 0. Additionally gives the AI their choose modules action button.
 */
/datum/antagonist/traitor/proc/add_law_zero()
	var/mob/living/silicon/ai/killer = owner.current
	killer.set_zeroth_law("Accomplish your objectives at all costs.", "Accomplish your AI's objectives at all costs.")
	killer.set_syndie_radio()
	to_chat(killer, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	killer.add_malf_picker()
	var/datum/atom_hud/data/human/malf_ai/H = GLOB.huds[DATA_HUD_MALF_AI]
	H.add_hud_to(killer)
	for(var/mob/living/silicon/robot/borg in killer.connected_robots)
		H.add_hud_to(borg)

/**
 * Gives a traitor human their uplink, and uplink code.
 */
/datum/antagonist/traitor/proc/give_uplink()
	if(is_ai(owner.current))
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
			if(ISEVEN(freq))
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

/datum/antagonist/traitor/custom_blurb()
		return "[GLOB.current_date_string], [station_time_timestamp()]\n[station_name()], [get_area_name(owner.current, TRUE)], \n[organization.intro_desc] BEGIN MISSION"
/datum/antagonist/traitor/proc/reveal_delayed_objectives()

	for(var/datum/objective/delayed/delayed_obj in get_antag_objectives(FALSE))
		delayed_obj.reveal_objective()

	if(!owner?.current)
		return
	SEND_SOUND(owner.current, sound('sound/ambience/alarm4.ogg'))

	if(prob(ORG_PROB_PARANOIA)) // Low chance of fake 'You are targeted' notification
		queue_backstab()

	if(prob(EXCHANGE_PROBABILITY))
		start_exchange()

	var/list/messages = owner.prepare_announce_objectives()
	to_chat(owner.current, chat_box_red(messages.Join("<br>")))
	delayed_objectives = FALSE

/datum/antagonist/traitor/proc/queue_backstab()
	// We do not want to send out two of these. As such, if the datum is already sending a backstab, abort.
	if(sending_backstab)
		return
	sending_backstab = TRUE
	addtimer(CALLBACK(src, PROC_REF(send_backstab)), rand(2 MINUTES, 5 MINUTES))

/datum/antagonist/traitor/proc/send_backstab()
	if(!owner.current)
		return
	add_antag_objective(/datum/objective/potentially_backstabbed)
	var/list/messages = owner.prepare_announce_objectives()
	to_chat(owner.current, chat_box_red(messages.Join("<br>")))
	SEND_SOUND(owner.current, sound('sound/ambience/alarm4.ogg'))

RESTRICT_TYPE(/datum/antagonist/traitor/malf)

/datum/antagonist/traitor/malf
	name = "Malfunctioning AI"
	roundend_category = "traitors"
	job_rank = ROLE_MALF
	special_role = SPECIAL_ROLE_MALF
	antag_hud_name = "hudsyndicate"
	antag_hud_type = ANTAG_HUD_TRAITOR
	wiki_page_name = "Traitor"
	give_codewords = TRUE
	is_roundstart = TRUE

/datum/antagonist/traitor/malf/add_owner_to_gamemode()
	SSticker.mode.malf_AIs += owner

/datum/antagonist/traitor/malf/remove_owner_from_gamemode()
	SSticker.mode.malf_AIs -= owner

/datum/antagonist/traitor/malf/finalize_antag()
	var/list/messages = list()
	if(is_ai(owner.current))
		add_law_zero()
		owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
		var/mob/living/silicon/ai/A = owner.current
		A.show_laws()
	if(give_codewords)
		messages.Add(give_codewords())

	return messages

/**
 * Gives traitor AIs, and their connected cyborgs, a law 0. Additionally gives the AI their choose modules action button.
 */
/datum/antagonist/traitor/malf/proc/add_law_zero()
	var/mob/living/silicon/ai/killer = owner.current
	killer.set_zeroth_law("Accomplish your objectives at all costs.", "Accomplish your AI's objectives at all costs.")
	killer.set_syndie_radio()
	to_chat(killer, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	killer.add_malf_picker()
	var/datum/atom_hud/data/human/malf_ai/H = GLOB.huds[DATA_HUD_MALF_AI]
	H.add_hud_to(killer, src)
	for(var/mob/living/silicon/robot/borg in killer.connected_robots)
		H.add_hud_to(borg, src)

/datum/antagonist/traitor/malf/Destroy(force, ...)
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
		H.remove_hud_from(usr, src)
		for(var/mob/living/silicon/robot/borg in A.connected_robots)
			H.remove_hud_from(borg, src)

	return ..()

/datum/antagonist/traitor/malf/give_objectives()
	forge_ai_objectives()

/**
 * Create and assign a full set of AI traitor objectives.
 */
/datum/antagonist/traitor/malf/proc/forge_ai_objectives()
	add_antag_objective(/datum/objective/block)
	add_antag_objective(/datum/objective/assassinate)
	add_antag_objective(/datum/objective/survive)


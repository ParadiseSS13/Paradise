RESTRICT_TYPE(/datum/antagonist/malf)

/datum/antagonist/malf
	name = "Malfunctioning AI"
	roundend_category = "traitors"
	job_rank = ROLE_MALF
	special_role = SPECIAL_ROLE_MALF
	antag_hud_name = "hudsyndicate"
	antag_hud_type = ANTAG_HUD_TRAITOR
	wiki_page_name = "Traitor"
	organization = /datum/antag_org/syndicate/self // It makes sense that SELF would be the only one sending malf AIs to NT stations.
	var/give_codewords = TRUE
	var/is_roundstart = TRUE

/datum/antagonist/malf/add_owner_to_gamemode()
	SSticker.mode.malf_ais += owner

/datum/antagonist/malf/remove_owner_from_gamemode()
	SSticker.mode.malf_ais -= owner

/datum/antagonist/malf/Destroy(force, ...)
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

/datum/antagonist/malf/finalize_antag()
	var/list/messages = list()
	add_law_zero()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	var/mob/living/silicon/ai/A = owner.current
	A.show_laws()
	antag_memory += "<b>Organization</b>: [organization.name]<br>"
	if(give_codewords)
		messages.Add(give_codewords())

	return messages

/**
 * Gives traitor AIs, and their connected cyborgs, a law 0. Additionally gives the AI their choose modules action button.
 */
/datum/antagonist/malf/proc/add_law_zero()
	var/mob/living/silicon/ai/killer = owner.current
	killer.set_zeroth_law("Accomplish your objectives at all costs.", "Accomplish your AI's objectives at all costs.")
	killer.set_syndie_radio()
	to_chat(killer, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	killer.add_malf_picker()
	var/datum/atom_hud/data/human/malf_ai/H = GLOB.huds[DATA_HUD_MALF_AI]
	H.add_hud_to(killer, src)
	for(var/mob/living/silicon/robot/borg in killer.connected_robots)
		H.add_hud_to(borg, src)



/datum/antagonist/malf/give_objectives()
	add_antag_objective(/datum/objective/block)
	add_antag_objective(/datum/objective/assassinate)
	add_antag_objective(/datum/objective/survive)

/datum/antagonist/malf/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "codephrases", src)
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "coderesponses", src)

/datum/antagonist/malf/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current
	for(var/datum/component/codeword_hearing/component in datum_owner.GetComponents(/datum/component/codeword_hearing))
		component.delete_if_from_source(src)

/datum/game_mode/proc/auto_declare_completion_malf()
	if(!length(malf_ais))
		return

	var/list/text = list("<br><font size=3>[SPAN_BOLD("The Malfunctioning AIs were:")]</font>")
	for(var/datum/mind/malf in malf_ais)
		var/malf_win = TRUE
		text += "<br>[malf.get_display_key()] was [malf.name] and "
		if(malf.current)
			if(malf.current.stat == DEAD)
				text += "[SPAN_BOLD("died")]!"
			else
				text += SPAN_BOLD("survived!")
			if(malf.current.real_name != malf.name)
				text += " as [malf.current.real_name]"
			else
				text += "!"
		else
			text += SPAN_BOLD("had [malf.p_their()] body destroyed!")

		var/list/all_objectives = malf.get_antag_objectives(include_team = FALSE)
		if(length(all_objectives))
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				text += "<br><b>Objective #[count]</b>: [objective.explanation_text]"
				if(objective.check_completion())
					SSblackbox.record_feedback("nested tally", "malf_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					SSblackbox.record_feedback("nested tally", "malf_objective", 1, list("[objective.type]", "FAIL"))
					malf_win = FALSE
				count++
		if(malf_win)
			SSblackbox.record_feedback("tally", "malf_success", 1, "SUCCESS")
		else
			SSblackbox.record_feedback("tally", "malf_success", 1, "FAIL")
	return text.Join("")

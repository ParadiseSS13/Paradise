/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"
	tdm_gamemode = TRUE
	required_players = 20
	required_enemies = 1
	recommended_enemies = 1
	single_antag_positions = list()

	var/finished = FALSE
	var/but_wait_theres_more = FALSE
	var/list/pre_wizards = list()

/datum/game_mode/wizard/announce()
	to_chat(world, "<B>The current game mode is - Wizard!</B>")
	to_chat(world, "<B>There is a <font color='red'>SPACE WIZARD</font> on the station. You can't let him achieve his objective!</B>")

/datum/game_mode/wizard/pre_setup()
	var/list/datum/mind/possible_wizards = get_players_for_role(ROLE_WIZARD)
	if(!length(possible_wizards))
		return FALSE
	var/datum/mind/wizard = pick(possible_wizards)

	pre_wizards += wizard
	wizard.assigned_role = SPECIAL_ROLE_WIZARD //So they aren't chosen for other jobs.
	wizard.special_role = SPECIAL_ROLE_WIZARD
	if(!length(GLOB.wizardstart))
		to_chat(wizard.current, "<span class='danger'>A starting location for you could not be found, please report this bug!</span>")
		return FALSE
	return TRUE

/datum/game_mode/wizard/post_setup()
	for(var/datum/mind/wiz in pre_wizards)
		wiz.add_antag_datum(/datum/antagonist/wizard)
		wiz.current.forceMove(pick(GLOB.wizardstart))
	pre_wizards.Cut()
	..()

// Checks if the game should end due to all wizards and apprentices being dead, or MMI'd/Borged
/datum/game_mode/wizard/check_finished()
	if(but_wait_theres_more)
		return ..()

	// Wizards and Apprentices
	for(var/datum/mind/wizard in (wizards + apprentices)) // yes, this works so it iterates through wizards, then apprentices
		var/datum/antagonist/wizard/datum_wizard = wizard.has_antag_datum(/datum/antagonist/wizard)
		if(datum_wizard?.wizard_is_alive())
			return ..()

	finished = TRUE
	return TRUE

/datum/game_mode/wizard/declare_completion(ragin = 0)
	if(finished && !ragin)
		SSticker.mode_result = "wizard loss - wizard killed"
		to_chat(world, "<span class='warning'><FONT size = 3><B> The wizard[(length(wizards)>1)?"s":""] has been killed by the crew! The Space Wizards Federation has been taught a lesson they will not soon forget!</B></FONT></span>")
	..()
	return TRUE

/datum/game_mode/proc/auto_declare_completion_wizard()
	if(!length(wizards))
		return
	var/list/text = list("<br><font size=3><b>the wizards/witches were:</b></font>")

	for(var/datum/mind/wizard in wizards)

		text += "<br><b>[wizard.get_display_key()]</b> was <b>[wizard.name]</b> ("
		if(wizard.current)
			if(wizard.current.stat == DEAD)
				text += "died"
			else
				text += "survived"
			if(wizard.current.real_name != wizard.name)
				text += " as <b>[wizard.current.real_name]</b>"
		else
			text += "body destroyed"
		text += ")"

		var/count = 1
		var/wizardwin = 1
		for(var/datum/objective/objective in wizard.get_all_objectives(include_team = FALSE))
			if(objective.check_completion())
				text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
				SSblackbox.record_feedback("nested tally", "wizard_objective", 1, list("[objective.type]", "SUCCESS"))
			else
				text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
				SSblackbox.record_feedback("nested tally", "wizard_objective", 1, list("[objective.type]", "FAIL"))
				wizardwin = 0
			count++

		if(wizard.current && wizard.current.stat != DEAD && wizardwin)
			text += "<br><font color='green'><B>The wizard was successful!</B></font>"
			SSblackbox.record_feedback("tally", "wizard_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><B>The wizard has failed!</B></font>"
			SSblackbox.record_feedback("tally", "wizard_success", 1, "FAIL")
		if(wizard.spell_list)
			text += "<br><B>[wizard.name] used the following spells: </B>"
			text += english_list(wizard.spell_list)

		text += "<br>"

	return text.Join("")

//OTHER PROCS

//To batch-remove wizard spells. Linked to mind.dm
/mob/proc/spellremove()
	if(!mind)
		return
	for(var/datum/spell/spell_to_remove in mind.spell_list)
		qdel(spell_to_remove)
		mind.spell_list -= spell_to_remove

//To batch-remove mob spells.
/mob/proc/mobspellremove()
	for(var/datum/spell/spell_to_remove in mob_spell_list)
		qdel(spell_to_remove)
		mob_spell_list -= spell_to_remove

/proc/iswizard(mob/living/M)
	return istype(M) && M.mind?.has_antag_datum(/datum/antagonist/wizard)

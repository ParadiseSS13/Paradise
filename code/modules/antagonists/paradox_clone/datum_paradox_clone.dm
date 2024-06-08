GLOBAL_LIST_INIT(possible_paradox_clone_ids, list("Alpha", "Bravo", "Charlie",
	"Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet",
	"Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec",
	"Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray",
	"Yankee", "Zulu")) // just a copy of GLOB.photenic_alphabet but for paradox clones ids which removes

GLOBAL_LIST_INIT(paradox_clones, list())

/datum/antagonist/paradox_clone
	name = "Paradox Clone"
	roundend_category = "paradox clones"
	job_rank = ROLE_PARADOX_CLONE
	special_role = SPECIAL_ROLE_PARADOX_CLONE
	antag_hud_name = "hudparadoxclone"
	antag_hud_type = ANTAG_HUD_PARADOX_CLONE // they see each other hud
	clown_gain_text = "<span class='notice'>You are from alternative universe, where clowns are actually quite dextrous. This allows you to wield weapons without harming yourself.</span>"
	clown_removal_text = "<span class='danger'>Your connection with your native universe fades, and with it goes your dexterity.</span>"
	wiki_page_name = "Paradox_Clone"

	give_objectives = FALSE
	silent = TRUE

	blurb_text_color = COLOR_GRAY
	blurb_text_outline_width = 2

	blurb_r = 46
	blurb_g = 46
	blurb_b = 46
	blurb_a = 0.40

	var/paradox_id = "Paradox"
	var/real_id
	var/static/list/paradox_powers = list(
		/datum/spell/paradox_spell/click_target/gaze,
		/datum/spell/touch/paradox_spell/space_distortion,
		/datum/spell/paradox_spell/self/digital_supersede,
		/datum/spell/paradox_spell/click_target/mind_interference,
		/datum/spell/paradox_spell/self/illusion,
		/datum/spell/paradox_spell/click_target/energy_exchange,
		/datum/spell/touch/paradox_spell/microcircuit_disorder,
		/datum/spell/paradox_spell/self/intangibility,
		/datum/spell/touch/paradox_spell/suppression,
		/datum/spell/paradox_spell/aoe/hud_malfunction,
		/datum/spell/paradox_spell/self/light_step
	)
	// "replace" is issued if there is a objective to kill n replace and "United Bonds" when need to protect original.
	var/mob/living/carbon/human/original
	var/list/current_powers = list()
	var/light_step = FALSE

/datum/antagonist/paradox_clone/on_gain()
	var/mob/living/carbon/human/H = owner.current
	GLOB.paradox_clones += owner
	var/prefix = pick("Experiment", "Paradox", "Agent", "Subject") // There is some hint that some paradoxical clones are victims of an anomaly, either experiments by scientists, or specially sent agents.
	if(length(GLOB.possible_paradox_clone_ids))
		var/id = pick(GLOB.possible_paradox_clone_ids)
		real_id = id
		GLOB.possible_paradox_clone_ids -= id
		paradox_id = "[prefix] [id]"
	else
		paradox_id = "[prefix] [rand(1,999)]"

	for(var/mob/living/carbon/human/clone in GLOB.human_list)
		if(clone != H && is_paradox_clone(clone))
			to_chat("<span class='danger'>You have a feeling, that something familiar and native appeared in this dark universe...</span>")
	..()

/datum/antagonist/paradox_clone/Destroy()
	GLOB.paradox_clones -= owner
	STOP_PROCESSING(SSobj, src)
	GLOB.possible_paradox_clone_ids += real_id
	REMOVE_TRAIT(owner.current, TRAIT_AI_UNTRACKABLE, PARADOX_CLONE_TRAIT)

	owner.current.remove_status_effect(/datum/status_effect/internal_pinpointer/paradox_stalking)
	return ..()

/datum/antagonist/paradox_clone/greet()
	SEND_SOUND(owner.current, sound('sound/ambience/antag/paradox_clone_alert.ogg'))

/datum/antagonist/paradox_clone/farewell()
	to_chat(owner.current, "<span class='biggerdanger'><b>You are becoming more and more a part of this universe...</b></span>")
	owner.current.remove_status_effect(/datum/status_effect/internal_pinpointer/paradox_stalking)

/datum/antagonist/paradox_clone/apply_innate_effects(mob/living/mob_override)
	var/mob/living/carbon/human/H = owner.current
	H.add_language("Paradoxial Link")
	if(!ishuman(H))
		STOP_PROCESSING(SSobj, src)

	if(!mob_override)
		for(var/datum/spell/S as anything in paradox_powers)
			H.mind.AddSpell(new S(H))
			H.mind.spell_list += S
	else
		for(var/datum/spell/S as anything in current_powers)
			H.mind.AddSpell(new S(H))
			H.mind.spell_list += S
	..()

/datum/antagonist/paradox_clone/remove_innate_effects(mob/living/mob_override)
	var/mob/living/carbon/human/H = owner.current
	H.remove_language("Paradoxial Link")

	for(var/datum/spell/S as anything in current_powers)
		H.mind.RemoveSpell(S)
		H.mind.spell_list -= S

	for(var/datum/spell/S as anything in owner.spell_list)
		if(S.type in paradox_powers)
			H.mind.RemoveSpell(S)
			H.mind.spell_list -= S
	..()

/datum/antagonist/paradox_clone/give_objectives()
	return //gives during spawning in paradox_camera.dm

/proc/auto_declare_completion_paradox_clone()
	if(!length(GLOB.paradox_clones))
		return

	var/list/text = list("The paradox clones were:")

	for(var/datum/mind/pc in GLOB.paradox_clones)
		var/pc_win = TRUE
		paradox_print(pc, TRUE)

		var/list/all_objectives = pc.get_all_objectives(include_team = FALSE)

		if(length(all_objectives))
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				if(objective.check_completion())
					text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='green'><b>Success!</b></font>"
					SSblackbox.record_feedback("nested tally", "paradox_clone_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='red'>Fail.</font>"
					SSblackbox.record_feedback("nested tally", "paradox_clone_objective", 1, list("[objective.type]", "FAIL"))
					pc_win = FALSE
				count++


		if(pc_win)
			text += "<br><font color='green'><b>The Paradox Clone was successful!</b></font>"
			SSblackbox.record_feedback("tally", "paradox_clone_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><b>The Paradox Clone has failed!</b></font>"
			SSblackbox.record_feedback("tally", "paradox_clone_success", 1, "FAIL")

		return text.Join("")

/proc/paradox_print(datum/mind/ply, fleecheck)
	var/datum/antagonist/paradox_clone/pc = ply.has_antag_datum(/datum/antagonist/paradox_clone)
	var/text = "<b>[ply.get_display_key()]</b> was paradox clone of <b>[pc.original.real_name]</b>, the [pc.original.mind.assigned_role] and"
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += " <span class='redtext'>died</span>"
		else
			text += " <span class='greentext'>survived</span>"
		if(fleecheck)
			var/turf/T = get_turf(ply.current)
			if(!T || !is_station_level(T.z))
				text += " while <span class='redtext'>fleeing the station</span>"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += " <span class='redtext'>had [ply.p_their()] body destroyed</span>"

	return text

/proc/is_paradox_clone(mob/M)
	return M.mind?.has_antag_datum(/datum/antagonist/paradox_clone)

/datum/antagonist/paradox_clone/custom_blurb()
	return "On the [GLOB.current_date_string]?, at [station_time_timestamp()]?,\n in the [station_name()]?, [get_area_name(owner.current, TRUE)]?...\nIn another universe..."

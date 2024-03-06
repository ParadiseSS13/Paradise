/datum/game_mode
	/// A list of all minds currently in the cult
	// var/list/datum/mind/cult = list()

	var/datum/team/cult/cult_team

/datum/game_mode/proc/get_cult_team()
	return cult_team || new /datum/team/cult()

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list("Chaplain", "AI", "Cyborg", "Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Blueshield", "Nanotrasen Representative", "Magistrate", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Solar Federation General")
	protected_jobs = list()
	required_players = 30
	required_enemies = 3
	recommended_enemies = 4

	var/list/pre_cult = list()

	var/const/min_cultists_to_start = 3
	var/const/max_cultists_to_start = 4

/datum/game_mode/cult/announce()
	to_chat(world, "<B>The current game mode is - Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the offer rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with holy water reverts them to whatever CentComm-allowed faith they had.</B>")

/datum/game_mode/cult/pre_setup()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/cultists_possible = get_players_for_role(ROLE_CULTIST)
	for(var/cultists_number = 1 to max_cultists_to_start)
		if(!length(cultists_possible))
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		pre_cult += cultist
		cultist.restricted_roles = restricted_jobs
		cultist.special_role = SPECIAL_ROLE_CULTIST
	return length(pre_cult)

/datum/game_mode/cult/post_setup()
	for(var/datum/mind/cult_mind in pre_cult)
		cult_team.equip_cultist(cult_mind.current) // cTODO, use get_cult
	..()


/datum/game_mode/proc/add_cultist(datum/mind/cult_mind)
	if(!istype(cult_mind) || cult_mind.has_antag_datum(/datum/antagonist/cultist))
		return FALSE

	cult_mind.add_antag_datum(/datum/antagonist/cultist)
		RegisterSignal(cult_mind.current, COMSIG_PARENT_QDELETING, PROC_REF(remove_cultist))
	return TRUE

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = TRUE, remove_gear = FALSE, mob/target_mob)
	// if(target_mob)
	// 	cult -= target_mob // ctodo, figure out how to do this better
	if(!cult_mind.has_antag_datum(/datum/antagonist/cultist)) // Not actually a cultist in the first place
		return

	var/mob/cultist = target_mob
	if(!cultist)
		cultist = cult_mind.current
	cult_team.remove_member(cult_mind)

	if(show_message)
		cultist.visible_message("<span class='cult'>[cultist] looks like [cultist.p_they()] just reverted to [cultist.p_their()] old faith!</span>",
		"<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of [SSticker.cultdat ? SSticker.cultdat.entity_title1 : "Nar'Sie"] and the memories of your time as their servant with it.</span>")
	UnregisterSignal(cult_mind.current, COMSIG_MOB_STATCHANGE)

/datum/game_mode/proc/add_cult_immunity(mob/living/target)
	ADD_TRAIT(target, TRAIT_CULT_IMMUNITY, CULT_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(remove_cult_immunity), target), 1 MINUTES)

/datum/game_mode/proc/remove_cult_immunity(mob/living/target)
	REMOVE_TRAIT(target, TRAIT_CULT_IMMUNITY, CULT_TRAIT)


/**
  * Decides at the start of the round how many conversions are needed to rise/ascend.
  *
  * The number is decided by (Percentage * (Players - Cultists)), so for example at 110 players it would be 11 conversions for rise. (0.1 * (110 - 4))
  * These values change based on population because 20 cultists are MUCH more powerful if there's only 50 players, compared to 120.
  *
  * Below 100 players, [CULT_RISEN_LOW] and [CULT_ASCENDANT_LOW] are used.
  * Above 100 players, [CULT_RISEN_HIGH] and [CULT_ASCENDANT_HIGH] are used.
  */
/datum/game_mode/proc/cult_threshold_check()
	var/list/living_players = get_living_players(exclude_nonhuman = TRUE, exclude_offstation = TRUE)
	var/players = length(living_players)
	var/cultists = get_cultists() // Don't count the starting cultists towards the number of needed conversions
	if(players >= CULT_POPULATION_THRESHOLD)
		// Highpop
		ascend_percent = CULT_ASCENDANT_HIGH
		rise_number = round(CULT_RISEN_HIGH * (players - cultists))
		ascend_number = round(CULT_ASCENDANT_HIGH * (players - cultists))
	else
		// Lowpop
		ascend_percent = CULT_ASCENDANT_LOW
		rise_number = round(CULT_RISEN_LOW * (players - cultists))
		ascend_number = round(CULT_ASCENDANT_LOW * (players - cultists))

/**
  * Returns the current number of cultists and constructs.
  *
  * Returns the number of cultists and constructs in a list ([1] = Cultists, [2] = Constructs), or as one combined number.
  *
  * * separate - Should the number be returned as a list with two separate values (Humans and Constructs) or as one number.
  */
/datum/game_mode/proc/get_cultists(separate = FALSE)
	var/cultists = 0
	var/constructs = 0
	for(var/datum/mind/M as anything in cult)
		if(QDELETED(M) || M.current?.stat == DEAD)
			continue
		if(ishuman(M.current) && !M.current.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
			cultists++
		else if(isconstruct(M.current))
			constructs++
	if(separate)
		return list(cultists, constructs)
	return cultists + constructs

/datum/game_mode/proc/cultist_stat_change(mob/target_cultist, new_stat, old_stat)
	SIGNAL_HANDLER // COMSIG_MOB_STATCHANGE from cultists
	if(new_stat == old_stat) // huh, how? whatever, we ignore it
		return
	if(new_stat != DEAD && old_stat != DEAD)
		return // switching between alive and unconcious
	// switching between dead and alive/unconcious
	check_cult_size()

/datum/game_mode/proc/check_cult_size()
	var/cult_players = get_cultists()

	if(cult_ascendant)
		// The cult only falls if below 1/2 of the rising, usually pretty low. e.g. 5% on highpop, 10% on lowpop
		if(cult_players < (rise_number / 2))
			cult_fall()
		return

	if((cult_players >= rise_number) && !cult_risen)
		cult_rise()
		return

	if(cult_players >= ascend_number)
		cult_ascend()

/datum/game_mode/proc/cult_rise()
	cult_risen = TRUE
	for(var/datum/mind/M in cult)
		if(!ishuman(M.current))
			continue
		SEND_SOUND(M.current, sound('sound/hallucinations/i_see_you2.ogg'))
		to_chat(M.current, "<span class='cultlarge'>The veil weakens as your cult grows, your eyes begin to glow...</span>")
		addtimer(CALLBACK(src, PROC_REF(rise), M.current), 20 SECONDS)


/datum/game_mode/proc/cult_ascend()
	cult_ascendant = TRUE
	for(var/datum/mind/M in cult)
		if(!ishuman(M.current))
			continue
		SEND_SOUND(M.current, sound('sound/hallucinations/im_here1.ogg'))
		to_chat(M.current, "<span class='cultlarge'>Your cult is ascendant and the red harvest approaches - you cannot hide your true nature for much longer!</span>")
		addtimer(CALLBACK(src, PROC_REF(ascend), M.current), 20 SECONDS)
	GLOB.major_announcement.Announce("Picking up extradimensional activity related to the Cult of [SSticker.cultdat ? SSticker.cultdat.entity_name : "Nar'Sie"] from your station. Data suggests that about [ascend_percent * 100]% of the station has been converted. Security staff are authorized to use lethal force freely against cultists. Non-security staff should be prepared to defend themselves and their work areas from hostile cultists. Self defense permits non-security staff to use lethal force as a last resort, but non-security staff should be defending their work areas, not hunting down cultists. Dead crewmembers must be revived and deconverted once the situation is under control.", "Central Command Higher Dimensional Affairs", 'sound/AI/commandreport.ogg')

/datum/game_mode/proc/cult_fall()
	cult_ascendant = FALSE
	for(var/datum/mind/M in cult)
		if(!ishuman(M.current))
			continue
		SEND_SOUND(M.current, sound('sound/hallucinations/wail.ogg'))
		to_chat(M.current, "<span class='cultlarge'>The veil repairs itself, your power grows weaker...</span>")
		addtimer(CALLBACK(src, PROC_REF(descend), M.current), 20 SECONDS)
	GLOB.major_announcement.Announce("Paranormal activity has returned to minimal levels. \
									Security staff should minimize lethal force against cultists, using non-lethals where possible. \
									All dead cultists should be taken to medbay or robotics for immediate revival and deconversion. \
									Non-security staff may defend themselves, but should prioritize leaving any areas with cultists and reporting the cultists to security. \
									Self defense permits non-security staff to use lethal force as a last resort. Hunting down cultists may make you liable for a manslaughter charge. \
									Any access granted in response to the paranormal threat should be reset. \
									Any and all security gear that was handed out should be returned. Finally, all weapons (including improvised) should be removed from the crew.",
									"Central Command Higher Dimensional Affairs", 'sound/AI/commandreport.ogg')

/datum/game_mode/proc/rise(cultist)
	if(!ishuman(cultist) || !iscultist(cultist))
		return
	var/mob/living/carbon/human/H = cultist
	if(!H.original_eye_color)
		H.original_eye_color = H.get_eye_color()
	H.change_eye_color(BLOODCULT_EYE, FALSE)
	H.update_eyes()
	ADD_TRAIT(H, CULT_EYES, CULT_TRAIT)
	H.update_body()

/datum/game_mode/proc/ascend(cultist)
	if(!ishuman(cultist) || !iscultist(cultist))
		return
	var/mob/living/carbon/human/H = cultist
	new /obj/effect/temp_visual/cult/sparks(get_turf(H), H.dir)
	H.update_halo_layer()

/datum/game_mode/proc/descend(cultist)
	if(!ishuman(cultist) || !iscultist(cultist))
		return
	var/mob/living/carbon/human/H = cultist
	new /obj/effect/temp_visual/cult/sparks(get_turf(H), H.dir)
	H.update_halo_layer()
	to_chat(cultist, "<span class='userdanger'>The halo above your head shatters!</span>")
	playsound(cultist, "shatter", 50, TRUE)

/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CULT]
	if(cult_mind.current)
		culthud.join_hud(cult_mind.current)
		set_antag_hud(cult_mind.current, "hudcultist")

/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CULT]
	if(cult_mind.current)
		culthud.leave_hud(cult_mind.current)
		set_antag_hud(cult_mind.current, null)

/datum/game_mode/proc/add_cult_actions(datum/mind/cult_mind)
	if(cult_mind.current)
		var/datum/action/innate/cult/comm/C = new
		var/datum/action/innate/cult/check_progress/D = new
		C.Grant(cult_mind.current)
		D.Grant(cult_mind.current)
		if(ishuman(cult_mind.current))
			var/datum/action/innate/cult/blood_magic/magic = new
			magic.Grant(cult_mind.current)
			var/datum/action/innate/cult/use_dagger/dagger = new
			dagger.Grant(cult_mind.current)
		cult_mind.current.update_action_buttons(TRUE)


/datum/game_mode/cult/declare_completion()
	if(cult_team.sacrifices_required == NARSIE_HAS_RISEN)
		SSticker.mode_result = "cult win - cult win"
		to_chat(world, "<span class='danger'> <FONT size = 3>The cult wins! It has succeeded in summoning [GET_CULT_DATA(entity_name, "their god")]!</FONT></span>")
	else if(cult_team.sacrifices_required == NARSIE_HAS_FALLEN)
		SSticker.mode_result = "cult draw - narsie died, nobody wins"
		to_chat(world, "<span class='danger'> <FONT size = 3>Nobody wins! [GET_CULT_DATA(entity_name, "the cult god")] was summoned, but banished!</FONT></span>")
	else
		SSticker.mode_result = "cult loss - staff stopped the cult"
		to_chat(world, "<span class='warning'> <FONT size = 3>The staff managed to stop the cult!</FONT></span>")

	..()

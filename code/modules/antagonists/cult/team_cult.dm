/datum/team/cult
	name = "Cult"
	antag_datum_type = /datum/antagonist/cultist

	/// Does the cult have glowing eyes
	var/cult_risen = FALSE
	/// Does the cult have halos
	var/cult_ascendant = FALSE
	/// How many crew need to be converted to rise
	var/rise_number
	/// How many crew need to be converted to ascend
	var/ascend_number
	/// Used for the CentComm announcement at ascension
	var/ascend_percent
	/// Variable used for tracking the progress of the cult's sacrifices & god summonings
	var/cult_status = NARSIE_IS_ASLEEP

	/// God summon objective added when ready_to_summon() is called
	var/datum/objective/eldergod/obj_summon
	var/sacrifices_done = 0
	var/sacrifices_required = 2

	/// Are cultist mirror shields active yet?
	var/mirror_shields_active = FALSE

/datum/team/cult/New(list/starting_members)
	..()
	SSticker.mode.cult_team = src

	objective_holder.add_objective(/datum/objective/servecult)

	cult_threshold_check()
	addtimer(CALLBACK(src, PROC_REF(cult_threshold_check)), 2 MINUTES) // Check again in 2 minutes for latejoiners

	cult_status = NARSIE_DEMANDS_SACRIFICE

	create_next_sacrifice()

	for(var/datum/mind/M as anything in starting_members)
		var/datum/antagonist/cultist/cultist = M.has_antag_datum(__IMPLIED_TYPE__)
		cultist.equip_roundstart_cultist()

/datum/team/cult/Destroy(force, ...)
	SSticker.mode.cult_team = null
	return ..()


// /datum/team/cult/get_target_excludes()
// 	return ..() + get_targetted_head_minds()
/datum/team/cult/handle_adding_member(datum/mind/new_member)
	. = ..()
	check_cult_size()
	RegisterSignal(new_member.current, COMSIG_MOB_STATCHANGE, PROC_REF(cultist_stat_change))
	RegisterSignal(new_member.current, COMSIG_PARENT_QDELETING, PROC_REF(remove_member))

/datum/team/cult/handle_removing_member(datum/mind/member)
	. = ..()
	UnregisterSignal(member.current, COMSIG_MOB_STATCHANGE)
	check_cult_size()


/datum/team/cult/on_round_end()
	var/list/endtext = list()
	endtext += "<br><b>The cultists' objectives were:</b>"
	for(var/datum/objective/obj in objective_holder.get_objectives())
		endtext += "<br>[obj.explanation_text] - "
		if(!obj.check_completion())
			endtext += "<font color='red'>Fail.</font>"
		else
			endtext += "<font color='green'><B>Success!</B></font>"

	to_chat(world, endtext.Join(""))

/datum/team/cult/proc/add_cult_immunity(mob/living/target)
	ADD_TRAIT(target, TRAIT_CULT_IMMUNITY, CULT_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(remove_cult_immunity), target), 1 MINUTES)

/datum/team/cult/proc/remove_cult_immunity(mob/living/target)
	REMOVE_TRAIT(target, TRAIT_CULT_IMMUNITY, CULT_TRAIT)

/**
 * Makes sure that the signal stays on the correct body when a cultist changes bodies
 */
/datum/team/cult/proc/cult_body_transfer(old_body, new_body)
	UnregisterSignal(old_body, COMSIG_MOB_STATCHANGE)
	RegisterSignal(new_body, COMSIG_MOB_STATCHANGE, PROC_REF(cultist_stat_change))

/**
  * Returns the current number of cultists and constructs.
  *
  * Returns the number of cultists and constructs in a list ([1] = Cultists, [2] = Constructs), or as one combined number.
  *
  * * separate - Should the number be returned as a list with two separate values (Humans and Constructs) or as one number.
  */
/datum/team/cult/proc/get_cultists(separate = FALSE)
	var/cultists = 0
	var/constructs = 0
	for(var/datum/mind/M as anything in members)
		if(isnull(M))
			stack_trace("Found a null mind in /datum/team/cult's members.") // ctodo remove TM stack traces
			continue
		if(isnull(M.current))
			stack_trace("Found a mind with no body in /datum/team/cult's members.") // ctodo remove TM stack traces
			continue
		if(QDELETED(M) || M.current.stat == DEAD)
			continue
		if(ishuman(M.current) && !M.current.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
			cultists++
		else if(isconstruct(M.current))
			constructs++
	if(separate)
		return list(cultists, constructs)
	return cultists + constructs

/datum/team/cult/proc/cultist_stat_change(mob/target_cultist, new_stat, old_stat)
	if(new_stat == old_stat) // huh, how? whatever, we ignore it
		return
	if(new_stat != DEAD && old_stat != DEAD)
		return // switching between alive and unconcious
	// switching between dead and alive/unconcious
	check_cult_size()

/datum/team/cult/proc/check_cult_size()
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

/datum/team/cult/proc/cult_rise()
	cult_risen = TRUE
	for(var/datum/mind/M in members)
		if(!ishuman(M.current))
			continue
		SEND_SOUND(M.current, sound('sound/hallucinations/i_see_you2.ogg'))
		to_chat(M.current, "<span class='cultlarge'>The veil weakens as your cult grows, your eyes begin to glow...</span>")

	addtimer(CALLBACK(src, PROC_REF(all_members_timer), TYPE_PROC_REF(/datum/antagonist/cultist, rise)), 20 SECONDS)

/datum/team/cult/proc/cult_ascend()
	cult_ascendant = TRUE
	for(var/datum/mind/M in members)
		if(!ishuman(M.current))
			continue
		SEND_SOUND(M.current, sound('sound/hallucinations/im_here1.ogg'))
		to_chat(M.current, "<span class='cultlarge'>Your cult is ascendant and the red harvest approaches - you cannot hide your true nature for much longer!</span>")

	addtimer(CALLBACK(src, PROC_REF(all_members_timer), TYPE_PROC_REF(/datum/antagonist/cultist, ascend)), 20 SECONDS)
	GLOB.major_announcement.Announce("Picking up extradimensional activity related to the Cult of [GET_CULT_DATA(entity_name, "Nar'Sie")] from your station. Data suggests that about [ascend_percent * 100]% of the station has been converted. Security staff are authorized to use lethal force freely against cultists. Non-security staff should be prepared to defend themselves and their work areas from hostile cultists. Self defense permits non-security staff to use lethal force as a last resort, but non-security staff should be defending their work areas, not hunting down cultists. Dead crewmembers must be revived and deconverted once the situation is under control.", "Central Command Higher Dimensional Affairs", 'sound/AI/commandreport.ogg')

/datum/team/cult/proc/cult_fall()
	cult_ascendant = FALSE
	for(var/datum/mind/M in members)
		if(!ishuman(M.current))
			continue
		SEND_SOUND(M.current, sound('sound/hallucinations/wail.ogg'))
		to_chat(M.current, "<span class='cultlarge'>The veil repairs itself, your power grows weaker...</span>")

	addtimer(CALLBACK(src, PROC_REF(all_members_timer), TYPE_PROC_REF(/datum/antagonist/cultist, descend)), 20 SECONDS)
	GLOB.major_announcement.Announce("Paranormal activity has returned to minimal levels. \
									Security staff should minimize lethal force against cultists, using non-lethals where possible. \
									All dead cultists should be taken to medbay or robotics for immediate revival and deconversion. \
									Non-security staff may defend themselves, but should prioritize leaving any areas with cultists and reporting the cultists to security. \
									Self defense permits non-security staff to use lethal force as a last resort. Hunting down cultists may make you liable for a manslaughter charge. \
									Any access granted in response to the paranormal threat should be reset. \
									Any and all security gear that was handed out should be returned. Finally, all weapons (including improvised) should be removed from the crew.",
									"Central Command Higher Dimensional Affairs", 'sound/AI/commandreport.ogg')
/**
 * This is a magic fuckin proc that takes a proc_ref, and calls it on all the human cultists.
 * Created so that we don't make 1000 timers, and I'm too lazy to make a proc for all of these.
 * Used in callbacks for some *magic bullshit*.
 */
/datum/team/cult/proc/all_members_timer(proc_ref_to_call)
	for(var/datum/mind/M in members)
		if(!ishuman(M.current))
			continue
		var/datum/antagonist/cultist/cultist = M.has_antag_datum(/datum/antagonist/cultist)
		if(cultist)
			call(cultist, proc_ref_to_call)() // yes this is a type proc ref passed by a callback, i know its deranged

/datum/team/cult/proc/is_convertable_to_cult(datum/mind/mind)
	if(!mind)
		return FALSE
	if(!mind.current)
		return FALSE
	if(IS_SACRIFICE_TARGET(mind))
		return FALSE
	if(mind.has_antag_datum(/datum/antagonist/cultist))
		return TRUE //If they're already in the cult, assume they are convertable
	if(HAS_MIND_TRAIT(mind.current, TRAIT_HOLY))
		return FALSE
	if(ishuman(mind.current))
		var/mob/living/carbon/human/H = mind.current
		if(ismindshielded(H)) //mindshield protects against conversions unless removed
			return FALSE
	if(mind.offstation_role)
		return FALSE
	if(issilicon(mind.current))
		return FALSE //can't convert machines, that's ratvar's thing
	if(isguardian(mind.current))
		var/mob/living/simple_animal/hostile/guardian/G = mind.current
		if(IS_CULTIST(G.summoner))
			return TRUE //can't convert it unless the owner is converted
	if(isgolem(mind.current))
		return FALSE
	if(isanimal(mind.current))
		return FALSE
	return TRUE

/**
  * Decides at the start of the round how many conversions are needed to rise/ascend.
  *
  * The number is decided by (Percentage * (Players - Cultists)), so for example at 110 players it would be 11 conversions for rise. (0.1 * (110 - 4))
  * These values change based on population because 20 cultists are MUCH more powerful if there's only 50 players, compared to 120.
  *
  * Below 100 players, [CULT_RISEN_LOW] and [CULT_ASCENDANT_LOW] are used.
  * Above 100 players, [CULT_RISEN_HIGH] and [CULT_ASCENDANT_HIGH] are used.
  */
/datum/team/cult/proc/cult_threshold_check()
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

/datum/team/cult/proc/study_objectives(mob/living/M, display_members = FALSE) //Called by cultists/cult constructs checking their objectives
	if(!M)
		return FALSE

	switch(cult_status)
		if(NARSIE_IS_ASLEEP)
			to_chat(M, "<span class='cult'>[GET_CULT_DATA(entity_name, "The Dark One")] is asleep. This is probably a bug.</span>")
		if(NARSIE_DEMANDS_SACRIFICE)
			var/list/all_objectives = objective_holder.get_objectives()
			if(!length(all_objectives))
				to_chat(M, "<span class='danger'>Error: No objectives. Something went wrong, adminhelp with F1.</span>")
			else
				var/datum/objective/sacrifice/current_obj = all_objectives[length(all_objectives)] //get the last obj in the list, ie the current one
				to_chat(M, "<span class='cult'>The Veil needs to be weakened before we are able to summon [GET_CULT_DATA(entity_title1, "The Dark One")].</span>")
				to_chat(M, "<span class='cult'>Current goal: [current_obj.explanation_text]</span>")
		if(NARSIE_NEEDS_SUMMONING)
			to_chat(M, "<span class='cult'>The Veil is weak! We can summon [GET_CULT_DATA(entity_title3, "The Dark One")]!</span>")
			to_chat(M, "<span class='cult'>Current goal: [obj_summon.explanation_text]</span>")
		if(NARSIE_HAS_RISEN)
			to_chat(M, "<span class='cultlarge'>\"I am here.\"</span>")
			to_chat(M, "<span class='cult'>Current goal:</span> <span class='cultlarge'>\"Feed me.\"</span>")
		if(NARSIE_HAS_FALLEN)
			to_chat(M, "<span class='cultlarge'>[GET_CULT_DATA(entity_name, "The Dark One")] has been banished!</span>")
			to_chat(M, "<span class='cult'>Current goal: Slaughter the unbelievers!</span>")
		else
			to_chat(M, "<span class='danger'>Error: Cult objective status currently unknown. Something went wrong, adminhelp with F1.</span>")

	if(!display_members)
		return
	var/list/cult = get_cultists(separate = TRUE)
	var/total_cult = cult[1] + cult[2]

	var/overview = "<span class='cultitalic'><br><b>Current cult members: [total_cult]"
	if(!cult_ascendant)
		var/rise = rise_number - total_cult
		var/ascend = ascend_number - total_cult
		if(rise > 0)
			overview += " | Conversions until Rise: [rise]"
		else if(ascend > 0)
			overview += " | Conversions until Ascension: [ascend]"
	to_chat(M, "[overview]</b></span>")

	if(cult[2]) // If there are any constructs, separate them out
		to_chat(M, "<span class='cultitalic'><b>Cultists:</b> [cult[1]]")
		to_chat(M, "<span class='cultitalic'><b>Constructs:</b> [cult[2]]")

/datum/team/cult/proc/create_next_sacrifice()
	var/datum/objective/sacrifice/obj_sac = objective_holder.add_objective(/datum/objective/sacrifice)
	if(!obj_sac.target)
		qdel(obj_sac)
		ready_to_summon()
		return
	return obj_sac

/datum/team/cult/proc/current_sac_objective() //Return the current sacrifice objective datum, if any
	var/list/presummon_objs = objective_holder.get_objectives()
	if(cult_status == NARSIE_DEMANDS_SACRIFICE && length(presummon_objs))
		var/datum/objective/sacrifice/current_obj = presummon_objs[length(presummon_objs)]
		if(istype(current_obj))
			return current_obj

/datum/team/cult/proc/is_sac_target(datum/mind/mind)
	var/datum/objective/sacrifice/current_obj = current_sac_objective()
	return istype(current_obj) && current_obj.target == mind

/datum/team/cult/proc/find_new_sacrifice_target(datum/mind/mind)
	var/datum/objective/sacrifice/current_obj = current_sac_objective()
	if(!current_obj.find_target())
		ready_to_summon()
		return FALSE
	for(var/datum/mind/cult_mind in members)
		if(cult_mind && cult_mind.current)
			to_chat(cult_mind.current, "<span class='danger'>[GET_CULT_DATA(entity_name, "Your god")]</span> murmurs, <span class='cultlarge'>Our goal is beyond your reach. Sacrifice [current_obj.target] instead...</span>")
	return TRUE

/datum/team/cult/proc/successful_sacrifice()
	var/datum/objective/sacrifice/current_obj = current_sac_objective()
	current_obj.sacced = TRUE
	sacrifices_done++
	if(sacrifices_done >= sacrifices_required)
		ready_to_summon()
		return

	var/datum/objective/sacrifice/obj_sac = create_next_sacrifice()
	if(!obj_sac)
		return

	for(var/datum/mind/cult_mind in members)
		if(cult_mind && cult_mind.current)
			to_chat(cult_mind.current, "<span class='cult'>You and your acolytes have made progress, but there is more to do still before [GET_CULT_DATA(entity_title1, "The Dark One")] can be summoned!</span>")
			to_chat(cult_mind.current, "<span class='cult'>Current goal: [obj_sac.explanation_text]</span>")

/datum/team/cult/proc/ready_to_summon()
	if(!obj_summon)
		obj_summon = objective_holder.add_objective(/datum/objective/eldergod)

	cult_status = NARSIE_NEEDS_SUMMONING
	for(var/datum/mind/cult_mind in members)
		if(cult_mind && cult_mind.current)
			to_chat(cult_mind.current, "<span class='cult'>You and your acolytes have succeeded in preparing the station for the ultimate ritual!</span>")
			to_chat(cult_mind.current, "<span class='cult'>Current goal: [obj_summon.explanation_text]</span>")

/datum/team/cult/proc/successful_summon()
	cult_status = NARSIE_HAS_RISEN
	obj_summon.summoned = TRUE

/datum/team/cult/proc/narsie_death()
	cult_status = NARSIE_HAS_FALLEN
	obj_summon.killed = TRUE
	for(var/datum/mind/cult_mind in members)
		if(cult_mind && cult_mind.current)
			to_chat(cult_mind.current, "<span class='cultlarge'>RETRIBUTION!</span>")
			to_chat(cult_mind.current, "<span class='cult'>Current goal: Slaughter the heretics!</span>")

/datum/team/cult/proc/get_cult_status_as_string()
	var/list/bitch_list = list(
		"[NARSIE_IS_ASLEEP]" = "NARSIE_IS_ASLEEP",
		"[NARSIE_DEMANDS_SACRIFICE]" = "NARSIE_DEMANDS_SACRIFICE",
		"[NARSIE_NEEDS_SUMMONING]" = "NARSIE_NEEDS_SUMMONING",
		"[NARSIE_HAS_RISEN]" = "NARSIE_HAS_RISEN",
		"[NARSIE_HAS_FALLEN]" = "NARSIE_HAS_FALLEN",
	)
	return bitch_list["[cult_status]"]
/**
 * ADMIN STUFF DOWN YONDER
 */

/datum/team/cult/get_admin_commands()
	return list(
		"Cult Mindspeak" = CALLBACK(src, PROC_REF(cult_mindspeak)),
		"Unlock Nar'Sie summoning" = CALLBACK(src, PROC_REF(unlock_summoning))
		)

/datum/team/cult/proc/cult_mindspeak(admin_caller)
	var/input = stripped_input(admin_caller, "Communicate to all the cultists with the voice of [GET_CULT_DATA(entity_name, "a cult god")]", "Voice of [GET_CULT_DATA(entity_name, "Cult God")]")
	if(!input)
		return

	for(var/datum/mind/H in members)
		if(H.current)
			to_chat(H.current, "<span class='cult'>[GET_CULT_DATA(entity_name, "Your god")] murmurs,</span> <span class='cultlarge'>\"[input]\"</span>")

	for(var/mob/dead/observer/O in GLOB.player_list)
		to_chat(O, "<span class='cult'>[GET_CULT_DATA(entity_name, "Your god")] murmurs,</span> <span class='cultlarge'>\"[input]\"</span>")

	message_admins("Admin [key_name_admin(admin_caller)] has talked with the Voice of [GET_CULT_DATA(entity_name, "Cult God")].")
	log_admin("[key_name(admin_caller)] Voice of [GET_CULT_DATA(entity_name, "Cult God")]: [input]")

/datum/team/cult/proc/unlock_summoning(admin_caller)
	if(alert(admin_caller, "Unlock the ability to summon Nar'Sie?", "Cult Debug", "Yes", "No") != "Yes")
		return

	ready_to_summon()

	message_admins("Admin [key_name_admin(admin_caller)] has unlocked the Cult's ability to summon Nar'Sie.")
	log_admin("Admin [key_name_admin(admin_caller)] has unlocked the Cult's ability to summon Nar'Sie.")

/datum/team/cult/Topic(href, href_list)
	. = ..()

	if(!check_rights(R_ADMIN))
		return

	// manually cramming some shit in here, because it only conditonally pops up

	switch(href_list["cult_command"])
		if("cult_adjustsacnumber")
			var/amount = input("Adjust the amount of sacrifices required before summoning Nar'Sie", "Sacrifice Adjustment", 2) as null | num
			if(amount > 0)
				var/old = sacrifices_required
				sacrifices_required = amount
				message_admins("Admin [key_name_admin(usr)] has modified the amount of cult sacrifices required before summoning from [old] to [amount]")
				log_admin("Admin [key_name_admin(usr)] has modified the amount of cult sacrifices required before summoning from [old] to [amount]")

		if("cult_newtarget")
			if(alert(usr, "Reroll the cult's sacrifice target?", "Cult Debug", "Yes", "No") != "Yes")
				return

			find_new_sacrifice_target()

			message_admins("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")
			log_admin("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")

		if("cult_newsummonlocations")
			if(!obj_summon)
				to_chat(usr, "<span class='danger'>The cult has NO summon objective yet.</span>")
				return
			if(alert(usr, "Reroll the cult's summoning locations?", "Cult Debug", "Yes", "No") != "Yes")
				return

			obj_summon.find_summon_locations(TRUE)
			if(cult_status == NARSIE_NEEDS_SUMMONING) //Only update cultists if they are already have the summon goal since they arent aware of summon spots till then
				for(var/datum/mind/cult_mind in members)
					if(cult_mind && cult_mind.current)
						to_chat(cult_mind.current, "<span class='cult'>The veil has shifted! Our summoning will need to take place elsewhere.</span>")
						to_chat(cult_mind.current, "<span class='cult'>Current goal : [obj_summon.explanation_text]</span>")

			message_admins("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")
			log_admin("Admin [key_name_admin(usr)] has rerolled the Cult's sacrifice target.")

/datum/team/cult/get_admin_html()
	var/list/content = ..()
	content += "<br><br>Cult Controls:<br>"
	content += "<br>Cult Status: [get_cult_status_as_string()]"
	content += "<br>Sacrifices completed: [sacrifices_done]"
	content += "<br>Sacrifice required for summoning: [sacrifices_required]<br>"
	if(obj_summon)
		content += "<br>Summoning locations: [english_list(obj_summon.summon_spots)]"
		content += "<br><a href='?src=[UID()];cult_command=cult_newsummonlocations'>Reroll summoning locations</a>"
	else
		content += "<br>Summoning locations: None, Cult has not yet reached the summoning stage."
	content += "<br>"
	if(cult_status == NARSIE_DEMANDS_SACRIFICE)
		content += "<br><a href='?src=[UID()];cult_command=cult_adjustsacnumber'>Modify amount of sacrifices required</a>"
		content += "<br><a href='?src=[UID()];cult_command=cult_newtarget'>Reroll sacrifice target</a>"
	else
		content += "<br>Cannot modify amount of sacrifices required (Summon available!)"
		content += "<br>Cannot reroll sacrifice target (Summon available!)"
	return content

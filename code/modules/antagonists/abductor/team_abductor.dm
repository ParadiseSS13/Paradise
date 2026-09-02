RESTRICT_TYPE(/datum/team/abductor)

/datum/team/abductor
	name = "Abductor"
	var/team_number
	var/datum/mind/agent
	var/datum/mind/scientist
	var/datum/objective/experiment/experiment_objective

/datum/team/abductor/create_team(list/starting_members)
	. = ..()
	handle_team_number()
	name = "Mothership [pick(GLOB.greek_letters)]" //TODO Ensure unique and actual alieny names

	add_team_objective(/datum/objective/stay_hidden)
	var/datum/objective/experiment/experiment = new
	experiment.abductor_team_number = team_number
	experiment_objective = experiment
	add_team_objective(experiment)

/datum/team/abductor/can_create_team()
	return length(SSticker.mode.actual_abductor_teams) < 4

/datum/team/abductor/assign_team(list/starting_members)
	SSticker.mode.actual_abductor_teams |= src

/datum/team/abductor/clear_team_reference()
	SSticker.mode.actual_abductor_teams -= src

/datum/team/abductor/get_admin_commands()
	return list(
		"Create Agent" = CALLBACK(src, PROC_REF(create_agent)),
		"Create Scientist" = CALLBACK(src, PROC_REF(create_scientist))
		)

/datum/team/abductor/proc/handle_team_number()
	// Maybe someday, make this more complex to make sure if a team is lost somehow, that we can recycle their number
	team_number = length(SSticker.mode.actual_abductor_teams)

/datum/team/abductor/proc/create_body(location, datum/mind/mind, is_scientist = FALSE)
	var/mob/living/carbon/human/body = new /mob/living/carbon/human/abductor(location)
	var/datum/species/abductor/abductor_species = body.dna.species
	abductor_species.team = team_number
	abductor_species.scientist = is_scientist
	var/old_body = mind.current
	mind.transfer_to(body)
	if(old_body)
		qdel(old_body)

	var/datum_type = /datum/antagonist/abductor
	body.real_name = name + " Agent"
	if(is_scientist)
		datum_type = /datum/antagonist/abductor/scientist
		body.real_name = name + " Scientist"
	mind.name = body.real_name
	mind.set_original_mob(body)

	var/datum/antagonist/abductor/antag = new datum_type()
	antag.our_team = src
	mind.add_antag_datum(antag)
	antag.equip_abductor()

	if(is_scientist)
		scientist = mind
	else
		agent = mind

/datum/team/abductor/proc/create_agent()
	if(agent)
		return
	var/turf/target_loc
	var/turf/backup
	for(var/obj/effect/landmark/abductor/agent/A in GLOB.landmarks_list)
		if(A.team == team_number)
			target_loc = get_turf(A)
		else
			backup = get_turf(A)
	var/list/available_minds = (members - scientist)
	if(!length(available_minds))
		return
	create_body(target_loc || backup, pick(available_minds), is_scientist = FALSE)

/datum/team/abductor/proc/create_scientist()
	if(scientist)
		return
	var/turf/target_loc
	var/turf/backup
	for(var/obj/effect/landmark/abductor/scientist/A in GLOB.landmarks_list)
		if(A.team == team_number)
			target_loc = get_turf(A)
		else
			backup = get_turf(A)
	var/list/available_minds = (members - agent)
	if(!length(available_minds))
		return
	create_body(target_loc || backup, pick(available_minds), is_scientist = TRUE)

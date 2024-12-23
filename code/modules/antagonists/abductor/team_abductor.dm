RESTRICT_TYPE(/datum/team/abductor)

/datum/team/abductor
	name = "Base Abductor"
	var/team_number
	var/datum/antagonist/abductor/agent
	var/datum/antagonist/abductor/scientist/scientist

/datum/team/abductor/create_team(list/starting_members)
	. = ..()
	handle_team_number()
	name = "Mothership [pick(GLOB.greek_letters)]" //TODO Ensure unique and actual alieny names

	add_team_objective(/datum/objective/stay_hidden)
	var/datum/objective/experiment/experiment = new
	experiment.abductor_team_number = team_number
	add_team_objective(experiment)
	create_agent()
	create_scientist()

/datum/team/abductor/can_create_team()
	return length(SSticker.mode.actual_abductor_teams) < 4

/datum/team/abductor/assign_team(list/starting_members)
	SSticker.mode.actual_abductor_teams |= src

/datum/team/abductor/clear_team_reference()
	SSticker.mode.actual_abductor_teams -= src

/datum/team/abductor/proc/handle_team_number()
	// ctodo, make this more complex to make sure if a team is lost somehow, that we can recycle their number
	team_number = length(length(SSticker.mode.actual_abductor_teams)) + 1

/datum/team/abductor/proc/create_body(location, datum/mind/mind, is_scientist = FALSE)
	var/mob/living/carbon/human/body = new /mob/living/carbon/human/abductor(location)
	mind.transfer_to(body)

	var/datum_type = /datum/antagonist/abductor
	if(is_scientist)
		datum_type = /datum/antagonist/abductor/scientist
	var/datum/antagonist/abductor/antag = new datum_type()
	antag.our_team = src
	mind.add_antag_datum(antag)
	antag.equip_abductor()

/datum/team/abductor/proc/create_agent()
	if(agent)
		return
	var/turf/target_loc
	var/turf/backup
	for(var/obj/effect/landmark/abductor/A in GLOB.landmarks_list)
		if(istype(A, /obj/effect/landmark/abductor/agent))
			if(A.team == team_number)
				target_loc = get_turf(A)
			else
				backup = get_turf(A)
	var/list/available_minds = (members - scientist?.owner)
	if(!length(available_minds))
		return
	create_body(target_loc || backup, pick(available_minds), is_scientist = FALSE)

/datum/team/abductor/proc/create_scientist()
	if(scientist)
		return
	var/turf/target_loc
	var/turf/backup
	for(var/obj/effect/landmark/abductor/A in GLOB.landmarks_list)
		if(istype(A, /obj/effect/landmark/abductor/scientist))
			if(A.team == team_number)
				target_loc = get_turf(A)
			else
				backup = get_turf(A)
	var/list/available_minds = (members - agent?.owner)
	if(!length(available_minds))
		return
	create_body(target_loc || backup, pick(available_minds), is_scientist = TRUE)

#define ABDUCTOR_MAX_TEAMS 4

/datum/antagonist/abductor
	name = "\improper Abductor"
	roundend_category = "abductors"
	job_rank = ROLE_ABDUCTOR
	special_role = SPECIAL_ROLE_ABDUCTOR
	antag_hud_name = "abductor"
	antag_hud_type = ANTAG_HUD_ABDUCTOR
	wiki_page_name = "Abductor"
	var/datum/team/abductor_team/team
	var/sub_role
	var/outfit
	var/landmark_type
	var/greet_text

/datum/antagonist/abductor/agent
	name = "\improper Abductor Agent"
	sub_role = "Agent"
	outfit = /datum/outfit/abductor/agent
	landmark_type = /obj/effect/landmark/abductor/agent
	greet_text = "Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve."

/datum/antagonist/abductor/scientist
	name = "\improper Abductor Scientist"
	sub_role = "Scientist"
	outfit = /datum/outfit/abductor/scientist
	landmark_type = /obj/effect/landmark/abductor/scientist
	greet_text = "Use your experimental console and surgical equipment to monitor your agent and experiment upon abducted humans."

/datum/antagonist/abductor/scientist/onemanteam
	name = "\improper Abductor Solo"
	outfit = /datum/outfit/abductor/scientist/onemanteam

/datum/team/abductor_team
	member_name = "abductor"
	var/team_number
	var/list/datum/mind/abductees = list()
	var/static/team_count = 1

/datum/team/abductor_team/New()
	..()
	team_number = team_count++
	name = "Mothership [pick(GLOB.possible_changeling_IDs)]" //TODO Ensure unique and actual alieny names
	add_objective(new/datum/objective/experiment)

/datum/team/abductor_team/is_solo()
	return FALSE

/datum/team/abductor_team/proc/add_objective(datum/objective/O)
	O.team = src
	//O.update_explanation_text()
	objectives += O

// LANDMARKS
/obj/effect/landmark/abductor
	var/team_number = 1

/obj/effect/landmark/abductor/agent
	icon_state = "abductor_agent"
/obj/effect/landmark/abductor/scientist
	icon_state = "abductor"

// OBJECTIVES
/datum/objective/experiment
	target_amount = 6

/datum/objective/experiment/New()
	explanation_text = "Experiment on [target_amount] humans."

/datum/objective/experiment/check_completion()
	for(var/obj/machinery/abductor/experiment/E in GLOB.machines)
		if(!istype(team, /datum/team/abductor_team))
			return FALSE
		var/datum/team/abductor_team/T = team
		if(E.team_number == T.team_number)
			return E.points >= target_amount
	return FALSE
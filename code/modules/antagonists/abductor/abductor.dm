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
	greet_text = "Use your stealth technology and equipment to incapacitate crew for your scientist to retrieve."

/datum/antagonist/abductor/scientist
	name = "\improper Abductor Scientist"
	sub_role = "Scientist"
	outfit = /datum/outfit/abductor/scientist
	landmark_type = /obj/effect/landmark/abductor/scientist
	greet_text = "Use your experimental console and surgical equipment to monitor your agent and experiment upon abducted crew."

/datum/antagonist/abductor/get_team()
	return team

/datum/antagonist/abductor/on_gain()
	owner.special_role = SPECIAL_ROLE_ABDUCTOR
	objectives += team.objectives
	finalize_abductor()
	ADD_TRAIT(owner, TRAIT_ABDUCTOR_TRAINING, ABDUCTOR_ANTAGONIST)
	return ..()

/datum/antagonist/abductor/Destroy(force, ...)
	owner.special_role = null
	REMOVE_TRAIT(owner, TRAIT_ABDUCTOR_TRAINING, ABDUCTOR_ANTAGONIST)
	var/mob/living/carbon/human/H = owner.current
	for(var/obj/item/I in H)
		qdel(I)
	H.set_species(/datum/species/grey) //Ayy lmao downgrade
	H.real_name = random_name(H.gender, H.dna.species.name)
	return ..()

/datum/antagonist/abductor/greet()
	. = ..()
	to_chat(owner.current, span_notice("With the help of your teammate, kidnap and experiment on station crewmembers!"))
	to_chat(owner.current, span_notice("[greet_text]"))
	//owner.announce_objectives()

/datum/antagonist/abductor/proc/finalize_abductor()
	//Equip
	var/mob/living/carbon/human/H = owner.current
	H.set_species(/datum/species/abductor)
	var/datum/species/abductor/S
	S = H.dna.species
	S.team_number = team.team_number

	H.real_name = "[team.name] [sub_role]"
	H.equipOutfit(outfit)

	move_to_ship(owner.current)

/datum/antagonist/abductor/proc/move_to_ship(mob/M)
	for(var/obj/effect/landmark/abductor/LM in GLOB.landmarks_list)
		if(istype(LM, landmark_type) && LM.team_number == team.team_number)
			M.forceMove(LM.loc)
			break

/datum/antagonist/abductor/admin_add(datum/mind/new_owner, mob/admin)
	if(!ishuman(new_owner.current))
		to_chat(admin, span_warning("This only works on humans!"))
		return
	var/list/current_teams = list()
	for(var/datum/team/abductor_team/T in GLOB.antagonist_teams)
		current_teams[T.name] = T
	var/choice = input(admin,"Add to which team ?") as null|anything in (current_teams + "new team")
	if (choice == "new team")
		team = new
	else if(choice in current_teams)
		team = current_teams[choice]
	else
		return FALSE
	
	var/mob/living/carbon/human/H = new_owner.current
	var/gear = alert("Agent or Scientist?","Gear","Agent","Scientist")
	if(gear)
		for(var/obj/item/I in H)
			qdel(I)
		if(gear == "Agent")
			sub_role = "Agent"
			outfit = /datum/outfit/abductor/agent
			landmark_type = /obj/effect/landmark/abductor/agent
			greet_text = "Use your stealth technology and equipment to incapacitate crew for your scientist to retrieve."
		else
			sub_role = "Scientist"
			outfit = /datum/outfit/abductor/scientist
			landmark_type = /obj/effect/landmark/abductor/scientist
			greet_text = "Use your experimental console and surgical equipment to monitor your agent and experiment upon abducted crew."
	else
		return FALSE
	new_owner.add_antag_datum(src)
	log_admin("[key_name(usr)] made [key_name(new_owner)] [name] on [choice]!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(new_owner)] [name] on [choice] !")

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

/datum/antagonist/abductor/create_team(datum/team/abductor_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/team/abductor_team/roundend_report()
	var/list/result = list()

	var/won = TRUE
	for(var/datum/objective/O in objectives)
		if(!O.check_completion())
			won = FALSE
	if(won)
		result += "<span class='greentext big'>[name] team fulfilled its mission!</span>"
	else
		result += "<span class='redtext big'>[name] team failed its mission.</span>"

	result += "<span class='header'>The abductors of [name] were:</span>"
	for(var/datum/mind/abductor_mind in members)
		result += printplayer(abductor_mind)
	result += printobjectives(objectives)

	return "<div class='panel redborder'>[result.Join("<br>")]</div>"

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
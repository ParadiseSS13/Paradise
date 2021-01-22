#define HIJACK_BROTHER_CHANCE 10
#define BROTHER_OBJ_STEAL_CHANCE 50
#define BROTHER_OBJ_DESTROY_CHANCE 20
#define BROTHER_OBJ_MAROON_CHANCE 30
#define BROTHER_OBJ_KILL_ONCE_CHANCE 50

/*
	*This is the holder for a blood brothers team, objectives, team members and team name are stored here for bookkeeping purposes.
	*Guide lines for Blood brother teams: This team is a two or three members, if you need to add or remove members from a pre-generated blood brother team, disband the team and traitor the remaining blood brother instead.
	*/
/datum/team/brother_team
	name = "brotherhood"
	member_name = "Blood brother"
	/// The chosen meeting area for a blood brother team.
	var/meeting_area
	/// list of meeting area's for blood brothers
	var/meeting_areas = list("The Bar", "Dorms", "Escape Dock", "Arrivals", "Holodeck", "Primary Tool Storage", "Recreation Area", "Chapel", "Library")
	/// This includes assassinate as well as steal objectives. prevents duplicate objectives
	var/list/assigned_targets = list() 

/datum/team/brother_team/is_solo()
	return FALSE

/datum/team/brother_team/add_member(datum/mind/new_member)
	. = ..()
	new_member.add_antag_datum(/datum/antagonist/brother)

/datum/team/brother_team/remove_member(datum/mind/member)
	. = ..()
	member.remove_antag_datum(/datum/antagonist/brother)

/datum/team/brother_team/Destroy()
	for(var/b in members)
		var/datum/mind/brother = b
		brother.remove_antag_datum(/datum/antagonist/brother)
	GLOB.brother_teams -= src	
	return ..()

/*
	* This picks the meeting area for the team from var/meeting_areas
	*/
/datum/team/brother_team/proc/pick_meeting_area()
	meeting_area = pick(meeting_areas)

/*
	* This builds the name of the team
	*/
/datum/team/brother_team/proc/update_name()
	//we're grabbing the last names of the players in question, if they don't have a last name, doesn't matter first name will be used instead.
	var/list/last_names = list()
	for(var/m in members)
		var/datum/mind/M = m
		var/list/split_name = splittext(M.name, " ")
		last_names += split_name[length(split_name)]

	name = last_names.Join(" & ")

/*
	* This builds the blood brother team objectives.
	*/
/datum/team/brother_team/proc/forge_brother_objectives()
	objectives = list()
	var/is_hijacker = prob(HIJACK_BROTHER_CHANCE)
	for(var/i = 1 to max(1, (config.brother_objectives_amount + (length(members) > 2) - is_hijacker))) //this determines the number of objectives generated.
		forge_single_objective()
	if(is_hijacker)
		if(!(locate(/datum/objective/hijack) in objectives))
			objectives += new /datum/objective/hijack
	else if(!(locate(/datum/objective/escape) in objectives))
		objectives += new /datum/objective/escape
/*
	* This is what picks the blood brother team objectives.
	*/
/datum/team/brother_team/proc/forge_single_objective()
	if(prob(BROTHER_OBJ_STEAL_CHANCE))
		var/list/active_ais = active_ais()
		if(length(active_ais) && prob(BROTHER_OBJ_DESTROY_CHANCE))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.team = src
			destroy_objective.find_target()
			if(destroy_objective in assigned_targets)	        
				return FALSE
			else if(destroy_objective.target)					    
				assigned_targets.Add(destroy_objective.target)
			objectives += destroy_objective
		else if(prob(BROTHER_OBJ_MAROON_CHANCE))
			var/datum/objective/maroon/shared/maroon_objective = new
			maroon_objective.team = src
			maroon_objective.find_target()
			if(maroon_objective in assigned_targets)
				return FALSE
			else if(maroon_objective.target)
				assigned_targets.Add(maroon_objective.target)
			objectives += maroon_objective
		else if(prob(BROTHER_OBJ_KILL_ONCE_CHANCE))
			var/datum/objective/assassinate/once/shared/kill_objective = new
			kill_objective.team = src
			kill_objective.find_target()
			if(kill_objective.target in assigned_targets)
				return FALSE
			else if(kill_objective.target)
				assigned_targets.Add(kill_objective.target)
			objectives += kill_objective
		else
			var/datum/objective/assassinate/shared/kill_objective = new
			kill_objective.team = src
			kill_objective.find_target()
			if(kill_objective.target in assigned_targets)
				return FALSE
			else if(kill_objective.target)
				assigned_targets.Add(kill_objective.target)
			objectives += kill_objective
	else
		var/datum/objective/steal/steal_objective = new
		steal_objective.team = src
		steal_objective.find_target()
		if(steal_objective.steal_target in assigned_targets)
			return FALSE
		else if(steal_objective.steal_target)
			assigned_targets.Add(steal_objective.steal_target)
		objectives += steal_objective


/*
	*Blood brother is a team orientated antagonist that is meant to complete traitor style objectives using just their team members and game knowledge.
	*/
/datum/antagonist/brother
	name = "Brother"
	roundend_category = "Brother"
	job_rank = ROLE_BROTHER
	var/datum/team/brother_team/team //the owning team is stored here.
/*
	* This proc is called when a new brother team is created.
	*/
/datum/antagonist/brother/create_team(datum/team/brother_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization")
	team = new_team

/datum/antagonist/brother/get_team()
	return team

/datum/antagonist/brother/on_gain()
	SSticker.mode.brothers += owner
	owner.objectives += team.objectives
	owner.special_role |= ROLE_BROTHER
	update_brother_icons_added()
	finalize_brother()
	return ..()

/datum/antagonist/brother/on_removal()
	SSticker.mode.brothers -= owner
	owner.objectives -= team.objectives
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'> You are no longer a blood brother!</span>")
	owner.special_role -= ROLE_BROTHER
	update_brother_icons_removed()
	return ..()

/datum/antagonist/brother/proc/give_meeting_area()
	if(!owner.current || !team || !team.meeting_area)
		return
	to_chat(owner.current, "<b>Your designated meeting area:</b> [team.meeting_area]")
	antag_memory += "<b>Meeting Area</b>: [team.meeting_area]<br>"

/datum/antagonist/brother/greet()
	var/list/brothers = team.members - owner
	var/brother_text = english_list(brothers)
	to_chat(owner.current, "<span class='alertsyndie'>You are the [owner.special_role] of [brother_text].</span>")
	to_chat(owner.current, "The Syndicate only accepts those that have proven themselves. Prove yourself and prove your [team.member_name]s by completing your objectives together!")
	owner.announce_objectives()
	antag_memory += "<b>Your brothers are</b>: [brother_text].<br>"
	give_meeting_area()

/datum/antagonist/brother/proc/finalize_brother()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/brother/proc/update_brother_icons_added(datum/mind/brother_mind)
	if(locate(/datum/objective/hijack) in owner.objectives)
		var/datum/atom_hud/antag/hijackhud = GLOB.huds[ANTAG_HUD_TRAITOR]
		hijackhud.join_hud(owner.current, null)
		set_antag_hud(owner.current, "hudhijackbrother")
	else
		var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
		traitorhud.join_hud(owner.current, null)
		set_antag_hud(owner.current, "hudbrother")

/datum/antagonist/brother/proc/update_brother_icons_removed(datum/mind/brother_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(owner.current, null)
	set_antag_hud(owner.current, null)

#define HIJACKBROTHERCHANCE 10
#define BROTHEROBJSTEALCHANCE 50
#define BROTHEROBJDESTROYCHANCE 20
#define BROTHEROBJMAROONCHANCE 30
#define BROTHEROBJKILLONCECHANCE 50

/*
	*This is the holder for a blood brothers team, objectives, team members and team name are stored here for bookkeeping purposes.
	*/
/datum/team/brother_team
	name = "brotherhood"
	member_name = "Blood brother"
	var/meeting_area
	var/meeting_areas = list("The Bar", "Dorms", "Escape Dock", "Arrivals", "Holodeck", "Primary Tool Storage", "Recreation Area", "Chapel", "Library")
	var/list/assigned_targets = list() // This includes assassinate as well as steal objectives. prevents duplicate objectives

/datum/team/brother_team/is_solo()
	return FALSE

/datum/team/brother_team/Destroy()
	for(var/datum/mind/brother in members)
		if(brother.has_antag_datum(/datum/antagonist/brother))
			brother.remove_antag_datum(/datum/antagonist/brother)
	SSticker.mode.brother_teams -= src	
	return ..()

/datum/team/brother_team/proc/pick_meeting_area()
	meeting_area = pick(meeting_areas)

/datum/team/brother_team/proc/update_name()
	var/list/last_names = list()
	for(var/datum/mind/M in members)
		var/list/split_name = splittext(M.name, " ")
		last_names += split_name[split_name.len]

	name = last_names.Join(" & ")

/datum/team/brother_team/proc/add_objective(datum/objective/O)
	objectives += O

/datum/team/brother_team/proc/forge_brother_objectives()
	objectives = list()
	var/is_hijacker = prob(HIJACKBROTHERCHANCE)
	for(var/i = 1 to max(1, (config.brother_objectives_amount + (members.len > 2) - is_hijacker))) //this determines the number of objectives generated.
		forge_single_objective()
	if(is_hijacker)
		if(!locate(/datum/objective/hijack) in objectives)
			add_objective(new/datum/objective/hijack)
	else if(!locate(/datum/objective/escape) in objectives)
		add_objective(new/datum/objective/escape)

/datum/team/brother_team/proc/forge_single_objective() //objectives are chosen here.
	if(prob(BROTHEROBJSTEALCHANCE))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(BROTHEROBJDESTROYCHANCE))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.team = src
			destroy_objective.find_target()
			if("[destroy_objective]" in assigned_targets)	        
				return FALSE
			else if(destroy_objective.target)					    
				assigned_targets.Add("[destroy_objective.target]")
			add_objective(destroy_objective)
		else if(prob(BROTHEROBJMAROONCHANCE))
			var/datum/objective/maroon/shared/maroon_objective = new
			maroon_objective.team = src
			maroon_objective.find_target()
			if("[maroon_objective]" in assigned_targets)
				return FALSE
			else if(maroon_objective.target)
				assigned_targets.Add("[maroon_objective.target]")
			add_objective(maroon_objective)
		else if(prob(BROTHEROBJKILLONCECHANCE))
			var/datum/objective/assassinate/once/shared/kill_objective = new
			kill_objective.team = src
			kill_objective.find_target()
			if("[kill_objective.target]" in assigned_targets)
				return FALSE
			else if(kill_objective.target)
				assigned_targets.Add("[kill_objective.target]")
			add_objective(kill_objective)
		else
			var/datum/objective/assassinate/shared/kill_objective = new
			kill_objective.team = src
			kill_objective.find_target()
			if("[kill_objective.target]" in assigned_targets)
				return FALSE
			else if(kill_objective.target)
				assigned_targets.Add("[kill_objective.target]")
			add_objective(kill_objective)
	else
		var/datum/objective/steal/steal_objective = new
		steal_objective.team = src
		steal_objective.find_target()
		if("[steal_objective.steal_target]" in assigned_targets)
			return FALSE
		else if(steal_objective.steal_target)
			assigned_targets.Add("[steal_objective.steal_target]")
		add_objective(steal_objective)

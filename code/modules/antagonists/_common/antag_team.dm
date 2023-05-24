GLOBAL_LIST_EMPTY(antagonist_teams)

/**
 * # Antagonist Team
 *
 * Datum used by team antagonists to track it's members and objectives the team needs to complete.
 */
/datum/team
	/// The name of the team.
	var/name = "Generic Team Name"
	/// A list of [minds][/datum/mind] who belong to this team.
	var/list/members
	/// A list of objectives which all team members share.
	var/list/objectives
	/// Type of antag datum members of this team have. Also given to new members added by admins.
	var/antag_datum_type

/datum/team/New(list/starting_members)
	..()
	members = list()
	objectives = list()
	if(starting_members && !islist(starting_members))
		starting_members = list(starting_members)
	for(var/datum/mind/M as anything in starting_members)
		add_member(M)
	GLOB.antagonist_teams += src

/datum/team/Destroy(force = FALSE, ...)
	for(var/datum/mind/member as anything in members)
		remove_member(member)
	QDEL_LIST_CONTENTS(objectives)
	members.Cut()
	GLOB.antagonist_teams -= src
	return ..()

/**
 * Adds `new_member` to this team.
 *
 * Generally this should ONLY be called by `add_antag_datum()` to ensure proper order of operations.
 */
/datum/team/proc/add_member(datum/mind/new_member)
	SHOULD_CALL_PARENT(TRUE)
	var/datum/antagonist/team_antag = get_antag_datum_from_member(new_member)
	members |= new_member
	team_antag.objectives |= objectives

/**
 * Removes `member` from this team.
 */
/datum/team/proc/remove_member(datum/mind/member)
	SHOULD_CALL_PARENT(TRUE)
	var/datum/antagonist/A = get_antag_datum_from_member(member)
	members -= member
	A.objectives -= objectives

/**
 * Adds a new member to this team from a list of players in the round.
 */
/datum/team/proc/admin_add_member(mob/user)
	var/list/valid_minds = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H.mind || (H.mind in members))
			continue
		valid_minds[H.real_name] = H.mind

	var/name = input(user, "Choose a player to add to this team", "Add Team Member") as null|anything in valid_minds
	if(!name)
		to_chat(user, "<span class='warning'>No suitable humanoid targets found!</span>")
		return

	var/datum/mind/new_member = valid_minds[name]
	add_member(new_member)

/**
 * Adds a team objective to each member's matching antag datum.
 */
/datum/team/proc/add_objective_to_members(datum/objective/O)
	for(var/datum/mind/M as anything in members)
		var/datum/antagonist/A = get_antag_datum_from_member(M)
		A.objectives |= O

/**
 * Remove a team objective from each member's matching antag datum.
 */
/datum/team/proc/remove_objective_from_members(datum/objective/O)
	for(var/datum/mind/M as anything in members)
		var/datum/antagonist/A = get_antag_datum_from_member(M)
		A.objectives -= O
	objectives -= O
	qdel(O)

/**
 * Return an antag datum from a member which is linked with this team.
 */
/datum/team/proc/get_antag_datum_from_member(datum/mind/member)
	for(var/datum/antagonist/A as anything in member.antag_datums)
		if(A.get_team() != src)
			continue
		return A
	// If no matching antag datum was found, give them one.
	if(antag_datum_type)
		member.add_antag_datum(antag_datum_type, src)

/**
 * Allows admins to send a message to all members of this team.
 */
/datum/team/proc/admin_communicate(mob/user)
	var/message = input(user, "Enter a message to send to the team:", "Team Message") as text|null
	if(!message)
		return

	for(var/datum/mind/M as anything in members)
		to_chat(M.current, "<font color='#d6000b'><span class='bold'>Admin Team Message ([user.key]): </span><span class='notice'>[message]</span>")

	message_admins("Team Message: [key_name(user)] -> '[name]' team. Message: [message]")
	log_admin("Team Message: [key_name(user)] -> '[name]' team. Message: [message]")

/**
 * Allows admins to add a team objective.
 */
/datum/team/proc/admin_add_objective(mob/user)
	var/selected = input("Select an objective type:", "Objective Type") as null|anything in GLOB.admin_objective_list
	if(!selected)
		return

	var/objective_type = GLOB.admin_objective_list[selected]
	var/datum/objective/O = new objective_type(team_to_join = src)
	O.find_target(members) // Blacklist any team members from being the target.
	objectives |= O
	add_objective_to_members(O)

	message_admins("[key_name_admin(user)] added objective [O.type] to the team '[name]'.")
	log_admin("[key_name(user)] added objective [O.type] to the team '[name]'.")

/**
 * Allows admins to remove a team objective.
 */
/datum/team/proc/admin_remove_objective(mob/user, datum/objective/O)
	remove_objective_from_members(O)
	message_admins("[key_name_admin(user)] removed objective [O.type] from the team '[name]'.")
	log_admin("[key_name(user)] removed objective [O.type] from the team '[name]'.")

/**
 * Allows admins to rename the team.
 */
/datum/team/proc/admin_rename_team(mob/user)
	var/team_name = stripped_input(user, "Enter a new name for the team:", "Rename Team")
	if(!team_name)
		return

	message_admins("[key_name_admin(user)] renamed the '[name]' team to '[team_name]'.")
	log_admin("[key_name(user)] renamed the '[name]' team to '[team_name]'.")
	name = team_name

/**
 * Allows admins to remove a team member.
 */
/datum/team/proc/admin_remove_member(mob/user, datum/mind/M)
	message_admins("[key_name_admin(user)] removed [key_name_admin(M)] from the team '[name]'.")
	log_admin("[key_name(user)] removed [key_name(M)] from the team '[name]'.")
	remove_member(M)

// Used for running team specific admin commands.
/datum/team/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	var/commands = get_admin_commands()
	for(var/admin_command in commands)
		if(href_list["command"] == admin_command)
			var/datum/callback/C = commands[admin_command]
			C.Invoke(usr)
			return

/**
 * A list of team-specific admin commands for this team. Should be in the form of `"command" = CALLBACK(x, PROC_REF(some_proc))`.
 */
/datum/team/proc/get_admin_commands()
	return list()

/**
 * Opens a window which lists the teams for the round.
 */
/datum/admins/proc/check_teams()
	if(!SSticker.HasRoundStarted())
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	var/datum/browser/popup = new(usr, "teams", "Team List", 500, 500)
	popup.set_content(list_teams())
	popup.open()

/**
 * Returns HTML content for the "check teams" window.
 */
/datum/admins/proc/list_teams()
	var/list/content = list()
	if(!length(GLOB.antagonist_teams))
		content += "There are currently no antag teams."
	for(var/datum/team/T as anything in GLOB.antagonist_teams)
		content += "<h3>[T.name] - [T.type]</h3>"
		content += "<a href='?_src_=holder;team_command=rename_team;team=[T.UID()]'>Rename Team</a>"
		content += "<a href='?_src_=holder;team_command=delete_team;team=[T.UID()]'>Delete Team</a>"
		content += "<a href='?_src_=holder;team_command=communicate;team=[T.UID()]'>Message Team</a>"
		for(var/command in T.get_admin_commands())
			// _src_ is T.UID() so it points to `/datum/team/Topic` instead of `/datum/admins/Topic`.
			content += "<a href='?_src_=[T.UID()];command=[command]'>[command]</a>"
		content += "<br><br>Objectives:<br><ol>"
		for(var/datum/objective/O as anything in T.objectives)
			content += "<li>[O.explanation_text] - <a href='?_src_=holder;team_command=remove_objective;team=[T.UID()];objective=[O.UID()]'>Remove</a></li>"
		content += "</ol><a href='?_src_=holder;team_command=add_objective;team=[T.UID()]'>Add Objective</a><br><br>"
		content += "Members: <br><ol>"
		for(var/datum/mind/M as anything in T.members)
			content += "<li>[M.name] - <a href='?_src_=holder;team_command=view_member;team=[T.UID()];member=[M.UID()]'>Show Player Panel</a>"
			content += "<a href='?_src_=holder;team_command=remove_member;team=[T.UID()];member=[M.UID()]'>Remove Member</a></li>"
		content += "</ol><a href='?_src_=holder;team_command=admin_add_member;team=[T.UID()]'>Add Member</a><hr>"
	return content.Join()

GLOBAL_LIST_EMPTY(antagonist_teams)

#define DEFAULT_TEAM_NAME "Generic Team Name"

/**
 * # Antagonist Team
 *
 * Datum used by team antagonists to track it's members and objectives the team needs to complete.
 */
/datum/team
	/// The name of the team.
	var/name = DEFAULT_TEAM_NAME
	/// A list of [minds][/datum/mind] who belong to this team.
	var/list/datum/mind/members
	/// A list of objectives which all team members share.
	var/datum/objective_holder/objective_holder
	/// Type of antag datum members of this team have. Also given to new members added by admins.
	var/antag_datum_type
	/// The name to save objective successes under in the blackboxes. Saves nothing if blank.
	var/blackbox_save_name

/datum/team/New(list/starting_members)
	..()
	members = list()
	objective_holder = new(src)
	if(starting_members && !islist(starting_members))
		starting_members = list(starting_members)
	for(var/datum/mind/M as anything in starting_members)
		add_member(M)
	GLOB.antagonist_teams += src

/datum/team/Destroy(force = FALSE, ...)
	for(var/datum/mind/member as anything in members)
		remove_member(member)
	qdel(objective_holder)
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
	var/datum/antagonist/antag = get_antag_datum_from_member(new_member) // make sure they have the antag datum
	members |= new_member
	if(!antag) // this team has no antag role, we'll add it directly to their mind team
		LAZYDISTINCTADD(new_member.teams, src)

/**
 * Removes `member` from this team.
 */
/datum/team/proc/remove_member(datum/mind/member)
	SHOULD_CALL_PARENT(TRUE)
	members -= member
	LAZYREMOVE(member.teams, src)
	var/datum/antagonist/antag = get_antag_datum_from_member(member)
	if(!QDELETED(antag))
		qdel(antag)

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
/datum/team/proc/add_team_objective(datum/objective/O, _explanation_text, mob/target_override)
	if(ispath(O))
		O = new O()
	O.team = src
	return objective_holder.add_objective(O, _explanation_text, target_override)

/**
 * Remove a team objective from each member's matching antag datum.
 */
/datum/team/proc/remove_team_objective(datum/objective/O)
	. = objective_holder.remove_objective(O)
	if(!QDELETED(O))
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
		return member.add_antag_datum(antag_datum_type, src)

/**
 * Special overrides for teams for target exclusion from objectives.
 */
/datum/team/proc/get_target_excludes()
	return members

/**
 * Displays the roundend stats for teams
 */
/datum/team/proc/on_round_end()
	if(!length(members))
		return
	var/temp_name = name
	if(temp_name == DEFAULT_TEAM_NAME || !temp_name)
		temp_name = "This team"
	else
		temp_name = "The [name]"

	var/list/to_send = list("<br><b>[temp_name]'s objectives were:</b>")
	var/obj_count = 1
	var/team_win = TRUE
	for(var/datum/objective/objective in objective_holder.get_objectives())

		var/text_to_add = "<b>Objective #[obj_count++]</b>: [objective.explanation_text] "
		var/failed = "FAIL"
		if(objective.check_completion())
			text_to_add += "<font color='green'><b>Success!</b></font>"
			failed = "SUCCESS"
		else
			text_to_add += "<font color='red'>Fail.</font>"
			team_win = FALSE
		to_send += text_to_add

		// handle blackbox stuff
		if(initial(blackbox_save_name)) // no im not letting admins var edit shit to the blackbox
			if(istype(objective, /datum/objective/steal))
				var/datum/objective/steal/S = objective
				SSblackbox.record_feedback("nested tally", "[initial(blackbox_save_name)]_team_steal_objective", 1, list("Steal [S.steal_target]", failed))
			else
				SSblackbox.record_feedback("nested tally", "[initial(blackbox_save_name)]_team_objective", 1, list("[objective.type]", failed))

	if(team_win)
		to_send += "<font color='green'><B>[temp_name] were successful!</B></font><br/>"
		if(initial(blackbox_save_name)) // no im not letting admins var edit shit to the blackbox
			SSblackbox.record_feedback("tally", "[initial(blackbox_save_name)]_team_success", 1, "SUCCESS")
	else
		to_send += "<font color='red'><B>[temp_name] failed!</B></font><br/>"
		if(initial(blackbox_save_name)) // no im not letting admins var edit shit to the blackbox
			SSblackbox.record_feedback("tally", "[initial(blackbox_save_name)]_team_success", 1, "FAIL")

	to_chat(world, to_send.Join("<br>"))

/**
 * Allows admins to send a message to all members of this team.
 */
/datum/team/proc/admin_communicate(mob/user)
	var/message = input(user, "Enter a message to send to the team:", "Team Message") as text|null
	if(!message)
		return

	var/team_message = chat_box_red("<font color='#d6000b'><span class='bold'>Admin '[name]' Team Message ([user.key]): </span></font><span class='notice'>[message]</span>")
	var/team_alert_sound = sound('sound/effects/adminticketopen.ogg')
	for(var/datum/mind/M as anything in members)
		if(QDELETED(M.current))
			continue
		SEND_SOUND(M.current, team_alert_sound)
		to_chat(M.current, team_message)

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
	O.find_target(get_target_excludes()) // Blacklist any team members from being the target.
	add_team_objective(O)

	message_admins("[key_name_admin(user)] added objective [O.type] to the team '[name]'.")
	log_admin("[key_name(user)] added objective [O.type] to the team '[name]'.")

/**
 * Allows admins to announce objectives to all team members.
 */
/datum/team/proc/admin_announce_objectives(mob/user)
	// This button is right next to the
	if(alert(user, "Are you sure you want to announce objectives to all members?", "Are you sure?", "Yes", "No") == "No")
		return


	log_admin("[key_name(usr)] has announced team [src]'s objectives")
	message_admins("[key_name_admin(usr)] has announced team [src]'s objectives")

	for(var/datum/mind/member in members)
		if(!member.current || !isliving(member.current))
			return
		var/list/messages = member.prepare_announce_objectives()
		to_chat(member.current, chat_box_red(messages.Join("<br>")))
		SEND_SOUND(member.current, sound('sound/ambience/alarm4.ogg'))

/**
 * Allows admins to remove a team objective.
 */
/datum/team/proc/admin_remove_objective(mob/user, datum/objective/O)
	remove_team_objective(O)
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

/datum/team/proc/get_admin_html()
	var/list/content = list()
	content += "<h3>[name] - [type]</h3>"
	content += "<a href='?_src_=holder;team_command=rename_team;team=[UID()]'>Rename Team</a>"
	content += "<a href='?_src_=holder;team_command=delete_team;team=[UID()]'>Delete Team</a>"
	content += "<a href='?_src_=holder;team_command=communicate;team=[UID()]'>OOC Message Team</a>"
	content += ADMIN_VV(src, "View Variables")
	for(var/command in get_admin_commands())
		// _src_ is UID() so it points to `/datum/team/Topic` instead of `/datum/admins/Topic`.
		content += "<a href='?_src_=[UID()];command=[command]'>[command]</a>"
	content += "<br><br>Objectives:<br><ol>"
	for(var/datum/objective/O as anything in objective_holder.get_objectives())
		content += "<li>[O.explanation_text] - <a href='?_src_=holder;team_command=remove_objective;team=[UID()];objective=[O.UID()]'>Remove</a></li>"
	content += "</ol><a href='?_src_=holder;team_command=add_objective;team=[UID()]'>Add Objective</a><br>"
	if(objective_holder.has_objectives())
		content += "</ol><a href='?_src_=holder;team_command=announce_objectives;team=[UID()]'>Announce Objectives to All Members</a><br><br>"
	content += "Members: <br><ol>"
	for(var/datum/mind/M as anything in members)
		content += "<li>[M.name] - <a href='?_src_=holder;team_command=view_member;team=[UID()];member=[M.UID()]'>Show Player Panel</a>"
		content += "<a href='?_src_=holder;team_command=remove_member;team=[UID()];member=[M.UID()]'>Remove Member</a></li>"
	content += "</ol><a href='?_src_=holder;team_command=admin_add_member;team=[UID()]'>Add Member</a>"
	return content

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
		content += "There are currently no antag teams.<br/>"
	content += "<a href='?_src_=holder;team_command=new_custom_team;'>Create new Team</a><br>"
	if(length(GLOB.antagonist_teams) > 1)
		var/index = 1
		for(var/datum/team/T as anything in GLOB.antagonist_teams) // with multiple teams, this is going to get messy. It should probably be turned into a tabs-like system
			content += "<a href='?_src_=holder;team_command=switch_team_tab;team_index=[index]'>[T.name]</a>"
			index++
	else
		team_switch_tab_index = 1

	if(length(GLOB.antagonist_teams))
		content += "<hr>"
		team_switch_tab_index = clamp(team_switch_tab_index, 1, length(GLOB.antagonist_teams))
		var/datum/team/T = GLOB.antagonist_teams[team_switch_tab_index]
		if(istype(T))
			var/list/stringy_list = T.get_admin_html()
			content += stringy_list.Join()
	return content.Join()

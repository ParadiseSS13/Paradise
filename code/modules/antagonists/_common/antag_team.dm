#define TEAM_OBJECTIVE_ASSASSINATE	"Assassinate"
#define TEAM_OBJECTIVE_MAROON		"Maroon"
#define TEAM_OBJECTIVE_PROTECT		"Protect"
#define TEAM_OBJECTIVE_DESTROY		"Destroy"
#define TEAM_OBJECTIVE_STEAL		"Steal"
#define TEAM_OBJECTIVE_ESCAPE		"Escape"
#define TEAM_OBJECTIVE_HIJACK		"Hijack"
#define TEAM_OBJECTIVE_CUSTOM		"Custom"

#define TEAM_OBJECTIVE_LIST list(TEAM_OBJECTIVE_ASSASSINATE, TEAM_OBJECTIVE_MAROON, TEAM_OBJECTIVE_PROTECT, TEAM_OBJECTIVE_DESTROY, TEAM_OBJECTIVE_STEAL, TEAM_OBJECTIVE_ESCAPE, TEAM_OBJECTIVE_HIJACK, TEAM_OBJECTIVE_CUSTOM)

/*Guide lines to using antag teams properly
	*Teams should have team specific antag datums to clarify that they are different from normal antags.
	*Teams do not mix, for each assigned team a mind would need a seperate datum/antag to acommodate it.
	*Team subtypes should handle their own add and remove member as they will have differing requirements.
	*Team subtypes should handle their own destroy as they will have differing requirements.
	*/
/datum/team
	var/list/datum/mind/members = list()
	var/name = "team"
	var/member_name = "member"
	/// Common objectives, these won't be added or removed automatically, subtypes handle this, this is here for bookkeeping purposes.
	var/list/objectives = list() 

/datum/team/New(starting_members)
	. = ..()
	if(starting_members)
		if(islist(starting_members))
			for(var/datum/mind/M in starting_members)
				add_member(M)
		else
			add_member(starting_members)

/datum/team/proc/is_solo()
	return length(members) == 1

/datum/team/proc/add_member(datum/mind/new_member) //subtypes should handle what happens when a new member is added
	members |= new_member

/datum/team/proc/remove_member(datum/mind/member)
	members -= member

/*
 *This proc brings up a teams edit window, child this off to team subtypes if they require specific additions otherwise leave as is.
 *Team edit handles the following:
 *Adding and removing members, remove_member and add_member should have childern in their own team subtypes, since those are required to do extra work to keep the team functioning properly.
 *Displays members, as well as providing links to the players /datum/mind, also whether they are dead or not.
 *Displays objectives, their explanation text, as well as allowing adding, announcing, editing and removing for normal objectives and objective completion toggle for custom objectives.
 *Finally allows for the disbanding of teams entirely, the proc/destory() on team subtypes should handle everything relating to this.
 */
/datum/team/proc/edit_team()
	if(!check_rights(R_ADMIN))
		return
	var/dat = "<html><head><title>Team [name]</title></head><br><body><table><tr><td><b>[name]</b></td><td></td></tr>"
	dat += "<tr><td><a href='?src=[UID()];add_member=1'>Add a member</a></td></tr>"
	dat += "<tr><td><a href='?src=[UID()];remove_member=1'>Remove a member</a></td></tr>"
	dat += "<tr><td><b>Team Members:</b></td></tr>"
	for(var/m in members)
		var/datum/mind/member = m
		var/mob/M = member.current
		dat += "<tr><td>[ADMIN_PP(M, "[M.real_name]")][M.client ? "" : " <i>(ghost)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td></tr>"
	dat += "<tr><td><b>Objectives:</b></td></tr>"
	var/objective_count = 1
	for(var/O in objectives)
		var/datum/objective/objective = O
		dat += "<tr><td><b>Objective #[objective_count]</b>: [objective.explanation_text]"
		dat += " <a href='?src=[UID()];obj_edit=[objective.UID()]'>Edit</a> " // Edit
		dat += "<a href='?src=[UID()];obj_delete=[objective.UID()]'>Delete</a> " // Delete
		dat += "<a href='?src=[UID()];obj_completed=[objective.UID()]'>" // Mark Completed
		dat += "<font color=[objective.completed ? "green" : "red"]>Toggle Completion</font>"
		dat += "</a></td></tr>"
		objective_count++
	dat += "<tr><td><a href='?src=[UID()];obj_add=1'>Add objective</a></td></tr>"
	dat += "<tr><td><a href='?src=[UID()];obj_announce=1'>Announce Objectives</a></td></tr>"
	dat += "<tr><td><a href='?src=[UID()];delete_team=1'>Disband team</a></td></tr>"
	dat += "</body></table><html>"
	usr << browse(dat, "window=editteam;size=400x500")

/*
	*Theses are what you call when you need to edit teams in any way.
	*/
/datum/team/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	if(href_list["add_member"])
		var/list/candidates = list()
		for(var/mob/living/L in GLOB.player_list)
			if(!L.mind) //technically anyone can be a member of a team, even silicons and simple mobs.
				continue						
			candidates[L.mind.name] = L.mind
		var/choice = input(usr, "Choose new member to add", "Member") as null|anything in candidates
		if(!choice)
			return
		add_member(choice)
		log_admin("[key_name(usr)] has added [choice] to antag team \"[name]\"")
		message_admins("[key_name_admin(usr)] has added [choice] to antag team \"[name]\"")

	else if (href_list["remove_member"])
		var/choice = input(usr, "Choose which member to remove", "Member") as null|anything in members
		if(!choice)
			return
		remove_member(choice)
		log_admin("[key_name(usr)] has removed [choice] from antag team \"[name]\"")
		message_admins("[key_name_admin(usr)] has removed [choice] from antag team \"[name]\"")

	else if(href_list["delete_team"])
		log_admin("[key_name(usr)] has disbanded antag team \"[name]\"")
		message_admins("[key_name_admin(usr)] has disbanded antag team \"[name]\"")
		qdel(src)

	else if(href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if(href_list["obj_edit"])
			objective = locateUID(href_list["obj_edit"])
			if(!objective)
				return
			objective_pos = objectives.Find(objective)

			/// Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"// Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)// Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"
		
		/// If your adding new objectives, insert the name here.
		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in TEAM_OBJECTIVE_LIST
		if(!new_obj_type)
			return

		var/datum/objective/new_objective = null
		/// if an objective doesn't require a target add a new if to the switch
		switch(new_obj_type) 
			if(TEAM_OBJECTIVE_ASSASSINATE, TEAM_OBJECTIVE_MAROON, TEAM_OBJECTIVE_PROTECT) 
				var/list/possible_targets = list()
				for(var/pt in SSticker.minds)
					var/datum/mind/possible_target = pt
					if(possible_target != src && ishuman(possible_target.current))
						possible_targets += possible_target.current

				var/mob/def_target = null
				var/list/objective_list = list(/datum/objective/assassinate, /datum/objective/maroon)
				if(objective && (objective.type in objective_list) && objective.target)
					def_target = objective.target.current
				possible_targets = sortAtom(possible_targets)

				var/mob/living/new_target = null
				if(length(possible_targets))
					if(alert(usr, "Do you want to pick the objective yourself? No will randomise it", "Pick objective", "Yes", "No") == "Yes")
						possible_targets += "Free objective"
						new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
					else
						new_target = pick(possible_targets)

					if(!new_target)
						return
				else
					to_chat(usr, "<span class='warning'>No possible target found. Defaulting to a Free objective.</span>")
					new_target = "Free objective"

				if(new_target == "Free objective")
					new_objective = new /datum/objective
					new_objective.team = src
					new_objective.target = null
					new_objective.explanation_text = "Free objective"
					return
				/// Objectives requiring targets go here
				switch(new_obj_type) 
					if(TEAM_OBJECTIVE_ASSASSINATE)
						new_objective = new /datum/objective/assassinate/shared
						new_objective.team = src
						new_objective.target = new_target
						/// Will display as special role if assigned mode is equal to special role.. Ninjas/commandos/nuke ops.
						new_objective.explanation_text = "Assassinate [new_target.name], the [new_target.mind.assigned_role == new_target.mind.special_role ? (new_target.mind.special_role) : (new_target.mind.assigned_role)]."
					if(TEAM_OBJECTIVE_MAROON)
						new_objective = new /datum/objective/maroon/shared
						new_objective.team = src
						new_objective.target = new_target
						new_objective.explanation_text = "Maroon [new_target.name], the [new_target.mind.assigned_role == new_target.mind.special_role ? (new_target.mind.special_role) : (new_target.mind.assigned_role)]."
					if(TEAM_OBJECTIVE_PROTECT)
						new_objective = new /datum/objective/protect/shared
						new_objective.team = src
						new_objective.target = new_target
						new_objective.explanation_text = "Protect [new_target.name], the [new_target.mind.assigned_role == new_target.mind.special_role ? (new_target.mind.special_role) : (new_target.mind.assigned_role)]."

			if(TEAM_OBJECTIVE_DESTROY)
				var/list/possible_targets = active_ais()
				if(length(possible_targets))
					var/mob/new_target = input("Select target:", "Objective target") as null|anything in possible_targets
					new_objective = new /datum/objective/destroy
					new_objective.target = new_target.mind
					new_objective.team = src
					new_objective.explanation_text = "Destroy [new_target.name], the experimental AI."
				else
					to_chat(usr, "No active AIs with minds")

			if(TEAM_OBJECTIVE_HIJACK)
				new_objective = new /datum/objective/hijack
				new_objective.team = src

			if(TEAM_OBJECTIVE_ESCAPE)
				new_objective = new /datum/objective/escape
				new_objective.team = src

			if(TEAM_OBJECTIVE_STEAL)
				if(!istype(objective, /datum/objective/steal))
					new_objective = new /datum/objective/steal
					new_objective.team = src
				else
					new_objective = objective
				var/datum/objective/steal/steal = new_objective
				if(!steal.select_target())
					return

			if(TEAM_OBJECTIVE_CUSTOM)
				var/expl = sanitize(copytext(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null, 1 ,MAX_MESSAGE_LEN))
				if(!expl)
					return
				new_objective = new /datum/objective
				new_objective.team = src
				new_objective.explanation_text = expl

		if(!new_objective)
			return

		if(objective)
			objectives -= objective
			for(var/m in members)
				var/datum/mind/M = m
				M.objectives -= objective
				M.objectives += new_objective
			qdel(objective)
			objectives.Insert(objective_pos, new_objective)
		else
			objectives += new_objective
			for(var/m in members)
				var/datum/mind/M = m
				M.objectives += new_objective
		log_admin("[key_name(usr)] has updated [name]'s objectives: [new_objective]")
		message_admins("[key_name_admin(usr)] has updated [name]'s objectives: [new_objective]")


	else if(href_list["obj_delete"])
		var/datum/objective/objective = locateUID(href_list["obj_delete"])
		if(!istype(objective))
			return
		for(var/datum/mind/M in members)
			M.objectives -= objective
		objectives -= objective

		log_admin("[key_name(usr)] has removed one of [name]'s objectives: [objective]")
		message_admins("[key_name_admin(usr)] has removed one of [name]'s objectives: [objective]")
		qdel(objective)

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locateUID(href_list["obj_completed"])
		if(!istype(objective))
			return
		objective.completed = !objective.completed

		log_admin("[key_name(usr)] has toggled the completion of one of [name]'s objectives")
		message_admins("[key_name_admin(usr)] has toggled the completion of one of [name]'s objectives")

	else if(href_list["obj_announce"])
		for(var/m in members)
			var/datum/mind/M = m
			M.announce_objectives()
			SEND_SOUND(M.current, sound('sound/ambience/alarm4.ogg'))
		log_admin("[key_name(usr)] has announced [name]'s objectives")
		message_admins("[key_name_admin(usr)] has announced [name]'s objectives")

	edit_team()

#undef TEAM_OBJECTIVE_ASSASSINATE
#undef TEAM_OBJECTIVE_MAROON
#undef TEAM_OBJECTIVE_PROTECT
#undef TEAM_OBJECTIVE_DESTROY
#undef TEAM_OBJECTIVE_STEAL
#undef TEAM_OBJECTIVE_ESCAPE
#undef TEAM_OBJECTIVE_HIJACK
#undef TEAM_OBJECTIVE_CUSTOM

#undef TEAM_OBJECTIVE_LIST


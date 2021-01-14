//A barebones antagonist team.
/datum/team
	var/list/datum/mind/members = list()
	var/name = "team"
	var/member_name = "member"
	var/list/objectives = list() //common objectives, these won't be added or removed automatically, subtypes handle this, this is here for bookkeeping purposes.

/datum/team/New(starting_members)
	. = ..()
	if(starting_members)
		if(islist(starting_members))
			for(var/datum/mind/M in starting_members)
				add_member(M)
		else
			add_member(starting_members)

/datum/team/proc/is_solo()
	return members.len == 1

/datum/team/proc/add_member(datum/mind/new_member) //subtypes should handle what happens when a new member is added
	members |= new_member

/datum/team/proc/remove_member(datum/mind/member)
	members -= member

/datum/team/proc/edit_team()
	if(!check_rights(R_ADMIN))
		return
	var/dat = "<br><table cellspacing=5><tr><td><B>[name]</B></td><td></td></tr>"
	dat += "<br><tr><td><a href='?src=[UID()];add_member=[src.UID()]'>Add a member</a></td></tr>"
	dat += "<br><tr><td><a href='?src=[UID()];remove_member=[src.UID()]'>Remove a member</a></td></tr>"
	for(var/datum/mind/member in members)
		dat += "<br><tr><td>[member.name]</td></tr>"
		for(var/datum/objective/objective in objectives)
			dat += "<br><tr><td><B>Objective</B>: [objective.explanation_text]"
			dat += " <a href='?src=[UID()];obj_edit=[objective.UID()]'>Edit</a> " // Edit
			dat += "<a href='?src=[UID()];obj_delete=[objective.UID()]'>Delete</a> " // Delete
			dat += "<a href='?src=[UID()];obj_completed=[objective.UID()]'>" // Mark Completed
			dat += "<font color=[objective.completed ? "green" : "red"]>Toggle Completion</font>"
			dat += "</a></td></tr>"
		dat += "<br><tr><td><a href='?src=[UID()];obj_announce=[src.UID()]'>Announce Objectives</a></td></tr>"
		dat += "<br><tr><td><a href='?src=[UID()];delete_team=[src.UID()]'>Disband team</a></td></tr>"
	dat += "</table>"
	usr << browse(dat, "window=roundstatus;size=400x500")

/*
	*Theses are what you call when you need to edit teams in any way.
	*/
/datum/team/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	if(href_list["add_member"])
		var/list/candidates = list()
		for(var/mob/living/L in GLOB.alive_mob_list)
			if(!L.mind) //technically anyone can be a member of a team, even silicons and simple mobs.
				continue						
			candidates[L.mind.name] = L.mind
		var/choice = input(usr,"Choose new member to add", "Member") as null|anything in candidates
		if(!choice)
			return
		add_member(choice)
		log_admin("[key_name(usr)] has added [choice] to [name]")
		message_admins("[key_name_admin(usr)] has added [choice] to [name]")

	else if (href_list["remove_member"])
		var/choice = input(usr, "Choose which member to remove", "Member") as null|anything in members
		if(!choice)
			return
		remove_member(choice)
		log_admin("[key_name(usr)] has removed [choice] to [name]")
		message_admins("[key_name_admin(usr)] has removed [choice] to [name]")

	else if(href_list["delete_team"])
		log_admin("[key_name(usr)] has disbanded [name]")
		message_admins("[key_name_admin(usr)] has disbanded [name]")
		qdel(src)

	else if(href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if(href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if(!objective)
				return
			objective_pos = objectives.Find(objective)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"
		
		// If your adding new objectives, insert the name here.
		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "protect", "hijack", "escape", "steal", "destroy", "maroon", "custom")
		if(!new_obj_type)
			return

		var/datum/objective/new_objective = null

		switch(new_obj_type) //if an objective doesn't require a target add a new if to the switch
			if("assassinate", "maroon", "protect") 
				var/list/possible_targets = list()
				for(var/datum/mind/possible_target in SSticker.minds)
					if((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target.current

				var/mob/def_target = null
				var/list/objective_list = list(/datum/objective/assassinate, /datum/objective/maroon)
				if(objective && (objective.type in objective_list) && objective:target)
					def_target = objective.target.current
				possible_targets = sortAtom(possible_targets)

				var/new_target
				if(length(possible_targets) > 0)
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
					new_objective:target = null
					new_objective.explanation_text = "Free objective"
					return

				switch(new_obj_type) //Objectives requiring targets go here
					if("assassinate")
						new_objective = new /datum/objective/assassinate/shared
						new_objective.team = src
						new_objective:target = new_target:mind
						//Will display as special role if assigned mode is equal to special role.. Ninjas/commandos/nuke ops.
						new_objective.explanation_text = "Assassinate [new_target:real_name], the [new_target:mind:assigned_role == new_target:mind:special_role ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."
					if("maroon")
						new_objective = new /datum/objective/maroon/shared
						new_objective.team = src
						new_objective:target = new_target:mind
						new_objective.explanation_text = "Maroon [new_target:real_name], the [new_target:mind:assigned_role == new_target:mind:special_role ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."
					if("protect")
						new_objective = new /datum/objective/protect/shared
						new_objective.team = src
						new_objective:target = new_target:mind
						new_objective.explanation_text = "Maroon [new_target:real_name], the [new_target:mind:assigned_role == new_target:mind:special_role ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

			if("destroy")
				var/list/possible_targets = active_ais(1)
				if(possible_targets.len)
					var/mob/new_target = input("Select target:", "Objective target") as null|anything in possible_targets
					new_objective = new /datum/objective/destroy
					new_objective.target = new_target.mind
					new_objective.team = src
					new_objective.explanation_text = "Destroy [new_target.name], the experimental AI."
				else
					to_chat(usr, "No active AIs with minds")

			if("hijack")
				new_objective = new /datum/objective/hijack
				new_objective.team = src

			if("escape")
				new_objective = new /datum/objective/escape
				new_objective.team = src

			if("steal")
				if(!istype(objective, /datum/objective/steal))
					new_objective = new /datum/objective/steal
					new_objective.team = src
				else
					new_objective = objective
				var/datum/objective/steal/steal = new_objective
				if(!steal.select_target())
					return

			if("custom")
				var/expl = sanitize(copytext(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null,1,MAX_MESSAGE_LEN))
				if(!expl)
					return
				new_objective = new /datum/objective
				new_objective.team = src
				new_objective.explanation_text = expl

		if(!new_objective)
			return

		if(objective)
			objectives -= objective
			for(var/datum/mind/M in members)
				M.objectives -= objective
				M.objectives += new_objective
			qdel(objective)
			objectives.Insert(objective_pos, new_objective)

		else
			objectives += new_objective
			for(var/datum/mind/M in members)
				M.objectives += objective
		log_admin("[key_name(usr)] has updated [name]'s objectives: [new_objective]")
		message_admins("[key_name_admin(usr)] has updated [name]'s objectives: [new_objective]")


	else if(href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))
			return
		for(var/datum/mind/M in members)
			M.objectives -= objective
		objectives -= objective

		log_admin("[key_name(usr)] has removed one of [name]'s objectives: [objective]")
		message_admins("[key_name_admin(usr)] has removed one of [name]'s objectives: [objective]")
		qdel(objective)

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))
			return
		objective.completed = !objective.completed

		log_admin("[key_name(usr)] has toggled the completion of one of [name]'s objectives")
		message_admins("[key_name_admin(usr)] has toggled the completion of one of [name]'s objectives")

	else if(href_list["obj_announce"])
		for(var/datum/mind/M in members)
			M.announce_objectives()
			SEND_SOUND(M.current, sound('sound/ambience/alarm4.ogg'))
		log_admin("[key_name(usr)] has announced [name]'s objectives")
		message_admins("[key_name_admin(usr)] has announced [name]'s objectives")

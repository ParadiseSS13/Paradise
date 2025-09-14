RESTRICT_TYPE(/datum/ui_module/admin/antagonist_menu)

/datum/ui_module/admin/antagonist_menu
	name = "Antagonist Menu"
	var/list/cached_data
	COOLDOWN_DECLARE(cache_cooldown)

/datum/ui_module/admin/antagonist_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminAntagMenu", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/admin/antagonist_menu/ui_data(mob/user)
	if(COOLDOWN_FINISHED(src, cache_cooldown))
		update_cached_data()
		COOLDOWN_START(src, cache_cooldown, 1 SECONDS)
	return cached_data

/datum/ui_module/admin/antagonist_menu/proc/update_cached_data()
	cached_data = list()
	cached_data["antagonists"] = list()
	for(var/datum/antagonist/antagonist as anything in GLOB.antagonists)
		var/list/temp_list = list()
		temp_list["antag_name"] = antagonist.name
		var/datum/mind/antag_mind = antagonist.owner
		temp_list["antag_mind_uid"] = antag_mind.UID()
		temp_list["name"] = ""
		temp_list["status"] = "No Body"
		temp_list["name"] = antag_mind.name
		temp_list["body_destroyed"] = TRUE
		if(!QDELETED(antag_mind.current))
			temp_list["body_destroyed"] = FALSE
			temp_list["status"] = ""
			if(antag_mind.current.stat == DEAD)
				temp_list["status"] = "(DEAD)"
			else if(!antag_mind.current.client)
				temp_list["status"] = "(SSD)"
			if(istype(get_area(antag_mind.current), /area/station/security/permabrig))
				temp_list["status"] += "(PERMA)"
		// temp_list["ckey"] = antag_mind.current.client?.ckey
		temp_list["ckey"] = ckey(antag_mind.key)
		temp_list["is_hijacker"] = istype((locate(/datum/objective/hijack) in antag_mind.get_all_objectives()), /datum/objective/hijack)
		cached_data["antagonists"] += list(temp_list)

	cached_data["objectives"] = list()
	for(var/datum/objective/objective as anything in GLOB.all_objectives)
		var/list/temp_list = list()
		temp_list["obj_name"] = objective.name || objective.type
		temp_list["obj_desc"] = objective.explanation_text
		temp_list["obj_uid"] = objective.UID()

		temp_list["status"] = objective.check_completion()
		if(!objective.holder)
			temp_list["owner_uid"] = "This shit fucked up"
			temp_list["owner_name"] = "???"
			if(istype(objective.owner, /datum/mind))
				// special handling for contractor objectives I guess
				temp_list["owner_uid"] = objective.owner.UID()
				temp_list["owner_name"] = objective.owner.name
		else
			var/datum/thingy = objective.holder.get_holder_owner()
			temp_list["owner_uid"] = thingy.UID()
			if(istype(thingy, /datum/antagonist))
				var/datum/antagonist/antag = thingy
				temp_list["owner_name"] = antag.owner.name
			else
				temp_list["owner_name"] = "[thingy]"

		var/datum/the_target = objective.found_target()
		temp_list["no_target"] = (!objective.needs_target && !the_target)
		temp_list["target_name"] = "\[No Assigned Target\]"
		temp_list["track"] = list()
		if(istype(the_target, /datum/mind))
			var/datum/mind/mind = the_target
			temp_list["target_name"] = mind.name
			temp_list["track"] = list(the_target.UID())

		if(istype(the_target, /datum/theft_objective))
			var/datum/theft_objective/theft = the_target
			var/atom/theft_target = theft.typepath
			temp_list["target_name"] = theft_target.name
			var/list/target_uids = list()
			for(var/atom/target in GLOB.high_value_items)
				if(!istype(target, theft.typepath))
					continue
				var/turf/T = get_turf(target)
				if(!T || is_admin_level(T.z))
					continue
				temp_list["target_name"] = target.name // is usually more accurate, i.e. captains modsuit
				target_uids += target.UID()
			temp_list["track"] = target_uids

		cached_data["objectives"] += list(temp_list)

	cached_data["high_value_items"] = list()
	for(var/atom/target in GLOB.high_value_items)
		if(QDELETED(target))
			continue
		var/list/temp_list = list()
		temp_list["name"] = target.name
		temp_list["person"] = get(target, /mob/living)
		temp_list["loc"] = target.loc ? target.loc.name : "null"
		temp_list["uid"] = target.UID()
		var/turf/T = get_turf(target)
		temp_list["admin_z"] = !T || is_admin_level(T.z)
		cached_data["high_value_items"] += list(temp_list)

	cached_data["security"] = list()
	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(!player.mind)
			continue
		var/role = determine_role(player)
		if(!(role in GLOB.active_security_positions) && player.mind.special_role != SPECIAL_ROLE_ERT)
			continue
		var/list/temp_list = list()
		temp_list["name"] = player.mind.name
		temp_list["role"] = role
		temp_list["mind_uid"] = player.mind.UID()
		temp_list["ckey"] = ckey(player.mind.key)
		temp_list["status"] = player.stat
		temp_list["antag"] = (isAntag(player) ? player.mind.special_role : "")
		temp_list["broken_bone"] = FALSE
		temp_list["internal_bleeding"] = FALSE
		for(var/name in player.bodyparts_by_name)
			var/obj/item/organ/external/e = player.bodyparts_by_name[name]
			if(!e)
				continue
			temp_list["broken_bone"] |= (e.status & ORGAN_BROKEN)
			temp_list["internal_bleeding"] |= (e.status & ORGAN_INT_BLEEDING)
		temp_list["health"] = player.health
		temp_list["max_health"] = player.maxHealth
		cached_data["security"] += list(temp_list)

	cached_data["disease_carriers"] = list()
	cached_data["virus_data"] = list()
	for(var/datum/disease/advance/virus in GLOB.active_diseases)
		var/list/temp_list = list()
		var/list/temp_list2 = list()
		var/mob/living/carbon/player = virus.affected_mob
		if(!player?.mind)
			continue
		temp_list["name"] = player.mind.name
		temp_list["mind_uid"] = player.mind.UID()
		temp_list["ckey"] = ckey(player.mind.key)
		temp_list["status"] = player.stat
		temp_list["health"] = player.health
		temp_list["max_health"] = player.maxHealth
		temp_list["progress"] = virus.progress
		temp_list["patient_zero"] = virus.carrier
		temp_list["virus_name"] = virus.name
		temp_list["strain"] = virus.strain
		if(!("[virus.strain]" in temp_list2))
			temp_list2["[virus.strain]"] = english_list(virus.symptoms)
		cached_data["disease_carriers"] += list(temp_list)
		cached_data["virus_data"] += temp_list2

/datum/ui_module/admin/antagonist_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("refresh")
			return TRUE
		if("show_player_panel")
			var/datum/mind/mind = locateUID(params["mind_uid"])
			if(QDELETED(mind.current))
				to_chat(ui.user, "<span class='warning'>Mind doesn't have a corresponding mob.</span>")
				return
			ui.user.client.holder.show_player_panel(mind.current)
		if("pm")
			ui.user.client.cmd_admin_pm(params["ckey"], null)
		if("follow")
			ghost_follow_uid(ui.user, params["datum_uid"])
		if("obs")
			var/client/C = ui.user.client
			var/datum/mind/mind = locateUID(params["mind_uid"])

			if(!ismob(mind.current))
				to_chat(ui.user, "<span class='warning'>This can only be used on instances of type /mob</span>")
				return
			C.admin_observe_target(mind.current)
		if("tp")
			var/datum/mind/mind = locateUID(params["mind_uid"])
			if(QDELETED(mind))
				to_chat(ui.user, "<span class='warning'>No mind!</span>")
				return
			mind.edit_memory()
		if("vv")
			ui.user.client.debug_variables(locateUID(params["uid"]), null)
		if("obj_owner")
			var/client/C = ui.user.client
			var/datum/target = locateUID(params["owner_uid"])
			if(QDELETED(target))
				to_chat(ui.user, "<span class='warning'>It seems the target you are looking for is null or deleted.</span>")
				return
			if(istype(target, /datum/antagonist))
				var/datum/antagonist/antag = target
				target = antag.owner
			if(istype(target, /datum/mind))
				var/datum/mind/mind = target
				if(!ismob(mind.current))
					to_chat(ui.user, "<span class='warning'>This can only be used on instances of type /mob</span>")
					return
				target = mind.current
				var/mob/dead/observer/A = C.mob
				A.manual_follow(target)
				return
			if(istype(target, /datum/team))
				ui.user.client.holder.team_switch_tab_index = clamp(GLOB.antagonist_teams.Find(target), 1, length(GLOB.antagonist_teams))
				ui.user.client.holder.check_teams()
				return
			to_chat(ui.user, "<span class='warning'>Type [target.type] isn't supported for finding the owner of an objective.</span>")

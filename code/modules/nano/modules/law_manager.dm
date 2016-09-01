/datum/nano_module/law_manager
	name = "Law manager"
	var/ion_law	= "IonLaw"
	var/zeroth_law = "ZerothLaw"
	var/inherent_law = "InherentLaw"
	var/supplied_law = "SuppliedLaw"
	var/supplied_law_position = MIN_SUPPLIED_LAW_NUMBER

	var/current_view = 0

	var/global/list/datum/ai_laws/admin_laws
	var/global/list/datum/ai_laws/player_laws
	var/mob/living/silicon/owner = null

/datum/nano_module/law_manager/New(var/mob/living/silicon/S)
	..()
	owner = S

	if(!admin_laws)
		admin_laws = new()
		player_laws = new()

		init_subtypes(/datum/ai_laws, admin_laws)
		admin_laws = dd_sortedObjectList(admin_laws)

		for(var/datum/ai_laws/laws in admin_laws)
			if(laws.selectable)
				player_laws += laws

/datum/nano_module/law_manager/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["set_view"])
		current_view = text2num(href_list["set_view"])
		return 1

	if(href_list["law_channel"])
		if(href_list["law_channel"] in owner.law_channels())
			owner.lawchannel = href_list["law_channel"]
		return 1

	if(href_list["state_law"])
		var/datum/ai_law/AL = locate(href_list["ref"]) in owner.laws.all_laws()
		if(AL)
			var/state_law = text2num(href_list["state_law"])
			owner.laws.set_state_law(AL, state_law)
		return 1

	if(href_list["add_zeroth_law"])
		if(zeroth_law && is_admin(usr) && !owner.laws.zeroth_law)
			owner.set_zeroth_law(zeroth_law)
		return 1

	if(href_list["add_ion_law"])
		if(ion_law && is_malf(usr))
			owner.add_ion_law(ion_law)
		return 1

	if(href_list["add_inherent_law"])
		if(inherent_law && is_malf(usr))
			owner.add_inherent_law(inherent_law)
		return 1

	if(href_list["add_supplied_law"])
		if(supplied_law && supplied_law_position >= 1 && MIN_SUPPLIED_LAW_NUMBER <= MAX_SUPPLIED_LAW_NUMBER && is_malf(usr))
			owner.add_supplied_law(supplied_law_position, supplied_law)
		return 1

	if(href_list["change_zeroth_law"])
		var/new_law = sanitize(input("Enter new law Zero. Leaving the field blank will cancel the edit.", "Edit Law", zeroth_law))
		if(new_law && new_law != zeroth_law && can_still_topic())
			zeroth_law = new_law
		return 1

	if(href_list["change_ion_law"])
		var/new_law = sanitize(input("Enter new ion law. Leaving the field blank will cancel the edit.", "Edit Law", ion_law))
		if(new_law && new_law != ion_law && can_still_topic())
			ion_law = new_law
		return 1

	if(href_list["change_inherent_law"])
		var/new_law = sanitize(input("Enter new inherent law. Leaving the field blank will cancel the edit.", "Edit Law", inherent_law))
		if(new_law && new_law != inherent_law && can_still_topic())
			inherent_law = new_law
		return 1

	if(href_list["change_supplied_law"])
		var/new_law = sanitize(input("Enter new supplied law. Leaving the field blank will cancel the edit.", "Edit Law", supplied_law))
		if(new_law && new_law != supplied_law && can_still_topic())
			supplied_law = new_law
		return 1

	if(href_list["change_supplied_law_position"])
		var/new_position = input(usr, "Enter new supplied law position between 1 and [MAX_SUPPLIED_LAW_NUMBER], inclusive. Inherent laws at the same index as a supplied law will not be stated.", "Law Position", supplied_law_position) as num|null
		if(isnum(new_position) && can_still_topic())
			supplied_law_position = Clamp(new_position, 1, MAX_SUPPLIED_LAW_NUMBER)
		return 1

	if(href_list["edit_law"])
		if(is_malf(usr))
			var/datum/ai_law/AL = locate(href_list["edit_law"]) in owner.laws.all_laws()
			if(AL)
				var/new_law = sanitize(input(usr, "Enter new law. Leaving the field blank will cancel the edit.", "Edit Law", AL.law))
				if(new_law && new_law != AL.law && is_malf(usr) && can_still_topic())
					log_and_message_admins("has changed a law of [owner] from '[AL.law]' to '[new_law]'")
					AL.law = new_law
			return 1

	if(href_list["delete_law"])
		if(is_malf(usr))
			var/datum/ai_law/AL = locate(href_list["delete_law"]) in owner.laws.all_laws()
			if(AL && is_malf(usr))
				owner.delete_law(AL)
		return 1

	if(href_list["state_laws"])
		owner.statelaws(owner.laws)
		return 1

	if(href_list["state_law_set"])
		var/datum/ai_laws/ALs = locate(href_list["state_law_set"]) in (is_admin(usr) ? admin_laws : player_laws)
		if(ALs)
			owner.statelaws(ALs)
		return 1

	if(href_list["transfer_laws"])
		if(is_malf(usr))
			var/datum/ai_laws/ALs = locate(href_list["transfer_laws"]) in (is_admin(usr) ? admin_laws : player_laws)
			if(ALs)
				log_and_message_admins("has transfered the [ALs.name] laws to [owner].")
				ALs.sync(owner, 0)
				current_view = 0
		return 1

	if(href_list["notify_laws"])
		to_chat(owner, "<span class='danger'>Law Notice</span>")
		owner.laws.show_laws(owner)
		if(isAI(owner))
			var/mob/living/silicon/ai/AI = owner
			for(var/mob/living/silicon/robot/R in AI.connected_robots)
				to_chat(R, "<span class='danger'>Law Notice</span>")
				R.laws.show_laws(R)
		if(usr != owner)
			to_chat(usr, "<span class='notice'>Laws displayed.</span>")
		return 1

	return 0

/datum/nano_module/law_manager/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	var/data[0]
	owner.lawsync()

	data["ion_law_nr"] = ionnum()
	data["ion_law"] = ion_law
	data["zeroth_law"] = zeroth_law
	data["inherent_law"] = inherent_law
	data["supplied_law"] = supplied_law
	data["supplied_law_position"] = supplied_law_position

	package_laws(data, "zeroth_laws", list(owner.laws.zeroth_law))
	package_laws(data, "ion_laws", owner.laws.ion_laws)
	package_laws(data, "inherent_laws", owner.laws.inherent_laws)
	package_laws(data, "supplied_laws", owner.laws.supplied_laws)

	data["isAI"] = isAI(owner)
	data["isMalf"] = is_malf(user)
	data["isSlaved"] = owner.is_slaved()
	data["isAdmin"] = is_admin(user)
	data["view"] = current_view

	var/channels[0]
	for(var/ch_name in owner.law_channels())
		channels[++channels.len] = list("channel" = ch_name)
	data["channel"] = owner.lawchannel
	data["channels"] = channels
	data["law_sets"] = package_multiple_laws(data["isAdmin"] ? admin_laws : player_laws)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "law_manager.tmpl", sanitize("[src] - [owner.name]"), 800, is_malf(user) ? 600 : 400, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/law_manager/proc/package_laws(var/list/data, var/field, var/list/datum/ai_law/laws)
	var/packaged_laws[0]
	for(var/datum/ai_law/AL in laws)
		packaged_laws[++packaged_laws.len] = list("law" = AL.law, "index" = AL.get_index(), "state" = owner.laws.get_state_law(AL), "ref" = "\ref[AL]")
	data[field] = packaged_laws
	data["has_[field]"] = packaged_laws.len

/datum/nano_module/law_manager/proc/package_multiple_laws(var/list/datum/ai_laws/laws)
	var/law_sets[0]
	for(var/datum/ai_laws/ALs in laws)
		var/packaged_laws[0]
		package_laws(packaged_laws, "zeroth_laws", list(ALs.zeroth_law, ALs.zeroth_law_borg))
		package_laws(packaged_laws, "ion_laws", ALs.ion_laws)
		package_laws(packaged_laws, "inherent_laws", ALs.inherent_laws)
		package_laws(packaged_laws, "supplied_laws", ALs.supplied_laws)
		law_sets[++law_sets.len] = list("name" = ALs.name, "header" = ALs.law_header, "ref" = "\ref[ALs]","laws" = packaged_laws)

	return law_sets

/datum/nano_module/law_manager/proc/is_malf(var/mob/user)
	return (is_admin(user) && !owner.is_slaved()) || is_special_character(owner)

/mob/living/silicon/proc/is_slaved()
	return 0

/mob/living/silicon/robot/is_slaved()
	return lawupdate && connected_ai ? sanitize(connected_ai.name) : null

/datum/nano_module/law_manager/proc/sync_laws(var/mob/living/silicon/ai/AI)
	if(!AI)
		return
	for(var/mob/living/silicon/robot/R in AI.connected_robots)
		R.sync()
	log_and_message_admins("has syncronized [AI]'s laws with its borgs.")

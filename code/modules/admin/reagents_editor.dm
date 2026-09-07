/datum/reagents_editor
	var/atom/target
	/// Indexed by target.UID
	var/static/list/datum/reagents_editor/editors = list()

/datum/reagents_editor/New(atom/target)
	src.target = target

/datum/reagents_editor/ui_state(mob/user)
	return GLOB.admin_state

/datum/reagents_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReagentsEditor")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/reagents_editor/ui_close(mob/user)
	var/open_uis = SStgui.open_uis_by_src[src.UID()]
	if(isnull(open_uis) || !islist(open_uis) || length(open_uis) <= 1)
		// Remove after everyone closes UI to avoid memory leak
		editors -= target.UID()

/datum/reagents_editor/ui_static_data(mob/user)
	. = ..()

	var/list/reagents_information = list()
	.["reagentsInformation"] = reagents_information
	for(var/id in GLOB.chemical_reagents_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[id]
		reagents_information[id] = list(
			"name" = R.name,
		)

/datum/reagents_editor/ui_data(mob/user)
	. = ..()

	var/list/reagents = list()
	.["reagents"] = reagents
	for(var/datum/reagent/R in target.reagents.reagent_list)
		reagents[R.id] = list(
			"volume" = R.volume,
			"uid" = R.UID(),
		)

// This interface intentionally emulates VV.
// It should, therefore, doesn't place restrictions on any actions, which includes but
// is not limited to: adding a reagent which overfills the container and adding blood
// with a non-existent blood type. It may also do things unconventionally, such as
// directly appending reagents to the list rather than using reagents.add_reagent to
// bypass reagent reactions.
/datum/reagents_editor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return

	. = TRUE

	switch(action)
		if("add_reagent")
			var/reagent_id = params["reagentID"]
			var/datum/reagent/reagent_prototype = GLOB.chemical_reagents_list[reagent_id]
			if(isnull(reagent_prototype))
				return FALSE
			var/new_volume = tgui_input_number(ui.user, "How much units of the reagent do you want to add?", "Add Reagent", 0, 1E100, -1E100)
			var/datum/reagent/reagent = target.reagents.get_reagent_by_id(reagent_id)
			if(isnull(reagent))
				reagent = new reagent_prototype.type()
				reagent.holder = target.reagents
				reagent.on_new()
				if(ishuman(target)) 
					var/mob/living/carbon/human/human = target
					if(human.can_metabolize(reagent))
						reagent.on_mob_add(human)
				target.reagents.reagent_list += reagent

			reagent.volume = new_volume
			log_and_message_admins("[ui.user] has added [new_volume]u of [reagent] to [target]!")

		if("edit_volume")
			var/reagent_uid = params["uid"]
			var/datum/reagent/reagent = locateUID(reagent_uid)
			if(isnull(reagent))
				return FALSE
			var/new_volume = tgui_input_number(ui.user, "How much units of the reagent do you want to be in the container?", "Edit Reagent Volume", 0, 1E100, -1E100)
			if(isnull(new_volume))
				return
			reagent.volume = new_volume
			log_and_message_admins("[ui.user] has edited volume of [reagent] to [new_volume]u in [target]!")

		if("delete_reagent")
			var/reagent_uid = params["uid"]
			var/datum/reagent/reagent = locateUID(reagent_uid)
			if(isnull(reagent))
				return FALSE
			target.reagents.reagent_list -= reagent
			log_and_message_admins("[ui.user] has deleted [reagent] from [target]!")

		if("update_total")
			target.reagents.update_total()

		if("react_reagents")
			target.reagents.handle_reactions()
			log_and_message_admins("[ui.user] has forced a chemical reaction in [target]!")

		else
			. = FALSE

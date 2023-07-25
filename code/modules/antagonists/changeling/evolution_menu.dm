/// The evolution menu will be shown in the compact mode, with only powers and costs being displayed.
#define COMPACT_MODE	0
/// The evolution menu will be shown in the expanded mode, with powers, costs, and ability descriptions being displayed.
#define EXPANDED_MODE	1


/datum/action/changeling/evolution_menu
	name = "-Evolution Menu-" //Dashes are so it's listed before all the other abilities.
	desc = "Choose our method of subjugation."
	button_icon_state = "changelingsting"
	power_type = CHANGELING_INNATE_POWER
	/// Which UI view will be displayed. Compact mode will show only ability names, and will leave out their descriptions and helptext.
	var/view_mode = EXPANDED_MODE
	/// A list containing the names of bought changeling abilities. For use with the UI.
	var/list/purchased_abilities = list()
	/// A list containing every purchasable changeling ability. Includes its name, description, helptext and cost.
	var/static/list/ability_list = list()


/datum/action/changeling/evolution_menu/Grant(mob/M)
	..()
	if(length(ability_list))
		return // List is already populated.

	for(var/power_path in cling.purchaseable_powers)
		var/datum/action/changeling/c_power = power_path
		ability_list += list(list(
			"name" = initial(c_power.name),
			"description" = initial(c_power.desc),
			"helptext" = initial(c_power.helptext),
			"cost" = initial(c_power.dna_cost),
			"power_path" = power_path
		))


/datum/action/changeling/evolution_menu/try_to_sting(mob/user, mob/target)
	if(!ishuman(user))	// No need to manipulate with the menu while you are not a humanoid
		to_chat(user, span_warning("We cannot do that in this form!"))
		return
	ui_interact(user)


/datum/action/changeling/evolution_menu/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "EvolutionMenu", "Evolution Menu", 480, 574, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()


/datum/action/changeling/evolution_menu/ui_data(mob/user)
	var/list/data = list(
		"can_respec" = cling.can_respec,
		"evo_points" = cling.genetic_points,
		"purchased_abilities" = purchased_abilities,
		"view_mode" = view_mode
	)
	return data


/datum/action/changeling/evolution_menu/ui_static_data(mob/user)
	var/list/data = list(
		"ability_list" = ability_list
	)
	return data


/datum/action/changeling/evolution_menu/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("readapt")
			if(!cling.try_respec())
				return FALSE

			purchased_abilities.Cut()
			return TRUE

		if("purchase")
			var/power_path = text2path(params["power_path"])
			if(!ispath(power_path) || !try_purchase_power(power_path))
				return FALSE

			purchased_abilities |= power_path
			return TRUE

		if("set_view_mode")
			var/new_view_mode = text2num(params["mode"])
			if(!(new_view_mode in list(COMPACT_MODE, EXPANDED_MODE)))
				return FALSE

			view_mode = new_view_mode
			return TRUE


/datum/action/changeling/evolution_menu/proc/try_purchase_power(power_type)
	if(!(power_type in cling.purchaseable_powers))
		return FALSE

	if(power_type in purchased_abilities)
		to_chat(owner, span_warning("We have already evolved this ability!"))
		return FALSE

	var/datum/action/changeling/power = power_type
	if(cling.absorbed_count < initial(power.req_dna))
		to_chat(owner, span_warning("We must absorb more victims before we can evolve this ability!"))
		return FALSE

	if(cling.genetic_points < initial(power.dna_cost))
		to_chat(owner, span_warning("We cannot afford to evolve this ability!"))
		return FALSE

	if(HAS_TRAIT(owner, TRAIT_FAKEDEATH)) // To avoid potential exploits by buying new powers while in stasis, which clears your verblist.
		to_chat(owner, span_warning("We lack the energy to evolve new abilities right now."))
		return FALSE

	cling.give_power(new power_type)
	return TRUE


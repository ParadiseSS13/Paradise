/// The evolution menu will be shown in the compact mode, with only powers and costs being displayed.
#define COMPACT_MODE	0
/// The evolution menu will be shown in the expanded mode, with powers, costs, and power descriptions being displayed.
#define EXPANDED_MODE	1

/datum/action/changeling/evolution_menu
	name = "Evolution Menu"
	desc = "Choose our method of subjugation."
	button_icon_state = "changelingsting"
	power_type = CHANGELING_INNATE_POWER
	/// Which UI view will be displayed. Compact mode will show only power names, and will leave out their descriptions and helptext.
	var/view_mode = EXPANDED_MODE
	/// A list containing the typepaths of bought changeling abilities. For use with the UI.
	var/list/purchased_abilities = list()
	/// A list containing lists of category and abilities, related to this category. For each ability includes its name, description, helptext and cost. For use with the UI.
	var/static/list/ability_tabs = list()

/datum/action/changeling/evolution_menu/try_to_sting(mob/user, mob/target)
	ui_interact(user)

/datum/action/changeling/evolution_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/action/changeling/evolution_menu/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EvolutionMenu", "Evolution Menu")
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
		"ability_tabs" = get_ability_tabs()
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
	PRIVATE_PROC(TRUE)

	if(!(power_type in cling.purchaseable_powers))
		return FALSE
	if(power_type in purchased_abilities)
		to_chat(owner, "<span class='warning'>We have already evolved this ability!</span>")
		return FALSE
	var/datum/action/changeling/power = power_type
	if(cling.absorbed_count < initial(power.req_dna))
		to_chat(owner, "<span class='warning'>We must absorb more victims before we can evolve this ability!</span>")
		return FALSE
	if(cling.genetic_points < initial(power.dna_cost))
		to_chat(owner, "<span class='warning'>We cannot afford to evolve this ability!</span>")
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_FAKEDEATH)) // To avoid potential exploits by buying new powers while in stasis, which clears your verblist.
		to_chat(owner, "<span class='warning'>We lack the energy to evolve new abilities right now.</span>")
		return FALSE

	cling.give_power(new power_type)
	SSblackbox.record_feedback("nested tally", "changeling_powers_purchased", 1, list("[initial(power.name)]"))
	return TRUE

/datum/action/changeling/evolution_menu/proc/get_ability_tabs()
	PRIVATE_PROC(TRUE)

	if(!length(ability_tabs))
		ability_tabs = build_ability_tabs()

	return ability_tabs

/datum/action/changeling/evolution_menu/proc/build_ability_tabs()
	PRIVATE_PROC(TRUE)

	var/list/abilities_by_category_name = get_abilities_grouped_by_category_name()
	if(!length(abilities_by_category_name))
		return list()

	var/list/sorted_ability_categories = sortTim(subtypesof(/datum/changeling_power_category), GLOBAL_PROC_REF(cmp_changeling_power_category_asc))

	var/list/sorted_ability_tabs = list()
	for(var/datum/changeling_power_category/category as anything in sorted_ability_categories)
		var/list/abilities = abilities_by_category_name[initial(category.name)]
		sorted_ability_tabs += list(list(
			"category" = initial(category.name),
			"abilities" = abilities))

	return sorted_ability_tabs

/datum/action/changeling/evolution_menu/proc/get_abilities_grouped_by_category_name()
	PRIVATE_PROC(TRUE)

	var/list/abilities_by_category_name = list()
	for(var/power_path in cling.purchaseable_powers)
		var/datum/action/changeling/changeling_ability = power_path

		if(!changeling_ability.category)
			stack_trace("Cling power [changeling_ability], [changeling_ability.type] had no assigned category!")
			continue

		var/category_name = initial(changeling_ability.category.name)
		var/list/abilities = abilities_by_category_name[category_name]
		if(!islist(abilities))
			abilities_by_category_name[category_name] = abilities = list()

		abilities += list(list(
			"name" = initial(changeling_ability.name),
			"description" = initial(changeling_ability.desc),
			"helptext" = initial(changeling_ability.helptext),
			"cost" = initial(changeling_ability.dna_cost),
			"power_path" = power_path
		))

	return abilities_by_category_name

#undef COMPACT_MODE
#undef EXPANDED_MODE

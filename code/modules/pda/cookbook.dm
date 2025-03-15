// PDA apps don't seem to support ui_static_data so we do a bunch of back and
// forth filtering the recipes by category on the BYOND side
/datum/data/pda/app/cookbook
	name = "Recipe Book"
	title = "Chef's Guide to the Galaxy"
	template = "pda_cookbook"
	// Almost positive this is never used anywhere but sure
	update = PDA_APP_NOUPDATE

	var/current_category
	var/list/recipe_list = list()
	var/search_text = ""

/datum/data/pda/app/cookbook/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui.set_autoupdate(FALSE)

/datum/data/pda/app/cookbook/update_ui(mob/user, list/data)
	data["categories"] = list()
	for(var/category in GLOB.pcwj_cookbook_lookup)
		data["categories"] += category

	data["recipes"] = recipe_list
	data["current_category"] = current_category
	data["search_text"] = search_text

	return data

/datum/data/pda/app/cookbook/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("set_category")
			current_category = params["name"]
			search_text = params["search_text"]
			recipe_list = isnull(current_category) ? list() : GLOB.pcwj_cookbook_lookup[current_category]
			SStgui.update_uis(pda)


/datum/data/pda/app/cookbook
	name = "Recipe Book"
	title = "Chef's Guide to the Galaxy"
	template = "pda_cookbook"
	update = PDA_APP_NOUPDATE

	var/current_category

/datum/data/pda/app/cookbook/update_ui(mob/user, list/data)
	data["categories"] = list()
	for(var/category in GLOB.pcwj_cookbook_lookup)
		data["categories"] += category

	data["recipes"] = isnull(current_category) ? list() : GLOB.pcwj_cookbook_lookup[current_category]
	data["current_category"] = current_category

	return data

/datum/data/pda/app/cookbook/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("set_category")
			current_category = params["name"]


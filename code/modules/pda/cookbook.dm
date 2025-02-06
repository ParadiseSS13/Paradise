/datum/data/pda/app/cookbook
	name = "Recipe Book"
	title = "Chef's Guide to the Galaxy"
	template = "pda_cookbook"
	update = PDA_APP_NOUPDATE

/datum/data/pda/app/cookbook/update_ui(mob/user, list/data)
	data["recipes"] = GLOB.pcwj_cookbook_lookup
	return data

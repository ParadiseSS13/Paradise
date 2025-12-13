/datum/nuclear_rod_design
	var/type_path
	var/category = "Unknown"
	var/list/metadata

/datum/nuclear_rod_design/proc/build_metadata_list(path)
	metadata = list()
	type_path = path

	var/obj/item/nuclear_rod/T = path

	metadata["name"] = initial(T.name)
	metadata["desc"] = initial(T.desc)
	metadata["icon"] = initial(T.icon)
	metadata["icon_state"] = initial(T.icon_state)
	metadata["type_path"] = path

	metadata["max_durability"] = initial(T.max_durability)
	metadata["degredation_speed"] = initial(T.degredation_speed)
	metadata["heat_amount"] = initial(T.heat_amount)
	metadata["heat_amp_mod"] = initial(T.heat_amp_mod)
	metadata["power_amount"] = initial(T.power_amount)
	metadata["power_amp_mod"] = initial(T.power_amp_mod)
	metadata["alpha_rad"] = initial(T.alpha_rad)
	metadata["beta_rad"] = initial(T.beta_rad)
	metadata["gamma_rad"] = initial(T.gamma_rad)
	metadata["minimum_temp_modifier"] = initial(T.minimum_temp_modifier)

	metadata["required_object"] = initial(T.required_object)

	// Temp object lets us read in materials because you can't initial() a list
	var/obj/item/nuclear_rod/temp_rod = new path()
	var/list/raw_materials = temp_rod.materials
	qdel(temp_rod)

	if(raw_materials && length(raw_materials))
		var/list/formatted_materials = list()
		for(var/mat_id in raw_materials)
			var/display_name = CallMaterialName(mat_id)
			formatted_materials[display_name] = raw_materials[mat_id]
		metadata["materials"] = formatted_materials
	else
		metadata["materials"] = list()

	if(ispath(path, /obj/item/nuclear_rod/fuel))
		var/obj/item/nuclear_rod/fuel/F = path
		metadata["craftable"] = initial(F.craftable)
		metadata["enrichment_cycles"] = initial(F.enrichment_cycles)
		metadata["power_enrich_threshold"] = initial(F.power_enrich_threshold)
		metadata["heat_enrich_threshold"] = initial(F.heat_enrich_threshold)

		if(initial(F.power_enrich_result))
			var/obj/item/nuclear_rod/power_result = initial(F.power_enrich_result)
			metadata["power_enrich_result_name"] = initial(power_result.name)
		if(initial(F.heat_enrich_result))
			var/obj/item/nuclear_rod/heat_result = initial(F.heat_enrich_result)
			metadata["heat_enrich_result_name"] = initial(heat_result.name)
	else if(ispath(path, /obj/item/nuclear_rod/moderator))
		var/obj/item/nuclear_rod/moderator/M = path
		metadata["craftable"] = initial(M.craftable)
	else if(ispath(path, /obj/item/nuclear_rod/coolant))
		var/obj/item/nuclear_rod/coolant/C = path
		metadata["craftable"] = initial(C.craftable)
	else
		metadata["craftable"] = FALSE

	var/list/requirements = initial(T.adjacent_requirements)
	if(requirements && length(requirements))
		var/list/temp_reqs = list()
		for(var/req_path in requirements)
			var/obj/item/nuclear_rod/req = req_path
			temp_reqs += initial(req.name)
		metadata["adjacent_requirements_display"] = english_list(temp_reqs, and_text = ", ")
	else
		metadata["adjacent_requirements_display"] = "None"

	return TRUE

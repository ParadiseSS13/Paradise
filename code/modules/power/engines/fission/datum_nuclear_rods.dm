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
	metadata["degradation_speed"] = initial(T.degradation_speed)
	metadata["heat_amount"] = initial(T.heat_amount)
	metadata["heat_amp_mod"] = initial(T.heat_amp_mod)
	metadata["power_amount"] = initial(T.power_amount)
	metadata["power_amp_mod"] = initial(T.power_amp_mod)
	metadata["alpha_rad"] = initial(T.alpha_rad)
	metadata["beta_rad"] = initial(T.beta_rad)
	metadata["gamma_rad"] = initial(T.gamma_rad)
	metadata["minimum_temp_modifier"] = initial(T.minimum_temp_modifier)
	metadata["upgrade_required"] = initial(T.upgrade_required)

	metadata["required_object"] = initial(T.required_object)

	// Temp object lets us read in materials and adjacent requirements because you can't initial() a list
	var/obj/item/nuclear_rod/temp_rod = new path()
	var/list/raw_materials = temp_rod.materials
	var/list/requirements = temp_rod.adjacent_requirements
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

		// Get enrichment result names
		if(initial(F.power_enrich_result))
			var/obj/item/nuclear_rod/power_result = initial(F.power_enrich_result)
			metadata["power_enrichment"] = initial(power_result.name)
			metadata["power_enrichment_requirement"] = initial(F.power_enrich_threshold)
		else
			metadata["power_enrichment"] = null
			metadata["power_enrichment_requirement"] = null

		if(initial(F.heat_enrich_result))
			var/obj/item/nuclear_rod/heat_result = initial(F.heat_enrich_result)
			metadata["heat_enrichment"] = initial(heat_result.name)
			metadata["heat_enrichment_requirement"] = initial(F.heat_enrich_threshold)
		else
			metadata["heat_enrichment"] = null
			metadata["heat_enrichment_requirement"] = null
	else if(ispath(path, /obj/item/nuclear_rod/moderator))
		var/obj/item/nuclear_rod/moderator/M = path
		metadata["craftable"] = initial(M.craftable)
	else if(ispath(path, /obj/item/nuclear_rod/coolant))
		var/obj/item/nuclear_rod/coolant/C = path
		metadata["craftable"] = initial(C.craftable)
	else
		metadata["craftable"] = FALSE

	if(requirements && length(requirements))
		var/list/temp_reqs = list()
		var/list/req_counts = list()

		// Count occurrences of each requirement type
		for(var/req_path in requirements)
			var/obj/item/nuclear_rod/req = req_path
			var/req_name = initial(req.name)
			if(req_counts[req_name])
				req_counts[req_name]++
			else
				req_counts[req_name] = 1

		// Format the requirements with counts
		for(var/req_name in req_counts)
			var/count = req_counts[req_name]
			temp_reqs += "[count]x [req_name]"

		metadata["neighbor_requirements"] = temp_reqs
		metadata["adjacent_requirements_display"] = english_list(temp_reqs, and_text = ", ")
	else
		metadata["neighbor_requirements"] = list()
		metadata["adjacent_requirements_display"] = "None"

	return TRUE

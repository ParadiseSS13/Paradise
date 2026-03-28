/datum/objective/uplifted
	needs_target = FALSE

/datum/objective/uplifted/propagate
	explanation_text = "Propagate your kind across the station by filling your nest with food and scrap."
	completed = TRUE

/datum/objective/uplifted/collect_items
	explanation_text = "Decorate your nest with whatever interesting items you find around the station."
	completed = TRUE

/datum/objective/uplifted/collect_animals
	explanation_text = "Find creatures who do not have the gift of sentience and keep them safe near your nest."
	completed = TRUE

/datum/objective/uplifted/barter
	explanation_text = "Trade whatever you can find or steal with anyone willing to give you appropriate payment."
	completed = TRUE

/datum/objective/uplifted/fortify
	explanation_text = "Fortify your nest against potential attackers and arm your fellow primitives."
	completed = TRUE

/datum/objective/uplifted/build_nest_in_area
	/// The area in which the nest must be built to complete the objective.
	var/area/target_area

/datum/objective/uplifted/build_nest_in_area/New()
	..()
	target_area = select_target_location()
	update_explanation_text()

/datum/objective/uplifted/build_nest_in_area/update_explanation_text()
	explanation_text = "Build and defend a collective nest in [target_area.name]."

/datum/objective/uplifted/build_nest_in_area/proc/select_target_location()
	var/list/potential_areas = list()
	for(var/area/station/A in SSmapping.existing_station_areas)
		// using the cult summon validity as a heuristic here should be fine,
		// since the goal here is similar
		if(!A.valid_territory)
			continue

		potential_areas += A
	return pick(potential_areas)

/datum/objective/uplifted/build_nest_in_area/check_completion()
	if(completed)
		return TRUE
	for(var/datum/mind/M in get_owners())
		var/datum/antagonist/uplifted_primitive/U = M.has_antag_datum(/datum/antagonist/uplifted_primitive)
		var/obj/nest = locateUID(U.nest_uid)
		if(!QDELETED(nest) && get_area(nest) == target_area)
			return TRUE
	return FALSE

/datum/objective/uplifted/obtain
	/// The typepath of the item which must be possessed to complete the objective.
	var/obj/item/target_type

	/// The possible typepaths that can be selected as a target.
	var/list/allowed_targets = list(
		/obj/item/clothing/head/helmet,
		/obj/item/melee/baton/cattleprod,
		/obj/item/fireaxe,
		/obj/item/gun/energy/laser/practice,
		/obj/item/clothing/gloves/color/yellow,
		/obj/item/camera,
		/obj/item/aicard,
		/obj/item/pda,
		/obj/item/megaphone,
	)

/datum/objective/uplifted/obtain/New()
	..()
	target_type = pick(allowed_targets)
	update_explanation_text()

/datum/objective/uplifted/obtain/update_explanation_text()
	explanation_text = "Obtain [target_type::name] through barter, theft, craftiness, or any other means."

/datum/objective/uplifted/obtain/check_completion()
	if(completed)
		return TRUE
	for(var/datum/mind/M in get_owners())
		if(locate(target_type) in M.current.contents)
			return TRUE

		var/datum/antagonist/uplifted_primitive/U = M.has_antag_datum(/datum/antagonist/uplifted_primitive)
		var/obj/nest = locateUID(U.nest_uid)
		if(!QDELETED(nest) && locate(target_type) in get_turf(nest))
			return TRUE
	return FALSE

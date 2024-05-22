/datum/station_goal/secondary/virology
	name = "Generic Virology Goal"
	department = "Virology"

/datum/secondary_goal_progress/virology
	/// The amount of units currently already delivered  
	var/delivered_amount = 0  
	/// The amount of units of the required virus that must be delivered for the completion of this goal  
	/// If you change this, update the report messages.
	var/delivery_goal = 15

/datum/secondary_goal_progress/virology/proc/check_virus(datum/disease/advance/D, datum/economy/cargo_shuttle_manifest/manifest, complain)
	return TRUE

/datum/secondary_goal_progress/virology/update(obj/item/reagent_containers/C, datum/economy/cargo_shuttle_manifest/manifest = null, complain = FALSE)
	// Not in a matching personal crate? Ignore.
	if(!check_personal_crate(C))
		return

	// Not a reagent container? Ignore.
	if(!istype(C))
		return
	if(!length(C.reagents?.reagent_list))
		return

	// No blood with viruses? Ignore.
	var/datum/reagent/blood/BL = locate() in C.reagents.reagent_list
	if(!length(BL?.data?["viruses"]))
		return

	for(var/datum/disease/advance/D in BL.data["viruses"])
		if(!check_virus(D, BL.volume, manifest, complain))
			continue
		delivered_amount += BL.volume
		return COMSIG_CARGO_SELL_PRIORITY
	return COMSIG_CARGO_SELL_WRONG

/datum/secondary_goal_progress/virology/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	return delivered_amount >= delivery_goal

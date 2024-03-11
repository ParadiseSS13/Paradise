/datum/supply_packs
	var/name
	v	/// OBJ: What is inside the crate
	var/list/contains = list()
	/// STRING: What is inside the crate
	var/list/contains_special = list()
	var/manifest = ""
	var/amount
	var/cost //default amount to cover crate cost?
	var/containertype = /obj/structure/closet/crate
	var/containername
	var/access
	var/hidden = FALSE
	var/contraband = FALSE
	var/group = SUPPLY_MISC
	///Determines which departments do not need QM approval to order this supply pack
	var/list/department_restrictions = list()

	var/list/announce_beacons = list() // Particular beacons that we'll notify the relevant department when we reach

	var/special = FALSE //Event/Station Goals/Admin enabled packs
	var/special_enabled = FALSE

	/// List of names for being done in TGUI
	var/list/ui_manifest = list()

/datum/supply_packs/New()
	. = ..()
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)
			continue
		var/atom/movable/AM = path
		manifest += "<li>[initial(AM.name)]</li>"
		//Add the name to the UI manifest
		ui_manifest += "[initial(AM.name)]"
	for(var/item in contains_special)
		manifest += "<li>[item]</li>"
		ui_manifest += "[item]"
	manifest += "</ul>"

/datum/supply_packs/proc/create_package(turf/spawn_location)
	var/obj/structure/closet/crate/crate = new containertype(spawn_location)

	crate.name = containername
	if(access)
		crate.req_access = list(text2num(access))

	//we now create the actual contents
	for(var/typepath in generate_items())
		if(!typepath)
			continue
		var/atom/A = new typepath(crate)
		if(isstack(A) && amount)
			var/obj/item/stack/mats = A
			mats.amount = amount

	return crate

/datum/supply_packs/proc/generate_items()
	return contains

/datum/supply_packs/misc/randomised/generate_items()
	. = list()
	if(length(contains))
		for(var/j in 1 to num_contained)
			. += pick(contains)

/datum/supply_packs/proc/get_cost()
	return cost * SSeconomy.pack_price_modifier

/datum/supply_packs/proc/get_special_manifest(content_list)
	for(var/item in contains_special)
		content_list += item
	return content_list

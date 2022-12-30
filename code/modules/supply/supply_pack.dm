/datum/supply_packs
	var/name
	var/list/contains = list()
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
	manifest += "</ul>"

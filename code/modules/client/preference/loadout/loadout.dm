GLOBAL_LIST_EMPTY(loadout_categories)
GLOBAL_LIST_EMPTY(gear_datums)

/datum/loadout_category
	var/category = ""
	var/list/gear = list()

/datum/loadout_category/New(cat)
	category = cat
	..()

/datum/gear
	/// Displayed name of the item listing.
	var/display_name
	/// Description of the item listing. If left blank will default to the description of the pathed item.
	var/description
	/// Typepath of the item.
	var/path
	/// Loadout points cost to select the item listing.
	var/cost = 1
	/// Slot to equip the item to.
	var/slot
	/// List of job roles which can spawn with the item.
	var/list/allowed_roles
	/// Loadout category of the item listing.
	var/sort_category = "General"
	/// List of datums which will alter the item after it has been spawned. (NYI)
	var/list/gear_tweaks = list()
	/// Set on empty category datums to skip them being added to the list. (/datum/gear/accessory, /datum/gear/suit/coat/job, etc.)
	var/main_typepath = /datum/gear
	/// Does selecting a second item with the same `main_typepath` cost loadout points.
	var/subtype_selection_cost = TRUE
	/// Patreon donator tier needed to select this item listing.
	var/donator_tier = 0

/datum/gear/New()
	..()
	if(!description)
		var/obj/O = path
		description = initial(O.desc)

/datum/gear_data
	var/path
	var/location

/datum/gear_data/New(npath, nlocation)
	path = npath
	location = nlocation

/datum/gear/proc/spawn_item(location, metadata)
	var/datum/gear_data/gd = new(path, location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_gear_data(metadata["[gt]"], gd)
	var/item = new gd.path(gd.location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_item(item, metadata["[gt]"])
	return item

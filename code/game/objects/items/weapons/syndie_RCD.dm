/obj/item/rcd/syndicate
	name = "Syndicate rapid-construction-device (RCD)"
	desc = "A device used to rapidly build and deconstruct walls, floors and airlocks. This one is made by syndicate"
	icon = 'icons/obj/tools.dmi'
	icon_state = "syndi_rcd"
	item_state = "syndi_rcd"
	materials = list(MAT_PLASMA = 10000, MAT_TITANIUM = 10000, MAT_METAL = 20000)
	origin_tech = "engineering=4;materials=2;syndicate=4"
	req_access = list(ACCESS_SYNDICATE)
	usesound = 'sound/items/deconstruct.ogg'
	/// The max amount of matter that can be stored.
	max_matter = RCD_MATTER_100
	/// If the RCD can deconstruct reinforced walls.
	canRwall = TRUE
	/// Is the RCD's airlock access selection menu locked?
	locked = TRUE
	/// The current airlock type that will be build.
	door_type = /obj/machinery/door/airlock/syndicate/public
	/// An associative list of airlock type paths as keys, and their names as values.
	var/static/list/syndie_rcd_door_types = list()
	/// An associative list containing an airlock's name, type path, and image. For use with the UI.
	var/static/list/syndie_door_types_ui_list = list()
	/// An associative list containing all station accesses. Includes their name and access number. For use with the UI.
	var/static/list/syndie_door_accesses_list = list()

	region_min = REGION_TAIPAN
	region_max = REGION_TAIPAN

	fulltile_window = TRUE
	window_type = /obj/structure/window/plastitanium
	floor_type = /turf/simulated/floor/plating
	wall_type = /turf/simulated/wall/mineral/plastitanium
	matter_type = /obj/item/rcd_ammo/syndicate
	matter_type_large = /obj/item/rcd_ammo/syndicate/large

/obj/item/rcd/syndicate/Initialize()
	. = ..()
	if(!length(syndie_rcd_door_types))
		syndie_rcd_door_types = list(
			/obj/machinery/door/airlock/syndicate/public = "Standard",
			/obj/machinery/door/airlock/syndicate/public/glass = "Standard (Glass)",
			/obj/machinery/door/airlock/syndicate/command = "Command",
			/obj/machinery/door/airlock/syndicate/command/glass = "Command (Glass)",
			/obj/machinery/door/airlock/syndicate/security = "Security",
			/obj/machinery/door/airlock/syndicate/security/glass = "Security (Glass)",
			/obj/machinery/door/airlock/syndicate/atmos = "Atmospherics",
			/obj/machinery/door/airlock/syndicate/atmos/glass = "Atmospherics (Glass)",
			/obj/machinery/door/airlock/syndicate/maintenance = "Maintenance",
			/obj/machinery/door/airlock/syndicate/maintenance/glass = "Maintenance (Glass)",
			/obj/machinery/door/airlock/syndicate/medical = "Medical",
			/obj/machinery/door/airlock/syndicate/medical/glass = "Medical (Glass)",
			/obj/machinery/door/airlock/syndicate/cargo = "Cargo",
			/obj/machinery/door/airlock/syndicate/cargo/glass = "Cargo (Glass)",
			/obj/machinery/door/airlock/syndicate/research = "Research",
			/obj/machinery/door/airlock/syndicate/research/glass = "Research (Glass)",
			/obj/machinery/door/airlock/syndicate/engineering = "Engineering",
			/obj/machinery/door/airlock/syndicate/engineering/glass = "Engineering (Glass)",
			/obj/machinery/door/airlock/syndicate/extmai = "External Maint.",
			/obj/machinery/door/airlock/syndicate/extmai/glass = "External Maint. (Glass)",
			/obj/machinery/door/airlock/syndicate/freezer = "Freezer",
			/obj/machinery/door/airlock/syndicate/freezer/glass = "Freezer (Glass)",
			/obj/machinery/door/airlock/hatch = "Airtight Hatch",
			/obj/machinery/door/airlock/maintenance_hatch = "Maintenance Hatch"
		)
	if(!length(syndie_door_types_ui_list))
		for(var/type in syndie_rcd_door_types)
			syndie_door_types_ui_list += list(list(
				"name" = syndie_rcd_door_types[type],
				"type" = type,
				"image" = get_airlock_image(type)
			))
	if(!length(syndie_door_accesses_list))
		for(var/access in get_taipan_syndicate_access())
			syndie_door_accesses_list += list(list(
				"name" = get_syndicate_access_desc(access),
				"id" = access
			))

	current_rcd_door_types = syndie_rcd_door_types
	current_door_types_ui_list = syndie_door_types_ui_list
	current_door_accesses_list = syndie_door_accesses_list

/**
 * Creates and displays a radial menu to a user when they trigger the `attack_self` of the RCD.
 *
 * Arguments:
 * * user - the mob trying to open the RCD radial.
 */
/obj/item/rcd/syndicate/radial_menu(mob/user)
	if(!check_menu(user))
		return
	var/list/choices = list(
		RCD_MODE_AIRLOCK = image(icon = 'icons/obj/interface.dmi', icon_state = "syndie_airlock"),
		RCD_MODE_DECON = image(icon = 'icons/obj/interface.dmi', icon_state = "syndie_delete"),
		RCD_MODE_WINDOW = image(icon = 'icons/obj/interface.dmi', icon_state = "syndie_grillewindow"),
		RCD_MODE_TURF = image(icon = 'icons/obj/interface.dmi', icon_state = "wallfloor"),
		"UI" = image(icon = 'icons/obj/interface.dmi', icon_state = "ui_interact")
	)
	if(mode == RCD_MODE_AIRLOCK)
		choices += list(
			"Change Access" = image(icon = 'icons/obj/interface.dmi', icon_state = "syndie_access"),
			"Change Airlock Type" = image(icon = 'icons/obj/interface.dmi', icon_state = "syndie_airlocktype")
		)
	choices -= mode // Get rid of the current mode, clicking it won't do anything.
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, .proc/check_menu, user))
	if(!check_menu(user))
		return
	switch(choice)
		if(RCD_MODE_AIRLOCK, RCD_MODE_DECON, RCD_MODE_WINDOW, RCD_MODE_TURF)
			mode = choice
		if("UI")
			ui_interact(user)
			return
		if("Change Access")
			ui_tab = RCD_TAB_AIRLOCK_ACCESS
			ui_interact(user)
			return
		if("Change Airlock Type")
			ui_tab = RCD_TAB_AIRLOCK_TYPE
			ui_interact(user)
			return
		else
			return
	playsound(src, 'sound/effects/pop.ogg', 50, 0)
	to_chat(user, "<span class='notice'>You change [src]'s mode to '[choice]'.</span>")

/obj/item/rcd/syndicate/combat
	name = "Syndicate combat rapid-construction-device (RCD)"
	max_matter = RCD_MATTER_500

/obj/item/rcd/syndicate/borg
	borg_rcd = TRUE
	power_use_multiplier = 80

/obj/item/rcd_ammo/syndicate
	name = "suspicious matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "syndie_rcd"
	item_state = "syndie_rcdammo"
	origin_tech = "materials=3,syndicate=2"
	materials = list(MAT_METAL = 8000, MAT_GLASS = 4000, MAT_TITANIUM = 4000, MAT_PLASMA = 4000)

/obj/item/rcd_ammo/syndicate/large
	ammoamt = 100
	materials = list(MAT_METAL = 40000, MAT_GLASS = 20000, MAT_TITANIUM = 20000, MAT_PLASMA = 20000)

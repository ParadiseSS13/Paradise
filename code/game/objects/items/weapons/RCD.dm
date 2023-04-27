/obj/item/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build and deconstruct walls, floors and airlocks."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	flags = CONDUCT | NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 30000)
	origin_tech = "engineering=4;materials=2"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'
	flags_2 = NO_MAT_REDEMPTION_2
	req_access = list(ACCESS_ENGINE)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF

	//RCD for the borgs or not?
	// If this is a borg RCD we use power instead of matter
	var/borg_rcd = FALSE
	// A multipler which is applied to matter amount checks by borg RCDs. A higher number means more power usage per RCD usage.
	var/power_use_multiplier = 160

	/// The spark system used to create sparks when the user interacts with the RCD.
	var/datum/effect_system/spark_spread/spark_system
	/// The current amount of matter stored.
	var/matter = NONE
	/// The max amount of matter that can be stored.
	var/max_matter = RCD_MATTER_100
	/// The RCD's current build mode.
	var/mode = RCD_MODE_TURF
	/// If the RCD can deconstruct reinforced walls.
	var/canRwall = FALSE
	/// Is the RCD's airlock access selection menu locked?
	var/locked = TRUE
	/// The current airlock type that will be build.
	var/door_type = /obj/machinery/door/airlock
	/// The name that newly build airlocks will receive.
	var/door_name = "Airlock"
	/// If this is TRUE, any airlocks that gets built will require only ONE of the checked accesses. If FALSE, it will require ALL of them.
	var/one_access = TRUE
	/// Which airlock tab the UI is currently set to display.
	var/ui_tab = RCD_TAB_AIRLOCK_TYPE
	/// A list of access numbers which have been checked off by the user in the UI.
	var/list/selected_accesses = list()
	/// List of areas where we can't deconstruct stuff
	var/static/list/areas_blacklist = list(/area/lavaland/surface/outdoors/necropolis, /area/mine/necropolis)
	/// An associative list of airlock type paths as keys, and their names as values.
	var/static/list/rcd_door_types = list()

	var/list/current_rcd_door_types = list()
	/// An associative list containing an airlock's name, type path, and image. For use with the UI.
	var/static/list/door_types_ui_list = list()

	var/list/current_door_types_ui_list = list()
	/// An associative list containing all station accesses. Includes their name and access number. For use with the UI.
	var/static/list/door_accesses_list = list()

	var/list/current_door_accesses_list = list()

	var/region_min = REGION_GENERAL
	var/region_max = REGION_COMMAND

	var/fulltile_window = FALSE // Do we place fulltile windows?
	var/window_type = /obj/structure/window/reinforced
	var/floor_type = /turf/simulated/floor/plating
	var/wall_type = /turf/simulated/wall
	var/firelock_type = /obj/machinery/door/firedoor
	var/matter_type = /obj/item/rcd_ammo
	var/matter_type_large = /obj/item/rcd_ammo/large

/obj/item/rcd/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	GLOB.rcd_list += src

	if(!length(rcd_door_types))
		rcd_door_types = list(
			/obj/machinery/door/airlock = "Standard",
			/obj/machinery/door/airlock/glass = "Standard (Glass)",
			/obj/machinery/door/airlock/command = "Command",
			/obj/machinery/door/airlock/command/glass = "Command (Glass)",
			/obj/machinery/door/airlock/security = "Security",
			/obj/machinery/door/airlock/security/glass = "Security (Glass)",
			/obj/machinery/door/airlock/engineering = "Engineering",
			/obj/machinery/door/airlock/engineering/glass = "Engineering (Glass)",
			/obj/machinery/door/airlock/atmos = "Atmospherics",
			/obj/machinery/door/airlock/atmos/glass = "Atmospherics (Glass)",
			/obj/machinery/door/airlock/mining = "Mining",
			/obj/machinery/door/airlock/mining/glass = "Mining (Glass)",
			/obj/machinery/door/airlock/medical = "Medical",
			/obj/machinery/door/airlock/medical/glass = "Medical (Glass)",
			/obj/machinery/door/airlock/research = "Research",
			/obj/machinery/door/airlock/research/glass = "Research (Glass)",
			/obj/machinery/door/airlock/science = "Science",
			/obj/machinery/door/airlock/science/glass = "Science (Glass)",
			/obj/machinery/door/airlock/maintenance = "Maintenance",
			/obj/machinery/door/airlock/maintenance/glass = "Maintenance (Glass)",
			/obj/machinery/door/airlock/maintenance/external = "External Maintenance",
			/obj/machinery/door/airlock/maintenance/external/glass = "External Maint. (Glass)",
			/obj/machinery/door/airlock/external = "External",
			/obj/machinery/door/airlock/external/glass = "External (Glass)",
			/obj/machinery/door/airlock/hatch = "Airtight Hatch",
			/obj/machinery/door/airlock/maintenance_hatch = "Maintenance Hatch",
			/obj/machinery/door/airlock/freezer = "Freezer"
		)
	if(!length(door_types_ui_list))
		for(var/type in rcd_door_types)
			door_types_ui_list += list(list(
				"name" = rcd_door_types[type],
				"type" = type,
				"image" = get_airlock_image(type)
			))
	if(!length(door_accesses_list))
		for(var/access in get_all_accesses())
			door_accesses_list += list(list(
				"name" = get_access_desc(access),
				"id" = access
			))

	current_rcd_door_types = rcd_door_types
	current_door_types_ui_list = door_types_ui_list
	current_door_accesses_list = door_accesses_list

/obj/item/rcd/examine(mob/user)
	. = ..()
	. += "<span class='notice'>MATTER: [matter]/[max_matter] matter-units.</span>"
	. += "<span class='notice'>MODE: [mode].</span>"

/obj/item/rcd/Destroy()
	QDEL_NULL(spark_system)
	GLOB.rcd_list -= src
	return ..()

/**
 * Creates and returns a base64 icon of the given `airlock_type`.
 *
 * This is used for airlock icon previews in the UI.
 *
 * Arugments:
 * * airlock_type - an airlock typepath.
 */
/obj/item/rcd/proc/get_airlock_image(airlock_type)
	var/obj/machinery/door/airlock/proto = new airlock_type(null)
	proto.icon_state = "closed"
	if(!proto.glass)
		proto.add_overlay("fill_closed")
	var/icon/I = getFlatIcon(proto, no_anim = TRUE)
	qdel(proto)
	return "[icon2base64(I)]"

/**
 * Runs a series of pre-checks before opening the radial menu to the user.
 *
 * Arguments:
 * * user - the mob trying to open the radial menu.
 */
/obj/item/rcd/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/rcd/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/rcd_ammo))
		return ..()
	rcd_reload(W, user)

/obj/item/rcd/proc/rcd_reload(obj/item/rcd_ammo/rcd_ammo, mob/user)
	if(matter >= max_matter)
		to_chat(user, "<span class='notice'>The RCD can't hold any more matter-units.</span>")
		return

	if(!user.unEquip(rcd_ammo))
		to_chat(user, "<span class='warning'>[rcd_ammo] is stuck to your hand!</span>")
		return

	user.put_in_active_hand(rcd_ammo)
	if(rcd_ammo.type == matter_type || rcd_ammo.type == matter_type_large)
		matter = min(matter + rcd_ammo.ammoamt, max_matter)
		qdel(rcd_ammo)
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>")
	else
		to_chat(user, "<span class='warning'>This matter cartridge is incompatible with your RCD</span>")
	SStgui.update_uis(src)

/**
 * Creates and displays a radial menu to a user when they trigger the `attack_self` of the RCD.
 *
 * Arguments:
 * * user - the mob trying to open the RCD radial.
 */
/obj/item/rcd/proc/radial_menu(mob/user)
	if(!check_menu(user))
		return
	var/list/choices = list(
		RCD_MODE_AIRLOCK = image(icon = 'icons/obj/interface.dmi', icon_state = "airlock"),
		RCD_MODE_DECON = image(icon = 'icons/obj/interface.dmi', icon_state = "delete"),
		RCD_MODE_WINDOW = image(icon = 'icons/obj/interface.dmi', icon_state = "grillewindow"),
		RCD_MODE_TURF = image(icon = 'icons/obj/interface.dmi', icon_state = "wallfloor"),
		RCD_MODE_FIRELOCK = image(icon = 'icons/obj/interface.dmi', icon_state = "firelock"),
		"UI" = image(icon = 'icons/obj/interface.dmi', icon_state = "ui_interact")
	)
	if(mode == RCD_MODE_AIRLOCK)
		choices += list(
			"Change Access" = image(icon = 'icons/obj/interface.dmi', icon_state = "access"),
			"Change Airlock Type" = image(icon = 'icons/obj/interface.dmi', icon_state = "airlocktype")
		)
	choices -= mode // Get rid of the current mode, clicking it won't do anything.
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, .proc/check_menu, user))
	if(!check_menu(user))
		return
	switch(choice)
		if(RCD_MODE_AIRLOCK, RCD_MODE_DECON, RCD_MODE_WINDOW, RCD_MODE_TURF, RCD_MODE_FIRELOCK)
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


/obj/item/rcd/attack_self(mob/user)
	//Change the mode // Oh I thought the UI was just for fucking staring at
	radial_menu(user)

/obj/item/rcd/attack_self_tk(mob/user)
	radial_menu(user)

/obj/item/rcd/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RCD", "Rapid Construction Device", 471, 673, master_ui, state)
		ui.open()

/obj/item/rcd/ui_data(mob/user)
	var/list/data = list(
		"tab" = ui_tab,
		"mode" = mode,
		"locked" = locked,
		"matter" = matter,
		"door_type" = door_type,
		"door_name" = door_name,
		"one_access" = one_access,
		"selected_accesses" = selected_accesses,
		"modal" = ui_modal_data(src)
	)
	return data

/obj/item/rcd/ui_static_data(mob/user)
	var/list/data = list(
		"max_matter" = max_matter,
		"regions" = get_accesslist_static_data(region_min, region_max),
		"door_accesses_list" = current_door_accesses_list,
		"door_types_ui_list" = current_door_types_ui_list
	)
	return data

/obj/item/rcd/ui_act(action, list/params)
	if(..())
		return

	if(prob(20))
		spark_system.start()

	if(ui_act_modal(action, params))
		return TRUE

	. = TRUE
	switch(action)
		if("set_tab")
			var/tab = text2num(params["tab"])
			if(!(tab in list(RCD_TAB_AIRLOCK_TYPE, RCD_TAB_AIRLOCK_ACCESS)))
				return FALSE
			ui_tab = tab

		if("mode")
			var/new_mode = params["mode"]
			if(!(new_mode in list(RCD_MODE_TURF, RCD_MODE_AIRLOCK, RCD_MODE_DECON, RCD_MODE_WINDOW, RCD_MODE_FIRELOCK)))
				return FALSE
			mode = new_mode

		if("door_type")
			var/new_door_type = text2path(params["door_type"])
			if(!(new_door_type in current_rcd_door_types))
				message_admins("<span class='warning'>RCD Door HREF exploit</span> attempted by [ADMIN_FULLMONTY(usr)]!")
				return FALSE
			door_type = new_door_type

		if("set_lock")
			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				return FALSE
			locked = params["new_lock"] == "lock" ? TRUE : FALSE

		if("set_one_access")
			one_access = params["access"] == "one" ? TRUE : FALSE

		if("set")
			var/access = text2num(params["access"])
			if(isnull(access))
				return
			if(access in selected_accesses)
				selected_accesses -= access
			else
				selected_accesses |= access

		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < region_min || region > region_max)
				return
			selected_accesses |= get_region_accesses(region)

		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < region_min || region > region_max)
				return
			selected_accesses -= get_region_accesses(region)

		if("clear_all")
			selected_accesses = list()

		if("grant_all")
			selected_accesses = get_all_accesses()

/**
  * Called in ui_act() to process modal actions
  *
  * Arguments:
  * * action - The action passed by tgui
  * * params - The params passed by tgui
  */
/obj/item/rcd/proc/ui_act_modal(action, list/params)
	. = TRUE
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			ui_modal_input(src, "renameAirlock", "Enter a new name:", value = door_name, max_length = UI_MODAL_INPUT_MAX_LENGTH_NAME)
		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			if(!answer)
				return
			door_name = sanitize(copytext(answer, 1, UI_MODAL_INPUT_MAX_LENGTH_NAME))
		else
			return FALSE


/obj/item/rcd/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/rcd_ammo))
		rcd_reload(target, user)
		return
	var/area/check_area = get_area(target)
	if(check_area?.type in areas_blacklist)
		to_chat(user, span_warning("Something prevents you from using [src] in here..."))
		return
	target.rcd_act(user, src, mode)
	SStgui.update_uis(src)

/**
 * Called in each of the four build modes after an object is successfully built.
 *
 * Subtracts the amount of matter used from `matter`.
 *
 * Arguments:
 * * amount - the amount of matter that was used.
 */
/obj/item/rcd/proc/useResource(amount, mob/user)
	if(!borg_rcd)
		if(matter < amount)
			return FALSE
		matter -= amount
		SStgui.update_uis(src)
		return TRUE

	if(!isrobot(user))
		return FALSE

	var/mob/living/silicon/robot/R = user
	return R.cell.use(amount * power_use_multiplier)

/**
 * Called in each of the four build modes before an object gets build. Makes sure there is enough matter to build the object.
 *
 * Arguments:
 * * amount - an amount of matter to check for
 */
/obj/item/rcd/proc/checkResource(amount, mob/user)
	if(!borg_rcd)
		return matter >= amount

	if(!isrobot(user))
		return FALSE

	var/mob/living/silicon/robot/R = user
	return R.cell.charge >= (amount * power_use_multiplier)

/obj/item/rcd/borg
	canRwall = TRUE
	borg_rcd = TRUE

/obj/item/rcd/borg/syndicate
	power_use_multiplier = 80

/**
 * Called from malf AI's "detonate RCD" ability.
 *
 * Creates a delayed explosion centered around the RCD.
 */
/obj/item/rcd/proc/detonate_pulse()
	if(is_taipan(z) || is_admin_level(z)) //Защищает тайпан и админские Z-lvla от взрыва RCD
		return
	audible_message("<span class='danger'><b>[src] begins to vibrate and buzz loudly!</b></span>", "<span class='danger'><b>[src] begins vibrating violently!</b></span>")
	// 5 seconds to get rid of it
	addtimer(CALLBACK(src, .proc/detonate_pulse_explode), 50)

/**
 * Called in `/obj/item/rcd/proc/detonate_pulse()` via callback.
 */
/obj/item/rcd/proc/detonate_pulse_explode()
	explosion(src, 0, 0, 3, 1, flame_range = 1, cause = "AI detonate RCD")
	qdel(src)

/obj/item/rcd/preloaded
	matter = 100

/obj/item/rcd/combat
	icon_state = "combat-rcd"
	item_state = "combat_rcd"
	name = "combat RCD"
	max_matter = RCD_MATTER_500
	matter = RCD_MATTER_500
	canRwall = TRUE

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	origin_tech = "materials=3"
	materials = list(MAT_METAL=16000, MAT_GLASS=8000)
	var/ammoamt = 20

/obj/item/rcd_ammo/large
	ammoamt = 100

/obj/item/rcd/mecha_ref
	name = "Mecha inner RCD"
	desc = "You should not be able to see it..."
	power_use_multiplier = 250
	var/obj/mecha/chassis = null

/obj/item/rcd/mecha_ref/useResource(amount, mob/user)
	if(!chassis)
		return
	chassis.spark_system.start()
	return chassis.use_power(power_use_multiplier)

/obj/item/rcd/mecha_ref/checkResource(amount, mob/user)
	if(!chassis)
		return
	return chassis.cell.charge >= power_use_multiplier

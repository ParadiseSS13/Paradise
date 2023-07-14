
#define MATTER_100 100
#define MATTER_500 500

#define TAB_AIRLOCK_TYPE	1
#define TAB_AIRLOCK_ACCESS	2

#define MODE_TURF		"Floors and Walls"
#define MODE_AIRLOCK	"Airlocks"
#define MODE_WINDOW		"Windows"
#define MODE_DECON		"Deconstruction"

/obj/item/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build and deconstruct walls, floors and airlocks."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	item_state = "rcd"
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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	/// No ammo warning
	var/no_ammo_message = "<span class='warning'>The \'Low Ammo\' light on the device blinks yellow.</span>"
	/// The spark system used to create sparks when the user interacts with the RCD.
	var/datum/effect_system/spark_spread/spark_system
	/// The current amount of matter stored.
	var/matter = NONE
	/// The max amount of matter that can be stored.
	var/max_matter = MATTER_100
	/// The RCD's current build mode.
	var/mode = MODE_TURF
	/// If the RCD can deconstruct reinforced walls.
	var/canRwall = FALSE
	/// Is the RCD's airlock access selection menu locked?
	var/locked = TRUE
	/// The current airlock type that will be build.
	var/door_type = /obj/machinery/door/airlock
	/// The name that newly build airlocks will receive.
	var/door_name = "Airlock"
	/// If the glass airlock is polarized.
	var/electrochromic = FALSE
	var/airlock_glass = FALSE
	/// If this is TRUE, any airlocks that gets built will require only ONE of the checked accesses. If FALSE, it will require ALL of them.
	var/one_access = TRUE
	/// Which airlock tab the UI is currently set to display.
	var/ui_tab = TAB_AIRLOCK_TYPE
	/// A list of access numbers which have been checked off by the user in the UI.
	var/list/selected_accesses = list()
	/// A list of valid atoms that RCDs can target. Clicking on an atom with an RCD which is not in this list, will do nothing.
	var/static/list/allowed_targets = list(/turf, /obj/structure/grille, /obj/structure/window, /obj/structure/lattice, /obj/machinery/door/airlock)
	/// An associative list of airlock type paths as keys, and their names as values.
	var/static/list/rcd_door_types = list()
	/// An associative list containing an airlock's name, type path, and image. For use with the UI.
	var/static/list/door_types_ui_list = list()
	/// An associative list containing all station accesses. Includes their name and access number. For use with the UI.
	var/static/list/door_accesses_list = list()

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
			/obj/machinery/door/airlock/virology = "Virology",
			/obj/machinery/door/airlock/virology/glass = "Virology (Glass)",
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

	update_icon(UPDATE_OVERLAYS)

/obj/item/rcd/examine(mob/user)
	. = ..()
	. += "MATTER: [matter]/[max_matter] matter-units."
	. += "MODE: [mode]."

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
	var/obj/machinery/door/airlock/airlock = airlock_type
	var/icon/base = icon(initial(airlock.icon), "closed")
	if(initial(airlock.glass))
		var/icon/glass_fill = icon(initial(airlock.overlays_file), "glass_closed")
		base.Blend(glass_fill, ICON_OVERLAY)
	else
		var/icon/solid_fill = icon(initial(airlock.icon), "fill_closed")
		base.Blend(solid_fill, ICON_OVERLAY)
	return "[icon2base64(base)]"

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
/**
*Tries to load ammo into an RCD, borgs will not use this.
* Arguments:
* * cart - the compressed matter catridge to insert
* * user - the user to display the chat messages to
*/
/obj/item/rcd/proc/load(obj/item/rcd_ammo/cart, mob/living/user)
	if(matter == max_matter)
		to_chat(user, "<span class='notice'>The RCD can't hold any more matter-units.</span>")
		return FALSE
	matter = clamp((matter + cart.ammoamt), 0, 100)
	qdel(cart)
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	to_chat(user, "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>")
	update_icon(UPDATE_OVERLAYS)
	SStgui.update_uis(src)

/obj/item/rcd/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/rcd_ammo))
		return ..()
	var/obj/item/rcd_ammo/R = W
	load(R, user)
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
		MODE_AIRLOCK = image(icon = 'icons/obj/interface.dmi', icon_state = "airlock"),
		MODE_DECON = image(icon = 'icons/obj/interface.dmi', icon_state = "delete"),
		MODE_WINDOW = image(icon = 'icons/obj/interface.dmi', icon_state = "grillewindow"),
		MODE_TURF = image(icon = 'icons/obj/interface.dmi', icon_state = "wallfloor"),
		"UI" = image(icon = 'icons/obj/interface.dmi', icon_state = "ui_interact")
	)
	if(mode == MODE_AIRLOCK)
		choices += list(
			"Change Access" = image(icon = 'icons/obj/interface.dmi', icon_state = "access"),
			"Change Airlock Type" = image(icon = 'icons/obj/interface.dmi', icon_state = "airlocktype")
		)
	choices -= mode // Get rid of the current mode, clicking it won't do anything.
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user))
	if(!check_menu(user))
		return
	switch(choice)
		if(MODE_AIRLOCK, MODE_DECON, MODE_WINDOW, MODE_TURF)
			mode = choice
		if("UI")
			ui_interact(user)
			return
		if("Change Access")
			ui_tab = TAB_AIRLOCK_ACCESS
			ui_interact(user)
			return
		if("Change Airlock Type")
			ui_tab = TAB_AIRLOCK_TYPE
			ui_interact(user)
			return
		else
			return
	if(prob(20))
		spark_system.start()
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
		"electrochromic" = electrochromic,
		"airlock_glass" = airlock_glass,
		"one_access" = one_access,
		"selected_accesses" = selected_accesses,
		"modal" = ui_modal_data(src)
	)
	return data

/obj/item/rcd/ui_static_data(mob/user)
	var/list/data = list(
		"max_matter" = max_matter,
		"regions" = get_accesslist_static_data(REGION_GENERAL, REGION_COMMAND),
		"door_accesses_list" = door_accesses_list,
		"door_types_ui_list" = door_types_ui_list
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
			if(!(tab in list(TAB_AIRLOCK_TYPE, TAB_AIRLOCK_ACCESS)))
				return FALSE
			ui_tab = tab

		if("mode")
			var/new_mode = params["mode"]
			if(!(new_mode in list(MODE_TURF, MODE_AIRLOCK, MODE_DECON, MODE_WINDOW)))
				return FALSE
			mode = new_mode

		if("door_type")
			var/new_door_type = text2path(params["door_type"])
			if(!(new_door_type in rcd_door_types))
				message_admins("RCD Door HREF exploit attempted by [key_name(usr)]!")
				return FALSE
			door_type = new_door_type
			var/obj/machinery/door/airlock/picked_door = door_type
			airlock_glass = initial(picked_door.glass)

		if("electrochromic")
			electrochromic = !electrochromic

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
			if(isnull(region) || region < REGION_GENERAL || region > REGION_COMMAND)
				return
			selected_accesses |= get_region_accesses(region)

		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < REGION_GENERAL || region > REGION_COMMAND)
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

/**
 * Called in `afterattack()` if `mode` is set to `MODE_TURF`.
 *
 * Creates either a plating, or a wall, depending on the turf that already exists at the location.
 *
 * Arguments:
 * * A - the location we're trying to build at.
 * * user - the mob using the RCD.
 */
/obj/item/rcd/proc/mode_turf(atom/A, mob/user)
	if(isspaceturf(A) || istype(A, /obj/structure/lattice))
		if(useResource(1, user))
			to_chat(user, "Building Floor...")
			playsound(loc, usesound, 50, 1)
			var/turf/AT = get_turf(A)
			new/obj/effect/temp_visual/rcd_effect/end(get_turf(A))
			AT.ChangeTurf(/turf/simulated/floor/plating)
			return TRUE
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE

	if(isfloorturf(A))
		if(checkResource(3, user))
			to_chat(user, "Building Wall...")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			var/obj/effect/temp_visual/rcd_effect/short/E = new(get_turf(A))
			if(do_after(user, 2 SECONDS * toolspeed, target = A))
				if(!isfloorturf(A))
					return FALSE
				if(!useResource(3, user))
					return FALSE
				playsound(loc, usesound, 50, 1)
				var/turf/AT = A
				new/obj/effect/temp_visual/rcd_effect/end(get_turf(A))
				AT.ChangeTurf(/turf/simulated/wall)
				return TRUE
			qdel(E)
			return FALSE
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE
	to_chat(user, "<span class='warning'>ERROR! Location unsuitable for wall construction!</span>")
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	return FALSE

/**
 * Called in `afterattack()` if `mode` is set to `MODE_AIRLOCK`.
 *
 * Creates an `door_type` airlock at the given location `A`, and assigns it accesses from `selected_accesses`.
 *
 * Arguments:
 * * A - the location we're trying to build at.
 * * user - the mob using the RCD.
 */
/obj/item/rcd/proc/mode_airlock(atom/A, mob/user)
	if(isfloorturf(A))
		if(checkResource(10, user))
			to_chat(user, "Building Airlock...")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			var/obj/effect/temp_visual/rcd_effect/E = new(get_turf(A))
			if(do_after(user, 5 SECONDS * toolspeed, target = A))
				if(locate(/obj/machinery/door/airlock) in A.contents)
					return FALSE
				if(!useResource(10, user))
					return FALSE
				playsound(loc, usesound, 50, 1)
				new/obj/effect/temp_visual/rcd_effect/end(get_turf(A))
				var/obj/machinery/door/airlock/T = new door_type(A)
				if(T.glass)
					T.polarized_glass = electrochromic
				T.name = door_name
				T.autoclose = TRUE
				if(one_access)
					T.req_one_access = selected_accesses.Copy()
				else
					T.req_access = selected_accesses.Copy()
				return FALSE
			qdel(E)
			return FALSE
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE
	to_chat(user, "<span class='warning'>ERROR! Location unsuitable for airlock construction!</span>")
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	return FALSE

/**
 * Called in `afterattack()` if `mode` is set to `MODE_DECON`.
 *
 * Deconstrcts the target atom `A`.
 * Valid atoms are: basic walls, reinforced walls (if `canRwall` is `TRUE`), airlocks, and windows.
 *
 * Arguments:
 * * A - the location we're trying to build at.
 * * user - the mob using the RCD.
 */
/obj/item/rcd/proc/mode_decon(atom/A, mob/user)
	if(iswallturf(A))
		if(isreinforcedwallturf(A) && !canRwall)
			return FALSE
		if(istype(A, /turf/simulated/wall/indestructible))
			return FALSE
		if(checkResource(5, user))
			to_chat(user, "Deconstructing Wall...")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			var/obj/effect/temp_visual/rcd_effect/reverse/E = new(get_turf(A))
			if(do_after(user, 5 SECONDS * toolspeed, target = A))
				if(!useResource(5, user))
					return FALSE
				playsound(loc, usesound, 50, 1)
				var/turf/AT = A
				AT.ChangeTurf(/turf/simulated/floor/plating)
				return TRUE
			qdel(E)
			return FALSE
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE

	if(isfloorturf(A))
		if(checkResource(5, user))
			to_chat(user, "Deconstructing Floor...")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			var/obj/effect/temp_visual/rcd_effect/reverse/E = new(get_turf(A))
			if(do_after(user, 5 SECONDS * toolspeed, target = A))
				if(!useResource(5, user))
					return FALSE
				playsound(loc, usesound, 50, 1)
				var/turf/AT = A
				AT.ChangeTurf(AT.baseturf)
				return TRUE
			qdel(E)
			return FALSE
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE

	if(istype(A, /obj/machinery/door/airlock))
		if(checkResource(20, user))
			to_chat(user, "Deconstructing Airlock...")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			var/obj/effect/temp_visual/rcd_effect/reverse/E = new(get_turf(A))
			if(do_after(user, 5 SECONDS * toolspeed, target = A))
				if(!useResource(20, user))
					return FALSE
				playsound(loc, usesound, 50, 1)
				qdel(A)
				return TRUE
			qdel(E)
			return FALSE
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE

	if(istype(A, /obj/structure/window)) // You mean the grille of course, do you?
		A = locate(/obj/structure/grille) in A.loc
	if(istype(A, /obj/structure/grille))
		if(!checkResource(2, user))
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			return FALSE
		to_chat(user, "Deconstructing window...")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		var/obj/effect/temp_visual/rcd_effect/reverse_short/E = new(get_turf(A))
		if(!do_after(user, 20 * toolspeed, target = A))
			qdel(E)
			return FALSE
		if(!useResource(2, user))
			return FALSE
		playsound(loc, usesound, 50, 1)
		var/turf/T1 = get_turf(A)
		QDEL_NULL(A)
		for(var/obj/structure/window/W in T1.contents)
			qdel(W)
		return TRUE
	return FALSE

/**
 * Called in `afterattack()` if `mode` is set to `MODE_WINDOW`.
 *
 * Constructs a grille and 4 reinforced window panes at the given location `A`.
 *
 * Arguments:
 * * A - the location we're trying to build at.
 * * user - the mob using the RCD.
 */
/obj/item/rcd/proc/mode_window(atom/A, mob/user)
	if(isfloorturf(A))
		if(locate(/obj/structure/grille) in A)
			return FALSE // We already have window
		if(!checkResource(2, user))
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			return FALSE
		to_chat(user, "Constructing window...")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		var/obj/effect/temp_visual/rcd_effect/short/E = new(get_turf(A))
		if(!do_after(user, 20 * toolspeed, target = A))
			qdel(E)
			return FALSE
		if(locate(/obj/structure/grille) in A)
			return FALSE // We already have window
		if(!useResource(2, user))
			return FALSE
		playsound(loc, usesound, 50, 1)
		new/obj/effect/temp_visual/rcd_effect/end(get_turf(A))
		new /obj/structure/grille(A)
		for(var/obj/structure/window/W in A)
			qdel(W)
		new /obj/structure/window/full/reinforced(A)
		var/turf/AT = A
		AT.ChangeTurf(/turf/simulated/floor/plating) // Platings go under windows.
		return TRUE
	to_chat(user, "<span class='warning'>ERROR! Location unsuitable for window construction!</span>")
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	return FALSE

/obj/item/rcd/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return FALSE
	if(istype(A, /turf/space/transit))
		return FALSE
	if(!is_type_in_list(A, allowed_targets))
		return FALSE

	switch(mode)
		if(MODE_TURF)
			. = mode_turf(A, user)
		if(MODE_AIRLOCK)
			. = mode_airlock(A, user)
		if(MODE_DECON)
			. = mode_decon(A, user)
		if(MODE_WINDOW)
			. = mode_window(A, user)
		else
			to_chat(user, "ERROR: RCD in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin.")
			. = 0

	update_icon(UPDATE_OVERLAYS)
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
	if(matter < amount)
		return FALSE
	matter -= amount
	SStgui.update_uis(src)
	return TRUE

/**
 * Called in each of the four build modes before an object gets build. Makes sure there is enough matter to build the object.
 *
 * Arguments:
 * * amount - an amount of matter to check for
 */
/obj/item/rcd/proc/checkResource(amount, mob/user)
	. = matter >= amount
	if(!. && user)
		to_chat(user, no_ammo_message)
		flick("[icon_state]_empty", src)

	return

/obj/item/rcd/update_overlays()
	..()
	var/ratio = CEILING((matter / max_matter) * 10, 1)
	cut_overlays()
	add_overlay("[icon_state]_charge[ratio]")

/obj/item/rcd/borg
	canRwall = TRUE
	/// A multipler which is applied to matter amount checks. A higher number means more power usage per RCD usage.
	var/power_use_multiplier = 160

/obj/item/rcd/borg/syndicate
	power_use_multiplier = 80

/obj/item/rcd/borg/useResource(amount, mob/user)
	if(!isrobot(user))
		return FALSE
	var/mob/living/silicon/robot/R = user
	return R.cell.use(amount * power_use_multiplier)

/obj/item/rcd/borg/checkResource(amount, mob/user)
	if(!isrobot(user))
		return FALSE
	var/mob/living/silicon/robot/R = user
	return R.cell.charge >= (amount * power_use_multiplier)

/**
 * Called from malf AI's "detonate RCD" ability.
 *
 * Creates a delayed explosion centered around the RCD.
 */
/obj/item/rcd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] begins to vibrate and buzz loudly!</b></span>", "<span class='danger'><b>[src] begins vibrating violently!</b></span>")
	// 5 seconds to get rid of it
	addtimer(CALLBACK(src, PROC_REF(detonate_pulse_explode)), 50)

/**
 * Called in `/obj/item/rcd/proc/detonate_pulse()` via callback.
 */
/obj/item/rcd/proc/detonate_pulse_explode()
	explosion(src, 0, 0, 3, 1, flame_range = 1)
	qdel(src)

/obj/item/rcd/preloaded
	matter = 100

/obj/item/rcd/combat
	name = "combat RCD"
	icon_state = "crcd"
	item_state = "crcd"
	max_matter = MATTER_500
	matter = MATTER_500
	canRwall = TRUE

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	origin_tech = "materials=3"
	materials = list(MAT_METAL=16000, MAT_GLASS=8000)
	var/ammoamt = 20

/obj/item/rcd_ammo/attackby(obj/item/I, mob/user)
	if(!istype(I, /obj/item/rcd) || issilicon(user))
		return ..()
	var/obj/item/rcd/R = I
	R.load(src, user)

/obj/item/rcd_ammo/large
	ammoamt = 100

#undef MATTER_100
#undef MATTER_500

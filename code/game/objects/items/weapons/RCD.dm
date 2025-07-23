#define TAB_AIRLOCK_TYPE	1
#define TAB_AIRLOCK_ACCESS	2

#define MODE_TURF		"Floors and Walls"
#define MODE_AIRLOCK	"Airlocks"
#define MODE_WINDOW		"Windows"
#define MODE_DECON		"Deconstruction"

/// A generic action for an RCD.
/datum/rcd_act
	/// How much compressed matter this action costs.
	var/cost = 0
	/// How long this action takes.
	var/delay = 0
	/// The message (if any) to send the user when the action starts.
	var/start_message
	/// The effect (if any) to create when the action starts.
	var/obj/effect/start_effect_type
	/// The effect (if any) to create when the action completes.
	var/obj/effect/end_effect_type
	/// The mode the RCD must be in.
	var/mode

/// Attempt the action. This should not need to be overridden.
/datum/rcd_act/proc/try_act(atom/A, obj/item/rcd/rcd, mob/user)
	if(!can_act(A, rcd))
		return FALSE
	// We don't use the sound effect from use_tool because RCDs have a different sound effect for the start and end.
	playsound(get_turf(rcd), 'sound/machines/click.ogg', 50, TRUE)
	if(!rcd.tool_use_check(user, cost))
		return FALSE
	if(start_message)
		to_chat(user, start_message)
	var/obj/effect/start_effect
	if(start_effect_type)
		start_effect = new start_effect_type(get_turf(A))
	if(!rcd.use_tool(A, user, delay, cost))
		if(!QDELETED(start_effect))
			qdel(start_effect)
		return FALSE
	if(start_effect)
		qdel(start_effect)
	// If time elapsed, check our preconditions again.
	if(delay && !can_act(A, rcd))
		return FALSE
	if(end_effect_type)
		new end_effect_type(get_turf(A))
	playsound(get_turf(rcd), 'sound/items/deconstruct.ogg', 50, TRUE)
	act(A, rcd, user)
	return TRUE

/// Test to see if the act is possible. You should usually override this.
/datum/rcd_act/proc/can_act(atom/A, obj/item/rcd/rcd)
	SHOULD_CALL_PARENT(TRUE)
	return rcd.mode == mode

/// Perform the act. You should usually override this.
/datum/rcd_act/proc/act(atom/A, obj/item/rcd/rcd, mob/user)
	return

/datum/rcd_act/place_floor
	mode = MODE_TURF
	cost = 1
	start_message = "Building floor..."
	end_effect_type = /obj/effect/temp_visual/rcd_effect/end

/datum/rcd_act/place_floor/can_act(atom/A, obj/item/rcd/rcd)
	if(!..())
		return FALSE
	return isspaceturf(A) || istype(A, /obj/structure/lattice)

/datum/rcd_act/place_floor/act(atom/A, obj/item/rcd/rcd, mob/user)
	var/turf/act_on = get_turf(A)
	act_on.ChangeTurf(/turf/simulated/floor/plating)

/datum/rcd_act/place_wall
	mode = MODE_TURF
	cost = 3
	start_message = "Building wall..."
	delay = 2 SECONDS
	start_effect_type = /obj/effect/temp_visual/rcd_effect/short
	end_effect_type = /obj/effect/temp_visual/rcd_effect/end

/datum/rcd_act/place_wall/can_act(atom/A, obj/item/rcd/rcd)
	if(!..())
		return FALSE
	return isfloorturf(A)

/datum/rcd_act/place_wall/act(atom/A, obj/item/rcd/rcd, mob/user)
	var/turf/act_on = get_turf(A)
	act_on.ChangeTurf(/turf/simulated/wall)

/datum/rcd_act/place_airlock
	mode = MODE_AIRLOCK
	cost = 10
	start_message = "Building airlock..."
	delay = 5 SECONDS
	start_effect_type = /obj/effect/temp_visual/rcd_effect
	end_effect_type = /obj/effect/temp_visual/rcd_effect/end

/datum/rcd_act/place_airlock/can_act(atom/A, obj/item/rcd/rcd)
	if(!..())
		return FALSE
	return isfloorturf(A) && !(/obj/machinery/door/airlock in A.contents)

/datum/rcd_act/place_airlock/act(atom/A, obj/item/rcd/rcd, mob/user)
	var/obj/machinery/door/airlock/T = new rcd.door_type(A)
	if(T.glass)
		T.polarized_glass = rcd.electrochromic
	T.name = rcd.door_name
	T.autoclose = TRUE
	if(rcd.one_access)
		T.req_one_access = rcd.selected_accesses.Copy()
	else
		T.req_access = rcd.selected_accesses.Copy()

/datum/rcd_act/place_window
	mode = MODE_WINDOW
	cost = 2
	start_message = "Building window..."
	delay = 2 SECONDS
	start_effect_type = /obj/effect/temp_visual/rcd_effect/short
	end_effect_type = /obj/effect/temp_visual/rcd_effect/end

/datum/rcd_act/place_window/can_act(atom/A, obj/item/rcd/rcd)
	if(!..())
		return FALSE
	return isfloorturf(A) && !(/obj/structure/grille in A.contents)

/datum/rcd_act/place_window/act(atom/A, obj/item/rcd/rcd, mob/user)
	var/turf/act_on= A
	for(var/obj/structure/window/window_to_delete in act_on)
		qdel(window_to_delete)
	new /obj/structure/grille(act_on)
	new /obj/structure/window/full/reinforced(act_on)
	act_on.ChangeTurf(/turf/simulated/floor/plating) // Platings go under windows.

/datum/rcd_act/remove_floor
	mode = MODE_DECON
	cost = 5
	start_message = "Deconstructing floor..."
	delay = 5 SECONDS
	start_effect_type = /obj/effect/temp_visual/rcd_effect/reverse

/datum/rcd_act/remove_floor/can_act(atom/A, obj/item/rcd/rcd)
	if(!..())
		return FALSE
	return isfloorturf(A)

/datum/rcd_act/remove_floor/act(atom/A, obj/item/rcd/rcd, mob/user)
	var/turf/act_on = get_turf(A)
	act_on.ChangeTurf(act_on.baseturf)

/datum/rcd_act/remove_wall
	mode = MODE_DECON
	cost = 5
	start_message = "Deonstructing wall..."
	delay = 5 SECONDS
	start_effect_type = /obj/effect/temp_visual/rcd_effect/reverse

/datum/rcd_act/remove_wall/can_act(atom/A, obj/item/rcd/rcd)
	if(!..())
		return FALSE
	if(isreinforcedwallturf(A) && !rcd.can_rwall)
		return FALSE
	if(istype(A, /turf/simulated/wall/indestructible))
		return FALSE
	return iswallturf(A)

/datum/rcd_act/remove_wall/act(atom/A, obj/item/rcd/rcd, mob/user)
	var/turf/act_on = get_turf(A)
	act_on.ChangeTurf(/turf/simulated/floor/plating)

/datum/rcd_act/remove_airlock
	mode = MODE_DECON
	cost = 20
	start_message = "Deconstructing airlock..."
	delay = 5 SECONDS
	start_effect_type = /obj/effect/temp_visual/rcd_effect/reverse

/datum/rcd_act/remove_airlock/can_act(atom/A, obj/item/rcd/rcd)
	if(!..())
		return FALSE
	return istype(A, /obj/machinery/door/airlock)

/datum/rcd_act/remove_airlock/act(atom/A, obj/item/rcd/rcd, mob/user)
	qdel(A)

/datum/rcd_act/remove_window
	mode = MODE_DECON
	cost = 2
	start_message = "Deconstructing window..."
	delay = 2 SECONDS
	start_effect_type = /obj/effect/temp_visual/rcd_effect/reverse_short

/datum/rcd_act/remove_window/can_act(atom/A, obj/item/rcd/rcd)
	if(!..())
		return FALSE
	return istype(A, /obj/structure/window)

/datum/rcd_act/remove_window/act(atom/A, obj/item/rcd/rcd, mob/user)
	var/turf/act_on = get_turf(A)
	qdel(A)
	for(var/obj/structure/grille/grill_to_destroy in act_on)
		qdel(grill_to_destroy)

/datum/rcd_act/remove_user
	mode = MODE_DECON
	cost = 5
	start_message = "Deconstructing user..."
	delay = 5 SECONDS
	start_effect_type = /obj/effect/temp_visual/rcd_effect/reverse

/datum/rcd_act/remove_user/can_act(atom/A, obj/item/rcd/rcd)
	if(!..())
		return FALSE
	return A == rcd.loc

/obj/item/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build and deconstruct walls, floors and airlocks."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	flags = CONDUCT | NOBLUDGEON
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL = 30000)
	origin_tech = "engineering=4;materials=2"
	flags_2 = NO_MAT_REDEMPTION_2
	req_access = list(ACCESS_ENGINE)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	new_attack_chain = TRUE
	/// No ammo warning
	var/no_ammo_message = "<span class='warning'>The \'Low Ammo\' light on the device blinks yellow.</span>"
	/// The spark system used to create sparks when the user interacts with the RCD.
	var/datum/effect_system/spark_spread/spark_system
	/// The current amount of matter stored.
	var/matter = NONE
	/// The max amount of matter that can be stored.
	var/max_matter = 100
	/// The RCD's current build mode.
	var/mode = MODE_TURF
	/// If the RCD can deconstruct reinforced walls.
	var/can_rwall = FALSE
	/// Is the RCD's airlock access selection menu locked?
	var/locked = TRUE
	/// The current airlock type that will be build.
	var/door_type = /obj/machinery/door/airlock
	/// The name that newly build airlocks will receive.
	var/door_name = "Airlock"
	/// If the glass airlock is polarized.
	var/electrochromic = FALSE
	/// If the airlock will be created with glass so it can be seen through.
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
	/// The list of potential RCD actions.
	var/static/list/possible_actions

/obj/item/rcd/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))
	if(!length(possible_actions))
		possible_actions = list()
		for(var/action_type in subtypesof(/datum/rcd_act))
			possible_actions += new action_type()

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

/obj/item/rcd/suicide_act(mob/living/user)
	user.Immobilize(10 SECONDS) // You cannot move.
	set_nodrop(TRUE, user)
	if(mode == MODE_DECON)
		user.visible_message("<span class='suicide'>[user] points [src] at [user.p_their()] chest and pulls the trigger. It looks like [user.p_theyre()] trying to commit suicide!</span>")
		var/datum/rcd_act/remove_user/act = new()
		if(!act.try_act(user, src, user))
			set_nodrop(FALSE, user)
			return SHAME
		user.visible_message("<span class='suicide'>[user] deconstructs [user.p_themselves()] with [src]!</span>")
		for(var/obj/item/W in user)	// Do not delete all their stuff.
			user.drop_item_to_ground(W)			// Dump everything on the floor instead.
		set_nodrop(FALSE, user)
		user.dust()					// (held items fall to the floor when dusting).
		return OBLITERATION

	user.visible_message("<span class='suicide'>[user] puts the barrel of [src] into [user.p_their()] mouth and pulls the trigger. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(!interact_with_atom(get_turf(src), user, TRUE))
		set_nodrop(FALSE, user)
		return SHAME
	user.visible_message("<span class='suicide'>[user] explodes as [src] builds a structure inside [user.p_them()]!</span>")
	set_nodrop(FALSE, user)
	user.gib()
	return OBLITERATION

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
	matter = clamp((matter + cart.ammoamt), 0, max_matter)
	qdel(cart)
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	to_chat(user, "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>")
	update_icon(UPDATE_OVERLAYS)
	SStgui.update_uis(src)

/obj/item/rcd/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/smithed_item/tool_bit))
		SEND_SIGNAL(src, COMSIG_BIT_ATTACH, used, user)
		return ..()
	if(!istype(used, /obj/item/rcd_ammo))
		return ..()
	var/obj/item/rcd_ammo/ammo = used
	load(ammo, user)
	return ITEM_INTERACT_COMPLETE

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

/obj/item/rcd/activate_self(mob/user)
	if(..())
		return
	//Change the mode // Oh I thought the UI was just for fucking staring at
	radial_menu(user)

/obj/item/rcd/attack_self_tk(mob/user)
	radial_menu(user)

/obj/item/rcd/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/rcd/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RCD", "Rapid Construction Device")
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
			door_name = sanitize(copytext_char(answer, 1, UI_MODAL_INPUT_MAX_LENGTH_NAME))
		else
			return FALSE

/obj/item/rcd/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(istype(target, /turf/space/transit))
		return FALSE
	if(!is_type_in_list(target, allowed_targets))
		return FALSE

	for(var/datum/rcd_act/act in possible_actions)
		if(act.can_act(target, src))
			. = act.try_act(target, src, user)
			update_icon(UPDATE_OVERLAYS)
			SStgui.update_uis(src)
			return ITEM_INTERACT_COMPLETE

	if(mode == MODE_DECON)
		to_chat(user, "<span class='warning'>You can't deconstruct that!</span>")
	else
		to_chat(user, "<span class='warning'>Location unsuitable for construction.</span>")

	update_icon(UPDATE_OVERLAYS)
	SStgui.update_uis(src)
	return FALSE

/**
 * Attempts to use matter from the RCD.
 *
 * Arguments:
 * * amount - the amount of matter to use
 */
/obj/item/rcd/use(amount)
	amount = amount * bit_efficiency_mod
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
/obj/item/rcd/tool_use_check(mob/user, amount)
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
	can_rwall = TRUE
	matter = 100

/obj/item/rcd/borg/syndicate
	/// A multipler which is applied to matter amount checks. A higher number means more power usage per RCD usage.
	var/power_use_multiplier = 80

/obj/item/rcd/borg/syndicate/use(amount)
	var/mob/living/silicon/robot/R = usr
	if(!istype(R))
		return FALSE
	return R.cell.use(amount * power_use_multiplier)

/obj/item/rcd/borg/syndicate/tool_use_check(mob/user, amount)
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
	explosion(src, 0, 0, 3, 1, flame_range = 1, cause = "RCD Explosion")
	qdel(src)

/obj/item/rcd/preloaded
	matter = 100

/obj/item/rcd/combat
	name = "combat RCD"
	icon_state = "crcd"
	max_matter = 500
	matter = 500
	can_rwall = TRUE

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	inhand_icon_state = "rcdammo"
	origin_tech = "materials=3"
	materials = list(MAT_METAL=16000, MAT_GLASS=8000)
	new_attack_chain = TRUE
	var/ammoamt = 20

/obj/item/rcd_ammo/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/rcd))
		return ..()
	var/obj/item/rcd/R = used
	R.load(src, user)
	return ITEM_INTERACT_COMPLETE

/obj/item/rcd_ammo/large
	ammoamt = 100

#undef TAB_AIRLOCK_TYPE
#undef TAB_AIRLOCK_ACCESS
#undef MODE_TURF
#undef MODE_AIRLOCK
#undef MODE_WINDOW
#undef MODE_DECON

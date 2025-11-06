/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	var/level = 2
	var/flags = NONE
	var/flags_2 = NONE
	/// how the atom should handle ricochet behavior
	var/flags_ricochet = NONE
	var/list/fingerprints
	var/list/fingerprintshidden
	var/fingerprintslast = null
	///For handling persistent filters
	var/list/filter_data

	/// pass_flags that we are. If any of this matches a pass_flag on a moving thing, by default, we let them through.
	var/pass_flags_self = NONE
	/// How this atom should react to having its astar blocking checked
	var/can_pathfind_pass = CANPATHFINDPASS_DENSITY

	var/list/blood_DNA
	var/blood_color
	/// Will the atom spread blood when touched?
	var/should_spread_blood = FALSE
	var/pass_flags = 0
	/// The higher the germ level, the more germ on the atom.
	var/germ_level = GERM_LEVEL_AMBIENT
	/// Filter for actions - used by lighting overlays
	var/simulated = TRUE
	var/atom_say_verb = "says"
	/// What icon the mob uses for speechbubbles
	var/bubble_icon = "default"

	// Chemistry.
	var/container_type = NONE
	var/datum/reagents/reagents = null

	/// This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list
	/// HUD images that this atom can provide.
	var/list/hud_possible

	/// Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	///vis overlays managed by SSvis_overlays to automaticaly turn them like other overlays.
	var/list/managed_vis_overlays

	// Detective Work, used for the duplicate data points kept in the scanners
	var/list/original_atom
	/// List of fibers that this atom has
	var/list/suit_fibers

	var/admin_spawned = FALSE	//was this spawned by an admin? used for stat tracking stuff.

	var/initialized = FALSE

	var/list/priority_overlays	//overlays that should remain on top and not normally removed when using cut_overlay functions, like c4.
	var/list/remove_overlays // a very temporary list of overlays to remove
	var/list/add_overlays // a very temporary list of overlays to add
	///overlays managed by [update_overlays][/atom/proc/update_overlays] to prevent removing overlays that weren't added by the same proc. Single items are stored on their own, not in a list.
	var/list/managed_overlays

	var/list/atom_colours	 //used to store the different colors on an atom
						//its inherent color, the colored paint applied on it, special color effect etc...

	/// Radiation insulation for alpha emissions
	var/rad_insulation_alpha = RAD_ALPHA_BLOCKER
	/// Radiation insulation for beta emissions
	var/rad_insulation_beta = RAD_NO_INSULATION
	/// Radiation insulation for gamma emissions
	var/rad_insulation_gamma = RAD_NO_INSULATION

	/// Last name used to calculate a color for the chatmessage overlays. Used for caching.
	var/chat_color_name
	/// Last color calculated for the the chatmessage overlays. Used for caching.
	var/chat_color

	/*
	Smoothing Vars
	*/
	///Icon-smoothing behavior.
	var/smoothing_flags = NONE
	///Smoothing variable
	var/top_left_corner
	///Smoothing variable
	var/top_right_corner
	///Smoothing variable
	var/bottom_left_corner
	///Smoothing variable
	var/bottom_right_corner
	///What smoothing groups does this atom belongs to, to match canSmoothWith. If null, nobody can smooth with it.
	var/list/smoothing_groups = null
	///List of smoothing groups this atom can smooth with. If this is null and atom is smooth, it smooths only with itself.
	var/list/canSmoothWith = null
	///What directions this is currently smoothing with. IMPORTANT: This uses the smoothing direction flags as defined in icon_smoothing.dm, instead of the BYOND flags.
	var/smoothing_junction = null //This starts as null for us to know when it's first set, but after that it will hold a 8-bit mask ranging from 0 to 255.
	///Used for changing icon states for different base sprites.
	var/base_icon_state
	/// This var isn't actually used for anything, but is present so that DM's map reader doesn't forfeit on reading a JSON-serialized map. AKA DO NOT FUCK WITH
	var/map_json_data

	/*
	Lighting Vars
	*/
	/// Intensity of the light. Can be negative to remove light
	var/light_power = 1
	// Range in tiles of the light.
	var/light_range = 0
	// Hexadecimal RGB string representing the colour of the light. ALWAYS REMEMBER TO MAKE SURE THIS CAN'T BE NULL/NEGATIVE
	var/light_color

	// Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/datum/light_source/light
	// Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.
	var/tmp/list/light_sources
	// Variables for bloom and exposure
	var/glow_icon = 'icons/obj/lamps.dmi'
	var/exposure_icon = 'icons/effects/exposures.dmi'

	var/glow_icon_state
	var/glow_colored = TRUE
	var/exposure_icon_state
	var/exposure_colored = TRUE

	var/image/glow_overlay
	var/image/exposure_overlay
	/// The alternate appearances we own. Lazylist
	var/list/alternate_appearances
	/// The alternate appearances we're viewing, stored here to reestablish them after Logout()s. Lazylist
	var/list/viewing_alternate_appearances
	/// Contains the world.time of when we start dragging something with our mouse. Used to prevent weird situations where you fail to click on something
	var/drag_start = 0

	///When a projectile tries to ricochet off this atom, the projectile ricochet chance is multiplied by this
	var/receive_ricochet_chance_mod = 1
	///When a projectile ricochets off this atom, it deals the normal damage * this modifier to this atom
	var/receive_ricochet_damage_coeff = 0.33
	/// AI controller that controls this atom. type on init, then turned into an instance during runtime
	var/datum/ai_controller/ai_controller
	/// Information about attacks performed on this atom.
	var/datum/attack_info/attack_info

	/// Whether this atom is using the new attack chain.
	var/new_attack_chain = FALSE

	/// Do we care about temperature at all? Saves us a ton of proc calls during big fires.
	var/cares_about_temperature = FALSE

	// Should we ignore PROJECTILE_HIT_THRESHHOLD_LAYER to hit it? Allows us to hit things like floor, cables etc.
	var/proj_ignores_layer = FALSE

/atom/New(loc, ...)
	SHOULD_CALL_PARENT(TRUE)
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		GLOB._preloader.load(src)
	. = ..()
	attempt_init(arglist(args))

// This is distinct from /tg/ because of our space management system
// This is overriden in /atom/movable and the parent isn't called if the SMS wants to deal with it's init
/atom/proc/attempt_init(...)
	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			// we were deleted
			return

//Called after New if the map is being loaded. mapload = TRUE
//Called from base of New if the map is not being loaded. mapload = FALSE
//This base must be called or derivatives must set initialized to TRUE
//must not sleep
//Other parameters are passed from New (excluding loc), this does not happen if mapload is TRUE
//Must return an Initialize hint. Defined in __DEFINES/subsystems.dm

//Note: the following functions don't call the base for optimization and must copypasta:
// /turf/Initialize
// /turf/open/space/Initialize

/atom/proc/Initialize(mapload, ...)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(desc == ABSTRACT_TYPE_DESC)
		stack_trace("[type] was initialized, but is marked as an abstract base type")

	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if(light_power && light_range)
		update_light()

	if(loc)
		SEND_SIGNAL(loc, COMSIG_ATOM_INITIALIZED_ON, src) // Used for poolcontroller / pool to improve performance greatly. However it also open up path to other usage of observer pattern on turfs.

	if(length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
		SET_BITFLAG_LIST(smoothing_groups)
	if(length(canSmoothWith))
		sortTim(canSmoothWith)
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)

	if(ispath(ai_controller, /datum/ai_controller))
		ai_controller = new ai_controller(src)
	else if(!isnull(ai_controller))
		stack_trace("[src] expected an ai controller typepath or null for its AI controller, but was instead given [ai_controller].")

	return INITIALIZE_HINT_NORMAL

//called if Initialize returns INITIALIZE_HINT_LATELOAD
/atom/proc/LateInitialize()
	SHOULD_NOT_SLEEP(TRUE)
	return

/atom/proc/onCentcom()
	. = FALSE
	var/turf/T = get_turf(src)
	if(!T)
		return

	if(!is_admin_level(T.z))//if not, don't bother
		return

	//check for centcomm shuttles
	for(var/centcom_shuttle in list("emergency", "pod1", "pod2", "pod3", "pod4", "ferry"))
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(centcom_shuttle)
		if(T in M.areaInstance)
			return TRUE

	//finally check for centcom itself
	return istype(T.loc, /area/centcom)

/atom/proc/onSyndieBase()
	. = FALSE
	var/turf/T = get_turf(src)
	if(!T)
		return

	if(!is_admin_level(T.z))//if not, don't bother
		return

	if(istype(T.loc, /area/shuttle/syndicate_elite) || istype(T.loc, /area/syndicate_mothership))
		return TRUE

/atom/Destroy()
	QDEL_NULL(attack_info)

	if(alternate_appearances)
		for(var/aakey in alternate_appearances)
			var/datum/alternate_appearance/AA = alternate_appearances[aakey]
			qdel(AA)
		alternate_appearances = null

	REMOVE_FROM_SMOOTH_QUEUE(src)
	QDEL_NULL(reagents)
	invisibility = INVISIBILITY_MAXIMUM
	LAZYCLEARLIST(overlays)
	LAZYCLEARLIST(priority_overlays)

	managed_overlays = null

	if(ai_controller)
		QDEL_NULL(ai_controller)

	QDEL_NULL(light)

	return ..()

//Hook for running code when a dir change occurs
/atom/proc/setDir(newdir)
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir

/*
	Sets the atom's pixel locations based on the atom's `dir` variable, and what pixel offset arguments are passed into it
	If no arguments are supplied, `pixel_x` or `pixel_y` will be set to 0
	Used primarily for when players attach mountable frames to walls (APC frame, fire alarm frame, etc.)
*/
/atom/proc/set_pixel_offsets_from_dir(pixel_north = 0, pixel_south = 0, pixel_east = 0, pixel_west = 0)
	switch(dir)
		if(NORTH)
			pixel_y = pixel_north
		if(SOUTH)
			pixel_y = pixel_south
		if(EAST)
			pixel_x = pixel_east
		if(WEST)
			pixel_x = pixel_west
		if(NORTHEAST)
			pixel_y = pixel_north
			pixel_x = pixel_east
		if(NORTHWEST)
			pixel_y = pixel_north
			pixel_x = pixel_west
		if(SOUTHEAST)
			pixel_y = pixel_south
			pixel_x = pixel_east
		if(SOUTHWEST)
			pixel_y = pixel_south
			pixel_x = pixel_west

///Handle melee attack by a mech
/atom/proc/mech_melee_attack(obj/mecha/M)
	return

/atom/proc/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	SEND_SIGNAL(src, COMSIG_ATOM_HULK_ATTACK, user)
	if(does_attack_animation)
		user.changeNext_move(CLICK_CD_MELEE)
		add_attack_logs(user, src, "Punched with hulk powers")
		user.do_attack_animation(src, ATTACK_EFFECT_SMASH)

/atom/proc/CheckParts(list/parts_list)
	for(var/A in parts_list)
		if(istype(A, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(A)
			reagents.conditional_update()
		else if(istype(A, /atom/movable))
			var/atom/movable/M = A
			if(isliving(M.loc))
				var/mob/living/L = M.loc
				L.drop_item_to_ground(M)
			M.forceMove(src)

///Return the air if we can analyze it
/atom/proc/return_analyzable_air()
	return null

/atom/proc/on_reagent_change()
	return

/atom/proc/Bumped(atom/movable/AM)
	// This may seem scary but one will find that replacing this with
	// SHOULD_NOT_SLEEP(TRUE) surfaces two dozen instances where /Bumped sleeps,
	// such as airlocks. We cannot wait for these procs to finish because they
	// will clobber any movement which occurred in the intervening time. If we
	// want to get rid of this we need to move bumping in its entirety to signal
	// handlers, which is scarier.
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_ATOM_BUMPED, AM)

/// Convenience proc to see if a container is open for chemistry handling
/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/// Is this atom injectable into other atoms
/atom/proc/is_injectable(mob/user, allowmobs = TRUE)
	return reagents && (container_type & (INJECTABLE|REFILLABLE))

/// Can we draw from this atom with an injectable atom
/atom/proc/is_drawable(mob/user, allowmobs = TRUE)
	return reagents && (container_type & (DRAWABLE|DRAINABLE))

/// Can this atoms reagents be refilled
/atom/proc/is_refillable()
	return reagents && (container_type & REFILLABLE)

/// Is this atom drainable of reagents
/atom/proc/is_drainable()
	return reagents && (container_type & DRAINABLE)

/atom/proc/HasProximity(atom/movable/AM)
	return

/**
 * Proc which will make the atom act accordingly to an EMP.
 * This proc can sleep depending on the implementation. So assume it sleeps!
 *
 * severity - The severity of the EMP. Either EMP_HEAVY, EMP_LIGHT, or EMP_WEAKENED
 */
/atom/proc/emp_act(severity)
	SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity)

/atom/proc/water_act(volume, temperature, source, method = REAGENT_TOUCH) //amount of water acting : temperature of water in kelvin : object that called it (for shennagins)
	return TRUE

/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	. = P.on_hit(src, 0, def_zone)

/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(loc, container))
			return TRUE
	else if(src in container)
		return TRUE
	return FALSE

/*
 *	atom/proc/search_contents_for(path, list/filter_path = null)
 * Recursevly searches all atom contens (including contents contents and so on).
 *
 * ARGS: path - search atom contents for atoms of this type
 *	   list/filter_path - if set, contents of atoms not of types in this list are excluded from search.
 *
 * RETURNS: list of found atoms
 */

/atom/proc/search_contents_for(path, list/filter_path = null)
	var/list/found = list()
	for(var/atom/A in src)
		if(istype(A, path))
			found += A
		if(filter_path)
			var/pass = 0
			for(var/type in filter_path)
				pass |= istype(A, type)
			if(!pass)
				continue
		if(length(A.contents))
			found += A.search_contents_for(path, filter_path)
	return found

/atom/proc/build_base_description(infix = "", suffix = "")
	//This reformat names to get a/an properly working on item descriptions when they are bloody
	var/f_name = "\a [src][infix]."
	if(src.blood_DNA)
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		if(blood_color != "#030303")
			f_name += "<span class='danger'>blood-stained</span> [name][infix]!"
		else
			f_name += "oil-stained [name][infix]."
	. = list("[bicon(src)] That's [f_name] [suffix]")
	if(desc)
		. += desc

/atom/proc/build_reagent_description(mob/user)
	. = list()
	if(!reagents)
		return
	var/one_percent = reagents.total_volume / 100
	var/blood_type = ""
	if(user.advanced_reagent_vision())	// You can see absolute unit concentrations in transparent containers and % concentrations in opaque containers. You can also see blood types.
		. += "<span class='notice'>It contains:</span>"
		if(!length(reagents.reagent_list))
			. += "<span class='notice'>Nothing.</span>"
			return
		if(container_type & TRANSPARENT)
			for(var/I in reagents.reagent_list)
				var/datum/reagent/R = I
				if(R.id != "blood")
					. += "<span class='notice'>[R.volume] units of [R] ([round(R.volume / one_percent)]%)</span>"
				else
					blood_type = R.data["blood_type"]
					. += "<span class='notice'>[R.volume] units of [R] ([blood_type ? "[blood_type]" : ""]) ([round(R.volume / one_percent)]%)</span>"
			return
		// Opaque containers
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				. += "<span class='notice'>[R] ([round(R.volume / one_percent)]%)</span>"
			else
				blood_type = R.data["blood_type"]
				. += "<span class='notice'>[R] ([blood_type ? "[blood_type]" : ""]) ([round(R.volume / one_percent)]%)</span>"
		return

	if(container_type & TRANSPARENT)
		. += "<span class='notice'>It contains:</span>"
		if(user.reagent_vision())	// You can see absolute unit quantities of reagents in transparent containers.
			for(var/I in reagents.reagent_list)
				var/datum/reagent/R = I
				. += "<span class='notice'>[R.volume] units of [R] ([round(R.volume / one_percent)]%)</span>"
			return

		//Otherwise, just show the total volume
		if(length(reagents?.reagent_list))
			. += "<span class='notice'>[reagents.total_volume] units of various reagents.</span>"
		else
			. += "<span class='notice'>Nothing.</span>"
		return

	if(container_type & AMOUNT_VISIBLE)
		if(reagents.total_volume)
			. += "<span class='notice'>It has [reagents.total_volume] unit\s left.</span>"
		else
			. += "<span class='danger'>It's empty.</span>"

/atom/proc/examine(mob/user, infix = "", suffix = "")
	. = build_base_description(infix, suffix)
	. += build_reagent_description(user)

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

/// Extended description of an object. Allows you to double examine objects and have them give you a second description of an item. Useful for writing flavourful stuff.
/atom/proc/examine_more(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)
	. = list()
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE_MORE, user, .)

/**
 * Updates the appearence of the atom, including text.
 *
 * Mostly delegates to update_name, update_desc, and update_icon
 *
 * Arguments:
 * - updates: A set of bitflags dictating what should be updated. Defaults to [ALL]
 *
 * Supported bitflags: UPDATE_NAME, UPDATE_DESC, UPDATE_ICON
 */
/atom/proc/update_appearance(updates=ALL)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	/// Signal sent should the appearance be updated. This is more broad if listening to a more specific signal doesn't cut it
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_APPEARANCE, updates)
	if(updates & UPDATE_NAME)
		update_name(updates)
	if(updates & UPDATE_DESC)
		update_desc(updates)
	if(updates & UPDATE_ICON)
		update_icon(updates)

/// Updates the name of the atom
/atom/proc/update_name(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_NAME, updates)

/// Updates the description of the atom
/atom/proc/update_desc(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_DESC, updates)

/**
 * Updates the icon and overlays of the atom
 *
 * Mostly delegates to update_icon_state and update_overlays
 *
 * Arguments:
 * - updates: A set of bitflags dictating what should be updated. Defaults to [ALL]
 *
 * Supported bitflags: UPDATE_ICON_STATE, UPDATE_OVERLAYS
 */
/atom/proc/update_icon(updates=ALL)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	if(updates & NONE)
		return // NONE is being sent on purpose, and thus no signal should be sent.

	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON, updates)
	if(updates & UPDATE_ICON_STATE)
		update_icon_state()
		SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)

	if(updates & UPDATE_OVERLAYS)
		var/list/new_overlays = update_overlays(updates)
		if(managed_overlays)
			cut_overlay(managed_overlays)
			managed_overlays = null
		if(length(new_overlays))
			if(length(new_overlays) == 1)
				managed_overlays = new_overlays[1]
			else
				managed_overlays = new_overlays
			add_overlay(new_overlays)

	SEND_SIGNAL(src, COMSIG_ATOM_UPDATED_ICON, updates)

/**
 * Updates the icon state of the atom
 *
 * Excluding the base proc, or child overrides that do not intend to change the icon_state, this proc needs a minimum of two possible icon_states, otherwise it effectively becomes permanent and a redundant proc.
 */
/atom/proc/update_icon_state()
	PROTECTED_PROC(TRUE)
	return

/**
 * Updates the managed overlays of the atom
 *
 * Old overlays from this proc are removed when called, and does not affect overlays from outside it. e.g. add_overlay() called independently in a different proc.
 *
 * It has to return a list of overlays if it can't call the parent to create one. The list can contain anything that would be valid for the add_overlay proc: Images, mutable appearances, icon state names...
 */
/atom/proc/update_overlays()
	PROTECTED_PROC(TRUE)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, .)

/atom/proc/relaymove()
	return

/atom/proc/ex_act()
	return

/atom/proc/blob_act(obj/structure/blob/B)
	SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, B)

/atom/proc/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
	if(reagents)
		reagents.temperature_reagents(exposed_temperature)

// Tool-specific behavior procs. To be overridden in subtypes.
/atom/proc/crowbar_act(mob/living/user, obj/item/I)
	return

/atom/proc/multitool_act(mob/living/user, obj/item/I)
	return

//Check if the multitool has an item in its data buffer
/atom/proc/multitool_check_buffer(user, silent = FALSE)
	if(!silent)
		to_chat(user, "<span class='warning'>[src] has no data buffer!</span>")
	return FALSE

/atom/proc/screwdriver_act(mob/living/user, obj/item/I)
	return

/atom/proc/wrench_act(mob/living/user, obj/item/I)
	return

/atom/proc/wirecutter_act(mob/living/user, obj/item/I)
	return

/atom/proc/welder_act(mob/living/user, obj/item/I)
	return

/atom/proc/hammer_act(mob/living/user, obj/item/I)
	return

/// This is when an atom is emagged. Should return false if it fails, or it has no emag_act defined.
/atom/proc/emag_act(mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_EMAG_ACT, user)
	return FALSE

/atom/proc/unemag()
	return

/atom/proc/cmag_act(mob/user)
	return FALSE

/atom/proc/uncmag()
	return

/**
 * Respond to a radioactive wave hitting this atom
 *
 * This should only be called through the atom/base_rad_act proc
 */
/atom/proc/rad_act(atom/source, amount, emission_type)
	return

/**
* Sends a COMSIG_ATOM_RAD_ACT signal, calls the atoms rad_act with the amount of radiation it should have absorbed and returns the rad insulation of the atom that isappropriate for emission_type
*/
/atom/proc/base_rad_act(atom/source, amount, emission_type)
	switch(emission_type)
		if(ALPHA_RAD)
			. = rad_insulation_alpha
		if(BETA_RAD)
			. = rad_insulation_beta
		if(GAMMA_RAD)
			. = rad_insulation_gamma
	SEND_SIGNAL(src, COMSIG_ATOM_RAD_ACT, amount, emission_type)
	if(amount >= RAD_BACKGROUND_RADIATION)
		rad_act(source, amount * (1 - .), emission_type)

/// Attempt to contaminate a single atom
/atom/proc/contaminate_atom(atom/source, intensity, emission_type)
	if(flags_2 & RAD_NO_CONTAMINATE_2 || (SEND_SIGNAL(src, COMSIG_ATOM_RAD_CONTAMINATING) & COMPONENT_BLOCK_CONTAMINATION))
		return
	AddComponent(/datum/component/radioactive, intensity, source, emission_type)


/atom/proc/fart_act(mob/living/M)
	return FALSE

/atom/proc/rpd_act()
	return

/atom/proc/rpd_blocksusage()
	// Atoms that return TRUE prevent RPDs placing any kind of pipes on their turf.
	return FALSE

/atom/proc/hitby(atom/movable/hitting_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SEND_SIGNAL(src, COMSIG_ATOM_HITBY, hitting_atom, skipcatch, hitpush, blocked, throwingdatum)
	if(density && !has_gravity(hitting_atom)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, PROC_REF(hitby_react), hitting_atom), 2)

/// This proc applies special effects of a carbon mob hitting something, be it a wall, structure, or window. You can set mob_hurt to false to avoid double dipping through subtypes if returning ..()
/atom/proc/hit_by_thrown_mob(mob/living/C, datum/thrownthing/throwingdatum, damage, mob_hurt = FALSE, self_hurt = FALSE)
	return

/atom/proc/hitby_react(atom/movable/AM)
	if(AM && isturf(AM.loc))
		step(AM, turn(AM.dir, 180))


/atom/proc/add_filter(name, priority, list/params)
	LAZYINITLIST(filter_data)
	var/list/p = params.Copy()
	p["priority"] = priority
	filter_data[name] = p
	update_filters()

/atom/proc/update_filters()
	filters = null
	filter_data = sortTim(filter_data, GLOBAL_PROC_REF(cmp_filter_data_priority), TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		filters += filter(arglist(arguments))
	UNSETEMPTY(filter_data)

/atom/proc/transition_filter(name, time, list/new_params, easing = LINEAR_EASING, loop = 1)
	var/filter = get_filter(name)
	if(!filter)
		return

	var/list/old_filter_data = filter_data[name]

	var/list/params = old_filter_data.Copy()
	for(var/thing in new_params)
		params[thing] = new_params[thing]

	animate(filter, new_params, time = time, easing = easing, loop = loop)
	for(var/param in params)
		filter_data[name][param] = params[param]

/atom/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return

	filter_data[name]["priority"] = new_priority
	update_filters()

/obj/item/update_filters()
	. = ..()
	update_action_buttons()

/atom/proc/get_filter(name)
	if(filter_data && filter_data[name])
		return filters[filter_data.Find(name)]

/atom/proc/remove_filter(name_or_names)
	if(!filter_data)
		return

	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/atom/proc/clear_filters()
	filter_data = null
	filters = null

/*
 * Base proc, terribly named but it's all over the code so who cares I guess right?
 *
 * Returns FALSE by default, if a child returns TRUE it is implied that the atom has in
 * some way done a spooky thing. Current usage is so that Boo knows if it needs to cool
 * down or not, but this could be expanded upon if you were a bad enough dude.
 */
/atom/proc/get_spooked()
	return FALSE

/**
	Base proc, intended to be overriden.

	This should only be called from one place: inside the slippery component.
	Called after a human mob slips on this atom.

	If you want the person who slipped to have something special done to them, put it here.
*/
/atom/proc/after_slip(mob/living/carbon/human/H)
	return

/atom/proc/add_hiddenprint(mob/living/M)
	if(isnull(M))
		return
	if(isnull(M.key))
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!istype(H.dna, /datum/dna))
			return FALSE
		if(H.gloves)
			if(fingerprintslast != H.ckey)
				//Add the list if it does not exist.
				if(!fingerprintshidden)
					fingerprintshidden = list()
				fingerprintshidden += "\[[all_timestamps()]\] (Wearing gloves). Real name: [H.real_name], Key: [H.key]"
				fingerprintslast = H.ckey
			return FALSE
		if(!fingerprints)
			if(fingerprintslast != H.ckey)
				//Add the list if it does not exist.
				if(!fingerprintshidden)
					fingerprintshidden = list()
				fingerprintshidden += "\[[all_timestamps()]\] Real name: [H.real_name], Key: [H.key]"
				fingerprintslast = H.ckey
			return TRUE
	else
		if(fingerprintslast != M.ckey)
			//Add the list if it does not exist.
			if(!fingerprintshidden)
				fingerprintshidden = list()
			fingerprintshidden += "\[[all_timestamps()]\] Real name: [M.real_name], Key: [M.key]"
			fingerprintslast = M.ckey
	return


//Set ignoregloves to add prints irrespective of the mob having gloves on.
/atom/proc/add_fingerprint(mob/living/M, ignoregloves = FALSE)
	if(isnull(M))
		return
	if(isnull(M.key))
		return
	if(ishuman(M))
		//Add the list if it does not exist.
		if(!fingerprintshidden)
			fingerprintshidden = list()

		//Fibers~
		add_fibers(M)

		//He has no prints!
		if(HAS_TRAIT(M, TRAIT_NOFINGERPRINTS))
			if(fingerprintslast != M.key)
				fingerprintshidden += "(Has no fingerprints) Real name: [M.real_name], Key: [M.key]"
				fingerprintslast = M.key
			return FALSE		//Now, lets get to the dirty work.
		//First, make sure their DNA makes sense.
		var/mob/living/carbon/human/H = M
		if(!istype(H.dna, /datum/dna) || !H.dna.uni_identity || (length(H.dna.uni_identity) != 32))
			if(!istype(H.dna, /datum/dna))
				H.dna = new /datum/dna(null)
				H.dna.real_name = H.real_name
		H.check_dna()

		//Check if the gloves (if any) hide fingerprints
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.transfer_prints)
				ignoregloves = TRUE

		//Now, deal with gloves.
		if(!ignoregloves)
			if(H.gloves && H.gloves != src)
				if(fingerprintslast != H.ckey)
					fingerprintshidden += "\[[all_timestamps()]\] (Wearing gloves). Real name: [H.real_name], Key: [H.key]"
					fingerprintslast = H.ckey
				return FALSE

		//More adminstuffz
		if(fingerprintslast != H.ckey)
			fingerprintshidden += "\[[all_timestamps()]\] Real name: [H.real_name], Key: [H.key]"
			fingerprintslast = H.ckey

		//Make the list if it does not exist.
		if(!fingerprints)
			fingerprints = list()

		//Hash this shit.
		var/full_print = H.get_full_print()

		// Add the fingerprints
		fingerprints[full_print] = full_print

		return TRUE
	else
		//Smudge up dem prints some
		if(fingerprintslast != M.ckey)
			fingerprintshidden += "\[[all_timestamps()]\] Real name: [M.real_name], Key: [M.key]"
			fingerprintslast = M.ckey

	return

/atom/proc/transfer_fingerprints_to(atom/A)
	// Make sure everything are lists.
	if(!islist(A.fingerprints))
		A.fingerprints = list()
	if(!islist(A.fingerprintshidden))
		A.fingerprintshidden = list()

	if(!islist(fingerprints))
		fingerprints = list()
	if(!islist(fingerprintshidden))
		fingerprintshidden = list()

	// Transfer
	if(fingerprints)
		A.fingerprints |= fingerprints.Copy()            //detective
	if(fingerprintshidden)
		A.fingerprintshidden |= fingerprintshidden.Copy()    //admin
	A.fingerprintslast = fingerprintslast

GLOBAL_LIST_EMPTY(blood_splatter_icons)

//returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(get_blood_id() != "blood")
		return
	return list("ANIMAL DNA" = "Y-")

/mob/living/carbon/get_blood_dna_list()
	if(get_blood_id() != "blood")
		return
	var/list/blood_dna = list()
	if(dna)
		blood_dna[dna.unique_enzymes] = dna.blood_type
	else
		blood_dna["UNKNOWN DNA"] = "X*"
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("UNKNOWN DNA" = "X*")

//to add a mob's dna info into an object's blood_DNA list.
/atom/proc/transfer_mob_blood_dna(mob/living/L)
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return FALSE
	return transfer_blood_dna(new_blood_dna)

/obj/effect/decal/cleanable/blood/splatter/transfer_mob_blood_dna(mob/living/L)
	..(L)
	var/list/b_data = L.get_blood_data(L.get_blood_id())
	if(b_data && !isnull(b_data["blood_color"]))
		basecolor = b_data["blood_color"]
	else
		basecolor = "#A10808"
	update_icon()

/obj/effect/decal/cleanable/blood/footprints/transfer_mob_blood_dna(mob/living/L)
	..(L)
	var/list/b_data = L.get_blood_data(L.get_blood_id())
	if(b_data && !isnull(b_data["blood_color"]))
		basecolor = b_data["blood_color"]
	else
		basecolor = "#A10808"
	update_icon()

//to add blood dna info to the object's blood_DNA list
/atom/proc/transfer_blood_dna(list/blood_dna)
	if(!blood_DNA)
		blood_DNA = list()
	var/old_length = length(blood_DNA)
	blood_DNA |= blood_dna
	if(length(blood_DNA) > old_length)
		return TRUE//some new blood DNA was added

//to add blood from a mob onto something, and transfer their dna info
/atom/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.get_blood_dna_list()
	if(!blood_dna)
		return FALSE
	var/bloodcolor = "#A10808"
	var/list/b_data = M.get_blood_data(M.get_blood_id())
	if(b_data)
		bloodcolor = b_data["blood_color"]

	return add_blood(blood_dna, bloodcolor)

//to add blood onto something, with blood dna info to include.
/atom/proc/add_blood(list/blood_dna, b_color)
	return FALSE

/obj/item/add_blood(list/blood_dna, b_color)
	if(isnull(b_color))
		b_color = "#A10808"
	var/blood_count = !blood_DNA ? 0 : length(blood_DNA)
	if(!transfer_blood_dna(blood_dna))
		return FALSE
	blood_color = b_color // update the blood color
	if(!blood_count) //apply the blood-splatter overlay if it isn't already in there
		add_blood_overlay()
	return TRUE //we applied blood to the item

/*
	* This proc makes src gloves bloody, if you touch something with them you will leave a blood trace

	* blood_dna: list of blood DNAs stored in each atom in blood_DNA variable or in get_blood_dna_list() on carbons
	* b_color: blood color, simple. If there will be null, the blood will be red, otherwise the color you pass
	* amount: amount of "blood charges" you want to give to the gloves, that will be used to make items/walls bloody.
		You can make something bloody this amount - 1 times.
		If this variable will be null, amount will be set randomly from 2 to max_amount
	* max_amount: if amount is not set, amount will be random from 2 to this value, default 4
*/
/obj/item/clothing/gloves/add_blood(list/blood_dna, b_color, amount, max_amount = 4)
	. = ..()
	if(isnull(amount))
		transfer_blood = rand(2, max_amount)
	else
		transfer_blood = max(1, amount)

/turf/add_blood(list/blood_dna, b_color)
	if(isnull(b_color))
		b_color = "#A10808"
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src)
	B.transfer_blood_dna(blood_dna) //give blood info to the blood decal.
	B.basecolor = b_color
	return TRUE //we bloodied the floor

/mob/living/carbon/human/add_blood(list/blood_dna, b_color)
	if(wear_suit)
		wear_suit.add_blood(blood_dna, b_color)
		update_inv_wear_suit()
	else if(w_uniform)
		w_uniform.add_blood(blood_dna, b_color)
		update_inv_w_uniform()
	if(head)
		head.add_blood(blood_dna, b_color)
		update_inv_head()
	if(glasses)
		glasses.add_blood(blood_dna, b_color)
		update_inv_glasses()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood(blood_dna, b_color)
		add_verb(src, /mob/living/carbon/human/proc/bloody_doodle)
	else
		hand_blood_color = b_color
		bloody_hands = rand(2, 4)
		transfer_blood_dna(blood_dna)
		add_verb(src, /mob/living/carbon/human/proc/bloody_doodle)

	update_inv_gloves()	//handles bloody hands overlays and updating
	return TRUE

/obj/item/proc/add_blood_overlay()
	if(initial(icon) && initial(icon_state))
		var/list/params = GLOB.blood_splatter_icons["[blood_color]"]
		if(!params)
			params = layering_filter(icon = icon('icons/effects/blood.dmi', "itemblood"), color = blood_color, blend_mode = BLEND_INSET_OVERLAY)
			GLOB.blood_splatter_icons["[blood_color]"] = params
		add_filter("blood_splatter", 1, params)

/atom/proc/clean_blood(radiation_clean = FALSE)
	germ_level = 0
	if(radiation_clean)
		clean_radiation()
	if(islist(blood_DNA))
		blood_DNA = null
		return TRUE

/**
  * Removes some radiation from an atom
  *
  * Removes a configurable amount of radiation from an atom
  * and stops green glow if radiation gets low enough through it.
  * Arguments:
  * * clean_factor - How much radiation to remove, as a multiple of RAD_BACKGROUND_RADIATION (currently 9)
  */
/atom/proc/clean_radiation(clean_factor = 2)
	var/datum/component/radioactive/healthy_green_glow = GetComponent(/datum/component/radioactive)
	if(!QDELETED(healthy_green_glow))
		healthy_green_glow.alpha_strength = max(0, (healthy_green_glow.alpha_strength - (RAD_BACKGROUND_RADIATION * clean_factor)))
		healthy_green_glow.beta_strength = max(0, (healthy_green_glow.beta_strength - (RAD_BACKGROUND_RADIATION * clean_factor)))
		healthy_green_glow.gamma_strength = max(0, (healthy_green_glow.gamma_strength - (RAD_BACKGROUND_RADIATION * clean_factor)))
		if((healthy_green_glow.alpha_strength + healthy_green_glow.beta_strength + healthy_green_glow.gamma_strength) <= RAD_BACKGROUND_RADIATION)
			healthy_green_glow.RemoveComponent()

/obj/effect/decal/cleanable/blood/clean_blood(radiation_clean = FALSE)
	return // While this seems nonsensical, clean_blood isn't supposed to be used like this on a blood decal.

/obj/item/clean_blood(radiation_clean = FALSE)
	. = ..()
	if(.)
		if(initial(icon) && initial(icon_state))
			remove_filter("blood_splatter")

/obj/item/clothing/gloves/clean_blood(radiation_clean = FALSE)
	. = ..()
	if(.)
		transfer_blood = 0

/obj/item/clothing/shoes/clean_blood(radiation_clean = FALSE)
	..()
	bloody_shoes = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0)
	blood_state = BLOOD_STATE_NOT_BLOODY
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/mob/living/carbon/human/clean_blood(radiation_clean = FALSE, clean_hands = TRUE, clean_mask = TRUE, clean_feet = TRUE)
	if(w_uniform && !(wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT))
		if(w_uniform.clean_blood(radiation_clean))
			update_inv_w_uniform()
	if(gloves && !(wear_suit && wear_suit.flags_inv & HIDEGLOVES))
		if(gloves.clean_blood(radiation_clean))
			update_inv_gloves()
			gloves.germ_level = 0
			clean_hands = FALSE
	if(shoes && !(wear_suit && wear_suit.flags_inv & HIDESHOES))
		if(shoes.clean_blood(radiation_clean))
			update_inv_shoes()
			clean_feet = FALSE
	if(s_store && !(wear_suit && wear_suit.flags_inv & HIDESUITSTORAGE))
		if(s_store.clean_blood(radiation_clean))
			update_inv_s_store()
	if(lip_style && !(head && head.flags_inv & HIDEMASK))
		lip_style = null
		update_body()
	if(glasses && !(wear_mask && wear_mask.flags_inv & HIDEEYES))
		if(glasses.clean_blood(radiation_clean))
			update_inv_glasses()
	if(l_ear && !(wear_mask && wear_mask.flags_inv & HIDEEARS))
		if(l_ear.clean_blood(radiation_clean))
			update_inv_ears()
	if(r_ear && !(wear_mask && wear_mask.flags_inv & HIDEEARS))
		if(r_ear.clean_blood(radiation_clean))
			update_inv_ears()
	if(belt)
		if(belt.clean_blood(radiation_clean))
			update_inv_belt()
	if(neck)
		if(neck.clean_blood(radiation_clean))
			update_inv_neck()
	..(clean_hands, clean_mask, clean_feet)
	update_icons()	//apply the now updated overlays to the mob

/atom/proc/add_vomit_floor(toxvomit = FALSE, green = FALSE, type_override)
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	if(!isspaceturf(src))
		var/type = green ? /obj/effect/decal/cleanable/vomit/green : /obj/effect/decal/cleanable/vomit
		var/vomit_reagent = green ? "green_vomit" : "vomit"
		if(type_override)
			type = type_override
		for(var/obj/effect/decal/cleanable/vomit/V in get_turf(src))
			if(V.type == type)
				V.reagents.add_reagent(vomit_reagent, 5)
				return

		var/obj/effect/decal/cleanable/vomit/this = new type(get_turf(src))
		if(!this.gravity_check)
			this.newtonian_move(dir)

		// Make toxins vomit look different
		if(toxvomit)
			this.icon_state = "vomittox_[pick(1, 4)]"

/atom/proc/get_global_map_pos()
	if(!islist(GLOB.global_map) || isemptylist(GLOB.global_map))
		return
	var/cur_x = null
	var/cur_y = null
	var/list/y_arr = null
	for(cur_x in 1 to length(GLOB.global_map))
		y_arr = GLOB.global_map[cur_x]
		cur_y = y_arr.Find(src.z)
		if(cur_y)
			break
//	to_chat(world, "X = [cur_x]; Y = [cur_y]")
	if(cur_x && cur_y)
		return list("x" = cur_x, "y" = cur_y)
	else
		return null

// Used to provide overlays when using this atom as a viewing focus
// (cameras, locker tint, etc.)
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

//the sight changes to give to the mob whose perspective is set to that atom (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
/atom/proc/update_remote_sight(mob/living/user)
	user.sync_lighting_plane_alpha()
	return

/atom/proc/checkpass(passflag)
	return pass_flags & passflag

/atom/proc/isinspace()
	if(isspaceturf(get_turf(src)))
		return TRUE
	else
		return FALSE

/atom/proc/handle_fall()
	return

/atom/proc/singularity_act()
	return

/atom/proc/singularity_pull(obj/singularity/S, current_size)
	SEND_SIGNAL(src, COMSIG_ATOM_SING_PULL, S, current_size)

/**
  * Respond to acid being used on our atom
  *
  * Default behaviour is to send COMSIG_ATOM_ACID_ACT and return
  */
/atom/proc/acid_act(acidpwr, acid_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_ACID_ACT, acidpwr, acid_volume)

/atom/proc/narsie_act()
	return

/**
 * Respond to an electric bolt action on our item
 *
 * Default behaviour is to return, we define here to allow for cleaner code later on
 */
/atom/proc/zap_act(power, zap_flags)
	return

/atom/proc/handle_ricochet(obj/item/projectile/ricocheting_projectile)
	var/turf/p_turf = get_turf(ricocheting_projectile)
	var/face_direction = get_dir(src, p_turf) || get_dir(src, ricocheting_projectile)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (ricocheting_projectile.Angle + 180))
	var/a_incidence_s = abs(incidence_s)
	if(a_incidence_s > 90 && a_incidence_s < 270)
		return FALSE
	if((ricocheting_projectile.flag in list(BULLET, BOMB)) && ricocheting_projectile.ricochet_incidence_leeway)
		if((a_incidence_s < 90 && a_incidence_s < 90 - ricocheting_projectile.ricochet_incidence_leeway) || (a_incidence_s > 270 && a_incidence_s -270 > ricocheting_projectile.ricochet_incidence_leeway))
			return FALSE
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	ricocheting_projectile.set_angle(new_angle_s)
	return TRUE

//This proc is called on the location of an atom when the atom is Destroy()'d
/atom/proc/handle_atom_del(atom/A)
	return

/atom/proc/atom_say(message)
	if(!message)
		return
	var/list/speech_bubble_hearers = list()
	for(var/mob/M as anything in get_mobs_in_view(7, src, ai_eyes=AI_EYE_REQUIRE_HEAR))
		M.show_message("<span class='game say'><span class='name'>[src]</span> [atom_say_verb], \"[message]\"</span>", 2, null, 1)
		if(M.client)
			speech_bubble_hearers += M.client

		if((M.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) && M.can_hear())
			M.create_chat_message(src, message)

	if(length(speech_bubble_hearers))
		var/image/I = image('icons/mob/talk.dmi', src, "[bubble_icon][say_test(message)]", FLY_LAYER)
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay), I, speech_bubble_hearers, 30)

/atom/proc/atom_emote(emote)
	if(!emote)
		return
	visible_message("<span class='game emote'><span class='name'>[src]</span> [emote]</span>", "<span class='game emote'>You hear how something [emote]</span>")

	runechat_emote(src, emote)

/atom/proc/speech_bubble(bubble_state = "", bubble_loc = src, list/bubble_recipients = list())
	return

/atom/proc/AllowDrop()
	return FALSE

/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : get_turf(L)

/atom/Entered(atom/movable/AM, atom/oldLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, oldLoc)

/**
 * An atom is attempting to exit this atom's contents
 *
 * Default behaviour is to send the [COMSIG_ATOM_EXIT]
 */
/atom/Exit(atom/movable/leaving, direction)
	// Don't call `..()` here, otherwise `Uncross()` gets called.
	// See the doc comment on `Uncross()` to learn why this is bad.

	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, leaving, direction) & COMPONENT_ATOM_BLOCK_EXIT)
		return FALSE

	return TRUE

/atom/Exited(atom/movable/AM, direction)
	var/new_loc = get_step(AM, direction)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, new_loc)

/*
	Adds an instance of colour_type to the atom's atom_colours list
*/
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !length(atom_colours))
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > length(atom_colours))
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()

/*
	Removes an instance of colour_type from the atom's atom_colours list
*/
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(colour_priority > length(atom_colours))
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()

/*
	Resets the atom's color to null, and then sets it to the highest priority
	colour available
*/
/atom/proc/update_atom_colour()
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	color = null
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(length(L))
				color = L
				return
		else if(C)
			color = C
			return

/** Call this when you want to present a renaming prompt to the user.

	It's a simple proc, but handles annoying edge cases such as forgetting to add a "cancel" button,
	or being able to rename stuff remotely.

	Arguments:
	* user - the renamer.
	* implement - the tool doing the renaming (usually, a pen).
	* use_prefix - whether the new name should follow the format of "thing - user-given label" or
		if we allow to change the name completely arbitrarily.
	* actually_rename - whether we want to really change the `src.name`, or if we want to do everything *except* that.
	* prompt - a custom "what do you want rename this thing to be?" prompt shown in the inpit box.

	Returns: Either null if the renaming was aborted, or the user-provided sanitized string.
 **/
/atom/proc/rename_interactive(mob/user, obj/implement = null, use_prefix = TRUE,
		actually_rename = TRUE, prompt = null)
	// Sanity check that the user can, indeed, rename the thing.
	// This, sadly, means you can't rename things with a telekinetic pen, but that's
	// too much of a hassle to make work nicely.
	if((implement && implement.loc != user) || !in_range(src, user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return null

	var/prefix = ""
	if(use_prefix)
		prefix = "[initial(name)] - "

	var/default_value
	if(!use_prefix)
		default_value = name
	else if(findtext(name, prefix) != 0)
		default_value = copytext_char(name, length_char(prefix) + 1)
	else
		// Either the thing has a non-conforming name due to being set in the map
		// OR (much more likely) the thing is unlabeled yet.
		default_value = ""
	if(!prompt)
		prompt = "What would you like the label on [src] to be?"

	var/t = input(user, prompt, "Renaming [src]", default_value)  as text | null
	if(isnull(t))
		// user pressed Cancel
		return null

	// Things could have changed between when `input` is called and when it returns.
	if(!user)
		return null
	else if(implement && implement.loc != user)
		to_chat(user, "<span class='warning'>You no longer have the pen to rename [src].</span>")
		return null
	else if(!in_range(src, user))
		to_chat(user, "<span class='warning'>You cannot rename [src] from here.</span>")
		return null
	else if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You cannot rename [src] in your current state.</span>")
		return null


	t = sanitize(copytext_char(t, 1, MAX_NAME_LEN))

	// Logging
	var/logged_name = initial(name)
	if(t)
		logged_name = "[use_prefix ? "[prefix][t]" : t]"
	investigate_log("[key_name(user)] ([ADMIN_FLW(user,"FLW")]) renamed \"[src]\" ([ADMIN_VV(src, "VV")]) as \"[logged_name]\".", INVESTIGATE_RENAME)

	if(actually_rename)
		if(t == "")
			name = "[initial(name)]"
		else
			name = "[prefix][t]"
	return t

/atom/proc/set_angle(degrees)
	var/matrix/M = matrix()
	M.Turn(degrees)
	// If we aint 0, make it NN transform
	if(degrees)
		appearance_flags |= PIXEL_SCALE
	transform = M

/*
	Setter for the `density` variable.
	Arguments:
	* new_value - the new density you would want it to set.
	Returns: Either null if identical to existing density, or the new density if different.
*/
/atom/proc/set_density(new_value)
	if(density == new_value)
		return
	. = density
	density = new_value


/**
 * This proc is used for telling whether something can pass by this atom in a given direction, for use by the pathfinding system.
 *
 * Trying to generate one long path across the station will call this proc on every single object on every single tile that we're seeing if we can move through, likely
 * multiple times per tile since we're likely checking if we can access said tile from multiple directions, so keep these as lightweight as possible.
 *
 * For turfs this will only be used if pathing_pass_method is TURF_PATHING_PASS_PROC
 *
 * Arguments:
 * * to_dir - What direction we're trying to move in, relevant for things like directional windows that only block movement in certain directions
 * * pass_info - Datum that stores info about the thing that's trying to pass us
 *
 * IMPORTANT NOTE: /turf/proc/LinkBlockedWithAccess assumes that overrides of CanPathfindPass will always return true if density is FALSE
 * If this is NOT you, ensure you edit your can_pathfind_pass variable. Check __DEFINES/path.dm
 **/
/atom/proc/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	if(pass_info.pass_flags & pass_flags_self)
		return TRUE
	. = !density


/atom/proc/atom_prehit(obj/item/projectile/P)
	return SEND_SIGNAL(src, COMSIG_ATOM_PREHIT, P)

/// Passes Stat Browser Panel clicks to the game and calls client click on an atom
/atom/Topic(href, list/href_list)
	. = ..()
	if(!usr?.client)
		return

	if(href_list["statpanel_item_click"])
		var/client/usr_client = usr.client
		var/list/paramslist = list()
		switch(href_list["statpanel_item_click"])
			if("left")
				paramslist[LEFT_CLICK] = "1"
			if("right")
				paramslist[RIGHT_CLICK] = "1"
			if("middle")
				paramslist[MIDDLE_CLICK] = "1"
			else
				return

		if(href_list["statpanel_item_shiftclick"])
			paramslist[SHIFT_CLICK] = "1"
		if(href_list["statpanel_item_ctrlclick"])
			paramslist[CTRL_CLICK] = "1"
		if(href_list["statpanel_item_altclick"])
			paramslist[ALT_CLICK] = "1"

		var/mouseparams = list2params(paramslist)
		usr_client.Click(src, loc, null, mouseparams)
		return TRUE

/**
 * A special case of relaymove() in which the person relaying the move may be "driving" this atom
 *
 * This is a special case for vehicles and ridden animals where the relayed movement may be handled
 * by the riding component attached to this atom. Returns TRUE as long as there's nothing blocking
 * the movement, or FALSE if the signal gets a reply that specifically blocks the movement
 */
/atom/proc/relaydrive(mob/living/user, direction)
	return !(SEND_SIGNAL(src, COMSIG_RIDDEN_DRIVER_MOVE, user, direction) & COMPONENT_DRIVER_BLOCK_MOVE)

/// Used with the spawner component to do something when a mob is spawned.
/atom/proc/on_mob_spawn(mob/created_mob)
	return

///Returns the src and all recursive contents as a list.
/atom/proc/get_all_contents()
	. = list(src)
	var/i = 0
	while(i < length(.))
		var/atom/checked_atom = .[++i]
		. += checked_atom.contents

/atom/proc/store_last_attacker(mob/living/attacker, obj/item/weapon)
	if(!attack_info)
		attack_info = new
	attack_info.last_attacker_name = attacker.real_name
	attack_info.last_attacker_ckey = attacker.ckey
	if(istype(weapon))
		attack_info.last_attacker_weapon = "[weapon] ([weapon.type])"

// MARK: PTL PROCS

// Called when the target is selected
/atom/proc/on_ptl_target(obj/machinery/power/transmission_laser/ptl)
	if(ptl.firing)
		on_ptl_fire()
	return

// Called for each process of the PTL
/atom/proc/on_ptl_tick(obj/machinery/power/transmission_laser/ptl, output_level)
	return

// Called when no longer targeted by the ptl
/atom/proc/on_ptl_untarget(obj/machinery/power/transmission_laser/ptl)
	return

// Called when the PTL starts firing on the target
/atom/proc/on_ptl_fire(obj/machinery/power/transmission_laser/ptl)
	return

// Called when the PTL stops firing on the target
/atom/proc/on_ptl_stop(obj/machinery/power/transmission_laser/ptl)
	return

// Used in the PTL ui
/atom/proc/ptl_data()
	return name

// Called if an atom untargets itself
/atom/proc/untarget_self(obj/machinery/power/transmission_laser/ptl)
	on_ptl_untarget(ptl)
	if(ptl)
		ptl.target = null
	return

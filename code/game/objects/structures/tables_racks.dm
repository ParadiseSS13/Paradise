/* Tables and Racks
 * Contains:
 *		Tables
 *		Glass Tables
 *		Wooden Tables
 *		Reinforced Tables
 *		Racks
 *		Rack Parts
 */

// MARK: Table
/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/smooth_structures/tables/table.dmi'
	icon_state = "table-0"
	base_icon_state = "table"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	pass_flags_self = LETPASSTHROW | PASSTAKE
	climbable = TRUE
	max_integrity = 100
	integrity_failure = 30
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_TABLES)
	creates_cover = TRUE
	var/frame = /obj/structure/table_frame
	var/framestack = /obj/item/stack/rods
	var/buildstack = /obj/item/stack/sheet/metal
	var/busy = FALSE
	var/buildstackamount = 1
	var/framestackamount = 2
	var/deconstruction_ready = TRUE
	var/flipped = FALSE
	///If this is true, the table will have items slide off it when placed.
	var/slippery = FALSE
	/// The minimum level of environment_smash required for simple animals to be able to one-shot this.
	var/minimum_env_smash = ENVIRONMENT_SMASH_WALLS
	/// Can this table be flipped?
	var/can_be_flipped = TRUE
	var/flipped_table_icon_base = "table"

/obj/structure/table/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_atom_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	if(flipped)
		update_icon()

/obj/structure/table/examine(mob/user)
	. = ..()
	. += deconstruction_hints(user)
	if(can_be_flipped)
		if(flipped)
			. += "<span class='notice'><b>Alt-Shift-Click</b> to right the table again.</span>"
		else
			. += "<span class='notice'><b>Alt-Shift-Click</b> to flip over the table.</span>"

/obj/structure/table/proc/deconstruction_hints(mob/user)
	return "<span class='notice'>The top is <b>screwed</b> on, but the main <b>bolts</b> are also visible.</span>"

/obj/structure/table/update_icon(updates=ALL)
	. = ..()
	update_smoothing()

/obj/structure/table/update_icon_state()
	if((smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)) && !flipped)
		icon_state = ""

	if(flipped)
		var/type = 0
		var/subtype = null
		for(var/direction in list(turn(dir,90), turn(dir,-90)))
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,direction))
			if(T && T.flipped)
				type++
				if(type == 1)
					subtype = direction == turn(dir,90) ? "-" : "+"
		icon_state = "[flipped_table_icon_base]flip[type][type == 1 ? subtype : ""]"

/obj/structure/table/proc/update_smoothing()
	if((smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)) && !flipped)
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

	if(flipped)
		clear_smooth_overlays()

// Need to override this to allow flipped tables to be mapped in without the smoothing subsystem resetting the icon_state
/obj/structure/table/set_smoothed_icon_state(new_junction)
	if(flipped)
		return
	..()

/obj/structure/table/flipped
	icon_state = "tableflip0"
	flipped = TRUE

/obj/structure/table/narsie_act()
	new /obj/structure/table/reinforced/cult(loc)
	qdel(src)

/obj/structure/table/start_climb(mob/living/user)
	. = ..()
	item_placed(user)

/obj/structure/table/attack_hand(mob/living/user)
	..()
	if(length(climbers))
		for(var/mob/living/climber as anything in climbers)
			climber.Weaken(4 SECONDS)
			climber.visible_message("<span class='warning'>[climber.name] has been knocked off the table", "You've been knocked off the table", "You hear [climber.name] get knocked off the table</span>")
	else if(Adjacent(user) && user.pulling && user.pulling.pass_flags & PASSTABLE)
		user.Move_Pulled(src)
		if(user.pulling.loc == loc)
			user.visible_message("<span class='notice'>[user] places [user.pulling] onto [src].</span>",
				"<span class='notice'>You place [user.pulling] onto [src].</span>")
			user.stop_pulling()

/obj/structure/table/attack_tk() // no telehulk sorry
	return

/obj/structure/table/proc/item_placed(item)
	return

/obj/structure/table/CanPass(atom/movable/mover, border_dir)
	if(istype(mover,/obj/item/projectile))
		return check_cover(mover, border_dir)

	var/mob/living/living_mover = mover
	if(istype(living_mover) && (HAS_TRAIT(living_mover, TRAIT_FLYING) || (IS_HORIZONTAL(living_mover) && HAS_TRAIT(living_mover, TRAIT_CONTORTED_BODY))))
		return TRUE
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(mover.throwing)
		return TRUE
	if(length(get_atoms_of_type(get_turf(mover), /obj/structure/table) - mover))
		var/obj/structure/table/T = locate(/obj/structure/table) in get_turf(mover)
		if(!T.flipped)
			return TRUE
	if(flipped)
		if(border_dir == dir)
			return !density
		else
			return TRUE
	return FALSE

/obj/structure/table/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	. = !density
	if(pass_info.is_movable)
		. = . || pass_info.pass_flags & PASSTABLE

/**
 * Determines whether a projectile crossing our turf should be stopped.
 * Return FALSE to stop the projectile.
 *
 * Arguments:
 * * P - The projectile trying to cross.
 * * proj_dir - The incoming direction of the projectile.
 */
/obj/structure/table/proc/check_cover(obj/item/projectile/P, proj_dir)
	. = TRUE
	if(!flipped)
		return
	if(get_dist(P.starting, loc) <= 1) // Tables won't help you if people are THIS close
		return
	if(proj_dir != dir) // Back/side shots may pass
		return
	if(prob(40))
		return FALSE // Blocked

/obj/structure/table/proc/on_atom_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER // COMSIG_ATOM_EXIT

	if(istype(leaving) && leaving.checkpass(PASSTABLE))
		return

	if(flipped)
		if(direction == dir && density)
			return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/table/MouseDrop_T(obj/O, mob/user)
	if(..())
		return TRUE
	if((!isitem(O) || user.get_active_hand() != O))
		return
	if(isrobot(user))
		return
	if(!user.drop_item())
		return
	if(O.loc != src.loc)
		step(O, get_dir(O, src))
		return TRUE

/obj/structure/table/proc/tablepush(obj/item/grab/G, mob/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='danger'>Throwing [G.affecting] onto the table might hurt them!</span>")
		return
	if(get_dist(src, user) < 2)
		if(G.affecting.buckled)
			to_chat(user, "<span class='warning'>[G.affecting] is buckled to [G.affecting.buckled]!</span>")
			return FALSE
		if(G.state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return FALSE
		if(!G.confirm())
			return FALSE
		var/blocking_object = density_check()
		if(blocking_object)
			to_chat(user, "<span class='warning'>You cannot do this there is \a [blocking_object] in the way!</span>")
			return FALSE
		G.affecting.forceMove(get_turf(src))
		G.affecting.Weaken(4 SECONDS)
		item_placed(G.affecting)
		G.affecting.visible_message("<span class='danger'>[G.assailant] pushes [G.affecting] onto [src].</span>", \
									"<span class='userdanger'>[G.assailant] pushes [G.affecting] onto [src].</span>")
		add_attack_logs(G.assailant, G.affecting, "Pushed onto a table")
		qdel(G)
		return TRUE
	qdel(G)

/obj/structure/table/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I, /obj/item/grab))
		tablepush(I, user)
		return ITEM_INTERACT_COMPLETE

	if(I.is_robot_module())
		return ..()

	if(user.a_intent == INTENT_HELP && !(I.flags & ABSTRACT))
		if(user.drop_item())
			I.Move(loc)
			//Center the icon where the user clicked.
			if(!modifiers || !modifiers["icon-x"] || !modifiers["icon-y"])
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = clamp(text2num(modifiers["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = clamp(text2num(modifiers["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
			if(slippery)
				step_away(I, user)
				visible_message("<span class='warning'>[I] slips right off [src]!</span>")
				playsound(loc, 'sound/misc/slip.ogg', 50, TRUE, -1)
			else //Don't want slippery moving tables to have the item attached to them if it slides off.
				item_placed(I)
		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/structure/table/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(. && M.environment_smash >= minimum_env_smash)
		deconstruct(FALSE)
		M.visible_message("<span class='danger'>[M] smashes [src]!</span>", "<span class='notice'>You smash [src].</span>")

/obj/structure/table/shove_impact(mob/living/target, mob/living/attacker)
	if(locate(/obj/structure/table) in get_turf(target))
		return FALSE
	if(flipped)
		return FALSE
	var/pass_flags_cache = target.pass_flags
	target.pass_flags |= PASSTABLE
	if(target.Move(loc))
		. = TRUE
		target.Weaken(4 SECONDS)
		add_attack_logs(attacker, target, "pushed onto [src]", ATKLOG_ALL)
	else
		. = FALSE
	target.pass_flags = pass_flags_cache

/obj/structure/table/screwdriver_act(mob/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	if(!deconstruction_ready)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume) && deconstruction_ready)
		deconstruct(TRUE)
		TOOL_DISMANTLE_SUCCESS_MESSAGE

/obj/structure/table/wrench_act(mob/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	if(!deconstruction_ready)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume) && deconstruction_ready)
		deconstruct(TRUE, 1)
		TOOL_DISMANTLE_SUCCESS_MESSAGE

/obj/structure/table/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags & NODECONSTRUCT))
		var/turf/T = get_turf(src)
		new buildstack(T, buildstackamount)
		if(!wrench_disassembly)
			new frame(T)
		else
			new framestack(T, framestackamount)
	qdel(src)

/obj/structure/table/proc/straight_table_check(direction)
	var/obj/structure/table/T
	for(var/angle in list(-90,90))
		T = locate() in get_step(loc,turn(direction,angle))
		if(T && !T.flipped)
			return 0
	T = locate() in get_step(loc,direction)
	if(!T || T.flipped)
		return 1
	if(istype(T,/obj/structure/table/reinforced/))
		if(!T.deconstruction_ready)
			return 0
	return T.straight_table_check(direction)

/obj/structure/table/AltShiftClick(mob/living/carbon/human/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || !can_be_flipped || is_ventcrawling(user))
		return

	var/flip_speed = get_flip_speed(user)

	if(!flipped)

		if(flip_speed > 0)
			user.visible_message("<span class='warning'>[user] starts trying to flip [src]!</span>", "<span class='warning'>You start trying to flip [src][flip_speed >= 5 SECONDS ? " (it'll take about [flip_speed / 10] seconds)." : ""].</span>")
			if(!do_after(user, flip_speed, TRUE, src))
				user.visible_message("<span class='notice'>[user] gives up on trying to flip [src].</span>")
				return
		if(!flip(get_cardinal_dir(user, src)))
			to_chat(user, "<span class='notice'>It won't budge.</span>")
			return


		user.visible_message("<span class='warning'>[user] flips [src]!</span>")

		if(climbable)
			structure_shaken()
	else
		if(flip_speed > 0)
			user.visible_message("<span class='warning'>[user] starts trying to right [src]!</span>", "<span class='warning'>You start trying to right [src][flip_speed >= 5 SECONDS ? " (it'll take about [flip_speed / 10] seconds)." : ""]</span>")
			if(!do_after(user, flip_speed, TRUE, src))
				user.visible_message("<span class='notice'>[user] gives up on trying to right [src].</span>")
				return
		if(!unflip())
			to_chat(user, "<span class='notice'>It won't budge.</span>")
		user.visible_message("<span class='warning'>[user] rights [src]!</span>")

/obj/structure/table/proc/get_flip_speed(mob/living/flipper)
	if(!istype(flipper))
		return 0 SECONDS // sure
	if(!isanimal_or_basicmob(flipper))
		return 0 SECONDS
	if(istype(flipper, /mob/living/simple_animal/revenant))
		return 0 SECONDS  // funny ghost table
	switch(flipper.mob_size)
		if(MOB_SIZE_TINY)
			return 30 SECONDS  // you can do it but you gotta *really* work for it
		if(MOB_SIZE_SMALL)
			return 5 SECONDS  // not gonna terrorize anything
		else
			return 0 SECONDS


/obj/structure/table/proc/flip(direction)
	if(flipped)
		return 0

	if(!straight_table_check(turn(direction, 90)) || !straight_table_check(turn(direction, -90)))
		return FALSE

	dir = direction
	if(dir != NORTH)
		layer = 5

	var/list/targets = list(get_step(src, dir), get_step(src, turn(dir, 45)), get_step(src, turn(dir, -45)))
	for(var/atom/movable/A in get_turf(src))
		if(isobserver(A))
			continue
		if(!A.anchored)
			INVOKE_ASYNC(A, TYPE_PROC_REF(/atom/movable/, throw_at), pick(targets), 1, 1)

	flipped = TRUE
	smoothing_flags = NONE
	flags |= ON_BORDER
	for(var/D in list(turn(direction, 90), turn(direction, -90)))
		if(locate(/obj/structure/table, get_step(src, D)))
			var/obj/structure/table/T = locate(/obj/structure/table, get_step(src, D))
			T.flip(direction)
	update_icon()

	creates_cover = FALSE
	if(isturf(loc))
		REMOVE_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))

	return TRUE

/obj/structure/table/proc/unflip()
	if(!flipped)
		return 0

	var/can_flip = 1
	for(var/mob/A in oview(src,0))//loc)
		if(istype(A))
			can_flip = 0
	if(!can_flip)
		return 0

	layer = initial(layer)
	flipped = FALSE
	// Initial smoothing flags doesn't add the required SMOOTH_OBJ flag, thats done on init
	smoothing_flags = initial(smoothing_flags) | SMOOTH_OBJ
	flags &= ~ON_BORDER
	for(var/D in list(turn(dir, 90), turn(dir, -90)))
		if(locate(/obj/structure/table,get_step(src,D)))
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,D))
			T.unflip()
	update_icon()

	creates_cover = TRUE
	if(isturf(loc))
		ADD_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))

	return 1

/obj/structure/table/water_act(volume, temperature, source, method)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_OIL_SLICKED))
		slippery = initial(slippery)
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
		REMOVE_TRAIT(src, TRAIT_OIL_SLICKED, "potion")

// MARK: Glass tables
/obj/structure/table/glass
	name = "glass table"
	desc = "Looks fragile. You should totally flip it. It is begging for it."
	icon = 'icons/obj/smooth_structures/tables/glass_table.dmi'
	icon_state = "glass_table-0"
	base_icon_state = "glass_table"
	buildstack = /obj/item/stack/sheet/glass
	smoothing_groups = list(SMOOTH_GROUP_GLASS_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_GLASS_TABLES)
	max_integrity = 70
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 80, ACID = 100)
	minimum_env_smash = ENVIRONMENT_SMASH_STRUCTURES
	var/list/debris = list()
	var/shardtype = /obj/item/shard

/obj/structure/table/glass/Initialize(mapload)
	. = ..()
	debris += new frame
	debris += new shardtype
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/glass/Destroy()
	for(var/i in debris)
		qdel(i)
	. = ..()

/obj/structure/table/glass/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	if(flags & NODECONSTRUCT)
		return
	if(!isliving(entered))
		return
	var/mob/living/L = entered
	if(L.incorporeal_move || HAS_TRAIT(L, TRAIT_FLYING) || L.floating)
		return

	// Don't break if they're just flying past
	if(entered.throwing)
		addtimer(CALLBACK(src, PROC_REF(throw_check), entered), 5)
	else
		check_break(entered)

/obj/structure/table/glass/proc/throw_check(mob/living/M)
	if(M.loc == get_turf(src))
		check_break(M)

/obj/structure/table/glass/proc/check_break(mob/living/M)
	if(has_gravity(M) && M.mob_size > MOB_SIZE_SMALL)
		if(M.buckled && HAS_TRAIT(M.buckled, TRAIT_NO_BREAK_GLASS_TABLES))
			return
		table_shatter(M)

/obj/structure/table/glass/flip(direction)
	deconstruct(FALSE)

/obj/structure/table/glass/proc/table_shatter(mob/living/L)
	visible_message("<span class='warning'>[src] breaks!</span>",
		"<span class='danger'>You hear breaking glass.</span>")
	var/turf/T = get_turf(src)
	playsound(T, "shatter", 50, 1)
	for(var/I in debris)
		var/atom/movable/AM = I
		AM.forceMove(T)
		debris -= AM
		if(istype(AM, /obj/item/shard))
			AM.throw_impact(L)
	L.Weaken(10 SECONDS)
	qdel(src)

/obj/structure/table/glass/shove_impact(mob/living/target, mob/living/attacker)
	var/pass_flags_cache = target.pass_flags
	target.pass_flags |= PASSTABLE
	if(target.Move(loc)) // moving onto a table smashes it, stunning them
		. = TRUE
		add_attack_logs(attacker, target, "pushed onto [src]", ATKLOG_ALL)
	else
		. = FALSE
	target.pass_flags = pass_flags_cache

/obj/structure/table/glass/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			..()
			return
		else
			var/turf/T = get_turf(src)
			playsound(T, "shatter", 50, TRUE)
			for(var/X in debris)
				var/atom/movable/AM = X
				AM.forceMove(T)
				debris -= AM
	qdel(src)

/obj/structure/table/glass/plasma
	name = "plasma glass table"
	desc = "A table made from the blood, sweat, and tears of miners."
	icon = 'icons/obj/smooth_structures/tables/plasmaglass_table.dmi'
	icon_state = "plasmaglass_table-0"
	base_icon_state = "plasmaglass_table"
	buildstack = /obj/item/stack/sheet/plasmaglass
	max_integrity = 140
	shardtype = /obj/item/shard/plasma
	minimum_env_smash = ENVIRONMENT_SMASH_RWALLS

/obj/structure/table/glass/reinforced
	name = "reinforced glass table"
	desc = "Looks robust. You should totally flip it. It is begging for it."
	icon = 'icons/obj/smooth_structures/tables/rglass_table.dmi'
	icon_state = "rglass_table-0"
	base_icon_state = "rglass_table"
	buildstack = /obj/item/stack/sheet/rglass
	max_integrity = 100
	integrity_failure = 50
	deconstruction_ready = FALSE
	armor = list(MELEE = 10, BULLET = 30, LASER = 30, ENERGY = 100, BOMB = 20, RAD = 0, FIRE = 80, ACID = 70)
	smoothing_groups = list(SMOOTH_GROUP_REINFORCED_TABLES)
	minimum_env_smash = ENVIRONMENT_SMASH_RWALLS
	canSmoothWith = list(SMOOTH_GROUP_REINFORCED_TABLES)

/obj/structure/table/glass/reinforced/deconstruction_hints(mob/user) //look, it was either copy paste these 4 procs, or copy paste all of the glass stuff
	if(deconstruction_ready)
		to_chat(user, "<span class='notice'>The top cover has been <i>welded</i> loose and the main frame's <b>bolts</b> are exposed.</span>")
	else
		to_chat(user, "<span class='notice'>The top cover is firmly <b>welded</b> on.</span>")

/obj/structure/table/glass/reinforced/flip(direction)
	if(!deconstruction_ready)
		return FALSE
	else
		return ..()

/obj/structure/table/glass/reinforced/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You start [deconstruction_ready ? "strengthening" : "weakening"] the reinforced table...</span>")
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You [deconstruction_ready ? "strengthen" : "weaken"] the table.</span>")
		deconstruction_ready = !deconstruction_ready

/obj/structure/table/glass/reinforced/shove_impact(mob/living/target, mob/living/attacker)
	if(locate(/obj/structure/table) in get_turf(target))
		return FALSE
	var/pass_flags_cache = target.pass_flags
	target.pass_flags |= PASSTABLE
	if(target.Move(loc))
		. = TRUE
		target.Weaken(4 SECONDS)
		add_attack_logs(attacker, target, "pushed onto [src]", ATKLOG_ALL)
	else
		. = FALSE
	target.pass_flags = pass_flags_cache

/obj/structure/table/glass/reinforced/check_break(mob/living/M)
	if(has_gravity(M) && M.mob_size > MOB_SIZE_SMALL && (obj_integrity < (max_integrity / 2))) //big tables for big boys, only breaks under 50% hp
		table_shatter(M)

/obj/structure/table/glass/reinforced/plasma
	name = "reinforced plasma glass table"
	desc = "Seems a bit overkill for a table."
	icon = 'icons/obj/smooth_structures/tables/rplasmaglass_table.dmi'
	icon_state = "rplasmaglass_table-0"
	base_icon_state = "rplasmaglass_table"
	buildstack = /obj/item/stack/sheet/plasmarglass
	max_integrity = 180
	shardtype = /obj/item/shard/plasma

/obj/structure/table/glass/reinforced/titanium
	name = "reinforced titanium glass table"
	desc = "A very sleek looking glass table, neat!"
	icon = 'icons/obj/smooth_structures/tables/titaniumglass_table.dmi'
	icon_state = "titaniumglass_table-0"
	base_icon_state = "titaniumglass_table"
	buildstack = /obj/item/stack/sheet/titaniumglass
	max_integrity = 180

/obj/structure/table/glass/reinforced/plastitanium
	name = "reinforced plastitanium glass table"
	desc = "The mother of all glass tables."
	icon = 'icons/obj/smooth_structures/tables/plastitaniumglass_table.dmi'
	icon_state = "plastitaniumglass_table-0"
	base_icon_state = "plastitaniumglass_table"
	buildstack = /obj/item/stack/sheet/plastitaniumglass
	max_integrity = 200

// MARK: Wooden tables
/obj/structure/table/wood
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'icons/obj/smooth_structures/tables/wood_table.dmi'
	icon_state = "wood_table-0"
	base_icon_state = "wood_table"
	flipped_table_icon_base = "wood"
	frame = /obj/structure/table_frame/wood
	framestack = /obj/item/stack/sheet/wood
	buildstack = /obj/item/stack/sheet/wood
	max_integrity = 70
	smoothing_groups = list(SMOOTH_GROUP_WOOD_TABLES) //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = list(SMOOTH_GROUP_WOOD_TABLES)
	resistance_flags = FLAMMABLE

/// No specialties, Just a mapping object.
/obj/structure/table/wood/poker
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'icons/obj/smooth_structures/tables/poker_table.dmi'
	icon_state = "poker_table-0"
	base_icon_state = "poker_table"
	flipped_table_icon_base = "poker"
	buildstack = /obj/item/stack/tile/carpet

// MARK: Fancy tables
/obj/structure/table/wood/fancy
	name = "fancy table"
	desc = "A standard metal table frame covered with an amazingly fancy, patterned cloth."
	icon = 'icons/obj/smooth_structures/tables/fancy/fancy_table.dmi'
	icon_state = "fancy_table-0"
	base_icon_state = "fancy_table"
	flipped_table_icon_base = "fancy"
	frame = /obj/structure/table_frame
	framestack = /obj/item/stack/rods
	buildstack = /obj/item/stack/tile/carpet
	smoothing_groups = list(SMOOTH_GROUP_FANCY_WOOD_TABLES) //Don't smooth with SMOOTH_GROUP_TABLES or SMOOTH_GROUP_WOOD_TABLES
	canSmoothWith = list(SMOOTH_GROUP_FANCY_WOOD_TABLES)

/obj/structure/table/wood/fancy/flip(direction)
	return FALSE

/obj/structure/table/wood/fancy/Initialize(mapload)
	. = ..()
	QUEUE_SMOOTH(src)

/obj/structure/table/wood/fancy/black
	icon_state = "fancy_table_black-0"
	base_icon_state = "fancy_table_black"
	flipped_table_icon_base = "fancyblack"
	buildstack = /obj/item/stack/tile/carpet/black
	icon = 'icons/obj/smooth_structures/tables/fancy/fancy_table_black.dmi'


/obj/structure/table/wood/fancy/blue
	icon_state = "fancy_table_blue-0"
	base_icon_state = "fancy_table_blue"
	buildstack = /obj/item/stack/tile/carpet/blue
	icon = 'icons/obj/smooth_structures/tables/fancy/fancy_table_blue.dmi'

/obj/structure/table/wood/fancy/cyan
	icon_state = "fancy_table_cyan-0"
	base_icon_state = "fancy_table_cyan"
	buildstack = /obj/item/stack/tile/carpet/cyan
	icon = 'icons/obj/smooth_structures/tables/fancy/fancy_table_cyan.dmi'

/obj/structure/table/wood/fancy/green
	icon_state = "fancy_table_green-0"
	base_icon_state = "fancy_table_green"
	buildstack = /obj/item/stack/tile/carpet/green
	icon = 'icons/obj/smooth_structures/tables/fancy/fancy_table_green.dmi'

/obj/structure/table/wood/fancy/orange
	icon_state = "fancy_table_orange-0"
	base_icon_state = "fancy_table_orange"
	buildstack = /obj/item/stack/tile/carpet/orange
	icon = 'icons/obj/smooth_structures/tables/fancy/fancy_table_orange.dmi'

/obj/structure/table/wood/fancy/purple
	icon_state = "fancy_table_purple-0"
	base_icon_state = "fancy_table_purple"
	buildstack = /obj/item/stack/tile/carpet/purple
	icon = 'icons/obj/smooth_structures/tables/fancy/fancy_table_purple.dmi'

/obj/structure/table/wood/fancy/red
	icon_state = "fancy_table_red-0"
	base_icon_state = "fancy_table_red"
	buildstack = /obj/item/stack/tile/carpet/red
	icon = 'icons/obj/smooth_structures/tables/fancy/fancy_table_red.dmi'

/obj/structure/table/wood/fancy/royalblack
	icon_state = "fancy_table_royalblack-0"
	base_icon_state = "fancy_table_royalblack"
	buildstack = /obj/item/stack/tile/carpet/royalblack
	icon = 'icons/obj/smooth_structures/tables/fancy/fancy_table_royalblack.dmi'


/obj/structure/table/wood/fancy/royalblue
	icon_state = "fancy_table_royalblue-0"
	base_icon_state = "fancy_table_royalblue"
	buildstack = /obj/item/stack/tile/carpet/royalblue
	icon = 'icons/obj/smooth_structures/tables/fancy/fancy_table_royalblue.dmi'

// MARK: Reinforced tables
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A reinforced version of the four legged table."
	icon = 'icons/obj/smooth_structures/tables/reinforced_table.dmi'
	icon_state = "reinforced_table-0"
	base_icon_state = "reinforced_table"
	flipped_table_icon_base = "rtables"
	deconstruction_ready = FALSE
	buildstack = /obj/item/stack/sheet/plasteel
	smoothing_groups = list(SMOOTH_GROUP_REINFORCED_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_REINFORCED_TABLES)
	max_integrity = 200
	integrity_failure = 50
	armor = list(MELEE = 10, BULLET = 30, LASER = 30, ENERGY = 100, BOMB = 20, RAD = 0, FIRE = 80, ACID = 70)

/obj/structure/table/reinforced/deconstruction_hints(mob/user)
	if(deconstruction_ready)
		to_chat(user, "<span class='notice'>The top cover has been <i>welded</i> loose and the main frame's <b>bolts</b> are exposed.</span>")
	else
		to_chat(user, "<span class='notice'>The top cover is firmly <b>welded</b> on.</span>")

/obj/structure/table/reinforced/flip(direction)
	if(!deconstruction_ready)
		return 0
	else
		return ..()

/obj/structure/table/reinforced/welder_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0))
		return
	. = TRUE
	to_chat(user, "<span class='notice'>You start [deconstruction_ready ? "strengthening" : "weakening"] the reinforced table...</span>")
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You [deconstruction_ready ? "strengthen" : "weaken"] the table.</span>")
		deconstruction_ready = !deconstruction_ready

/obj/structure/table/reinforced/brass
	name = "brass table"
	desc = "A solid, slightly beveled brass table."
	icon = 'icons/obj/smooth_structures/tables/brass_table.dmi'
	icon_state = "brass_table-0"
	base_icon_state = "brass_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	frame = /obj/structure/table_frame/brass
	framestack = /obj/item/stack/tile/brass
	buildstack = /obj/item/stack/tile/brass
	framestackamount = 1
	smoothing_groups = list(SMOOTH_GROUP_BRASS_TABLES) //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = list(SMOOTH_GROUP_BRASS_TABLES)

/obj/structure/table/reinforced/cult
	name = "runed metal table"
	desc = "A cold slab of metal engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/obj/smooth_structures/tables/cult_table.dmi'
	icon_state = "cult_table-0"
	base_icon_state = "cult_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	frame = /obj/structure/table_frame/cult
	framestack = /obj/item/stack/sheet/runed_metal
	buildstack = /obj/item/stack/sheet/runed_metal
	framestackamount = 1
	smoothing_groups = list(SMOOTH_GROUP_BRASS_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_BRASS_TABLES)

/obj/structure/table/reinforced/cult/narsie_act()
	return

// Special variant created by pylons when converting stuff. Drops no materials so they can't be used as a runed metal farm.
/obj/structure/table/reinforced/cult/no_metal
	name = "runed stone table"
	desc = "A cold slab of stone engraved with indecipherable symbols. Studying them causes your head to pound."

/obj/structure/table/reinforced/cult/no_metal/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	visible_message("<span class = 'warning'>[src] suddenly crumbles to dust!<span/>")
	qdel(src)

// MARK: Wheeled table
/obj/structure/table/tray
	name = "surgical instrument table"
	desc = "A small metal tray with wheels."
	anchored = FALSE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tray"
	buildstack = /obj/item/stack/sheet/mineral/titanium
	buildstackamount = 2
	can_be_flipped = FALSE
	var/list/typecache_can_hold = list(/mob, /obj/item)
	var/list/held_items = list()

/obj/structure/table/tray/Initialize(mapload)
	. = ..()
	typecache_can_hold = typecacheof(typecache_can_hold)
	for(var/atom/movable/held in get_turf(src))
		if(!held.anchored && held.move_resist != INFINITY && is_type_in_typecache(held, typecache_can_hold))
			held_items += held.UID()

/obj/structure/table/tray/Move(NewLoc, direct)
	var/atom/oldloc = loc
	. = ..()
	if(oldloc == loc) // ..() will return 0 if we didn't actually move anywhere, except for some diagonal cases.
		return

	if(direct & (direct - 1)) // This represents a diagonal movement, which is split into multiple cardinal movements. We'll handle moving the items on the cardinals only.
		return

	playsound(loc, pick('sound/items/cartwheel1.ogg', 'sound/items/cartwheel2.ogg'), 100, TRUE, ignore_walls = FALSE)

	var/atom/movable/held
	for(var/held_uid in held_items)
		held = locateUID(held_uid)
		if(!held)
			held_items -= held_uid
			continue
		if(oldloc != held.loc)
			held_items -= held_uid
			continue
		held.forceMove(NewLoc)

/obj/structure/table/tray/can_be_pulled(user, grab_state, force, show_message)
	var/atom/movable/puller = user
	if(loc != puller.loc)
		held_items -= puller.UID()
	if(isliving(user))
		var/mob/living/M = user
		if(M.UID() in held_items)
			return FALSE
	return ..()

/obj/structure/table/tray/item_placed(atom/movable/item)
	. = ..()
	if(is_type_in_typecache(item, typecache_can_hold))
		held_items += item.UID()
		if(isliving(item))
			var/mob/living/M = item
			if(M.pulling == src)
				M.stop_pulling()

/obj/structure/table/tray/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags & NODECONSTRUCT))
		var/turf/T = get_turf(src)
		new buildstack(T, buildstackamount)
	qdel(src)

/obj/structure/table/tray/deconstruction_hints(mob/user)
	to_chat(user, "<span class='notice'>It is held together by some <b>screws</b> and <b>bolts</b>.</span>")

/obj/structure/table/tray/flip()
	return FALSE

/obj/structure/table/tray/narsie_act()
	return FALSE

// MARK: Racks
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW | PASSTAKE
	max_integrity = 20
	var/deconstruction_item = /obj/item/rack_parts
	var/deconstruction_quantity = 1

/obj/structure/rack/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's held together by a couple of <b>bolts</b>.</span>"

/obj/structure/rack/CanPass(atom/movable/mover, border_dir)
	if(!density) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover))
		if(mover.checkpass(PASSTABLE))
			return TRUE
		var/mob/living/living_mover = mover
		if(istype(living_mover) && IS_HORIZONTAL(living_mover) && HAS_TRAIT(living_mover, TRAIT_CONTORTED_BODY))
			return TRUE
	if(mover.throwing)
		return 1
	else
		return 0

/obj/structure/rack/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	. = !density
	if(pass_info.is_movable)
		. = . || pass_info.pass_flags & PASSTABLE

/obj/structure/rack/MouseDrop_T(obj/O, mob/user)
	if((!isitem(O) || user.get_active_hand() != O))
		return
	if(isrobot(user))
		return
	if(!user.drop_item())
		return
	if(O.loc != src.loc)
		step(O, get_dir(O, src))
		return TRUE

/obj/structure/rack/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(isrobot(user) && !istype(W.loc, /obj/item/gripper))
		return
	if(user.a_intent == INTENT_HARM)
		return
	if(!(W.flags & ABSTRACT))
		if(user.drop_item())
			W.Move(loc)
	return ITEM_INTERACT_COMPLETE

/obj/structure/rack/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(flags & NODECONSTRUCT)
		to_chat(user, "<span class='warning'>Try as you might, you can't figure out how to deconstruct this.</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/rack/attack_hand(mob/living/user)
	if(user.IsWeakened())
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message("<span class='warning'>[user] kicks [src].</span>", \
							"<span class='danger'>You kick [src].</span>")
	take_damage(rand(4,8), BRUTE, MELEE, 1)

/obj/structure/rack/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/items/dodgeball.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 40, TRUE)

/obj/structure/rack/skeletal_bar
	name = "skeletal minibar"
	desc = "Made with the skulls of the fallen."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "minibar"

/obj/structure/rack/skeletal_bar/left
	icon_state = "minibar_left"

/obj/structure/rack/skeletal_bar/right
	icon_state = "minibar_right"

/*
 * Rack destruction
 */

/obj/structure/rack/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		density = FALSE
		if(deconstruction_quantity)
			new deconstruction_item(loc, deconstruction_quantity)
		else
			var/decon_parts = new deconstruction_item(get_turf(src))
			transfer_fingerprints_to(decon_parts)
	qdel(src)

/*
 * Rack Parts
 */

/obj/item/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon_state = "rack_parts"
	flags = CONDUCT
	materials = list(MAT_METAL=2000)
	var/building = FALSE

/obj/item/rack_parts/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	new /obj/item/stack/sheet/metal(user.loc)
	qdel(src)

/obj/item/rack_parts/attack_self__legacy__attackchain(mob/user)
	if(building)
		return
	building = TRUE
	to_chat(user, "<span class='notice'>You start constructing a rack...</span>")
	if(do_after(user, 50, target = user, progress=TRUE))
		if(!user.drop_item(src))
			return
		var/obj/structure/rack/R = new /obj/structure/rack(user.loc)
		user.visible_message("<span class='notice'>[user] assembles \a [R].\
			</span>", "<span class='notice'>You assemble \a [R].</span>")
		R.add_fingerprint(user)
		qdel(src)
	building = FALSE

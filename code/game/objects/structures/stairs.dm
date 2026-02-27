#define STAIR_TERMINATOR_AUTOMATIC 0
#define STAIR_TERMINATOR_NO 1
#define STAIR_TERMINATOR_YES 2

/// Range within which stair indicators will appear for approaching mobs
#define STAIR_INDICATOR_RANGE 3

// dir determines the direction of travel to go upwards
// stairs require /turf/open/openspace as the tile above them to work, unless your stairs have 'force_open_above' set to TRUE
// multiple stair objects can be chained together; the Z level transition will happen on the final stair object in the chain

/obj/structure/stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	base_icon_state = "stairs"
	anchored = TRUE
	move_resist = INFINITY
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER

	/// Determines if this stair is the last in a "chain" of stairs, ie next step is upstairs
	VAR_FINAL/terminator_mode = STAIR_TERMINATOR_AUTOMATIC
	/// Turf on the higher/lower level of this stairs' turf.
	VAR_FINAL/turf/opposing_turf
	VAR_PRIVATE/traverse_dir = UP
	/// If TRUE, we have left/middle/right sprites.
	var/has_merged_sprites = TRUE
	/// Lazyassoc list of weakef to mob viewing stair indicators to their images
	VAR_PRIVATE/list/mob_to_image

/obj/structure/stairs/north
	dir = NORTH

/obj/structure/stairs/south
	dir = SOUTH

/obj/structure/stairs/east
	dir = EAST

/obj/structure/stairs/west
	dir = WEST

/obj/structure/stairs/wood
	icon_state = "stairs_wood"
	has_merged_sprites = FALSE

/obj/structure/stairs/stone
	icon_state = "stairs_stone"
	has_merged_sprites = FALSE

/obj/structure/stairs/Initialize(mapload)
	. = ..()

	GLOB.stairs += src

	build_signal_listener()
	update_surrounding()

	var/static/list/exit_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit_stairs),
	)

	AddElement(/datum/element/connect_loc, exit_connections)

	var/static/list/range_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_enter_range),
		COMSIG_ATOM_EXITED = PROC_REF(on_exit_range),
	)
	AddComponent(/datum/component/connect_range, tracked = src, connections = range_connections, range = STAIR_INDICATOR_RANGE)


/obj/structure/stairs/Destroy()
	if(opposing_turf)
		opposing_turf = null
	for(var/climber_ref in mob_to_image)
		clear_climber_image(climber_ref, instant = TRUE)
	GLOB.stairs -= src
	return ..()

/obj/structure/stairs/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change) //Look this should never happen but...
	. = ..()
	build_signal_listener()
	update_surrounding()

/// Updates the sprite and the sprites of neighboring stairs to reflect merged sprites
/obj/structure/stairs/proc/update_surrounding()
	if(!has_merged_sprites)
		return

	update_appearance()

	for(var/obj/structure/stairs/stair in get_step(src, turn(dir, 90)))
		stair.update_appearance()

	for(var/obj/structure/stairs/stair in get_step(src, turn(dir, -90)))
		stair.update_appearance()

/obj/structure/stairs/update_icon_state()
	. = ..()
	if(!has_merged_sprites)
		return

	var/has_left_stairs = FALSE
	var/has_right_stairs = FALSE
	for(var/obj/structure/stairs/stair in get_step(src, turn(dir, 90)))
		if(stair.dir == dir)
			has_left_stairs = TRUE
			break

	for(var/obj/structure/stairs/stair in get_step(src, turn(dir, -90)))
		if(stair.dir == dir)
			has_right_stairs = TRUE
			break

	if(has_left_stairs && has_right_stairs)
		icon_state = "[base_icon_state]-m"
	else if(has_left_stairs)
		icon_state = "[base_icon_state]-r"
	else if(has_right_stairs)
		icon_state = "[base_icon_state]-l"
	else
		icon_state = base_icon_state

/obj/structure/stairs/proc/on_exit_stairs(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return //Let's not block ourselves.

	if(!isobserver(leaving) && isTerminator() && direction == dir)
		INVOKE_ASYNC(src, PROC_REF(stair_traverse), leaving)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

#define POINT_X_COMPONENT(pdir) ((pdir & EAST) ? 2 : ((pdir & WEST) ? -2 : 0))
#define POINT_Y_COMPONENT(pdir) ((pdir & SOUTH) ? 2 : ((pdir & NORTH) ? -2 : 0))

/obj/structure/stairs/proc/on_enter_range(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(!isliving(entered))
		return

	var/mob/living/climber = entered
	var/climber_ref = climber.UID()
	if(!climber.client)
		return
	if(climber.dir == REVERSE_DIR(dir))
		return // walking away
	if(LAZYACCESS(mob_to_image, climber_ref))
		return // already see it
	if(!(climber in viewers(STAIR_INDICATOR_RANGE + 1, src)))
		return // can't see the staircase (+1 tile for some leeway)
	var/turf/simulated/floor/floor_turf = get_step(src, traverse_dir)
	if(!istype(floor_turf))
		return // no place to go up to

	var/image/pointing_image = get_pointing_image()
	climber.client.images += pointing_image
	pointing_image.alpha = 0
	animate(pointing_image, pixel_x = POINT_X_COMPONENT(dir), pixel_y = POINT_Y_COMPONENT(dir), time = 0.5 SECONDS, easing = SINE_EASING|EASE_OUT, loop = -1, tag = "point_xy")
	animate(pixel_x = 0, pixel_y = 0, time = 0.5 SECONDS, easing = SINE_EASING|EASE_IN)
	animate(pointing_image, alpha = 180, time = 0.75 SECONDS, tag = "point_fadein")
	LAZYSET(mob_to_image, climber_ref, pointing_image)

/obj/structure/stairs/proc/on_exit_range(datum/source, atom/movable/exited)
	SIGNAL_HANDLER

	if(!isliving(exited))
		return

	var/climber_uid = exited.UID()
	if(!LAZYACCESS(mob_to_image, climber_uid))
		return // not seeing anything
	if(exited in viewers(STAIR_INDICATOR_RANGE, src))
		return // still in range and can see the staircase

	clear_climber_image(climber_uid)

/obj/structure/stairs/proc/clear_climber_image(climber_uid, instant = FALSE)
	var/image/pointing_image = LAZYACCESS(mob_to_image, climber_uid)
	if(!pointing_image)
		LAZYREMOVE(mob_to_image, climber_uid) // just in case
		return
	if(instant)
		clear_climber_image_callback(climber_uid, pointing_image)
		return

	animate(pointing_image, alpha = 0, time = 0.75 SECONDS, tag = "point_fadeout")
	// note: the player won't see a new indicator until the image is fully a removed, so this timer also serves as a cooldown
	addtimer(CALLBACK(src, PROC_REF(clear_climber_image_callback), climber_uid, pointing_image), 1.5 SECONDS, TIMER_UNIQUE)

/obj/structure/stairs/proc/clear_climber_image_callback(climber_uid, image/pointing_image)
	PRIVATE_PROC(TRUE)
	var/mob/living/climber = locateUID(climber_uid)
	climber?.client?.images -= pointing_image
	LAZYREMOVE(mob_to_image, climber_uid)

/obj/structure/stairs/proc/get_pointing_image()
	PROTECTED_PROC(TRUE)
	var/image/point_image = image('icons/mob/screen_gen.dmi', src, "arrow_large_white_still")
	point_image.color = COLOR_DARK_MODERATE_LIME_GREEN
	point_image.appearance_flags |= KEEP_APART
	point_image.transform = matrix().Turn(dir2angle(REVERSE_DIR(dir)))
	point_image.layer = BELOW_MOB_LAYER
	point_image.plane = GAME_PLANE
	return point_image

#undef POINT_X_COMPONENT
#undef POINT_Y_COMPONENT

/obj/structure/stairs/Cross(atom/movable/AM)
	if(isTerminator() && (get_dir(src, AM) == dir))
		return FALSE
	return ..()

/obj/structure/stairs/proc/stair_traverse(atom/movable/climber)
	var/turf/simulated/floor/checking = get_step(src, traverse_dir)
	if(!istype(checking))
		return
	var/turf/target = get_step(src, dir|traverse_dir)
	if(istype(target))
		climber.forceMove(target)
		/// Moves anything that's being dragged by src or anything buckled to it to the stairs turf.
		climber.pulling?.move_from_pull(climber, loc, climber.glide_size)
		for(var/mob/living/buckled as anything in climber.buckled_mobs)
			buckled.pulling?.move_from_pull(buckled, loc, buckled.glide_size)

/obj/structure/stairs/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(!var_value)
		if(opposing_turf)
			opposing_turf = null
	else
		build_signal_listener()

/obj/structure/stairs/proc/build_signal_listener()
	if(is_lower_level(z))
		var/turf/T = get_step(src, UP)
		if(istype(T))
			opposing_turf = T
			traverse_dir = UP
	else if(is_upper_level(z))
		var/turf/T = get_step(src, DOWN)
		if(istype(T))
			opposing_turf = T
			traverse_dir = DOWN

/// Will the passed mob tumble down the stairs instead of walking?
/obj/structure/stairs/proc/can_fall_down_stairs(mob/living/falling)
	if(falling.buckled || falling.pulledby)
		return FALSE
	if(falling.stat >= UNCONSCIOUS) // if you shove someone unconscious down the stairs, they'd probably roll
		return TRUE
	if(falling.has_status_effect(/datum/status_effect/transient/dizziness)) // off balance
		return TRUE
	return FALSE

/// What happens when a mob tumbles down the stairs
/obj/structure/stairs/proc/on_fall(mob/living/falling)
	falling.Paralyse(2 SECONDS)
	falling.KnockDown(5 SECONDS)
	falling.spin(1 SECONDS, 0.25 SECONDS)
	falling.apply_damage(rand(4, 8), BRUTE, spread_damage = TRUE)
	GLOB.move_manager.move_towards(falling, get_ranged_target_turf(src, REVERSE_DIR(dir), 2), delay = 0.4 SECONDS, timeout = 1 SECONDS)

/obj/structure/stairs/proc/isTerminator() //If this is the last stair in a chain and should move mobs up
	if(terminator_mode != STAIR_TERMINATOR_AUTOMATIC)
		return (terminator_mode == STAIR_TERMINATOR_YES)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	var/turf/them = get_step(T, dir)
	if(!them)
		return FALSE
	for(var/obj/structure/stairs/S in them)
		if(S.dir == dir)
			return FALSE
	return TRUE

#undef STAIR_TERMINATOR_AUTOMATIC
#undef STAIR_TERMINATOR_NO
#undef STAIR_TERMINATOR_YES

#undef STAIR_INDICATOR_RANGE

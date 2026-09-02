#define SPEED_MOD 5
#define PX_OFFSET 16 //half of total px size of sprite

/// Cars that can drift.
/obj/tgvehicle/sealed/vectorcraft
	name = "all-terrain hovercraft"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-Earth technologies that are still relevant on most planet-bound outposts."
	inertia_moving = FALSE
	animate_movement = 0
	max_integrity = 100
	var/vector = list("x" = 0, "y" = 0) //vector math
	var/tile_loc = list("x" = 0, "y" = 0) //x y offset of tile
	var/max_acceleration = 5.25
	var/accel_step = 0.3
	var/acceleration = 0.4
	var/max_deceleration = 2
	var/max_velocity = 50
	var/enginesound_delay = 0
	var/boost_cooldown
	var/pixel_collision_size_x = 0
	var/pixel_collision_size_y = 0

	var/mob/living/carbon/human/driver

/obj/tgvehicle/sealed/vectorcraft/mob_enter(mob/living/M)
	if(!driver)
		driver = M
	start_engine()
	return ..()

/obj/tgvehicle/sealed/vectorcraft/mob_exit(mob/living/M, silent = FALSE, randomstep = FALSE)
	.=..()
	if(!driver)
		stop_engine()
		return
	if(driver.client)
		driver.client.pixel_x = 0
		driver.client.pixel_y = 0
	driver.pixel_x = 0
	driver.pixel_y = 0
	if(M == driver)
		driver = null
	stop_engine()

// MARK: Driving

/obj/tgvehicle/sealed/vectorcraft/proc/start_engine()
	if(dead_check())
		return
	START_PROCESSING(SSvectorcraft, src)
	if(!driver)
		stop_engine()

/obj/tgvehicle/sealed/vectorcraft/proc/stop_engine()
	STOP_PROCESSING(SSvectorcraft, src)
	vector = list("x" = 0, "y" = 0)
	acceleration = initial(acceleration)

/obj/tgvehicle/sealed/vectorcraft/proc/dead_check()
	if(driver.stat > 0)
		mob_exit(driver)
		stop_engine()
		return TRUE
	return FALSE

//Move the damn car
/obj/tgvehicle/sealed/vectorcraft/vehicle_move(cached_direction)
	if(!driver)
		stop_engine()
	if(driver.stat == DEAD)
		mob_exit(driver)
	dir = cached_direction
	check_boost()
	calc_acceleration()
	calc_vector(cached_direction)
	forceMove(get_step(src, cached_direction))

/// Passive hover drift.
/obj/tgvehicle/sealed/vectorcraft/proc/hover_loop()
	check_boost()
	if(driver.m_intent == MOVE_INTENT_WALK)
		var/deceleration = max_deceleration
		if(driver.in_throw_mode)
			deceleration *= 1.5
		friction(deceleration, TRUE)
	else if(driver.in_throw_mode)
		friction(max_deceleration*1.2, TRUE)
	friction(max_deceleration/4)

	if(trailer)
		var/dir_to_move = get_dir(trailer.loc, loc)
		var/did_move = move_car()
		if(did_move)
			step(trailer, dir_to_move)
			trailer.pixel_x = tile_loc["x"]
			trailer.pixel_y = tile_loc["y"]
		after_move(did_move)
		return did_move
	else
		var/direction = move_car()
		after_move(direction)
		return direction

/obj/tgvehicle/sealed/vectorcraft/process()
	hover_loop()
	dead_check()

// MARK: Movement

/obj/tgvehicle/sealed/vectorcraft/proc/move_car()
	#ifdef VEHICLE_DEBUG
		message_admins("Pre_ Tile_loc: [tile_loc["x"]], [tile_loc["y"]] Vector: [vector["x"]],[vector["y"]]")
	#endif

	var/cached_tile = tile_loc
	tile_loc["x"] += vector["x"]/SPEED_MOD
	tile_loc["y"] += vector["y"]/SPEED_MOD
	//range = -16 to 16
	var/x_move = 0
	if(tile_loc["x"] > PX_OFFSET)
		x_move = round((tile_loc["x"]+PX_OFFSET) / (PX_OFFSET*2), 1)
		tile_loc["x"] = ((tile_loc["x"]+PX_OFFSET) % (PX_OFFSET*2))-PX_OFFSET
	else if(tile_loc["x"] < -PX_OFFSET)
		x_move = round((tile_loc["x"]-PX_OFFSET) / (PX_OFFSET*2), 1)
		tile_loc["x"] = ((tile_loc["x"]-PX_OFFSET) % -(PX_OFFSET*2))+PX_OFFSET

	var/y_move = 0
	if(tile_loc["y"] > PX_OFFSET)
		y_move = round((tile_loc["y"]+PX_OFFSET) / (PX_OFFSET*2), 1)
		tile_loc["y"] = ((tile_loc["y"]+PX_OFFSET) % (PX_OFFSET*2))-PX_OFFSET
	else if(tile_loc["y"] < -PX_OFFSET)
		y_move = round((tile_loc["y"]-PX_OFFSET) / (PX_OFFSET*2), 1)
		tile_loc["y"] = ((tile_loc["y"]-PX_OFFSET) % -(PX_OFFSET*2))+PX_OFFSET

	if(!(x_move == 0 && y_move == 0))
		var/turf/T = get_offset_target_turf(src, x_move, y_move)
		for(var/atom/A in T.contents)
			Bump(A)
			if(A.density)
				ricochet()
				tile_loc = cached_tile
				return FALSE
		if(T.density)
			ricochet()
			tile_loc = cached_tile
			return FALSE

	x += x_move
	y += y_move
	pixel_x = round(tile_loc["x"], 1)
	pixel_y = round(tile_loc["y"], 1)
	if(driver && driver.client)
		driver.client.pixel_x = pixel_x
		driver.client.pixel_y = pixel_y

	#ifdef VEHICLE_DEBUG
		message_admins("Post TileLoc:[tile_loc["x"]], [tile_loc["y"]] Movement: [x_move],[y_move]")
		message_admins("Pix:[pixel_x],[pixel_y] TileLoc:[tile_loc["x"]], [tile_loc["y"]]. [round(tile_loc["x"])], [round(tile_loc["y"])]")
	#endif

	// no tile movement
	if(x_move == 0 && y_move == 0)
		return FALSE

	loc.Entered(src)

	return TRUE

/// Check the cooldown on the boost.
/obj/tgvehicle/sealed/vectorcraft/proc/check_boost()
	if(enginesound_delay < world.time)
		enginesound_delay = 0
	if(!boost_cooldown)
		return
	if(boost_cooldown < world.time)
		boost_cooldown = 0
		playsound(src.loc,'sound/effects/vehicles/boost_ready.ogg', 65, 0)
	return

/// Bounce the car off a wall.
/obj/tgvehicle/sealed/vectorcraft/proc/bounce()
	vector["x"] = -vector["x"]/2
	vector["y"] = -vector["y"]/2
	acceleration /= 2

/obj/tgvehicle/sealed/vectorcraft/proc/ricochet(x_move, y_move)
	var/speed = calc_speed()
	apply_damage(speed/10)
	bounce()

/obj/tgvehicle/sealed/vectorcraft/item_interaction(mob/living/user, obj/item/O, list/modifiers)
	if(istype(O, /obj/item/weldingtool))
		if(obj_integrity < max_integrity)
			if(!O.tool_start_check(user, amount = 0))
				return

			user.visible_message(
				SPAN_NOTICE("[user] begins repairing [src]."),
				SPAN_NOTICE("You begin repairing [src]..."),
				SPAN_NOTICE("You hear welding."),
			)

			if(O.use_tool(src, user, 40, volume=50))
				to_chat(user, SPAN_NOTICE("You repair [src]."))
				apply_damage(-max_integrity)
		else
			to_chat(user, SPAN_NOTICE("[src] does not need repairs.</span>"))

/obj/tgvehicle/sealed/vectorcraft/attack_hand(mob/user)
	remove_key(driver)
	..()

/// Heals/damages the car
/obj/tgvehicle/sealed/vectorcraft/proc/apply_damage(damage)
	obj_integrity -= damage
	var/healthratio = ((obj_integrity/max_integrity)/4) + 0.75
	max_acceleration = initial(max_acceleration) * healthratio
	max_deceleration = initial(max_deceleration) * healthratio

	if(obj_integrity > max_integrity)
		obj_integrity = max_integrity

/obj/tgvehicle/sealed/vectorcraft/obj_destruction(damage_flag)
	mob_exit(driver)
	var/datum/effect_system/reagents_explosion/e = new()
	var/turf/T = get_turf(src)
	e.set_up(1, T, 1, 3)
	e.start()
	visible_message("The [src] explodes from taking too much damage!")

	. = ..()

/obj/tgvehicle/sealed/vectorcraft/Bump(atom/M)
	var/speed = calc_speed()
	if(isliving(M))
		var/mob/living/C = M
		if(!C.anchored)
			var/atom/throw_target = get_edge_target_turf(C, calc_angle())
			C.throw_at(throw_target, 10, 14)
		to_chat(C, SPAN_WARNING("You are hit by the [src]!"))
		to_chat(driver, SPAN_WARNING("<You just ran into [C]lunatic!"))
		C.adjustBruteLoss(speed/10)
		return ..()

	if(istype(M, /obj/tgvehicle/sealed/vectorcraft))
		var/obj/tgvehicle/sealed/vectorcraft/Vc = M
		Vc.apply_damage(speed/5)
		Vc.vector["x"] += vector["x"]/2
		Vc.vector["y"] += vector["y"]/2
		apply_damage(speed/10)
		bounce()
		return ..()
	if(istype(M, /obj/))
		var/obj/O = M
		if(O.density)
			O.take_damage(speed*2.5)
	return ..()

/// Returns the angle to move towards
/obj/tgvehicle/sealed/vectorcraft/proc/calc_angle()
	var/x = round(vector["x"], 1)
	var/y = round(vector["y"], 1)
	if(y == 0)
		if(x > 0)
			return EAST
		else if(x < 0)
			return WEST
	if(x == 0)
		if(y > 0)
			return NORTH
		else if(y < 0)
			return SOUTH
	if(x == 0 || y == 0)
		return FALSE
	var/angle = (ATAN2(x,y))

	// I WISH I HAD RADIANSSSSSSSSSS
	if(angle > 0)
		switch(angle)
			if(0 to 22)
				return EAST
			if(22 to 67)
				return NORTHEAST
			if(67 to 112)
				return NORTH
			if(112 to 157)
				return NORTHWEST
			if(157 to 180)
				return WEST
	else
		switch(angle)
			if(-22 to 0)
				return EAST
			if(-67 to -22)
				return SOUTHEAST
			if(-112 to -67)
				return SOUTH
			if(-157 to -112)
				return SOUTHWEST
			if(-180 to -157)
				return WEST

/// Updates the internal speed of the car (used for crashing).
/obj/tgvehicle/sealed/vectorcraft/proc/calc_speed()
	var/speed = max(sqrt((vector["x"]**2)), sqrt((vector["y"]**2)))
	return speed

/// Calculates the acceleration.
/obj/tgvehicle/sealed/vectorcraft/proc/calc_acceleration() //Make speed 0 - 100 regardless of gear here
	acceleration += accel_step
	acceleration = clamp(acceleration, initial(acceleration), max_acceleration)
	if(!enginesound_delay)
		playsound(src.loc,'sound/effects/vehicles/norm_eng.ogg', 25, 0)
		enginesound_delay = world.time + 16
	return

/// Calculates the vector change.
/obj/tgvehicle/sealed/vectorcraft/proc/calc_vector(direction)
	var/cached_acceleration = acceleration
	var/boost_active = FALSE

	var/result_vector = vector
	switch(direction)
		if(NORTH)
			result_vector["y"] += cached_acceleration
		if(NORTHEAST)
			result_vector["x"] += cached_acceleration/1.4
			result_vector["y"] += cached_acceleration/1.4
		if(EAST)
			result_vector["x"] += cached_acceleration
		if(SOUTHEAST)
			result_vector["x"] += cached_acceleration/1.4
			result_vector["y"] -= cached_acceleration/1.4
		if(SOUTH)
			result_vector["y"] -= cached_acceleration
		if(SOUTHWEST)
			result_vector["x"] -= cached_acceleration/1.4
			result_vector["y"] -= cached_acceleration/1.4
		if(WEST)
			result_vector["x"] -= cached_acceleration
		if(NORTHWEST)
			result_vector["y"] += cached_acceleration/1.4
			result_vector["x"] -= cached_acceleration/1.4

	if(boost_active)
		vector["x"] = result_vector["x"]
		vector["y"] = result_vector["y"]
	else
		vector["x"] = clamp(result_vector["x"], -max_velocity, max_velocity)
		vector["y"] = clamp(result_vector["y"], -max_velocity, max_velocity)

	if(vector["x"] > max_velocity || vector["x"] < -max_velocity)
		vector["x"] = vector["x"] - (vector["x"]/10)
		vector["x"] = clamp(vector["x"], -250, 250)
	if(vector["y"] > max_velocity || vector["y"] < -max_velocity)
		vector["y"] = vector["y"] - (vector["y"]/10)
		vector["y"] = clamp(vector["y"], -250, 250)

	return

/// Reduces speed.
/obj/tgvehicle/sealed/vectorcraft/proc/friction(change, sfx = FALSE)
	if(vector["x"] == 0 && vector["y"] == 0)
		return
	if(vector["x"] <= -change)
		vector["x"] += change
	else if(vector["x"] >= change)
		vector["x"] -= change
	else
		vector["x"] = 0

	if(vector["y"] <= -change)
		vector["y"] += change
	else if(vector["y"] >= change)
		vector["y"] -= change
	else
		vector["y"] = 0

	if(sfx)
		playsound(loc, 'sound/effects/vehicles/skid.ogg', 50, 0)

#undef SPEED_MOD
#undef PX_OFFSET

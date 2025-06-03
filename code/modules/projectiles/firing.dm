/obj/item/ammo_casing/proc/fire(atom/target, mob/living/user, params, distro, quiet, zone_override = "", spread, atom/firer_source_atom)
	distro += variance
	for(var/i = max(1, pellets), i > 0, i--)
		var/targloc = get_turf(target)
		ready_proj(target, user, quiet, zone_override, firer_source_atom)
		if(distro) //We have to spread a pixel-precision bullet. throw_proj was called before so angles should exist by now...
			if(randomspread)
				spread = round((rand() - 0.5) * distro)
			else //Smart spread
				spread = round((i / pellets - 0.5) * distro)
		if(isnull(throw_proj(target, targloc, user, params, spread, firer_source_atom)))
			return FALSE
		if(i > 1)
			newshot()
	if(click_cooldown_override)
		user.changeNext_move(click_cooldown_override)
	else
		user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target, user))
	update_icon()
	return TRUE

/obj/item/ammo_casing/proc/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/firer_source_atom)
	if(!BB)
		return
	BB.original = target
	BB.firer = user
	BB.firer_source_atom = firer_source_atom
	if(zone_override)
		BB.def_zone = zone_override
	else
		BB.def_zone = user.zone_selected
	BB.suppressed = quiet

	if(reagents && BB.reagents)
		reagents.trans_to(BB, reagents.total_volume) //For chemical darts/bullets
		qdel(reagents)

/obj/item/ammo_casing/proc/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread, atom/firer_source_atom)
	var/turf/curloc = get_turf(firer_source_atom)
	if(!istype(curloc)) // False-bottomed briefcase check / shell launch system check.
		var/obj/item/holding = user.get_active_hand()
		if(istype(holding, /obj/item/storage/briefcase/false_bottomed))
			curloc = get_turf(holding)
		if(istype(firer_source_atom, /obj/item/gun/projectile/revolver/doublebarrel/shell_launcher))
			curloc = get_turf(user)
	if(!istype(targloc) || !istype(curloc) || !BB)
		return
	BB.ammo_casing = src
	if(istype(BB.ammo_casing, /obj/item/ammo_casing/energy))
		var/obj/item/ammo_casing/energy/energy_casing = BB.ammo_casing
		BB.damage = BB.damage * energy_casing.lens_damage_multiplier
		BB.stamina = BB.stamina * energy_casing.lens_damage_multiplier
		BB.speed = BB.speed * energy_casing.lens_speed_multiplier

	if(target && get_dist(user, target) <= 1) //Point blank shot must always hit
		BB.starting = curloc
		BB.prehit(target)
		target.bullet_act(BB, BB.def_zone)
		QDEL_NULL(BB)
		return TRUE

	if(targloc == curloc)
		if(target) //if the target is right on our location we go straight to bullet_act()
			BB.prehit(target)
			target.bullet_act(BB, BB.def_zone)
		QDEL_NULL(BB)
		return TRUE

	var/modifiers = params2list(params)
	BB.preparePixelProjectile(target, user, modifiers, spread)

	if(BB)
		BB.fire()
	BB = null

	return TRUE

/obj/item/ammo_casing/proc/spread(turf/target, turf/current, distro)
	var/dx = abs(target.x - current.x)
	var/dy = abs(target.y - current.y)
	return locate(target.x + round(gaussian(0, distro) * (dy+2)/8, 1), target.y + round(gaussian(0, distro) * (dx+2)/8, 1), target.z)

/**
 * Aims the projectile at a target.
 *
 * Must be passed at least one of a target or a list of click parameters.
 * If only passed the click modifiers the source atom must be a mob with a client.
 *
 * Arguments:
 * - [target][/atom]: (Optional) The thing that the projectile will be aimed at.
 * - [source][/atom]: The initial location of the projectile or the thing firing it.
 * - [modifiers][/list]: (Optional) A list of click parameters to apply to this operation.
 * - deviation: (Optional) How the trajectory should deviate from the target in degrees.
 *   - //Spread is FORCED!
 */
/obj/item/projectile/proc/preparePixelProjectile(atom/target, atom/source, list/modifiers = null, deviation = 0)
	if(!(isnull(modifiers) || islist(modifiers)))
		stack_trace("WARNING: Projectile [type] fired with non-list modifiers, likely was passed click params.")
		modifiers = null

	var/turf/source_loc = get_turf(source)
	var/turf/target_loc = get_turf(target)
	if(isnull(source_loc))
		stack_trace("WARNING: Projectile [type] fired from nullspace.")
		qdel(src)
		return FALSE

	trajectory_ignore_forcemove = TRUE
	forceMove(source_loc)
	trajectory_ignore_forcemove = FALSE

	starting = source_loc
	pixel_x = source.pixel_x
	pixel_y = source.pixel_y
	original = target
	if(length(modifiers))
		var/list/calculated = calculate_projectile_angle_and_pixel_offsets(source, target_loc && target, modifiers)

		p_x = calculated[2]
		p_y = calculated[3]
		set_angle(calculated[1] + deviation)
		return TRUE

	if(target_loc)
		yo = target_loc.y - source_loc.y
		xo = target_loc.x - source_loc.x
		set_angle(get_angle(src, target_loc) + deviation)
		return TRUE

	stack_trace("WARNING: Projectile [type] fired without a target or mouse parameters to aim with.")
	qdel(src)
	return FALSE

/**
 * Calculates the pixel offsets and angle that a projectile should be launched at.
 *
 * Arguments:
 * - [source][/atom]: The thing that the projectile is being shot from.
 * - [target][/atom]: (Optional) The thing that the projectile is being shot at.
 *   - If this is not provided the  source atom must be a mob with a client.
 * - [modifiers][/list]: A list of click parameters used to modify the shot angle.
 */
/proc/calculate_projectile_angle_and_pixel_offsets(atom/source, atom/target, modifiers)
	var/angle = 0
	var/p_x = LAZYACCESS(modifiers, ICON_X) ? text2num(LAZYACCESS(modifiers, ICON_X)) : world.icon_size / 2 // ICON_(X|Y) are measured from the bottom left corner of the icon.
	var/p_y = LAZYACCESS(modifiers, ICON_Y) ? text2num(LAZYACCESS(modifiers, ICON_Y)) : world.icon_size / 2 // This centers the target if modifiers aren't passed.

	var/mob/user = source
	if(ismob(user) && user?.client && LAZYACCESS(modifiers, SCREEN_LOC))
		//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
		var/list/screen_loc_params = splittext(LAZYACCESS(modifiers, SCREEN_LOC), ",")

		//Split X+Pixel_X up into list(X, Pixel_X)
		var/list/screen_loc_X = splittext(screen_loc_params[1],":")

		//Split Y+Pixel_Y up into list(Y, Pixel_Y)
		var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
		var/x = (text2num(screen_loc_X[1]) - 1) * world.icon_size + text2num(screen_loc_X[2])
		var/y = (text2num(screen_loc_Y[1]) - 1) * world.icon_size + text2num(screen_loc_Y[2])

		//Calculate the "resolution" of screen based on client's view and world's icon size. This will work if the user can view more tiles than average.
		var/list/screenview = getviewsize(user.client.view)

		var/ox = round((screenview[1] * world.icon_size) / 2) - user.client.pixel_x //"origin" x
		var/oy = round((screenview[2] * world.icon_size) / 2) - user.client.pixel_y //"origin" y
		angle = ATAN2(y - oy, x - ox)

		return list(angle, p_x, p_y)

	if(!target)
		CRASH("Can't make trajectory calculations without a target or click modifiers and a client.")

	var/turf/source_loc = get_turf(source)
	var/turf/target_loc = get_turf(target)
	var/dx = ((target_loc.x - source_loc.x) * world.icon_size) + (target.pixel_x - source.pixel_x) + (p_x - (world.icon_size / 2))
	var/dy = ((target_loc.y - source_loc.y) * world.icon_size) + (target.pixel_y - source.pixel_y) + (p_y - (world.icon_size / 2))

	angle = ATAN2(dy, dx)
	return list(angle, p_x, p_y)

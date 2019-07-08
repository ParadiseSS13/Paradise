/obj/item/ammo_casing/proc/fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, params, distro, quiet, zone_override = "", spread)
	distro += variance
	for(var/i = max(1, pellets), i > 0, i--)
		var/targloc = get_turf(target)
		ready_proj(target, user, quiet, zone_override)
		if(distro) //We have to spread a pixel-precision bullet. throw_proj was called before so angles should exist by now...
			if(randomspread)
				spread = round((rand() - 0.5) * distro)
			else //Smart spread
				spread = round((i / pellets - 0.5) * distro)
		if(!throw_proj(target, targloc, user, params, spread))
			return 0
		if(i > 1)
			newshot()
	if(click_cooldown_override)
		user.changeNext_move(click_cooldown_override)
	else
		user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target, user))
	update_icon()
	return 1

/obj/item/ammo_casing/proc/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	BB.original = target
	BB.firer = user
	if(zone_override)
		BB.def_zone = zone_override
	else
		BB.def_zone = user.zone_sel.selecting
	BB.suppressed = quiet

	if(reagents && BB.reagents)
		reagents.trans_to(BB, reagents.total_volume) //For chemical darts/bullets
		qdel(reagents)

/obj/item/ammo_casing/proc/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread)
	var/turf/curloc = get_turf(user)
	if(!istype(targloc) || !istype(curloc) || !BB)
		return 0
	BB.ammo_casing = src
	
	if(target && get_dist(user, target) <= 1) //Point blank shot must always hit
		target.bullet_act(BB, BB.def_zone)
		QDEL_NULL(BB)
		return 1

	if(targloc == curloc)
		if(target) //if the target is right on our location we go straight to bullet_act()
			target.bullet_act(BB, BB.def_zone)
		QDEL_NULL(BB)
		return 1

	BB.preparePixelProjectile(target, user, params, spread)
	if(BB)
		BB.fire()
	BB = null
	return 1

/obj/item/ammo_casing/proc/spread(turf/target, turf/current, distro)
	var/dx = abs(target.x - current.x)
	var/dy = abs(target.y - current.y)
	return locate(target.x + round(gaussian(0, distro) * (dy+2)/8, 1), target.y + round(gaussian(0, distro) * (dx+2)/8, 1), target.z)

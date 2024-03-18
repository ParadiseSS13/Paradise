/obj/item/gun/energy/tool_gun
	name = "Tool Gun"
	desc = "A revolver covered in circuits and stray wiring, with its cylinder replaced with a battery wrapped with wires. Looks pretty fucking powerful."
	icon_state = "tool_gun"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	fire_sound_text = "ping"
	fire_sound = "ricochet"
	ammo_type = list(/obj/item/ammo_casing/energy/deleter, /obj/item/ammo_casing/energy/throwing)
	cell_type = /obj/item/stock_parts/cell/pulse


/obj/item/ammo_casing/energy/deleter
	projectile_type = /obj/item/projectile/beam/prop_gun/deleter
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	e_cost = 500
	select_name = "Delete"


/obj/item/ammo_casing/energy/throwing
	projectile_type = /obj/item/projectile/beam/prop_gun/throwing
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	e_cost = 100
	select_name = "Throw"


/obj/item/projectile/beam/prop_gun
	impact_effect_type = null
	light_color = null
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	tracer_type = /obj/effect/projectile/tracer/disabler
	impact_type = /obj/effect/projectile/impact/disabler
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_range = 0.75
	hitscan_light_color_override = LIGHT_COLOR_LIGHTBLUE
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_LIGHTBLUE
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = LIGHT_COLOR_LIGHTBLUE

/obj/item/projectile/beam/prop_gun/deleter/on_hit(atom/target, blocked, hit_zone)
	if(isturf(target))
		var/turf/T = target
		T.ChangeTurf(T.baseturf)
		return
	if(ismovable(target))
		qdel(target)


/obj/item/projectile/beam/prop_gun/throwing/on_hit(atom/target, blocked, hit_zone)
	if(!ismovable(target))
		return
	var/atom/movable/AM = target
	var/atom/throwing_targ = get_angle_target_turf(get_turf(src), Angle, 100)
	AM.throw_at(throwing_targ, 100, 14) // fuck you


/** CTODO WAIT ON FRAGS TO BE MERGED AND THEN REMOVE THIS */
// returns turf relative to A for a given clockwise angle at set range
// result is bounded to map size
/proc/get_angle_target_turf(atom/A, angle, range)
	if(!istype(A))
		return null
	var/x = A.x
	var/y = A.y

	x += range * sin(angle)
	y += range * cos(angle)

	//Restricts to map boundaries while keeping the final angle the same
	var/dx = A.x - x
	var/dy = A.y - y
	var/ratio
	if(dy == 0) //prevents divide-by-zero errors
		ratio = INFINITY
	else
		ratio = dx / dy

	if(x < 1)
		y += (1 - x) / ratio
		x = 1
	else if(x > world.maxx)
		y += (world.maxx - x) / ratio
		x = world.maxx

	if(y < 1)
		x += (1 - y) * ratio
		y = 1
	else if(y > world.maxy)
		x += (world.maxy - y) * ratio
		y = world.maxy

	return locate(round(x, 1), round(y, 1), A.z)

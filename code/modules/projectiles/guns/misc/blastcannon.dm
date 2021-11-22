/obj/item/gun/blastcannon
	name = "pipe gun"
	desc = "A pipe welded onto a gun stock, with a mechanical trigger. The pipe has an opening near the top, and there seems to be a spring loaded wheel in the hole."
	icon_state = "empty_blastcannon"
	var/icon_state_loaded = "loaded_blastcannon"
	item_state = "blastcannon_empty"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	fire_sound = 'sound/weapons/blastcannon.ogg'
	needs_permit = FALSE
	clumsy_check = FALSE
	randomspread = FALSE

	var/obj/item/transfer_valve/bomb

/obj/item/gun/blastcannon/Destroy()
	QDEL_NULL(bomb)
	return ..()

/obj/item/gun/blastcannon/attack_self(mob/user)
	if(bomb)
		bomb.forceMove(user.loc)
		user.put_in_hands(bomb)
		user.visible_message("<span class='warning'>[user] detaches [bomb] from [src].</span>")
		bomb = null
	update_icon()
	return ..()

/obj/item/gun/blastcannon/update_icon()
	if(bomb)
		icon_state = icon_state_loaded
		name = "blast cannon"
		desc = "A makeshift device used to concentrate a bomb's blast energy to a narrow wave."
	else
		icon_state = initial(icon_state)
		name = initial(name)
		desc = initial(desc)

/obj/item/gun/blastcannon/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/transfer_valve))
		var/obj/item/transfer_valve/T = O
		if(!T.tank_one || !T.tank_two)
			to_chat(user, "<span class='warning'>What good would an incomplete bomb do?</span>")
			return FALSE
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[T] seems to be stuck to your hand!</span>")
			return FALSE
		user.visible_message("<span class='warning'>[user] attaches [T] to [src]!</span>")
		T.forceMove(src)
		bomb = T
		update_icon()
		return TRUE
	return ..()

/obj/item/gun/blastcannon/proc/calculate_bomb()
	if(!istype(bomb)||!istype(bomb.tank_one)||!istype(bomb.tank_two))
		return 0
	var/datum/gas_mixture/temp = new()	//directional buff.
	temp.volume = 60
	temp.merge(bomb.tank_one.air_contents.remove_ratio(1))
	temp.merge(bomb.tank_two.air_contents.remove_ratio(2))
	for(var/i in 1 to 6)
		temp.react()
	var/pressure = temp.return_pressure()
	qdel(temp)
	if(pressure < TANK_FRAGMENT_PRESSURE)
		return 0
	return (pressure / TANK_FRAGMENT_SCALE)

/obj/item/gun/blastcannon/afterattack(atom/target, mob/user, flag, params)
	if((!bomb) || (!target) || (get_dist(get_turf(target), get_turf(user)) <= 2))
		return ..()
	var/power = calculate_bomb()
	QDEL_NULL(bomb)
	update_icon()
	var/heavy = power * 0.2
	var/medium = power * 0.5
	var/light = power
	user.visible_message("<span class='danger'>[user] opens [bomb] on [user.p_their()] [name] and fires a blast wave at [target]!</span>","<span class='danger'>You open [bomb] on your [name] and fire a blast wave at [target]!</span>")
	playsound(user, "explosion", 100, 1)
	var/turf/starting = get_turf(user)
	var/turf/targturf = get_turf(target)
	message_admins("Blast wave fired from [ADMIN_COORDJMP(starting)] ([get_area_name(user, TRUE)]) at [ADMIN_COORDJMP(targturf)] ([target.name]) by [key_name_admin(user)] with power [heavy]/[medium]/[light].")
	log_game("Blast wave fired from ([starting.x], [starting.y], [starting.z]) ([get_area_name(user, TRUE)]) at ([target.x], [target.y], [target.z]) ([target]) by [key_name(user)] with power [heavy]/[medium]/[light].")
	var/obj/item/projectile/blastwave/BW = new(loc, heavy, medium, light)
	BW.preparePixelProjectile(target, get_turf(target), user, params, 0)
	BW.fire()

/obj/item/projectile/blastwave
	name = "blast wave"
	icon_state = "blastwave"
	damage = 0
	nodamage = FALSE
	forcedodge = TRUE
	range = 150
	var/heavyr = 0
	var/mediumr = 0
	var/lightr = 0

/obj/item/projectile/blastwave/New(loc, _h, _m, _l)
	..()
	heavyr = _h
	mediumr = _m
	lightr = _l

/obj/item/projectile/blastwave/Range()
	..()
	var/amount_destruction = 0
	if(heavyr)
		amount_destruction = EXPLODE_DEVASTATE
	else if(mediumr)
		amount_destruction = EXPLODE_HEAVY
	else if(lightr)
		amount_destruction = EXPLODE_LIGHT
	if(amount_destruction && isturf(loc))
		var/turf/T = loc
		for(var/thing in T.contents)
			var/atom/AM = thing
			if(AM && AM.simulated)
				AM.ex_act(amount_destruction)
				CHECK_TICK
		T.ex_act(amount_destruction)
	else
		qdel(src)
	heavyr = max(heavyr - 1, 0)
	mediumr = max(mediumr - 1, 0)
	lightr = max(lightr - 1, 0)

/obj/item/projectile/blastwave/ex_act()
	return

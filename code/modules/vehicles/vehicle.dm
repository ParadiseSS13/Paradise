/obj/vehicle
	name = "vehicle"
	icon = 'icons/obj/vehicles.dmi'
	layer = MOB_LAYER + 0.1 //so it sits above objects including mobs
	density = 1
	anchored = 1
	animate_movement=1
	luminosity = 3

	var/attack_log = null
	var/on = 0
	var/health = 0	//do not forget to set health for your vehicle!
	var/maxhealth = 0
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0	//Maint panel
	var/locked = 1
	var/stat = 0
	var/emagged = 0
	var/powered = 0		//set if vehicle is powered and should use fuel when moving
	var/move_delay = 1	//set this to limit the speed of the vehicle
	var/movable = 1

	var/obj/item/weapon/cell/cell
	var/charge_use = 5	//set this to adjust the amount of power the vehicle uses per move

	var/atom/movable/load		//all vehicles can take a load, since they should all be a least drivable
	var/load_item_visible = 1	//set if the loaded item should be overlayed on the vehicle sprite
	var/load_offset_x = 0		//pixel_x offset for item overlay
	var/load_offset_y = 0		//pixel_y offset for item overlay
	var/mob_offset_y = 0		//pixel_y offset for mob overlay

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/New()
	..()
	//spawn the cell you want in each vehicle

/obj/vehicle/Move()
	if(world.time > l_move_time + move_delay)
		if(on && powered && cell.charge < charge_use)
			turn_off()

		var/init_anc = anchored
		anchored = 0
		if(!..())
			anchored = init_anc
			return 0

		anchored = init_anc

		if(on && powered)
			cell.use(charge_use)

		if(load)
			load.forceMove(loc)// = loc
			load.dir = dir

		return 1
	else
		return 0

/obj/vehicle/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/hand_labeler))
		return
	if(istype(W, /obj/item/weapon/screwdriver))
		if(!locked)
			open = !open
			update_icon()
			user << "<span class='notice'>Maintenance panel is now [open ? "opened" : "closed"].</span>"
	else if(istype(W, /obj/item/weapon/crowbar) && cell && open)
		remove_cell(user)

	else if(istype(W, /obj/item/weapon/cell) && !cell && open)
		insert_cell(W, user)
	else if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/T = W
		if(T.welding)
			if(health < maxhealth)
				if(open)
					health = min(maxhealth, health+10)
					user.visible_message("\red [user] repairs [src]!","\blue You repair [src]!")
				else
					user << "<span class='notice'>Unable to repair with the maintenance panel closed.</span>"
			else
				user << "<span class='notice'>[src] does not need a repair.</span>"
		else
			user << "<span class='notice'>Unable to repair while [src] is off.</span>"
	else if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		Emag(user)
	else if(hasvar(W,"force") && hasvar(W,"damtype"))
		switch(W.damtype)
			if("fire")
				health -= W.force * fire_dam_coeff
			if("brute")
				health -= W.force * brute_dam_coeff
		..()
		healthcheck()
	else
		..()

/obj/vehicle/attack_animal(var/mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)	return
	health -= M.melee_damage_upper
	src.visible_message("\red <B>[M] has [M.attacktext] [src]!</B>")
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
	if(prob(10))
		new /obj/effect/decal/cleanable/oil(src.loc)
	healthcheck()

/obj/vehicle/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()

/obj/vehicle/meteorhit()
	explode()
	return

/obj/vehicle/blob_act()
	src.health -= rand(20,40)*fire_dam_coeff
	healthcheck()
	return

/obj/vehicle/ex_act(severity)
	switch(severity)
		if(1.0)
			explode()
			return
		if(2.0)
			health -= rand(5,10)*fire_dam_coeff
			health -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3.0)
			if (prob(50))
				health -= rand(1,5)*fire_dam_coeff
				health -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

/obj/vehicle/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = 1
	pulse2.dir = pick(cardinal)

	spawn(10)
		pulse2.delete()
	if(on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if(was_on)
			turn_on()

/obj/vehicle/attack_ai(mob/user as mob)
	return

/obj/vehicle/proc/handle_rotation()
	return

//-------------------------------------------
// Vehicle procs
//-------------------------------------------
/obj/vehicle/proc/turn_on()
	if(stat)
		return 0
	if(powered && cell.charge < charge_use)
		return 0
	on = 1
	luminosity = initial(luminosity)
	update_icon()
	return 1

/obj/vehicle/proc/turn_off()
	on = 0
	luminosity = 0
	update_icon()

/obj/vehicle/proc/Emag(mob/user as mob)
	emagged = 1

	if(locked)
		locked = 0
		user << "<span class='warning'>You bypass [src]'s controls.</span>"

/obj/vehicle/proc/explode()
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)

	if(cell)
		cell.forceMove(Tsec)
		cell.update_icon()
		cell = null

	//stuns people who are thrown off a train that has been blown up
	if(istype(load, /mob/living))
		var/mob/living/M = load
		M.apply_effects(5, 5)

	unload()

	new /obj/effect/gibspawner/robot(Tsec)
	new /obj/effect/decal/cleanable/oil(src.loc)

	del(src)

/obj/vehicle/proc/healthcheck()
	if(health <= 0)
		explode()

/obj/vehicle/proc/powercheck()
	if(!cell && !powered)
		return

	if(!cell && powered)
		turn_off()
		return

	if(cell.charge < charge_use)
		turn_off()
		return

	if(cell && powered)
		turn_on()
		return

/obj/vehicle/proc/insert_cell(var/obj/item/weapon/cell/C, var/mob/living/carbon/human/H)
	if(cell)
		return
	if(!istype(C))
		return

	H.drop_from_inventory(C)
	C.forceMove(src)
	cell = C
	powercheck()
	usr << "<span class='notice'>You install [C] in [src].</span>"

/obj/vehicle/proc/remove_cell(var/mob/living/carbon/human/H)
	if(!cell)
		return

	usr << "<span class='notice'>You remove [cell] from [src].</span>"
	cell.forceMove(get_turf(H))
	H.put_in_hands(cell)
	cell = null
	powercheck()

/obj/vehicle/proc/RunOver(var/mob/living/carbon/human/H)
	return		//write specifics for different vehicles

//-------------------------------------------
// Loading/unloading procs
//
// Set specific item restriction checks in
// the vehicle load() definition before
// calling this parent proc.
//-------------------------------------------
/obj/vehicle/proc/load(var/atom/movable/C)
	//define allowed items for loading in specific vehicle definitions

	if(!isturf(C.loc)) //To prevent loading things from someone's inventory, which wouldn't get handled properly.
		return 0
	if(load || C.anchored)
		return 0

	// if a create/closet, close before loading
	var/obj/structure/closet/crate = C
	if(istype(crate))
		crate.close()

	C.forceMove(loc)
	C.dir = dir
	C.anchored = 1

	load = C

	if(load_item_visible)
		C.pixel_x += load_offset_x
		if(ismob(C))
			C.pixel_y += mob_offset_y
		else
			C.pixel_y += load_offset_y
		C.layer = layer + 0.1		//so it sits above the vehicle

	if(ismob(C))
		var/mob/M = C
		M.buckled = src
		M.update_canmove()

	return 1


/obj/vehicle/proc/unload(var/mob/user, var/direction)
	if(!load)
		return

	var/turf/dest = null

	//find a turf to unload to
	if(direction)	//if direction specified, unload in that direction
		dest = get_step(src, direction)
	else if(user)	//if a user has unloaded the vehicle, unload at their feet
		dest = get_turf(user)

	if(!dest)
		dest = get_step_to(src, get_step(src, turn(dir, 90))) //try unloading to the side of the vehicle first if neither of the above are present

	//if these all result in the same turf as the vehicle or nullspace, pick a new turf with open space
	if(!dest || dest == get_turf(src))
		var/list/options = new()
		for(var/test_dir in alldirs)
			var/new_dir = get_step_to(src, get_step(src, test_dir))
			if(new_dir && load.Adjacent(new_dir))
				options += new_dir
		if(options.len)
			dest = pick(options)
		else
			dest = get_turf(src)	//otherwise just dump it on the same turf as the vehicle

	if(!isturf(dest))	//if there still is nowhere to unload, cancel out since the vehicle is probably in nullspace
		return 0

	load.forceMove(dest)
	load.dir = get_dir(loc, dest)
	load.anchored = initial(load.anchored)
	load.pixel_x = initial(load.pixel_x)
	load.pixel_y = initial(load.pixel_y)
	load.layer = initial(load.layer)

	if(ismob(load))
		var/mob/M = load
		M.buckled = null
		M.anchored = initial(M.anchored)
		M.update_canmove()

	load = null

	return 1


//-------------------------------------------------------
// Stat update procs
//-------------------------------------------------------
/obj/vehicle/proc/update_stats()
	return
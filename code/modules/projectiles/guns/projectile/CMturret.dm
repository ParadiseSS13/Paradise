/mob/living/carbon/human
	var/obj/structure/machinegun/mounted

/mob/living/carbon/human/ClickOn(atom/A, params)
    if(mounted && Adjacent(mounted))
        if(next_move < world.time)
            mounted.shoot(get_turf(A))
    else
        . = ..()


/obj/structure/machinegun
	name = "machine gun"
	desc = "A stationary machine gun."
	icon = 'icons/obj/structures.dmi'
	icon_state = "mgun+barrier"
	var/fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	var/empty_sound = 'sound/weapons/empty.ogg'
	var/ammo_type = "/obj/item/projectile/bullet/midbullet2"
	var/ammo = 500
	var/ammomax = 500
	var/list/row1 = list()
	var/list/row2 = list()
	var/list/row3 = list()
	var/mob/living/carbon/human/user
	var/FIRETIME = 1 //tenths of seconds
	density = 1
	anchored = 0
	flags = ON_BORDER
	var/health = 500

/obj/structure/machinegun/process()
	var/mob/living/carbon/human/U
	for(var/mob/living/carbon/human/H in range(0, src))
		if(H)
			U = H
	if(U)
		if(user && user != U)
			user.mounted = null
			user = null
		user = U
		user.mounted = src
	else
		if(user)
			user.mounted = null
			user = null

/obj/structure/machinegun/Destroy()
	user.mounted = null
	user = null
	return ..()

/obj/structure/machinegun/New()
	..()
	processing_objects.Add(src)

/obj/structure/machinegun/proc/shoot(var/turf/T)
	if(ammo <= 0)
		if(user)
			playsound(src, empty_sound, 70, 1)
			to_chat(user, "This machine gun is out of ammo!")

		return
	if(T && user && !user.incapacitated())
		var/row = 0
		if(row1.Find(T))
			row = 1
		else if(row2.Find(T))
			row = 2
		else if(row3.Find(T))
			row = 3
		if(row)
			var/turf/shootfrom
			switch(row)
				if(1)
					shootfrom = get_step(src, turn(dir, 90))
				if(2)
					shootfrom = get_step(src, dir)
				if(3)
					shootfrom = get_step(src, turn(dir, 270))
			if(shootfrom)

				var/turf/curloc = get_turf(shootfrom)
				var/turf/targloc
				switch(row)
					if(1)
						targloc = row1[7]
					if(2)
						targloc = row2[7]
					if(3)
						targloc = row3[7]
				if (!istype(targloc) || !istype(curloc))
					return
				playsound(src, fire_sound, 50, 1)
				var/obj/item/projectile/bullet = new ammo_type(shootfrom)
				bullet.firer = user
				bullet.def_zone = user.zone_sel.selecting
				bullet.original = T
				bullet.loc = get_turf(shootfrom)
				bullet.starting = get_turf(shootfrom)
				bullet.shot_from = src
				bullet.silenced = 0
				bullet.current = curloc
				bullet.yo = targloc.y - curloc.y
				bullet.xo = targloc.x - curloc.x
				ammo--
				spawn()
					if(bullet)
						bullet.process()
				user.changeNext_move(CLICK_CD_MOUNTED)


/obj/structure/machinegun/proc/update_rows()
	row1 = list()
	row2 = list()
	row3 = list()
	//row1 + 90
	//row2 + 0
	//row3 - 90

	//row1
	var/turf/pos = get_step(src, dir)
	pos = get_step(pos, turn(dir, 90))
	row1.Add(pos)
	var/i
	for(i=2, i<8, i++)
		row1.Add(get_turf(get_step(row1[i - 1], dir)))
	//row2
	pos = get_step(src, dir)
	row2.Add(pos)
	for(i=2, i<8, i++)
		row2.Add(get_turf(get_step(row2[i - 1], dir)))
	//row3
	pos = get_step(src, dir)
	pos = get_step(pos, turn(dir, 270))
	row3.Add(pos)
	for(i=2, i<8, i++)
		row3.Add(get_turf(get_step(row3[i - 1], dir)))


/obj/structure/machinegun/attackby(obj/item/W as obj, mob/user as mob)
	var/obj/item/machinegunammo/Ammo = W
	default_unfasten_wrench(user, W, 40)
	update_rows()
	if(Ammo)
		if(ammo < ammomax)
			var/amt = ammomax - ammo
			if(Ammo.count > amt)
				Ammo.count -= amt
				Ammo.desc = "Machine gun ammo. It has [Ammo.count] rounds remaining"
			else
				amt = Ammo.count
				del(Ammo)
			ammo = ammo + amt

	else
		return ..()


/obj/structure/machinegun/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if (get_dir(loc, target) == dir)
		return !density
	else
		return 1
	return 0

//checks if projectile 'P' from turf 'from' can hit whatever is behind the table. Returns 1 if it can, 0 if bullet stops.
/obj/structure/machinegun/proc/check_cover(obj/item/projectile/P, turf/from)
	var/turf/cover = get_turf(src)
	if (get_dist(P.starting, loc) <= 1) //Tables won't help you if people are THIS close
		return 1
	if (get_turf(P.original) == cover)
		var/chance = 50
		if (ismob(P.original))
			var/mob/M = P.original
			if (M.lying)
				chance += 20				//Lying down lets you catch less bullets

		if(get_dir(loc, from) == dir)	//Flipped tables catch more bullets
			chance += 20
		else
			return 1					//But only from one side
		if(prob(chance))
			health -= P.damage/2
			if (health > 0)
				visible_message("<span class='warning'>[P] hits \the [src]!</span>")
				return 0
			else
				visible_message("<span class='warning'>[src] breaks down!</span>")
				del(src)
				return 1
	return 1

/obj/structure/machinegun/CheckExit(atom/movable/O as mob|obj, target as turf)

	if (get_dir(loc, target) == dir)
		return !density
	else
		return 1
	return 1

/obj/item/machinegunammo
	icon = 'icons/obj/structures.dmi'
	icon_state = "mgun_crate"
	name = "machinegun ammo"
	desc = "Machine gun ammo. It has 500 rounds remaining"
	var/count = 500
	w_class = 2
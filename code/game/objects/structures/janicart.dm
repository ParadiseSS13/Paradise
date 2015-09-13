/obj/structure/stool/bed/chair/cart/
	icon = 'icons/obj/vehicles.dmi'
	anchored = 1
	density = 1
	var/empstun = 0
	var/health = 100
	var/destroyed = 0
	var/inertia_dir = 0
	var/allowMove = 1
	var/delay = 1
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread

/obj/structure/stool/bed/chair/cart/Move()
	..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc

/obj/structure/stool/bed/chair/cart/process()
	if(empstun > 0)
		empstun--
	if(empstun < 0)
		empstun = 0

/obj/structure/stool/bed/chair/cart/New()
	processing_objects |= src
	handle_rotation()

/obj/structure/stool/bed/chair/cart/examine()
	set src in usr
	switch(health)
		if(75 to 99)
			usr << "\blue It appears slightly dented."
		if(40 to 74)
			usr << "\red It appears heavily dented."
		if(1 to 39)
			usr << "\red It appears severely dented."
		if((INFINITY * -1) to 0)
			usr << "It appears completely unsalvageable"

/obj/structure/stool/bed/chair/cart/attackby(obj/item/W, mob/user, params)
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0))
			if(destroyed)
				user << "\red The [src.name] is destroyed beyond repair."
			add_fingerprint(user)
			user.visible_message("\blue [user] has fixed some of the dents on [src].", "\blue You fix some of the dents on \the [src]")
			health += 20
			HealthCheck()
		else
			user << "Need more welding fuel!"
			return
	if(istype(W, /obj/item/key))
		user << "Hold [W] in one of your hands while you drive this [name]."

/obj/structure/stool/bed/chair/cart/proc/Process_Spacemove(var/check_drift = 0, mob/user)
	//First check to see if we can do things

	/*
	if(istype(src,/mob/living/carbon))
		if(src.l_hand && src.r_hand)
			return 0
	*/

	var/dense_object = 0
	if(!user)
		for(var/turf/turf in oview(1,src))
			if(istype(turf,/turf/space))
				continue
			/*
			if((istype(turf,/turf/simulated/floor))
				if(user)
					if(user.lastarea.has_gravity == 0)
						continue*/



		/*
		if(istype(turf,/turf/simulated/floor) && (src.flags & NOGRAV))
			continue
		*/


			dense_object++
			break

		if(!dense_object && (locate(/obj/structure/lattice) in oview(1, src)))
			dense_object++

		//Lastly attempt to locate any dense objects we could push off of
		//TODO: If we implement objects drifing in space this needs to really push them
		//Due to a few issues only anchored and dense objects will now work.
		if(!dense_object)
			for(var/obj/O in oview(1, src))
				if((O) && (O.density) && (O.anchored))
					dense_object++
					break
	else
		for(var/turf/turf in oview(1,user))
			if(istype(turf,/turf/space))
				continue
			/*
			if((istype(turf,/turf/simulated/floor))
				if(user)
					if(user.lastarea.has_gravity == 0)
						continue*/



		/*
		if(istype(turf,/turf/simulated/floor) && (src.flags & NOGRAV))
			continue
		*/


			dense_object++
			break

		if(!dense_object && (locate(/obj/structure/lattice) in oview(1, user)))
			dense_object++

		//Lastly attempt to locate any dense objects we could push off of
		//TODO: If we implement objects drifing in space this needs to really push them
		//Due to a few issues only anchored and dense objects will now work.
		if(!dense_object)
			for(var/obj/O in oview(1, user))
				if((O) && (O.density) && (O.anchored))
					dense_object++
					break
	//Nothing to push off of so end here
	if(!dense_object)
		return 0


/* The cart has very grippy tires and or magnets to keep it from slipping when on a good surface
	//Check to see if we slipped
	if(prob(Process_Spaceslipping(5)))
		src << "\blue <B>You slipped!</B>"
		src.inertia_dir = src.last_move
		step(src, src.inertia_dir)
		return 0
	//If not then we can reset inertia and move
	*/
	inertia_dir = 0
	return 1

/obj/structure/stool/bed/chair/cart/buckle_mob(mob/M, mob/user)
	if(M != user || !ismob(M) || get_dist(src, user) > 1 || user.restrained() || user.lying || user.stat || M.buckled || istype(user, /mob/living/silicon) || destroyed)
		return

	unbuckle()

	M.visible_message(\
		"<span class='notice'>[M] climbs onto the [name]!</span>",\
		"<span class='notice'>You climb onto the [name]!</span>")
	M.buckled = src
	M.loc = loc
	M.dir = dir
	M.update_canmove()
	buckled_mob = M
	update_mob()
	add_fingerprint(user)
	return

/obj/structure/stool/bed/chair/cart/unbuckle()
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	..()

/obj/structure/stool/bed/chair/cart/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()

/obj/structure/stool/bed/chair/cart/proc/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -13
				buckled_mob.pixel_y = 7

/obj/structure/stool/bed/chair/cart/emp_act(severity)
	switch(severity)
		if(1)
			src.empstun = (rand(5,10))
		if(2)
			src.empstun = (rand(1,5))
	src.visible_message("\red The [src.name]'s motor short circuits!")
	spark_system.attach(src)
	spark_system.set_up(5, 0, src)
	spark_system.start()

/obj/structure/stool/bed/chair/cart/bullet_act(var/obj/item/projectile/Proj)
	var/hitrider = 0
	if(istype(Proj, /obj/item/projectile/ion))
		Proj.on_hit(src, 2)
		return
	if(buckled_mob)
		if(prob(75))
			hitrider = 1
			var/act = buckled_mob.bullet_act(Proj)
			if(act >= 0)
				visible_message("<span class='warning'>[buckled_mob.name] is hit by [Proj]!")
				if(istype(Proj, /obj/item/projectile/energy))
					unbuckle()
			return
		if(istype(Proj, /obj/item/projectile/energy/electrode))
			if(prob(25))
				unbuckle()
				visible_message("<span class='warning'>The [src.name] absorbs the [Proj]")
				if(!istype(buckled_mob, /mob/living/carbon/human))
					return buckled_mob.bullet_act(Proj)
				else
					var/mob/living/carbon/human/H = buckled_mob
					return H.electrocute_act(0, src, 1, 0)
	if(!hitrider)
		visible_message("<span class='warning'>[Proj] hits the [name]!</span>")
		if(!Proj.nodamage && Proj.damage_type == BRUTE || Proj.damage_type == BURN)
			health -= Proj.damage
		HealthCheck()

/obj/structure/stool/bed/chair/cart/proc/HealthCheck()
	if(health > 100) health = 100
	if(health <= 0 && !destroyed)
		destroyed = 1
		density = 0
		if(buckled_mob)
			unbuckle()
		visible_message("<span class='warning'>The [name] explodes!</span>")
		explosion(src.loc,-1,0,2,7,10)
		icon_state = "pussywagon_destroyed"

/obj/structure/stool/bed/chair/cart/ex_act(severity)
	switch (severity)
		if(1.0)
			health -= 100
		if(2.0)
			health -= 75
		if(3.0)
			health -= 45
	HealthCheck()


/////////////////////////////////////////////////////////////////////////

/obj/structure/stool/bed/chair/cart/janicart
	name = "janicart"
	icon_state = "pussywagon"
	flags = OPENCONTAINER
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null




/obj/structure/stool/bed/chair/cart/janicart/New()
	..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src


/obj/structure/stool/bed/chair/cart/janicart/examine()
	..()
	usr << "\icon[src] This [name] contains [reagents.total_volume] unit\s of [reagents]!"
	if(mybag)
		usr << "\A [mybag] is hanging on the [name]."

/obj/structure/stool/bed/chair/cart/janicart/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/mop))
		if(reagents.total_volume >= 2)
			reagents.trans_to(W, 2)
			user << "<span class='notice'>You wet the mop in the pimpin' ride.</span>"
			playsound(src.loc, 'sound/effects/slosh.ogg', 25, 1)
		if(reagents.total_volume < 1)
			user << "<span class='notice'>This pimpin' ride is out of water!</span>"
	else if(istype(W, /obj/item/weapon/storage/bag/trash))
		user << "<span class='notice'>You hook the trashbag onto the pimpin' ride.</span>"
		user.drop_item()
		W.loc = src
		mybag = W


/obj/structure/stool/bed/chair/cart/janicart/attack_hand(mob/user)
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
	else
		..()


/obj/structure/stool/bed/chair/cart/janicart/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis  || destroyed)
		unbuckle()
		return
	if(empstun > 0)
		if(user)
			user << "\red \the [src] is unresponsive."
		return
	if((istype(src.loc, /turf/space)))
		if(!src.Process_Spacemove(0))	return
	if(istype(user.l_hand, /obj/item/key) || istype(user.r_hand, /obj/item/key))
		if(!allowMove)
			return
		allowMove = 0
		step(src, direction)
		update_mob()
		handle_rotation()
		sleep(delay)
		allowMove = 1
			/*
		if(istype(src.loc, /turf/space) && (!src.Process_Spacemove(0, user)))
			var/turf/space/S = src.loc
			S.Entered(src)*/
	else
		user << "<span class='notice'>You'll need the keys in one of your hands to drive this pimpin' ride.</span>"

////////////////////////////////////////////////////////////////////////////////////////////////

/obj/structure/stool/bed/chair/cart/ambulance
	name = "ambulance"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "docwagon"
	anchored = 1
	density = 1
/var/brightness = 4
/var/strobe = 0

/obj/structure/stool/bed/chair/cart/ambulance/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis  || destroyed)
		unbuckle()
		return
	if(empstun > 0)
		if(user)
			user << "\red \the [src] is unresponsive."
		return
	if((istype(src.loc, /turf/space)))
		if(!src.Process_Spacemove(0))	return
	if(istype(user.l_hand, /obj/item/key) || istype(user.r_hand, /obj/item/key))
		if(!allowMove)
			return
		allowMove = 0
		step(src, direction)
		// NEW PULLING CODE
		if (istype(user.pulling, /obj/structure/stool/bed/roller))
			var/turf/T = loc
			step(user.pulling, get_dir(user.pulling.loc, T))

		// END NEW PULLING CODE
		update_mob()
		handle_rotation()
		sleep(delay)
		allowMove = 1
		/*
		if(istype(src.loc, /turf/space) && (!src.Process_Spacemove(0, user)))
			var/turf/space/S = src.loc
			S.Entered(src)*/
	else
		user << "<span class='notice'>You'll need the keys in one of your hands to drive this ambulance.</span>"










/obj/item/key
	name = "key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = 1

/obj/item/key/ambulance
	name = "ambulance key"
	desc = "A keyring with a small steel key, and tag with a red cross on it."
	icon_state = "keydoc"

//TG style Janicart

/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "This is the alpha and omega of sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = 0
	density = 1
	flags = OPENCONTAINER
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null
	var/obj/item/weapon/mop/mymop = null
	var/obj/item/weapon/reagent_containers/spray/cleaner/myspray = null
	var/obj/item/device/lightreplacer/myreplacer = null
	var/signs = 0
	var/const/max_signs = 4


/obj/structure/janitorialcart/New()
	create_reagents(100)


/obj/structure/janitorialcart/proc/wet_mop(obj/item/weapon/mop, mob/user)
	if(reagents.total_volume < 1)
		user << "[src] is out of water!</span>"
	else
		reagents.trans_to(mop, 5)	//
		user << "<span class='notice'>You wet [mop] in [src].</span>"
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

/obj/structure/janitorialcart/proc/put_in_cart(obj/item/I, mob/user)
	user.drop_item()
	I.loc = src
	updateUsrDialog()
	user << "<span class='notice'>You put [I] into [src].</span>"
	return


/obj/structure/janitorialcart/attackby(obj/item/I, mob/user, params)
	var/fail_msg = "<span class='notice'>There is already one of those in [src].</span>"

	if(!I.is_robot_module())
		if(istype(I, /obj/item/weapon/mop))
			var/obj/item/weapon/mop/m=I
			if(m.reagents.total_volume < m.reagents.maximum_volume)
				wet_mop(m, user)
				return
			if(!mymop)
				m.janicart_insert(user, src)
			else
				user << fail_msg

		else if(istype(I, /obj/item/weapon/storage/bag/trash))
			if(!mybag)
				var/obj/item/weapon/storage/bag/trash/t=I
				t.janicart_insert(user, src)
			else
				user <<  fail_msg
		else if(istype(I, /obj/item/weapon/reagent_containers/spray/cleaner))
			if(!myspray)
				put_in_cart(I, user)
				myspray=I
				update_icon()
			else
				user << fail_msg
		else if(istype(I, /obj/item/device/lightreplacer))
			if(!myreplacer)
				var/obj/item/device/lightreplacer/l=I
				l.janicart_insert(user,src)
			else
				user << fail_msg
		else if(istype(I, /obj/item/weapon/caution))
			if(signs < max_signs)
				put_in_cart(I, user)
				signs++
				update_icon()
			else
				user << "<span class='notice'>[src] can't hold any more signs.</span>"
		else if(istype(I, /obj/item/weapon/crowbar))
			user.visible_message("<span class='warning'>[user] begins to empty the contents of [src].</span>")
			if(do_after(user, 30, target = src))
				usr << "<span class='notice'>You empty the contents of [src]'s bucket onto the floor.</span>"
				reagents.reaction(src.loc)
				src.reagents.clear_reagents()
		else if(istype(I, /obj/item/weapon/wrench))
			if (!anchored && !isinspace())
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message( \
					"[user] tightens \the [src]'s casters.", \
					"<span class='notice'> You have tightened \the [src]'s casters.</span>", \
					"You hear ratchet.")
				anchored = 1
			else if(anchored)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message( \
					"[user] loosens \the [src]'s casters.", \
					"<span class='notice'> You have loosened \the [src]'s casters.</span>", \
					"You hear ratchet.")
				anchored = 0
		else if(mybag)
			mybag.attackby(I, user, params)
	else
		usr << "<span class='warning'>You cannot interface your modules [src]!</span>"

/obj/structure/janitorialcart/attack_hand(mob/user)
	user.set_machine(src)
	var/dat
	if(mybag)
		dat += "<a href='?src=\ref[src];garbage=1'>[mybag.name]</a><br>"
	if(mymop)
		dat += "<a href='?src=\ref[src];mop=1'>[mymop.name]</a><br>"
	if(myspray)
		dat += "<a href='?src=\ref[src];spray=1'>[myspray.name]</a><br>"
	if(myreplacer)
		dat += "<a href='?src=\ref[src];replacer=1'>[myreplacer.name]</a><br>"
	if(signs)
		dat += "<a href='?src=\ref[src];sign=1'>[signs] sign\s</a><br>"
	var/datum/browser/popup = new(user, "janicart", name, 240, 160)
	popup.set_content(dat)
	popup.open()


/obj/structure/janitorialcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["garbage"])
		if(mybag)
			user.put_in_hands(mybag)
			user << "<span class='notice'>You take [mybag] from [src].</span>"
			mybag = null
	if(href_list["mop"])
		if(mymop)
			user.put_in_hands(mymop)
			user << "<span class='notice'>You take [mymop] from [src].</span>"
			mymop = null
	if(href_list["spray"])
		if(myspray)
			user.put_in_hands(myspray)
			user << "<span class='notice'>You take [myspray] from [src].</span>"
			myspray = null
	if(href_list["replacer"])
		if(myreplacer)
			user.put_in_hands(myreplacer)
			user << "<span class='notice'>You take [myreplacer] from [src].</span>"
			myreplacer = null
	if(href_list["sign"])
		if(signs)
			var/obj/item/weapon/caution/Sign = locate() in src
			if(Sign)
				user.put_in_hands(Sign)
				user << "<span class='notice'>You take \a [Sign] from [src].</span>"
				signs--
			else
				WARNING("Signs ([signs]) didn't match contents")
				signs = 0

	update_icon()
	updateUsrDialog()


/obj/structure/janitorialcart/update_icon()
	overlays = null
	if(mybag)
		overlays += "cart_garbage"
	if(mymop)
		overlays += "cart_mop"
	if(myspray)
		overlays += "cart_spray"
	if(myreplacer)
		overlays += "cart_replacer"
	if(signs)
		overlays += "cart_sign[signs]"
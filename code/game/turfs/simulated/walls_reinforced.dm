/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "r_wall"
	opacity = 1
	density = 1
	explosion_block = 2
	damage_cap = 200
	max_temperature = 6000
	hardness = 10
	walltype = "rwall"

	var/d_state = 0

/turf/simulated/wall/r_wall/attackby(obj/item/W as obj, mob/user as mob, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such

	if(rotting)
		if(istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.remove_fuel(0,user) )
				user << "<span class='notice'>You burn away the fungi with \the [WT].</span>"
				playsound(src, 'sound/items/Welder.ogg', 10, 1)
				for(var/obj/effect/E in src) if(E.name == "Wallrot")
					qdel(E)
				rotting = 0
				return
		else if(!is_sharp(W) && W.force >= 10 || W.force >= 20)
			user << "<span class='notice'>\The [src] crumbles away under the force of your [W.name].</span>"
			src.dismantle_wall()
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if( thermite )
		if( istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.remove_fuel(0,user) )
				thermitemelt(user)
				return

		else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
			thermitemelt(user)
			return

		else if( istype(W, /obj/item/weapon/melee/energy/blade) )
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			user << "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>"
			playsound(src, "sparks", 50, 1)
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)

			thermitemelt(user)
			return

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		user << "<span class='notice'>This wall is too thick to slice through. You will need to find a different path.</span>"
		return

	if(damage && istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			user << "<span class='notice'>You start repairing the damage to [src].</span>"
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(do_after(user, max(5, damage / 5), target = src) && WT && WT.isOn())
				user << "<span class='notice'>You finish repairing the damage to [src].</span>"
				take_damage(-damage)
			return
		else
			user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
			return


	//DECONSTRUCTION
	switch(d_state)
		if(0)
			if(istype(W, /obj/item/weapon/wirecutters))
				playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
				d_state = 1
				icon_state = "r_wall-1"
				new /obj/item/stack/rods(src)
				user << "<span class='notice'>You cut the outer grille.</span>"
				return

		if(1)
			if (istype(W, /obj/item/weapon/screwdriver))
				user << "<span class='notice'>You begin removing the support lines.</span>"
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)

				if(do_after(user, 40, target = src) && d_state == 1)
					d_state = 2
					icon_state = "r_wall-2"
					user << "<span class='notice'>You remove the support lines.</span>"
				return

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/O = W
				if(O.use(1))
					d_state = 0
					icon_state = "r_wall"
					relativewall_neighbours()	//call smoothwall stuff
					user << "<span class='notice'>You replace the outer grille.</span>"
				else
					user << "<span class='warning'>You don't have enough rods for that!</span>"

		if(2)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					user << "<span class='notice'>You begin slicing through the metal cover.</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, 60, target = src) && d_state == 2)
						d_state = 3
						icon_state = "r_wall-3"
						user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"

				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return

			if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
				user << "<span class='notice'>You begin slicing through the metal cover.</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 40, target = src) && d_state == 2)
					d_state = 3
					icon_state = "r_wall-3"
					user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return

		if(3)
			if(istype(W, /obj/item/weapon/crowbar))
				user << "<span class='notice'>You struggle to pry off the cover.</span>"
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user, 100, target = src) && d_state == 3)
					d_state = 4
					icon_state = "r_wall-4"
					user << "<span class='notice'>You pry off the cover.</span>"
				return

		if(4)
			if(istype(W, /obj/item/weapon/wrench))
				user << "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame.</span>"
				playsound(src, 'sound/items/Ratchet.ogg', 100, 1)

				if(do_after(user, 40, target = src) && d_state == 4)
					d_state = 5
					icon_state = "r_wall-5"
					user << "<span class='notice'>You remove the bolts anchoring the support rods.</span>"
				return

		if(5)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					user << "<span class='notice'>You begin slicing through the support rods.</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, 100, target = src) && d_state == 5)
						d_state = 6
						icon_state = "r_wall-6"
						new /obj/item/stack/rods(src)
						user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return

			if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
				user << "<span class='notice'>You begin slicing through the support rods.</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 70, target = src) && d_state == 5)
					d_state = 6
					icon_state = "r_wall-6"
					new /obj/item/stack/rods( src )
					user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
				return

		if(6)
			if(istype(W, /obj/item/weapon/crowbar))
				user << "<span class='notice'>You struggle to pry off the outer sheath.</span>"
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user, 100, target = src) && d_state == 6)
					user << "<span class='notice'>You pry off the outer sheath.</span>"
					dismantle_wall()
				return

//vv OK, we weren't performing a valid deconstruction step or igniting thermite,let's check the other possibilities vv

	//DRILLING
	if(istype(W, /obj/item/weapon/pickaxe/drill/diamonddrill))
		user << "<span class='notice'>You begin to drill though the wall.</span>"

		if(do_after(user, 200, target = src))
			user << "<span class='notice'>Your drill tears through the last of the reinforced plating.</span>"
			dismantle_wall()

	if(istype(W,/obj/item/weapon/pickaxe/drill/jackhammer))
		user << "<span class='notice'>You begin to disintegrate the wall.</span>"

		if(do_after(user, 100, target = src))
			user << "<span class='notice'>Your sonic jackhammer disintegrates the reinforced plating.</span>"
			dismantle_wall()

	//REPAIRING
	else if(istype(W, /obj/item/stack/sheet/metal) && d_state)
		var/obj/item/stack/sheet/metal/MS = W

		user << "<span class='notice'>You begin patching-up the wall with \a [MS].</span>"

		if(do_after(user, max(20 * d_state, 100), target = src) && d_state)
			if(!MS.use(1))
				user << "<span class='warning'>You don't have enough metal for that!</span>"
				return

			d_state = 0
			icon_state = "r_wall"
			relativewall_neighbours()	//call smoothwall stuff
			user << "<span class='notice'>You repair the last of the damage.</span>"


	//APC
	else if(istype(W,/obj/item/mounted))
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/contraband/poster))
		place_poster(W,user)
		return

	//Bone White - Place pipes on walls
	else if(istype(W,/obj/item/pipe))
		var/obj/item/pipe/V = W
		if(V.pipe_type != -1) // ANY PIPE
			var/obj/item/pipe/P = W

			playsound(get_turf(src), 'sound/weapons/circsawhit.ogg', 50, 1)
			user.visible_message( \
				"[user] starts drilling a hole in \the [src].", \
				"\blue You start drilling a hole in \the [src]. This is going to take a while.", \
				"You hear ratchet.")
			if (do_after(user, 160, target = src))
				user.visible_message( \
					"[user] drills a hole in \the [src] and pushes \a [P] into the void", \
					"\blue You have finished drilling in \the [src] and push the [P] into the void.", \
					"You hear ratchet.")

				user.drop_item()
				if (P.pipe_type in list (1,3,12))  // bent pipe rotation fix see construction.dm
					P.dir = 5
					if (user.dir == 1)
						P.dir = 6
					if (user.dir == 2)
						P.dir = 9
					if (user.dir == 4)
						P.dir = 10
					if (user.dir == 5)
						P.dir = 8
				else
					P.dir = user.dir
				P.x = src.x
				P.y = src.y
				P.z = src.z
				P.loc = src
				P.level = 2
		return

	//Finally, CHECKING FOR FALSE WALLS if it isn't damaged
	else if(!d_state)
		return attack_hand(user)
	return

/turf/simulated/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()
/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = 1
	explosion_block = 2
	damage_cap = 200
	max_temperature = 6000
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amount = 1
	girder_type = /obj/structure/girder/reinforced
	var/d_state = RWALL_INTACT
	var/can_be_reinforced = 1

/turf/simulated/wall/r_wall/examine(mob/user)
	..()
	switch(d_state)
		if(RWALL_INTACT)
			to_chat(user, "<span class='notice'>The outer <b>grille</b> is fully intact.</span>")
		if(RWALL_SUPPORT_LINES)
			to_chat(user, "<span class='notice'>The outer <i>grille</i> has been cut, and the support lines are <b>screwed</b> securely to the outer cover.</span>")
		if(RWALL_COVER)
			to_chat(user, "<span class='notice'>The support lines have been <i>unscrewed</i>, and the metal cover is <b>welded</b> firmly in place.</span>")
		if(RWALL_CUT_COVER)
			to_chat(user, "<span class='notice'>The metal cover has been <i>sliced through</i>, and is <b>connected loosely</b> to the girder.</span>")
		if(RWALL_BOLTS)
			to_chat(user, "<span class='notice'>The outer cover has been <i>pried away</i>, and the bolts anchoring the support rods are <b>wrenched</b> in place.</span>")
		if(RWALL_SUPPORT_RODS)
			to_chat(user, "<span class='notice'>The bolts anchoring the support rods have been <i>loosened</i>, but are still <b>welded</b> firmly to the girder.</span>")
		if(RWALL_SHEATH)
			to_chat(user, "<span class='notice'>The support rods have been <i>sliced through</i>, and the outer sheath is <b>connected loosely</b> to the girder.</span>")

/turf/simulated/wall/r_wall/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	//get the user's location
	if(!isturf(user.loc))
		return	//can't do this stuff whilst inside objects and such

	if(rotting)
		if(iswelder(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0,user))
				to_chat(user, "<span class='notice'>You burn away the fungi with \the [WT].</span>")
				playsound(src, WT.usesound, 10, 1)
				for(var/obj/effect/overlay/wall_rot/WR in src)
					qdel(WR)
				rotting = 0
				return
		else if(!is_sharp(W) && W.force >= 10 || W.force >= 20)
			to_chat(user, "<span class='notice'>\The [src] crumbles away under the force of your [W.name].</span>")
			dismantle_wall()
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(iswelder(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0,user))
				thermitemelt(user)
				return

		else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
			thermitemelt(user)
			return

		else if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			to_chat(user, "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>")
			playsound(src, "sparks", 50, 1)
			playsound(src, EB.usesound, 50, 1)

			thermitemelt(user)
			return

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		to_chat(user, "<span class='notice'>This wall is too thick to slice through. You will need to find a different path.</span>")
		return

	if(damage && iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>You start repairing the damage to [src].</span>")
			playsound(src, WT.usesound, 100, 1)
			if(do_after(user, max(5, damage / 5) * WT.toolspeed, target = src) && WT && WT.isOn())
				to_chat(user, "<span class='notice'>You finish repairing the damage to [src].</span>")
				take_damage(-damage)
			return
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return


	//DECONSTRUCTION
	switch(d_state)
		if(RWALL_INTACT)
			if(iswirecutter(W))
				playsound(src, W.usesound, 100, 1)
				d_state = RWALL_SUPPORT_LINES
				update_icon()
				new /obj/item/stack/rods(src)
				to_chat(user, "<span class='notice'>You cut the outer grille.</span>")
				return

		if(RWALL_SUPPORT_LINES)
			if(isscrewdriver(W))
				to_chat(user, "<span class='notice'>You begin unsecuring the support lines...</span>")
				playsound(src, W.usesound, 100, 1)

				if(do_after(user, 40 * W.toolspeed, target = src) && d_state == RWALL_SUPPORT_LINES)
					d_state = RWALL_COVER
					update_icon()
					to_chat(user, "<span class='notice'>You unsecure the support lines.</span>")
				return

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/O = W
				if(O.use(1))
					d_state = RWALL_INTACT
					update_icon()
					icon_state = "r_wall"
					update_icon()
					to_chat(user, "<span class='notice'>You replace the outer grille.</span>")
				else
					to_chat(user, "<span class='warning'>You don't have enough rods for that!</span>")

		if(RWALL_COVER)
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					to_chat(user, "<span class='notice'>You begin slicing through the metal cover...</span>")
					playsound(src, WT.usesound, 100, 1)

					if(do_after(user, 60 * WT.toolspeed, target = src) && d_state == RWALL_COVER)
						d_state = RWALL_CUT_COVER
						update_icon()
						to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")

				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return

			if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
				to_chat(user, "<span class='notice'>You begin slicing through the metal cover...</span>")
				playsound(src, W.usesound, 100, 1)

				if(do_after(user, 40 * W.toolspeed, target = src) && d_state == RWALL_COVER)
					d_state = RWALL_CUT_COVER
					update_icon()
					to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				return

			if(isscrewdriver(W))
				to_chat(user, "<span class='notice'>You begin securing the support lines...</span>")
				playsound(src, W.usesound, 100, 1)
				if(do_after(user, 40*W.toolspeed, target = src))
					if(!istype(src, /turf/simulated/wall/r_wall) || !W || d_state != RWALL_COVER)
						return 1
					d_state = RWALL_SUPPORT_LINES
					update_icon()
					to_chat(user, "<span class='notice'>The support lines have been secured.</span>")
				return 1

		if(RWALL_CUT_COVER)
			if(iscrowbar(W))
				to_chat(user, "<span class='notice'>You struggle to pry off the cover...</span>")
				playsound(src, W.usesound, 100, 1)

				if(do_after(user, 100 * W.toolspeed, target = src) && d_state == RWALL_CUT_COVER)
					d_state = RWALL_BOLTS
					update_icon()
					to_chat(user, "<span class='notice'>You pry off the cover.</span>")
				return

			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					to_chat(user, "<span class='notice'>You begin welding the metal cover back to the frame...</span>")
					playsound(src, WT.usesound, 100, 1)
					if(do_after(user, 60*WT.toolspeed, target = src))
						if(!istype(src, /turf/simulated/wall/r_wall) || !WT || !WT.isOn() || d_state != RWALL_CUT_COVER)
							return 1
						d_state = RWALL_COVER
						update_icon()
						to_chat(user, "<span class='notice'>The metal cover has been welded securely to the frame.</span>")
				return 1

		if(RWALL_BOLTS)
			if(iswrench(W))
				to_chat(user, "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame...</span>")
				playsound(src, W.usesound, 100, 1)

				if(do_after(user, 40 * W.toolspeed, target = src) && d_state == RWALL_BOLTS)
					d_state = RWALL_SUPPORT_RODS
					update_icon()
					to_chat(user, "<span class='notice'>You remove the bolts anchoring the support rods.</span>")
				return

			if(iscrowbar(W))
				to_chat(user, "<span class='notice'>You start to pry the cover back into place...</span>")
				playsound(src, W.usesound, 100, 1)
				if(do_after(user, 20*W.toolspeed, target = src))
					if(!istype(src, /turf/simulated/wall/r_wall) || !W || d_state != RWALL_BOLTS)
						return 1
					d_state = RWALL_CUT_COVER
					update_icon()
					to_chat(user, "<span class='notice'>The metal cover has been pried back into place.</span>")
				return 1

		if(RWALL_SUPPORT_RODS)
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					to_chat(user, "<span class='notice'>You begin slicing through the support rods...</span>")
					playsound(src, WT.usesound, 100, 1)

					if(do_after(user, 100 * WT.toolspeed, target = src) && d_state == RWALL_SUPPORT_RODS)
						d_state = RWALL_SHEATH
						update_icon()
				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return

			if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
				to_chat(user, "<span class='notice'>You begin slicing through the support rods...</span>")
				playsound(src, W.usesound, 100, 1)

				if(do_after(user, 70 * W.toolspeed, target = src) && d_state == RWALL_SUPPORT_RODS)
					d_state = RWALL_SHEATH
					update_icon()
				return

			if(iswrench(W))
				to_chat(user, "<span class='notice'>You start tightening the bolts which secure the support rods to their frame...</span>")
				playsound(src, W.usesound, 100, 1)
				if(do_after(user, 40*W.toolspeed, target = src))
					if(!istype(src, /turf/simulated/wall/r_wall) || !W || d_state != RWALL_SUPPORT_RODS)
						return 1
					d_state = RWALL_BOLTS
					update_icon()
					to_chat(user, "<span class='notice'>You tighten the bolts anchoring the support rods.</span>")
				return 1

		if(RWALL_SHEATH)
			if(iscrowbar(W))
				to_chat(user, "<span class='notice'>You struggle to pry off the outer sheath...</span>")
				playsound(src, W.usesound, 100, 1)

				if(do_after(user, 100 * W.toolspeed, target = src) && d_state == RWALL_SHEATH)
					to_chat(user, "<span class='notice'>You pry off the outer sheath.</span>")
					dismantle_wall()
				return

//vv OK, we weren't performing a valid deconstruction step or igniting thermite,let's check the other possibilities vv

	//DRILLING
	if(istype(W, /obj/item/weapon/pickaxe/drill/diamonddrill))
		to_chat(user, "<span class='notice'>You begin to drill though the wall...</span>")

		if(do_after(user, 800 * W.toolspeed, target = src)) // Diamond drill has 0.25 toolspeed, so 200
			to_chat(user, "<span class='notice'>Your drill tears through the last of the reinforced plating.</span>")
			dismantle_wall()

	if(istype(W,/obj/item/weapon/pickaxe/drill/jackhammer))
		to_chat(user, "<span class='notice'>You begin to disintegrate the wall...</span>")

		if(do_after(user, 1000 * W.toolspeed, target = src)) // Jackhammer has 0.1 toolspeed, so 100
			to_chat(user, "<span class='notice'>Your sonic jackhammer disintegrates the reinforced plating.</span>")
			dismantle_wall()

	//REPAIRING
	else if(istype(W, /obj/item/stack/sheet/metal) && d_state)
		var/obj/item/stack/sheet/metal/MS = W

		to_chat(user, "<span class='notice'>You begin patching-up the wall with \a [MS]...</span>")

		if(do_after(user, max(20 * d_state, 100) * MS.toolspeed, target = src) && d_state)
			if(!MS.use(1))
				to_chat(user, "<span class='warning'>You don't have enough metal for that!</span>")
				return

			d_state = RWALL_INTACT
			update_icon()
			smooth_icon_neighbors(src)
			to_chat(user, "<span class='notice'>You repair the last of the damage.</span>")

	//UPGRADING TO COATED
	else if(istype(W, /obj/item/stack/sheet/plasteel) && !d_state)
		var/obj/item/stack/sheet/plasteel/MS = W
		if(!can_be_reinforced)
			to_chat(user, "<span class='notice'>The wall is already coated!</span>")
			return
		to_chat(user, "<span class='notice'>You begin adding an additional layer of coating to the wall with \a [MS]...</span>")

		if(do_after(user, 40 * MS.toolspeed, target = src) && !d_state)
			if(!MS.use(2))
				to_chat(user, "<span class='warning'>You don't have enough plasteel for that!</span>")
				return
			to_chat(user, "<span class='notice'>You add an additional layer of coating to the wall.</span>")
			ChangeTurf(/turf/simulated/wall/r_wall/coated)
			update_icon()
			smooth_icon_neighbors(src)
			can_be_reinforced = 0
			return

	//APC
	else if(istype(W,/obj/item/mounted))
		return

	//Poster stuff
	else if(istype(W, /obj/item/weapon/poster))
		place_poster(W, user)
		return

	//Bone White - Place pipes on walls
	else if(istype(W,/obj/item/pipe))
		var/obj/item/pipe/V = W
		if(V.pipe_type != -1) // ANY PIPE
			var/obj/item/pipe/P = W

			playsound(get_turf(src), 'sound/weapons/circsawhit.ogg', 50, 1)
			user.visible_message( \
				"[user] starts drilling a hole in \the [src]...", \
				"<span class='notice'>You start drilling a hole in \the [src]. This is going to take a while.</span>", \
				"You hear ratchet.")
			if(do_after(user, 160 * V.toolspeed, target = src))
				user.visible_message( \
					"[user] drills a hole in \the [src] and pushes \a [P] into the void.", \
					"<span class='notice'>You have finished drilling in \the [src] and push the [P] into the void.</span>", \
					"You hear ratchet.")

				user.drop_item()
				if(P.is_bent_pipe())  // bent pipe rotation fix see construction.dm
					P.dir = 5
					if(user.dir == 1)
						P.dir = 6
					else if(user.dir == 2)
						P.dir = 9
					else if(user.dir == 4)
						P.dir = 10
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

/turf/simulated/wall/r_wall/update_icon()
	. = ..()

	if(d_state)
		icon_state = "r_wall-[d_state]"
		smooth = SMOOTH_FALSE
		clear_smooth_overlays()
	else
		smooth = SMOOTH_TRUE
		icon_state = ""

/turf/simulated/wall/r_wall/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/metal(src, 2)

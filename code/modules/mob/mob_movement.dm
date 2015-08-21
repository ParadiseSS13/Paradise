/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSMOB))
		return 1
	if(ismob(mover))
		var/mob/moving_mob = mover
		if ((other_mobs && moving_mob.other_mobs))
			return 1
		return (!mover.density || !density || lying)
	else
		return (!mover.density || !density || lying)
	return


/client/North()
	..()


/client/South()
	..()


/client/West()
	..()


/client/East()
	..()


/client/Northeast()
	swap_hand()
	return


/client/Southeast()
	attack_self()
	return


/client/Southwest()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()
	else if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		var/module = R.get_selected_module()
		if(!module)
			usr << "\red You have no module selected."
			return
		R.cycle_modules()
		R.uneq_numbered(module)
	else
		usr << "\red This mob type cannot throw items."
	return


/client/Northwest()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(!C.get_active_hand())
			usr << "\red You have nothing to drop in your hand."
			return
		drop_item()
	else if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		if(!R.get_selected_module())
			usr << "\red You have no module selected."
			return
		R.deselect_module(R.get_selected_module())
	else
		usr << "\red This mob type cannot drop items."
	return

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
		usr << "\blue You are not pulling anything."
		return
	usr.stop_pulling()

/client/verb/swap_hand()
	set hidden = 1
	if(istype(mob, /mob/living/carbon))
		mob:swap_hand()
	if(istype(mob,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = mob
		R.cycle_modules()
	return



/client/verb/attack_self()
	set hidden = 1
	if(mob)
		mob.mode()
	return


/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!istype(mob, /mob/living/carbon))
		return
	if (!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob:toggle_throw_mode()
	else
		return


/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob))
		mob.drop_item_v()
	return


/client/Center()
	/* No 3D movement in 2D spessman game. dir 16 is Z Up
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	*/
	return


/atom/movable/Move(NewLoc, direct)
	if (direct & (direct - 1))
		if (direct & 1)
			if (direct & 4)
				if (step(src, NORTH))
					step(src, EAST)
				else
					if (step(src, EAST))
						step(src, NORTH)
			else
				if (direct & 8)
					if (step(src, NORTH))
						step(src, WEST)
					else
						if (step(src, WEST))
							step(src, NORTH)
		else
			if (direct & 2)
				if (direct & 4)
					if (step(src, SOUTH))
						step(src, EAST)
					else
						if (step(src, EAST))
							step(src, SOUTH)
				else
					if (direct & 8)
						if (step(src, SOUTH))
							step(src, WEST)
						else
							if (step(src, WEST))
								step(src, SOUTH)
	else
		. = ..()
	return


/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)	return
			mob.control_object.dir = direct
		else
			mob.control_object.loc = get_step(mob.control_object,direct)
	return


/client/Move(n, direct)

	if(viewingCanvas)
		view = world.view //Reset the view
		winset(src, "mapwindow.map", "icon-size=[src.reset_stretch]")
		viewingCanvas = 0
		mob.reset_view()
		mob.button_pressed_F12()
		if(!mob.hud_used.hud_shown)
			mob.button_pressed_F12()
		mob.update_hud()
		mob.update_action_buttons()

	if(mob.control_object)	Move_object(direct)

	if(world.time < move_delay)  return

	if(!isliving(mob))  return mob.Move(n,direct)

	if(moving)  return 0

	if(!mob)	return

	if(locate(/obj/effect/stop/, mob.loc))
		for(var/obj/effect/stop/S in mob.loc)
			if(S.victim == mob)
				return

	if(mob.stat==2)	return

// handle possible spirit movement
	if(istype(mob,/mob/spirit))
		var/mob/spirit/currentSpirit = mob
		return currentSpirit.Spirit_Move(direct)

	if(mob.notransform)	return//This is sota the goto stop mobs from moving var

	if(isliving(mob))
		var/mob/living/L = mob
		if(L.incorporeal_move)//Move though walls
			Process_Incorpmove(direct)
			return
		if(mob.client)
			if(mob.client.view != world.view)
				if(locate(/obj/item/weapon/gun/energy/sniperrifle, mob.contents))		// If mob moves while zoomed in with sniper rifle, unzoom them.
					var/obj/item/weapon/gun/energy/sniperrifle/s = locate() in mob
					if(s.zoom)
						s.zoom()

	if(Process_Grab())	return


	if(mob.remote_control)					//we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(isAI(mob))
		return AIMove(n,direct,mob)		
		
	if(!mob.canmove)
		return

	//if(istype(mob.loc, /turf/space) || (mob.flags & NOGRAV))
	//	if(!mob.Process_Spacemove(0))	return 0

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	if((istype(mob.loc, /turf/space)) || ((mob.lastarea.has_gravity == 0) && (!istype(mob.loc, /obj/spacepod))))		// spacepods shouldn't get affected by changes in gravity
		if(!mob.Process_Spacemove(0))	return 0


	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(isturf(mob.loc))

		if(mob.restrained())//Why being pulled while cuffed prevents you from moving
			for(var/mob/M in range(mob, 1))
				if(M.pulling == mob)
					if(!M.restrained() && M.stat == 0 && M.canmove && mob.Adjacent(M))
						src << "\blue You're restrained! You can't move!"
						return 0
					else
						M.stop_pulling()

		if(mob.pinned.len)
			src << "\blue You're pinned to a wall by [mob.pinned[1]]!"
			return 0

		move_delay = world.time//set move delay
		mob.last_move_intent = world.time + 10
		switch(mob.m_intent)
			if("run")
				if(mob.drowsyness > 0)
					move_delay += 6
				move_delay += 1+config.run_speed
			if("walk")
				move_delay += 1+config.walk_speed
		move_delay += mob.movement_delay()

		if(config.Tickcomp)
			move_delay -= 1.3
			var/tickcomp = ((1/(world.tick_lag))*1.3)
			move_delay = move_delay + tickcomp

		if(istype(mob.buckled, /obj/vehicle) || istype(mob.buckled, /obj/structure/stool/bed/chair/cart))
			return mob.buckled.relaymove(mob,direct)

		if(mob.pulledby || mob.buckled) // Wheelchair driving!
			if(istype(mob.loc, /turf/space))
				return // No wheelchair driving in space
			if(istype(mob.pulledby, /obj/structure/stool/bed/chair/wheelchair))
				return mob.pulledby.relaymove(mob, direct)
			else if(istype(mob.buckled, /obj/structure/stool/bed/chair/wheelchair))
				if(ishuman(mob.buckled))
					var/mob/living/carbon/human/driver = mob.buckled
					var/obj/item/organ/external/l_hand = driver.get_organ("l_hand")
					var/obj/item/organ/external/r_hand = driver.get_organ("r_hand")
					if((!l_hand || (l_hand.status & ORGAN_DESTROYED)) && (!r_hand || (r_hand.status & ORGAN_DESTROYED)))
						return // No hands to drive your chair? Tough luck!
				move_delay += 2
				return mob.buckled.relaymove(mob,direct)

		//We are now going to move
		moving = 1
		//Something with pulling things
		if(locate(/obj/item/weapon/grab, mob))
			move_delay = max(move_delay, world.time + 7)
			var/list/L = mob.ret_grab()
			if(istype(L, /list))
				if(L.len == 2)
					L -= mob
					var/mob/M = L[1]
					if(M)
						if ((get_dist(mob, M) <= 1 || M.loc == mob.loc))
							var/turf/T = mob.loc
							. = ..()
							if (isturf(M.loc))
								var/diag = get_dir(mob, M)
								if ((diag - 1) & diag)
								else
									diag = null
								if ((get_dist(mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
				else
					for(var/mob/M in L)
						M.other_mobs = 1
						if(mob != M)
							M.animate_movement = 3
					for(var/mob/M in L)
						spawn( 0 )
							step(M, direct)
							return
						spawn( 1 )
							M.other_mobs = null
							M.animate_movement = 2
							return

		else if(mob.confused)
			step(mob, pick(cardinal))
			mob.last_movement=world.time
		else
			. = ..()
			mob.last_movement=world.time

		for (var/obj/item/weapon/grab/G in mob)
			if (G.state == GRAB_NECK)
				mob.set_dir(reverse_dir[direct])
			G.adjust_position()
		for (var/obj/item/weapon/grab/G in mob.grabbed_by)
			G.adjust_position()

		moving = 0

		return .

	return


///Process_Grab()
///Called by client/Move()
///Checks to see if you are being grabbed and if so attemps to break it
/client/proc/Process_Grab()
	if(locate(/obj/item/weapon/grab, locate(/obj/item/weapon/grab, mob.grabbed_by.len)))
		var/list/grabbing = list()
		if(istype(mob.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = mob.l_hand
			grabbing += G.affecting
		if(istype(mob.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = mob.r_hand
			grabbing += G.affecting
		for(var/obj/item/weapon/grab/G in mob.grabbed_by)
			if((G.state == 1)&&(!grabbing.Find(G.assailant)))	qdel(G)
			if(G.state == 2)
				move_delay = world.time + 10
				if(!prob(25))	return 1
				mob.visible_message("\red [mob] has broken free of [G.assailant]'s grip!")
				qdel(G)
			if(G.state == 3)
				move_delay = world.time + 10
				if(!prob(5))	return 1
				mob.visible_message("\red [mob] has broken free of [G.assailant]'s headlock!")
				qdel(G)
	return 0


///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
	if(!isliving(mob))
		return
	var/mob/living/L = mob
	switch(L.incorporeal_move)
		if(1)
			L.loc = get_step(L, direct)
			L.dir = direct
		if(2)
			if(prob(50))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				L.loc = locate(locx,locy,mobloc.z)
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, L.loc))
						spawn(0)
							anim(T,L,'icons/mob/mob.dmi',,"shadow",,L.dir)
						limit--
						if(limit<=0)	break
			else
				spawn(0)
					anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,L.dir)
				L.loc = get_step(L, direct)
			L.dir = direct
		if(3) //Incorporeal move, but blocked by holy-watered tiles
			var/turf/simulated/floor/stepTurf = get_step(L, direct)
			if(stepTurf.flags & NOJAUNT)
				L << "<span class='warning'>Holy energies block your path.</span>"
				L.notransform = 1
				spawn(2)
					L.notransform = 0
			else
				L.loc = get_step(L, direct)
				L.dir = direct
	return 1


///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/proc/Process_Spacemove(var/check_drift = 0)
	//First check to see if we can do things
	if(restrained())
		return 0

	/*
	if(istype(src,/mob/living/carbon))
		if(src.l_hand && src.r_hand)
			return 0
	*/

	var/dense_object = 0
	for(var/turf/turf in oview(1,src))
		if(istype(turf,/turf/space))
			continue

		if(!turf.density && !mob_negates_gravity())
			continue



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

	//Nothing to push off of so end here
	if(!dense_object)
		return 0

	//Check to see if we slipped
	if(prob(Process_Spaceslipping(5)))
		src << "\blue <B>You slipped!</B>"
		src.inertia_dir = src.last_move
		step(src, src.inertia_dir)
		return 0

	//If not then we can reset inertia and move
	inertia_dir = 0
	return 1

/mob/proc/mob_has_gravity(turf/T)
	return has_gravity(src, T)

/mob/proc/mob_negates_gravity()
	return 0

/mob/proc/Process_Spaceslipping(var/prob_slip = 5)
	//Setup slipage
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		prob_slip = 0  // Changing this to zero to make it line up with the comment.

	prob_slip = round(prob_slip)
	return(prob_slip)

/mob/proc/update_gravity()
	return

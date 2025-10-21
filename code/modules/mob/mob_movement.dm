/mob/CanPass(atom/movable/mover, border_dir)
	var/horizontal = FALSE
	if(isliving(src))
		var/mob/living/L = src
		horizontal = IS_HORIZONTAL(L)

	if(isprojectile(mover))
		return projectile_hit_check(mover)
	if(mover.throwing)
		return (!density || horizontal || (mover.throwing?.get_thrower() == src))
	if(mover.checkpass(PASSMOB))
		return 1
	if(buckled == mover)
		return TRUE
	if(ismob(mover))
		var/mob/moving_mob = mover
		if(src in moving_mob.grab_do_not_move)
			return TRUE
		if(mover in buckled_mobs)
			return TRUE
	return (!mover.density || !density || horizontal)

/mob/proc/projectile_hit_check(obj/item/projectile/P)
	return !(P.always_hit_living_nondense && (stat != DEAD) && !isLivingSSD(src)) && !density

/client/verb/toggle_throw_mode()
	set hidden = 1
	if(iscarbon(mob))
		var/mob/living/carbon/C = mob
		C.toggle_throw_mode()
	else
		to_chat(usr, "<span class='danger'>This mob type cannot throw items.</span>")

/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object, direct)
			if(!mob.control_object)
				return
			mob.control_object.setDir(direct)
		else
			mob.control_object.forceMove(get_step(mob.control_object, direct))
	return

#define CONFUSION_LIGHT_COEFFICIENT		0.15
#define CONFUSION_HEAVY_COEFFICIENT		0.075
#define CONFUSION_MAX					80 SECONDS


/client/Move(new_loc, direct)
	if(world.time < move_delay)
		return

	input_data.desired_move_dir_add = NONE
	input_data.desired_move_dir_sub = NONE

	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag //this is here because Move() can now be called multiple times per tick
	if(!mob || !mob.loc)
		return 0

	if(!new_loc || !direct) // why did we never check this before?
		return FALSE

	if(mob.notransform)
		return 0 //This is sota the goto stop mobs from moving var

	if(mob.throwing && mob.throwing.block_movement)
		return

	if(mob.control_object)
		return Move_object(direct)

	if(!isliving(mob))
		return mob.Move(new_loc, direct)

	if(mob.stat == DEAD)
		mob.ghostize()
		return 0

	if(moving)
		return 0

	var/mob/living/living_mob = null
	if(isliving(mob))
		living_mob = mob
		if(living_mob.incorporeal_move)//Move though walls
			Process_Incorpmove(direct)
			return

	if(mob.remote_control) //we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(is_ai(mob))
		var/mob/living/silicon/ai/ai = mob
		var/mob/camera/eye/ai/eye = ai.eyeobj
		if(istype(eye) && !istype(ai.remote_control))
			ai.remote_control = eye
			return eye.relaymove(mob, direct)
		if(!istype(eye) && !istype(mob.loc, /obj/item/aicard))
			eye = new /mob/camera/eye/ai(mob.loc, ai.name, ai, ai)
			if(istype(eye))
				return eye.relaymove(mob, direct)
		return FALSE // If the AI is outside of its eye or a mech (e.g. carded), it can't move

	if(Process_Grab())
		return

	if(mob.buckled) //if we're buckled to something, tell it we moved.
		return mob.buckled.relaymove(mob, direct)

	if(living_mob && !(living_mob.mobility_flags & MOBILITY_MOVE))
		return

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	if(isobj(mob.loc) || ismob(mob.loc)) //Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return 0

	if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_MOVE, args) & COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE)
		return FALSE

	if(mob.restrained()) // Why being pulled while cuffed prevents you from moving
		for(var/mob/M in orange(1, mob))
			if(M.pulling == mob)
				if(!M.incapacitated() && mob.Adjacent(M))
					to_chat(src, "<span class='warning'>You're restrained! You can't move!</span>")
					move_delay = world.time + 10
					return 0
				else
					M.stop_pulling()

	// We are now going to move
	var/add_delay = mob.movement_delay()

	if(locate(/obj/item/grab, mob))
		if(!isalienhunter(mob)) // i hate grab code
			add_delay += 7

	var/diagonal_factor = 1
	if(IS_DIR_DIAGONAL(direct))
		diagonal_factor = sqrt(2)
	mob.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay * diagonal_factor)) // set it now in case of pulled objects

	//If the move was recent, count using old_move_delay
	//We want fractional behavior and all
	if(old_move_delay + world.tick_lag > world.time)
		//Yes this makes smooth movement stutter if add_delay is too fractional
		//Yes this is better then the alternative
		move_delay = old_move_delay
	else
		move_delay = world.time

	//Basically an optional override for our glide size
	//Sometimes you want to look like you're moving with a delay you don't actually have yet
	visual_delay = 0
	var/old_dir = mob.dir

	if(istype(living_mob))
		var/newdir = NONE
		var/confusion = living_mob.get_confusion()
		if(confusion > CONFUSION_MAX)
			newdir = pick(GLOB.alldirs)
		else if(prob(confusion * CONFUSION_HEAVY_COEFFICIENT))
			newdir = angle2dir(dir2angle(direct) + pick(90, -90))
		else if(prob(confusion * CONFUSION_LIGHT_COEFFICIENT))
			newdir = angle2dir(dir2angle(direct) + pick(45, -45))
		if(newdir)
			direct = newdir
			new_loc = get_step(mob, direct)

	mob.last_movement_dir = direct

	var/prev_pulling_loc = null
	if(mob.pulling)
		prev_pulling_loc = mob.pulling.loc

	. = ..()

	// Only adjust for diagonal movement if the move was *actually* diagonal
	if(mob.loc == new_loc)
		// Similar to the glide size calculation above, LONG_GLIDE mobs need to slow down and other mobs speed up.
		// Unline before, we also want to calculate the new movement delay, which is increased for LONG_GLIDE mobs, and unchanged for other mobs.
		mob.last_movement = world.time
		if(IS_DIR_DIAGONAL(direct))
			add_delay *= sqrt(2)

	var/new_glide_size = 0
	if(visual_delay)
		new_glide_size = visual_delay
	else
		new_glide_size = DELAY_TO_GLIDE_SIZE(add_delay)

	mob.set_glide_size(new_glide_size)

	move_delay += add_delay
	SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_MOVED, direct, old_dir)

	if(mob.pulledby)
		mob.pulledby.stop_pulling()

	if(prev_pulling_loc && mob.pulling?.face_while_pulling && (mob.pulling.loc != prev_pulling_loc))
		mob.setDir(get_dir(mob, mob.pulling)) // Face welding tanks and stuff when pulling

	if(mob && . && mob.throwing)
		mob.throwing.finalize(FALSE)

#undef CONFUSION_LIGHT_COEFFICIENT
#undef CONFUSION_HEAVY_COEFFICIENT
#undef CONFUSION_MAX


///Process_Grab()
///Called by client/Move()
///Checks to see if you are being grabbed and if so attemps to break it
/client/proc/Process_Grab()
	if(length(mob.grabbed_by))
		if(mob.incapacitated(FALSE, TRUE)) // Can't break out of grabs if you're incapacitated
			return TRUE
		if(HAS_TRAIT(mob, TRAIT_IMMOBILIZED))
			return TRUE //You can't move, so you can't break it by trying to move.
		var/list/grabbing = list()

		if(istype(mob.l_hand, /obj/item/grab))
			var/obj/item/grab/G = mob.l_hand
			grabbing += G.affecting

		if(istype(mob.r_hand, /obj/item/grab))
			var/obj/item/grab/G = mob.r_hand
			grabbing += G.affecting

		for(var/X in mob.grabbed_by)
			var/obj/item/grab/G = X
			switch(G.state)

				if(GRAB_PASSIVE)
					if(!grabbing.Find(G.assailant)) //moving always breaks a passive grab unless we are also grabbing our grabber.
						qdel(G)

				if(GRAB_AGGRESSIVE)
					move_delay = world.time + 10
					if(!prob(25))
						return TRUE
					mob.visible_message("<span class='danger'>[mob] has broken free of [G.assailant]'s grip!</span>")
					qdel(G)

				if(GRAB_NECK)
					move_delay = world.time + 10
					if(!prob(5))
						return TRUE
					mob.visible_message("<span class='danger'>[mob] has broken free of [G.assailant]'s headlock!</span>")
					qdel(G)
	return FALSE


///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
	if(!isliving(mob))
		return
	var/mob/living/L = mob
	switch(L.incorporeal_move)
		if(INCORPOREAL_MOVE_NORMAL)
			L.forceMove(get_step(L, direct))
			L.dir = direct
		if(INCORPOREAL_MOVE_NINJA)
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
				L.forceMove(locate(locx,locy,mobloc.z))
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in get_line(mobloc, L.loc))
						new /obj/effect/temp_visual/dir_setting/ninja/shadow(T, L.dir)
						limit--
						if(limit<=0)
							break
			else
				new /obj/effect/temp_visual/dir_setting/ninja/shadow(mobloc, L.dir)
				L.forceMove(get_step(L, direct))
			L.dir = direct
		if(INCORPOREAL_MOVE_HOLY_BLOCK)
			var/turf/simulated/floor/stepTurf = get_step(L, direct)
			if(stepTurf.flags & BLESSED_TILE)
				to_chat(L, "<span class='warning'>Holy energies block your path.</span>")
				L.notransform = TRUE
				spawn(2)
					L.notransform = FALSE
			else
				L.forceMove(get_step(L, direct))
				L.dir = direct
	return TRUE


/**
 * Handles mob/living movement in space (or no gravity)
 *
 * Called by /client/Move()
 *
 * return TRUE for movement or FALSE for none
 */
/mob/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	if(..())
		return TRUE

	// TODO: if(buckled) may belong here

	var/atom/movable/backup = get_spacemove_backup(movement_dir, continuous_move)
	if(!backup)
		return FALSE

	if(continuous_move || !istype(backup) || !movement_dir || backup.anchored)
		return TRUE

	last_pushoff = world.time
	var/opposite_dir = turn(movement_dir, 180)
	if(backup.newtonian_move(opposite_dir)) //You're pushing off something movable, so it moves
		to_chat(src, "<span class='notice'>You push off of [backup] to propel yourself.</span>")
	return TRUE

/**
 * Finds a target near a mob that is viable for pushing off when moving.
 * Takes the intended movement direction as input, alongside if the context is checking if we're allowed to continue drifting
 */
/mob/get_spacemove_backup(moving_direction, continuous_move)
	for(var/atom/pushover as anything in range(1, get_turf(src)))
		if(pushover == src)
			continue
		if(isarea(pushover))
			continue
		if(isturf(pushover))
			var/turf/turf = pushover
			if(isspaceturf(turf))
				continue
			if(!turf.density && !mob_negates_gravity())
				continue
			return pushover

		var/atom/movable/rebound = pushover
		if(rebound == buckled)
			continue
		if(ismob(rebound))
			var/mob/lover = rebound
			if(lover.buckled)
				continue

		var/pass_allowed = rebound.CanPass(src, get_dir(rebound, src))
		if(!rebound.density && pass_allowed)
			continue
		//Sometime this tick, this pushed off something. Doesn't count as a valid pushoff target
		if(rebound.last_pushoff == world.time)
			continue
		if(continuous_move && !pass_allowed)
			var/datum/move_loop/move/rebound_engine = GLOB.move_manager.processing_on(rebound, SSspacedrift)
			// If us and the rebound object are both drifting in the same
			// direction, we can't push off of it. We do not check
			// get_dir(src, pushover) because two objects drifting in the same
			// direction may potentially occupy the same turf at some point
			// during processing.
			if(rebound_engine && moving_direction == rebound_engine.direction)
				continue
		else if(!pass_allowed)
			if(moving_direction == get_dir(src, pushover)) // Can't push "off" of something that you're walking into
				continue
		if(rebound.anchored)
			return rebound
		if(pulling == rebound)
			continue
		return rebound

/mob/proc/mob_has_gravity(turf/T)
	return has_gravity(src, T)

/mob/proc/mob_negates_gravity()
	return 0

/atom/movable/proc/Move_Pulled(atom/moving_atom)
	if(!pulling)
		return FALSE
	if(pulling.anchored || pulling.move_resist > move_force || !pulling.Adjacent(src, src, pulling))
		stop_pulling()
		return FALSE
	if(isliving(pulling))
		var/mob/living/pulling_mob = pulling
		if(pulling_mob.buckled && pulling_mob.buckled.buckle_prevents_pull) //if they're buckled to something that disallows pulling, prevent it
			stop_pulling()
			return FALSE
	if(moving_atom == loc && pulling.density)
		return FALSE
	var/move_dir = get_dir(pulling.loc, moving_atom)
	if(!Process_Spacemove(move_dir))
		return FALSE
	if(!move_dir)
		return FALSE
	pulling.Move(get_step(pulling.loc, move_dir), move_dir, glide_size)
	return TRUE

/mob/living/Move_Pulled(atom/moving_atom)
	. = ..()
	if(!. || !isliving(moving_atom))
		return
	if(!Process_Spacemove(get_dir(pulling.loc, moving_atom)))
		return
	if(src in pulling.contents)
		return
	var/target_turf = get_step(pulling, get_dir(pulling.loc, moving_atom))
	if(get_dist(target_turf, loc) > 1) // Make sure the turf we are trying to pull to is adjacent to the user.
		return // We do not use Adjacent() here because it checks if there are dense objects in the way, making it impossible to move an object to the side if we're blocked on both sides.
	var/move_dir = get_dir(pulling.loc, moving_atom)
	if(ismob(pulling))
		var/mob/M = pulling
		var/atom/movable/t = M.pulling
		M.stop_pulling()

		// we set the return value to step here, if we don't having someone
		// buckled in to a chair and being pulled won't let them be unbuckeled
		. = pulling.Move(get_step(pulling.loc, moving_atom), move_dir, glide_size)
		if(M)
			M.start_pulling(t)
	else
		. = pulling.Move(get_step(pulling.loc, moving_atom), move_dir, glide_size)

/mob/proc/update_gravity(has_gravity)
	return

/client/proc/check_has_body_select()
	return mob && mob.hud_used && mob.hud_used.zone_select && istype(mob.hud_used.zone_select, /atom/movable/screen/zone_sel)

/client/verb/body_toggle_head()
	set name = "body-toggle-head"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	switch(mob.zone_selected)
		if(BODY_ZONE_HEAD)
			next_in_line = BODY_ZONE_PRECISE_EYES
		if(BODY_ZONE_PRECISE_EYES)
			next_in_line = BODY_ZONE_PRECISE_MOUTH
		else
			next_in_line = BODY_ZONE_HEAD

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line, mob)

/client/verb/body_r_arm()
	set name = "body-r-arm"
	set hidden = 1
	if(!check_has_body_select())
		return

	var/next_in_line
	if(mob.zone_selected == BODY_ZONE_R_ARM)
		next_in_line = BODY_ZONE_PRECISE_R_HAND
	else
		next_in_line = BODY_ZONE_R_ARM

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line, mob)

/client/verb/body_chest()
	set name = "body-chest"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_CHEST, mob)

/client/verb/body_l_arm()
	set name = "body-l-arm"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	if(mob.zone_selected == BODY_ZONE_L_ARM)
		next_in_line = BODY_ZONE_PRECISE_L_HAND
	else
		next_in_line = BODY_ZONE_L_ARM

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line, mob)

/client/verb/body_r_leg()
	set name = "body-r-leg"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	if(mob.zone_selected == BODY_ZONE_R_LEG)
		next_in_line = BODY_ZONE_PRECISE_R_FOOT
	else
		next_in_line = BODY_ZONE_R_LEG

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line, mob)

/client/verb/body_groin()
	set name = "body-groin"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_PRECISE_GROIN, mob)

/client/verb/body_l_leg()
	set name = "body-l-leg"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	if(mob.zone_selected == BODY_ZONE_L_LEG)
		next_in_line = BODY_ZONE_PRECISE_L_FOOT
	else
		next_in_line = BODY_ZONE_L_LEG

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line, mob)

/client/verb/toggle_walk_run()
	set name = "toggle-walk-run"
	set hidden = TRUE
	set instant = TRUE
	if(mob)
		mob.toggle_move_intent()

/mob/proc/toggle_move_intent()
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		if(C.legcuffed)
			to_chat(C, "<span class='notice'>You are legcuffed! You cannot run until you get [C.legcuffed] removed!</span>")
			C.m_intent = MOVE_INTENT_WALK	//Just incase
			C.hud_used.move_intent.icon_state = "walking"
			return

	var/icon_toggle
	if(m_intent == MOVE_INTENT_RUN)
		m_intent = MOVE_INTENT_WALK
		icon_toggle = "walking"
	else
		m_intent = MOVE_INTENT_RUN
		icon_toggle = "running"

	if(hud_used && hud_used.move_intent && hud_used.static_inventory)
		hud_used.move_intent.icon_state = icon_toggle
		for(var/atom/movable/screen/mov_intent/selector in hud_used.static_inventory)
			selector.update_icon()
	SEND_SIGNAL(src, COMSIG_MOVE_INTENT_TOGGLED)

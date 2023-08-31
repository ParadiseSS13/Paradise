/obj/singularity
	name = "gravitational singularity"
	desc = "A gravitational singularity."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"
	anchored = TRUE
	density = TRUE
	layer = MASSIVE_OBJ_LAYER
	flags_2 = IMMUNE_TO_SHUTTLECRUSH_2
	light_range = 6
	appearance_flags = LONG_GLIDE
	var/current_size = 1
	var/allowed_size = 1
	var/energy = 100 //How strong are we?
	var/dissipate = TRUE //Do we lose energy over time?
	var/dissipate_delay = 10
	var/dissipate_track = 0
	var/dissipate_strength = 1 //How much energy do we lose?
	var/move_self = TRUE //Do we move on our own?
	var/grav_pull = 4 //How many tiles out do we pull?
	move_resist = INFINITY	//no, you don't get to push the singulo. Not even you OP wizard gateway statues
	var/consume_range = 0 //How many tiles out do we eat
	var/event_chance = 15 //Prob for event each tick
	var/target = null //its target. moves towards the target if it has one
	var/last_failed_movement = 0//Will not move in the same dir if it couldnt before, will help with the getting stuck on fields thing
	var/last_warning
	var/consumedSupermatter = FALSE //If the singularity has eaten a supermatter shard and can go to stage six
	var/warps_projectiles = TRUE
	var/obj/effect/warp_effect/supermatter/warp
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	/// Whether or not we've pinged ghosts
	var/isnt_shutting_down = FALSE

/obj/singularity/Initialize(mapload, starting_energy = 50)
	. = ..()
	//CARN: admin-alert for chuckle-fuckery.
	admin_investigate_setup()

	energy = starting_energy
	if(warps_projectiles)
		AddComponent(/datum/component/proximity_monitor/singulo, _radius = 10)

	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src
	GLOB.singularities += src
	for(var/obj/machinery/power/singularity_beacon/singubeacon in GLOB.machines)
		if(singubeacon.active)
			target = singubeacon
			break

/obj/singularity/Destroy()
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list.Remove(src)
	GLOB.singularities -= src
	vis_contents -= warp
	QDEL_NULL(warp)  // don't want to leave it hanging
	target = null
	return ..()

/obj/singularity/Move(atom/newloc, direct)
	if(current_size >= STAGE_FIVE || check_turfs_in(direct))
		last_failed_movement = 0//Reset this because we moved
		return ..()
	else
		last_failed_movement = direct
		return 0


/obj/singularity/attack_hand(mob/user)
	consume(user)
	return 1

/obj/singularity/attack_alien(mob/user)
	consume(user)

/obj/singularity/attack_animal(mob/user)
	consume(user)

/obj/singularity/attackby(obj/item/W, mob/user, params)
	consume(user)
	return 1

/obj/singularity/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	investigate_log("has consumed the brain of [key_name(C)] after being touched with telekinesis", "singulo")
	C.visible_message("<span class='danger'>[C] suddenly slumps over.</span>", \
		"<span class='userdanger'>As you concentrate on the singularity, your understanding of the cosmos expands exponentially. An immense wealth of raw information is at your fingertips, and you're determined not to squander a single morsel. Within mere microseconds, you absorb a staggering amount of information—more than any AI could ever hope to access—and you can't help but feel a godlike sense of power. However, the gravity of this situation swiftly sinks in. As you sense your skull starting to collapse under pressure, you can't help but admit to yourself: That was a really dense idea, wasn't it?</span>")
	var/obj/item/organ/internal/brain/B = C.get_int_organ(/obj/item/organ/internal/brain)
	C.ghostize(0)
	if(B)
		B.remove(C)
		qdel(B)

/obj/singularity/Process_Spacemove() //The singularity stops drifting for no man!
	return 0

/obj/singularity/blob_act(obj/structure/blob/B)
	return

/obj/singularity/ex_act(severity)
	switch(severity)
		if(1)
			if(current_size <= STAGE_TWO)
				investigate_log("has been destroyed by a heavy explosion.","singulo")
				qdel(src)
				return
			else
				energy -= round(((energy+1)/2),1)
		if(2)
			energy -= round(((energy+1)/3),1)
		if(3)
			energy -= round(((energy+1)/4),1)
	return


/obj/singularity/bullet_act(obj/item/projectile/P)
	qdel(P)
	return 0 //Will there be an impact? Who knows. Will we see it? No.


/obj/singularity/Bump(atom/A)
	consume(A)
	return


/obj/singularity/Bumped(atom/A)
	consume(A)
	return


/obj/singularity/process()
	if(allowed_size >= STAGE_TWO)
		// Start moving even before we reach "true" stage two.
		// If we are stage one and are sufficiently energetic to be allowed to 2,
		//  it might mean we are stuck in a corner somewere. So move around to try to expand.
		move()
	if(current_size >= STAGE_TWO)
		radiation_pulse(src, min(5000, (energy * 4.5) + 1000), RAD_DISTANCE_COEFFICIENT * 0.5)
		if(prob(event_chance))//Chance for it to run a special event TODO:Come up with one or two more that fit
			event()
	eat()
	do_dissipate()
	check_energy()
	update_warp()

	return


/obj/singularity/attack_ai() //to prevent ais from gibbing themselves when they click on one.
	return


/obj/singularity/proc/admin_investigate_setup()
	last_warning = world.time
	var/count = locate(/obj/machinery/field/containment) in urange(30, src, 1)
	if(!count)
		message_admins("A singularity has been created without containment fields active at [x], [y], [z] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
	investigate_log("was created. [count?"":"<font color='red'>No containment fields were active</font>"]","singulo")

/obj/singularity/proc/do_dissipate()
	if(!dissipate)
		return
	if(dissipate_track >= dissipate_delay)
		src.energy -= dissipate_strength
		dissipate_track = 0
	else
		dissipate_track++


/obj/singularity/proc/expand(force_size = 0)
	var/temp_allowed_size = src.allowed_size
	if(force_size)
		temp_allowed_size = force_size
	if(temp_allowed_size >= STAGE_SIX && !consumedSupermatter)
		temp_allowed_size = STAGE_FIVE
	switch(temp_allowed_size)
		if(STAGE_ONE)
			current_size = STAGE_ONE
			icon = 'icons/obj/singularity.dmi'
			icon_state = "singularity_s1"
			pixel_x = 0
			pixel_y = 0
			grav_pull = 4
			consume_range = 0
			dissipate_delay = 10
			dissipate_track = 0
			dissipate_strength = 1
			if(warp)
				vis_contents -= warp
				qdel(warp)
		if(STAGE_TWO)
			if((check_turfs_in(1,1))&&(check_turfs_in(2,1))&&(check_turfs_in(4,1))&&(check_turfs_in(8,1)))
				current_size = STAGE_TWO
				icon = 'icons/effects/96x96.dmi'
				icon_state = "singularity_s3"
				pixel_x = -32
				pixel_y = -32
				grav_pull = 6
				consume_range = 1
				dissipate_delay = 5
				dissipate_track = 0
				dissipate_strength = 5
				if(!warp)
					warp = new(src)
					vis_contents += warp
		if(STAGE_THREE)
			if((check_turfs_in(1,2))&&(check_turfs_in(2,2))&&(check_turfs_in(4,2))&&(check_turfs_in(8,2)))
				current_size = STAGE_THREE
				icon = 'icons/effects/160x160.dmi'
				icon_state = "singularity_s5"
				pixel_x = -64
				pixel_y = -64
				grav_pull = 8
				consume_range = 2
				dissipate_delay = 4
				dissipate_track = 0
				dissipate_strength = 20
				if(!warp) //In the event the singularity eats a clown and skips stage 2.
					warp = new(src)
					vis_contents += warp
		if(STAGE_FOUR)
			if((check_turfs_in(1,3))&&(check_turfs_in(2,3))&&(check_turfs_in(4,3))&&(check_turfs_in(8,3)))
				current_size = STAGE_FOUR
				icon = 'icons/effects/224x224.dmi'
				icon_state = "singularity_s7"
				pixel_x = -96
				pixel_y = -96
				grav_pull = 10
				consume_range = 3
				dissipate_delay = 10
				dissipate_track = 0
				dissipate_strength = 10
				notify_dead()
		if(STAGE_FIVE)//this one also lacks a check for gens because it eats everything
			current_size = STAGE_FIVE
			icon = 'icons/effects/288x288.dmi'
			icon_state = "singularity_s9"
			pixel_x = -128
			pixel_y = -128
			grav_pull = 10
			consume_range = 4
			dissipate = FALSE //It cant go smaller due to e loss
		if(STAGE_SIX) //This only happens if a stage 5 singulo consumes a supermatter shard.
			current_size = STAGE_SIX
			icon = 'icons/effects/352x352.dmi'
			icon_state = "singularity_s11"
			pixel_x = -160
			pixel_y = -160
			grav_pull = 15
			consume_range = 5
			dissipate = FALSE
	if(current_size == allowed_size)
		investigate_log("<font color='red'>grew to size [current_size]</font>","singulo")
		return 1
	else if(current_size < (--temp_allowed_size))
		expand(temp_allowed_size)
	else
		return 0


/obj/singularity/proc/check_energy()
	if(energy <= 0)
		investigate_log("collapsed.","singulo")
		qdel(src)
		return 0
	switch(energy)//Some of these numbers might need to be changed up later -Mport
		if(1 to 199)
			allowed_size = STAGE_ONE
		if(200 to 499)
			allowed_size = STAGE_TWO
		if(500 to 999)
			allowed_size = STAGE_THREE
		if(1000 to 1999)
			allowed_size = STAGE_FOUR
		if(2000 to INFINITY)
			if(energy >= 3000 && consumedSupermatter)
				allowed_size = STAGE_SIX
			else
				allowed_size = STAGE_FIVE
	if(current_size != allowed_size)
		expand()
	return 1


/obj/singularity/proc/eat()
	for(var/tile in spiral_range_turfs(grav_pull, src))
		var/turf/T = tile
		if(!T || !isturf(loc))
			continue
		if(get_dist(T, src) > consume_range)
			T.singularity_pull(src, current_size)
		else
			consume(T)
		for(var/thing in T)
			if(isturf(loc) && thing != src)
				var/atom/movable/X = thing
				if(get_dist(X, src) > consume_range)
					X.singularity_pull(src, current_size)
				else
					consume(X)
			if(TICK_CHECK)
				return // You've eaten enough. Prevents weirdness like the singulo eating the containment on stage 2


/obj/singularity/proc/consume(atom/A)
	var/gain = A.singularity_act(current_size)
	src.energy += gain
	if(istype(A, /obj/machinery/atmospherics/supermatter_crystal) && !consumedSupermatter)
		desc = "[initial(desc)] It glows fiercely with inner fire."
		name = "supermatter-charged [initial(name)]"
		consumedSupermatter = TRUE
		set_light(10)
	if(istype(A, /obj/singularity/narsie))
		if(current_size == STAGE_SIX)
			visible_message("<span class='userdanger'>[SSticker.cultdat?.entity_name] is consumed by [src]!</span>")
			qdel(A)
		else
			visible_message("<span class='userdanger'>[SSticker.cultdat?.entity_name] strikes down [src]!</span>")
			investigate_log("has been destroyed by Nar'Sie","singulo")
			qdel(src)

	return


/obj/singularity/proc/move(force_move = 0)
	if(!move_self)
		return 0

	var/movement_dir = pick(GLOB.alldirs - last_failed_movement)

	if(force_move)
		movement_dir = force_move

	if(target && prob(60))
		movement_dir = get_dir(src,target) //moves to a singulo beacon, if there is one

	step(src, movement_dir)


/obj/singularity/proc/check_turfs_in(direction = 0, step = 0)
	if(!direction)
		return 0
	var/steps = 0
	if(!step)
		switch(current_size)
			if(STAGE_ONE)
				steps = 1
			if(STAGE_TWO)
				steps = 3//Yes this is right
			if(STAGE_THREE)
				steps = 3
			if(STAGE_FOUR)
				steps = 4
			if(STAGE_FIVE)
				steps = 5
	else
		steps = step
	var/list/turfs = list()
	var/turf/T = src.loc
	for(var/i = 1 to steps)
		T = get_step(T,direction)
	if(!isturf(T))
		return 0
	turfs.Add(T)
	var/dir2 = 0
	var/dir3 = 0
	switch(direction)
		if(NORTH, SOUTH)
			dir2 = 4
			dir3 = 8
		if(EAST, WEST)
			dir2 = 1
			dir3 = 2
	var/turf/T2 = T
	for(var/j = 1 to steps-1)
		T2 = get_step(T2,dir2)
		if(!isturf(T2))
			return 0
		turfs.Add(T2)
	for(var/k = 1 to steps-1)
		T = get_step(T,dir3)
		if(!isturf(T))
			return 0
		turfs.Add(T)
	for(var/turf/T3 in turfs)
		if(isnull(T3))
			continue
		if(!can_move(T3))
			return 0
	return 1


/obj/singularity/proc/can_move(turf/T)
	if(!T)
		return 0
	if((locate(/obj/machinery/field/containment) in T)||(locate(/obj/machinery/shieldwall) in T))
		return 0
	else if(locate(/obj/machinery/field/generator) in T)
		var/obj/machinery/field/generator/G = locate(/obj/machinery/field/generator) in T
		if(G && G.active)
			return 0
	else if(locate(/obj/machinery/shieldwallgen) in T)
		var/obj/machinery/shieldwallgen/S = locate(/obj/machinery/shieldwallgen) in T
		if(S?.activated)
			return 0
	return 1


/obj/singularity/proc/event()
	var/numb = rand(1, 4)
	switch(numb)
		if(1) //EMP
			emp_area()
		if(2) //Stun mobs who lack optic scanners
			mezzer()
		if(3, 4) //Sets all nearby mobs on fire
			if(current_size < STAGE_SIX)
				return 0
			combust_mobs()
		else
			return 0
	return 1


/obj/singularity/proc/combust_mobs()
	for(var/mob/living/carbon/C in urange(20, src, 1))
		C.visible_message("<span class='warning'>[C]'s skin bursts into flame!</span>", \
						"<span class='userdanger'>You feel an inner fire as your skin bursts into flames!</span>")
		C.adjust_fire_stacks(5)
		C.IgniteMob()
	return

/obj/singularity/proc/notify_dead()
	if(isnt_shutting_down)
		return
	notify_ghosts(
		"IT'S LOOSE",
		ghost_sound = 'sound/machines/warning-buzzer.ogg',
		source = src,
		action = NOTIFY_FOLLOW,
		flashwindow = FALSE,
		title = "IT'S LOOSE",
		alert_overlay = image(icon='icons/obj/singularity.dmi', icon_state="singularity_s1")
	)

	isnt_shutting_down = TRUE



/obj/singularity/proc/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(isbrain(M)) //Ignore brains
			continue

		if(HAS_TRAIT(M, TRAIT_MESON_VISION))
			to_chat(M, "<span class='notice'>You look directly into [src], but your meson vision protects you!</span>")
			return

		M.Stun(6 SECONDS)
		M.visible_message("<span class='danger'>[M] stares blankly at [src]!</span>", \
						"<span class='userdanger'>You look directly into [src] and feel weak.</span>")


/obj/singularity/proc/emp_area()
	empulse(src, 8, 10)
	return

/obj/singularity/proc/update_warp()
	if(!warp)
		return
	warp.pixel_x = initial(warp.pixel_x) - pixel_x
	warp.pixel_y = initial(warp.pixel_x) - pixel_y
	var/scaling = allowed_size / 3
	animate(warp, time = 6, transform = matrix().Scale(0.5 * scaling, 0.5 * scaling))
	animate(time = 14, transform = matrix().Scale(scaling, scaling))

/obj/singularity/singularity_act()
	var/gain = (energy/2)
	var/dist = max((current_size - 2),1)
	explosion(src.loc,(dist),(dist*2),(dist*4))
	qdel(src)
	return(gain)

/obj/singularity/onetile
	dissipate = FALSE
	move_self = FALSE
	grav_pull = TRUE

/obj/singularity/onetile/admin_investigate_setup()
	return

/obj/singularity/onetile/process()
	eat()
	if(prob(1))
		mezzer()

/datum/component/proximity_monitor/singulo
	field_checker_type = /obj/effect/abstract/proximity_checker/singulo

/datum/component/proximity_monitor/singulo/create_single_prox_checker(turf/T, checker_type)
	. = ..()
	var/obj/effect/abstract/proximity_checker/singulo/S = .
	S.calibrate()

/datum/component/proximity_monitor/singulo/recenter_prox_checkers()
	. = ..()
	for(var/obj/effect/abstract/proximity_checker/singulo/S as anything in proximity_checkers)
		S.calibrate()

/obj/effect/abstract/proximity_checker/singulo
	var/angle_to_singulo
	var/distance_to_singulo

/obj/effect/abstract/proximity_checker/singulo/proc/calibrate()
	angle_to_singulo = ATAN2(monitor.hasprox_receiver.y - y, monitor.hasprox_receiver.x - x)
	distance_to_singulo = get_dist(monitor.hasprox_receiver, src)

/obj/effect/abstract/proximity_checker/singulo/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(!istype(AM, /obj/item/projectile))
		return
	var/obj/item/projectile/P = AM
	var/distance = distance_to_singulo
	var/projectile_angle = P.Angle
	var/angle_to_projectile = angle_to_singulo
	if(angle_to_projectile == 180)
		angle_to_projectile = -180
	angle_to_projectile -= projectile_angle
	if(angle_to_projectile > 180)
		angle_to_projectile -= 360
	else if(angle_to_projectile < -180)
		angle_to_projectile += 360

	if(distance == 0)
		qdel(P)
		return
	projectile_angle += angle_to_projectile / (distance ** 2)
	P.damage += 10 / distance
	P.set_angle(projectile_angle)

/obj/singularity/proc/end_deadchat_plays()
	move_self = TRUE


/obj/singularity/deadchat_plays(mode = DEADCHAT_DEMOCRACY_MODE, cooldown = 12 SECONDS)
	. = AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(), cooldown, CALLBACK(src, TYPE_PROC_REF(/atom/movable, stop_deadchat_plays)))

	if(. == COMPONENT_INCOMPATIBLE)
		return

	move_self = FALSE


/obj/singularity/deadchat_controlled/Initialize(mapload, starting_energy)
	. = ..()
	deadchat_plays(mode = DEADCHAT_DEMOCRACY_MODE)

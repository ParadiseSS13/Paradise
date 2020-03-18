// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables
// Toilets are a type of disposal bin for small objects only and work on magic. By magic, I mean torque rotation
#define SEND_PRESSURE 0.05*ONE_ATMOSPHERE

/obj/machinery/disposal
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "disposal"
	anchored = 1
	density = 1
	on_blueprints = TRUE
	armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 30)
	max_integrity = 200
	resistance_flags = FIRE_PROOF
	var/datum/gas_mixture/air_contents	// internal reservoir
	var/mode = 1	// item mode 0=off 1=charging 2=charged
	var/flush = 0	// true if flush handle is pulled
	var/obj/structure/disposalpipe/trunk/trunk = null // the attached pipe trunk
	var/flushing = 0	// true if flushing in progress
	var/flush_every_ticks = 30 //Every 30 ticks it will look whether it is ready to flush
	var/flush_count = 0 //this var adds 1 once per tick. When it reaches flush_every_ticks it resets and tries to flush.
	var/last_sound = 0
	var/required_mode_to_deconstruct = -1
	var/deconstructs_to = PIPE_DISPOSALS_BIN
	active_power_usage = 600
	idle_power_usage = 100


// create a new disposal
// find the attached trunk (if present)
/obj/machinery/disposal/New()
	..()
	trunk_check()
	//gas.volume = 1.05 * CELLSTANDARD
	update()

/obj/machinery/disposal/proc/trunk_check()
	var/obj/structure/disposalpipe/trunk/T = locate() in loc
	if(!T)
		mode = 0
		flush = 0
	else
		mode = initial(mode)
		flush = initial(flush)
		T.nicely_link_to_other_stuff(src)

//When the disposalsoutlet is forcefully moved. Due to meteorshot (not the recall spell)
/obj/machinery/disposal/Moved(atom/OldLoc, Dir)
	. = ..()
	eject()
	var/ptype = istype(src, /obj/machinery/disposal/deliveryChute) ? PIPE_DISPOSALS_CHUTE : PIPE_DISPOSALS_BIN //Check what disposaltype it is
	var/turf/T = OldLoc
	if(T.intact)
		var/turf/simulated/floor/F = T
		F.remove_tile(null,TRUE,TRUE)
		T.visible_message("<span class='warning'>The floortile is ripped from the floor!</span>", "<span class='warning'>You hear a loud bang!</span>")
	if(trunk)
		trunk.remove_trunk_links()
	var/obj/structure/disposalconstruct/C = new (loc)
	transfer_fingerprints_to(C)
	C.ptype = ptype
	C.update()
	C.anchored = 0
	C.density = 1
	qdel(src)

/obj/machinery/disposal/Destroy()
	eject()
	if(trunk)
		trunk.remove_trunk_links()
	return ..()

/obj/machinery/disposal/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/machinery/disposal/Initialize()
	// this will get a copy of the air turf and take a SEND PRESSURE amount of air from it
	..()
	var/atom/L = loc
	var/datum/gas_mixture/env = new
	env.copy_from(L.return_air())
	var/datum/gas_mixture/removed = env.remove(SEND_PRESSURE + 1)
	air_contents = new
	air_contents.merge(removed)
	trunk_check()

// attack by item places it in to disposal
/obj/machinery/disposal/attackby(var/obj/item/I, var/mob/user, params)
	if(stat & BROKEN || !I || !user)
		return

	src.add_fingerprint(user)

	if(istype(I, /obj/item/melee/energy/blade))
		to_chat(user, "You can't place that item inside the disposal unit.")
		return

	if(istype(I, /obj/item/storage))
		var/obj/item/storage/S = I
		if((S.allow_quick_empty || S.allow_quick_gather) && S.contents.len)
			S.hide_from(user)
			user.visible_message("[user] empties \the [S] into \the [src].", "You empty \the [S] into \the [src].")
			for(var/obj/item/O in S.contents)
				S.remove_from_storage(O, src)
			S.update_icon() // For content-sensitive icons
			update()
			return

	var/obj/item/grab/G = I
	if(istype(G))	// handle grabbed mob
		if(ismob(G.affecting))
			var/mob/GM = G.affecting
			for(var/mob/V in viewers(usr))
				V.show_message("[usr] starts putting [GM.name] into the disposal.", 3)
			if(do_after(usr, 20, target = GM))
				GM.forceMove(src)
				for(var/mob/C in viewers(src))
					C.show_message("<span class='warning'>[GM.name] has been placed in the [src] by [user].</span>", 3)
				qdel(G)
				add_attack_logs(usr, GM, "Disposal'ed", !!GM.ckey ? null : ATKLOG_ALL)
		return

	if(!I)
		return

	if(!user.drop_item())
		return
	if(I)
		I.forceMove(src)

	to_chat(user, "You place \the [I] into the [src].")
	for(var/mob/M in viewers(src))
		if(M == user)
			continue
		M.show_message("[user.name] places \the [I] into the [src].", 3)

	update()




/obj/machinery/disposal/screwdriver_act(mob/user, obj/item/I)
	if(mode>0) // It's on
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(contents.len > 0)
		to_chat(user, "Eject the items first!")
		return
	if(mode==0) // It's off but still not unscrewed
		mode=-1 // Set it to doubleoff l0l
	else if(mode==-1)
		mode=0
	to_chat(user, "You [mode ? "unfasten": "fasten"] the screws around the power connection.")

/obj/machinery/disposal/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(mode != required_mode_to_deconstruct)
		return
	if(contents.len > 0)
		to_chat(user, "Eject the items first!")
		return
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		var/obj/structure/disposalconstruct/C = new (src.loc)
		C.ptype = deconstructs_to
		C.update()
		C.anchored = 1
		C.density = 1
		qdel(src)

// mouse drop another mob or self
//
/obj/machinery/disposal/MouseDrop_T(mob/target, mob/user)
	if(!istype(target) || target.buckled || target.has_buckled_mobs() || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || istype(user, /mob/living/silicon/ai))
		return
	if(isanimal(user) && target != user) return //animals cannot put mobs other than themselves into disposal
	src.add_fingerprint(user)
	var/target_loc = target.loc
	var/msg
	for(var/mob/V in viewers(usr))
		if(target == user && !user.stat && !user.IsWeakened() && !user.stunned && !user.paralysis)
			V.show_message("[usr] starts climbing into the disposal.", 3)
		if(target != user && !user.restrained() && !user.stat && !user.IsWeakened() && !user.stunned && !user.paralysis)
			if(target.anchored) return
			V.show_message("[usr] starts stuffing [target.name] into the disposal.", 3)
	if(!do_after(usr, 20, target = target))
		return
	if(target_loc != target.loc)
		return
	if(target == user && !user.stat && !user.IsWeakened() && !user.stunned && !user.paralysis)	// if drop self, then climbed in
											// must be awake, not stunned or whatever
		msg = "[user.name] climbs into the [src]."
		to_chat(user, "You climb into the [src].")
	else if(target != user && !user.restrained() && !user.stat && !user.IsWeakened() && !user.stunned && !user.paralysis)
		msg = "[user.name] stuffs [target.name] into the [src]!"
		to_chat(user, "You stuff [target.name] into the [src]!")

		add_attack_logs(user, target, "Disposal'ed", !!target.ckey ? null : ATKLOG_ALL)
	else
		return
	target.forceMove(src)

	for(var/mob/C in viewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)

	update()
	return

// attempt to move while inside
/obj/machinery/disposal/relaymove(mob/user as mob)
	if(user.stat || src.flushing)
		return
	src.go_out(user)
	return

// leave the disposal
/obj/machinery/disposal/proc/go_out(mob/user)
	if(user)
		user.forceMove(loc)
	update()

// ai as human but can't flush
/obj/machinery/disposal/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	ui_interact(user)

/obj/machinery/disposal/attack_ghost(mob/user as mob)
	ui_interact(user)

// human interact with machine
/obj/machinery/disposal/attack_hand(mob/user as mob)
	if(..(user))
		return 1

	if(stat & BROKEN)
		return

	if(user && user.loc == src)
		to_chat(usr, "<span class='warning'>You cannot reach the controls from inside.</span>")
		return

	// Clumsy folks can only flush it.
	if(user.IsAdvancedToolUser())
		ui_interact(user)
	else
		flush = !flush
		update()
	return

/obj/machinery/disposal/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "disposal_bin.tmpl", "Waste Disposal Unit", 395, 250)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/disposal/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	var/pressure = Clamp(100* air_contents.return_pressure() / (SEND_PRESSURE), 0, 100)
	var/pressure_round = round(pressure,1)

	data["isAI"] = isAI(user)
	data["flushing"] = flush
	data["mode"] = mode
	if(mode <= 0)
		data["pumpstatus"] = "N/A"
	else if(mode == 1)
		data["pumpstatus"] = "Pressurizing"
	else if(mode == 2)
		data["pumpstatus"] = "Ready"
	else
		data["pumpstatus"] = "Idle"
	data["pressure"] = pressure_round

	return data

/obj/machinery/disposal/Topic(href, href_list)
	if(usr.loc == src)
		to_chat(usr, "<span class='warning'>You cannot reach the controls from inside.</span>")
		return

	if(mode==-1 && !href_list["eject"]) // only allow ejecting if mode is -1
		to_chat(usr, "<span class='warning'>The disposal units power is disabled.</span>")
		return

	if(..())
		return

	if(stat & BROKEN)
		return

	src.add_fingerprint(usr)

	if(usr.stat || usr.restrained() || src.flushing)
		return

	if(istype(src.loc, /turf))
		if(href_list["pump"])
			if(text2num(href_list["pump"]))
				mode = 1
			else
				mode = 0
			update()

		if(!isAI(usr))
			if(href_list["handle"])
				flush = text2num(href_list["handle"])
				update()

			if(href_list["eject"])
				eject()
	return

// eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	for(var/atom/movable/AM in src)
		AM.loc = src.loc
		AM.pipe_eject(0)
	update()

// update the icon & overlays to reflect mode & status
/obj/machinery/disposal/proc/update()
	overlays.Cut()
	if(stat & BROKEN)
		icon_state = "disposal-broken"
		mode = 0
		flush = 0
		return

	// flush handle
	if(flush)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-handle")

	// only handle is shown if no power
	if(stat & NOPOWER || mode == -1)
		return

	// 	check for items in disposal - occupied light
	if(contents.len > 0)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-full")

	// charging and ready light
	if(mode == 1)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-charge")
	else if(mode == 2)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-ready")

// timed process
// charge the gas reservoir and perform flush if ready
/obj/machinery/disposal/process()
	use_power = NO_POWER_USE
	if(stat & BROKEN)			// nothing can happen if broken
		return

	flush_count++
	if( flush_count >= flush_every_ticks )
		if( contents.len )
			if(mode == 2)
				spawn(0)
					feedback_inc("disposal_auto_flush",1)
					flush()
		flush_count = 0

	src.updateDialog()

	if(flush && air_contents.return_pressure() >= SEND_PRESSURE )	// flush can happen even without power
		flush()

	if(stat & NOPOWER)			// won't charge if no power
		return

	use_power = IDLE_POWER_USE

	if(mode != 1)		// if off or ready, no need to charge
		return

	// otherwise charge
	use_power = ACTIVE_POWER_USE

	var/atom/L = loc						// recharging from loc turf

	var/datum/gas_mixture/env = L.return_air()
	var/pressure_delta = (SEND_PRESSURE*1.01) - air_contents.return_pressure()

	if(env.temperature > 0)
		var/transfer_moles = 0.1 * pressure_delta*air_contents.volume/(env.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = env.remove(transfer_moles)
		air_contents.merge(removed)
		air_update_turf()


	// if full enough, switch to ready mode
	if(air_contents.return_pressure() >= SEND_PRESSURE)
		mode = 2
		update()
	return

// perform a flush
/obj/machinery/disposal/proc/flush()

	flushing = 1
	flick("[icon_state]-flush", src)

	var/wrapcheck = 0
	var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
												// travels through the pipes.
	//Hacky test to get drones to mail themselves through disposals.
	for(var/mob/living/silicon/robot/drone/D in src)
		wrapcheck = 1

	for(var/mob/living/silicon/robot/syndicate/saboteur/R in src)
		wrapcheck = 1

	for(var/obj/item/smallDelivery/O in src)
		wrapcheck = 1

	if(wrapcheck == 1)
		H.tomail = 1

	sleep(10)
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		last_sound = world.time
	sleep(5) // wait for animation to finish


	H.init(src)	// copy the contents of disposer to holder
	air_contents = new() // The holder just took our gas; replace it
	H.start(src) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
	update()
	return


// called when area power changes
/obj/machinery/disposal/power_change()
	..()	// do default setting/reset of stat NOPOWER bit
	update()	// update icon
	return


// called when holder is expelled from a disposal
// should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(var/obj/structure/disposalholder/H)

	var/turf/target
	playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
	if(H) // Somehow, someone managed to flush a window which broke mid-transit and caused the disposal to go in an infinite loop trying to expel null, hopefully this fixes it
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.loc = src.loc
			AM.pipe_eject(0)
			if(!istype(AM, /mob/living/silicon/robot/drone) && !istype(AM, /mob/living/silicon/robot/syndicate/saboteur)) //Poor drones kept smashing windows and taking system damage being fired out of disposals. ~Z
				spawn(1)
					if(AM)
						AM.throw_at(target, 5, 1)

		H.vent_gas(loc)
		qdel(H)

/obj/machinery/disposal/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(75))
			I.loc = src
			for(var/mob/M in viewers(src))
				M.show_message("\the [I] lands in \the [src].", 3)
			update()
		else
			for(var/mob/M in viewers(src))
				M.show_message("\the [I] bounces off of \the [src]'s rim!.", 3)
		return 0
	else
		return ..(mover, target, height)


/obj/machinery/disposal/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		qdel(src)

/obj/machinery/disposal/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)

// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/structure/disposalholder
	invisibility = 101
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/gas_mixture/gas = null	// gas used to flush, will appear at exit point
	var/active = 0	// true if the holder is moving, otherwise inactive
	dir = 0
	var/count = 1000	//*** can travel 1000 steps before going inactive (in case of loops)
	var/has_fat_guy = 0	// true if contains a fat person
	var/destinationTag = 0 // changes if contains a delivery container
	var/tomail = 0 //changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob

/obj/structure/disposalholder/Destroy()
	QDEL_NULL(gas)
	active = 0
	return ..()

	// initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(var/obj/machinery/disposal/D)
	gas = D.air_contents// transfer gas resv. into holder object

	//Check for any living mobs trigger hasmob.
	//hasmob effects whether the package goes to cargo or its tagged destination.
	for(var/mob/living/M in D)
		if(M && M.stat != 2 && !istype(M, /mob/living/silicon/robot/drone) && !istype(M, /mob/living/silicon/robot/syndicate/saboteur))
			hasmob = 1

	//Checks 1 contents level deep. This means that players can be sent through disposals...
	//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
	for(var/obj/O in D)
		if(O.contents)
			for(var/mob/living/M in O.contents)
				if(M && M.stat != 2 && !istype(M,/mob/living/silicon/robot/drone) && !istype(M, /mob/living/silicon/robot/syndicate/saboteur))
					hasmob = 1

	// now everything inside the disposal gets put into the holder
	// note AM since can contain mobs or objs
	for(var/atom/movable/AM in D)
		AM.loc = src
		SEND_SIGNAL(AM, COMSIG_MOVABLE_DISPOSING, src, D)
		if(istype(AM, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = AM
			if(FAT in H.mutations)		// is a human and fat?
				has_fat_guy = 1			// set flag on holder
		if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
			var/obj/structure/bigDelivery/T = AM
			destinationTag = T.sortTag
		if(istype(AM, /obj/item/smallDelivery) && !hasmob)
			var/obj/item/smallDelivery/T = AM
			destinationTag = T.sortTag
		//Drones can mail themselves through maint.
		if(istype(AM, /mob/living/silicon/robot/drone))
			var/mob/living/silicon/robot/drone/drone = AM
			destinationTag = drone.mail_destination
		if(istype(AM, /mob/living/silicon/robot/syndicate/saboteur))
			var/mob/living/silicon/robot/syndicate/saboteur/S = AM
			destinationTag = S.mail_destination
		if(istype(AM, /obj/item/shippingPackage) && !hasmob)
			var/obj/item/shippingPackage/sp = AM
			if(sp.sealed)	//only sealed packages get delivered to their intended destination
				destinationTag = sp.sortTag


	// start the movement process
	// argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(var/obj/machinery/disposal/D)
	if(!D.trunk)
		D.expel(src)	// no trunk connected, so expel immediately
		return

	loc = D.trunk
	active = 1
	dir = DOWN
	spawn(1)
		move()		// spawn off the movement process

	return

	// movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move()
	var/obj/structure/disposalpipe/last
	while(active)
	/*	if(hasmob && prob(3))
			for(var/mob/living/H in src)
				if(!istype(H,/mob/living/silicon/robot/drone)) //Drones use the mailing code to move through the disposal system,
					H.take_overall_damage(20, 0, "Blunt Trauma") */ //horribly maim any living creature jumping down disposals.  c'est la vie

		if(has_fat_guy && prob(2)) // chance of becoming stuck per segment if contains a fat guy
			active = 0
			// find the fat guys
			for(var/mob/living/carbon/human/H in src)

			break
		sleep(1)		// was 1
		var/obj/structure/disposalpipe/curr = loc
		last = curr
		curr = curr.transfer(src)
		if(!curr)
			last.expel(src, loc, dir)

		//
		if(!(count--))
			active = 0
	return



	// find the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step(loc,dir)

	// find a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(var/turf/T)
	if(!T)
		return null

	var/fdir = turn(dir, 180)	// flip the movement direction
	for(var/obj/structure/disposalpipe/P in T)
		if(fdir & P.dpdir)		// find pipe direction mask that matches flipped dir
			return P
	// if no matching pipe, return null
	return null

	// merge two holder objects
	// used when a a holder meets a stuck holder
/obj/structure/disposalholder/proc/merge(var/obj/structure/disposalholder/other)
	for(var/atom/movable/AM in other)
		AM.loc = src		// move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)	// if a client mob, update eye to follow this holder
				M.client.eye = src

	if(other.has_fat_guy)
		has_fat_guy = 1
	qdel(other)


	// called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/user as mob)
	if(!istype(user,/mob/living))
		return

	var/mob/living/U = user

	if(U.stat || U.last_special <= world.time)
		return

	U.last_special = world.time+100

	if(src.loc)
		for(var/mob/M in hearers(src.loc.loc))
			to_chat(M, "<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>")

	playsound(src.loc, 'sound/effects/clang.ogg', 50, 0, 0)

	// called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(var/atom/location)
	if(location)
		location.assume_air(gas)  // vent all gas to turf
	air_update_turf()
	return

// Disposal pipes

/obj/structure/disposalpipe
	icon = 'icons/obj/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = 1
	density = 0

	on_blueprints = TRUE
	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	max_integrity = 200
	armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 30)
	damage_deflection = 10
	layer = DISPOSAL_PIPE_LAYER				// slightly lower than wires and other pipes
	var/base_icon_state	// initial icon state on map

	// new pipe, set the icon_state as on map
/obj/structure/disposalpipe/New()
	..()
	base_icon_state = icon_state


// pipe is deleted
// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	for(var/obj/structure/disposalholder/H in contents)
		H.active = 0
		var/turf/T = loc
		if(T.density)
			// deleting pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(0)
			qdel(H)
			..()
			return

		// otherwise, do normal expel from turf
		expel(H, T, 0)
	return ..()

/obj/structure/disposalpipe/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

// returns the direction of the next pipe object, given the entrance dir
// by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(var/fromdir)
	return dpdir & (~turn(fromdir, 180))

// transfer the holder through this pipe segment
// overriden for special behaviour
//
/obj/structure/disposalpipe/proc/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else			// if wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P


// update the icon_state to reflect hidden status
/obj/structure/disposalpipe/proc/update()
	var/turf/T = src.loc
	hide(T.intact && !istype(T,/turf/space))	// space never hides pipes
	update_icon()

// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalpipe/hide(var/intact)
	invisibility = intact ? 101: 0	// hide if floor is intact
	update_icon()

// update actual icon_state depending on visibility
// if invisible, append "f" to icon_state to show faded version
// this will be revealed if a T-scanner is used
// if visible, use regular icon_state
/obj/structure/disposalpipe/update_icon()
	if(invisibility)
		icon_state = "[base_icon_state]f"
	else
		icon_state = base_icon_state


// expel the held objects into a turf
// called when there is a break in the pipe
//

/obj/structure/disposalpipe/proc/expel(var/obj/structure/disposalholder/H, var/turf/T, var/direction)

	if(!T)
		return

	var/turf/target

	if(T.density)		// dense ouput turf, so stop holder
		H.active = 0
		H.loc = src
		return
	if(T.intact && istype(T,/turf/simulated/floor)) //intact floor, pop the tile
		var/turf/simulated/floor/F = T
		new F.builtin_tile.type(H)
		F.remove_tile(null,TRUE,FALSE)

	if(direction)		// direction is specified
		if(istype(T, /turf/space)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else						// otherwise limit to 10 tiles
			target = get_ranged_target_turf(T, direction, 10)

		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		if(H)
			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(direction)
				spawn(1)
					if(AM)
						AM.throw_at(target, 100, 1)
			H.vent_gas(T)
			qdel(H)

	else	// no specified direction, so throw in random direction

		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		if(H)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

				AM.loc = T
				AM.pipe_eject(0)
				spawn(1)
					if(AM)
						AM.throw_at(target, 5, 1)

			H.vent_gas(T)	// all gas vent to turf
			qdel(H)

// call to break the pipe
// will expel any holder inside at the time
// then delete the pipe
// remains : set to leave broken pipe pieces in place
/obj/structure/disposalpipe/proc/broken(remains = 0)
	if(remains)
		for(var/D in cardinal)
			if(D & dpdir)
				var/obj/structure/disposalpipe/broken/P = new(src.loc)
				P.setDir(D)

	invisibility = 101	// make invisible (since we won't delete the pipe immediately)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		// holder was present
		H.active = 0
		var/turf/T = src.loc
		if(T.density)
			// broken pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(0)
			qdel(H)
			return

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)

	spawn(2)	// delete pipe after 2 ticks to ensure expel proc finished
		qdel(src)

// pipe affected by explosion
/obj/structure/disposalpipe/ex_act(severity)
	switch(severity)
		if(1)
			broken(0)
		if(2)
			health -= rand(5, 15)
			healthcheck()
		if(3)
			health -= rand(0, 15)
			healthcheck()

// test health for brokenness
/obj/structure/disposalpipe/proc/healthcheck()
	if(health < -2)
		broken(0)
	else if(health<1)
		broken(1)
	return

//attack by item
//weldingtool: unfasten and convert to obj/disposalconstruct

/obj/structure/disposalpipe/attackby(var/obj/item/I, var/mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes

	add_fingerprint(user)

/obj/structure/disposalpipe/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	WELDER_SLICING_SUCCESS_MESSAGE
	var/obj/structure/disposalconstruct/C = new (get_turf(src))
	switch(base_icon_state)
		if("pipe-s")
			C.ptype = PIPE_DISPOSALS_STRAIGHT
		if("pipe-c")
			C.ptype = PIPE_DISPOSALS_BENT
		if("pipe-j1")
			C.ptype = PIPE_DISPOSALS_JUNCTION_RIGHT
		if("pipe-j2")
			C.ptype = PIPE_DISPOSALS_JUNCTION_LEFT
		if("pipe-y")
			C.ptype = PIPE_DISPOSALS_Y_JUNCTION
		if("pipe-t")
			C.ptype = PIPE_DISPOSALS_TRUNK
		if("pipe-j1s")
			C.ptype = PIPE_DISPOSALS_SORT_RIGHT
		if("pipe-j2s")
			C.ptype = PIPE_DISPOSALS_SORT_LEFT
	src.transfer_fingerprints_to(C)
	C.dir = dir
	C.density = FALSE
	C.anchored = TRUE
	C.update()

	qdel(src)

// *** TEST verb
//client/verb/dispstop()
//	for(var/obj/structure/disposalholder/H in world)
//		H.active = 0

// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/segment/New()
	..()
	if(icon_state == "pipe-s")
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)

	update()



//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/junction/New()
	..()
	if(icon_state == "pipe-j1")
		dpdir = dir | turn(dir, -90) | turn(dir,180)
	else if(icon_state == "pipe-j2")
		dpdir = dir | turn(dir, 90) | turn(dir,180)
	else // pipe-y
		dpdir = dir | turn(dir,90) | turn(dir, -90)
	update()


	// next direction to move
	// if coming in from secondary dirs, then next is primary dir
	// if coming in from primary dir, then next is equal chance of other dirs

/obj/structure/disposalpipe/junction/nextdir(var/fromdir)
	var/flipdir = turn(fromdir, 180)
	if(flipdir != dir)	// came from secondary dir
		return dir		// so exit through primary
	else				// came from primary
						// so need to choose either secondary exit
		var/mask = ..(fromdir)

		// find a bit which is set
		var/setbit = 0
		if(mask & NORTH)
			setbit = NORTH
		else if(mask & SOUTH)
			setbit = SOUTH
		else if(mask & EAST)
			setbit = EAST
		else
			setbit = WEST

		if(prob(50))	// 50% chance to choose the found bit or the other one
			return setbit
		else
			return mask & (~setbit)

//a three-way junction that sorts objects
/obj/structure/disposalpipe/sortjunction

	icon_state = "pipe-j1s"
	var/sortType = 0	//Look at the list called TAGGERLOCATIONS in /code/_globalvars/lists/flavor_misc.dm
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/sortjunction/proc/updatedesc()
	desc = "An underfloor disposal pipe with a package sorting mechanism."
	if(sortType>0)
		var/tag = uppertext(GLOB.TAGGERLOCATIONS[sortType])
		desc += "\nIt's tagged with [tag]"

/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)

	dpdir = sortdir | posdir | negdir

/obj/structure/disposalpipe/sortjunction/New()
	..()
	updatedir()
	updatedesc()
	update()
	return

/obj/structure/disposalpipe/sortjunction/attackby(var/obj/item/I, var/mob/user, params)
	if(..())
		return

	if(istype(I, /obj/item/destTagger))
		var/obj/item/destTagger/O = I

		if(O.currTag > 0)// Tag set
			sortType = O.currTag
			name = GLOB.TAGGERLOCATIONS[O.currTag]
			playsound(src.loc, 'sound/machines/twobeep.ogg', 100, 1)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, "<span class='notice'>Changed filter to [tag]</span>")
			updatedesc()


	// next direction to move
	// if coming in from negdir, then next is primary dir or sortdir
	// if coming in from posdir, then flip around and go back to posdir
	// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/sortjunction/nextdir(var/fromdir, var/sortTag)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir

		if(src.sortType == sortTag) //if destination matches filtered type...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
						// so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)
		H.loc = P
	else			// if wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P


//a three-way junction that sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/wrapsortjunction
	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects."
	icon_state = "pipe-j1s"
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/wrapsortjunction/New()
	..()
	posdir = dir
	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
		negdir = turn(posdir, 180)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)
		negdir = turn(posdir, 180)
	dpdir = sortdir | posdir | negdir

	update()
	return


	// next direction to move
	// if coming in from negdir, then next is primary dir or sortdir
	// if coming in from posdir, then flip around and go back to posdir
	// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/wrapsortjunction/nextdir(var/fromdir, var/istomail)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir
		if(istomail) //if destination matches filtered type...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
		return posdir 						// so go with the flow to positive direction

/obj/structure/disposalpipe/wrapsortjunction/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.tomail)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else			// if wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P

//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/New()
	..()
	dpdir = dir
	spawn(1)
		getlinked()

	update()
	return

/obj/structure/disposalpipe/trunk/Destroy()
	if(istype(linked, /obj/structure/disposaloutlet))
		var/obj/structure/disposaloutlet/O = linked
		O.expel(animation = 0)
	else if(istype(linked, /obj/machinery/disposal))
		var/obj/machinery/disposal/D = linked
		if(D.trunk == src)
			D.go_out()
			D.trunk = null
	remove_trunk_links()
	return ..()

/obj/structure/disposalpipe/trunk/proc/getlinked()
	var/obj/machinery/disposal/D = locate() in src.loc
	if(D)
		nicely_link_to_other_stuff(D)
		return
	var/obj/structure/disposaloutlet/O = locate() in src.loc
	if(O)
		nicely_link_to_other_stuff(O)

/obj/structure/disposalpipe/trunk/proc/remove_trunk_links() //disposals is well-coded
	if(!linked)
		return
	else if(istype(linked, /obj/machinery/disposal)) //jk lol
		var/obj/machinery/disposal/D = linked
		D.trunk = null
	else if(istype(linked, /obj/structure/disposaloutlet)) //God fucking damn it
		var/obj/structure/disposaloutlet/D = linked
		D.linkedtrunk = null
	linked = null

/obj/structure/disposalpipe/trunk/proc/nicely_link_to_other_stuff(obj/O)
	remove_trunk_links() //Breaks the connections between this trunk and the linked machinery so we don't get sent to nullspace or some shit like that
	if(istype(O, /obj/machinery/disposal))
		var/obj/machinery/disposal/D = O
		linked = D
		D.trunk = src
	else if(istype(O, /obj/structure/disposaloutlet))
		var/obj/structure/disposaloutlet/D = O
		linked = D
		D.linkedtrunk = src

	// Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/disposalpipe/trunk/attackby(var/obj/item/I, var/mob/user, params)

	//Disposal bins or chutes
	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in src.loc
	if(C && C.anchored)
		return

	var/turf/T = src.loc
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes
	src.add_fingerprint(user)

	// would transfer to next pipe segment, but we are in a trunk
	// if not entering from disposal bin,
	// transfer to linked object (outlet or bin)

/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/H)
	if(!H)
		return
	if(H.dir == DOWN)		// we just entered from a disposer
		return ..()		// so do base transfer proc
	// otherwise, go to the linked object
	if(!linked)
		expel(H, loc, FALSE)	// expel at turf
	else if(istype(linked, /obj/structure/disposaloutlet))
		var/obj/structure/disposaloutlet/DO = linked
		for(var/atom/movable/AM in H)
			AM.forceMove(DO)
		qdel(H)
		H.vent_gas(loc)
		DO.expel()
	else if(istype(linked, /obj/machinery/disposal))
		var/obj/machinery/disposal/D = linked
		H.forceMove(D)
		D.expel(H)	// expel at disposal
	else //just in case
		expel(H, loc, FALSE)
	// nextdir

/obj/structure/disposalpipe/trunk/nextdir(var/fromdir)
	if(fromdir == DOWN)
		return dir
	else
		return 0

// a broken pipe
/obj/structure/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

/obj/structure/disposalpipe/broken/New()
	..()
	update()
	return

/obj/structure/disposalpipe/broken/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, 0, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You remove [src]!</span>")
		I.play_tool_sound(src, I.tool_volume)
		qdel(src)
		return TRUE

// the disposal outlet machine

/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "outlet"
	density = 1
	anchored = 1
	var/active = 0
	var/turf/target	// this will be where the output objects are 'thrown' to.
	var/obj/structure/disposalpipe/trunk/linkedtrunk
	var/mode = 0

/obj/structure/disposaloutlet/New()
	..()
	spawn(1)
		target = get_ranged_target_turf(src, dir, 10)
		var/obj/structure/disposalpipe/trunk/T = locate() in loc
		if(T)
			T.nicely_link_to_other_stuff(src)

/obj/structure/disposaloutlet/Destroy()
	if(linkedtrunk)
		linkedtrunk.remove_trunk_links()
	expel(FALSE)
	return ..()


// expel the contents of the outlet
/obj/structure/disposaloutlet/proc/expel(animation = TRUE)
	if(animation)
		flick("outlet-open", src)
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0, 0)
		sleep(20)	//wait until correct animation frame
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
	for(var/atom/movable/AM in contents)
		AM.forceMove(loc)
		AM.pipe_eject(dir)
		if(istype(AM,/mob/living/silicon/robot/drone) || istype(AM, /mob/living/silicon/robot/syndicate/saboteur)) //Drones keep smashing windows from being fired out of chutes. Bad for the station. ~Z
			return
		spawn(5)
			if(QDELETED(AM))
				return
			AM.throw_at(target, 3, 1)


/obj/structure/disposaloutlet/attackby(var/obj/item/I, var/mob/user, params)
	if(!I || !user)
		return
	src.add_fingerprint(user)
	if(istype(I, /obj/item/screwdriver))
		if(mode==0)
			mode=1
			playsound(src.loc, I.usesound, 50, 1)
			to_chat(user, "You remove the screws around the power connection.")
			return
		else if(mode==1)
			mode=0
			playsound(src.loc, I.usesound, 50, 1)
			to_chat(user, "You attach the screws around the power connection.")
			return

/obj/structure/disposaloutlet/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		var/obj/structure/disposalconstruct/C = new (src.loc)
		C.ptype = PIPE_DISPOSALS_OUTLET
		C.update()
		C.anchored = TRUE
		C.density = TRUE
		transfer_fingerprints_to(C)
		qdel(src)

//When the disposalsoutlet is forcefully moved. Due to meteorshot or the recall item spell for instance
/obj/structure/disposaloutlet/Moved(atom/OldLoc, Dir)
	. = ..()
	var/turf/T = OldLoc
	if(T.intact)
		var/turf/simulated/floor/F = T
		F.remove_tile(null,TRUE,TRUE)
		T.visible_message("<span class='warning'>The floortile is ripped from the floor!</span>", "<span class='warning'>You hear a loud bang!</span>")
	if(linkedtrunk)
		linkedtrunk.remove_trunk_links()
	var/obj/structure/disposalconstruct/C = new (loc)
	transfer_fingerprints_to(C)
	C.ptype = PIPE_DISPOSALS_OUTLET
	C.update()
	C.anchored = 0
	C.density = 1
	qdel(src)

// called when movable is expelled from a disposal pipe or outlet
// by default does nothing, override for special behaviour

/atom/movable/proc/pipe_eject(var/direction)
	return

// check if mob has client, if so restore client view on eject
/mob/pipe_eject(var/direction)
	reset_perspective(null)

/obj/effect/decal/cleanable/blood/gibs/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)

/obj/effect/decal/cleanable/blood/gibs/robot/gib/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)

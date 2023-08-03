// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables
// Toilets are a type of disposal bin for small objects only and work on magic. By magic, I mean torque rotation
#define SEND_PRESSURE 0.05*ONE_ATMOSPHERE
/// How frequently disposals can make sounds, to prevent huge sound stacking
#define DISPOSAL_SOUND_COOLDOWN (0.1 SECONDS)

/obj/machinery/disposal
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit. Alt-click to manually eject its contents."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "disposal"
	anchored = TRUE
	density = TRUE
	on_blueprints = TRUE
	armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 100, BOMB = 0, RAD = 100, FIRE = 90, ACID = 30)
	max_integrity = 200
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	resistance_flags = FIRE_PROOF
	active_power_consumption = 600
	idle_power_consumption = 100

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
	C.anchored = FALSE
	C.density = TRUE
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

/obj/machinery/disposal/Initialize(mapload)
	// this will get a copy of the air turf and take a SEND PRESSURE amount of air from it
	. = ..()
	var/atom/L = loc
	var/datum/gas_mixture/env = new
	env.copy_from(L.return_air())
	var/datum/gas_mixture/removed = env.remove(SEND_PRESSURE + 1)
	air_contents = new
	air_contents.merge(removed)
	trunk_check()
	update()

// attack by item places it in to disposal
/obj/machinery/disposal/attackby(obj/item/I, mob/user, params)
	if(stat & BROKEN || !user || I.flags & ABSTRACT)
		return

	src.add_fingerprint(user)

	if(istype(I, /obj/item/melee/energy/blade))
		to_chat(user, "You can't place that item inside the disposal unit.")
		return

	if(isstorage(I))
		var/obj/item/storage/S = I
		if(!S.removal_allowed_check(user))
			return
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
				V.show_message("[usr] starts putting [GM] into the disposal.", 3)
			if(do_after(usr, 20, target = GM))
				GM.forceMove(src)
				for(var/mob/C in viewers(src))
					C.show_message("<span class='warning'>[GM] has been placed in [src] by [user].</span>", 3)
				qdel(G)
				add_attack_logs(usr, GM, "Disposal'ed", !!GM.ckey ? null : ATKLOG_ALL)
		return

	if(!user.drop_item() || QDELETED(I))
		return

	I.forceMove(src)
	user.visible_message("[user] places [I] into [src].", "You place [I] into [src].")
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
	update()

/obj/machinery/disposal/welder_act(mob/user, obj/item/I)
	if(mode != required_mode_to_deconstruct)
		return
	. = TRUE
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
		C.anchored = TRUE
		C.density = TRUE
		qdel(src)

/obj/machinery/disposal/shove_impact(mob/living/target, mob/living/attacker)
	target.visible_message(
		"<span class='warning'>[attacker] shoves [target] inside of [src]!</span>",
		"<span class='userdanger'>[attacker] shoves you inside of [src]!</span>",
		"<span class='warning'>You hear the sound of something being thrown in the trash.</span>"
	)
	target.forceMove(src)
	add_attack_logs(attacker, target, "Shoved into disposals", target.ckey ? null : ATKLOG_ALL)
	playsound(src, "sound/effects/bang.ogg")
	update()
	return TRUE

// mouse drop another mob or self
//
/obj/machinery/disposal/MouseDrop_T(mob/living/target, mob/living/user)
	if(!istype(target) || target.buckled || target.has_buckled_mobs() || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || isAI(user))
		return
	if(isanimal(user) && target != user)
		return //animals cannot put mobs other than themselves into disposal
	src.add_fingerprint(user)
	for(var/mob/V in viewers(usr))
		if(target == user && !user.stat && !user.IsWeakened() && !user.IsStunned() && !user.IsParalyzed())
			V.show_message("[usr] starts climbing into the disposal.", 3)
		if(target != user && !user.restrained() && !user.stat && !user.IsWeakened() && !user.IsStunned() && !user.IsParalyzed())
			if(target.anchored) return
			V.show_message("[usr] starts stuffing [target.name] into the disposal.", 3)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/disposal, put_in), target, user)
	return TRUE

/obj/machinery/disposal/proc/put_in(mob/living/target, mob/living/user) // need this proc to use INVOKE_ASYNC in other proc. You're not recommended to use that one
	var/msg
	var/target_loc = target.loc
	if(!do_after(usr, 20, target = target))
		return
	if(QDELETED(src) || target_loc != target.loc)
		return
	if(target == user && !user.stat && !user.IsWeakened() && !user.IsStunned() && !user.IsParalyzed())	// if drop self, then climbed in
											// must be awake, not stunned or whatever
		msg = "[user.name] climbs into [src]."
		to_chat(user, "You climb into [src].")
	else if(target != user && !user.restrained() && !user.stat && !user.IsWeakened() && !user.IsStunned() && !user.IsParalyzed())
		msg = "[user.name] stuffs [target.name] into [src]!"
		to_chat(user, "You stuff [target.name] into [src]!")
		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = user
		add_attack_logs(user, target, "Disposal'ed", !!target.ckey ? null : ATKLOG_ALL)
	else
		return
	target.forceMove(src)

	for(var/mob/C in viewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)

	update()

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

/obj/machinery/disposal/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "DisposalBin", name, 300, 250, master_ui, state)
		ui.open()


/obj/machinery/disposal/ui_data(mob/user)
	var/list/data = list()

	data["isAI"] = isAI(user)
	data["flushing"] = flush
	data["mode"] = mode
	data["pressure"] = round(clamp(100* air_contents.return_pressure() / (SEND_PRESSURE), 0, 100),1)

	return data

/obj/machinery/disposal/ui_act(action, params)
	if(..())
		return
	if(usr.loc == src)
		to_chat(usr, "<span class='warning'>You cannot reach the controls from inside.</span>")
		return

	if(mode==-1 && action != "eject") // If the mode is -1, only allow ejection
		to_chat(usr, "<span class='warning'>The disposal units power is disabled.</span>")
		return

	if(stat & BROKEN)
		return

	src.add_fingerprint(usr)

	if(src.flushing)
		return

	if(isturf(src.loc))
		if(action == "pumpOn")
			mode = 1
			update()
		if(action == "pumpOff")
			mode = 0
			update()

		if(!issilicon(usr))
			if(action == "engageHandle")
				flush = 1
				update()
			if(action == "disengageHandle")
				flush = 0
				update()

			if(action == "eject")
				eject()

	return TRUE

// eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		AM.pipe_eject(0)
	update()

/obj/machinery/disposal/AltClick(mob/user)
	if(!Adjacent(user) || !ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	user.visible_message(
		"<span class='notice'>[user] tries to eject the contents of [src] manually.</span>",
		"<span class='notice'>You operate the manual ejection lever on [src].</span>"
	)
	if(do_after(user, 5 SECONDS, target = src))
		user.visible_message(
			"<span class='notice'>[user] ejects the contents of [src].</span>",
			"<span class='notice'>You eject the contents of [src].</span>"
		)
		eject()

// update the icon & overlays to reflect mode & status
/obj/machinery/disposal/proc/update()
	if(stat & BROKEN)
		mode = 0
		flush = 0

	update_icon()

/obj/machinery/disposal/update_icon_state()
	. = ..()

	if(stat & BROKEN)
		icon_state = "disposal-broken"
		return

	icon_state = initial(icon_state)

/obj/machinery/disposal/update_overlays()
	. = ..()
	underlays.Cut()

	if(flush)
		. += "dispover-handle"

	if(stat & (NOPOWER|BROKEN) || mode == -1)
		return

	// 	check for items in disposal - occupied light
	if(contents.len > 0)
		. += "dispover-full"
		underlays += emissive_appearance(icon, "dispover-full")

	// charging and ready light
	switch(mode)
		if(-1)
			. += "dispover-unscrewed"
		if(1)
			. += "dispover-charge"
			underlays += emissive_appearance(icon, "dispover-charge")
		if(2)
			. += "dispover-ready"
			underlays += emissive_appearance(icon, "dispover-ready")

// timed process
// charge the gas reservoir and perform flush if ready
/obj/machinery/disposal/process()
	change_power_mode(NO_POWER_USE)
	if(stat & BROKEN)			// nothing can happen if broken
		return

	flush_count++
	if( flush_count >= flush_every_ticks )
		if( contents.len )
			if(mode == 2)
				spawn(0)
					flush()
		flush_count = 0

	src.updateDialog()

	if(flush && air_contents.return_pressure() >= SEND_PRESSURE )	// flush can happen even without power
		flush()

	if(stat & NOPOWER)			// won't charge if no power
		return

	change_power_mode(IDLE_POWER_USE)

	if(mode != 1)		// if off or ready, no need to charge
		return

	// otherwise charge
	change_power_mode(ACTIVE_POWER_USE)

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
	var/obj/structure/disposalholder/H = new(src)	// virtual holder object which actually
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
	if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
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
	if(!..())
		return	// do default setting/reset of stat NOPOWER bit
	update()	// update icon
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	return


// called when holder is expelled from a disposal
// should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(obj/structure/disposalholder/H)

	var/turf/target
	if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, FALSE)
		last_sound = world.time

	if(H) // Somehow, someone managed to flush a window which broke mid-transit and caused the disposal to go in an infinite loop trying to expel null, hopefully this fixes it
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.forceMove(loc)
			AM.pipe_eject(0)
			if(!isdrone(AM) && !istype(AM, /mob/living/silicon/robot/syndicate/saboteur)) //Poor drones kept smashing windows and taking system damage being fired out of disposals. ~Z
				spawn(1)
					if(AM)
						AM.throw_at(target, 5, 1)

		H.vent_gas(loc)
		qdel(H)

/obj/machinery/disposal/CanPass(atom/movable/mover, turf/target, height=0)
	if(isitem(mover) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(75))
			I.forceMove(src)
			for(var/mob/M in viewers(src))
				M.show_message("\the [I] lands in \the [src].", 3)
			update()
		else
			for(var/mob/M in viewers(src))
				M.show_message("\the [I] bounces off of \the [src]'s rim!", 3)
		return 0
	else
		return ..(mover, target, height)


/obj/machinery/disposal/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		qdel(src)

/obj/machinery/disposal/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)

/obj/machinery/disposal/force_eject_occupant(mob/target)
	target.forceMove(get_turf(src))

// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/structure/disposalholder
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	var/datum/gas_mixture/gas = null	// gas used to flush, will appear at exit point
	var/active = FALSE	// true if the holder is moving, otherwise inactive
	dir = 0
	var/count = 1000	//*** can travel 1000 steps before going inactive (in case of loops)
	var/has_fat_guy = 0	// true if contains a fat person
	/// Destination the holder is set to, defaulting to disposals and changes if the contents have a mail/sort tag.
	var/destinationTag = 1
	var/tomail = 0 //changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob

/obj/structure/disposalholder/Destroy()
	QDEL_NULL(gas)
	active = FALSE
	return ..()

	// initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(obj/machinery/disposal/D)
	gas = D.air_contents// transfer gas resv. into holder object

	//Check for any living mobs trigger hasmob.
	//hasmob effects whether the package goes to cargo or its tagged destination.
	for(var/mob/living/M in D)
		if(M && M.stat != 2 && !isdrone(M) && !istype(M, /mob/living/silicon/robot/syndicate/saboteur))
			hasmob = 1

	//Checks 1 contents level deep. This means that players can be sent through disposals...
	//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
	for(var/obj/O in D)
		if(O.contents)
			for(var/mob/living/M in O.contents)
				if(M && M.stat != 2 && !isdrone(M) && !istype(M, /mob/living/silicon/robot/syndicate/saboteur))
					hasmob = 1

	// now everything inside the disposal gets put into the holder
	// note AM since can contain mobs or objs
	for(var/atom/movable/AM in D)
		AM.forceMove(src)
		SEND_SIGNAL(AM, COMSIG_MOVABLE_DISPOSING, src, D)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(HAS_TRAIT(H, TRAIT_FAT))		// is a human and fat?
				has_fat_guy = 1			// set flag on holder
		if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
			var/obj/structure/bigDelivery/T = AM
			destinationTag = T.sortTag
		if(istype(AM, /obj/item/smallDelivery) && !hasmob)
			var/obj/item/smallDelivery/T = AM
			destinationTag = T.sortTag
		//Drones can mail themselves through maint.
		if(isdrone(AM))
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
/obj/structure/disposalholder/proc/start(obj/machinery/disposal/D)
	if(!D.trunk)
		D.expel(src)	// no trunk connected, so expel immediately
		return

	forceMove(D.trunk)
	active = TRUE
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
			active = FALSE
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
			active = FALSE
	return



	// find the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step(loc,dir)

	// find a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(turf/T)
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
/obj/structure/disposalholder/proc/merge(obj/structure/disposalholder/other)
	for(var/atom/movable/AM in other)
		AM.forceMove(src)		// move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			M.reset_perspective(src)	// if a client mob, update eye to follow this holder

	if(other.has_fat_guy)
		has_fat_guy = 1
	qdel(other)


	// called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/user)
	if(!isliving(user))
		return

	var/mob/living/U = user

	if(U.stat || world.time <= U.last_special)
		return

	U.last_special = world.time + 100

	if(loc)
		for(var/mob/M in hearers(loc.loc))
			to_chat(M, "<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>")

	playsound(loc, 'sound/effects/clang.ogg', 50, 0, 0)

	// called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(atom/location)
	if(location)
		location.assume_air(gas)  // vent all gas to turf
	air_update_turf()
	return

// Disposal pipes

/obj/structure/disposalpipe
	icon = 'icons/obj/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = TRUE
	density = FALSE

	on_blueprints = TRUE
	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	max_integrity = 200
	armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 100, BOMB = 0, RAD = 100, FIRE = 90, ACID = 30)
	damage_deflection = 10
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	plane = FLOOR_PLANE
	layer = DISPOSAL_PIPE_LAYER				// slightly lower than wires and other pipes
	base_icon_state	// initial icon state on map
	/// The last time a sound was played from this
	var/last_sound

	// new pipe, set the icon_state as on map
/obj/structure/disposalpipe/Initialize(mapload)
	. = ..()
	base_icon_state = icon_state


// pipe is deleted
// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	for(var/obj/structure/disposalholder/H in contents)
		H.active = FALSE
		var/turf/T = loc
		if(T.density)
			// deleting pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.forceMove(T)
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
/obj/structure/disposalpipe/proc/nextdir(fromdir)
	return dpdir & (~turn(fromdir, 180))

// transfer the holder through this pipe segment
// overriden for special behaviour
//
/obj/structure/disposalpipe/proc/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P


// update the icon_state to reflect hidden status and change icon when welded
/obj/structure/disposalpipe/proc/update()
	var/turf/T = get_turf(src)
	hide(T.intact && !isspaceturf(T) && !T.transparent_floor)	// space and transparent floors never hide pipes
	update_icon(UPDATE_ICON_STATE)

// hide called by levelupdate if turf intact status changes
// change visibility status
/obj/structure/disposalpipe/hide(intact)
	if(intact)
		invisibility = INVISIBILITY_MAXIMUM
		alpha = 128
		return
	invisibility = INVISIBILITY_MINIMUM
	alpha = 255

// makes sure we are using the right icon state when we secure the disposals
/obj/structure/disposalpipe/update_icon_state()
	icon_state = base_icon_state

// expel the held objects into a turf
// called when there is a break in the pipe
//

/obj/structure/disposalpipe/proc/expel(obj/structure/disposalholder/H, turf/T, direction)

	if(!T)
		return

	var/turf/target

	if(T.density)		// dense ouput turf, so stop holder
		H.active = FALSE
		H.forceMove(src)
		return
	if(T.intact && isfloorturf(T)) //intact floor, pop the tile
		var/turf/simulated/floor/F = T
		var/turf_typecache = F.floor_tile
		if(F.remove_tile(null, TRUE, FALSE))
			new turf_typecache(T)

	if(direction)		// direction is specified
		if(isspaceturf(T)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else						// otherwise limit to 10 tiles
			target = get_ranged_target_turf(T, direction, 10)

		if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
			playsound(src, 'sound/machines/hiss.ogg', 50, 0, FALSE)
			last_sound = world.time

		if(H)
			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(direction)
				SEND_SIGNAL(AM, COMSIG_MOVABLE_EXIT_DISPOSALS)

				spawn(1)
					if(AM)
						AM.throw_at(target, 100, 1)
			H.vent_gas(T)
			qdel(H)

	else	// no specified direction, so throw in random direction

		if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
			playsound(src, 'sound/machines/hiss.ogg', 50, 0, FALSE)
			last_sound = world.time
		if(H)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

				AM.forceMove(T)
				AM.pipe_eject(0)
				SEND_SIGNAL(AM, COMSIG_MOVABLE_EXIT_DISPOSALS)

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
		for(var/D in GLOB.cardinal)
			if(D & dpdir)
				var/obj/structure/disposalpipe/broken/P = new(src.loc)
				P.setDir(D)

	invisibility = 101	// make invisible (since we won't delete the pipe immediately)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		// holder was present
		H.active = FALSE
		var/turf/T = src.loc
		if(T.density)
			// broken pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.forceMove(T)
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

/obj/structure/disposalpipe/attackby(obj/item/I, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact || T.transparent_floor)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return 		// prevent interaction with T-scanner revealed pipes and pipes under glass

	add_fingerprint(user)

/obj/structure/disposalpipe/welder_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(!I.tool_use_check(user, 0))
		return
	if(T.transparent_floor)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
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
//		H.active = FALSE

// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/segment/Initialize(mapload)
	. = ..()
	if(icon_state == "pipe-s")
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)
	update()

/obj/structure/disposalpipe/segment/corner
	icon_state = "pipe-c"

//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/junction/reversed
	icon_state = "pipe-j2"

/obj/structure/disposalpipe/junction/y
	icon_state = "pipe-y"

/obj/structure/disposalpipe/junction/Initialize(mapload)
	. = ..()
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

/obj/structure/disposalpipe/junction/nextdir(fromdir)
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
	name = "disposal sort junction"
	icon_state = "pipe-j1s"
	var/list/sort_type = list(1)
	var/sort_type_txt //Look at the list called TAGGERLOCATIONS in /code/_globalvars/lists/flavor_misc.dm and cry
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/sortjunction/reversed
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)

	dpdir = sortdir | posdir | negdir

/obj/structure/disposalpipe/sortjunction/Initialize(mapload)
	. = ..()
	updatedir()
	if(mapload)
		parse_sort_destinations()
	update_appearance(UPDATE_DESC)
	update()
	return

/obj/structure/disposalpipe/sortjunction/proc/parse_sort_destinations()
	if(sort_type_txt == "1")
		return

	var/list/sort_type_str = splittext(sort_type_txt, ";")
	var/mapping_fail

	if(length(sort_type_str)) // Default to disposals if mapped with it along other destinations
		if("1" in sort_type_str)
			mapping_fail = "Mutually exclusive sort types in sort_type_txt"
		else
			var/new_sort_type = list()
			for(var/x in sort_type_str)
				var/n = text2num(x)
				if(n)
					new_sort_type |= n
			if(length(new_sort_type))
				sort_type = new_sort_type
			else
				mapping_fail = "No sort types after parsing sort_type_txt"
	else
		mapping_fail = "Sort_type_txt is empty"
	if(mapping_fail)
		stack_trace("[src] mapped incorrectly at [x],[y],[z] - [mapping_fail]")

/obj/structure/disposalpipe/sortjunction/attackby(obj/item/I, mob/user, params)
	if(..())
		return

	if(istype(I, /obj/item/destTagger))
		var/obj/item/destTagger/O = I
		var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
		playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)
		if(O.currTag == 1)
			sort_type = list(1)
			to_chat(user, "<span class='notice'>Filter set to [tag] only.</span>")
		else if(O.currTag in sort_type)
			sort_type.Remove(O.currTag)
			to_chat(user, "<span class='notice'>Removed [tag] from filter.</span>")
			if(!length(sort_type))
				sort_type.Add(1) // Default to Disposals if everything is removed.
				to_chat(user, "<span class='notice'>Filter defaulting to [uppertext(GLOB.TAGGERLOCATIONS[1])].</span>")
		else
			if(1 in sort_type) // Remove Disposals if a destination is added.
				sort_type.Remove(1)
			sort_type.Add(O.currTag)
			to_chat(user, "<span class='notice'>Added [tag] to filter.</span>")
		update_appearance(UPDATE_NAME|UPDATE_DESC)

/obj/structure/disposalpipe/sortjunction/update_name()
	. = ..()
	name = initial(name)
	if(length(sort_type) == 1)
		name += " - [GLOB.TAGGERLOCATIONS[sort_type[1]]]"
		return
	name = "multi disposal sort junction"

/obj/structure/disposalpipe/sortjunction/update_desc()
	. = ..()
	desc = "An underfloor disposal pipe with a package sorting mechanism."
	if(length(sort_type))
		var/tags = list()
		for(var/destinations in sort_type)
			tags += GLOB.TAGGERLOCATIONS[destinations]
		desc += "\nIt's tagged with [english_list(tags)]."

	// next direction to move
	// if coming in from negdir, then next is primary dir or sortdir
	// if coming in from posdir, then flip around and go back to posdir
	// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/sortjunction/nextdir(fromdir, sortTag)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir

		if(sortTag in sort_type) //if destination matches filtered types...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
						// so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)
		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P


//a three-way junction that sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/wrapsortjunction
	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects."
	icon_state = "pipe-j1s"
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/wrapsortjunction/reversed
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/wrapsortjunction/Initialize(mapload)
	. = ..()
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

/obj/structure/disposalpipe/wrapsortjunction/nextdir(fromdir, istomail)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir
		if(istomail) //if destination matches filtered type...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
		return posdir 						// so go with the flow to positive direction

/obj/structure/disposalpipe/wrapsortjunction/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.tomail)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P

//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/Initialize(mapload)
	. = ..()
	dpdir = dir
	addtimer(CALLBACK(src, PROC_REF(getlinked)), 0) // This has a delay of 0, but wont actually start until the MC is done

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
	var/turf/T = get_turf(src)
	var/obj/machinery/disposal/D = locate() in T
	if(D)
		nicely_link_to_other_stuff(D)
		return
	var/obj/structure/disposaloutlet/O = locate() in T
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
/obj/structure/disposalpipe/trunk/attackby(obj/item/I, mob/user, params)

	//Disposal bins or chutes
	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in src.loc
	if(C && C.anchored)
		return

	var/turf/T = src.loc
	if(T.intact || T.transparent_floor)
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

/obj/structure/disposalpipe/trunk/nextdir(fromdir)
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

/obj/structure/disposalpipe/broken/Initialize(mapload)
	. = ..()
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
	density = TRUE
	anchored = TRUE
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	var/active = FALSE
	var/turf/target	// this will be where the output objects are 'thrown' to.
	var/obj/structure/disposalpipe/trunk/linkedtrunk
	var/mode = FALSE // Is the maintenance panel open? Different than normal disposal's mode
	/// The last time a sound was played
	var/last_sound

/obj/structure/disposaloutlet/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(setup)), 0) // Wait of 0, but this wont actually do anything until the MC is firing


/obj/structure/disposaloutlet/proc/setup()
	target = get_ranged_target_turf(src, dir, 10)
	var/obj/structure/disposalpipe/trunk/T = locate() in get_turf(src)
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
		var/play_sound = FALSE
		if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
			play_sound = TRUE
			last_sound = world.time
		if(play_sound)
			playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0, FALSE)
		sleep(20)	//wait until correct animation frame
		if(play_sound)
			playsound(src, 'sound/machines/hiss.ogg', 50, 0, FALSE)
	for(var/atom/movable/AM in contents)
		AM.forceMove(loc)
		AM.pipe_eject(dir)
		if(isdrone(AM) || istype(AM, /mob/living/silicon/robot/syndicate/saboteur)) //Drones keep smashing windows from being fired out of chutes. Bad for the station. ~Z
			return
		spawn(5)
			if(QDELETED(AM))
				return
			AM.throw_at(target, 3, 1)

/obj/structure/disposaloutlet/screwdriver_act(mob/living/user, obj/item/I)
	add_fingerprint(user)

	if(mode == FALSE)
		to_chat(user, "<span class='notice'>You remove the screws around the power connection.</span>")
	else if(mode == TRUE)
		to_chat(user, "<span class='notice'>You attach the screws around the power connection.</span>")
	I.play_tool_sound(src)
	mode = !mode
	return TRUE

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
	C.anchored = FALSE
	C.density = TRUE
	qdel(src)

// called when movable is expelled from a disposal pipe or outlet
// by default does nothing, override for special behaviour

/atom/movable/proc/pipe_eject(direction)
	return

/obj/effect/decal/cleanable/blood/gibs/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	src.streak(dirs)

/obj/effect/decal/cleanable/blood/gibs/robot/gib/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	src.streak(dirs)

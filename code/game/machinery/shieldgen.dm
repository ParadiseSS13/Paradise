/obj/machinery/shield
		name = "Emergency energy shield"
		desc = "An energy shield used to contain hull breaches."
		icon = 'icons/effects/effects.dmi'
		icon_state = "shield-old"
		density = 1
		opacity = FALSE
		anchored = 1
		resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
		var/const/max_health = 200
		var/health = max_health //The shield can only take so much beating (prevents perma-prisons)

/obj/machinery/shield/New()
	dir = pick(NORTH, SOUTH, EAST, WEST)
	..()

/obj/machinery/shield/Initialize()
	air_update_turf(1)
	..()

/obj/machinery/shield/Destroy()
	opacity = FALSE
	density = 0
	air_update_turf(1)
	return ..()

/obj/machinery/shield/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/machinery/shield/CanPass(atom/movable/mover, turf/target, height)
	if(!height)
		return FALSE
	return ..()

/obj/machinery/shield/CanAtmosPass(turf/T)
	return !density

/obj/machinery/shield/attackby(obj/item/I, mob/user, params)
	if(!istype(I))
		return

	//Calculate damage
	var/aforce = I.force
	if(I.damtype == BRUTE || I.damtype == BURN)
		health -= aforce

	//Play a fitting sound
	playsound(loc, 'sound/effects/empulse.ogg', 75, 1)

	if(health <= 0)
		visible_message("<span class='notice'>The [src] dissipates</span>")
		qdel(src)
		return

	opacity = TRUE
	spawn(20)
		if(src)
			opacity = FALSE

	..()

/obj/machinery/shield/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <=0)
		visible_message("<span class='notice'>The [src] dissipates</span>")
		qdel(src)
		return
	opacity = TRUE
	spawn(20)
		if(src)
			opacity = FALSE

/obj/machinery/shield/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(75))
				qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
		if(3.0)
			if(prob(25))
				qdel(src)

/obj/machinery/shield/emp_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)

/obj/machinery/shield/blob_act()
	qdel(src)


/obj/machinery/shield/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/O = AM
		tforce = O.throwforce

	health -= tforce

	//This seemed to be the best sound for hitting a force field.
	playsound(loc, 'sound/effects/empulse.ogg', 100, 1)

	//Handle the destruction of the shield
	if(health <= 0)
		visible_message("<span class='notice'>The [src] dissipates</span>")
		qdel(src)
		return

	//The shield becomes dense to absorb the blow.. purely asthetic.
	opacity = TRUE
	spawn(20)
		if(src)
			opacity = FALSE


/obj/machinery/shieldgen
	name = "Emergency shield projector"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	density = 1
	opacity = FALSE
	anchored = 0
	pressure_resistance = 2*ONE_ATMOSPHERE
	req_access = list(access_engine)
	var/const/max_health = 100
	var/health = max_health
	var/active = 0
	var/malfunction = FALSE //Malfunction causes parts of the shield to slowly dissapate
	var/list/deployed_shields = list()
	var/is_open = FALSE //Whether or not the wires are exposed
	var/locked = FALSE

/obj/machinery/shieldgen/Destroy()
	QDEL_LIST(deployed_shields)
	deployed_shields = null
	return ..()


/obj/machinery/shieldgen/proc/shields_up()
	if(active)
		return //If it's already turned on, how did this get called?

	active = 1
	update_icon()
	anchored = 1

	for(var/turf/target_tile in range(2, src))
		if(istype(target_tile,/turf/space) && !(locate(/obj/machinery/shield) in target_tile))
			if(malfunction && prob(33) || !malfunction)
				deployed_shields += new /obj/machinery/shield(target_tile)

/obj/machinery/shieldgen/proc/shields_down()
	if(!active)
		return //If it's already off, how did this get called?

	active = 0
	update_icon()

	for(var/obj/machinery/shield/shield_tile in deployed_shields)
		qdel(shield_tile)

/obj/machinery/shieldgen/process()
	if(malfunction && active)
		if(deployed_shields.len && prob(5))
			qdel(pick(deployed_shields))

	return

/obj/machinery/shieldgen/proc/checkhp()
	if(health <= 30)
		malfunction = TRUE
	if(health <= 0)
		qdel(src)
	update_icon()
	return

/obj/machinery/shieldgen/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= 75
			checkhp()
		if(2.0)
			health -= 30
			if(prob(15))
				malfunction = TRUE
			checkhp()
		if(3.0)
			health -= 10
			checkhp()
	return

/obj/machinery/shieldgen/emp_act(severity)
	switch(severity)
		if(1)
			health = health * 0.5 //cut health in half
			malfunction = TRUE
			locked = pick(TRUE, FALSE)
		if(2)
			if(prob(50))
				health *= 0.3 //chop off a third of the health
				malfunction = TRUE
	checkhp()

/obj/machinery/shieldgen/attack_hand(mob/user as mob)
	if(locked)
		to_chat(user, "The machine is locked, you are unable to use it.")
		return
	if(is_open)
		to_chat(user, "The panel must be closed before operating this machine.")
		return

	if(active)
		user.visible_message("<span class='notice'>[bicon(src)] [user] deactivated the shield generator.</span>", \
			"<span class='notice'>[bicon(src)] You deactivate the shield generator.</span>", \
			"You hear heavy droning fade out.")
		shields_down()
	else
		if(anchored)
			user.visible_message("<span class='notice'>[bicon(src)] [user] activated the shield generator.</span>", \
				"<span class='notice'>[bicon(src)] You activate the shield generator.</span>", \
				"You hear heavy droning.")
			shields_up()
		else
			to_chat(user, "The device must first be secured to the floor.")

/obj/machinery/shieldgen/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/card/emag))
		malfunction = TRUE
		update_icon()

	else if(istype(I, /obj/item/stack/cable_coil) && malfunction && is_open)
		var/obj/item/stack/cable_coil/coil = I
		to_chat(user, "<span class='notice'>You begin to replace the wires.</span>")
		if(do_after(user, 30 * coil.toolspeed, target = src))
			if(!src || !coil)
				return
			coil.use(1)
			health = max_health
			malfunction = TRUE
			playsound(loc, coil.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You repair the [src]!</span>")
			update_icon()

	else if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda))
		if(allowed(user))
			locked = !locked
			to_chat(user, "The controls are now [locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else
		return ..()

/obj/machinery/shieldgen/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	is_open = !is_open
	if(is_open)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE

/obj/machinery/shieldgen/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(locked)
		to_chat(user, "The bolts are covered, unlocking this would retract the covers.")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		WRENCH_UNANCHOR_MESSAGE
		if(active)
			visible_message("<span class='warning'>[src] shuts off!</span>")
			shields_down()
		anchored = FALSE
	else
		if(istype(get_turf(src), /turf/space))
			return //No wrenching these in space!
		WRENCH_ANCHOR_MESSAGE
		anchored = TRUE

/obj/machinery/shieldgen/update_icon()
	if(active)
		icon_state = malfunction ? "shieldonbr":"shieldon"
	else
		icon_state = malfunction ? "shieldoffbr":"shieldoff"
	return


////FIELD GEN START //shameless copypasta from fieldgen, powersink, and grille
#define maxstoredpower 500
/obj/machinery/shieldwallgen
		name = "Shield Generator"
		desc = "A shield generator."
		icon = 'icons/obj/stationobjs.dmi'
		icon_state = "Shield_Gen"
		anchored = 0
		density = 1
		req_access = list(access_teleporter)
		var/active = 0
		var/power = 0
		var/state = 0
		var/steps = 0
		var/last_check = 0
		var/check_delay = 10
		var/recalc = 0
		var/locked = TRUE
		var/destroyed = 0
		var/directwired = 1
		var/obj/structure/cable/attached		// the attached cable
		var/storedpower = 0
		flags = CONDUCT
		use_power = NO_POWER_USE

/obj/machinery/shieldwallgen/proc/power()
	if(!anchored)
		power = 0
		return 0
	var/turf/T = loc

	var/obj/structure/cable/C = T.get_cable_node()
	var/datum/powernet/PN
	if(C)
		PN = C.powernet		// find the powernet of the connected cable

	if(!PN)
		power = 0
		return 0

	var/surplus = max(PN.avail-PN.load, 0)
	var/shieldload = min(rand(50,200), surplus)
	if(shieldload==0 && !storedpower)		// no cable or no power, and no power stored
		power = 0
		return 0
	else
		power = 1	// IVE GOT THE POWER!
		if(PN) //runtime errors fixer. They were caused by PN.load trying to access missing network in case of working on stored power.
			storedpower += shieldload
			PN.load += shieldload //uses powernet power.
//		message_admins("[PN.load]", 1)
//		use_power(250) //uses APC power

/obj/machinery/shieldwallgen/attack_hand(mob/user)
	if(state != 1)
		to_chat(user, "<span class='warning'>The shield generator needs to be firmly secured to the floor first.</span>")
		return 1
	if(locked && !issilicon(user))
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return 1
	if(power != 1)
		to_chat(user, "<span class='warning'>The shield generator needs to be powered by wire underneath.</span>")
		return 1

	if(active >= 1)
		active = 0
		icon_state = "Shield_Gen"

		user.visible_message("[user] turned the shield generator off.", \
			"You turn off the shield generator.", \
			"You hear heavy droning fade out.")
		for(var/dir in list(NORTH, SOUTH, EAST, WEST))
			cleanup(dir)
	else
		active = 1
		icon_state = "Shield_Gen +a"
		user.visible_message("[user] turned the shield generator on.", \
			"You turn on the shield generator.", \
			"You hear heavy droning.")
	add_fingerprint(user)

/obj/machinery/shieldwallgen/process()
	spawn(100)
		power()
		if(power)
			storedpower -= 50 //this way it can survive longer and survive at all
	if(storedpower >= maxstoredpower)
		storedpower = maxstoredpower
	if(storedpower <= 0)
		storedpower = 0

	if(active == 1)
		if(!state == 1)
			active = 0
			return
		spawn(1)
			setup_field(1)
		spawn(2)
			setup_field(2)
		spawn(3)
			setup_field(4)
		spawn(4)
			setup_field(8)
		active = 2
	if(active >= 1)
		if(power == 0)
			visible_message("<span class='warning'>The [name] shuts down due to lack of power!</span>", \
				"You hear heavy droning fade out")
			icon_state = "Shield_Gen"
			active = 0
			for(var/dir in list(NORTH, SOUTH, EAST, WEST))
				cleanup(dir)

/obj/machinery/shieldwallgen/proc/setup_field(NSEW = 0)
	var/turf/T = loc
	var/turf/T2 = loc
	var/obj/machinery/shieldwallgen/G
	var/steps = 0
	var/oNSEW = 0

	if(!NSEW)//Make sure its ran right
		return

	if(NSEW == 1)
		oNSEW = 2
	else if(NSEW == 2)
		oNSEW = 1
	else if(NSEW == 4)
		oNSEW = 8
	else if(NSEW == 8)
		oNSEW = 4

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for another generator
		T = get_step(T2, NSEW)
		T2 = T
		steps += 1
		if(locate(/obj/machinery/shieldwallgen) in T)
			G = (locate(/obj/machinery/shieldwallgen) in T)
			steps -= 1
			if(!G.active)
				return
			G.cleanup(oNSEW)
			break

	if(isnull(G))
		return

	T2 = loc

	for(var/dist = 0, dist < steps, dist += 1) // creates each field tile
		var/field_dir = get_dir(T2,get_step(T2, NSEW))
		T = get_step(T2, NSEW)
		T2 = T
		var/obj/machinery/shieldwall/CF = new/obj/machinery/shieldwall/(src, G) //(ref to this gen, ref to connected gen)
		CF.loc = T
		CF.dir = field_dir


/obj/machinery/shieldwallgen/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wrench))
		if(active)
			to_chat(user, "Turn off the field generator first.")
			return

		else if(state == 0)
			state = 1
			playsound(loc, I.usesound, 75, 1)
			to_chat(user, "You secure the external reinforcing bolts to the floor.")
			anchored = 1
			return

		else if(state == 1)
			state = 0
			playsound(loc, I.usesound, 75, 1)
			to_chat(user, "You undo the external reinforcing bolts.")
			anchored = 0
			return

	if(istype(I, /obj/item/card/id)||istype(I, /obj/item/pda))
		if(allowed(user))
			locked = !locked
			to_chat(user, "Controls are now [locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else
		add_fingerprint(user)
		..()

/obj/machinery/shieldwallgen/proc/cleanup(NSEW)
	var/obj/machinery/shieldwall/F
	var/obj/machinery/shieldwallgen/G
	var/turf/T = loc
	var/turf/T2 = loc

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for fields
		T = get_step(T2, NSEW)
		T2 = T
		if(locate(/obj/machinery/shieldwall) in T)
			F = (locate(/obj/machinery/shieldwall) in T)
			if(F.gen_primary == src || F.gen_secondary == src)
				qdel(F)

		if(locate(/obj/machinery/shieldwallgen) in T)
			G = (locate(/obj/machinery/shieldwallgen) in T)
			if(!G.active)
				break

/obj/machinery/shieldwallgen/Destroy()
	cleanup(1)
	cleanup(2)
	cleanup(4)
	cleanup(8)
	return ..()

/obj/machinery/shieldwallgen/bullet_act(obj/item/projectile/Proj)
	storedpower -= Proj.damage
	..()
	return


////////////// Containment Field START
/obj/machinery/shieldwall
		name = "Shield"
		desc = "An energy shield."
		icon = 'icons/effects/effects.dmi'
		icon_state = "shieldwall"
		anchored = 1
		density = 1
		resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
		light_range = 3
		var/needs_power = 0
		var/active = 1
		var/delay = 5
		var/last_active
		var/mob/U
		var/obj/machinery/shieldwallgen/gen_primary
		var/obj/machinery/shieldwallgen/gen_secondary

/obj/machinery/shieldwall/New(obj/machinery/shieldwallgen/A, obj/machinery/shieldwallgen/B)
	..()
	gen_primary = A
	gen_secondary = B
	if(A && B)
		needs_power = 1

/obj/machinery/shieldwall/attack_hand(mob/user)
	return

/obj/machinery/shieldwall/rpd_blocksusage()
	return TRUE

/obj/machinery/shieldwall/process()
	if(needs_power)
		if(isnull(gen_primary)||isnull(gen_secondary))
			qdel(src)
			return

		if(!(gen_primary.active)||!(gen_secondary.active))
			qdel(src)
			return

		if(prob(50))
			gen_primary.storedpower -= 10
		else
			gen_secondary.storedpower -=10


/obj/machinery/shieldwall/bullet_act(obj/item/projectile/Proj)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		if(prob(50))
			G = gen_primary
		else
			G = gen_secondary
		G.storedpower -= Proj.damage
	..()
	return


/obj/machinery/shieldwall/ex_act(severity)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		switch(severity)
			if(1.0) //big boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 200

			if(2.0) //medium boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 50

			if(3.0) //lil boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 20
	return


/obj/machinery/shieldwall/CanPass(atom/movable/mover, turf/target, height=0)
	if(height == 0)
		return TRUE

	if(istype(mover) && mover.checkpass(PASSGLASS))
		return prob(20)
	else
		if(istype(mover, /obj/item/projectile))
			return prob(10)
		else
			return !density


/obj/machinery/shieldwall/syndicate
	name = "energy shield"
	desc = "A strange energy shield."
	icon_state = "shield-red"

/obj/machinery/shieldwall/syndicate/CanPass(atom/movable/mover, turf/target, height=0)
	if(isliving(mover))
		var/mob/living/M = mover
		if("syndicate" in M.faction)
			return 1
	if(istype(mover, /obj/item/projectile))
		return 0
	return ..(mover, target, height)

/obj/machinery/shieldwall/syndicate/CanAStarPass(ID, to_dir, caller)
	if(isliving(caller))
		var/mob/living/M = caller
		if("syndicate" in M.faction)
			return 1
	return ..(ID, to_dir, caller)

/obj/machinery/shieldwall/syndicate/proc/phaseout()
	// If you're bumping into an invisible shield, make it fully visible, then fade out over a couple of seconds.
	if(alpha == 0)
		alpha = 255
		animate(src, alpha = 10, time = 20, easing = EASE_OUT)
		spawn(20)
			alpha = 0

/obj/machinery/shieldwall/syndicate/Bumped(atom/user)
	phaseout()
	return ..()

/obj/machinery/shieldwall/syndicate/attackby(obj/item/W, mob/user, params)
	phaseout()
	return ..()

/obj/machinery/shieldwall/syndicate/bullet_act(obj/item/projectile/Proj)
	phaseout()
	return ..()

/obj/machinery/shieldwall/syndicate/ex_act(severity)
	phaseout()
	return ..()

/obj/machinery/shieldwall/syndicate/emp_act(severity)
	phaseout()
	return ..()

/obj/machinery/shieldwall/syndicate/attack_hand(mob/user)
	phaseout()
	return ..()

/obj/machinery/shieldwall/syndicate/hitby(AM as mob|obj)
	phaseout()
	return ..()

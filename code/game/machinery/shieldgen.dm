/obj/machinery/shield
		name = "Emergency energy shield"
		desc = "An energy shield used to contain hull breaches."
		icon = 'icons/effects/effects.dmi'
		icon_state = "shield-old"
		density = TRUE
		opacity = FALSE
		anchored = TRUE
		move_resist = INFINITY
		resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
		flags_2 = RAD_NO_CONTAMINATE_2
		max_integrity = 200

/obj/machinery/shield/Initialize(mapload)
	. = ..()
	dir = pick(NORTH, SOUTH, EAST, WEST)
	air_update_turf(1)

/obj/machinery/shield/Destroy()
	opacity = FALSE
	density = FALSE
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

/obj/machinery/shield/cult
	name = "cult barrier"
	desc = "A shield summoned by cultists to keep heretics away."
	max_integrity = 100
	icon_state = "shield-cult"

/obj/machinery/shield/cult/emp_act(severity)
	return

/obj/machinery/shield/cult/narsie
	name = "sanguine barrier"
	desc = "A potent shield summoned by cultists to defend their rites."
	max_integrity = 60

/obj/machinery/shield/cult/weak
	name = "Invoker's Shield"
	desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals."
	max_integrity = 20
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER

/obj/machinery/shield/cult/barrier
	density = FALSE
	/// The rune that created the shield itself. Used to delete the rune when the shield is destroyed.
	var/obj/effect/rune/parent_rune

/obj/machinery/shield/cult/barrier/Initialize()
	. = ..()
	invisibility = INVISIBILITY_MAXIMUM

/obj/machinery/shield/cult/barrier/Destroy()
	if(parent_rune && !QDELETED(parent_rune))
		QDEL_NULL(parent_rune)
	return ..()

/obj/machinery/shield/cult/barrier/attack_hand(mob/living/user)
	parent_rune.attack_hand(user)

/obj/machinery/shield/cult/barrier/attack_animal(mob/living/simple_animal/user)
	if(IS_CULTIST(user))
		parent_rune.attack_animal(user)
	else
		..()

/**
* Turns the shield on and off.
*
* The shield has 2 states: on and off. When on, it will block movement, projectiles, items, etc. and be clearly visible, and block atmospheric gases.
* When off, the rune no longer blocks anything and turns invisible.
* The barrier itself is not intended to interact with the conceal runes cult spell for balance purposes.
*/
/obj/machinery/shield/cult/barrier/proc/Toggle()
	var/visible
	if(!density) // Currently invisible
		density = TRUE // Turn visible
		invisibility = initial(invisibility)
		visible = TRUE
	else // Currently visible
		density = FALSE // Turn invisible
		invisibility = INVISIBILITY_MAXIMUM
		visible = FALSE

	air_update_turf(1)
	return visible

/obj/machinery/shieldgen
	name = "emergency shield projector"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	density = TRUE
	opacity = FALSE
	anchored = FALSE
	pressure_resistance = 2*ONE_ATMOSPHERE
	req_access = list(ACCESS_ENGINE)
	var/const/max_health = 100
	var/health = max_health
	var/active = FALSE
	var/malfunction = FALSE //Malfunction causes parts of the shield to slowly dissapate
	var/list/deployed_shields = list()
	var/is_open = FALSE //Whether or not the wires are exposed
	var/locked = FALSE
	var/shield_range = 2

/obj/machinery/shieldgen/Destroy()
	QDEL_LIST_CONTENTS(deployed_shields)
	deployed_shields = null
	return ..()


/obj/machinery/shieldgen/proc/shields_up()
	if(active)
		return //If it's already turned on, how did this get called?

	active = TRUE
	update_icon(UPDATE_ICON_STATE)
	anchored = TRUE

	for(var/turf/target_tile in range(shield_range, src))
		if(isspaceturf(target_tile) && !(locate(/obj/machinery/shield) in target_tile))
			if(malfunction && prob(33) || !malfunction)
				var/obj/machinery/shield/new_shield = new(target_tile)
				RegisterSignal(new_shield, COMSIG_PARENT_QDELETING, PROC_REF(remove_shield)) // Ensures they properly GC
				deployed_shields += new_shield

/obj/machinery/shieldgen/proc/remove_shield(obj/machinery/shield/S)
	deployed_shields -= S

/obj/machinery/shieldgen/proc/shields_down()
	if(!active)
		return //If it's already off, how did this get called?

	active = FALSE
	update_icon(UPDATE_ICON_STATE)

	QDEL_LIST_CONTENTS(deployed_shields)

/obj/machinery/shieldgen/process()
	if(malfunction && active)
		if(length(deployed_shields) && prob(5))
			qdel(pick_n_take(deployed_shields))

/obj/machinery/shieldgen/proc/checkhp()
	if(health <= 30)
		malfunction = TRUE
	if(health <= 0)
		qdel(src)
	update_icon(UPDATE_ICON_STATE)
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
		update_icon(UPDATE_ICON_STATE)

	else if(istype(I, /obj/item/stack/cable_coil) && malfunction && is_open)
		var/obj/item/stack/cable_coil/coil = I
		to_chat(user, "<span class='notice'>You begin to replace the wires.</span>")
		if(do_after(user, 30 * coil.toolspeed, target = src))
			if(!src || !coil)
				return
			coil.use(1)
			health = max_health
			malfunction = FALSE
			playsound(loc, coil.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You repair [src]!</span>")
			update_icon(UPDATE_ICON_STATE)

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
	else
		if(isspaceturf(get_turf(src)))
			return //No wrenching these in space!
		WRENCH_ANCHOR_MESSAGE
	anchored = !anchored

/obj/machinery/shieldgen/update_icon_state()
	icon_state = "shield[active ? "on" : "off"][malfunction ? "br" : ""]"

/obj/machinery/shieldgen/raven
	name = "military shield generator"
	desc = "Military grade shield generators used to protect spaceships from incoming fire."
	shield_range = 4
	anchored = TRUE

////FIELD GEN START //shameless copypasta from fieldgen, powersink, and grille
#define MAX_STORED_POWER 500
/obj/machinery/shieldwallgen
	name = "Shield Generator"
	desc = "A shield generator."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "Shield_Gen"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_TELEPORTER)
	flags = CONDUCT
	power_state = NO_POWER_USE

	var/activated = FALSE
	var/locked = TRUE
	var/list/active_shields
	var/stored_power = 0

/obj/machinery/shieldwallgen/Initialize(mapload)
	. = ..()
	active_shields = list() // Doing it here since you can't cast numeral defines to strings using "[NORTH]" in the definition
	for(var/direction in GLOB.cardinal)
		active_shields["[direction]"] = list()
	if(!activated)
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/shieldwallgen/update_icon_state()
	icon_state = "Shield_Gen[activated ? " +a" : ""]"

/obj/machinery/shieldwallgen/proc/try_charge_shields_power()
	var/turf/T = loc

	var/obj/structure/cable/C = T.get_cable_node()
	var/datum/regional_powernet/PN = C?.powernet // find the powernet of the connected cable

	if(!PN)
		deactivate()
		return FALSE

	var/surplus = max(PN.available_power - PN.power_demand, 0)
	var/shieldload = min(rand(50, 200), surplus)
	if(!shieldload && stored_power <= 0)		// no cable or no power, and no power stored
		deactivate()
		return FALSE

	stored_power += min(shieldload, MAX_STORED_POWER - stored_power)
	PN.power_demand += shieldload //uses powernet power.
	return TRUE

/obj/machinery/shieldwallgen/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, "<span class='warning'>The shield generator needs to be firmly secured to the floor first.</span>")
		return TRUE
	if(locked && !issilicon(user))
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return TRUE
	var/turf/T = loc
	if(!T.get_cable_node())
		to_chat(user, "<span class='warning'>The shield generator needs to be powered by wire underneath.</span>")
		return TRUE

	if(!activated)
		activate()
	else
		deactivate()

	user.visible_message("<span class='notice'>[user] turned the shield generator [activated ? "on" : "off"].</span>", \
		"<span class='notice'>You turn [activated ? "on" : "off"] the shield generator.</span>", \
		"You hear heavy droning [activated ? "" : "fade out"].")

	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(user)

/obj/machinery/shieldwallgen/process()
	if(!try_charge_shields_power())
		visible_message("<span class='warning'>[name] shuts down due to lack of power!</span>", \
				"You hear heavy droning fade out")
		deactivate()
		update_icon(UPDATE_ICON_STATE)


/obj/machinery/shieldwallgen/proc/activate()
	activated = TRUE
	START_PROCESSING(SSmachines, src)
	for(var/direction in GLOB.cardinal)
		INVOKE_ASYNC(src, PROC_REF(try_link_generators), direction)

/obj/machinery/shieldwallgen/proc/try_link_generators(direction)
	var/turf/current_turf = loc
	var/obj/machinery/shieldwallgen/other_generator
	var/list/traveled_turfs = list()
	for(var/distance in 1 to 9)
		current_turf = get_step(current_turf, direction)
		if(iswallturf(current_turf)) // Should go through windows etc
			return
		other_generator = locate(/obj/machinery/shieldwallgen) in current_turf
		if(other_generator)
			break
		traveled_turfs += current_turf

	if(!other_generator?.activated)
		return

	sleep(rand(1, 4)) // TODO check if we want this behaviour

	var/opposite_direction = turn(direction, 180)
	for(var/T in traveled_turfs)
		var/obj/machinery/shieldwall/SW = new /obj/machinery/shieldwall(T, src, other_generator) //(ref to this gen, ref to connected gen)
		SW.dir = direction
		active_shields["[direction]"] += SW
		other_generator.active_shields["[opposite_direction]"] += SW

/obj/machinery/shieldwallgen/proc/deactivate()
	activated = FALSE
	STOP_PROCESSING(SSmachines, src)
	for(var/direction in GLOB.cardinal)
		var/list/L = active_shields["[direction]"]
		QDEL_LIST_CONTENTS(L) // Don't want to clean the assoc keys so no QDEL_LIST_ASSOC_VAL

/obj/machinery/shieldwallgen/proc/remove_active_shield(obj/machinery/shieldwall/SW, direction)
	var/list/L = active_shields["[direction]"]
	L -= SW

/obj/machinery/shieldwallgen/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id)||istype(I, /obj/item/pda))
		if(allowed(user))
			locked = !locked
			to_chat(user, "Controls are now [locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else
		add_fingerprint(user)
		..()

/obj/machinery/shieldwallgen/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(activated)
		to_chat(user, "<span class='warning'>Turn off the field generator first.</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	anchored = !anchored
	to_chat(user, anchored ? "You secure the external reinforcing bolts to the floor." : "You undo the external reinforcing bolts.")

/obj/machinery/shieldwallgen/Destroy()
	deactivate()
	return ..()

/obj/machinery/shieldwallgen/bullet_act(obj/item/projectile/Proj)
	stored_power -= Proj.damage
	..()
	return


////////////// Containment Field START
/obj/machinery/shieldwall
	name = "Shield"
	desc = "An energy shield."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldwall"
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 3
	var/needs_power = FALSE
	var/active = TRUE
	var/obj/machinery/shieldwallgen/gen_primary
	var/obj/machinery/shieldwallgen/gen_secondary

/obj/machinery/shieldwall/Initialize(mapload, obj/machinery/shieldwallgen/A, obj/machinery/shieldwallgen/B)
	. = ..()
	gen_primary = A
	gen_secondary = B
	if(A && B)
		needs_power = TRUE

/obj/machinery/shieldwall/Destroy()
	gen_primary?.remove_active_shield(src, dir)
	gen_secondary?.remove_active_shield(src, turn(dir, 180))
	gen_primary = null
	gen_secondary = null
	return ..()

/obj/machinery/shieldwall/attack_hand(mob/user)
	return

/obj/machinery/shieldwall/rpd_blocksusage()
	return TRUE

/obj/machinery/shieldwall/process()
	if(needs_power)
		if(prob(50))
			gen_primary.stored_power = max(gen_primary.stored_power - 10, 0)
		else
			gen_secondary.stored_power = max(gen_secondary.stored_power - 10, 0)


/obj/machinery/shieldwall/bullet_act(obj/item/projectile/Proj)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		if(prob(50))
			G = gen_primary
		else
			G = gen_secondary
		G.stored_power -= Proj.damage
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
				G.stored_power -= 200

			if(2.0) //medium boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.stored_power -= 50

			if(3.0) //lil boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.stored_power -= 20
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
			return TRUE
	if(istype(mover, /obj/item/projectile))
		return FALSE
	return ..(mover, target, height)

/obj/machinery/shieldwall/syndicate/CanPathfindPass(obj/item/card/id/ID, to_dir, caller, no_id = FALSE)
	if(isliving(caller))
		var/mob/living/M = caller
		if("syndicate" in M.faction)
			return TRUE
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

/obj/machinery/shieldwall/syndicate/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	phaseout()
	return ..()

#undef MAX_STORED_POWER

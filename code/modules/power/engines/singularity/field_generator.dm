/*
field_generator energy level display
 *   The icon used for the field_generator need to have 'num_energy_levels' number of icon states
 *   named 'Field_Gen +p[num]' where 'num' ranges from 1 to 'num_energy_levels'
 *   The energy level is displayed using overlays. The current displayed energy level is stored in 'energylevel'.
 *   The overlay in use and the energylevel variable must be kept in sync.  A energylevel equal to 0 means that
 *   no energy level overlay is currently in the overlays list.
 *   -Aygar
*/

#define FIELD_GENERATOR_MAX_ENERGY 125

#define FG_UNSECURED 0
#define FG_SECURED 1
#define FG_WELDED 2

#define FG_OFFLINE 0
#define FG_CHARGING 1
#define FG_ONLINE 2

/obj/machinery/field/generator
	name = "Field Generator"
	desc = "A large thermal battery that projects a high amount of energy when powered."
	icon = 'icons/obj/machines/field_generator.dmi'
	icon_state = "Field_Gen"
	density = TRUE
	power_state = NO_POWER_USE
	max_integrity = 500
	//100% immune to lasers and energy projectiles since it absorbs their energy.
	armor = list(MELEE = 25, BULLET = 10, LASER = 100, ENERGY = 100, BOMB = 0, RAD = 0, FIRE = 50, ACID = 70)
	var/const/num_energy_levels = 6	// Total number of power level icon has
	var/energy_level = 0
	var/active = FG_OFFLINE
	var/energy = 20  // Current amount of energy
	var/state = FG_UNSECURED
	var/warming_up = 0
	var/list/obj/machinery/field/containment/fields
	var/list/obj/machinery/field/generator/connected_gens
	var/clean_up = FALSE

/obj/machinery/field/generator/update_overlays()
	. = ..()
	if(warming_up)
		. += "+a[warming_up]"
	if(length(fields))
		. += "+on"
	if(energy_level)
		. += "+p[energy_level]"

/obj/machinery/field/generator/Initialize(mapload)
	. = ..()
	fields = list()
	connected_gens = list()


/obj/machinery/field/generator/process()
	if(active == FG_ONLINE)
		calc_energy()

/**
 * Gets a list of generators that form a field that is enclosing a given singularity, if such a field exists.
 *
 * Arguments:
 * * _dir - The direction in which we are currently going
 * * singulo - The singularity we are looking to contain
 * * containment_gens - A list of generators which is the portion of the potential result we have so far.
 */
/obj/machinery/field/generator/proc/find_containment_gens(_dir, obj/singularity/singulo, list/containment_gens = list())
	// We can't go in a direction that doesn't exist
	if(!dir)
		return list()

	containment_gens |= src
	// This is used to evaluate a path before returning it. We don't want to stop after the first dead end.
	var/list/temp_gens = list()

	for(var/obj/machinery/field/generator/gen in connected_gens)
		// We don't ever want to do anything with the generator behind us so this check comes first
		if(get_dir(src, gen) == turn(_dir, 180))
			continue
		// If we completed a full circle and it contains the singularity return it. Otherwise continue
		if(gen in containment_gens)
			if(singulo.in_containment(containment_gens))
				return containment_gens
			continue

		// Go right if we can, forward if we can't go right, and left if we can't go forward
		if(get_dir(src, gen) == turn(_dir, -90))
			temp_gens = gen.find_containment_gens(turn(_dir, -90), singulo, containment_gens)
			if(length(temp_gens))
				return temp_gens
		if(get_dir(src, gen) == _dir)
			temp_gens = gen.find_containment_gens(_dir, singulo, containment_gens)
			if(length(temp_gens))
				return temp_gens
		if(get_dir(src, gen) == turn(_dir, 90))
			temp_gens = gen.find_containment_gens(turn(_dir, 90), singulo, containment_gens)
			if(length(temp_gens))
				return temp_gens

	// We got to a dead end, temp_gens should be empty here.
	return temp_gens

/obj/machinery/field/generator/attack_hand(mob/user)
	if(state == FG_WELDED)
		if(get_dist(src, user) <= 1)//Need to actually touch the thing to turn it on
			if(active >= FG_CHARGING)
				to_chat(user, "<span class='warning'>You are unable to turn off [src] once it is online!</span>")
				return 1
			else
				user.visible_message("[user] turns on [src].", \
					"<span class='notice'>You turn on [src].</span>", \
					"<span class='italics'>You hear heavy droning.</span>")
				turn_on()
				investigate_log("<font color='green'>activated</font> by [user.key].", INVESTIGATE_SINGULO)

				add_fingerprint(user)
	else
		to_chat(user, "<span class='warning'>[src] needs to be firmly secured to the floor first!</span>")

/obj/machinery/field/generator/wrench_act(mob/living/user, obj/item/W)
	. = TRUE
	if(active)
		to_chat(user, "<span class='warning'>[src] needs to be off!</span>")
		return
	switch(state)
		if(FG_UNSECURED)
			if(isinspace()) return
			state = FG_SECURED
			W.play_tool_sound(W, 75)
			user.visible_message("[user.name] secures [name] to the floor.", \
				"<span class='notice'>You secure the external reinforcing bolts to the floor.</span>", \
				"<span class='italics'>You hear ratchet.</span>")
			anchored = TRUE
		if(FG_SECURED)
			state = FG_UNSECURED
			W.play_tool_sound(W, 75)
			user.visible_message("[user.name] unsecures [name] reinforcing bolts from the floor.", \
				"<span class='notice'>You undo the external reinforcing bolts.</span>", \
				"<span class='italics'>You hear ratchet.</span>")
			anchored = FALSE
		if(FG_WELDED)
			to_chat(user, "<span class='warning'>[src] needs to be unwelded from the floor!</span>")

/obj/machinery/field/generator/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(state == FG_UNSECURED)
		to_chat(user, "<span class='warning'>[src] needs to be wrenched to the floor!</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	if(state == FG_SECURED)
		WELDER_ATTEMPT_FLOOR_WELD_MESSAGE
	else if(state == FG_WELDED)
		WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		if(state == FG_SECURED)
			WELDER_FLOOR_WELD_SUCCESS_MESSAGE
			state = FG_WELDED
		else if(state == FG_WELDED)
			WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
			state = FG_SECURED

/obj/machinery/field/generator/emp_act()
	return 0

/obj/machinery/field/generator/attack_animal(mob/living/simple_animal/M)
	if(M.environment_smash & ENVIRONMENT_SMASH_RWALLS && active == FG_OFFLINE && state != FG_UNSECURED)
		state = FG_UNSECURED
		anchored = FALSE
		M.visible_message("<span class='warning'>[M] rips [src] free from its moorings!</span>")
	else
		..()
	if(!anchored)
		step(src, get_dir(M, src))

/obj/machinery/field/generator/blob_act(obj/structure/blob/B)
	if(active)
		return 0
	else
		..()

/obj/machinery/field/generator/bullet_act(obj/item/projectile/Proj)
	if(Proj.flag != BULLET && !Proj.nodamage)
		energy = min(energy + Proj.damage, FIELD_GENERATOR_MAX_ENERGY)
		check_energy_level()
	return 0


/obj/machinery/field/generator/Destroy()
	cleanup()
	return ..()


/obj/machinery/field/generator/proc/check_energy_level()
	var/new_level = round(num_energy_levels * energy / FIELD_GENERATOR_MAX_ENERGY)
	if(new_level != energy_level)
		energy_level = new_level
		update_icon()

/obj/machinery/field/generator/proc/turn_off()
	active = FG_OFFLINE
	spawn(1)
		cleanup()
		while(warming_up > 0 && !active)
			sleep(50)
			warming_up--
			update_icon()

/obj/machinery/field/generator/proc/turn_on()
	active = FG_CHARGING
	spawn(1)
		while(warming_up < 3 && active)
			sleep(50)
			warming_up++
			update_icon()
			if(warming_up >= 3)
				start_fields()


/obj/machinery/field/generator/proc/calc_energy()
	var/power_draw = 2 + length(fields)

	if(draw_power(round(power_draw / 2, 1)))
		spread_energy()
		check_energy_level()
		return TRUE
	else
		visible_message("<span class='danger'>[src] shuts down!</span>", "<span class='italics'>You hear something shutting down.</span>")
		turn_off()
		investigate_log("ran out of energy and <font color='red'>deactivated</font>",INVESTIGATE_SINGULO)
		energy = 0
		check_energy_level()
		return FALSE

/**
* Draws power. If there isn't enough energy to sustain the draw, draw from connected generators, up to 3 generators away.
* We never do a 180, so at most we should be going around 270 degrees, and never loop.
*
* Arguments:
** draw - Amount of energy needed to sustain powerdraw during this cycle
** failsafe - Current depth of the recursion. We don't let this go above 3.
** last - should be src of the previous call, we check against this to prevent going back and forth between two field generators.
*/
/obj/machinery/field/generator/proc/draw_power(draw = 0, failsafe = 0, obj/machinery/field/generator/last = null)
	if(failsafe >= 3)// Asking at most 3 gens away so we can't loop.
		return 0
	else
		failsafe++

	if(energy >= draw)// We have enough energy
		energy -= draw
		return 1

	else//Need more energy
		draw -= energy
		energy = 0
		for(var/CG in connected_gens)
			var/obj/machinery/field/generator/FG = CG
			if(FG == last)// We just asked you
				continue
			else// We are askin another for energy
				if(FG.draw_power(draw, failsafe, src))
					return 1
				else
					return 0

/// Sends energy to every neighbour that has less energy
/obj/machinery/field/generator/proc/spread_energy()
	for(var/obj/machinery/field/generator/gen as anything in connected_gens)
		if(energy > gen.energy + 3)
			var/diff = min(energy - gen.energy, FIELD_GENERATOR_MAX_ENERGY - gen.energy)// We don't want to delete energy
			gen.energy += diff / 2
			energy -= diff / 2

/obj/machinery/field/generator/proc/start_fields()
	if(state != FG_WELDED || !anchored)
		turn_off()
		return
	spawn(1)
		setup_field(1)
	spawn(2)
		setup_field(2)
	spawn(3)
		setup_field(4)
	spawn(4)
		setup_field(8)
	spawn(5)
		active = FG_ONLINE


/obj/machinery/field/generator/proc/setup_field(NSEW)
	var/turf/T = loc
	if(!istype(T))
		return 0

	var/obj/machinery/field/generator/G = null
	var/steps = 0
	if(!NSEW)//Make sure its ran right
		return 0
	for(var/dist in 0 to 7) // checks out to 8 tiles away for another generator
		T = get_step(T, NSEW)
		if(T.density)//We cant shoot a field though this
			return 0

		G = locate(/obj/machinery/field/generator) in T
		if(G)
			steps -= 1
			if(!G.active)
				return 0
			break

		for(var/TC in T.contents)
			var/atom/A = TC
			if(ismob(A))
				continue
			if(A.density)
				return 0

		steps++

	if(!G)
		return 0

	T = loc
	for(var/dist in 0 to steps) // creates each field tile
		var/field_dir = get_dir(T, get_step(G.loc, NSEW))
		T = get_step(T, NSEW)
		if(!locate(/obj/machinery/field/containment) in T)
			var/obj/machinery/field/containment/CF = new/obj/machinery/field/containment()
			CF.set_master(src, G)
			CF.loc = T
			CF.dir = field_dir
			fields += CF
			G.fields += CF
			for(var/mob/living/L in T)
				CF.Crossed(L, null)

	connected_gens |= G
	G.connected_gens |= src
	update_icon()


/obj/machinery/field/generator/proc/cleanup()
	clean_up = TRUE
	for(var/F in fields)
		qdel(F)

	for(var/CG in connected_gens)
		var/obj/machinery/field/generator/FG = CG
		FG.connected_gens -= src
		if(!FG.clean_up)//Makes the other gens clean up and shutdown as well
			FG.turn_off()
		connected_gens -= FG
	clean_up = FALSE
	update_icon()

	//This is here to help fight the "hurr durr, release singulo cos nobody will notice before the
	//singulo eats the evidence". It's not fool-proof but better than nothing.
	//I want to avoid using global variables.
	INVOKE_ASYNC(src, PROC_REF(admin_alert))

/obj/machinery/field/generator/proc/admin_alert()
	var/temp = TRUE //stops spam
	for(var/thing in GLOB.singularities)
		var/obj/singularity/O = thing
		if(O.last_warning && temp && atoms_share_level(O, src))
			if((world.time - O.last_warning) > 50) //to stop message-spam
				temp = FALSE
				// To the person who asks "Hey affected, why are you using this massive operator when you can use AREACOORD?" Well, ill tell you
				// get_area_name is fucking broken and uses a for(x in world) search
				// It doesnt even work, is expensive, and returns 0
				// Im not refactoring one thing which could risk breaking all admin location logs
				// Fight me
				// [src ? "[get_location_name(src, TRUE)] [COORD(src)]" : "nonexistent location"] [ADMIN_JMP(src)] works much better and actually works at all
				// Oh and yes, this exact comment was pasted from the exact same thing I did to tcomms code. Dont at me.
				message_admins("A singularity exists and a containment field has failed on the same Z-Level. Singulo location: [O ? "[get_location_name(O, TRUE)] [COORD(O)]" : "nonexistent location"] [ADMIN_JMP(O)] | Field generator location: [src ? "[get_location_name(src, TRUE)] [COORD(src)]" : "nonexistent location"] [ADMIN_JMP(src)]")
				investigate_log("has <font color='red'>failed</font> whilst a singulo exists.", INVESTIGATE_SINGULO)
		O.last_warning = world.time

/obj/machinery/field/generator/shock_field(mob/living/user)
	if(length(fields))
		..()

/obj/machinery/field/generator/bump_field(atom/movable/AM as mob|obj)
	if(length(fields))
		..()

#undef FG_UNSECURED
#undef FG_SECURED
#undef FG_WELDED

#undef FG_OFFLINE
#undef FG_CHARGING
#undef FG_ONLINE

#undef FIELD_GENERATOR_MAX_ENERGY

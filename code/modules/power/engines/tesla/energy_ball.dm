#define TESLA_DEFAULT_POWER 1738260
#define TESLA_MINI_POWER 869130
//Zap constants, speeds up targeting
#define COIL (ROD + 1)
#define ROD (APC + 1)
#define APC (RIDE + 1)
#define RIDE (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (BLOB + 1)
#define BLOB (STRUCTURE + 1)
#define STRUCTURE (1)

/// The Tesla engine
/obj/singularity/energy_ball
	name = "energy ball"
	desc = "An energy ball."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	current_size = STAGE_TWO
	move_self = TRUE
	grav_pull = 0
	density = TRUE
	energy = 0
	dissipate = FALSE
	dissipate_delay = 5
	dissipate_strength = 1
	warps_projectiles = FALSE
	var/list/orbiting_balls = list()
	var/miniball = FALSE
	var/produced_power
	var/energy_to_raise = 32
	var/energy_to_lower = -20
	var/obj/singularity/energy_ball/parent_energy_ball
	/// Turf where the tesla will move to if it's loose
	var/turf/target_turf
	/// Direction we have to go to go towards the target turf
	var/movement_dir
	/// Variable that defines whether it has a field generator close enough
	var/has_close_field = FALSE
	/// Init list that has all the areas that we can possibly move to, to reduce processing impact
	var/list/all_possible_areas = list()

/obj/singularity/energy_ball/Initialize(mapload, starting_energy = 50, is_miniball = FALSE)
	miniball = is_miniball
	RegisterSignal(src, COMSIG_ATOM_ORBIT_BEGIN, PROC_REF(on_start_orbit))
	RegisterSignal(src, COMSIG_ATOM_ORBIT_STOP, PROC_REF(on_stop_orbit))
	RegisterSignal(parent_energy_ball, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_delete))
	. = ..()
	if(!is_miniball)
		set_light(10, 7, "#5e5edd")
	else
		// This gets added by the parent call
		GLOB.poi_list -= src
	all_possible_areas = findUnrestrictedEventArea()

/obj/singularity/energy_ball/ex_act(severity, target)
	return

/obj/singularity/energy_ball/consume(severity, target)
	return

/obj/singularity/energy_ball/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_ORBIT_BEGIN)
	UnregisterSignal(src, COMSIG_ATOM_ORBIT_STOP)
	if(parent_energy_ball && !QDELETED(parent_energy_ball))
		UnregisterSignal(parent_energy_ball, COMSIG_PARENT_QDELETING)
		parent_energy_ball.on_stop_orbit(src, TRUE)
		parent_energy_ball.orbiting_balls -= src
		parent_energy_ball = null

	if(!miniball)
		GLOB.poi_list -= src

	QDEL_LIST_CONTENTS(orbiting_balls)
	return ..()

/obj/singularity/energy_ball/admin_investigate_setup()
	if(miniball)
		return //don't annnounce miniballs
	..()

/obj/singularity/energy_ball/process()
	if(!parent_energy_ball)
		handle_energy()
		move_the_basket_ball()

		playsound(loc, 'sound/magic/lightningbolt.ogg', 100, TRUE, extrarange = 30, channel = CHANNEL_ENGINE)

		pixel_x = 0
		pixel_y = 0
		var/list/shocking_info = list()
		tesla_zap(src, 3, TESLA_DEFAULT_POWER, shocked_targets = shocking_info)

		pixel_x = -32
		pixel_y = -32
		for(var/ball in orbiting_balls)
			var/range = rand(1, clamp(length(orbiting_balls), 2, 3))
			//We zap off the main ball instead of ourselves to make things looks proper
			tesla_zap(src, range, TESLA_MINI_POWER / 7 * range)
	else
		energy = 0 // ensure we dont have miniballs of miniballs //But it'll be cool broooooooooooooooo

/obj/singularity/energy_ball/examine(mob/user)
	. = ..()
	if(length(orbiting_balls))
		. += "There are [length(orbiting_balls)] mini-balls orbiting it."

/obj/singularity/energy_ball/proc/move_the_basket_ball()
	for(var/i in 1 to length(GLOB.field_generator_fields))
		var/temp_distance = get_dist(src, GLOB.field_generator_fields[i])
		if(temp_distance <= 15)
			has_close_field = TRUE
			break
	if(has_close_field)
		var/turf/T = get_step(src, pick(GLOB.alldirs))
		if(can_move(T))
			forceMove(T)
			has_close_field = FALSE
			for(var/mob/living/carbon/C in loc)
				dust_mobs(C)
		return
	if(!target_turf)
		find_the_basket()
		return
	for(var/i in 0 to 8)
		movement_dir = get_dir(get_turf(src), target_turf)
		forceMove(get_step(src, movement_dir))
		if(get_turf(src) == target_turf)
			target_turf = null
		for(var/mob/living/carbon/C in loc)
			dust_mobs(C)
		has_close_field = FALSE


/obj/singularity/energy_ball/proc/find_the_basket()
	var/area/where_to_move = pick(all_possible_areas) // Grabs a random area that isn't restricted
	var/turf/target_area_turfs = get_area_turfs(where_to_move) // Grabs the turfs from said area
	target_turf = pick(target_area_turfs) // Grabs a single turf from the entire list
	return


/obj/singularity/energy_ball/proc/handle_energy()
	if(energy >= energy_to_raise)
		energy_to_lower = energy_to_raise - 20
		energy_to_raise = energy_to_raise * 1.25

		playsound(src.loc, 'sound/magic/lightning_chargeup.ogg', 100, TRUE, extrarange = 30, channel = CHANNEL_ENGINE)
		addtimer(CALLBACK(src, PROC_REF(new_mini_ball)), 100)

	else if(energy < energy_to_lower && length(orbiting_balls))
		energy_to_raise = energy_to_raise / 1.25
		energy_to_lower = (energy_to_raise / 1.25) - 20

		var/Orchiectomy_target = pick(orbiting_balls)
		qdel(Orchiectomy_target)

	else if(length(orbiting_balls))
		do_dissipate() //sing code has a much better system.

/obj/singularity/energy_ball/proc/new_mini_ball()
	if(!loc)
		return
	var/obj/singularity/energy_ball/EB = new(loc, 0, TRUE)

	EB.transform *= pick(0.3, 0.4, 0.5, 0.6, 0.7)
	var/icon/I = icon(icon,icon_state,dir)

	var/orbitsize = (I.Width() + I.Height()) * pick(0.4, 0.5, 0.6, 0.7, 0.8)
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)

	EB.parent_energy_ball = src
	EB.orbit(src, orbitsize, pick(FALSE, TRUE), rand(10, 25), pick(3, 4, 5, 6, 36), orbit_layer = EB.layer)

/obj/singularity/energy_ball/Bump(atom/A)
	dust_mobs(A)

/obj/singularity/energy_ball/Bumped(atom/movable/AM)
	dust_mobs(AM)

/obj/singularity/energy_ball/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	investigate_log("has consumed the brain of [key_name(C)] after being touched with telekinesis", "singulo")
	C.visible_message("<span class='danger'>[C] suddenly slumps over.</span>", \
		"<span class='userdanger'>As you mentally focus on the energy ball you feel the contents of your skull become overcharged. That was shockingly stupid.</span>")
	var/obj/item/organ/internal/brain/B = C.get_int_organ(/obj/item/organ/internal/brain)
	C.ghostize(0)
	if(B)
		B.remove(C)
		qdel(B)

/// When we get orbited, add the orbiter to our tracked balls
/obj/singularity/energy_ball/proc/on_start_orbit(atom/movable/this, atom/orbiter)
	SIGNAL_HANDLER	// COMSIG_ATOM_ORBIT_BEGIN

	if(istype(orbiter, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/ball = orbiter
		orbiting_balls += ball
		dissipate_strength = length(orbiting_balls)

/obj/singularity/energy_ball/proc/on_stop_orbit(atom/movable/this, atom/orbiter)
	SIGNAL_HANDLER	// COMSIG_ATOM_ORBIT_END

	if(istype(orbiter, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/ball = orbiter
		orbiting_balls -= ball
		dissipate_strength = length(orbiting_balls)
		ball.parent_energy_ball = null

		if(!loc || !QDELETED(ball))
			qdel(ball)

/obj/singularity/energy_ball/proc/on_parent_delete(obj/singularity/energy_ball/target)
	SIGNAL_HANDLER

	parent_energy_ball = null

/obj/singularity/energy_ball/proc/dust_mobs(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.incorporeal_move || L.status_flags & GODMODE)
			return
	if(!iscarbon(A))
		return
	for(var/obj/machinery/power/grounding_rod/GR in orange(src, 2))
		if(GR.anchored)
			return
	var/mob/living/carbon/C = A
	C.dust()

/proc/tesla_zap(atom/source, zap_range = 3, power, zap_flags = ZAP_DEFAULT_FLAGS, list/shocked_targets = list())
	if(QDELETED(source))
		return
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(shocked_targets, source, TRUE) //I don't want no null refs in my list yeah?
	. = source.dir
	if(power < 1000)
		return

	/*
	THIS IS SO FUCKING UGLY AND I HATE IT, but I can't make it nice without making it slower, check*N rather then n. So we're stuck with it.
	*/
	var/atom/closest_atom
	var/closest_type = 0
	var/static/things_to_shock = typecacheof(list(/obj/machinery, /mob/living, /obj/structure, /obj/vehicle))
	var/static/blacklisted_tesla_types = typecacheof(list(/obj/machinery/atmospherics,
										/obj/machinery/atmospherics/portable,
										/obj/machinery/power/emitter,
										/obj/machinery/field/generator,
										/mob/living/simple_animal/slime,
										/obj/machinery/particle_accelerator/control_box,
										/obj/structure/particle_accelerator/fuel_chamber,
										/obj/structure/particle_accelerator/particle_emitter/center,
										/obj/structure/particle_accelerator/particle_emitter/left,
										/obj/structure/particle_accelerator/particle_emitter/right,
										/obj/structure/particle_accelerator/power_box,
										/obj/structure/particle_accelerator/end_cap,
										/obj/machinery/field/containment,
										/obj/structure/disposalpipe,
										/obj/structure/disposaloutlet,
										/obj/machinery/disposal/deliveryChute,
										/obj/machinery/camera,
										/obj/structure/sign,
										/obj/structure/lattice,
										/obj/structure/grille,
										/obj/structure/cable,
										/obj/machinery/the_singularitygen/tesla,
										/obj/machinery/constructable_frame/machine_frame))

	//Ok so we are making an assumption here. We assume that view() still calculates from the center out.
	//This means that if we find an object we can assume it is the closest one of its type. This is somewhat of a speed increase.
	//This also means we have no need to track distance, as the doview() proc does it all for us.

	//Darkness fucks oview up hard. I've tried dview() but it doesn't seem to work
	//I hate existance // Range() lets us see through walls, please direct all screaming players to me - DGL
	for(var/a in typecache_filter_multi_list_exclusion(range(zap_range + 2, source), things_to_shock, blacklisted_tesla_types))
		var/atom/A = a
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, A))
			continue
		if(closest_type >= COIL)
			continue //no need checking these other things

		else if(istype(A, /obj/machinery/power/tesla_coil))
			var/obj/machinery/power/tesla_coil/C = A
			if(!C.being_shocked)
				closest_type = COIL
				closest_atom = C

		else if(closest_type >= ROD)
			continue

		else if(istype(A, /obj/machinery/power/grounding_rod))
			closest_type = ROD
			closest_atom = A

		else if(istype(A, /obj/machinery/power/apc))
			closest_type = APC
			closest_atom = A

		else if(closest_type >= RIDE)
			continue

		else if(istype(A, /obj/vehicle))
			var/obj/vehicle/R = A
			if(R.can_buckle && !R.being_shocked)
				closest_type = RIDE
				closest_atom = A

		else if(closest_type >= LIVING)
			continue

		else if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD && !(HAS_TRAIT(L, TRAIT_TESLA_SHOCKIMMUNE)) && !(L.flags_2 & SHOCKED_2))
				closest_type = LIVING
				closest_atom = A

		else if(closest_type >= MACHINERY)
			continue

		else if(ismachinery(A))
			var/obj/machinery/M = A
			if(!M.being_shocked)
				closest_type = MACHINERY
				closest_atom = A

		else if(closest_type >= BLOB)
			continue

		else if(istype(A, /obj/structure/blob))
			var/obj/structure/blob/B = A
			if(!B.being_shocked)
				closest_type = BLOB
				closest_atom = A

		else if(closest_type >= STRUCTURE)
			continue

		else if(isstructure(A))
			var/obj/structure/S = A
			if(!S.being_shocked)
				closest_type = STRUCTURE
				closest_atom = A

	//Alright, we've done our loop, now lets see if was anything interesting in range
	if(!closest_atom)
		return
	//common stuff
	source.Beam(closest_atom, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5, maxdistance = INFINITY)
	var/zapdir = get_dir(source, closest_atom)
	if(zapdir)
		. = zapdir

	var/next_range = 2
	if(closest_type == COIL)
		next_range = 5

	if(closest_type == LIVING)
		var/mob/living/closest_mob = closest_atom
		closest_mob.set_shocked()
		addtimer(CALLBACK(closest_mob, TYPE_PROC_REF(/mob/living, reset_shocked)), 10)
		var/shock_damage = (zap_flags & ZAP_MOB_DAMAGE) ? (min(round(power / 600), 90) + rand(-5, 5)) : 0
		closest_mob.electrocute_act(shock_damage, source, 1, SHOCK_TESLA | ((zap_flags & ZAP_MOB_STUN) ? NONE : SHOCK_NOSTUN))
		if(issilicon(closest_mob))
			var/mob/living/silicon/S = closest_mob
			if((zap_flags & ZAP_MOB_STUN) && (zap_flags & ZAP_MOB_DAMAGE))
				S.emp_act(EMP_LIGHT)
			next_range = 7 // metallic folks bounce it further
		else
			next_range = 5
		power /= 1.5

	else
		power = closest_atom.zap_act(power, zap_flags)
	if(prob(20)) //I know I know
		var/list/shocked_copy = shocked_targets.Copy()
		tesla_zap(closest_atom, next_range, power * 0.5, zap_flags, shocked_copy) //Normally I'd copy here so grounding rods work properly, but it fucks with movement
		tesla_zap(closest_atom, next_range, power * 0.5, zap_flags, shocked_targets)
		shocked_targets += shocked_copy
	else
		tesla_zap(closest_atom, next_range, power, zap_flags)

#undef COIL
#undef ROD
#undef APC
#undef RIDE
#undef LIVING
#undef MACHINERY
#undef BLOB
#undef STRUCTURE

/*
Alright so, this is a file that has the proc for a proc that works like 90% of all zaps.
basic_tesla_zap() can be called by anything and does not need any overrides.
*/

//Zap constants, speeds up targeting
#define COIL (ROD + 1)
#define ROD (RIDE + 1)
#define RIDE (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (BLOB + 1)
#define BLOB (STRUCTURE + 1)
#define STRUCTURE (1)


// If you want a normal zap, you use the proc below

/proc/basic_tesla_zap(atom/source, zap_range = 3, power, zap_flags = ZAP_DEFAULT_FLAGS, list/shocked_targets = list(), target_APC = FALSE)
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

	for(var/a in typecache_filter_multi_list_exclusion(oview(zap_range + 2, source), things_to_shock, blacklisted_tesla_types))
		get_a_target(source, zap_range, power, zap_flags, shocked_targets, target_APC, closest_atom)

/proc/get_a_target(atom/source, zap_range = 3, power, zap_flags = ZAP_DEFAULT_FLAGS, list/shocked_targets = list(), target_APC = FALSE, closest_atom)
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
		basic_tesla_zap(closest_atom, next_range, power * 0.5, zap_flags, shocked_copy) //Normally I'd copy here so grounding rods work properly, but it fucks with movement
		basic_tesla_zap(closest_atom, next_range, power * 0.5, zap_flags, shocked_targets)
		shocked_targets += shocked_copy
	else
		basic_tesla_zap(closest_atom, next_range, power, zap_flags)

#undef COIL
#undef ROD
#undef RIDE
#undef LIVING
#undef MACHINERY
#undef BLOB
#undef STRUCTURE

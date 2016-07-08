#define TESLA_DEFAULT_POWER 1738260
#define TESLA_MINI_POWER 869130

var/list/blacklisted_tesla_types = list(/obj/machinery/atmospherics,
										/obj/machinery/power/emitter,
										/obj/machinery/field/generator,
										/mob/living/simple_animal,
										/obj/machinery/particle_accelerator/control_box,
										/obj/structure/particle_accelerator/fuel_chamber,
										/obj/structure/particle_accelerator/particle_emitter/center,
										/obj/structure/particle_accelerator/particle_emitter/left,
										/obj/structure/particle_accelerator/particle_emitter/right,
										/obj/structure/particle_accelerator/power_box,
										/obj/structure/particle_accelerator/end_cap,
										/obj/machinery/field/containment,
										/obj/structure/disposalpipe,
										/obj/structure/sign,
										/obj/machinery/gateway)

/obj/singularity/energy_ball
	name = "energy ball"
	desc = "An energy ball."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	current_size = STAGE_TWO
	move_self = 1
	grav_pull = 0
	contained = 0
	density = 1
	energy = 0
	var/list/orbiting_balls = list()
	var/produced_power
	var/energy_to_raise = 32
	var/energy_to_lower = -20

/obj/singularity/energy_ball/Destroy()
	if(orbiting && istype(orbiting, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/EB = orbiting
		EB.orbiting_balls -= src
		orbiting = null

	for(var/ball in orbiting_balls)
		var/obj/singularity/energy_ball/EB = ball
		qdel(EB)

	return ..()

/obj/singularity/energy_ball/process()
	if(!orbiting)
		handle_energy()

		move_the_basket_ball(4 + orbiting_balls.len * 2)

		playsound(src.loc, 'sound/magic/lightningbolt.ogg', 100, 1, extrarange = 30)

		pixel_x = 0
		pixel_y = 0

		dir = tesla_zap(src, 7, TESLA_DEFAULT_POWER)

		pixel_x = -32
		pixel_y = -32
		for(var/ball in orbiting_balls)
			tesla_zap(ball, rand(1, Clamp(orbiting_balls.len, 3, 7)), TESLA_MINI_POWER)
	else
		energy = 0 // ensure we dont have miniballs of miniballs

	return

/obj/singularity/energy_ball/examine(mob/user)
	..()
	if(orbiting_balls.len)
		to_chat(user, "The amount of orbiting mini-balls is [orbiting_balls.len].")


/obj/singularity/energy_ball/proc/move_the_basket_ball(var/move_amount)
	//we face the last thing we zapped, so this lets us favor that direction a bit
	var/first_move = dir
	for(var/i in 0 to move_amount)
		var/move_dir = pick(alldirs + first_move) //give the first move direction a bit of favoring.
		if(target && prob(60))
			move_dir = get_dir(src,target)
		var/turf/T = get_step(src, move_dir)
		if(can_move(T))
			loc = T


/obj/singularity/energy_ball/proc/handle_energy()
	if(energy >= energy_to_raise)
		energy_to_lower = energy_to_raise - 20
		energy_to_raise = energy_to_raise * 1.5

		playsound(src.loc, 'sound/magic/lightning_chargeup.ogg', 100, 1, extrarange = 30)
		spawn(100)
			if(!loc)
				return
			var/obj/singularity/energy_ball/EB = new(loc)

			EB.transform *= pick(0.3, 0.4, 0.5, 0.6, 0.7)
			var/icon/I = icon(icon,icon_state,dir)

			var/orbitsize = (I.Width() + I.Height()) * pick(0.4, 0.5, 0.6, 0.7, 0.8)
			orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)

			EB.orbit(src, orbitsize, pick(FALSE, TRUE), rand(10, 25), pick(3, 4, 5, 6, 36))

	else if(energy < energy_to_lower && orbiting_balls.len)
		energy_to_raise = energy_to_raise / 1.5
		energy_to_lower = (energy_to_raise / 1.5) - 20

		var/Orchiectomy_target = pick(orbiting_balls)
		qdel(Orchiectomy_target)

	else if(orbiting_balls.len)
		energy -= orbiting_balls.len * 0.5

/obj/singularity/energy_ball/Bump(atom/A)
	dust_mobs(A)

/obj/singularity/energy_ball/Bumped(atom/A)
	dust_mobs(A)

/obj/singularity/energy_ball/orbit(obj/singularity/energy_ball/target)
	if(istype(target))
		target.orbiting_balls += src

	. = ..()

	if(istype(target))
		target.orbiting_balls -= src
	if(!loc)
		qdel(src)

/obj/singularity/energy_ball/proc/dust_mobs(atom/A)
	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		C.dust()
	return

/proc/tesla_zap(var/atom/source, zap_range = 3, power)
	. = source.dir
	if(power < 1000)
		return

	var/closest_dist = 0
	var/closest_atom
	var/obj/machinery/power/tesla_coil/closest_tesla_coil
	var/obj/machinery/power/grounding_rod/closest_grounding_rod
	var/mob/living/closest_mob
	var/obj/machinery/closest_machine
	var/obj/structure/closest_structure

	for(var/A in oview(source, zap_range))
		if(istype(A, /obj/machinery/power/tesla_coil))
			var/dist = get_dist(source, A)
			var/obj/machinery/power/tesla_coil/C = A
			if((dist < closest_dist || !closest_tesla_coil) && !C.being_shocked)
				closest_dist = dist

				//we use both of these to save on istype and typecasting overhead later on
				//while still allowing common code to run before hand
				closest_tesla_coil = C
				closest_atom = C


		else if(closest_tesla_coil)
			continue //no need checking these other things

		else if(istype(A, /obj/machinery/power/grounding_rod))
			var/dist = get_dist(source, A)
			if(dist < closest_dist || !closest_grounding_rod)
				closest_grounding_rod = A
				closest_atom = A
				closest_dist = dist

		else if(closest_grounding_rod || is_type_in_list(A, blacklisted_tesla_types))
			continue

		else if(istype(A, /mob/living))
			var/dist = get_dist(source, A)
			var/mob/living/L = A
			if((dist < closest_dist || !closest_mob) && L.stat != DEAD)
				closest_mob = L
				closest_atom = A
				closest_dist = dist

		else if(closest_mob)
			continue

		else if(istype(A, /obj/machinery))
			var/obj/machinery/M = A
			var/dist = get_dist(source, A)
			if((dist < closest_dist || !closest_machine) && !M.being_shocked)
				closest_machine = M
				closest_atom = A
				closest_dist = dist

		else if(closest_mob)
			continue

		else if(istype(A, /obj/structure))
			var/obj/structure/S = A
			var/dist = get_dist(source, A)
			if((dist < closest_dist || !closest_tesla_coil) && !S.being_shocked)
				closest_structure = S
				closest_atom = A
				closest_dist = dist

	//Alright, we've done our loop, now lets see if was anything interesting in range
	if(closest_atom)
		//common stuff
		source.Beam(closest_atom, icon_state="lightning[rand(1,12)]", icon='icons/effects/effects.dmi', time=5)
		var/zapdir = get_dir(source, closest_atom)
		if(zapdir)
			. = zapdir

	//per type stuff:
	if(closest_tesla_coil)
		closest_tesla_coil.tesla_act(power)

	else if(closest_grounding_rod)
		closest_grounding_rod.tesla_act(power)

	else if(closest_mob)
		var/shock_damage = Clamp(round(power/400), 10, 90) + rand(-5, 5)
		closest_mob.electrocute_act(shock_damage, source, 1, tesla_shock = 1)
		if(istype(closest_mob, /mob/living/silicon))
			var/mob/living/silicon/S = closest_mob
			S.emp_act(2)
			tesla_zap(S, 7, power / 1.5) // metallic folks bounce it further
		else
			tesla_zap(closest_mob, 5, power / 1.5)

	else if(closest_machine)
		closest_machine.tesla_act(power)

	else if(closest_structure)
		closest_structure.tesla_act(power)
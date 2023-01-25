/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/chem_smoke
	icon = 'icons/goonstation/effects/64x64.dmi'
	icon_state = "smoke"
	density = FALSE
	opacity = FALSE
	layer = ABOVE_MOB_LAYER
	animate_movement = NO_STEPS
	var/matrix/first = matrix()
	var/matrix/second = matrix()
	var/matrix/third = matrix()
	var/first_scale = 0.1
	var/second_scale = 5
	var/third_scale = 2
	var/spread_amount = 96

/obj/effect/particle_effect/chem_smoke/New(location, chem_color)
	..(location)
	color = chem_color
	pixel_x += -16 + rand(-3, 3)
	pixel_y += -16 + rand(-3, 3)

	first = turn(first, rand(-90, 90))
	first.Scale(first_scale, first_scale)
	transform = first

	second = first
	second.Scale(second_scale, second_scale)

	third.Scale(third_scale, third_scale)

	animate(src,transform = second, time = 5, alpha = 200)
	animate(transform = third, time = 20, pixel_y = rand(-spread_amount, spread_amount), pixel_x = rand(-spread_amount, spread_amount), alpha = 1)
	QDEL_IN(src, 26)


/obj/effect/particle_effect/chem_smoke/small
	first_scale = 0.05
	second_scale = 2.5
	third_scale = 1
	spread_amount = 48


/datum/effect_system/smoke_spread/chem
	var/obj/chemholder
	var/list/smoked_atoms = list()

/datum/effect_system/smoke_spread/chem/New()
	..()
	chemholder = new
	chemholder.create_reagents(1000)
	chemholder.reagents.set_reacting(FALSE) // Just in case

/datum/effect_system/smoke_spread/chem/Destroy()
	QDEL_NULL(chemholder)
	smoked_atoms.Cut()
	return ..()

/datum/effect_system/smoke_spread/chem/set_up(datum/reagents/carry = null, loca, silent = FALSE)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	carry.copy_to(chemholder, carry.total_volume)
	carry.clear_reagents()
	if(!silent)
		var/contained = ""
		for(var/reagent in carry.reagent_list)
			contained += " [reagent] "
		if(contained)
			contained = "\[[contained]\]"
		var/area/A = get_area(location)

		var/where = "[A.name] | [location.x], [location.y]"
		var/whereLink = "<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>[where]</a>"

		if(carry && carry.my_atom)
			if(carry.my_atom.fingerprintslast)
				var/mob/M = get_mob_by_key(carry.my_atom.fingerprintslast)
				var/more = ""
				if(M)
					more = " "
				add_attack_logs(M, location, "Caused a chemical smoke reaction containing [contained]. Last associated key is [carry.my_atom.fingerprintslast][more]", ATKLOG_FEW)
			else
				add_attack_logs(carry.my_atom, "A chemical smoke reaction has taken place in ([whereLink])[contained]. No associated key.", ATKLOG_FEW)
		else
			add_attack_logs(carry, "A chemical smoke reaction has taken place in ([whereLink])[contained]. No associated key. CODERS: carry.my_atom may be null.", ATKLOG_FEW)


/datum/effect_system/smoke_spread/chem/start(effect_range = 2)
	set waitfor = FALSE

	var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)

	if(!effect_range)
		INVOKE_ASYNC(src, .proc/SmokeEm, effect_range, chemholder.reagents, 1)
		for(var/x in 0 to 9)
			for(var/i = 0, i < rand(2, 6), i++)
				new /obj/effect/particle_effect/chem_smoke/small(location, color)
			sleep(1)
	else
		var/obj/tile_reagents = new
		tile_reagents.create_reagents(1000)
		tile_reagents.reagents.set_reacting(FALSE) // Just in case
		for(var/x in 0 to (effect_range * 10 - 1))
			for(var/i = 0, i < rand(2, 6), i++)
				if(x < 20)
					new /obj/effect/particle_effect/chem_smoke/small(location, color)
				else
					new /obj/effect/particle_effect/chem_smoke(location, color)

			if(x % 10 == 0) //Once every 10 ticks.
				var/range = x / 10 + 1
				tile_reagents.reagents.clear_reagents()
				var/square_size = range * 2 + 1
				chemholder.reagents.copy_to(tile_reagents, chemholder.reagents.total_volume, 1 / (square_size * square_size) / effect_range)
				INVOKE_ASYNC(src, .proc/SmokeEm, range, tile_reagents.reagents)

			sleep(1)
	qdel(src)

/datum/effect_system/smoke_spread/chem/proc/SmokeEm(effect_range, var/datum/reagents/reagents)
	for(var/turf/T in view(effect_range, get_turf(location)))
		var/list/mob/living/carbon/carbons = list()
		for(var/atom/A in T.contents)
			if(istype(A, /obj/effect/particle_effect)) // Don't impact particle effects, as there can be hundreds of them in a small area. Also, we don't want smoke particles adding themselves to this list. Major performance issue.
				continue
			if(A in smoked_atoms)
				continue
			smoked_atoms += A
			reagents.reaction(A)
			if(iscarbon(A))
				var/mob/living/carbon/C = A
				if(C.can_breathe_gas())
					carbons += C
		for(var/mob/living/carbon/C in carbons)
			reagents.copy_to(C, reagents.total_volume, 1 / carbons.len)

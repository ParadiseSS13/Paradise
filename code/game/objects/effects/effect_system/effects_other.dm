/////////////////////////////////////////////
//////// Attach a trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/datum/effect_system/trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

/datum/effect_system/trail_follow/set_up(atom/atom)
	attach(atom)
	oldposition = get_turf(atom)

/datum/effect_system/trail_follow/Destroy()
	oldposition = null
	return ..()

/datum/effect_system/trail_follow/proc/stop()
	processing = 0
	on = 0
	oldposition = null

/datum/effect_system/trail_follow/steam
	effect_type = /obj/effect/particle_effect/steam

/datum/effect_system/trail_follow/steam/start() //Whoever is responsible for this abomination of code should become an hero
	if(!on)
		on = 1
		processing = 1
		if(!oldposition)
			oldposition = get_turf(holder)
	if(processing)
		processing = 0
		if(number < 3)
			var/obj/effect/particle_effect/steam/I = new effect_type(oldposition)
			number++
			I.dir = holder.dir
			oldposition = get_turf(holder)
			spawn(10)
				qdel(I)
				number--
		spawn(2)
			if(on)
				processing = 1
				start()

/obj/effect/particle_effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = 1

/datum/effect_system/trail_follow/ion
	effect_type = /obj/effect/particle_effect/ion_trails

/datum/effect_system/trail_follow/ion/start() //Whoever is responsible for this abomination of code should become an hero
	if(!on)
		on = 1
		processing = 1
	if(processing)
		processing = 0
		var/turf/T = get_turf(src.holder)
		if(T != oldposition)
			if(!has_gravity(T))
				var/obj/effect/particle_effect/ion_trails/I = new effect_type(oldposition)
				I.dir = holder.dir
				flick("ion_fade", I)
				I.icon_state = ""
				spawn(20)
					qdel(I)
			oldposition = T
		spawn(2)
			if(on)
				processing = 1
				start()

/datum/effect_system/trail_follow/ion/space_trail
	var/turf/oldloc // secondary ion trail loc
	var/turf/currloc

/datum/effect_system/trail_follow/ion/space_trail/Destroy()
	oldloc = null
	currloc = null
	return ..()

/datum/effect_system/trail_follow/ion/space_trail/start()
	if(!on)
		on = 1
		processing = 1
	if(processing)
		processing = 0
		spawn(0)
			var/turf/T = get_turf(src.holder)
			if(currloc != T)
				switch(holder.dir)
					if(NORTH)
						src.oldposition = T
						src.oldposition = get_step(oldposition, SOUTH)
						src.oldloc = get_step(oldposition,EAST)
						//src.oldloc = get_step(oldloc, SOUTH)
					if(SOUTH) // More difficult, offset to the north!
						src.oldposition = get_step(holder,NORTH)
						src.oldposition = get_step(oldposition,NORTH)
						src.oldloc = get_step(oldposition,EAST)
						//src.oldloc = get_step(oldloc,NORTH)
					if(EAST) // Just one to the north should suffice
						src.oldposition = T
						src.oldposition = get_step(oldposition, WEST)
						src.oldloc = get_step(oldposition,NORTH)
						//src.oldloc = get_step(oldloc,WEST)
					if(WEST) // One to the east and north from there
						src.oldposition = get_step(holder,EAST)
						src.oldposition = get_step(oldposition,EAST)
						src.oldloc = get_step(oldposition,NORTH)
						//src.oldloc = get_step(oldloc,EAST)
				if(istype(T, /turf/space))
					var/obj/effect/particle_effect/ion_trails/I = new effect_type(oldposition)
					var/obj/effect/particle_effect/ion_trails/II = new effect_type(oldloc)
					//src.oldposition = T
					I.dir = holder.dir
					II.dir = holder.dir
					flick("ion_fade", I)
					flick("ion_fade", II)
					I.icon_state = ""
					II.icon_state = ""
					spawn(20)
						if(I)
							qdel(I)
						if(II)
							qdel(II)
			spawn(2)
				if(on)
					processing = 1
					start()
			currloc = T

//Reagent-based explosion effect
/datum/effect_system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion

/datum/effect_system/reagents_explosion/set_up(amt, loca, flash = 0, flash_fact = 0)
	amount = amt
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

	flashing = flash
	flashing_factor = flash_fact


/datum/effect_system/reagents_explosion/start()
	if(amount <= 2)
		do_sparks(2, 1, location)

		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution violently explodes.</span>")
		for(var/mob/M in viewers(1, location))
			if(prob(50 * amount))
				to_chat(M, "<span class='warning'>The explosion knocks you down.</span>")
				M.Weaken(rand(1,5))
		return
	else
		var/devastation = -1
		var/heavy = -1
		var/light = -1
		var/flash = -1

		// Clamp all values to MAX_EXPLOSION_RANGE
		if(round(amount/12) > 0)
			devastation = min (MAX_EX_DEVASTATION_RANGE, devastation + round(amount/12))

		if(round(amount/6) > 0)
			heavy = min (MAX_EX_HEAVY_RANGE, heavy + round(amount/6))

		if(round(amount/3) > 0)
			light = min (MAX_EX_LIGHT_RANGE, light + round(amount/3))

		if(flashing && flashing_factor)
			flash += (round(amount/4) * flashing_factor)

		for(var/mob/M in viewers(8, location))
			to_chat(M, "<span class='warning'>The solution violently explodes.</span>")

		explosion(location, devastation, heavy, light, flash)

/datum/effect_system/reagents_explosion/proc/holder_damage(atom/holder)
	if(holder)
		var/dmglevel = 4

		if(round(amount/8) > 0)
			dmglevel = 1
		else if(round(amount/4) > 0)
			dmglevel = 2
		else if(round(amount/2) > 0)
			dmglevel = 3

		if(dmglevel<4)
			holder.ex_act(dmglevel)

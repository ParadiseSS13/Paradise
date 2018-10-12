/datum/event/undead
	var/spawn_prob = 10
	startWhen = 2
	announceWhen = 3

/datum/event/undead/start()
	var/datum/event/electrical_storm/RS = new
	RS.lightsoutAmount = pick(2,2,3)
	RS.start()
	RS.kill()
	for(var/area/A)
		if(!is_station_level(A.z)) continue //Spook on main station only.
		if(A.luminosity) continue
//			if(A.lighting_space) continue
		if(A.type == /area) continue
		var/list/turflist = list()
		for(var/turf/T in A)
			if(istype(T,/turf/space) || T.density) continue
			if(locate(/mob/living) in T) continue
			var/okay = 1
			for(var/obj/O in T)
				if(O.density)
					okay = 0
					break
			if(okay)
				turflist += T

		if(!turflist.len) continue
		var/turfs = round(turflist.len * spawn_prob/100,1)
		while(turfs > 0 && turflist.len) // safety
			turfs--
			var/turf/T = pick_n_take(turflist)
			var/undeadtype = pick(/mob/living/simple_animal/hostile/retaliate/skeleton,
								80;/mob/living/simple_animal/hostile/retaliate/zombie,
								60;/mob/living/simple_animal/hostile/retaliate/ghost)
			new undeadtype(T)

/datum/event/undead/announce()
	for(var/mob/living/M in GLOB.player_list)
		to_chat(M, "You feel [pick("a chill","a deathly chill","the undead","dirty", "creeped out","afraid","fear")]!")

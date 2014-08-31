/**********************Mineral deposits**************************/

/turf/simulated/mineral //wall piece
	name = "Rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	oxygen = 0
	nitrogen = 0
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = T0C
	var/mineral/mineral
	var/mined_ore = 0
	var/last_act = 0

	var/datum/geosample/geologic_data
	var/excavation_level = 0
	var/list/finds
	var/next_rock = 0
	var/archaeo_overlay = ""
	var/excav_overlay = ""
	var/obj/item/weapon/last_find
	var/datum/artifact_find/artifact_find
	var/scan_state = null

	has_resources = 1

	New()
		. = ..()

		MineralSpread()

		spawn(1)
			var/turf/T
			if((istype(get_step(src, NORTH), /turf/simulated/floor)) || (istype(get_step(src, NORTH), /turf/space)) || (istype(get_step(src, NORTH), /turf/simulated/shuttle/floor)))
				T = get_step(src, NORTH)
				if (T)
					T.overlays += image('icons/turf/walls.dmi', "rock_side_s", layer=2)
			if((istype(get_step(src, SOUTH), /turf/simulated/floor)) || (istype(get_step(src, SOUTH), /turf/space)) || (istype(get_step(src, SOUTH), /turf/simulated/shuttle/floor)))
				T = get_step(src, SOUTH)
				if (T)
					T.overlays += image('icons/turf/walls.dmi', "rock_side_n", layer=2)
			if((istype(get_step(src, EAST), /turf/simulated/floor)) || (istype(get_step(src, EAST), /turf/space)) || (istype(get_step(src, EAST), /turf/simulated/shuttle/floor)))
				T = get_step(src, EAST)
				if (T)
					T.overlays += image('icons/turf/walls.dmi', "rock_side_w", layer=2)
			if((istype(get_step(src, WEST), /turf/simulated/floor)) || (istype(get_step(src, WEST), /turf/space)) || (istype(get_step(src, WEST), /turf/simulated/shuttle/floor)))
				T = get_step(src, WEST)
				if (T)
					T.overlays += image('icons/turf/walls.dmi', "rock_side_e", layer=2)


	ex_act(severity)
		switch(severity)
			if(2.0)
				if (prob(70))
					mined_ore = 1 //some of the stuff gets blown up
					GetDrilled()
			if(1.0)
				mined_ore = 2 //some of the stuff gets blown up
				GetDrilled()


	Bumped(AM)
		. = ..()
		if(istype(AM,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = AM
			if((istype(H.l_hand,/obj/item/weapon/pickaxe)) && (!H.hand))
				attackby(H.l_hand,H)
			else if((istype(H.r_hand,/obj/item/weapon/pickaxe)) && H.hand)
				attackby(H.r_hand,H)

		else if(istype(AM,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = AM
			if(istype(R.module_active,/obj/item/weapon/pickaxe))
				attackby(R.module_active,R)

		else if(istype(AM,/obj/mecha))
			var/obj/mecha/M = AM
			if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
				M.selected.action(src)


	proc/MineralSpread()
		if(mineral && mineral.spread)
			for(var/trydir in cardinal)
				if(prob(mineral.spread_chance))
					var/turf/simulated/mineral/random/target_turf = get_step(src, trydir)
					if(istype(target_turf) && !target_turf.mineral)
						target_turf.mineral = mineral
						target_turf.UpdateMineral()
						target_turf.MineralSpread()


	proc/UpdateMineral()
		if(!mineral)
			name = "\improper Rock"
			icon_state = "rock"
			return
		name = "\improper [mineral.display_name] deposit"
		icon_state = "rock_[mineral.name][rand(1,3)]"
		scan_state = "rock_[mineral.name][rand(1,3)]"

	//Not even going to touch this pile of spaghetti
	attackby(obj/item/weapon/W as obj, mob/user as mob)

		if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
			usr << "\red You don't have the dexterity to do this!"
			return

		if (istype(W, /obj/item/device/core_sampler))
			geologic_data.UpdateNearbyArtifactInfo(src)
			var/obj/item/device/core_sampler/C = W
			C.sample_item(src, user)
			return

		if (istype(W, /obj/item/device/depth_scanner))
			var/obj/item/device/depth_scanner/C = W
			C.scan_atom(user, src)
			return

		if (istype(W, /obj/item/device/measuring_tape))
			var/obj/item/device/measuring_tape/P = W
			user.visible_message("\blue[user] extends [P] towards [src].","\blue You extend [P] towards [src].")
			if(do_after(user,25))
				user << "\blue \icon[P] [src] has been excavated to a depth of [2*excavation_level]cm."
			return

		if (istype(W, /obj/item/weapon/pickaxe))
			var/turf/T = user.loc
			if (!( istype(T, /turf) ))
				return

			var/obj/item/weapon/pickaxe/P = W
			if(last_act + P.digspeed > world.time)//prevents message spam
				return
			last_act = world.time

			playsound(user, P.drill_sound, 20, 1)

			//handle any archaeological finds we might uncover
			var/fail_message
			if(finds && finds.len)
				var/datum/find/F = finds[1]
				if(excavation_level + P.excavation_amount > F.excavation_required)
					//Chance to destroy / extract any finds here
					fail_message = ", <b>[pick("there is a crunching noise","[W] collides with some different rock","part of the rock face crumbles away","something breaks under [W]")]</b>"

			user << "\red You start [P.drill_verb][fail_message ? fail_message : ""]."

			if(fail_message && prob(90))
				if(prob(25))
					excavate_find(5, finds[1])
				else if(prob(50))
					finds.Remove(finds[1])
					if(prob(50))
						artifact_debris()

			if(do_after(user,P.digspeed))
				user << "\blue You finish [P.drill_verb] the rock."

				if(finds && finds.len)
					var/datum/find/F = finds[1]
					if(round(excavation_level + P.excavation_amount) == F.excavation_required)
						//Chance to extract any items here perfectly, otherwise just pull them out along with the rock surrounding them
						if(excavation_level + P.excavation_amount > F.excavation_required)
							//if you can get slightly over, perfect extraction
							excavate_find(100, F)
						else
							excavate_find(80, F)

					else if(excavation_level + P.excavation_amount > F.excavation_required - F.clearance_range)
						//just pull the surrounding rock out
						excavate_find(0, F)

				if( excavation_level + P.excavation_amount >= 100 )
					//if players have been excavating this turf, leave some rocky debris behind
					var/obj/structure/boulder/B
					if(artifact_find)
						if( excavation_level > 0 || prob(15) )
							//boulder with an artifact inside
							B = new(src)
							if(artifact_find)
								B.artifact_find = artifact_find
						else
							artifact_debris(1)
					else if(prob(15))
						//empty boulder
						B = new(src)

					if(B)
						GetDrilled(0)
					else
						GetDrilled(1)
					return

				excavation_level += P.excavation_amount

				//archaeo overlays
				if(!archaeo_overlay && finds && finds.len)
					var/datum/find/F = finds[1]
					if(F.excavation_required <= excavation_level + F.view_range)
						archaeo_overlay = "overlay_archaeo[rand(1,3)]"
						overlays += archaeo_overlay

				//there's got to be a better way to do this
				var/update_excav_overlay = 0
				if(excavation_level >= 75)
					if(excavation_level - P.excavation_amount < 75)
						update_excav_overlay = 1
				else if(excavation_level >= 50)
					if(excavation_level - P.excavation_amount < 50)
						update_excav_overlay = 1
				else if(excavation_level >= 25)
					if(excavation_level - P.excavation_amount < 25)
						update_excav_overlay = 1

				//update overlays displaying excavation level
				if( !(excav_overlay && excavation_level > 0) || update_excav_overlay )
					var/excav_quadrant = round(excavation_level / 25) + 1
					excav_overlay = "overlay_excv[excav_quadrant]_[rand(1,3)]"
					overlays += excav_overlay

				/* Nope.
				//extract pesky minerals while we're excavating
				while(excavation_minerals.len && excavation_level > excavation_minerals[excavation_minerals.len])
					DropMineral()
					pop(excavation_minerals)
					mineralAmt-- */

				//drop some rocks
				next_rock += P.excavation_amount * 10
				while(next_rock > 100)
					next_rock -= 100
					var/obj/item/weapon/ore/O = new(src)
					geologic_data.UpdateNearbyArtifactInfo(src)
					O.geologic_data = geologic_data

		else
			return attack_hand(user)


	proc/DropMineral()
		if(!mineral)
			return

		var/obj/item/weapon/ore/O = new mineral.ore (src)
		if(istype(O))
			geologic_data.UpdateNearbyArtifactInfo(src)
			O.geologic_data = geologic_data
		return O


	proc/GetDrilled(var/artifact_fail = 0)
		//var/destroyed = 0 //used for breaking strange rocks
		if (mineral && mineral.result_amount)

			//if the turf has already been excavated, some of it's ore has been removed
			for (var/i = 1 to mineral.result_amount - mined_ore)
				DropMineral()

		//destroyed artifacts have weird, unpleasant effects
		//make sure to destroy them before changing the turf though
		if(artifact_find && artifact_fail)
			var/pain = 0
			if(prob(50))
				pain = 1
			for(var/mob/living/M in range(src, 200))
				M << "<font color='red'><b>[pick("A high pitched [pick("keening","wailing","whistle")]","A rumbling noise like [pick("thunder","heavy machinery")]")] somehow penetrates your mind before fading away!</b></font>"
				if(pain)
					flick("pain",M.pain)
					if(prob(50))
						M.adjustBruteLoss(5)
				else
					flick("flash",M.flash)
					if(prob(50))
						M.Stun(5)
				M.apply_effect(25, IRRADIATE)

		var/turf/simulated/floor/plating/airless/asteroid/N = ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
		N.fullUpdateMineralOverlays()

		if(rand(1,750) == 1)
			visible_message("<span class='notice'>An old dusty crate was buried within!</span>")
			new /obj/structure/closet/crate/secure/loot(src)


	proc/excavate_find(var/prob_clean = 0, var/datum/find/F)
		//with skill and luck, players can cleanly extract finds
		//otherwise, they come out inside a chunk of rock
		var/obj/item/weapon/X
		if(prob_clean)
			X = new /obj/item/weapon/archaeological_find(src, new_item_type = F.find_type)
		else
			X = new /obj/item/weapon/ore/strangerock(src, inside_item_type = F.find_type)
			geologic_data.UpdateNearbyArtifactInfo(src)
			X:geologic_data = geologic_data

		//some find types delete the /obj/item/weapon/archaeological_find and replace it with something else, this handles when that happens
		//yuck
		var/display_name = "something"
		if(!X)
			X = last_find
		if(X)
			display_name = X.name

		//many finds are ancient and thus very delicate - luckily there is a specialised energy suspension field which protects them when they're being extracted
		if(prob(F.prob_delicate))
			var/obj/effect/suspension_field/S = locate() in src
			if(!S || S.field_type != get_responsive_reagent(F.find_type))
				if(X)
					visible_message("\red<b>[pick("[display_name] crumbles away into dust","[display_name] breaks apart")].</b>")
					del(X)

		finds.Remove(F)


	proc/artifact_debris(var/severity = 0)
		//cael's patented random limited drop componentized loot system!
		//sky's patented not-fucking-retarded overhaul!

		//Give a random amount of loot from 1 to 3 or 5, varying on severity.
		for(var/j in 1 to rand(1, 3 + max(min(severity, 1), 0) * 2))
			switch(rand(1,7))
				if(1)
					var/obj/item/stack/rods/R = new(src)
					R.amount = rand(5,25)

				if(2)
					var/obj/item/stack/tile/R = new(src)
					R.amount = rand(1,5)

				if(3)
					var/obj/item/stack/sheet/metal/R = new(src)
					R.amount = rand(5,25)

				if(4)
					var/obj/item/stack/sheet/plasteel/R = new(src)
					R.amount = rand(5,25)

				if(5)
					var/quantity = rand(1,3)
					for(var/i=0, i<quantity, i++)
						getFromPool(/obj/item/weapon/shard, loc)

				if(6)
					var/quantity = rand(1,3)
					for(var/i=0, i<quantity, i++)
						getFromPool(/obj/item/weapon/shard/plasma, loc)

				if(7)
					var/obj/item/stack/sheet/mineral/uranium/R = new(src)
					R.amount = rand(5,25)


/turf/simulated/mineral/random
	name = "Mineral deposit"
	var/mineralSpawnChanceList = list("Uranium" = 5, "Coal" = 50, "Iron" = 50, "Diamond" = 1, "Gold" = 5, "Silver" = 5, "Platinum" = 5, "Hydrogen" = 5, "Plasma" = 25, "Cave" = 1)//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 10  //means 10% chance of this plot changing to a mineral deposit

	New()
		if (prob(mineralChance) && !mineral)
			var/mineral_name = pickweight(mineralSpawnChanceList) //temp mineral name

			if(!name_to_mineral)
				SetupMinerals()

			if (mineral_name && mineral_name in name_to_mineral)
				mineral = name_to_mineral[mineral_name]
				UpdateMineral()

		. = ..()


/turf/simulated/mineral/random/high_chance
	mineralChance = 25
	mineralSpawnChanceList = list("Uranium" = 10, "Coal" = 30, "Iron" = 30, "Diamond" = 2, "Gold" = 10, "Silver" = 10, "Platinum" = 10, "Hydrogen" = 10, "Plasma" = 25)


/turf/simulated/mineral/random/high_chance_clown
	mineralChance = 40
	mineralSpawnChanceList = list("Uranium" = 10, "Coal" = 30, "Iron" = 30, "Diamond" = 2, "Gold" = 5, "Silver" = 5, "Platinum" = 5, "Hydrogen" = 5, "Plasma" = 25, "Clown" = 15)

/**********************Asteroid**************************/


/turf/simulated/floor/plating/airless/asteroid //floor piece
	name = "Asteroid"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = T0C
	icon_plating = "asteroid"
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug
	has_resources = 1

/turf/simulated/floor/plating/airless/asteroid/New()
	var/proper_name = name
	..()
	name = proper_name
	//if (prob(50))
	//	seedName = pick(list("1","2","3","4"))
	//	seedAmt = rand(1,4)
	if(prob(20))
		icon_state = "asteroid[rand(0,12)]"
	spawn(2)
		updateMineralOverlays()

/turf/simulated/floor/plating/airless/asteroid/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				gets_dug()
		if(1.0)
			gets_dug()
	return

/turf/simulated/floor/plating/airless/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(!W || !user)
		return 0

	if ((istype(W, /obj/item/weapon/shovel)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(loc, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(40)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "\blue You dug a hole."
			gets_dug()

	if ((istype(W,/obj/item/weapon/pickaxe/drill)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(loc, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(30)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "\blue You dug a hole."
			gets_dug()

	if ((istype(W,/obj/item/weapon/pickaxe/diamonddrill)) || (istype(W,/obj/item/weapon/pickaxe/borgdrill)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(loc, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(0)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "\blue You dug a hole."
			gets_dug()

	if(istype(W,/obj/item/weapon/storage/bag/ore))
		var/obj/item/weapon/storage/bag/ore/S = W
		if(S.collection_mode)
			for(var/obj/item/weapon/ore/O in contents)
				O.attackby(W,user)
				return
	else if(istype(W,/obj/item/weapon/storage/bag/fossils))
		var/obj/item/weapon/storage/bag/fossils/S = W
		if(S.collection_mode)
			for(var/obj/item/weapon/fossil/F in contents)
				F.attackby(W,user)
				return

	else
		..(W,user)
	return

/turf/simulated/floor/plating/airless/asteroid/proc/gets_dug()
	if(dug)
		return
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	dug = 1
	icon_plating = "asteroid_dug"
	icon_state = "asteroid_dug"
	return

/turf/simulated/floor/plating/airless/asteroid/proc/updateMineralOverlays()

	overlays.Cut()

	if(istype(get_step(src, NORTH), /turf/simulated/mineral))
		overlays += image('icons/turf/walls.dmi', "rock_side_n")
	if(istype(get_step(src, SOUTH), /turf/simulated/mineral))
		overlays += image('icons/turf/walls.dmi', "rock_side_s", layer=6)
	if(istype(get_step(src, EAST), /turf/simulated/mineral))
		overlays += image('icons/turf/walls.dmi', "rock_side_e", layer=6)
	if(istype(get_step(src, WEST), /turf/simulated/mineral))
		overlays += image('icons/turf/walls.dmi', "rock_side_w", layer=6)

/turf/simulated/floor/plating/airless/asteroid/proc/fullUpdateMineralOverlays()
	var/turf/simulated/floor/plating/airless/asteroid/A
	if(istype(get_step(src, WEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, WEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, EAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, EAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTH), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTH)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHWEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHEAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHWEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHEAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTH), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTH)
		A.updateMineralOverlays()
	updateMineralOverlays()



/turf/simulated/floor/plating/airless/asteroid/Entered(atom/movable/M as mob|obj)
	..()
	if(istype(M,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		if(istype(R.module, /obj/item/weapon/robot_module/miner))
			if(istype(R.module_state_1,/obj/item/weapon/storage/bag/ore))
				attackby(R.module_state_1,R)
			else if(istype(R.module_state_2,/obj/item/weapon/storage/bag/ore))
				attackby(R.module_state_2,R)
			else if(istype(R.module_state_3,/obj/item/weapon/storage/bag/ore))
				attackby(R.module_state_3,R)
			else
				return

/turf/simulated/floor/plating/airless/asteroid/cave
	var/length = 100
	var/mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath  = 5,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 1,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 3,
		/mob/living/simple_animal/hostile/asteroid/hivelord = 5
	)
	var/sanity = 1

/turf/simulated/floor/plating/airless/asteroid/cave/New(loc, var/length, var/go_backwards = 1, var/exclude_dir = -1)

	// If length (arg2) isn't defined, get a random length; otherwise assign our length to the length arg.
	if(!length)
		src.length = rand(25, 50)
	else
		src.length = length

	// Get our directiosn
	var/forward_cave_dir = pick(alldirs - exclude_dir)
	// Get the opposite direction of our facing direction
	var/backward_cave_dir = angle2dir(dir2angle(forward_cave_dir) + 180)

	// Make our tunnels
	make_tunnel(forward_cave_dir)
	if(go_backwards)
		make_tunnel(backward_cave_dir)
	// Kill ourselves by replacing ourselves with a normal floor.
	SpawnFloor(src)
	..()

/turf/simulated/floor/plating/airless/asteroid/cave/proc/make_tunnel(var/dir)

	var/turf/simulated/mineral/tunnel = src
	var/next_angle = pick(45, -45)

	for(var/i = 0; i < length; i++)
		if(!sanity)
			break

		var/list/L = list(45)
		if(IsOdd(dir2angle(dir))) // We're going at an angle and we want thick angled tunnels.
			L += -45

		// Expand the edges of our tunnel
		for(var/edge_angle in L)
			var/turf/simulated/mineral/edge = get_step(tunnel, angle2dir(dir2angle(dir) + edge_angle))
			if(istype(edge))
				SpawnFloor(edge)

		// Move our tunnel forward
		tunnel = get_step(tunnel, dir)

		if(istype(tunnel))
			// Small chance to have forks in our tunnel; otherwise dig our tunnel.
			if(i > 3 && prob(20))
				new src.type(tunnel, rand(10, 15), 0, dir)
			else
				SpawnFloor(tunnel)
		else //if(!istype(tunnel, src.parent)) // We hit space/normal/wall, stop our tunnel.
			break

		// Chance to change our direction left or right.
		if(i > 2 && prob(33))
			// We can't go a full loop though
			next_angle = -next_angle
			dir = angle2dir(dir2angle(dir) + next_angle)


/turf/simulated/floor/plating/airless/asteroid/cave/proc/SpawnFloor(var/turf/T)
	for(var/turf/S in range(2,T))
		if(istype(S, /turf/space) || istype(S.loc, /area/mine/explored))
			sanity = 0
			break
	if(!sanity)
		return

	SpawnMonster(T)


/turf/simulated/floor/plating/airless/asteroid/cave/proc/SpawnMonster(var/turf/T)
	if(prob(2))
		if(istype(loc, /area/mine/explored))
			return
		for(var/atom/A in range(7,T))//Lowers chance of mob clumps
			if(istype(A, /mob/living/simple_animal/hostile/asteroid))
				return
		var/randumb = pickweight(mob_spawn_list)
		new randumb(T)
	return

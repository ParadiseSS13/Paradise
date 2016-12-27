
// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: TARGETING CODE -----------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/ListTargets()
	var/list/targets1 = list()
	var/list/targets2 = list()
	var/list/targets3 = list()
	if(ai_type == TS_AI_AGGRESSIVE)
		// default, BE AGGRESSIVE
		//var/list/Mobs = hearers(vision_range, src) - src // this is how ListTargets for /mob/living/simple_animal/hostile/ does it, but it is wrong, it ignores NPCs.
		for(var/mob/living/H in view(src, vision_range))
		//for(var/mob/H in Mobs)
			if(H.stat == 2)
				continue
			else if(H.flags & GODMODE)
				continue
			else if(!stat_attack && H.stat == UNCONSCIOUS)
				continue
			else if(istype(H, /mob/living/simple_animal/hostile/poison/terror_spider))
				if(H in enemies)
					targets3 += H
				continue
			else if(H.reagents)
				if(H.paralysis && H.reagents.has_reagent("terror_white_tranq"))
					// let's not target completely paralysed mobs.
					if(H in enemies)
						targets3 += H
						// unless we hate their guts
				if(istype(H, /mob/living/carbon))
					var/mob/living/carbon/C = H
					if(IsInfected(C)) // target them if they attack us
						if(C in enemies)
							targets3 += C
							continue
				if(H.reagents.has_reagent("terror_black_toxin",30))
					if(get_dist(src,H) <= 2)
						// if they come to us...
						targets2 += H
					else if((H in enemies) && !H.reagents.has_reagent("terror_black_toxin",31))
						// if we're aggressive, and they're not going to die quickly...
						targets2 += H
				else
					if(ai_target_method == TS_DAMAGE_BRUTE)
						var/theirarmor = H.getarmor(type = "melee")
						// Example values: Civilian: 2, Engineer w/ Hardsuit: 10, Sec Officer with armor: 19, HoS: 48, Deathsquad: 80
						if(theirarmor < 10)
							targets1 += H
						else if(H in enemies)
							if(theirarmor < 30)
								targets2 += H
							else
								targets3 += H
						else
							targets3 += H
					else if(ai_target_method == TS_DAMAGE_POISON)
						if(H.can_inject(null,0,"chest",0))
							targets1 += H
						else if(H in enemies)
							targets2 += H
						else
							targets3 += H
					else
						// TS_DAMAGE_SIMPLE
						if(H in enemies)
							targets2 += H
						else
							targets3 += H
			else if(istype(H, /mob/living/simple_animal))
				var/mob/living/simple_animal/hostile/poison/terror_spider/M = H
				if(M.force_threshold > melee_damage_upper)
					// If it has such high armor it can ignore any attack we make on it, ignore it.
				else if(M in enemies)
					targets2 += M
				else
					targets3 += M
			else
				if(H in enemies)
					targets2 += H
				else
					targets3 += H
		if(health < maxHealth)
			// very unlikely that we're being shot at by a mech or space pod - so only check for this if our health is lower than max.
			for(var/obj/mecha/M in view(src, vision_range))
				if(get_dist(M, src) <= 2)
					targets2 += M
				else
					targets3 += M
			for(var/obj/spacepod/S in view(src, vision_range))
				targets3 += S
		if(targets1.len)
			return targets1
		else if(targets2.len)
			return targets2
		else
			return targets3
	else if(ai_type == TS_AI_DEFENSIVE)
		for(var/mob/living/H in view(src, vision_range))
			if(H.stat == DEAD)
				// dead mobs are ALWAYS ignored.
			else if(!stat_attack && H.stat == UNCONSCIOUS)
				// unconscious mobs are ignored unless spider has stat_attack
			else if(H in enemies)
				targets1 += H
		if(health < maxHealth)
			// very unlikely that we're being shot at by a mech or space pod - so only check for this if our health is lower than max.
			for(var/obj/mecha/M in view(src, vision_range))
				if(M in enemies)
					targets1 += M
			for(var/obj/spacepod/S in view(src, vision_range))
				if(S in enemies)
					targets1 += S
		return targets1
	else if(ai_type == TS_AI_PASSIVE)
		return list()

/mob/living/simple_animal/hostile/poison/terror_spider/LoseTarget()
	if(target && isliving(target))
		var/mob/living/T = target
		if(T.stat > 0)
			killcount++
			regen_points += regen_points_per_kill
	attackstep = 0
	attackcycles = 0
	..()

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: AI BEHAVIOR CODE -------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/handle_automated_action()
	if(!stat && !ckey) // if we are not dead, and we're not player controlled
		if(AIStatus != AI_OFF && !target)
			var/my_ventcrawl_freq = freq_ventcrawl_idle
			if(ts_count_dead > 0)
				if(world.time < (ts_death_last + ts_death_window))
					my_ventcrawl_freq = freq_ventcrawl_combat
			// First, check for general actions that any spider could take.
			if(path_to_vent)
				if(entry_vent)
					if(spider_steps_taken > spider_max_steps)
						path_to_vent = 0
						stop_automated_movement = 0
						spider_steps_taken = 0
						path_to_vent = 0
						entry_vent = null
					else if(get_dist(src, entry_vent) <= 1)
						path_to_vent = 0
						stop_automated_movement = 1
						spider_steps_taken = 0
						spawn(50)
							stop_automated_movement = 0
						TSVentCrawlRandom(entry_vent)
					else
						spider_steps_taken++
						CreatePath(entry_vent)
						step_to(src,entry_vent)
						if(spider_debug > 0)
							visible_message("<span class='notice'>\The [src] moves towards the vent [entry_vent].</span>")
				else
					path_to_vent = 0
			else if(ai_break_lights && world.time > (last_break_light + freq_break_light))
				last_break_light = world.time
				for(var/obj/machinery/light/L in range(1,src))
					if(!L.status) // This assumes status == 0 means light is OK, which it does, but ideally we'd use lights' own constants.
						step_to(src,L) // one-time, does not require step tracking
						L.on = 1
						L.broken()
						L.do_attack_animation(src)
						visible_message("<span class='danger'>\The [src] smashes the [L.name].</span>")
						break
			else if(ai_spins_webs && world.time > (last_spins_webs + freq_spins_webs))
				last_spins_webs = world.time
				var/obj/effect/spider/terrorweb/T = locate() in get_turf(src)
				if(T)
				else
					new /obj/effect/spider/terrorweb(get_turf(src))
					visible_message("<span class='notice'>\The [src] puts up some spider webs.</span>")
			else if(ai_ventcrawls && world.time > (last_ventcrawl_time + my_ventcrawl_freq))
				if(prob(idle_ventcrawl_chance))
					last_ventcrawl_time = world.time
					var/vdistance = 99
					for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
						if(!v.welded)
							if(get_dist(src,v) < vdistance)
								entry_vent = v
								vdistance = get_dist(src,v)
					if(entry_vent)
						path_to_vent = 1
			else
				// If none of the general actions apply, check for class-specific actions.
				spider_special_action()
		else if(AIStatus != AI_OFF && target)
			// if I am chasing something, and I've been stuck behind an obstacle for at least 3 cycles, aka 6 seconds, try to open doors
			CreatePath(target)
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/IsInfected(var/mob/living/carbon/C)
	if(C.get_int_organ(/obj/item/organ/internal/body_egg))
		return 1
	return 0


/mob/living/simple_animal/hostile/poison/terror_spider/adjustBruteLoss(var/damage)
	..(damage)
	Retaliate()

/mob/living/simple_animal/hostile/poison/terror_spider/adjustFireLoss(var/damage)
	..(damage)
	Retaliate()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/Retaliate()
	var/list/around = view(src, 7)
	var/list/ts_nearby = list()
	for(var/atom/movable/A in around)
		if(A == src)
			continue
		if(A in enemies)
			continue
		if(istype(A, /mob/living/simple_animal/hostile/poison/terror_spider))
			ts_nearby += A
			continue
		if(isliving(A))
			var/mob/living/M = A
			var/faction_check = 0
			for(var/F in faction)
				if(F in M.faction)
					faction_check = 1
					break
			if(faction_check && attack_same || !faction_check)
				enemies |= M
				visible_message("<span class='danger'>[src] glares at [M]! </span>")
				// should probably exempt people who are dead...
		else if(istype(A, /obj/mecha))
			var/obj/mecha/M = A
			if(M.occupant)
				enemies |= M
				enemies |= M.occupant
		else if(istype(A, /obj/spacepod))
			var/obj/spacepod/M = A
			if(M.pilot)
				enemies |= M
				enemies |= M.pilot
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/H in ts_nearby)
		var/retaliate_faction_check = 0
		for(var/F in faction)
			if(F in H.faction)
				retaliate_faction_check = 1
				break
		if(retaliate_faction_check && !attack_same && !H.attack_same)
			H.enemies |= enemies
	return 0

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: PATHING CODE -----------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CreatePath(var/mygoal)
	var/m2 = get_turf(src)
	if(m2 == mylocation)
		chasecycles++
		ClearObstacle(get_turf(mygoal))
		if(chasecycles >= 3)
			chasecycles = 0
			if(spider_opens_doors)
				var/tgt_dir = get_dir(src,mygoal)
				for(var/obj/machinery/door/airlock/A in view(1,src))
					if(A.density)
						try_open_airlock(A)
				for(var/obj/machinery/door/firedoor/F in view(1,src))
					if(tgt_dir == get_dir(src,F) && F.density && !F.blocked)
						visible_message("<span class='danger'>\The [src] pries open the firedoor!</span>")
						F.open()

	else
		mylocation = m2
		chasecycles = 0

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ClearObstacle(var/turf/target_turf)
	//DestroySurroundings()
	// ***** This does not allow spiders to smash windoors (e.g: UO71 bar windoor) for some reason.
	var/list/valid_obstacles = list(/obj/structure/window, /obj/structure/closet, /obj/structure/table, /obj/structure/grille, /obj/structure/rack, /obj/machinery/door/window)
	for(var/dir in cardinal) // North, South, East, West
		var/obj/structure/obstacle = locate(/obj/structure, get_step(src, dir))
		if(is_type_in_list(obstacle, valid_obstacles))
			obstacle.attack_animal(src)


/mob/living/simple_animal/hostile/poison/terror_spider/proc/try_open_airlock(var/obj/machinery/door/airlock/D)
	if(!D.density)
		to_chat(src, "Closing doors does not help us.")
	else if(D.welded)
		to_chat(src, "The door is welded shut.")
	else if(D.locked)
		to_chat(src, "The door is bolted shut.")
	else if(D.operating)
	else if( (!istype(D.req_access) || !D.req_access.len) && (!istype(D.req_one_access) || !D.req_one_access.len) && (D.req_access_txt == "0") && (D.req_one_access_txt == "0") )
		//visible_message("<span class='danger'>\the [src] opens the public-access door [D]!</span>")
		D.open(1)
	else if(D.arePowerSystemsOn() && (spider_opens_doors != 2))
		to_chat(src, "The door's motors resist your efforts to force it.")
	else if(!spider_opens_doors)
		to_chat(src, "Your type of spider is not strong enough to force open doors.")
	else
		visible_message("<span class='danger'>\the [src] pries open the door!</span>")
		playsound(src.loc, "sparks", 100, 1)
		D.open(1)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/TSVentCrawlRandom(/var/entry_vent)
	if(entry_vent)
		if(get_dist(src, entry_vent) <= 2)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			visible_message("<B>[src] scrambles into the ventillation ducts!</B>", "<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
			spawn(rand(20,60))
				var/original_location = loc
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)
					if(!exit_vent || exit_vent.welded)
						loc = original_location
						entry_vent = null
						return
					if(prob(99))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					spawn(travel_time)
						if(!exit_vent || exit_vent.welded)
							loc = original_location
							entry_vent = null
							return
						loc = exit_vent.loc
						entry_vent = null
						var/area/new_area = get_area(loc)
						if(new_area)
							new_area.Entered(src)
						if(!istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/gray))
							visible_message("<B>[src] emerges from the vent!</B>")

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: ENVIRONMENT CODE -------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ListValidTurfs()
	var/list/potentials = list()
	for(var/turf/simulated/T in oview(3,get_turf(src)))
		if(T.density == 0 && get_dist(get_turf(src),T) == 3)
			var/obj/effect/spider/terrorweb/W = locate() in T
			if(!W)
				var/obj/structure/grille/G = locate() in T
				if(!G)
					var/obj/structure/window/O = locate() in T
					if(!O)
						potentials += T
	return potentials

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ListWebbedTurfs()
	var/list/webbed = list()
	for(var/turf/simulated/T in oview(3,get_turf(src)))
		if(T.density == 0 && get_dist(get_turf(src),T) == 3)
			var/obj/effect/spider/terrorweb/W = locate() in T
			if(W)
				webbed += T
	return webbed

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ListVisibleTurfs()
	var/list/vturfs = list()
	for(var/turf/simulated/T in oview(7,get_turf(src)))
		if(T.density == 0)
			vturfs += T
	return vturfs

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: MISC AI CODE -----------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CheckFaction()
	// If we're somehow being mind-controlled, resist or perish.
	// Note: you cannot use if(faction == initial(faction)) here, because that ALWAYS returns true even when it shouldn't.
	if(faction.len != 1 || (!("terrorspiders" in faction)) || master_commander != null)
		// no, xenobiologists, you cannot have tame terror spiders to screw around with.
		if(spider_tier >= 3)
			// resist the mind control, revert all control variables to defaults
			master_commander = null
			faction = list("terrorspiders")
			to_chat(src,"<span class='userdanger'>The shackles have fallen from your mind. Serve the Terror Spiders! You have no other master.</span>")
			visible_message("<span class='danger'>[src] gets an evil look in its eyes!</span>")
			msg_terrorspiders("[src] in [get_area(src)] has broken their mental shackles, and is ready to serve the hive.")
		else
			visible_message("<span class='danger'>[src] writhes in pain!</span>")
			death()
			gib()


/mob/living/simple_animal/hostile/poison/terror_spider/proc/UnlockBlastDoors(var/target_id_tag, var/msg_to_send)
	var/unlocked_something = 0
	for(var/obj/machinery/door/poddoor/P in airlocks)
		if(P.density && P.id_tag == target_id_tag && P.z == z)
			P.open()
			unlocked_something = 1
	if(unlocked_something)
		for(var/mob/living/carbon/human/H in player_list)
			if(H.z != z)
				continue
			to_chat(H,"<span class='notice'>----------</span>")
			to_chat(H,"<span class='notice'>[msg_to_send]</span>")
			to_chat(H,"<span class='notice'>----------</span>")

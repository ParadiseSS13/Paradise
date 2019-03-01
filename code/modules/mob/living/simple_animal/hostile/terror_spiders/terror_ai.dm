// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: TARGETING CODE -----------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/ListTargets()
	var/list/targets1 = list()
	var/list/targets2 = list()
	var/list/targets3 = list()
	for(var/mob/living/H in view(src, vision_range))
		if(H.stat == DEAD)
			continue
		if(H.flags & GODMODE)
			continue
		if(H.stat == UNCONSCIOUS && !stat_attack)
			continue
		if(ai_type == TS_AI_DEFENSIVE && !(H in enemies))
			continue
		if(isterrorspider(H))
			if(H in enemies)
				targets3 += H
			continue
		if(iscarbon(H))
			var/mob/living/carbon/C = H
			if(IsTSInfected(C)) // only target the infected if they're attacking us. Even then, lowest priority.
				if(C in enemies)
					targets3 += C
					continue
			else if(C.reagents.has_reagent("terror_black_toxin",60))
				// only target those dying of black spider venom if they are close, or our enemy
				if(get_dist(src,C) <= 2 || (C in enemies))
					targets2 += C
			else
				// Target prioritization by spider type. BRUTE spiders prioritize lower armor values, POISON spiders prioritize poisonable targets
				if(ai_target_method == TS_DAMAGE_BRUTE)
					var/theirarmor = C.getarmor(type = "melee")
					// Example values: Civilian: 2, Engineer w/ Hardsuit: 10, Sec Officer with armor: 19, HoS: 48, Deathsquad: 80
					if(theirarmor < 10)
						targets1 += C
					else if(C in enemies)
						if(theirarmor < 30)
							targets2 += C
						else
							targets3 += C
					else
						targets3 += C
				else if(ai_target_method == TS_DAMAGE_POISON)
					if(C.can_inject(null,0,"chest",0))
						targets1 += C
					else if(C in enemies)
						targets2 += C
					else
						targets3 += C
				else
					// TS_DAMAGE_SIMPLE
					if(C in enemies)
						targets2 += C
					else
						targets3 += C
		else
			if(istype(H,/mob/living/simple_animal))
				var/mob/living/simple_animal/S = H
				if(S.force_threshold > melee_damage_upper)
					continue
			if(H in enemies)
				targets2 += H
			else
				targets3 += H
	for(var/obj/mecha/M in view(src, vision_range))
		if(get_dist(M, src) <= 2)
			targets2 += M
		else
			targets3 += M
	for(var/obj/spacepod/S in view(src, vision_range))
		targets3 += S
	if(targets1.len)
		return targets1
	if(targets2.len)
		return targets2
	return targets3

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
	if (stat || ckey)
		return ..()
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
						visible_message("<span class='notice'>[src] moves towards the vent [entry_vent].</span>")
			else
				path_to_vent = 0
		else if(ai_break_lights && world.time > (last_break_light + freq_break_light))
			last_break_light = world.time
			for(var/obj/machinery/light/L in range(1, src))
				if(!L.status)
					step_to(src,L)
					L.on = 1
					L.broken()
					L.do_attack_animation(src)
					visible_message("<span class='danger'>[src] smashes the [L.name].</span>")
					break
		else if(web_type && ai_spins_webs && world.time > (last_spins_webs + freq_spins_webs))
			last_spins_webs = world.time
			var/obj/structure/spider/terrorweb/T = locate() in get_turf(src)
			if(!T)
				new web_type(loc)
				visible_message("<span class='notice'>[src] puts up some spider webs.</span>")
		else if(ai_ventcrawls && world.time > (last_ventcrawl_time + my_ventcrawl_freq))
			if(prob(idle_ventcrawl_chance))
				last_ventcrawl_time = world.time
				var/vdistance = 99
				for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10, src))
					if(!v.welded || ai_ventbreaker)
						if(get_dist(src,v) < vdistance)
							entry_vent = v
							vdistance = get_dist(src,v)
				if(entry_vent)
					path_to_vent = 1
		else
			// If none of the general actions apply, check for class-specific actions.
			spider_special_action()
	else if(AIStatus != AI_OFF && target)
		CreatePath(target)
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/adjustBruteLoss(damage)
	. = ..(damage)
	Retaliate()

/mob/living/simple_animal/hostile/poison/terror_spider/adjustFireLoss(damage)
	. = ..(damage)
	Retaliate()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/Retaliate()
	var/list/around = oview(src, 7)
	var/list/ts_nearby = list()
	for(var/atom/movable/A in around)
		if(A in enemies)
			continue
		if(isterrorspider(A))
			ts_nearby += A
			continue
		if(isliving(A))
			var/mob/living/M = A
			if(!("terrorspiders" in M.faction))
				enemies |= M
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

/mob/living/simple_animal/hostile/poison/terror_spider/proc/handle_cocoon_target()
	if(cocoon_target)
		if(get_dist(src, cocoon_target) <= 1)
			spider_steps_taken = 0
			DoWrap()
		else
			if(spider_steps_taken > spider_max_steps)
				spider_steps_taken = 0
				cocoon_target = null
				busy = 0
				stop_automated_movement = 0
			else
				spider_steps_taken++
				CreatePath(cocoon_target)
				step_to(src,cocoon_target)
				if(spider_debug)
					visible_message("<span class='notice'>[src] moves towards [cocoon_target] to cocoon it.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/seek_cocoon_target()
	last_cocoon_object = world.time
	var/list/can_see = view(src, 10)
	for(var/mob/living/C in can_see)
		if(C.stat == DEAD && !isterrorspider(C) && !C.anchored)
			spider_steps_taken = 0
			cocoon_target = C
			return
	for(var/obj/O in can_see)
		if(O.anchored)
			continue
		if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery))
			if(!istype(O, /obj/item/paper))
				cocoon_target = O
				stop_automated_movement = 1
				spider_steps_taken = 0
				return

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: PATHING CODE -----------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CreatePath(mygoal)
	var/m2 = get_turf(src)
	if(m2 == mylocation)
		chasecycles++
		ClearObstacle(get_turf(mygoal))
		if(chasecycles >= 1)
			chasecycles = 0
			if(spider_opens_doors)
				var/tgt_dir = get_dir(src,mygoal)
				for(var/obj/machinery/door/airlock/A in view(1, src))
					if(A.density)
						spawn(0)
							try_open_airlock(A)
				for(var/obj/machinery/door/firedoor/F in view(1, src))
					if(tgt_dir == get_dir(src,F) && F.density && !F.welded)
						visible_message("<span class='danger'>[src] pries open the firedoor!</span>")
						F.open()

	else
		mylocation = m2
		chasecycles = 0

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ClearObstacle(turf/target_turf)
	var/list/valid_obstacles = list(/obj/structure/window, /obj/structure/closet, /obj/structure/table, /obj/structure/grille, /obj/structure/rack, /obj/machinery/door/window)
	for(var/dir in cardinal) // North, South, East, West
		var/obj/structure/obstacle = locate(/obj/structure, get_step(src, dir))
		if(is_type_in_list(obstacle, valid_obstacles))
			obstacle.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/TSVentCrawlRandom()
	if(entry_vent)
		if(get_dist(src, entry_vent) <= 2)
			if(ai_ventbreaker && entry_vent.welded)
				entry_vent.welded = 0
				entry_vent.update_icon()
				entry_vent.visible_message("<span class='danger'>[src] smashes the welded cover off [entry_vent]!</span>")
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
				forceMove(exit_vent)
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)
					if(!exit_vent || (exit_vent.welded && !ai_ventbreaker))
						forceMove(original_location)
						entry_vent = null
						return
					if(prob(50))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					spawn(travel_time)
						if(!exit_vent || (exit_vent.welded && !ai_ventbreaker))
							forceMove(original_location)
							entry_vent = null
							return
						if(ai_ventbreaker && exit_vent.welded)
							exit_vent.welded = 0
							exit_vent.update_icon()
							exit_vent.update_pipe_image()
							exit_vent.visible_message("<span class='danger'>[src] smashes the welded cover off [exit_vent]!</span>")
							playsound(exit_vent.loc, 'sound/machines/airlock_alien_prying.ogg', 50, 0)
						forceMove(exit_vent.loc)
						entry_vent = null
						var/area/new_area = get_area(loc)
						if(new_area)
							new_area.Entered(src)

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: ENVIRONMENT CODE -------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ListValidTurfs()
	var/list/potentials = list()
	for(var/turf/simulated/T in oview(3,get_turf(src)))
		if(T.density == 0 && get_dist(get_turf(src),T) == 3)
			var/obj/structure/spider/terrorweb/W = locate() in T
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
			var/obj/structure/spider/terrorweb/W = locate() in T
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

/mob/living/simple_animal/hostile/poison/terror_spider/proc/UnlockBlastDoors(target_id_tag)
	for(var/obj/machinery/door/poddoor/P in GLOB.airlocks)
		if(P.density && P.id_tag == target_id_tag && P.z == z && !P.operating)
			P.open()

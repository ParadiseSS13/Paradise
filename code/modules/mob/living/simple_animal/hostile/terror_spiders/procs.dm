
/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoShowOrders(var/usecache = 0, var/thequeen = null, var/theempress = null)
	if (ckey)
		to_chat(src, "------------------------")
		if (ai_type == TS_AI_AGGRESSIVE)
			to_chat(src, "Your Orders: <span class='danger'>kill all humanoids on sight! </span>")
		else if (ai_type == TS_AI_DEFENSIVE)
			to_chat(src, "Your Orders: <span class='notice'>defend yourself & the hive, without being aggressive </span> ")
		else if (ai_type == TS_AI_PASSIVE)
			to_chat(src, "Your Orders: <span class='danger'>do not attack anyone, not even in self-defense!</span> ")
		to_chat(src, "------------------------")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/BroadcastOrders()
	var/cache_thequeen = null
	var/cache_theempress = null
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q in ts_spiderlist)
		if (Q.ckey || !Q.spider_awaymission)
			cache_thequeen = Q
			break
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/empress/E in ts_spiderlist)
		if (E.ckey || !E.spider_awaymission)
			cache_theempress = E
			break
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/S in ts_spiderlist)
		if (S.stat != DEAD)
			S.DoShowOrders(1,cache_thequeen,cache_theempress)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/IsInfected(var/mob/living/B)
	if (iscarbon(B))
		var/mob/living/carbon/C = B
		if (C.get_int_organ(/obj/item/organ/internal/body_egg))
			return 1
	return 0


/mob/living/simple_animal/hostile/poison/terror_spider/proc/Retaliate()
	var/list/around = view(src, 7)
	var/list/ts_nearby = list()
	for(var/atom/movable/A in around)
		if (A == src)
			continue
		if (A in enemies)
			continue
		if (istype(A, /mob/living/simple_animal/hostile/poison/terror_spider))
			ts_nearby += A
			continue
		if (isliving(A))
			var/mob/living/M = A
			var/faction_check = 0
			for(var/F in faction)
				if (F in M.faction)
					faction_check = 1
					break
			if (faction_check && attack_same || !faction_check)
				enemies |= M
				visible_message("<span class='danger'>\icon[src] [src] glares at [M]! </span>")
				// should probably exempt people who are dead...
		else if (istype(A, /obj/mecha))
			var/obj/mecha/M = A
			if (M.occupant)
				enemies |= M
				enemies |= M.occupant
		else if (istype(A, /obj/spacepod))
			var/obj/spacepod/M = A
			if (M.occupant || M.occupant2)
				enemies |= M
				enemies |= M.occupant
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/H in ts_nearby)
		var/retaliate_faction_check = 0
		for(var/F in faction)
			if (F in H.faction)
				retaliate_faction_check = 1
				break
		if (retaliate_faction_check && !attack_same && !H.attack_same)
			H.enemies |= enemies
	if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/queen) || istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/empress)  )
		for (var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
			T.enemies |= enemies
	return 0


/mob/living/simple_animal/hostile/poison/terror_spider/proc/msg_terrorspiders(var/msgtext)
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if (T.stat != DEAD)
			to_chat(T, "<span class='alien'>TerrorSense: " + msgtext + "</span>")


/mob/living/simple_animal/hostile/poison/terror_spider/proc/CountSpiders()
	var/numspiders = 0
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if (T.stat != DEAD && !T.spider_placed && spider_awaymission == T.spider_awaymission)
			numspiders += 1
	return numspiders

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CountSpidersType(var/specific_type)
	var/numspiders = 0
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if (T.stat != DEAD && !T.spider_placed && spider_awaymission == T.spider_awaymission)
			if (T.type == specific_type)
				numspiders += 1
	return numspiders


/mob/living/simple_animal/hostile/poison/terror_spider/proc/CreatePath(var/mygoal)
	var/m2 = get_turf(src)
	if (m2 == mylocation)
		chasecycles++
		ClearObstacle(get_turf(mygoal))
		if (chasecycles >= 3)
			chasecycles = 0
			if (spider_opens_doors)
				var/tgt_dir = get_dir(src,mygoal)
				for(var/obj/machinery/door/airlock/A in view(1,src))
					if (A.density)
						try_open_airlock(A)
				for(var/obj/machinery/door/firedoor/F in view(1,src))
					if (tgt_dir == get_dir(src,F) && F.density && !F.blocked)
						visible_message("<span class='danger'>\The [src] pries open the firedoor!</span>")
						F.open()

	else
		mylocation = m2
		chasecycles = 0

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ClearObstacle(var/turf/target_turf)
	//Old, easy code.
	//DestroySurroundings()

	// *****BUG***** This does not allow spiders to smash windoors (e.g: UO71 bar windoor) for some reason.
	// New, adapted from DestroySurroundings, let's see if it works.

	var/list/valid_obstacles = list(/obj/structure/window, /obj/structure/closet, /obj/structure/table, /obj/structure/grille, /obj/structure/rack, /obj/machinery/door/window)

	for(var/dir in cardinal) // North, South, East, West
		var/obj/structure/obstacle = locate(/obj/structure, get_step(src, dir))
		if (is_type_in_list(obstacle, valid_obstacles))
			obstacle.attack_animal(src)



/mob/living/simple_animal/hostile/poison/terror_spider/proc/UnlockBlastDoors(var/target_id_tag, var/msg_to_send)
	var/unlocked_something = 0
	for (var/obj/machinery/door/poddoor/P in airlocks)
		if (P.density && P.id_tag == target_id_tag && P.z == z)
			P.open()
			unlocked_something = 1
	if (unlocked_something)
		for(var/mob/living/carbon/human/H in player_list)
			if (H.z != z)
				continue
			to_chat(H,"<span class='notice'>----------</span>")
			to_chat(H,"<span class='notice'>[msg_to_send]</span>")
			to_chat(H,"<span class='notice'>----------</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoHiveSense()
	var/hsline = ""
	to_chat(src, "Your Brood: ")
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		hsline = "* [T] in [get_area(T)], "
		if (T.stat == DEAD)
			hsline += "DEAD"
		else
			hsline += "health [T.health] / [T.maxHealth], "
		if (T.ckey)
			hsline += " *Player Controlled* "
		else
			hsline += " AI: "
			if (T.ai_type == TS_AI_AGGRESSIVE)
				hsline += "aggressive"
			else if (T.ai_type == TS_AI_DEFENSIVE)
				hsline += "defensive"
			else if (T.ai_type == TS_AI_PASSIVE)
				hsline += "passive"
		to_chat(src,hsline)


/mob/living/simple_animal/hostile/poison/terror_spider/proc/DialogHiveCommand()
	var/dstance = input("How aggressive should your brood be?") as null|anything in list("Aggressive","Defensive","Passive")

	var/new_ai = -1
	if (dstance == "Aggressive")
		new_ai = 0
	else if (dstance == "Defensive")
		new_ai = 1
	else if (dstance == "Passive")
		new_ai = 2
	else
		to_chat(src, "That choice was not recognized.")
		return

	var/dai = input("How often should they use vents?") as null|anything in list("Constantly","Sometimes","Rarely", "Never")

	var/new_ventcrawl = 0
	if (dai == "Constantly")
		new_ventcrawl = 15
	else if (dai == "Sometimes")
		new_ventcrawl = 5
	else if (dai == "Rarely")
		new_ventcrawl = 2
	else if (dai == "Never")
		new_ventcrawl = 0
	else
		to_chat(src, "That choice was not recognized.")
		return

	var/dpc = input("Allow ghosts to inhabit spider bodies?") as null|anything in list("Yes","No")

	var/new_pc = 0
	if (dpc == "Yes")
		new_pc = 1
	else if (dpc == "No")
		new_pc = 0
	else
		to_chat(src, "That choice was not recognized.")
		return

	msg_terrorspiders("[src] has ordered their hive to be [dstance].")
	var/commanded = SetHiveCommand(new_ai,new_ventcrawl,new_pc)

	to_chat(src, "<B><span class='notice'> [commanded] spiders recieved your orders.</span></B>")


/mob/living/simple_animal/hostile/poison/terror_spider/proc/SetHiveCommand(var/set_ai, var/set_ventcrawl, var/set_pc)
	var/numspiders = 0
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if (spider_awaymission && !T.spider_awaymission)
			continue
		else if (!spider_awaymission && T.spider_awaymission)
			continue
		numspiders += 1
		if (spider_tier >= T.spider_tier)
			if (T.ai_type != set_ai)
				T.ai_type = set_ai
				T.ShowOrders()
			if (T.idle_ventcrawl_chance != set_ventcrawl)
				T.idle_ventcrawl_chance = set_ventcrawl
			if (T.ai_playercontrol_allowingeneral != set_pc)
				if (set_pc == 1 && !spider_awaymission)
					notify_ghosts("[T.name] in [get_area(T)] can be controlled! <a href=?src=\ref[T];activate=1>(Click to play)</a>", source = T)
				T.ai_playercontrol_allowingeneral = set_pc
	for(var/obj/effect/spider/eggcluster/terror_eggcluster/T in ts_egg_list)
		if (T.ai_playercontrol_allowingeneral != set_pc)
			T.ai_playercontrol_allowingeneral = set_pc
	for(var/obj/effect/spider/spiderling/terror_spiderling/T in ts_spiderling_list)
		if (T.ai_playercontrol_allowingeneral != set_pc)
			T.ai_playercontrol_allowingeneral = set_pc
	return numspiders

/mob/living/simple_animal/hostile/poison/terror_spider/proc/try_open_airlock(var/obj/machinery/door/airlock/D)
	if (!D.density)
		to_chat(src, "Closing doors does not help us.")
	else if (D.welded)
		to_chat(src, "The door is welded shut.")
	else if (D.locked)
		to_chat(src, "The door is bolted shut.")
	else if (D.operating)
	else if ( (!istype(D.req_access) || !D.req_access.len) && (!istype(D.req_one_access) || !D.req_one_access.len) && (D.req_access_txt == "0") && (D.req_one_access_txt == "0") )
		//visible_message("<span class='danger'>\the [src] opens the public-access door [D]!</span>")
		D.open(1)
	else if (D.arePowerSystemsOn() && (spider_opens_doors != 2))
		to_chat(src, "The door's motors resist your efforts to force it.")
	else if (!spider_opens_doors)
		to_chat(src, "Your type of spider is not strong enough to force open doors.")
	else
		visible_message("<span class='danger'>\the [src] pries open the door!</span>")
		playsound(src.loc, "sparks", 100, 1)
		D.open(1)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/TSVentCrawlRandom(/var/entry_vent)
	if (entry_vent)
		if (get_dist(src, entry_vent) <= 2)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.parent.other_atmosmch)
				vents.Add(temp_vent)
			if (!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			visible_message("<B>[src] scrambles into the ventillation ducts!</B>", "<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
			spawn(rand(20,60))
				var/original_location = loc
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)
					if (!exit_vent || exit_vent.welded)
						loc = original_location
						entry_vent = null
						return
					if (prob(99))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					spawn(travel_time)
						if (!exit_vent || exit_vent.welded)
							loc = original_location
							entry_vent = null
							return
						loc = exit_vent.loc
						entry_vent = null
						var/area/new_area = get_area(loc)
						if (new_area)
							new_area.Entered(src)
						if (!istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/gray))
							visible_message("<B>[src] emerges from the vent!</B>")



/mob/living/simple_animal/hostile/poison/terror_spider/proc/humanize_spider(mob/user)
	if (key)//Someone is in it
		return
	var/error_on_humanize = ""
	var/humanize_prompt = "Take direct control of " + src.name + "? "
	if (ai_type == TS_AI_AGGRESSIVE)
		humanize_prompt += "Orders: AGGRESSIVE. "
	else if (ai_type == TS_AI_DEFENSIVE)
		humanize_prompt += "Orders: DEFENSIVE. "
	else if (ai_type == TS_AI_PASSIVE)
		humanize_prompt += "Orders: PASSIVE/TAME. "
	humanize_prompt += "Role: " + spider_role_summary
	if (user.ckey in ts_ckey_blacklist)
		error_on_humanize = "You are not able to control any terror spider this round."
	else if (!ai_playercontrol_allowingeneral)
		error_on_humanize = "Terror spiders cannot currently be player-controlled."
	else if (spider_awaymission)
		error_on_humanize = "Terror spiders that are part of an away mission cannot be controlled by ghosts."
	else if (!ai_playercontrol_allowtype)
		error_on_humanize = "This specific type of terror spider is not player-controllable."
	else if (degenerate)
		error_on_humanize = "Dying spiders are not player-controllable."
	else if (health == 0)
		error_on_humanize = "Dead spiders are not player-controllable."
	if (jobban_isbanned(user, "Syndicate") || jobban_isbanned(user, "alien"))
		to_chat(user,"You are jobbanned from role of syndicate and/or alien lifeform.")
		return
	if (error_on_humanize == "")
		var/spider_ask = alert(humanize_prompt, "Join as Terror Spider?", "Yes", "No")
		if (spider_ask == "No" || !src || qdeleted(src))
			return
	else
		to_chat(user, "Cannot inhabit spider: " + error_on_humanize)
		return
	if (key)
		to_chat(user, "<span class='notice'>Someone else already took this spider.</span>")
		return
	key = user.key
	for(var/mob/dead/observer/G in player_list)
		G.show_message("<i>A ghost has taken control of <b>[src]</b>. ([ghost_follow_link(src, ghost=G)]).</i>")
	// T1
	ShowGuide()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoWrap()
	if (!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1,src))
			if (L == src)
				continue
			if (Adjacent(L))
				if (L.stat != CONSCIOUS)
					choices += L
		for(var/obj/O in loc)
			if (Adjacent(O))
				if (istype(O, /obj/effect/spider/terrorweb))
				else
					choices += O
		cocoon_target = input(src,"What do you wish to cocoon?") in null|choices
	if (cocoon_target && busy != SPINNING_COCOON)
		busy = SPINNING_COCOON
		visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
		stop_automated_movement = 1
		walk(src,0)
		spawn(50)
			if (busy == SPINNING_COCOON)
				if (cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
					var/obj/effect/spider/cocoon/C = new(cocoon_target.loc)
					var/large_cocoon = 0
					C.pixel_x = cocoon_target.pixel_x
					C.pixel_y = cocoon_target.pixel_y
					for(var/obj/item/I in C.loc)
						I.loc = C
					for(var/obj/structure/S in C.loc)
						if (!S.anchored)
							S.loc = C
							large_cocoon = 1
					for(var/obj/machinery/M in C.loc)
						if (!M.anchored)
							M.loc = C
							large_cocoon = 1
					for(var/mob/living/L in C.loc)
						if (istype(L, /mob/living/simple_animal/hostile/poison/terror_spider))
							continue
						large_cocoon = 1
						fed++
						last_cocoon_object = 0
						L.loc = C
						C.pixel_x = L.pixel_x
						C.pixel_y = L.pixel_y
						visible_message("<span class='danger'>\the [src] sticks a proboscis into \the [L] and sucks a viscous substance out.</span>")
						break
					if (large_cocoon)
						C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
			cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ListValidTurfs()
	var/list/potentials = list()
	for (var/turf/simulated/T in oview(3,get_turf(src)))
		if (T.density == 0 && get_dist(get_turf(src),T) == 3)
			var/obj/effect/spider/terrorweb/W = locate() in T
			if (!W)
				var/obj/structure/grille/G = locate() in T
				if (!G)
					var/obj/structure/window/O = locate() in T
					if (!O)
						potentials += T
	return potentials

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ListWebbedTurfs()
	var/list/webbed = list()
	for (var/turf/simulated/T in oview(3,get_turf(src)))
		if (T.density == 0 && get_dist(get_turf(src),T) == 3)
			var/obj/effect/spider/terrorweb/W = locate() in T
			if (W)
				webbed += T
	return webbed

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ListVisibleTurfs()
	var/list/vturfs = list()
	for (var/turf/simulated/T in oview(7,get_turf(src)))
		if (T.density == 0)
			vturfs += T
	return vturfs

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CheckFaction()
	// If we're somehow being mind-controlled, resist or perish.
	// Note: you cannot use if (faction == initial(faction)) here, because that ALWAYS returns true even when it shouldn't.
	if (faction.len != 1 || (!("terrorspiders" in faction)) || master_commander != null)
		// no, xenobiologists, you cannot have tame terror spiders to screw around with.
		if (spider_tier >= 3)
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

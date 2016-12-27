
// All terror spider code that relates to queen ruling over a hive

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoHiveSense()
	var/hsline = ""
	to_chat(src, "Your Brood: ")
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if(T.spider_awaymission != spider_awaymission)
			continue
			// we don't say anything about UO71/awaymission spiders to queens on the main station.
		hsline = "* [T] in [get_area(T)], "
		if(T.stat == DEAD)
			hsline += "DEAD"
		else
			hsline += "health [T.health] / [T.maxHealth], "
		if(T.ckey)
			hsline += " *Player Controlled* "
		else
			hsline += " AI: "
			if(T.ai_type == TS_AI_AGGRESSIVE)
				hsline += "aggressive"
			else if(T.ai_type == TS_AI_DEFENSIVE)
				hsline += "defensive"
			else if(T.ai_type == TS_AI_PASSIVE)
				hsline += "passive"
		to_chat(src,hsline)


/mob/living/simple_animal/hostile/poison/terror_spider/proc/DialogHiveCommand()
	var/dstance = input("How aggressive should your brood be?") as null|anything in list("Aggressive","Defensive","Passive")

	var/new_ai = -1
	if(dstance == "Aggressive")
		new_ai = 0
	else if(dstance == "Defensive")
		new_ai = 1
	else if(dstance == "Passive")
		new_ai = 2
	else
		to_chat(src, "That choice was not recognized.")
		return

	var/dai = input("How often should they use vents?") as null|anything in list("Constantly","Sometimes","Rarely", "Never")

	var/new_ventcrawl = 0
	if(dai == "Constantly")
		new_ventcrawl = 15
	else if(dai == "Sometimes")
		new_ventcrawl = 5
	else if(dai == "Rarely")
		new_ventcrawl = 2
	else if(dai == "Never")
		new_ventcrawl = 0
	else
		to_chat(src, "That choice was not recognized.")
		return

	var/dpc = input("Allow ghosts to inhabit spider bodies?") as null|anything in list("Yes","No")

	var/new_pc = 0
	if(dpc == "Yes")
		new_pc = 1
	else if(dpc == "No")
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
		if(spider_awaymission && !T.spider_awaymission)
			continue
		else if(!spider_awaymission && T.spider_awaymission)
			continue
		numspiders += 1
		if(spider_tier >= T.spider_tier)
			if(T.ai_type != set_ai)
				T.ai_type = set_ai
				T.ShowOrders()
			if(T.idle_ventcrawl_chance != set_ventcrawl)
				T.idle_ventcrawl_chance = set_ventcrawl
			if(T.ai_playercontrol_allowingeneral != set_pc)
				if(set_pc == 1 && !spider_awaymission)
					notify_ghosts("\The [T] in [get_area(T)] can be controlled!", enter_link = "<a href=?src=\ref[T];activate=1>(Click to play)</a>", source = T)
				T.ai_playercontrol_allowingeneral = set_pc
	for(var/obj/effect/spider/eggcluster/terror_eggcluster/T in ts_egg_list)
		if(T.ai_playercontrol_allowingeneral != set_pc)
			T.ai_playercontrol_allowingeneral = set_pc
	for(var/obj/effect/spider/spiderling/terror_spiderling/T in ts_spiderling_list)
		if(T.ai_playercontrol_allowingeneral != set_pc)
			T.ai_playercontrol_allowingeneral = set_pc
	return numspiders


/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoShowOrders(var/usecache = 0, var/thequeen = null, var/theempress = null)
	if(ckey)
		to_chat(src, "------------------------")
		if(ai_type == TS_AI_AGGRESSIVE)
			to_chat(src, "Your Orders:<span class='danger'> kill all humanoids on sight! </span>")
		else if(ai_type == TS_AI_DEFENSIVE)
			to_chat(src, "Your Orders:<span class='notice'> defend yourself & the hive, without being aggressive </span>")
		else if(ai_type == TS_AI_PASSIVE)
			to_chat(src, "Your Orders:<span class='danger'> do not attack anyone, not even in self-defense!</span>")
		to_chat(src, "------------------------")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/BroadcastOrders()
	var/cache_thequeen = null
	var/cache_theempress = null
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q in ts_spiderlist)
		if(Q.ckey || !Q.spider_awaymission)
			cache_thequeen = Q
			break
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/empress/E in ts_spiderlist)
		if(E.ckey || !E.spider_awaymission)
			cache_theempress = E
			break
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/S in ts_spiderlist)
		if(S.stat != DEAD)
			S.DoShowOrders(1,cache_thequeen,cache_theempress)


/mob/living/simple_animal/hostile/poison/terror_spider/proc/CountSpiders()
	var/numspiders = 0
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if(T.stat != DEAD && !T.spider_placed && spider_awaymission == T.spider_awaymission)
			numspiders += 1
	return numspiders

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CountSpidersType(var/specific_type)
	var/numspiders = 0
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if(T.stat != DEAD && !T.spider_placed && spider_awaymission == T.spider_awaymission)
			if(T.type == specific_type)
				numspiders += 1
	for(var/obj/effect/spider/eggcluster/terror_eggcluster/E in ts_egg_list)
		if(E.spiderling_type == specific_type && E.z == z)
			numspiders += E.spiderling_number
	for(var/obj/effect/spider/spiderling/terror_spiderling/L in ts_spiderling_list)
		if(!L.stillborn && L.grow_as == specific_type && L.z == z)
			numspiders += 1
	return numspiders



// All terror spider code that relates to queen ruling over a hive

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoHiveSense()
	var/hsline = ""
	to_chat(src, "Your Brood: ")
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = thing
		if(T.spider_awaymission != spider_awaymission)
			continue
		hsline = "* [T] in [get_area(T)], "
		if(T.stat == DEAD)
			hsline += "DEAD"
		else
			hsline += "health [T.health] / [T.maxHealth], "
		if(T.ckey)
			hsline += " *Player Controlled* "
		else
			hsline += " AI "
		to_chat(src,hsline)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CountSpiders()
	var/numspiders = 0
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = thing
		if(T.stat != DEAD && !T.spider_placed && spider_awaymission == T.spider_awaymission)
			numspiders += 1
	return numspiders

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CountSpidersDetailed(check_mine = FALSE, list/mytypes = list())
	var/list/spider_totals = list("all" = 0)
	var/check_list = length(mytypes) > 0
	for(var/thistype in mytypes)
		spider_totals[thistype] = 0
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = thing
		if(T.stat == DEAD || T.spider_placed || spider_awaymission != T.spider_awaymission)
			continue
		if(check_mine && T.spider_myqueen != src)
			continue
		if(check_list && !(T.type in mytypes))
			continue
		if(T == src)
			continue
		if(spider_totals[T.type])
			spider_totals[T.type]++
		else
			spider_totals[T.type] = 1
		spider_totals["all"]++
	for(var/thing in GLOB.ts_egg_list)
		var/obj/structure/spider/eggcluster/terror_eggcluster/E = thing
		if(check_mine && E.spider_myqueen != src)
			continue
		if(check_list && E.spiderling_type && !(E.spiderling_type in mytypes))
			continue
		if(spider_totals[E.spiderling_type])
			spider_totals[E.spiderling_type] += E.spiderling_number
		else
			spider_totals[E.spiderling_type] = E.spiderling_number
		spider_totals["all"] += E.spiderling_number
	for(var/thing in GLOB.ts_spiderling_list)
		var/obj/structure/spider/spiderling/terror_spiderling/L = thing
		if(L.stillborn)
			continue
		if(check_mine && L.spider_myqueen != src)
			continue
		if(check_list && L.grow_as && !(L.grow_as in mytypes))
			continue
		if(spider_totals[L.grow_as])
			spider_totals[L.grow_as]++
		else
			spider_totals[L.grow_as] = 1
		spider_totals["all"]++
	return spider_totals


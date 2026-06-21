// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: EGGS (USED BY NURSE AND QUEEN TYPES) ---------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoLayTerrorEggs(lay_type, lay_number)
	stop_automated_movement = TRUE
	var/obj/structure/spider/eggcluster/terror_eggcluster/C = new /obj/structure/spider/eggcluster/terror_eggcluster(get_turf(src), lay_type)
	C.spiderling_number = lay_number
	C.spider_myqueen = spider_myqueen
	C.spider_mymother = src
	C.enemies = enemies
	if(spider_growinstantly)
		C.amount_grown = 250
		C.spider_growinstantly = TRUE
	spawn(10)
		stop_automated_movement = FALSE

/obj/structure/spider/eggcluster/terror_eggcluster
	name = "terror egg cluster"
	desc = "A cluster of tiny spider eggs. They pulse with a strong inner life, and appear to have sharp thorns on the sides."
	var/spider_growinstantly = FALSE
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/spider_myqueen = null
	var/mob/living/simple_animal/hostile/poison/terror_spider/spider_mymother = null
	var/spiderling_type = null
	var/spiderling_number = 1
	var/list/enemies = list()

/obj/structure/spider/eggcluster/terror_eggcluster/Initialize(mapload, lay_type)
	. = ..()
	GLOB.ts_egg_list += src
	spiderling_type = lay_type

	switch(spiderling_type)
		if(/mob/living/simple_animal/hostile/poison/terror_spider/red)
			name = "red terror eggs"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/gray)
			name = "gray terror eggs"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/green)
			name = "green terror eggs"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/black)
			name = "black terror eggs"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/purple)
			name = "purple terror eggs"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/white)
			name = "white terror eggs"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/mother)
			name = "mother of terror eggs"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/prince)
			name = "prince of terror eggs"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/queen)
			name = "queen of terror eggs"
	AddComponent(/datum/component/event_tracker, EVENT_TERROR_SPIDERS)

/obj/structure/spider/eggcluster/terror_eggcluster/Destroy()
	GLOB.ts_egg_list -= src
	return ..()

/obj/structure/spider/eggcluster/terror_eggcluster/process()
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		var/num = spiderling_number
		for(var/i=0, i<num, i++)
			var/mob/living/basic/spiderling/terror_spiderling/S = new /mob/living/basic/spiderling/terror_spiderling(get_turf(src))
			if(spiderling_type)
				S.grow_as = spiderling_type
			S.spider_myqueen = spider_myqueen
			S.spider_mymother = spider_mymother
			S.enemies = enemies
			if(spider_growinstantly)
				S.amount_grown = 250
		qdel(src)

/obj/structure/spider/royaljelly
	name = "royal jelly"
	desc = "A pulsating mass of slime, jelly, blood, and or liquified human organs considered delicious and highly nutritious by terror spiders."
	icon_state = "spiderjelly"


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: SPIDERLINGS (USED BY GREEN, WHITE, QUEEN AND MOTHER TYPES)
// --------------------------------------------------------------------------------

/obj/structure/spider/spiderling/terror_spiderling
	name = "spiderling"
	desc = "A fast-moving tiny spider, prone to making aggressive hissing sounds. Hope it doesn't grow up."
	icon_state = "spiderling"
	anchored = FALSE
	layer = 2.75
	max_integrity = 3
	var/stillborn = FALSE
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/spider_myqueen = null
	var/mob/living/simple_animal/hostile/poison/terror_spider/spider_mymother = null
	var/goto_mother = FALSE
	var/ventcrawl_chance = 30 // 30% every process(), assuming 33% wander does not trigger
	var/immediate_ventcrawl = TRUE
	var/list/enemies = list()
	var/spider_awaymission = FALSE
	var/frustration = 0
	var/debug_ai_choices = FALSE
	var/movement_disabled = FALSE

/obj/structure/spider/spiderling/terror_spiderling/Initialize(mapload)
	. = ..()
	GLOB.ts_spiderling_list += src
	if(is_away_level(z))
		spider_awaymission = TRUE

/obj/structure/spider/spiderling/terror_spiderling/Destroy()
	GLOB.ts_spiderling_list -= src
	return ..()

/obj/structure/spider/spiderling/terror_spiderling/Bump(obj/O)
	if(istype(O, /obj/structure/table))
		forceMove(O.loc)
	. = ..()


/obj/structure/spider/spiderling/terror_spiderling/Destroy()
	for(var/obj/structure/spider/spiderling/terror_spiderling/S in view(7, src))
		S.immediate_ventcrawl = TRUE
	return ..()

/obj/structure/spider/spiderling/terror_spiderling/proc/score_surroundings(atom/A = src)
	var/safety_score = 0
	var/turf/T = get_turf(A)
	for(var/mob/living/L in viewers(T))
		if(isterrorspider(L))
			if(L.stat == DEAD)
				safety_score--
			else
				safety_score++
				if(spider_mymother && L == spider_mymother)
					safety_score++
		else if(L.stat != DEAD)
			safety_score--
	if(debug_ai_choices)
		debug_visual(T, safety_score, A)
	return safety_score

/obj/structure/spider/spiderling/terror_spiderling/proc/debug_visual(turf/T, score, atom/A)
	// This proc exists to help debug why spiderlings are making the ventcrawl AI choices they do.
	// It won't be called unless you set the spiderling's debug_ai_choices to true.
	if(debug_ai_choices && istype(T))
		if(A == src)
			if(score > 0)
				new /obj/effect/temp_visual/heart(T) // heart symbol, I am safe here, protected by a friendly spider
			else if(score == 0)
				new /obj/effect/temp_visual/heal(T) // white "+" symbol, I am neutral here
			else
				new /obj/effect/temp_visual/at_shield(T) // octagon symbol, I am unsafe here, I need to flee
		else
			if(score > 0)
				new /obj/effect/temp_visual/telekinesis(T) // blue sparks, this is a safe area, I want to go here
			else if(score == 0)
				new /obj/effect/temp_visual/revenant(T) // purple sparks, this is a neutral area, an acceptable choice
			else
				new /obj/effect/temp_visual/cult/sparks(T) // red sparks, this is an unsafe area, I won't go here unless fleeing something worse

/obj/structure/spider/spiderling/terror_spiderling/process()
	var/turf/T = get_turf(src)
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		if(spider_awaymission && !is_away_level(T.z))
			stillborn = TRUE
		if(stillborn)
			if(amount_grown >= 300)
				// Fake spiderlings stick around for awhile, just to be spooky.
				qdel(src)
		else
			if(!grow_as)
				grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray, /mob/living/simple_animal/hostile/poison/terror_spider/green)
			var/mob/living/simple_animal/hostile/poison/terror_spider/S = new grow_as(T)
			S.spider_myqueen = spider_myqueen
			S.spider_mymother = spider_mymother
			S.enemies = enemies
			qdel(src)
	if(movement_disabled)
		return
	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = FALSE
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			frustration = 0
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.parent.other_atmosmch)
				if(temp_vent.welded) // no point considering a vent we can't even use
					continue
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			if(spider_mymother && (goto_mother || prob(10)))
				for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(5, spider_mymother))
					if(!v.welded)
						exit_vent = v
				goto_mother = FALSE
			if(!stillborn)
				var/current_safety_score = score_surroundings(src)
				var/new_safety_score = score_surroundings(exit_vent)
				if(new_safety_score < current_safety_score)
					// Try to find an alternative.
					exit_vent = pick(vents)
					new_safety_score = score_surroundings(exit_vent)
					if(new_safety_score < current_safety_score)
						// No alternative safe vent could be found. Abort.
						entry_vent = null
						return
			var/original_location = loc
			spawn(rand(20,60))
				forceMove(exit_vent)
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)
					if(!exit_vent || exit_vent.welded)
						forceMove(original_location)
						entry_vent = null
						return
					if(prob(50))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					spawn(travel_time)
						if(!exit_vent || exit_vent.welded)
							forceMove(original_location)
							entry_vent = null
							return
						forceMove(exit_vent.loc)
						entry_vent = null
						var/area/new_area = get_area(loc)
						if(new_area)
							new_area.Entered(src)
		else
			frustration++
			walk_to(src, entry_vent, 1)
			if(frustration > 2)
				entry_vent = null
	else if(prob(33))
		random_skitter()
	else if(immediate_ventcrawl || prob(ventcrawl_chance))
		immediate_ventcrawl = FALSE
		if(!stillborn && !goto_mother)
			var/safety_score = score_surroundings(src)
			if(safety_score > 0)
				// This area seems safe (friendly spiders present). Do not leave this area.
				return
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				walk_to(src, entry_vent, 1)
				break



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
	icon_state = "eggs"
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

/obj/structure/spider/eggcluster/terror_eggcluster/Destroy()
	GLOB.ts_egg_list -= src
	return ..()

/obj/structure/spider/eggcluster/terror_eggcluster/process()
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		var/num = spiderling_number
		for(var/i=0, i<num, i++)
			var/obj/structure/spider/spiderling/terror_spiderling/S = new /obj/structure/spider/spiderling/terror_spiderling(get_turf(src))
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

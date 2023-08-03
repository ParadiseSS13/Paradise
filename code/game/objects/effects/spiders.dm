/obj/structure/spider
	name = "web"
	desc = "it's stringy and sticky"
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	density = FALSE
	max_integrity = 15
	var/mob/living/carbon/human/master_commander = null

/obj/structure/spider/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)//the stickiness of the web mutes all attack sounds except fire damage type
		playsound(loc, 'sound/items/welder.ogg', 100, TRUE)


/obj/structure/spider/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BURN)
				damage_amount *= 2
			if(BRUTE)
				damage_amount *= 0.25
	. = ..()

/obj/structure/spider/Destroy()
	master_commander = null
	return ..()

/obj/structure/spider/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/spider/stickyweb
	icon_state = "stickyweb1"

/obj/structure/spider/stickyweb/Initialize(mapload)
	. = ..()
	if(prob(50))
		icon_state = "stickyweb2"

/obj/structure/spider/stickyweb/CanPass(atom/movable/mover, turf/target, height=0)
	if(height == 0)
		return TRUE
	if(istype(mover, /mob/living/simple_animal/hostile/poison/giant_spider) || isterrorspider(mover))
		return TRUE
	else if(isliving(mover))
		if(prob(50))
			to_chat(mover, "<span class='danger'>You get stuck in [src] for a moment.</span>")
			return FALSE
	else if(istype(mover, /obj/item/projectile))
		return prob(30)
	return TRUE

/obj/structure/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life"
	icon_state = "eggs"
	var/amount_grown = 0
	var/player_spiders = FALSE
	var/list/faction = list("spiders")
	flags_2 = CRITICAL_ATOM_2

/obj/structure/spider/eggcluster/Initialize(mapload)
	. = ..()
	pixel_x = rand(3,-3)
	pixel_y = rand(3,-3)
	START_PROCESSING(SSobj, src)

/obj/structure/spider/eggcluster/process()
	if(SSmobs.xenobiology_mobs > MAX_GOLD_CORE_MOBS - 10) //eggs gonna chill out until there is less spiders
		return

	amount_grown += rand(0, 2)

	if(amount_grown >= 100)
		var/num = rand(3, 12)
		for(var/i in 1 to num)
			var/obj/structure/spider/spiderling/S = new /obj/structure/spider/spiderling(loc)
			S.faction = faction.Copy()
			S.master_commander = master_commander
			if(player_spiders)
				S.player_spiders = TRUE
		qdel(src)

/obj/structure/spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	anchored = FALSE
	layer = 2.75
	max_integrity = 3
	var/amount_grown = 0
	var/grow_as = null
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/travelling_in_vent = FALSE
	var/player_spiders = FALSE
	var/list/faction = list("spiders")
	var/selecting_player = 0
	///Is this spiderling created from a xenobiology mob?
	var/xenobiology_spawned = FALSE

/obj/structure/spider/spiderling/Initialize(mapload)
	. = ..()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/swarming)
	ADD_TRAIT(src, TRAIT_EDIBLE_BUG, "edible_bug") // Normally this is just used for mobs, but spiderlings are kind of that...

/obj/structure/spider/spiderling/Destroy()
	STOP_PROCESSING(SSobj, src)
	// Release possible ref if a walk is still being processed
	walk_to(src, 0)
	entry_vent = null
	if(amount_grown < 100)
		new /obj/effect/decal/cleanable/spiderling_remains(get_turf(src))
	return ..()

/obj/structure/spider/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		loc = user.loc
	else
		..()

/obj/structure/spider/spiderling/process()
	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = FALSE
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			if(prob(50))
				visible_message("<B>[src] scrambles into the ventilation ducts!</B>", \
								"<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")

			spawn(rand(20,60))
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)

					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return

					if(prob(50))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					sleep(travel_time)

					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return
					loc = exit_vent.loc
					entry_vent = null
					var/area/new_area = get_area(loc)
					if(new_area)
						new_area.Entered(src)
	//=================

	else if(prob(33))
		if(random_skitter() && prob(40))
			visible_message("<span class='notice'>[src] skitters[pick(" away"," around","")].</span>")
	else if(prob(10))
		//ventcrawl!
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				walk_to(src, entry_vent, 1)
				break
	if(isturf(loc))
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			if(SSmobs.xenobiology_mobs > MAX_GOLD_CORE_MOBS && xenobiology_spawned)
				qdel(src)
				return
			if(!grow_as)
				grow_as = pick(typesof(/mob/living/simple_animal/hostile/poison/giant_spider))
			var/mob/living/simple_animal/hostile/poison/giant_spider/S = new grow_as(loc)
			S.faction = faction.Copy()
			S.master_commander = master_commander
			S.xenobiology_spawned = xenobiology_spawned
			if(xenobiology_spawned)
				SSmobs.xenobiology_mobs++
			if(player_spiders && !selecting_player)
				selecting_player = 1
				spawn()
					var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a giant spider?", ROLE_SENTIENT, TRUE, source = S)

					if(length(candidates) && !QDELETED(S))
						var/mob/C = pick(candidates)
						if(C)
							S.key = C.key
							if(S.master_commander)
								to_chat(S, "<span class='biggerdanger'>You are a spider who is loyal to [S.master_commander], obey [S.master_commander]'s every order and assist [S.master_commander.p_them()] in completing [S.master_commander.p_their()] goals at any cost.</span>")
			qdel(src)

/obj/structure/spider/spiderling/proc/random_skitter()
	var/list/available_turfs = list()
	for(var/turf/simulated/S in oview(10, src))
		// no !isspaceturf check needed since /turf/simulated is not a subtype of /turf/space
		if(S.density)
			continue
		available_turfs += S
	if(!length(available_turfs))
		return FALSE
	walk_to(src, pick(available_turfs))
	return TRUE

/obj/structure/spider/spiderling/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!isdrone(user))
		user.visible_message("<span class='notice'>[user] sucks [src] into its decompiler. There's a horrible crunching noise.</span>", \
		"<span class='warning'>It's a bit of a struggle, but you manage to suck [user] into your decompiler. It makes a series of visceral crunching noises.</span>")
		C.stored_comms["wood"] += 2
		C.stored_comms["glass"] += 2
		qdel(src)
		return TRUE
	return ..()

/obj/effect/decal/cleanable/spiderling_remains
	name = "spiderling remains"
	desc = "Green squishy mess."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenshatter"

/obj/structure/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web"
	icon_state = "cocoon1"
	max_integrity = 60

/obj/structure/spider/cocoon/Initialize(mapload)
	. = ..()
	icon_state = pick("cocoon1","cocoon2","cocoon3")

/obj/structure/spider/cocoon/Destroy()
	visible_message("<span class='danger'>[src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(loc)
	return ..()

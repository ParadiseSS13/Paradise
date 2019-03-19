
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T4 QUEEN OF TERROR ---------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: gamma-level threat to the whole station, like a blob
// -------------: AI: builds a nest, lays many eggs, attempts to take over the station
// -------------: SPECIAL: spins webs, breaks lights, breaks cameras, webs objects, lays eggs, commands other spiders...
// -------------: TO FIGHT IT: bring an army, and take no prisoners. Mechs and/or decloner guns are a very good idea.
// -------------: SPRITES FROM: IK3I

/mob/living/simple_animal/hostile/poison/terror_spider/queen
	name = "Queen of Terror spider"
	desc = "An enormous, terrifying spider. Its egg sac is almost as big as its body, and teeming with spider eggs!"
	spider_role_summary = "Commander of the spider forces. Lays eggs, directs the brood."
	ai_target_method = TS_DAMAGE_SIMPLE
	icon_state = "terror_queen"
	icon_living = "terror_queen"
	icon_dead = "terror_queen_dead"
	maxHealth = 200
	health = 200
	regen_points_per_tick = 3
	melee_damage_lower = 10
	melee_damage_upper = 20
	ventcrawler = 1
	idle_ventcrawl_chance = 0
	force_threshold = 18 // outright immune to anything of force under 18, this means welders can't hurt it, only guns can
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/pierce.ogg'
	projectiletype = /obj/item/projectile/terrorqueenspit
	spider_tier = TS_TIER_4
	spider_opens_doors = 2
	web_type = /obj/structure/spider/terrorweb/queen
	var/spider_spawnfrequency = 1200 // 120 seconds
	var/spider_spawnfrequency_stable = 1200 // 120 seconds. Spawnfrequency is set to this on ai spiders once nest setup is complete.
	var/spider_lastspawn = 0
	var/nestfrequency = 300 // 30 seconds
	var/lastnestsetup = 0
	var/neststep = 0
	var/hasnested = 0
	var/spider_max_per_nest = 35 // above this, AI queens become stable
	var/canlay = 4 // main counter for egg-laying ability! # = num uses, incremented at intervals
	var/eggslaid = 0
	var/spider_can_fakelings = 3 // spawns defective spiderlings that don't grow up, used to freak out crew, atmosphere
	var/list/spider_types_standard = list(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray, /mob/living/simple_animal/hostile/poison/terror_spider/green, /mob/living/simple_animal/hostile/poison/terror_spider/black)
	var/datum/action/innate/terrorspider/queen/queennest/queennest_action
	var/datum/action/innate/terrorspider/queen/queensense/queensense_action
	var/datum/action/innate/terrorspider/queen/queeneggs/queeneggs_action
	var/datum/action/innate/terrorspider/queen/queenfakelings/queenfakelings_action
	var/datum/action/innate/terrorspider/ventsmash/ventsmash_action

/mob/living/simple_animal/hostile/poison/terror_spider/queen/New()
	..()
	queennest_action = new()
	queennest_action.Grant(src)
	ventsmash_action = new()
	ventsmash_action.Grant(src)
	spider_myqueen = src
	if(spider_awaymission)
		spider_growinstantly = 1
		spider_spawnfrequency = 150

/mob/living/simple_animal/hostile/poison/terror_spider/queen/Life(seconds, times_fired)
	. = ..()
	if(.) // if mob is NOT dead
		if(ckey && canlay < 12 && hasnested) // max 12 eggs worth stored at any one time, realistically that's tons.
			if(world.time > (spider_lastspawn + spider_spawnfrequency))
				if(eggslaid >= 20)
					canlay += 3
				else if(eggslaid >= 10)
					canlay += 2
				else
					canlay++
				spider_lastspawn = world.time
				if(canlay == 1)
					to_chat(src, "<span class='notice'>You have an egg available to lay.</span>")
				else if(canlay == 12)
					to_chat(src, "<span class='notice'>You have [canlay] eggs available to lay. You won't grow any more eggs until you lay some of your existing ones.</span>")
				else
					to_chat(src, "<span class='notice'>You have [canlay] eggs available to lay.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/queen/death(gibbed)
	if(can_die() && !hasdied)
		SetHiveCommand(0, 15) // Hive becomes very aggressive.
		if(spider_uo71)
			UnlockBlastDoors("UO71_Caves")
		// When a queen dies, so do her player-controlled purple-type guardians. Intended as a motivator for purples to ensure they guard her.
		for(var/mob/living/simple_animal/hostile/poison/terror_spider/purple/P in ts_spiderlist)
			if(ckey)
				P.visible_message("<span class='danger'>\The [src] writhes in pain!</span>")
				to_chat(P,"<span class='userdanger'>\The [src] has died. Without her hivemind link, purple terrors like yourself cannot survive more than a few minutes!</span>")
				P.degenerate = 1
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/queen/Retaliate()
	..()
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		T.enemies |= enemies

/mob/living/simple_animal/hostile/poison/terror_spider/queen/proc/ai_nest_is_full()
	var/numspiders = CountSpiders()
	if(numspiders >= spider_max_per_nest)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/poison/terror_spider/queen/handle_automated_action()
	..()
	if(!stat && !ckey && AIStatus != AI_OFF && !target && !path_to_vent)
		switch(neststep)
			if(0)
				// No nest. If current location is eligible for nesting, advance to step 1.
				var/ok_to_nest = 1
				var/area/new_area = get_area(loc)
				if(new_area)
					if(findtext(new_area.name, "hall"))
						ok_to_nest = 0
						// nesting in a hallway would be very stupid - crew would find and kill you almost instantly
				var/numhostiles = 0
				for(var/mob/living/H in oview(10, src))
					if(!istype(H, /mob/living/simple_animal/hostile/poison/terror_spider))
						if(H.stat != DEAD)
							numhostiles += 1
							// nesting RIGHT NEXT TO SOMEONE is even worse
				if(numhostiles > 0)
					ok_to_nest = 0
				var/vdistance = 99
				for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10, src))
					if(!v.welded)
						if(get_dist(src, v) < vdistance)
							entry_vent = v
							vdistance = get_dist(src, v)
				if(!entry_vent)
					ok_to_nest = 0
					// don't nest somewhere with no vent - your brood won't be able to get out!
				if(ok_to_nest && entry_vent)
					nest_vent = entry_vent
					neststep = 1
					visible_message("<span class='danger'>\The [src] settles down, starting to build a nest.</span>")
				else if(entry_vent)
					if(!path_to_vent)
						visible_message("<span class='danger'>\The [src] looks around warily - then seeks a better nesting ground.</span>")
						path_to_vent = 1
				else
					visible_message("<span class='danger'>\The [src] looks around, searching for the vent that should be there, but isn't. A bluespace portal forms on her, and she is gone.</span>")
					qdel(src)
					new /obj/effect/portal(get_turf(loc))
			if(1)
				// No nest, and we should create one. Start NestMode(), then advance to step 2.
				if(world.time > (lastnestsetup + nestfrequency))
					lastnestsetup = world.time
					neststep = 2
					NestMode()
			if(2)
				// Create initial pair of purple nest guards.
				if(world.time > (lastnestsetup + nestfrequency))
					lastnestsetup = world.time
					spider_lastspawn = world.time
					DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple, 2)
					neststep = 3
			if(3)
				// Create spiders (random T1 types) until nest is full.
				if(world.time > (spider_lastspawn + spider_spawnfrequency))
					if(prob(20))
						if(ai_nest_is_full())
							if(spider_awaymission)
								spider_spawnfrequency = spider_spawnfrequency_stable
							neststep = 4
						else
							var/obj/structure/spider/eggcluster/terror_eggcluster/N = locate() in get_turf(src)
							if(!N)
								spider_lastspawn = world.time
								DoLayTerrorEggs(pick(spider_types_standard), 2)
			if(4)
				// Nest should be full. If so, pulse attack command. Otherwise, start replenishing nest (stage 5).
				if(world.time > (spider_lastspawn + spider_spawnfrequency))
					if(prob(20))
						if(ai_nest_is_full())
							SetHiveCommand(0, 15) // AI=0 (attack everyone), ventcrawl=15%/tick
						else
							neststep = 5
			if(5)
				// If already replenished, go idle (stage 4). Otherwise, replenish nest.
				if(world.time > (spider_lastspawn + spider_spawnfrequency))
					if(prob(20))
						if(ai_nest_is_full())
							neststep = 4
						else
							var/obj/structure/spider/eggcluster/terror_eggcluster/N = locate() in get_turf(src)
							if(!N)
								spider_lastspawn = world.time
								var/num_purple = CountSpidersType(/mob/living/simple_animal/hostile/poison/terror_spider/purple)
								var/num_white = CountSpidersType(/mob/living/simple_animal/hostile/poison/terror_spider/white)
								var/num_brown = CountSpidersType(/mob/living/simple_animal/hostile/poison/terror_spider/brown)
								if(num_purple < 4)
									DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple, 2)
								else if(num_white < 2)
									DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/white, 2)
								else if(num_brown < 2)
									DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/brown, 2)
								else
									DoLayTerrorEggs(pick(spider_types_standard), 2)

/mob/living/simple_animal/hostile/poison/terror_spider/queen/proc/NestPrompt()
	var/confirm = alert(src, "Are you sure you want to nest? You will be able to lay eggs, and smash walls, but not ventcrawl.","Nest?","Yes","No")
	if(confirm == "Yes")
		NestMode()

/mob/living/simple_animal/hostile/poison/terror_spider/queen/proc/NestMode()
	queeneggs_action = new()
	queeneggs_action.Grant(src)
	queenfakelings_action = new()
	queenfakelings_action.Grant(src)
	queensense_action = new()
	queensense_action.Grant(src)
	queennest_action.Remove(src)
	hasnested = 1
	ventcrawler = 0
	ai_ventcrawls = 0
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	DoQueenScreech(8, 100, 8, 100)
	MassFlicker()
	to_chat(src, "<span class='notice'>You have matured to your egglaying stage. You can now smash through walls, and lay eggs, but can no longer ventcrawl.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/queen/proc/MassFlicker()
	var/list/target_lights = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.z != z)
			continue
		if(H.stat == DEAD)
			continue
		for(var/obj/machinery/light/L in orange(7, H))
			if(L.on && prob(25))
				target_lights += L
	for(var/obj/machinery/light/I in target_lights)
		I.flicker()

/mob/living/simple_animal/hostile/poison/terror_spider/queen/proc/LayQueenEggs()
	if(stat == DEAD)
		return
	if(!hasnested)
		to_chat(src, "<span class='danger'>You must nest before doing this.</span>")
		return
	if(canlay < 1)
		var/remainingtime = round(((spider_lastspawn + spider_spawnfrequency) - world.time) / 10, 1)
		if(remainingtime > 0)
			to_chat(src, "<span class='danger'>Too soon to attempt that again. Wait another [num2text(remainingtime)] seconds.</span>")
		else
			to_chat(src, "<span class='danger'>Too soon to attempt that again. Wait just a few more seconds...</span>")
		return
	var/list/eggtypes = list(TS_DESC_RED, TS_DESC_GRAY, TS_DESC_GREEN, TS_DESC_BLACK, TS_DESC_PURPLE)
	if(canlay >= 4)
		eggtypes |= TS_DESC_BROWN
	if(canlay >= 12)
		eggtypes |= TS_DESC_MOTHER
		eggtypes |= TS_DESC_PRINCE
	var/num_purples = CountSpidersType(/mob/living/simple_animal/hostile/poison/terror_spider/purple)
	if(num_purples >= 2)
		eggtypes -= TS_DESC_PURPLE
	var/num_blacks = CountSpidersType(/mob/living/simple_animal/hostile/poison/terror_spider/black)
	if(num_blacks >= 2)
		eggtypes -= TS_DESC_BLACK
	var/eggtype = input("What kind of eggs?") as null|anything in eggtypes
	if(!(eggtype in eggtypes))
		to_chat(src, "<span class='danger'>Unrecognized egg type.</span>")
		return 0
	if(eggtype == TS_DESC_MOTHER || eggtype == TS_DESC_PRINCE)
		if(canlay < 12)
			to_chat(src, "<span class='danger'>Insufficient strength. It takes as much effort to lay one of those as it does to lay 12 normal eggs.</span>")
		else
			if(eggtype == TS_DESC_MOTHER)
				canlay -= 12
				DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/mother, 1)
			else if(eggtype == TS_DESC_PRINCE)
				canlay -= 12
				DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/prince, 1)
		return
	else if(eggtype == TS_DESC_BROWN)
		if(canlay < 4)
			to_chat(src, "<span class='danger'>Insufficient strength. It takes as much effort to lay one of those as it does to lay 4 normal eggs.</span>")
		else
			canlay -= 4
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/brown, 1)
		return
	var/numlings = 1
	if(eggtype != TS_DESC_PURPLE)
		if(canlay >= 5)
			numlings = input("How many in the batch?") as null|anything in list(1, 2, 3, 4, 5)
		else if(canlay >= 3)
			numlings = input("How many in the batch?") as null|anything in list(1, 2, 3)
		else if(canlay == 2)
			numlings = input("How many in the batch?") as null|anything in list(1, 2)
	if(eggtype == null || numlings == null)
		to_chat(src, "<span class='danger'>Cancelled.</span>")
		return
	canlay -= numlings
	eggslaid += numlings
	if(eggtype == TS_DESC_RED)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red, numlings)
	else if(eggtype == TS_DESC_GRAY)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/gray, numlings)
	else if(eggtype == TS_DESC_GREEN)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green, numlings)
	else if(eggtype == TS_DESC_BLACK)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black, numlings)
	else if(eggtype == TS_DESC_PURPLE)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple, numlings)
	else
		to_chat(src, "<span class='danger'>Unrecognized egg type.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/queen/proc/DoQueenScreech(light_range, light_chance, camera_range, camera_chance)
	visible_message("<span class='userdanger'>\The [src] emits a bone-chilling shriek!</span>")
	for(var/obj/machinery/light/L in orange(light_range, src))
		if(L.on && prob(light_chance))
			L.broken()
	for(var/obj/machinery/camera/C in orange(camera_range, src))
		if(C.status && prob(camera_chance))
			C.toggle_cam(src, 0)

/mob/living/simple_animal/hostile/poison/terror_spider/queen/proc/QueenFakeLings()
	if(eggslaid < 10)
		to_chat(src, "<span class='danger'>You must lay at least 10 eggs before doing this.</span>")
		return
	if(spider_can_fakelings)
		spider_can_fakelings--
		var/numlings = 25
		for(var/i in 1 to numlings)
			var/obj/structure/spider/spiderling/terror_spiderling/S = new /obj/structure/spider/spiderling/terror_spiderling(get_turf(src))
			S.grow_as = /mob/living/simple_animal/hostile/poison/terror_spider/red
			S.stillborn = 1
			S.spider_mymother = src
		if(!spider_can_fakelings)
			queenfakelings_action.Remove(src)
	else
		to_chat(src, "<span class='danger'>You have run out of uses of this ability.</span>")

/obj/item/projectile/terrorqueenspit
	name = "poisonous spit"
	damage = 0
	icon_state = "toxin"
	damage_type = TOX
	var/bonus_tox = 30

/obj/item/projectile/terrorqueenspit/on_hit(mob/living/carbon/target)
	if(ismob(target))
		var/mob/living/L = target
		if(L.reagents)
			if(L.can_inject(null, 0, "chest", 0))
				L.Hallucinate(400)
		if(!isterrorspider(L))
			L.adjustToxLoss(bonus_tox)

/obj/structure/spider/terrorweb/queen
	name = "shimmering web"
	desc = "This web seems to shimmer all different colors in the light."

/obj/structure/spider/terrorweb/queen/web_special_ability(mob/living/carbon/C)
	if(istype(C))
		var/inject_target = pick("chest","head")
		if(C.can_inject(null, 0, inject_target, 0))
			C.Hallucinate(400)
			C.adjustToxLoss(30)
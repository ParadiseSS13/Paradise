// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T5 EMPRESS OF TERROR -------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ruling over planets of uncountable spiders, like Xenomorph Empresses.
// -------------: AI: none - this is strictly adminspawn-only and intended for RP events, coder testing, and teaching people 'how to queen'
// -------------: SPECIAL: Lay Eggs ability that allows laying queen-level eggs.
// -------------: TO FIGHT IT: run away screaming?
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress
	name = "Empress of Terror"
	desc = "The unholy offspring of spiders, nightmares, and lovecraft fiction."
	spider_role_summary = "Adminbus spider"
	ai_target_method = TS_DAMAGE_SIMPLE
	maxHealth = 1000
	health = 1000
	melee_damage_lower = 30
	melee_damage_upper = 60
	move_to_delay = 5
	ventcrawler = 1
	idle_ventcrawl_chance = 0
	ai_playercontrol_allowtype = 0
	ai_type = TS_AI_AGGRESSIVE
	rapid = 1
	canlay = 1000
	spider_tier = TS_TIER_5
	projectiletype = /obj/item/projectile/terrorqueenspit/empress
	var/datum/action/innate/terrorspider/queen/empress/empresslings/empresslings_action
	var/datum/action/innate/terrorspider/queen/empress/empresserase/empresserase_action
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/New()
	..()
	empresserase_action = new()
	empresserase_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/handle_automated_action()
	return

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/NestMode()
	..()
	queeneggs_action.button.name = "Empress Eggs"
	queenfakelings_action.button.name = "Empress Lings"

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/LayQueenEggs()
	var/eggtype = input("What kind of eggs?") as null|anything in list(TS_DESC_QUEEN, TS_DESC_MOTHER, TS_DESC_PRINCE, TS_DESC_RED, TS_DESC_GRAY, TS_DESC_GREEN, TS_DESC_BLACK, TS_DESC_PURPLE, TS_DESC_WHITE)
	var/numlings = input("How many in the batch?") as null|anything in list(1, 2, 3, 4, 5, 10, 15, 20, 30, 40, 50)
	if(eggtype == null || numlings == null)
		to_chat(src, "<span class='danger'>Cancelled.</span>")
		return
	switch(eggtype)
		if(TS_DESC_RED)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red,numlings,1)
		if(TS_DESC_GRAY)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/gray,numlings,1)
		if(TS_DESC_GREEN)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green,numlings,1)
		if(TS_DESC_BLACK)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black,numlings,1)
		if(TS_DESC_PURPLE)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple,numlings,0)
		if(TS_DESC_WHITE)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/white,numlings,0)
		if(TS_DESC_PRINCE)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/prince,numlings,1)
		if(TS_DESC_MOTHER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/mother,numlings,1)
		if(TS_DESC_QUEEN)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/queen,numlings,1)
		else
			to_chat(src, "<span class='danger'>Unrecognized egg type.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/QueenFakeLings()
	var/numlings = input("How many?") as null|anything in list(10, 20, 30, 40, 50)
	var/sbpc = input("%chance to be stillborn?") as null|anything in list(0, 25, 50, 75, 100)
	for(var/i=0, i<numlings, i++)
		var/obj/structure/spider/spiderling/terror_spiderling/S = new /obj/structure/spider/spiderling/terror_spiderling(get_turf(src))
		S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, \
		/mob/living/simple_animal/hostile/poison/terror_spider/gray, \
		/mob/living/simple_animal/hostile/poison/terror_spider/green, \
		/mob/living/simple_animal/hostile/poison/terror_spider/white, \
		/mob/living/simple_animal/hostile/poison/terror_spider/black)
		S.spider_myqueen = spider_myqueen
		if(prob(sbpc))
			S.stillborn = 1
		if(spider_growinstantly)
			S.amount_grown = 250

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/proc/EraseBrood()
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if(T.spider_tier < spider_tier)
			T.degenerate = 1
			to_chat(T, "<span class='userdanger'>Through the hivemind, the raw power of [src] floods into your body, burning it from the inside out!</span>")
	for(var/obj/structure/spider/eggcluster/terror_eggcluster/T in ts_egg_list)
		qdel(T)
	for(var/obj/structure/spider/spiderling/terror_spiderling/T in ts_spiderling_list)
		T.stillborn = 1
	to_chat(src, "<span class='userdanger'>All Terror Spiders, except yourself, will die off shortly.</span>")


/obj/item/projectile/terrorqueenspit/empress
	damage_type = BURN
	damage = 30
	bonus_tox = 0
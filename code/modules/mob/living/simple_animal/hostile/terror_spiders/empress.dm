
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T5 EMPRESS OF TERROR -------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ruling over planets of uncountable spiders, like Xenomorph Empresses.
// -------------: AI: none - this is strictly adminspawn-only and intended for RP events, coder testing, and teaching people 'how to queen'
// -------------: SPECIAL: Lay Eggs ability that allows laying queen-level eggs. Wide-area EMP and light-breaking abilities.
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
	var/phasing = 0

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/handle_automated_action()
	return

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/verb/LayEmpressEggs()
	set name = "Lay Empress Eggs"
	set category = "Spider"
	set desc = "Lay spider eggs. As empress, you can lay queen-level eggs to create a new brood."
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

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/verb/EmpressScreech()
	set name = "Empress Screech"
	set category = "Spider"
	set desc = "Emit horrendusly loud screech which breaks lights and cameras in a massive radius. Good for making a spider nest in a pinch."
	for(var/obj/machinery/light/L in range(14, src))
		if(L.on)
			L.broken()
	for(var/obj/machinery/camera/C in range(14, src))
		if(C.status)
			C.toggle_cam(src, 0)

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/verb/EmpressToggleDebug()
	set name = "Toggle Debug"
	set category = "Spider"
	set desc = "Enables/disables debug mode for spiders."
	if(spider_debug)
		spider_debug = 0
		to_chat(src, "<span class='danger'>Debug: DEBUG MODE is now <b>OFF</b> for all spiders in the world.</span>")
	else
		spider_debug = 1
		to_chat(src, "<span class='danger'>Debug: DEBUG MODE is now <b>ON</b> for all spiders in the world.</span>")
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		T.spider_debug = spider_debug

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/verb/EmpressToggleInstant()
	set name = "Toggle Instant"
	set category = "Spider"
	set desc = "Enables/disables instant growth for spiders."
	if(spider_growinstantly)
		spider_growinstantly = 0
		to_chat(src, "<span class='danger'>Debug: INSTANT GROWTH is now <b>OFF</b> for all spiders in the world.</span>")
	else
		spider_growinstantly = 1
		to_chat(src, "<span class='danger'>Debug: INSTANT GROWTH is now <b>ON</b> for all spiders in the world.</span>")
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		T.spider_growinstantly = spider_growinstantly

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/verb/EmpressKillSpider()
	set name = "Erase Spider"
	set category = "Spider"
	set desc = "Kills a spider. If they are player-controlled, also bans them from controlling any other spider for the rest of the round."
	var/choices = list()
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/L in ts_spiderlist)
		if(L == src)
			continue
		if(L.stat == DEAD)
			continue
		choices += L
	var/killtarget = input(src, "Which terror spider should die?") in null|choices
	if(!killtarget)
		return
	else if(!isliving(killtarget))
		to_chat(src, "[killtarget] is not living.")
	else if(!istype(killtarget, /mob/living/simple_animal/hostile/poison/terror_spider))
		to_chat(src, "[killtarget] is not a terror spider.")
	else
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = killtarget
		if(T.ckey)
			// living player
			ts_ckey_blacklist += T.ckey
		to_chat(T, "<span class='userdanger'>Through the hivemind, the raw power of [src] floods into your body, burning it from the inside out!</span>")
		T.gib()

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/verb/EraseBrood()
	set name = "Erase Brood"
	set category = "Spider"
	set desc = "Debug: kill off all other spiders in the world. Takes two minutes to work."
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if(T.spider_tier < spider_tier)
			T.degenerate = 1
			to_chat(T, "<span class='userdanger'>Through the hivemind, the raw power of [src] floods into your body, burning it from the inside out!</span>")
	for(var/obj/effect/spider/eggcluster/terror_eggcluster/T in ts_egg_list)
		qdel(T)
	for(var/obj/effect/spider/spiderling/terror_spiderling/T in ts_spiderling_list)
		T.stillborn = 1
	to_chat(src, "<span class='userdanger'>Brood will die off shortly.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/verb/SpiderlingFlood()
	set name = "Spiderling Flood"
	set category = "Spider"
	set desc = "Debug: Spawns N spiderlings. They grow into random spider types (red/green/gray/white/black). Pure horror!"
	var/numlings = input("How many?") as null|anything in list(10, 20, 30, 40, 50)
	var/sbpc = input("%chance to be stillborn?") as null|anything in list(0, 25, 50, 75, 100)
	for(var/i=0, i<numlings, i++)
		var/obj/effect/spider/spiderling/terror_spiderling/S = new /obj/effect/spider/spiderling/terror_spiderling(get_turf(src))
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

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/verb/PhaseShift()
	set name = "Phase Shift"
	set category = "Spider"
	set desc = "Debug: Turns you semi-visible and intangible."
	phasing = !phasing
	if(phasing)
		visible_message("<span class='danger'>[src] steps into a bluespace portal!</span>", "<span class='terrorspider'>You step into the realm of nightmares.</span>")
		incorporeal_move = 1
		alpha = 0
	else
		visible_message("<span class='danger'>[src] steps out of a bluespace portal!</span>", "<span class='terrorspider'>You return from the realm of nightmares.</span>")
		incorporeal_move = 0
		alpha = 255
	new /obj/effect/effect/bad_smoke(loc)
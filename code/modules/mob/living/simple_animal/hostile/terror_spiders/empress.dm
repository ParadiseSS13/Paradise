
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T5 EMPRESS OF TERROR -------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ruling over planets of uncountable spiders, like Xenomorph Empresses.
// -------------: AI: none - this is strictly adminspawn-only and intended for RP events, coder testing, and teaching people 'how to queen'
// -------------: SPECIAL: Lay Eggs ability that allows laying queen-level eggs. Wide-area EMP and light-breaking abilities.
// -------------: TO FIGHT IT: run away screaming?
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/EldritchAbomination
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/BiggerBad
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/AuthorityEqualsAsskicking
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/empress
	name = "Empress of Terror"
	desc = "The unholy offspring of spiders, nightmares, and lovecraft fiction."
	spider_role_summary = "Adminbus spider"
	altnames = list ("Terror Empress spider")
	egg_name = "empress spider eggs"

	icon_state = "terror_queen"
	icon_living = "terror_queen"
	icon_dead = "terror_queen_dead"

	maxHealth = 1000
	health = 1000

	melee_damage_lower = 10
	melee_damage_upper = 40

	move_to_delay = 5
	ventcrawler = 1 // Adminbus.

	idle_ventcrawl_chance = 0
	ai_playercontrol_allowtype = 0
	ai_type = 1 // defend self only!

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/pierce.ogg'
	projectiletype = /obj/item/projectile/terrorempressspit
	force_threshold = 18 // same as queen, but a lot more health

	spider_tier = 5
	spider_opens_doors = 2

	var/shown_guide = 0 // has the empress player been warned of the chaos that can result from the use of their powers?

	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID


/mob/living/simple_animal/hostile/poison/terror_spider/empress/New()
	..()
	spawn(600)
		if (!ckey)
			// idea being that if someone spawns her, and she isn't player controlled within 60 seconds, it was probably a mistake and she should be despawned.
			visible_message("[src] steps into a bluespace portal, and is gone!")
			qdel(src)

/mob/living/simple_animal/hostile/poison/terror_spider/empress/Life()
	if (stat != DEAD)
		if (ckey && !shown_guide)
			shown_guide = 1
			ShowGuide()
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/LayEmpressEggs()
	set name = "Lay Empress Eggs"
	set category = "Spider"
	set desc = "Lay spider eggs. As empress, you can lay queen-level eggs to create a new brood."
	var/eggtype = input("What kind of eggs?") as null|anything in list("QUEEN", "MOTHER", "PRINCE", "red - assault","gray - ambush", "green - nurse", "black - poison","purple - guard")
	var/numlings = input("How many in the batch?") as null|anything in list(1,2,3,4,5,10,15,20,30,40,50)
	if (eggtype == null || numlings == null)
		to_chat(src, "Cancelled.")
		return
	// T1
	if (eggtype == "red - assault")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red,numlings,1)
	else if (eggtype == "gray - ambush")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/gray,numlings,1)
	else if (eggtype == "green - nurse")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green,numlings,1)
	// T2
	else if (eggtype == "black - poison")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black,numlings,1)
	else if (eggtype == "purple - guard")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple,numlings,0)
	// T3
	else if (eggtype == "PRINCE")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/prince,numlings,1)
	else if (eggtype == "MOTHER")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/mother,numlings,1)
	else if (eggtype == "QUEEN")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/queen,numlings,1)
	// Unrecognized
	else
		to_chat(src, "Unrecognized egg type.")

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/HiveSense()
	set name = "Hive Sense"
	set category = "Spider"
	set desc = "Sense the spiders at your command."
	DoHiveSense()

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/HiveCommand()
	set name = "Hive Command"
	set category = "Spider"
	set desc = "Instruct your brood on proper behavior."
	DialogHiveCommand()

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EMPShockwave()
	set name = "EMP Shockwave"
	set category = "Spider"
	set desc = "Emit a wide-area emp pulse, frying almost all electronics in a huge radius."
	empulse(loc,10,25)


/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressScreech()
	set name = "Empress Screech"
	set category = "Spider"
	set desc = "Emit horrendusly loud screech which breaks lights and cameras in a massive radius. Good for making a spider nest in a pinch."
	for(var/obj/machinery/light/L in range(14,src))
		if (L.on)
			L.broken()
	for(var/obj/machinery/camera/C in range(14,src))
		if (C.status)
			C.toggle_cam(src,0)


/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressMassHallucinate()
	set name = "Mass Hallucinate"
	set category = "Spider"
	set desc = "Causes widespread, terrifying hallucinations amongst many crew as you assault their minds."
	var/numaffected = 0
	for(var/mob/living/carbon/human/H in player_list)
		if (H.z != z)
			continue
		if (H.health < 1 || prob(50))
			continue
		H.hallucination = max(300, H.hallucination)
		if (prob(50))
			H.hallucination = max(600, H.hallucination)
		to_chat(H,"<span class='userdanger'>Your head hurts! </span>")
		numaffected++
	if (numaffected)
		to_chat(src, "You reach through bluespace into the minds of [numaffected] crew, making their fears come to life. They start to hallucinate.")
	else
		to_chat(src, "You reach through bluespace, searching for organic minds... but find none nearby.")


/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressToggleDebug()
	set name = "Toggle Debug"
	set category = "Spider"
	set desc = "Enables/disables debug mode for spiders."
	if (spider_debug)
		spider_debug = 0
		to_chat(src, "Debug: DEBUG MODE is now <b>OFF</b> for all spiders in world.")
	else
		spider_debug = 1
		to_chat(src, "Debug: DEBUG MODE is now <b>ON</b> for all spiders in world.")
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
		T.spider_debug = spider_debug

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressToggleInstant()
	set name = "Toggle Instant"
	set category = "Spider"
	set desc = "Enables/disables instant growth for spiders."
	if (spider_growinstantly)
		spider_growinstantly = 0
		to_chat(src, "Debug: INSTANT GROWTH is now <b>OFF</b> for all spiders in world.")
	else
		spider_growinstantly = 1
		to_chat(src, "Debug: INSTANT GROWTH is now <b>ON</b> for all spiders in world.")
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
		T.spider_growinstantly = spider_growinstantly

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressKillSpider()
	set name = "Erase Spider"
	set category = "Spider"
	set desc = "Kills a spider. If they are player-controlled, also bans them from controlling any other spider for the rest of the round."
	var/choices = list()
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/L in mob_list)
		if(L == src)
			continue
		if (L.health < 1)
			continue
		choices += L
	var/killtarget = input(src,"Which terror spider should die?") in null|choices
	if (!killtarget)
		// cancel
	else if (!isliving(killtarget))
		to_chat(src, "[killtarget] is not living.")
	else if (!istype(killtarget, /mob/living/simple_animal/hostile/poison/terror_spider/))
		to_chat(src, "[killtarget] is not a terror spider.")
	else
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = killtarget
		if (T.ckey)
			// living player
			ts_ckey_blacklist += T.ckey
		to_chat(T, "<span class='userdanger'> Through the hivemind, the raw power of [src] floods into your body, burning it from the inside out! </span>")
		T.death()
		T.gib()

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EraseBrood()
	set name = "Erase Brood"
	set category = "Spider"
	set desc = "Debug: kill off all other spiders in the world. Takes two minutes to work."
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
		if (T.spider_tier < 5)
			T.degenerate = 1
			T.loot = 0
			to_chat(T, "<span class='userdanger'> Through the hivemind, the raw power of [src] floods into your body, burning it from the inside out! </span>")
	for(var/obj/effect/spider/terror_eggcluster/T in world)
		qdel(T)
	for(var/obj/effect/spider/terror_spiderling/T in world)
		T.stillborn = 1
	to_chat(src, "Brood will die off shortly.")

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/SpiderlingFlood()
	set name = "Spiderling Flood"
	set category = "Spider"
	set desc = "Debug: Spawns N spiderlings. They grow into random spider types (red/green/gray/white/black). Pure horror!"
	var/numlings = input("How many?") as null|anything in list(10,20,30,40,50)
	var/sbpc = input("%chance to be stillborn?") as null|anything in list(0,25,50,75,100)
	for(var/i=0, i<numlings, i++)
		var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
		S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray, /mob/living/simple_animal/hostile/poison/terror_spider/green, /mob/living/simple_animal/hostile/poison/terror_spider/white, /mob/living/simple_animal/hostile/poison/terror_spider/black)
		S.spider_myqueen = spider_myqueen
		if (prob(sbpc))
			S.stillborn = 1
		if (spider_growinstantly)
			S.amount_grown = 250


/mob/living/simple_animal/hostile/poison/terror_spider/empress/death(gibbed)
	if (!hasdroppedloot)
		var/obj/item/clothing/accessory/medal/M = new /obj/item/clothing/accessory/medal/gold/heroism(get_turf(src))
		M.layer = 4.1
	..()

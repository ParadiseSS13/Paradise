
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 WHITE TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: stealthy reproduction
// -------------: AI: injects a venom that makes you grow spiders in your body, then retreats
// -------------: SPECIAL: stuns you on first attack - vulnerable to groups while it does this
// -------------: TO FIGHT IT: blast it before it can get away
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/BodyHorror
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/white
	name = "White Death spider"
	desc = "An ominous-looking white spider, its ghostly eyes and vicious-looking fangs are the stuff of nightmares."
	spider_role_summary = "Rare, bite-and-run spider that infects hosts with spiderlings"
	egg_name = "white spider eggs"

	altnames = list("White Terror spider","White Death spider","Ghostly Nightmare spider")
	icon_state = "terror_white"
	icon_living = "terror_white"
	icon_dead = "terror_white_dead"
	maxHealth = 100
	health = 100
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 4
	ventcrawler = 1
	spider_tier = 2
	loot = list(/obj/item/clothing/accessory/medal)

/mob/living/simple_animal/hostile/poison/terror_spider/white/LoseTarget()
	stop_automated_movement = 0
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/white/death(gibbed)
	if (!hasdroppedloot)
		if (spider_uo71)
			UnlockBlastDoors("UO71_Bridge", "UO71 Bridge is now unlocked!")
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/white/harvest()
	if (!spider_awaymission)
		new /obj/item/weapon/reagent_containers/terrorspider_parts/toxgland_white(get_turf(src))
	gib()


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 PURPLE TERROR -----------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: guarding queen nests
// -------------: AI: returns to queen if too far from her.
// -------------: SPECIAL: chance to stun on hit
// -------------: TO FIGHT IT: shoot it from range, bring friends!
// -------------: CONCEPT:http://tvtropes.org/pmwiki/pmwiki.php/Main/PraetorianGuard
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/purple
	name = "Praetorian spider"
	desc = "An ominous-looking purple spider."
	spider_role_summary = "Guards the nest of the Queen of Terror."
	egg_name = "purple spider eggs"
	altnames = list("Nest Guardian spider")

	icon_state = "terror_purple"
	icon_living = "terror_purple"
	icon_dead = "terror_purple_dead"
	maxHealth = 300
	health = 300
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 6
	idle_ventcrawl_chance = 0 // stick to the queen!
	spider_tier = 2

	ai_ventcrawls = 0


/mob/living/simple_animal/hostile/poison/terror_spider/purple/death(gibbed)
	if (spider_myqueen)
		var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q = spider_myqueen
		if (Q.health > 0 && !Q.ckey)
			if (get_dist(src,Q) > 20)
				if (!degenerate && !Q.degenerate)
					degenerate = 1
					Q.DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple,1,0)
					visible_message("<span class='notice'> [src] chitters in the direction of [Q]!</span>")
	..()

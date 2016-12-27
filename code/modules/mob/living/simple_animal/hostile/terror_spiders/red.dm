

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 RED TERROR --------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: generic attack spider
// -------------: AI: uses very powerful fangs to wreck people in melee
// -------------: SPECIAL: the more you hurt it, the harder it bites you
// -------------: TO FIGHT IT: shoot it from range. Kite it.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/MightyGlacier
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/red
	name = "Red Terror spider"
	desc = "An ominous-looking red spider, it has eight beady red eyes, and nasty, big, pointy fangs!"
	altnames = list("Red Terror spider", "Crimson Terror spider", "Bloody Butcher spider")
	egg_name = "red spider eggs"

	spider_role_summary = "High health, high damage, very slow, melee juggernaut"
	ai_target_method = TS_DAMAGE_BRUTE

	icon_state = "terror_red"
	icon_living = "terror_red"
	icon_dead = "terror_red_dead"
	maxHealth = 200
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 20
	spider_opens_doors = 2
	var/enrage = 0
	var/melee_damage_lower_rage0 = 15
	var/melee_damage_upper_rage0 = 20
	var/melee_damage_lower_rage1 = 15
	var/melee_damage_upper_rage1 = 35
	var/melee_damage_lower_rage2 = 35
	var/melee_damage_upper_rage2 = 40


/mob/living/simple_animal/hostile/poison/terror_spider/red/AttackingTarget()
	if(enrage == 0)
		if(health < maxHealth)
			enrage = 1
			visible_message("<span class='danger'>[src] growls, flexing its fangs!</span>")
			melee_damage_lower = melee_damage_lower_rage1
			melee_damage_upper = melee_damage_upper_rage1
	else if(enrage == 1)
		if(health == maxHealth)
			enrage = 0
			visible_message("<span class='notice'>[src] retracts its fangs a little.</span>")
			melee_damage_lower = melee_damage_lower_rage0
			melee_damage_upper = melee_damage_upper_rage0
		else if(health < (maxHealth/2))
			enrage = 2
			visible_message("<span class='danger'>[src] growls, spreading its fangs wide!</span>")
			melee_damage_lower = melee_damage_lower_rage2
			melee_damage_upper = melee_damage_upper_rage2
	else if(enrage == 2)
		if(health > (maxHealth/2))
			enrage = 1
			visible_message("<span class='notice'>[src] retracts its fangs a little.</span>")
			melee_damage_lower = melee_damage_lower_rage0
			melee_damage_upper = melee_damage_upper_rage0
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/red/ShowGuide()
	..()
	var/guidetext = "<BR>RED TERROR guide:"
	guidetext += "<BR>- A straightforward fighter, you have high health, and high melee damage, but are very slow-moving."
	guidetext += "<BR>- You are best at taking out slow, armored foes. Be careful not to get kited with ranged weapons."
	guidetext += "<BR>- You can take a lot of hits, so don't be afraid to act as the tank in a group."
	to_chat(src, guidetext)
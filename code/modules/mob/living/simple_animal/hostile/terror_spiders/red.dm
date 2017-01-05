

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 RED TERROR --------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: generic attack spider
// -------------: AI: uses very powerful fangs to wreck people in melee
// -------------: SPECIAL: the more you hurt it, the harder it bites you
// -------------: TO FIGHT IT: shoot it from range. Kite it.
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/red
	name = "Red Terror spider"
	desc = "An ominous-looking red spider, it has eight beady red eyes, and nasty, big, pointy fangs! It looks like it has a vicious streak a mile wide."

	spider_role_summary = "High health, high damage, very slow, melee juggernaut"

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



// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 KNIGHT TERROR --------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: generic attack spider
// -------------: AI: uses very powerful fangs to wreck people in melee
// -------------: SPECIAL: the more you hurt it, the harder it bites you
// -------------: TO FIGHT IT: shoot it from range. Kite it.
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/knight
	name = "Knight of Terror"
	desc = "An ominous-looking red spider, it has eight beady red eyes, and nasty, big, pointy fangs! It looks like it has a vicious streak a mile wide."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_red"
	icon_living = "terror_red"
	icon_dead = "terror_red_dead"
	maxHealth = 230
	health = 230
	heal_per_kill = 230
	melee_damage_lower = 25
	melee_damage_upper = 30
	obj_damage = 60
	attack_sound = 'sound/creatures/terrorspiders/bite2.ogg'
	death_sound = 'sound/creatures/terrorspiders/death1.ogg'
	armour_penetration = 10
	move_to_delay = 10 // at 20ticks/sec, this is 2 tile/sec movespeed
	speed = 0.5
	spider_opens_doors = 2
	move_resist = MOVE_FORCE_STRONG // no more pushing a several hundred if not thousand pound spider
	web_type = /obj/structure/spider/terrorweb/knight
	spider_intro_text = "Будучи Рыцарем Ужаса, ваша задача - создавать места для прорыва, или же оборонять гнездо. Несмотря на медлительность, вы живучи и опасны вблизи, используйте свою силу и выносливость, чтобы другие пауки могли выполнять свои функции!"
	gender = MALE
	var/enrage = 0
	var/melee_damage_lower_rage0 = 15
	var/melee_damage_upper_rage0 = 20
	var/melee_damage_lower_rage1 = 15
	var/melee_damage_upper_rage1 = 35
	var/melee_damage_lower_rage2 = 35
	var/melee_damage_upper_rage2 = 40

/mob/living/simple_animal/hostile/poison/terror_spider/knight/AttackingTarget()
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
			melee_damage_lower = melee_damage_lower_rage1
			melee_damage_upper = melee_damage_upper_rage1
	return ..()


/obj/structure/spider/terrorweb/knight
	max_integrity = 30
	name = "reinforced web"
	desc = "This web is reinforced with extra strands, for added strength."

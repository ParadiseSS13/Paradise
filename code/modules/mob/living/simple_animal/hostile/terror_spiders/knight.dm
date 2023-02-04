

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
	maxHealth = 200
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 19
	obj_damage = 60
	environment_smash = 2
	attack_sound = 'sound/creatures/terrorspiders/bite2.ogg'
	death_sound = 'sound/creatures/terrorspiders/death1.ogg'
	armour_penetration = 10
	move_to_delay = 10 // at 20ticks/sec, this is 2 tile/sec movespeed
	speed = 0.8
	spider_opens_doors = 2
	ventcrawler = 0
	move_resist = MOVE_FORCE_STRONG // no more pushing a several hundred if not thousand pound spider
	web_type = /obj/structure/spider/terrorweb/knight
	spider_intro_text = "Будучи Рыцарем Ужаса, ваша задача - создавать места для прорыва, или же оборонять гнездо. Несмотря на медлительность, вы живучи и опасны вблизи, используйте свою силу и выносливость, чтобы другие пауки могли выполнять свои функции! Ваши способности позволяют вам переключаться между режимом атаки и обороны, первый - увеличивает скорость, а также наносимый и получаемый урон, второй - уменьшает скорость, получаемый и наносимый урон."
	gender = MALE
	var/last_attack_mode = 0
	var/last_defence_mode = 0
	var/attack_mode_av = 1
	var/defence_mode_av = 1
	var/last_mode = 0
	var/current_mode = 0
	var/mode_cooldown = 300
	var/mode_duration = 100
	var/datum/action/innate/terrorspider/knight/defaultm/defaultmaction
	var/datum/action/innate/terrorspider/knight/attackm/attackmaction
	var/datum/action/innate/terrorspider/knight/defencem/defencemaction

/mob/living/simple_animal/hostile/poison/terror_spider/knight/New()
	..()
	attackmaction = new()
	attackmaction.Grant(src)
	defencemaction = new()
	defencemaction.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/knight/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD) // Can't use if(.) for this due to the fact it can sometimes return FALSE even when mob is alive.
		if(ckey)
			if (current_mode)
				if (world.time > (last_mode + mode_duration))
					activate_mode(0)
			if(world.time > (last_attack_mode + mode_cooldown))
				attack_mode_av = 1
			if(world.time > (last_defence_mode + mode_cooldown))
				defence_mode_av = 1

//MODE CHANGING. Knight has 3 modes, first - default, always active. Second - attack, grants increased speed and damage, but also increases damage you recieve.
//Third - defence, grants even slower movement speed then default, but you recieve much less damage.
//Both attack and defence mod lasts for 10 seconds and has a cd of 30. When you are out of non default modes your mode is set to default.
/mob/living/simple_animal/hostile/poison/terror_spider/knight/proc/activate_mode(n)
	var/t = world.time
	if	(n==0)
		playsound(src, 'sound/creatures/terrorspiders/mod_defence_out.ogg', 100)
		to_chat(src, "<span class='notice'>You are now in default mode</span>")
		speed = 0.8
		damage_coeff = list(BRUTE = 0.9, BURN = 1.2, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 2)
		melee_damage_lower = 15
		melee_damage_upper = 19
		current_mode = 0
		return 1
	if	(n==1)
		if(attack_mode_av)
			last_attack_mode = t
			last_mode = t
			attack_mode_av = 0
			playsound(src, 'sound/creatures/terrorspiders/mod_attack_out.ogg', 100)
			to_chat(src, "<span class='notice'>You are now in attack mode</span>")
			speed = 0
			damage_coeff = list(BRUTE = 1.2, BURN = 1.4, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 2)
			melee_damage_lower = 30
			melee_damage_upper = 35
			src.adjustBruteLoss(50)
			current_mode = 1
			return 1
		to_chat(src, "<span class='notice'>You cant do this yet!</span>")
		return 0
	if	(n==2)
		if(defence_mode_av)
			last_defence_mode = t
			last_mode = t
			defence_mode_av = 0
			playsound(src, 'sound/creatures/terrorspiders/mod_defence.ogg', 100)
			to_chat(src, "<span class='notice'>You are now in defence mode</span>")
			speed = 1.6
			damage_coeff = list(BRUTE = 0.6, BURN = 0.8, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 2)
			melee_damage_lower = 10
			melee_damage_upper = 15
			current_mode = 2
			return 1
		to_chat(src, "<span class='notice'>You cant do this yet!</span>")
		return 0

/obj/structure/spider/terrorweb/knight
	max_integrity = 30
	name = "reinforced web"
	desc = "This web is reinforced with extra strands, for added strength."

/mob/living/simple_animal/hostile/poison/terror_spider/knight/spider_specialattack(mob/living/carbon/human/L)
	if(L.stat != DEAD)
		L.adjustStaminaLoss(15) //8 hits for stamcrit
		L.attack_animal(src)
	else
		..()

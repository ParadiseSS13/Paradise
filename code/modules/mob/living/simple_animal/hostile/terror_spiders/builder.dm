

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 BUILDER TERROR --------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: similar to alien drona
// -------------: AI: wraps web, protects hive
// -------------: SPECIAL: wraps web realy fast
// -------------: TO FIGHT IT: shoot it from range. Kite it.

/mob/living/simple_animal/hostile/poison/terror_spider/builder
	name = "Drone of Terror"
	desc = "An ominous-looking spider, he appears to be heavy despite size."
	gender = MALE
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_drone"
	icon_living = "terror_drone"
	icon_dead = "terror_drone_dead"
	maxHealth = 80
	health = 80
	regeneration = 0
	delay_web = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_WALLS
	spider_opens_doors = 2
	ranged = 1
	rapid = 2
	ranged_cooldown_time = 25
	speed = 1
	projectilesound = 'sound/creatures/terrorspiders/spit3.ogg'
	projectiletype = /obj/item/projectile/terrorspider/builder
	web_type = /obj/structure/spider/terrorweb/queen/builder
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
	ventcrawler = 0
	can_wrap = FALSE
	spider_intro_text = "Будучи Дроном Ужаса, ваша задача - постройка и защита гнезда. Плетите паутину, используйте свои замедляющие плевки и замораживающие укусы для защиты яиц и гнезда. Помните, вы не регенерируете и двигаетесь медленно вне паутины!."

/mob/living/simple_animal/hostile/poison/terror_spider/builder/spider_specialattack(mob/living/carbon/human/L, poisonable)
	L.slowed = 2
	if(!poisonable)
		return ..()
	if(L.reagents.has_reagent("frostoil", 100))
		return ..()
	var/inject_target = pick("chest", "head")
	if(L.stunned || L.can_inject(null, FALSE, inject_target, FALSE))
		L.reagents.add_reagent("frostoil", 20)
		visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [target]!</span>")
	else
		L.reagents.add_reagent("frostoil", 10)
		visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [target]!</span>")
	L.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/builder/Move(atom/newloc, dir, step_x, step_y)  //moves slow while not in web, but fast while in. does not regenerate if not in web
	. = ..()
	var/obj/structure/spider/terrorweb/W = locate() in get_turf(src)
	if(W)
		if(speed == 1)
			speed = -0.2
			regeneration = 3
	else if(speed != 1)
		regeneration = 0
		speed = 1

/obj/structure/spider/terrorweb/queen/builder
	max_integrity = 30
	opacity = 1
	name = "drone web"
	desc = "Extremely thick web."

/obj/item/projectile/terrorspider/builder
	name = "drone venom"
	icon_state = "toxin2"
	damage = 17
	stamina = 17

/obj/item/projectile/terrorspider/drone/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.slowed = 1

	return ..()

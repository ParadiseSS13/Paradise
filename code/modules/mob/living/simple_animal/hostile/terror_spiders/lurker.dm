
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 LURKER TERROR -------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ambusher
// -------------: AI: hides in vents, emerges when prey is near to kill it, then hides again. Intended to scare normal crew.
// -------------: SPECIAL: invisible when on top of a vent, emerges when prey approaches or gets trapped in webs.
// -------------: TO FIGHT IT: shoot it through a window, or make it regret ambushing you
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/lurker
	name = "Lurker of Terror"
	desc = "An ominous-looking gray spider. It seems to blend into webs, making it hard to see."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_gray"
	icon_living = "terror_gray"
	icon_dead = "terror_gray_dead"
	maxHealth = 100
	health = 100
	death_sound = 'sound/creatures/terrorspiders/death5.ogg'
	speed = -0.3
	melee_damage_lower = 15
	melee_damage_upper = 15
	armour_penetration = 2
	stat_attack = UNCONSCIOUS // ensures they will target people in crit, too!
	delay_web = 10
	web_type = /obj/structure/spider/terrorweb/gray
	special_abillity = list(/obj/effect/proc_holder/spell/terror_stealth)
	spider_intro_text = "Будучи Наблюдателем Ужаса, ваша задача - устраивать засады. Вы почти невидимы в паутине, и наносите сокрушительный урон, пробивающий броню, если находитесь в ней. Вы также можете стать полностью невидимым на короткий промежуток времени."
	ai_spins_webs = FALSE // uses massweb instead
	tts_seed = "Cassiopeia"
	var/prob_ai_massweb = 10

/mob/living/simple_animal/hostile/poison/terror_spider/lurker/Move(atom/newloc, dir, step_x, step_y)
	. = ..()
	if(stat == DEAD)
		icon_state = icon_dead
	else
		var/obj/structure/spider/terrorweb/W = locate() in get_turf(src)
		if(W)
			if(icon_state == "terror_gray")
				icon_state = "terror_gray_cloaked"
				icon_living = "terror_gray_cloaked"
		else if(icon_state != "terror_gray")
			icon_state = "terror_gray"
			icon_living = "terror_gray"

/mob/living/simple_animal/hostile/poison/terror_spider/lurker/spider_specialattack(mob/living/carbon/human/L)
	var/obj/structure/spider/terrorweb/W = locate() in get_turf(src)
	if(W)
		melee_damage_lower = initial(melee_damage_lower) * 3
		melee_damage_upper = initial(melee_damage_upper) * 3
		armour_penetration = initial(armour_penetration) * 25
		visible_message("<span class='danger'>[src] suddenly attacks and savagely mauls [target]!</span>")
		L.adjustStaminaLoss(45)
		L.AdjustSilence(10 SECONDS)
	else
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		armour_penetration = initial(armour_penetration)
		visible_message("<span class='danger'>[src] bites [target]!</span>")
	L.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/lurker/spider_special_action()
	if(prob(prob_ai_massweb))
		for(var/turf/simulated/T in oview(2,get_turf(src)))
			if(T.density == 0)
				var/obj/structure/spider/terrorweb/W = locate() in T
				if(!W)
					new web_type(T)

/obj/structure/spider/terrorweb/gray
	alpha = 80
	name = "transparent web"
	desc = "This web is partly transparent, making it harder to see, and easier to get caught by."

/obj/structure/spider/terrorweb/gray/web_special_ability(mob/living/carbon/C) //super deadly web
	if(istype(C))
		C.AdjustSilence(14 SECONDS)
		C.Weaken(6 SECONDS)
		C.Slowed(10 SECONDS)

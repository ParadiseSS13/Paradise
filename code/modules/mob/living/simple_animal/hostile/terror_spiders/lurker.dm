
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
	maxHealth = 110
	health = 110
	death_sound = 'sound/creatures/terrorspiders/death5.ogg'
	speed = -0.2
	melee_damage_lower = 13
	melee_damage_upper = 16
	armour_penetration = 20
	stat_attack = UNCONSCIOUS // ensures they will target people in crit, too!
	delay_web = 15
	web_type = /obj/structure/spider/terrorweb/gray
	special_abillity = list(/obj/effect/proc_holder/spell/targeted/genetic/terror/stealth)
	spider_intro_text = "Будучи Наблюдателем Ужаса, ваша задача - устраивать засады. Вы невидимы в паутине, и наносите повышенный урон тем, кому не повезло в нее попасть, вы также можете стать невидимым на короткий промежуток времени."
	ai_spins_webs = FALSE // uses massweb instead
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

/mob/living/simple_animal/hostile/poison/terror_spider/lurker/spider_specialattack(mob/living/carbon/human/L, poisonable)
	var/obj/structure/spider/terrorweb/W = locate() in get_turf(L)
	if(W)
		melee_damage_lower = initial(melee_damage_lower) * 3
		melee_damage_upper = initial(melee_damage_upper) * 3
		visible_message("<span class='danger'>[src] savagely mauls [target] while [L.p_theyre()] stuck in the web!</span>")
		L.adjustStaminaLoss(45)
		L.AdjustSilence(5)
	else
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
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
	alpha = 70
	name = "transparent web"
	desc = "This web is partly transparent, making it harder to see, and easier to get caught by."

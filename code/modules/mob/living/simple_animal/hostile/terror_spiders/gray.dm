
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GRAY TERROR -------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ambusher
// -------------: AI: hides in vents, emerges when prey is near to kill it, then hides again. Intended to scare normal crew.
// -------------: SPECIAL: invisible when on top of a vent, emerges when prey approaches or gets trapped in webs.
// -------------: TO FIGHT IT: shoot it through a window, or make it regret ambushing you
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/gray
	name = "Gray Terror spider"
	desc = "An ominous-looking gray spider. It seems to blend into webs, making it hard to see."
	spider_role_summary = "Stealth spider that ambushes weak humans."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_gray"
	icon_living = "terror_gray"
	icon_dead = "terror_gray_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its almost invisible while on webs.
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	stat_attack = UNCONSCIOUS // ensures they will target people in crit, too!
	delay_web = 20 // double speed
	web_type = /obj/structure/spider/terrorweb/gray
	ai_spins_webs = FALSE // uses massweb instead
	var/prob_ai_massweb = 10

/mob/living/simple_animal/hostile/poison/terror_spider/gray/Move(turf/T)
	. = ..(T)
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

/mob/living/simple_animal/hostile/poison/terror_spider/gray/spider_specialattack(mob/living/carbon/human/L, poisonable)
	var/obj/structure/spider/terrorweb/W = locate() in get_turf(L)
	if(W)
		melee_damage_lower = initial(melee_damage_lower) * 2
		melee_damage_upper = initial(melee_damage_upper) * 2
		visible_message("<span class='danger'>[src] savagely mauls [target] while [L.p_theyre()] stuck in the web!</span>")
	else
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		visible_message("<span class='danger'>[src] bites [target]!</span>")
	L.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/gray/spider_special_action()
	if(prob(prob_ai_massweb))
		for(var/turf/simulated/T in oview(2,get_turf(src)))
			if(T.density == 0)
				var/obj/structure/spider/terrorweb/W = locate() in T
				if(!W)
					new web_type(T)

/obj/structure/spider/terrorweb/gray
	alpha = 100
	name = "transparent web"
	desc = "This web is partly transparent, making it harder to see, and easier to get caught by."
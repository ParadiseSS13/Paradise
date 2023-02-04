
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 GUARDIAN TERROR -----------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: guarding queen nests
// -------------: AI: dies if too far from queen
// -------------: SPECIAL: chance to stun on hit
// -------------: TO FIGHT IT: shoot it from range, bring friends!
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/guardian
	name = "Guardian of Terror"
	desc = "An ominous-looking purple spider. It looks about warily, as if waiting for something."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_purple"
	icon_living = "terror_purple"
	icon_dead = "terror_purple_dead"
	gender = MALE
	maxHealth = 220
	health = 220
	melee_damage_lower = 20
	melee_damage_upper = 25
	obj_damage = 70
	attack_sound = 'sound/creatures/terrorspiders/bite2.ogg'
	death_sound = 'sound/creatures/terrorspiders/death6.ogg'
	armour_penetration = 10
	spider_tier = TS_TIER_2
	move_to_delay = 5 // at 20ticks/sec, this is 4 tile/sec movespeed, same as a human. Faster than a normal spider, so it can intercept attacks on queen.
	spider_opens_doors = 2
	ventcrawler = 0
	move_resist = MOVE_FORCE_STRONG // no more pushing a several hundred if not thousand pound spider
	ai_ventcrawls = FALSE
	environment_smash = 2
	idle_ventcrawl_chance = 0 // stick to the queen!
	sight = SEE_MOBS
	web_type = /obj/structure/spider/terrorweb/purple
	can_wrap = FALSE
	delay_web = 20
	special_abillity = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/terror/shield)
	can_wrap = FALSE
	spider_intro_text = "Будучи Защитником Ужаса, ваша задача - охрана гнезда, яиц, принцесс и королевы. Вы очень сильны и живучи, используйте это, чтобы защитить выводок. Ваша активная способность создает временный неразрушимый барьер, через который могут пройти только пауки. Если встанет выбор, спасти принцессу, или королеву, при этои обрекая себя на смерть - делайте это без раздумий!."
	ai_spins_webs = FALSE
	var/queen_visible = TRUE
	var/cycles_noqueen = 0
	var/max_queen_range = 20

/mob/living/simple_animal/hostile/poison/terror_spider/guardian/spider_specialattack(mob/living/carbon/human/L)
	L.adjustStaminaLoss(15)
	if(prob(15))
		playsound(src, 'sound/creatures/terrorspiders/bite2.ogg', 120, 1)
		do_attack_animation(L)
		visible_message("<span class='danger'>[src] rams into [L], knocking [L.p_them()] to the floor!</span>")
		L.adjustBruteLoss(20)
		L.Weaken(1)
		L.Stun(1)
	else
		..()

/mob/living/simple_animal/hostile/poison/terror_spider/guardian/death(gibbed)
	if(can_die() && spider_myqueen)
		if(spider_myqueen.stat != DEAD && !spider_myqueen.ckey)
			if(get_dist(src, spider_myqueen) > max_queen_range)
				if(!degenerate && !spider_myqueen.degenerate)
					degenerate = TRUE
					spider_myqueen.DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/guardian, 1)
					visible_message("<span class='notice'>[src] chitters in the direction of [spider_myqueen]!</span>")
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/guardian/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD) // Can't use if(.) for this due to the fact it can sometimes return FALSE even when mob is alive.
		if(!degenerate && spider_myqueen)
			if(times_fired % 5 == 0)
				purple_distance_check()

/mob/living/simple_animal/hostile/poison/terror_spider/guardian/proc/purple_distance_check()
	if(spider_myqueen)
		var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q = spider_myqueen
		if(Q)
			if(Q.stat == DEAD)
				spider_myqueen = null
				degenerate = TRUE
				to_chat(src, "<span class='userdanger'>[Q] has died! Her power no longer sustains you!</span>")
				return

			if(get_dist(src, Q) < vision_range)
				queen_visible = TRUE
			else
				queen_visible = FALSE

			if(queen_visible)
				cycles_noqueen = 0
				if(spider_debug)
					to_chat(src, "<span class='notice'>[Q] visible.</span>")
			else
				cycles_noqueen++
				if(spider_debug)
					to_chat(src, "<span class='danger'>[Q] NOT visible. Cycles: [cycles_noqueen].</span>")
			var/area/A = get_area(spider_myqueen)
			switch(cycles_noqueen)
				if(6)
					// one minute without queen sighted
					to_chat(src, "<span class='danger'>You have become separated from [Q]. Return to her in [A].</span>")
				if(12)
					// two minutes without queen sighted
					to_chat(src, "<span class='danger'>Your long separation from [Q] weakens you. Return to her in [A].</span>")
				if(18)
					// three minutes without queen sighted, kill them.
					degenerate = TRUE
					to_chat(src, "<span class='userdanger'>Your link to [Q] has been broken! Your life force starts to drain away!</span>")
					melee_damage_lower = 5
					melee_damage_upper = 10

/mob/living/simple_animal/hostile/poison/terror_spider/guardian/Stat()
	..()
	// Provides a status panel indicator, showing purples how long they can be away from their queen before their hivemind link breaks, and they die.
	// Uses <font color='#X'> because the status panel does NOT accept <span class='X'>.
	if(statpanel("Status") && ckey && stat == CONSCIOUS)
		if(spider_myqueen)
			var/area/A = get_area(spider_myqueen)
			if(degenerate)
				stat(null, "Link: <font color='#eb4034'>BROKEN</font>") // color=red
			else if(queen_visible)
				stat(null, "Link: <font color='#32a852'>[spider_myqueen] is near</font>") // color=green
			else if(cycles_noqueen >= 18)
				stat(null, "Link: <font color='#eb4034'>Critical - return to [spider_myqueen] in [A]</font>") // color=red
			else
				stat(null, "Link: <font color='#fcba03'>Warning - return to [spider_myqueen] in [A]</font>") // color=orange

/obj/structure/spider/terrorweb/purple
	name = "thick web"
	desc = "This web is so thick, most cannot see beyond it."
	opacity = 1
	max_integrity = 40

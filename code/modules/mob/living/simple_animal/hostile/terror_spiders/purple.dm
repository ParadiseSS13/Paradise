
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 PURPLE TERROR -----------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: guarding queen nests
// -------------: AI: dies if too far from queen
// -------------: SPECIAL: chance to stun on hit
// -------------: TO FIGHT IT: shoot it from range, bring friends!
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/purple
	name = "Purple Terror spider"
	desc = "An ominous-looking purple spider. It looks about warily, as if waiting for something."
	spider_role_summary = "Guards the nest of the Queen of Terror."
	spider_intro_text = "As a Purple Terror Spider, your role is to guard all princess or queen terror spiders. \
	You move faster than other spiders, have high health, deal decent damage, can force open powered doors and can destroy walls. \
	Additionally, your webs are thick and will block vision for most of the crew. \
	However, being away from queen or princess spiders for too long will cause you to degenerate, taking gradual damage until you die or gain sight of them again."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_purple"
	icon_living = "terror_purple"
	icon_dead = "terror_purple_dead"
	maxHealth = 200
	health = 200
	melee_damage_upper = 25
	spider_tier = TS_TIER_2
	move_to_delay = 5 // at 20ticks/sec, this is 4 tile/sec movespeed, same as a human. Faster than a normal spider, so it can intercept attacks on queen.
	speed = 0 // '0' (also the default for human mobs) converts to 2.5 total delay, or 4 tiles/sec.
	spider_opens_doors = 2
	ventcrawler = VENTCRAWLER_NONE
	ai_ventcrawls = FALSE
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	idle_ventcrawl_chance = 0 // stick to the queen!
	web_type = /obj/structure/spider/terrorweb/purple
	ai_spins_webs = FALSE
	var/queen_visible = TRUE
	var/cycles_noqueen = 0
	var/max_queen_range = 20

/mob/living/simple_animal/hostile/poison/terror_spider/purple/death(gibbed)
	if(can_die() && spider_myqueen)
		if(spider_myqueen.stat != DEAD && !spider_myqueen.ckey)
			if(get_dist(src, spider_myqueen) > max_queen_range)
				if(!degenerate && !spider_myqueen.degenerate)
					degenerate = TRUE
					spider_myqueen.DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple, 1)
					visible_message("<span class='notice'>[src] chitters in the direction of [spider_myqueen]!</span>")
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/purple/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD) // Can't use if(.) for this due to the fact it can sometimes return FALSE even when mob is alive.
		if(!degenerate && spider_myqueen)
			if(times_fired % 5 == 0)
				purple_distance_check()

/mob/living/simple_animal/hostile/poison/terror_spider/purple/proc/purple_distance_check()
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

/mob/living/simple_animal/hostile/poison/terror_spider/purple/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	// Provides a status panel indicator, showing purples how long they can be away from their queen before their hivemind link breaks, and they die.
	// Uses <font color='#X'> because the status panel does NOT accept <span class='X'>.
	if(ckey && stat == CONSCIOUS)
		if(spider_myqueen)
			var/area/A = get_area(spider_myqueen)
			if(degenerate)
				status_tab_data[++status_tab_data.len] = list("Link:", "<font color='#eb4034'>BROKEN</font>") // color=red
			else if(queen_visible)
				status_tab_data[++status_tab_data.len] = list("Link:", "<font color='#32a852'>[spider_myqueen] is near</font>") // color=green
			else if(cycles_noqueen >= 12)
				status_tab_data[++status_tab_data.len] = list("Link:", "<font color='#eb4034'>Critical - return to [spider_myqueen] in [A]</font>") // color=red
			else
				status_tab_data[++status_tab_data.len] = list("Link:", "<font color='#fcba03'>Warning - return to [spider_myqueen] in [A]</font>") // color=orange




/obj/structure/spider/terrorweb/purple
	name = "thick web"
	desc = "This web is so thick, most cannot see beyond it."
	opacity = TRUE
	max_integrity = 40

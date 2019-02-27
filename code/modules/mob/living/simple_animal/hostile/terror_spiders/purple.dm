
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 PURPLE TERROR -----------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: guarding queen nests
// -------------: AI: dies if too far from queen
// -------------: SPECIAL: chance to stun on hit
// -------------: TO FIGHT IT: shoot it from range, bring friends!
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/purple
	name = "Purple Terror spider"
	desc = "An ominous-looking purple spider. It looks about warily, as if waiting for something."
	spider_role_summary = "Guards the nest of the Queen of Terror."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_purple"
	icon_living = "terror_purple"
	icon_dead = "terror_purple_dead"
	maxHealth = 200
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 25
	spider_tier = TS_TIER_2
	move_to_delay = 5 // at 20ticks/sec, this is 4 tile/sec movespeed, same as a human. Faster than a normal spider, so it can intercept attacks on queen.
	speed = 0 // '0' (also the default for human mobs) converts to 2.5 total delay, or 4 tiles/sec.
	spider_opens_doors = 2
	ventcrawler = 0
	ai_ventcrawls = 0
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	idle_ventcrawl_chance = 0 // stick to the queen!
	web_type = /obj/structure/spider/terrorweb/purple
	ai_spins_webs = FALSE
	var/dcheck_counter = 0
	var/queen_visible = 1
	var/cycles_noqueen = 0

/mob/living/simple_animal/hostile/poison/terror_spider/purple/death(gibbed)
	if(can_die() && spider_myqueen)
		var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q = spider_myqueen
		if(Q.stat != DEAD && !Q.ckey)
			if(get_dist(src,Q) > 20)
				if(!degenerate && !Q.degenerate)
					degenerate = 1
					Q.DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple, 1)
					visible_message("<span class='notice'>[src] chitters in the direction of [Q]!</span>")
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/purple/Life(seconds, times_fired)
	. = ..()
	if(.) // if mob is NOT dead
		if(!degenerate && spider_myqueen)
			if(dcheck_counter >= 10)
				dcheck_counter = 0
				purple_distance_check()
			else
				dcheck_counter++

/mob/living/simple_animal/hostile/poison/terror_spider/purple/proc/purple_distance_check()
	if(spider_myqueen)
		var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q = spider_myqueen
		if(Q)
			if(Q.stat == DEAD)
				spider_myqueen = null
				degenerate = 1
				to_chat(src,"<span class='userdanger'>Your Queen has died! Her power no longer sustains you!</span>")
				return
			queen_visible = 0
			for(var/mob/living/M in view(src, vision_range))
				if(M == Q)
					queen_visible = 1
					break
			if(queen_visible)
				cycles_noqueen = 0
				if(spider_debug)
					to_chat(src,"<span class='notice'>Queen visible.</span>")
			else
				cycles_noqueen++
				if(spider_debug)
					to_chat(src,"<span class='danger'>Queen NOT visible. Cycles: [cycles_noqueen].</span>")
			if(cycles_noqueen == 3)
				// one minute without queen sighted
				to_chat(src,"<span class='notice'>You wonder where your Queen is.</span>")
			else if(cycles_noqueen == 6)
				// two minutes without queen sighted
				to_chat(src,"<span class='danger'>Without your Queen in sight, you feel yourself getting weaker...</span>")
			else if(cycles_noqueen >= 9)
				// three minutes without queen sighted, kill them.
				degenerate = 1
				to_chat(src,"<span class='userdanger'>Your link to your Queen has been broken! Your life force starts to drain away!</span>")
				melee_damage_lower = 5
				melee_damage_upper = 10

/obj/structure/spider/terrorweb/purple
	name = "thick web"
	desc = "This web is so thick, most cannot see beyond it."
	opacity = 1
	health = 40
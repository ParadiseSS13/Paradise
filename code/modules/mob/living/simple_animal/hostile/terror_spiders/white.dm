
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 WHITE TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: stealthy reproduction
// -------------: AI: injects a venom that makes you grow spiders in your body, then retreats
// -------------: SPECIAL: stuns you on first attack - vulnerable to groups while it does this
// -------------: TO FIGHT IT: blast it before it can get away
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/BodyHorror
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/white
	name = "White Death spider"
	desc = "An ominous-looking white spider, its ghostly eyes and vicious-looking fangs are the stuff of nightmares."
	spider_role_summary = "Rare, bite-and-run spider that infects hosts with spiderlings"
	egg_name = "white spider eggs"

	altnames = list("White Terror spider","White Death spider","Ghostly Nightmare spider")
	icon_state = "terror_white"
	icon_living = "terror_white"
	icon_dead = "terror_white_dead"
	maxHealth = 100
	health = 100
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 4
	ventcrawler = 1
	spider_tier = 2
	loot = list(/obj/item/clothing/accessory/medal)

/mob/living/simple_animal/hostile/poison/terror_spider/white/LoseTarget()
	stop_automated_movement = 0
	attackstep = 0
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/white/death(gibbed)
	if (!hasdroppedloot)
		if (spider_uo71)
			UnlockBlastDoors("UO71_Bridge", "UO71 Bridge is now unlocked!")
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/white/harvest()
	if (!spider_awaymission)
		new /obj/item/weapon/reagent_containers/terrorspider_parts/toxgland_white(get_turf(src))
	gib()


/mob/living/simple_animal/hostile/poison/terror_spider/white/ShowGuide()
	..()
	to_chat(src, "WHITE TERROR guide:")
	to_chat(src, "- Amongst the most feared of all terror spiders, your multi-stage bite attack injects tiny spider eggs into a host, which will make spiders grow out of their skin in time.")
	to_chat(src, "- You should advance quickly, attack three times, then retreat, letting your venom of tiny eggs do its work.")
	to_chat(src, "- <span class='notice'>Your main objective is to infect humanoids with your egg venom, so that you can start a hive.</span>")
	to_chat(src, "- <span class='notice'>Once the hive has started, they will look to you for leadership.</span>")
	to_chat(src, "- Avoid groups, and stay alive, at all costs. White spiders, AKA White Death Spiders, are extremely rare, and impossible to replace!")

/mob/living/simple_animal/hostile/poison/terror_spider/white/spider_specialattack(var/mob/living/carbon/human/L, var/poisonable)
	if (!poisonable)
		..()
		return
	var/inject_target = pick("chest","head")
	if (attackstep == 0)
		visible_message("<span class='danger'> \icon[src] [src] crouches down on its powerful hind legs! </span>")
		attackstep = 1
	else if (attackstep == 1)
		visible_message("<span class='danger'> \icon[src] [src] pounces on [target]! </span>")
		do_attack_animation(L)
		L.emote("scream")
		L.drop_l_hand()
		L.drop_r_hand()
		L.Weaken(5) // stunbaton-like stun, floors them
		L.Stun(5)
		attackstep = 2
	else if (attackstep == 2)
		do_attack_animation(L)
		if (degenerate)
			visible_message("<span class='danger'> \icon[src] [src] does not have the strength to bite [target]!</span>")
		else if (L.stunned || L.paralysis || L.can_inject(null,0,inject_target,0))
			L.reagents.add_reagent("terror_white_toxin", 10)
			visible_message("<span class='danger'> \icon[src] [src] injects a green venom into the [inject_target] of [target]!</span>")
		else
			visible_message("<span class='danger'> \icon[src] [src] bites [target], but cannot inject venom into their [inject_target]!</span>")
			attackstep = 3
	else if (attackstep == 3)
		if (L in enemies)
			if (L.stunned || L.paralysis || L.can_inject(null,0,inject_target,0))
				do_attack_animation(L)
				L.reagents.add_reagent("terror_white_tranq", 5)
				visible_message("<span class='danger'> \icon[src] [src] injects a blue venom into the [inject_target] of [target]!</span></span>")
				enemies -= L
			else
				do_attack_animation(L)
				visible_message("<span class='danger'> \icon[src] [src] bites [target], but cannot inject venom into their [inject_target]!</span>")
		else
			visible_message("<span class='notice'> \icon[src] [src] takes a moment to recover... </span>")
			attackstep = 4
	else if (attackstep == 4)
		attackstep = 0
		attackcycles++
		if (ckey)
			if (IsInfected(L))
				to_chat(src, "<span class='notice'> [L] is infected. Find another host to attack/infect, or leave the area.</span>")
			else
				L.attack_animal(src)
		else
			if (attackcycles >= 3) // if we've an AI who has gone through 3 infection attempts on a single target, just give up trying to infect it, and kill it instead.
				attackstep = 5
				L.attack_animal(src)
				return
			if (!IsInfected(L))
				visible_message("<span class='notice'> \icon[src] [src] takes a moment to recover. </span>")
				return
			if (!ckey)
				var/vdistance = 99
				for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
					if (!v.welded)
						if (get_dist(src,v) < vdistance)
							entry_vent = v
							vdistance = get_dist(src,v)
				var/list/numtargets = ListTargets()
				if (numtargets.len > 0)
					LoseTarget()
					walk_away(src,L,2,1)
				else if (entry_vent)
					visible_message("<span class='notice'> \icon[src] [src] lets go of [target], and tries to flee! </span>")
					path_to_vent = 1
					var/temp_ai_type = ai_type
					ai_type = TS_AI_DEFENSIVE
					LoseTarget()
					walk_away(src,L,2,1)
					spawn(100) // 10 seconds
						ai_type = temp_ai_type
				else
					LoseTarget()
	else if (attackstep == 5)
		L.attack_animal(src)
	else
		attackstep = 0
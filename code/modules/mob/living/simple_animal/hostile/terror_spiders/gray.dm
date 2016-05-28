
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GRAY TERROR -------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ambusher
// -------------: AI: hides in vents, emerges when prey is near to kill it, then hides again. Intended to scare normal crew.
// -------------: SPECIAL: invisible when on top of a vent, emerges when prey approaches or gets trapped in webs
// -------------: TO FIGHT IT: shoot it through a window, or make it regret ambushing you
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/StealthExpert
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/gray
	name = "Gray Terror spider"
	desc = "An ominous-looking gray spider, its color and shape makes it hard to see."
	altnames = list("Gray Trap spider","Gray Stalker spider","Ghostly Ambushing spider")
	spider_role_summary = "Stealth spider that ambushes weak humans from vents."
	egg_name = "gray spider eggs"

	icon_state = "terror_gray"
	icon_living = "terror_gray"
	icon_dead = "terror_gray_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its almost invisible.
	health = 120
	melee_damage_lower = 15 // same as guard spider, its a melee class
	melee_damage_upper = 20
	ventcrawler = 1
	move_to_delay = 5 // normal speed
	stat_attack = 1 // ensures they will target people in crit, too!
	environment_smash = 1
	wander = 0 // wandering defeats the purpose of stealth
	idle_vision_range = 3 // very low idle vision range
	vision_type = null // prevent them seeing through walls when doing AOE web.


/mob/living/simple_animal/hostile/poison/terror_spider/gray/adjustBruteLoss(var/damage)
	..(damage)
	if (invisibility > 0 || icon_state == "terror_gray_cloaked")
		GrayDeCloak()

/mob/living/simple_animal/hostile/poison/terror_spider/gray/adjustFireLoss(var/damage)
	..(damage)
	if (invisibility > 0 || icon_state == "terror_gray_cloaked")
		GrayDeCloak()

/mob/living/simple_animal/hostile/poison/terror_spider/gray/Aggro()
	GrayDeCloak()
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/gray/AttackingTarget()
	if (invisibility > 0 || icon_state == "terror_gray_cloaked")
		GrayDeCloak()
	else
		..()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/GrayCloak()
	visible_message("<span class='notice'>[src] hides in the vent.</span>")
	invisibility = SEE_INVISIBLE_LEVEL_ONE
	icon_state = "terror_gray_cloaked"
	icon_living = "terror_gray_cloaked"
	if (!ckey)
		vision_range = 3
		idle_vision_range = 3
	// Bugged, does not work yet. Also spams webs. Also doesn't look great. But... planned.
	move_to_delay = 15 // while invisible, slow.

/mob/living/simple_animal/hostile/poison/terror_spider/proc/GrayDeCloak()
	invisibility = 0
	icon_state = "terror_gray"
	icon_living = "terror_gray"
	vision_range = 9
	idle_vision_range = 9
	move_to_delay = 5
	prob_ai_hides_in_vents = 10

/mob/living/simple_animal/hostile/poison/terror_spider/gray/ShowGuide()
	..()
	to_chat(src, "GRAY TERROR guide:")
	to_chat(src, "- You are an ambusher. Springing out of vents, you hunt unequipped and vulnerable humanoids.")
	to_chat(src, "- You are weak, but fast, and should use webs in corridors to trap your prey, hiding in a vent until they are entangled.")
	to_chat(src, "- Do not attempt to take on well-armed foes without the element of surprise - you will die quickly.")

/mob/living/simple_animal/hostile/poison/terror_spider/gray/spider_special_action()
	if (prob(prob_ai_hides_in_vents))
		var/obj/machinery/atmospherics/unary/vent_pump/e = locate() in get_turf(src)
		if (e)
			if (!e.welded || spider_awaymission)
				if (invisibility != SEE_INVISIBLE_LEVEL_ONE) // aka: 35. ghosts have 15 with no darkness, 60 with darkness. Weird...
					var/list/g_turfs_webbed = ListWebbedTurfs()
					var/webcount = g_turfs_webbed.len
					if (webcount >= 4)
						// if there are already at least 4 webs around us, then we have a good web setup already. Cloak.
						GrayCloak()
						// I wonder if we should settle down here forever?
						var/foundqueen = 0
						for(var/mob/living/H in view(src, 10))
							if (istype(H, /mob/living/simple_animal/hostile/poison/terror_spider/queen))
								foundqueen = 1
								break
						if (!foundqueen)
							var/list/g_turfs_visible = ListVisibleTurfs()
							if (g_turfs_visible.len >= 12)
								// So long as the room isn't tiny, and it has no queen in it, sure, settle there
								// since we are settled now, disable most AI behaviors so we don't waste CPU.
								ai_ventcrawls = 0
								ai_spins_webs = 0
								ai_break_lights = 0
								prob_ai_hides_in_vents = 3
								visible_message("<span class='notice'> [src] finishes setting up its trap in [get_area(src)].</span>")
					else
						var/list/g_turfs_valid = ListValidTurfs()
						var/turfcount = g_turfs_valid.len
						if (turfcount == 0)
							// if there is literally nowhere else we could put a web, cloak.
							GrayCloak()
						else
							// otherwise, pick one of the valid turfs with no web to create a web there.
							new /obj/effect/spider/terrorweb(pick(g_turfs_valid))
							visible_message("<span class='notice'> [src] spins a web.</span>")
			else
				if (invisibility == SEE_INVISIBLE_LEVEL_ONE)
					// if our vent is welded, decloak
					GrayDeCloak()
		else
			if (invisibility == SEE_INVISIBLE_LEVEL_ONE)
				// if there is no vent under us, and we are cloaked, decloak
				GrayDeCloak()
			var/vdistance = 99
			var/temp_vent = null
			for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(7,src))
				if (!v.welded)
					if (get_dist(src,v) < vdistance)
						temp_vent = v
						vdistance = get_dist(src,v)
			if (temp_vent)
				if (get_dist(src,temp_vent) > 0 && get_dist(src,temp_vent) < 5)
					step_to(src,temp_vent)
					// if you're bumped off your vent, try to get back to it
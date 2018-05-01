
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GREEN TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: reproduction
// -------------: AI: after it kills you, it webs you and lays new terror eggs on your body
// -------------: SPECIAL: can also create webs, web normal objects, etc
// -------------: TO FIGHT IT: kill it however you like - just don't die to it!
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/green
	name = "Green Terror spider"
	desc = "An ominous-looking green spider. It has a small egg-sac attached to it, and dried blood stains on its carapace."
	spider_role_summary = "Average melee spider that webs its victims and lays more spider eggs"
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_green"
	icon_living = "terror_green"
	icon_dead = "terror_green_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	var/feedings_to_lay = 2
	var/datum/action/innate/terrorspider/greeneggs/greeneggs_action


/mob/living/simple_animal/hostile/poison/terror_spider/green/New()
	..()
	greeneggs_action = new()
	greeneggs_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/green/proc/DoLayGreenEggs()
	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
	else if(fed < feedings_to_lay)
		to_chat(src, "<span class='warning'>You must wrap more humanoid prey before you can do this!</span>")
	else
		visible_message("<span class='notice'>[src] begins to lay a cluster of eggs.</span>")
		if(prob(33))
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red, 1, 1)
		else if(prob(50))
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/gray, 1, 1)
		else
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green, 1, 1)
		fed -= feedings_to_lay

/mob/living/simple_animal/hostile/poison/terror_spider/green/spider_special_action()
	if(cocoon_target)
		if(get_dist(src, cocoon_target) <= 1)
			spider_steps_taken = 0
			DoWrap()
		else
			if(spider_steps_taken > spider_max_steps)
				spider_steps_taken = 0
				cocoon_target = null
				busy = 0
				stop_automated_movement = 0
			else
				spider_steps_taken++
				CreatePath(cocoon_target)
				step_to(src,cocoon_target)
				if(spider_debug)
					visible_message("<span class='notice'>[src] moves towards [cocoon_target] to cocoon it.</span>")
	else if(fed >= feedings_to_lay)
		DoLayGreenEggs()
	else if(world.time > (last_cocoon_object + freq_cocoon_object))
		last_cocoon_object = world.time
		var/list/can_see = view(src, 10)
		for(var/mob/living/C in can_see)
			if(C.stat == DEAD && !isterrorspider(C) && !C.anchored)
				spider_steps_taken = 0
				cocoon_target = C
				return
		for(var/obj/O in can_see)
			if(O.anchored)
				continue
			if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery))
				if(!istype(O, /obj/item/paper))
					cocoon_target = O
					stop_automated_movement = 1
					spider_steps_taken = 0
					return

/mob/living/simple_animal/hostile/poison/terror_spider/green/spider_specialattack(mob/living/carbon/human/L, poisonable)
	if(!poisonable)
		..()
		return
	var/inject_target = pick("chest","head")
	if(L.stunned || L.can_inject(null,0,inject_target,0))
		if(L.eye_blurry < 60)
			L.AdjustEyeBlurry(10)
		// instead of having a venom that only lasts seconds, we just add the eyeblur directly.
		visible_message("<span class='danger'>[src] buries its fangs deep into the [inject_target] of [target]!</span>")
	else
		visible_message("<span class='danger'>[src] bites [target], but cannot inject venom into their [inject_target]!</span>")
	L.attack_animal(src)
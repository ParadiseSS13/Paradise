
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GREEN TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: reproduction
// -------------: AI: after it kills you, it webs you and lays new terror eggs on your body
// -------------: SPECIAL: can also create webs, web normal objects, etc
// -------------: TO FIGHT IT: kill it however you like - just don't die to it!
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/EnemySummoner
// -------------: SPRITES FROM: Codersprites :(

/mob/living/simple_animal/hostile/poison/terror_spider/green
	name = "Green Terror spider"
	desc = "An ominous-looking green spider, it has a small egg-sac attached to it."
	altnames = list("Green Terror spider","Insidious Breeding spider","Fast Bloodsucking spider")
	spider_role_summary = "Average melee spider that webs its victims and lays more spider eggs"
	ai_target_method = TS_DAMAGE_BRUTE
	egg_name = "green spider eggs"

	icon_state = "terror_green"
	icon_living = "terror_green"
	icon_dead = "terror_green_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	ventcrawler = 1



/mob/living/simple_animal/hostile/poison/terror_spider/green/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to eat (allowing you to lay eggs) and objects (making them inaccessible to humans)."
	DoWrap()


/mob/living/simple_animal/hostile/poison/terror_spider/green/verb/LayGreenEggs()
	set name = "Lay Green Eggs"
	set category = "Spider"
	set desc = "Lay a clutch of eggs. You must have wrapped a prey creature for feeding first."
	DoLayGreenEggs()


/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoLayGreenEggs()
	var/obj/effect/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
	else if(!fed)
		to_chat(src, "<span class='warning'>You are too hungry to do this!</span>")
	else
		visible_message("<span class='notice'>\The [src] begins to lay a cluster of eggs.</span>")
		if(prob(33))
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red, 2, 1)
		else if(prob(50))
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/gray, 2, 1)
		else
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green, 2, 1)
		fed--

/mob/living/simple_animal/hostile/poison/terror_spider/green/ShowGuide()
	..()
	var/guidetext = "GREEN TERROR guide:"
	guidetext += "<BR>- You are a breeding spider. Your job is to use the 'Wrap' verb (Spider tab) on any dead humaniod, then 'Lay Green Eggs'. These eggs hatch into more spiders!"
	guidetext += "<BR>- Lay your eggs in dark, low-traffic areas near vents. Don't be afraid to retreat from a fight to lay another day."
	to_chat(src, guidetext)

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
				if(spider_debug > 0)
					visible_message("<span class='notice'>\The [src] moves towards [cocoon_target] to cocoon it.</span>")
	else if(fed)
		DoLayGreenEggs()
	else if(world.time > (last_cocoon_object + freq_cocoon_object))
		last_cocoon_object = world.time
		var/list/can_see = view(src, 10)
		//first, check for potential food nearby to cocoon
		for(var/mob/living/C in can_see)
			if(C.stat == DEAD && !istype(C, /mob/living/simple_animal/hostile/poison/terror_spider))
				spider_steps_taken = 0
				cocoon_target = C
				return
		// if no food found, check for other objects
		for(var/obj/O in can_see)
			if(O.anchored)
				continue
			if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery))
				if(!istype(O, /obj/item/weapon/paper))
					cocoon_target = O
					stop_automated_movement = 1
					spider_steps_taken = 0
					return

/mob/living/simple_animal/hostile/poison/terror_spider/green/spider_specialattack(var/mob/living/carbon/human/L, var/poisonable)
	if(!poisonable)
		..()
		return
	var/inject_target = pick("chest","head")
	if(L.stunned || L.can_inject(null,0,inject_target,0))
		L.eye_blurry = max(L.eye_blurry + 10, 60)
		// instead of having a venom that only lasts seconds, we just add the eyeblur directly.
		visible_message("<span class='danger'>[src] buries its fangs deep into the [inject_target] of [target]!</span>")
	else
		visible_message("<span class='danger'>[src] bites [target], but cannot inject venom into their [inject_target]!</span>")
	L.attack_animal(src)
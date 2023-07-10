
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/poison/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	footstep_type = FOOTSTEP_MOB_CLAW
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/spidermeat= 2, /obj/item/reagent_containers/food/snacks/monstermeat/spiderleg= 8)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	heat_damage_per_tick = 20	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 20	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	faction = list("spiders")
	pass_flags = PASSTABLE
	move_to_delay = 6
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	gold_core_spawnable = HOSTILE_SPAWN
	var/venom_per_bite = 0 // While the /poison/ type path remains as-is for consistency reasons, we're really talking about venom, not poison.

/mob/living/simple_animal/hostile/poison/giant_spider/Initialize(mapload)
	. = ..()
	var/datum/action/innate/web_giant_spider/web_action = new()
	web_action.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/Destroy()
	for(var/datum/action/innate/web_giant_spider/web_action in actions)
		web_action.Remove(src)
	return ..()

/mob/living/simple_animal/hostile/poison/giant_spider/AttackingTarget()
	// This is placed here, NOT on /poison, because the other subtypes of /poison/ already override AttackingTarget() completely, and as such it would do nothing but confuse people there.
	. = ..()
	if(. && venom_per_bite > 0 && iscarbon(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/carbon/C = target
		var/inject_target = pick("chest", "head")
		if(C.can_inject(null, FALSE, inject_target, FALSE))
			C.reagents.add_reagent("spidertoxin", venom_per_bite)

/mob/living/simple_animal/hostile/poison/giant_spider/get_spacemove_backup()
	. = ..()
	// If we don't find any normal thing to use, attempt to use any nearby spider structure instead.
	if(!.)
		for(var/obj/structure/spider/S in range(1, get_turf(src)))
			return S

//nursemaids - these create webs and eggs
/mob/living/simple_animal/hostile/poison/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/spidermeat= 2, /obj/item/reagent_containers/food/snacks/monstermeat/spiderleg= 8, /obj/item/reagent_containers/food/snacks/monstermeat/spidereggs= 4)

	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	venom_per_bite = 30
	var/atom/cocoon_target
	var/fed = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/Initialize(mapload)
	. = ..()
	var/datum/action/innate/wrap_giant_spider/wrap_action = new()
	wrap_action.Grant(src)
	var/datum/action/innate/lay_eggs_giant_spider/egg_action = new()
	egg_action.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/Destroy()
	for(var/datum/action/innate/wrap_giant_spider/wrap_action in actions)
		wrap_action.Remove(src)
	for(var/datum/action/innate/lay_eggs_giant_spider/egg_action in actions)
		egg_action.Remove(src)
	return ..()

//hunters have the most poison and move the fastest, so they can find prey
/mob/living/simple_animal/hostile/poison/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	venom_per_bite = 10
	move_to_delay = 5

/mob/living/simple_animal/hostile/poison/giant_spider/handle_automated_movement() //Hacky and ugly.
	. = ..()
	if(AIStatus == AI_IDLE)
		//1% chance to skitter madly away
		if(prob(1))
			stop_automated_movement = TRUE
			Goto(pick(urange(20, src, 1)), move_to_delay)
			spawn(50)
				stop_automated_movement = FALSE
				walk(src,0)
		return 1

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/GiveUp(C)
	spawn(100)
		if(cocoon_target == C && get_dist(src, cocoon_target) > 1)
			cocoon_target = null
		stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/handle_automated_movement() //Hacky and ugly.
	if(..())
		var/list/can_see = view(src, 10)
		if(prob(30))	//30% chance to stop wandering and do something
			//first, check for potential food nearby to cocoon
			for(var/mob/living/C in can_see)
				if(C.stat && !istype(C, /mob/living/simple_animal/hostile/poison/giant_spider) && !C.anchored)
					cocoon_target = C
					Goto(C, move_to_delay)
					//give up if we can't reach them after 10 seconds
					GiveUp(C)
					return
			//second, spin a sticky spiderweb on this tile
			var/obj/structure/spider/stickyweb/W = locate() in get_turf(src)
			if(!W)
				create_web()
			else
				//third, lay an egg cluster there
				if(fed)
					lay_spider_eggs()
				else
					//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
					for(var/obj/O in can_see)
						if(O.anchored)
							continue

						if(isitem(O) || isstructure(O) || ismachinery(O))
							cocoon_target = O
							stop_automated_movement = TRUE
							Goto(O, move_to_delay)
							//give up if we can't reach them after 10 seconds
							GiveUp(O)

		else if(cocoon_target)
			if(get_dist(src, cocoon_target) <= 1)
				wrap_target()

	else
		stop_automated_movement = FALSE

/datum/action/innate/web_giant_spider
	name = "Lay Web"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "stickyweb1"

/datum/action/innate/web_giant_spider/Activate()
	var/mob/living/simple_animal/hostile/poison/giant_spider/user = owner
	user.create_web()

/datum/action/innate/wrap_giant_spider
	name = "Wrap"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "cocoon_large1"

/datum/action/innate/wrap_giant_spider/Activate()
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/user = owner
	user.wrap_target()

/datum/action/innate/lay_eggs_giant_spider
	name = "Lay Eggs"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "eggs"

/datum/action/innate/lay_eggs_giant_spider/Activate()
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/user = owner
	user.lay_spider_eggs()

/mob/living/simple_animal/hostile/poison/giant_spider/proc/create_web()
	var/T = loc

	visible_message("<span class='notice'>[src] begins to secrete a sticky substance.</span>")
	stop_automated_movement = TRUE
	if(!do_after_once(src, 4 SECONDS, target = loc, attempt_cancel_message = "You stop spinning a web."))
		return
	new /obj/structure/spider/stickyweb(T)
	stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/wrap_target()
	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1, src))
			if(L == src)
				continue
			if(L.stat != DEAD)
				continue
			if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
				continue
			if(Adjacent(L))
				choices += L
		for(var/obj/O in get_turf(src))
			if(O.anchored)
				continue
			if(!(isitem(O) || isstructure(O) || ismachinery(O)))
				continue
			if(Adjacent(O))
				choices += O
		if(length(choices))
			cocoon_target = input(src,"What do you wish to cocoon?") in null|choices
		else
			to_chat(src, "<span class='warning'>No suitable dead prey or wrappable objects found nearby.")
			return

	if(cocoon_target)
		visible_message("<span class='notice'>[src] begins to secrete a sticky substance around [cocoon_target].</span>")
		stop_automated_movement = TRUE
		walk(src, 0)
		if(!do_after_once(src, 5 SECONDS, target = cocoon_target, attempt_cancel_message = "You stop wrapping [cocoon_target]."))
			return
		if(cocoon_target && isturf(cocoon_target.loc) && get_dist(src, cocoon_target) <= 1)
			var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
			var/large_cocoon = FALSE
			C.pixel_x = cocoon_target.pixel_x
			C.pixel_y = cocoon_target.pixel_y
			for(var/obj/item/I in C.loc)
				I.loc = C
			for(var/obj/structure/S in C.loc)
				if(!S.anchored)
					S.loc = C
					large_cocoon = TRUE
			for(var/obj/machinery/M in C.loc)
				if(!M.anchored)
					M.loc = C
					large_cocoon = TRUE
			for(var/mob/living/L in C.loc)
				if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
					continue
				if(L.stat != DEAD)
					continue
				large_cocoon = TRUE
				L.loc = C
				C.pixel_x = L.pixel_x
				C.pixel_y = L.pixel_y
				fed++
				visible_message("<span class='danger'>[src] sticks a proboscis into [L] and sucks a viscous substance out.</span>")

				break
			if(large_cocoon)
				C.icon_state = pick("cocoon_large1", "cocoon_large2", "cocoon_large3")
	cocoon_target = null
	stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/lay_spider_eggs()
	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
		return
	if(!fed)
		to_chat(src, "<span class='warning'>You are too hungry to do this!</span>")
		return
	visible_message("<span class='notice'>[src] begins to lay a cluster of eggs.</span>")
	stop_automated_movement = TRUE
	if(!do_after_once(src, 4 SECONDS, target = loc, attempt_cancel_message = "You stop laying eggs."))
		return
	var/obj/structure/spider/eggcluster/C = new /obj/structure/spider/eggcluster(loc)
	C.faction = faction.Copy()
	C.master_commander = master_commander
	C.xenobiology_spawned = xenobiology_spawned
	if(ckey)
		C.player_spiders = TRUE
	fed--
	stop_automated_movement = FALSE

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON

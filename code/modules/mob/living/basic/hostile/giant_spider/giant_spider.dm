// basic spider mob, these generally guard nests
/mob/living/basic/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	speak_emote = list("chitters")
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	step_type = FOOTSTEP_MOB_CLAW
	a_intent = INTENT_HARM
	butcher_results = list(/obj/item/food/monstermeat/spidermeat = 2, /obj/item/food/monstermeat/spiderleg = 8)
	response_help_continuous = "pets"
	response_help_simple = "pets"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently pushes aside"
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	unsuitable_heat_damage = 20
	unsuitable_cold_damage = 20
	faction = list("spiders")
	pass_flags = PASSTABLE
	attack_verb_simple = "bite"
	attack_verb_continuous = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	gold_core_spawnable = HOSTILE_SPAWN
	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/spider
	ai_controller = /datum/ai_controller/basic_controller/giant_spider
	/// How much venom is injected per bite into the poor victim
	var/venom_per_bite = 0
	/// Actions to grant on Initialize
	var/list/innate_actions = list(/datum/action/innate/web_giant_spider = BB_SPIDER_WEB_ACTION)

/mob/living/basic/giant_spider/Initialize(mapload)
	. = ..()
	grant_actions_by_list(innate_actions)

/mob/living/basic/giant_spider/Destroy()
	for(var/datum/action/innate/web_giant_spider/web_action in actions)
		web_action.Remove(src)
	return ..()

/mob/living/basic/giant_spider/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(. && venom_per_bite > 0 && iscarbon(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/carbon/C = target
		var/inject_target = pick("chest", "head")
		if(C.can_inject(null, FALSE, inject_target, FALSE))
			C.reagents.add_reagent("spidertoxin", venom_per_bite)

/mob/living/basic/giant_spider/get_spacemove_backup(movement_dir)
	. = ..()
	// If we don't find any normal thing to use, attempt to use any nearby spider structure instead.
	if(!.)
		for(var/obj/structure/spider/S in range(1, get_turf(src)))
			return S

/mob/living/basic/giant_spider/proc/create_web()
	var/T = loc
	visible_message("<span class='notice'>[src] begins to secrete a sticky substance.</span>")
	if(!do_after_once(src, 4 SECONDS, target = loc, attempt_cancel_message = "You stop spinning a web.", interaction_key = "spider_web_create"))
		return
	new /obj/structure/spider/stickyweb(T)

// Nursemaids - these create webs and eggs
/mob/living/basic/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	butcher_results = list(/obj/item/food/monstermeat/spidermeat = 2, /obj/item/food/monstermeat/spiderleg = 8, /obj/item/food/monstermeat/spidereggs = 4)
	ai_controller = /datum/ai_controller/basic_controller/giant_spider/nurse
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	gold_core_spawnable = NO_SPAWN
	venom_per_bite = 30
	innate_actions = list(
		/datum/action/innate/web_giant_spider = BB_SPIDER_WEB_ACTION,
		/datum/action/innate/wrap_giant_spider = BB_SPIDER_WRAP_ACTION,
		/datum/action/innate/lay_eggs_giant_spider = BB_SPIDER_EGG_LAYING_ACTION
	)
	/// How much have we eaten
	var/fed = 0

/mob/living/basic/giant_spider/nurse/proc/wrap_target()
	var/atom/cocoon_target
	if(!client)
		cocoon_target = ai_controller.blackboard[BB_SPIDER_WRAP_TARGET]
	if(!cocoon_target && client)
		var/list/choices = list()
		for(var/mob/living/L in view(1, src))
			if(L == src)
				continue
			if(L.stat != DEAD)
				continue
			if(istype(L, /mob/living/basic/giant_spider))
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
			cocoon_target = tgui_input_list(src, "What do you wish to cocoon?", "Cocoon Wrapping", choices)
		else
			to_chat(src, "<span class='warning'>No suitable dead prey or wrappable objects found nearby.")
			return

	if(cocoon_target)
		visible_message("<span class='notice'>[src] begins to secrete a sticky substance around [cocoon_target].</span>")
		if(!do_after_once(src, 5 SECONDS, target = cocoon_target, attempt_cancel_message = "You stop wrapping [cocoon_target].", interaction_key = "spider_web_wrap"))
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
				if(istype(L, /mob/living/basic/giant_spider))
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

/mob/living/basic/giant_spider/nurse/proc/lay_spider_eggs()
	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
		return
	if(!fed)
		to_chat(src, "<span class='warning'>You are too hungry to do this!</span>")
		return
	visible_message("<span class='notice'>[src] begins to lay a cluster of eggs.</span>")
	if(!do_after_once(src, 4 SECONDS, target = loc, attempt_cancel_message = "You stop laying eggs.", interaction_key = "spider_egg_lay"))
		return
	var/obj/structure/spider/eggcluster/C = new /obj/structure/spider/eggcluster(loc)
	C.faction = faction.Copy()
	C.master_commander = master_commander
	if(ckey)
		C.player_spiders = TRUE
	fed--

/mob/living/basic/giant_spider/nurse/proc/find_cocoon_target()
	// Prioritize food
	var/list/food = list()
	var/list/can_see = view(src, 10)
	for(var/mob/living/C in can_see)
		if(C.stat && !istype(C, /mob/living/basic/giant_spider) && !C.anchored)
			food += C
	if(length(food))
		return pick(food)
	var/list/objects = list()
	for(var/obj/O in can_see)
		if(O.anchored)
			continue

		if(isitem(O) || isstructure(O) || ismachinery(O))
			objects += O
	if(length(objects))
		return pick(objects)
	return

// Hunters have the most poison and move the fastest, so they can find prey
/mob/living/basic/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	venom_per_bite = 10

/mob/living/basic/giant_spider/araneus
	name = "Sergeant Araneus"
	real_name = "Sergeant Araneus"
	desc = "A fierce companion for any person of power, this spider has been carefully trained by Nanotrasen specialists. Its beady, staring eyes send shivers down your spine."
	faction = list("spiders")
	maxHealth = 250
	health = 250
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 2, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/giant_spider/retaliate

/mob/living/basic/giant_spider/araneus/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "chitters!")

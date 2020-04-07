
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/poison/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	var/butcher_state = 8 // Icon state for dead spider icons
	icon_living = "guard"
	icon_dead = "guard_dead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/spidermeat = 2, /obj/item/reagent_containers/food/snacks/spiderleg = 8)
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
	var/busy = 0

/mob/living/simple_animal/hostile/poison/giant_spider/AttackingTarget()
	// This is placed here, NOT on /poison, because the other subtypes of /poison/ already override AttackingTarget() completely, and as such it would do nothing but confuse people there.
	. = ..()
	if(. && venom_per_bite > 0 && iscarbon(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/carbon/C = target
		var/inject_target = pick("chest", "head")
		if(C.can_inject(null, FALSE, inject_target, FALSE))
			C.reagents.add_reagent("spidertoxin", venom_per_bite)

//nursemaids - these create webs and eggs
/mob/living/simple_animal/hostile/poison/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/spidermeat = 2, /obj/item/reagent_containers/food/snacks/spiderleg = 8, /obj/item/reagent_containers/food/snacks/spidereggs = 4)

	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	venom_per_bite = 30
	var/atom/cocoon_target
	var/fed = 0

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
		if(!busy && prob(1))
			stop_automated_movement = 1
			Goto(pick(urange(20, src, 1)), move_to_delay)
			spawn(50)
				stop_automated_movement = 0
				walk(src,0)
		return 1

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/GiveUp(C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/handle_automated_movement() //Hacky and ugly.
	if(..())
		var/list/can_see = view(src, 10)
		if(!busy && prob(30))	//30% chance to stop wandering and do something
			//first, check for potential food nearby to cocoon
			for(var/mob/living/C in can_see)
				if(C.stat && !istype(C, /mob/living/simple_animal/hostile/poison/giant_spider) && !C.anchored)
					cocoon_target = C
					busy = MOVING_TO_TARGET
					Goto(C, move_to_delay)
					//give up if we can't reach them after 10 seconds
					GiveUp(C)
					return
			//second, spin a sticky spiderweb on this tile
			var/obj/structure/spider/stickyweb/W = locate() in get_turf(src)
			if(!W)
				Web()
			else
				//third, lay an egg cluster there
				if(fed)
					LayEggs()
				else
					//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
					for(var/obj/O in can_see)
						if(O.anchored)
							continue

						if(isitem(O) || isstructure(O) || ismachinery(O))
							cocoon_target = O
							busy = MOVING_TO_TARGET
							stop_automated_movement = 1
							Goto(O, move_to_delay)
							//give up if we can't reach them after 10 seconds
							GiveUp(O)

		else if(busy == MOVING_TO_TARGET && cocoon_target)
			if(get_dist(src, cocoon_target) <= 1)
				Wrap()

	else
		busy = 0
		stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/verb/Web()
	set name = "Lay Web"
	set category = "Spider"
	set desc = "Spread a sticky web to slow down prey."

	var/T = src.loc

	if(busy != SPINNING_WEB)
		busy = SPINNING_WEB
		src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
		stop_automated_movement = 1
		spawn(40)
			if(busy == SPINNING_WEB && src.loc == T)
				new /obj/structure/spider/stickyweb(T)
			busy = 0
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/giant_spider/nurse/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to feast upon and objects for safe keeping."

	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1,src))
			if(L == src)
				continue
			if(Adjacent(L))
				choices += L
		for(var/obj/O in src.loc)
			if(Adjacent(O))
				choices += O
		cocoon_target = input(src,"What do you wish to cocoon?") in null|choices

	if(cocoon_target && busy != SPINNING_COCOON)
		busy = SPINNING_COCOON
		src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
		stop_automated_movement = 1
		walk(src,0)
		spawn(50)
			if(busy == SPINNING_COCOON)
				if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
					var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
					var/large_cocoon = 0
					C.pixel_x = cocoon_target.pixel_x
					C.pixel_y = cocoon_target.pixel_y
					for(var/obj/item/I in C.loc)
						I.loc = C
					for(var/obj/structure/S in C.loc)
						if(!S.anchored)
							S.loc = C
							large_cocoon = 1
					for(var/obj/machinery/M in C.loc)
						if(!M.anchored)
							M.loc = C
							large_cocoon = 1
					for(var/mob/living/L in C.loc)
						if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
							continue
						large_cocoon = 1
						L.loc = C
						C.pixel_x = L.pixel_x
						C.pixel_y = L.pixel_y
						fed++
						visible_message("<span class='danger'>\the [src] sticks a proboscis into \the [L] and sucks a viscous substance out.</span>")

						break
					if(large_cocoon)
						C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
			cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/verb/LayEggs()
	set name = "Lay Eggs"
	set category = "Spider"
	set desc = "Lay a clutch of eggs, but you must wrap a creature for feeding first."

	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
	else if(!fed)
		to_chat(src, "<span class='warning'>You are too hungry to do this!</span>")
	else if(busy != LAYING_EGGS)
		busy = LAYING_EGGS
		src.visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
		stop_automated_movement = 1
		spawn(50)
			if(busy == LAYING_EGGS)
				E = locate() in get_turf(src)
				if(!E)
					var/obj/structure/spider/eggcluster/C = new /obj/structure/spider/eggcluster(src.loc)
					C.faction = faction.Copy()
					C.master_commander = master_commander
					if(ckey)
						C.player_spiders = 1
					fed--
			busy = 0
			stop_automated_movement = 0

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON

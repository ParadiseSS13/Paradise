//A slow but strong beast that tries to stun using its tentacles
/mob/living/simple_animal/hostile/asteroid/goliath
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_to_delay = 40
	ranged = TRUE
	ranged_cooldown_time = 120
	friendly = "wails at"
	speak_emote = list("bellows")
	vision_range = 4
	speed = 3
	maxHealth = 300
	health = 300
	harm_intent_damage = 1 //Only the manliest of men can kill a Goliath with only their fists.
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "pulverizes"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "does nothing to the rocky hide of the"
	vision_range = 5
	aggro_vision_range = 9
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	gender = NEUTER
	sentience_type = SENTIENCE_OTHER
	var/pre_attack = FALSE
	var/pre_attack_icon = "Goliath_preattack"
	loot = list(/obj/item/stack/sheet/animalhide/goliath_hide)
	var/draconian = 0
	var/tamed = FALSE
	var/mutable_appearance/draconian_overlay

/mob/living/simple_animal/hostile/asteroid/goliath/Life()
	. = ..()
	handle_preattack()
	if(stat != DEAD && (getBruteLoss() || getFireLoss())) // Regens health slowly
		adjustBruteLoss(-0.2)
		adjustFireLoss(-0.2)

/mob/living/simple_animal/hostile/asteroid/goliath/proc/handle_preattack()
	if(ranged_cooldown <= world.time + ranged_cooldown_time * 0.25 && !pre_attack)
		pre_attack++
	if(!pre_attack || stat || AIStatus == AI_IDLE)
		return
	icon_state = pre_attack_icon

/mob/living/simple_animal/hostile/asteroid/goliath/revive()
	..()
	anchored = TRUE

/mob/living/simple_animal/hostile/asteroid/goliath/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	..(gibbed)

/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire()
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)//Screen range check, so you can't get tentacle'd offscreen
		visible_message("<span class='warning'>[src] digs its tentacles under [target]!</span>")
		new /obj/effect/temp_visual/goliath_tentacle/original(tturf, src)
		ranged_cooldown = world.time + ranged_cooldown_time
		icon_state = icon_aggro
		pre_attack = FALSE

/mob/living/simple_animal/hostile/asteroid/goliath/adjustHealth(amount, updating_health = TRUE)
	ranged_cooldown -= 10
	handle_preattack()
	. = ..()

/mob/living/simple_animal/hostile/asteroid/goliath/Aggro()
	vision_range = aggro_vision_range
	handle_preattack()
	if(icon_state != icon_aggro)
		icon_state = icon_aggro

//Lavaland Goliath
/mob/living/simple_animal/hostile/asteroid/goliath/beast
	name = "goliath"
	desc = "A hulking, armor-plated beast with long tendrils arching from its back."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath"
	icon_living = "goliath"
	icon_aggro = "goliath"
	icon_dead = "goliath_dead"
	throw_message = "does nothing to the tough hide of the"
	pre_attack_icon = "goliath2"
	crusher_loot = /obj/item/crusher_trophy/goliath_tentacle
	butcher_results = list(/obj/item/reagent_containers/food/snacks/goliath = 2, /obj/item/stack/sheet/animalhide/goliath_hide = 1, /obj/item/stack/sheet/bone = 2)
	loot = list()
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE

/mob/living/simple_animal/hostile/asteroid/goliath/beast/random/Initialize(mapload)
	. = ..()
	if(prob(10))
		new /mob/living/simple_animal/hostile/asteroid/goliathjuv(loc)
		return INITIALIZE_HINT_QDEL
	if(prob(1))
		new /mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient(loc)
		return INITIALIZE_HINT_QDEL

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient
	name = "ancient goliath"
	desc = "Goliaths are biologically immortal, and rare specimens have survived for centuries. This one is clearly ancient, and its tentacles constantly churn the earth around it."
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	maxHealth = 400
	health = 400
	speed = 4
	pre_attack_icon = "Goliath_preattack"
	throw_message = "does nothing to the rocky hide of the"
	loot = list(/obj/item/stack/sheet/animalhide/goliath_hide) //A throwback to the asteroid days
	butcher_results = list(/obj/item/reagent_containers/food/snacks/goliath = 2, /obj/item/stack/sheet/bone = 2)
	crusher_drop_mod = 30
	wander = FALSE
	var/list/cached_tentacle_turfs
	var/turf/last_location
	var/tentacle_recheck_cooldown = 100
	var/juvgoliathsspawned = 0

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/Life()
	. = ..()
	if(!.) // dead
		return
	if(isturf(loc))
		if(!LAZYLEN(cached_tentacle_turfs) || loc != last_location || tentacle_recheck_cooldown <= world.time)
			LAZYCLEARLIST(cached_tentacle_turfs)
			last_location = loc
			tentacle_recheck_cooldown = world.time + initial(tentacle_recheck_cooldown)
			for(var/turf/simulated/floor/T in orange(4, loc))
				LAZYADD(cached_tentacle_turfs, T)
		for(var/t in cached_tentacle_turfs)
			if(isfloorturf(t))
				if(prob(10))
					new /obj/effect/temp_visual/goliath_tentacle(t, src)
			else
				cached_tentacle_turfs -= t
	if(target && prob(20) && juvgoliathsspawned <= 2) // Spawn juvenile goliaths to aid in combat. Maximum of 3.
		var/mob/living/simple_animal/hostile/asteroid/goliathjuv/G = new /mob/living/simple_animal/hostile/asteroid/goliathjuv(loc)
		G.admin_spawned = admin_spawned
		G.GiveTarget(target)
		G.friends = friends
		G.faction = faction.Copy()
		visible_message("<span class='warning'>[src] matter splits off to form a smaller monster!</span>")
		juvgoliathsspawned++
		G.creator = src
	if(stat != DEAD && juvgoliathsspawned <= 4) // Pickup stray juveniles for a max of 5, up from 3 it can spawn
		for(var/mob/living/simple_animal/hostile/asteroid/goliathjuv/G in GLOB.living_mob_list)
			if(isturf(G.loc) && get_dist(G, src) <= 7 && (G.creator == null || G.creator.stat == DEAD) && G.tamed == 0)
				G.creator = src
				juvgoliathsspawned++
		return

/mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril
	fromtendril = TRUE

/mob/living/simple_animal/hostile/asteroid/goliath/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		var/list/msgs = list()
		if(draconian)
			msgs += "<span class='warning'>It has streaks of magma coursing through its body!</span>"
		if(key)
			msgs += "<span class='warning'>It appears to be more aware of its surroundings.</span>"
		if(tamed)
			msgs += "<span class='notice'>It appears to have been tamed.</span>"
		. += msgs.Join("<BR>")

//Tentacles
/obj/effect/temp_visual/goliath_tentacle
	name = "goliath tentacle"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath_tentacle_spawn"
	layer = BELOW_MOB_LAYER
	var/mob/living/spawner

/obj/effect/temp_visual/goliath_tentacle/Initialize(mapload, mob/living/new_spawner)
	. = ..()
	for(var/obj/effect/temp_visual/goliath_tentacle/T in loc)
		if(T != src)
			return INITIALIZE_HINT_QDEL
	if(!QDELETED(new_spawner))
		spawner = new_spawner
	if(ismineralturf(loc))
		var/turf/simulated/mineral/M = loc
		M.gets_drilled()
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, .proc/tripanim), 7, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/original/Initialize(mapload, new_spawner)
	. = ..()
	if(spawner.maxHealth <= 150) // Normal subadults only spawn 2 tentacles
		var/list/directions = cardinal.Copy()
		for(var/i in 1 to 1)
			var/spawndir = pick_n_take(directions)
			var/turf/T = get_step(src, spawndir)
			if(T)
				new /obj/effect/temp_visual/goliath_tentacle(T, spawner)
	if(spawner.maxHealth >= 151 && spawner.maxHealth <= 399) // Range at which subadults/adults use 3 tentacles
		var/list/directions = cardinal.Copy()
		for(var/i in 1 to 3)
			var/spawndir = pick_n_take(directions)
			var/turf/T = get_step(src, spawndir)
			if(T)
				new /obj/effect/temp_visual/goliath_tentacle(T, spawner)
	else if(spawner.maxHealth >= 400) // Ancients and level 1 dragonsflame use 4
		var/list/directions = cardinal.Copy()
		for(var/i in 1 to 4)
			var/spawndir = pick_n_take(directions)
			var/turf/T = get_step(src, spawndir)
			if(T)
				new /obj/effect/temp_visual/goliath_tentacle(T, spawner)

/obj/effect/temp_visual/goliath_tentacle/proc/tripanim()
	icon_state = "Goliath_tentacle_wiggle"
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, .proc/trip), 3, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/proc/trip()
	var/latched = FALSE
	for(var/mob/living/L in loc)
		if((!QDELETED(spawner) && spawner.faction_check_mob(L)) || L.stat == DEAD)
			continue
		visible_message("<span class='danger'>[src] grabs hold of [L]!</span>")
		if(spawner.maxHealth >= 151)
			L.Stun(5)
		else
			L.Weaken(2) // 4 seconds of falling over if you are tripped by a subadult
		L.adjustBruteLoss(rand(10,15))
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, .proc/retract), 10, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/proc/retract()
	icon_state = "Goliath_tentacle_retract"
	deltimer(timerid)
	timerid = QDEL_IN(src, 7)

/mob/living/simple_animal/hostile/asteroid/goliath/proc/add_draconian_effect() // Apply the draconian overlay
	cut_overlay(draconian_overlay)
	var/status
	if(draconian == 0)
		return
	if(stat == DEAD)
		status = "_dead"
	if(draconian == 0)
		return
	draconian_overlay = mutable_appearance('icons/mob/lavaland/lavaland_monsters.dmi', "goliath_glow_adult[status]")
	if(draconian == 1)
		draconian_overlay.alpha = 150
	if(draconian == 2)
		draconian_overlay.alpha = 255
	add_overlay(draconian_overlay)

/mob/living/simple_animal/hostile/asteroid/goliath/death()
	..()
	add_draconian_effect(draconian_overlay)

/mob/living/simple_animal/hostile/asteroid/goliath/revive()
	..()
	add_draconian_effect(draconian_overlay)

// Juvenile Goliath

#define MEAT /obj/item/reagent_containers/food/snacks/meat
#define CORE /obj/item/organ/internal/regenerative_core
#define FLORA /obj/item/reagent_containers/food/snacks/grown/ash_flora
#define ORGANS /obj/item/organ/internal
#define DIAMOND /obj/item/stack/ore/diamond
#define CYBERORGAN /obj/item/organ/internal/cyberimp
#define DRAGONSBLOOD /obj/item/dragons_blood

/mob/living/simple_animal/hostile/asteroid/goliathjuv // Uncommon speedy monster
	name = "juvenile goliath"
	desc = "A small red animal. It looks like it can run fast!"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_baby"
	icon_living = "goliath_baby"
	icon_dead = "goliath_baby_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_ICON
	friendly = "wails at"
	speak_emote = list("chirps")
	vision_range = 4
	speed = 1
	maxHealth = 100
	health = 100
	ranged = FALSE
	ranged_cooldown_time = 60
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	vision_range = 5
	aggro_vision_range = 9
	gender = NEUTER
	environment_smash = 1
	sentience_type = SENTIENCE_OTHER
	var/growth = 0
	var/subadult = 0
	var/pre_attack = FALSE
	var/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/creator = null
	var/tame_progress = 0
	var/picking_candidates = FALSE
	var/tamed = 0 // 0 = wild, 1 = neutral, 2 = tamed & player controlled
	var/food_wanted = MEAT // Meat by default
	var/feed_cooldown = 0
	var/draconian = 0 // Can go up to 2
	var/mutable_appearance/draconian_overlay

/mob/living/simple_animal/hostile/asteroid/goliathjuv/subadult
	growth = 599

/mob/living/simple_animal/hostile/asteroid/goliathjuv/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Growth: [(growth*100)/1200]%.")

/mob/living/simple_animal/hostile/asteroid/goliathjuv/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		var/list/msgs = list()
		if(draconian)
			msgs += "<span class='warning'>It has streaks of magma coursing through its body!</span>"
		if(key)
			msgs += "<span class='warning'>It appears to be more aware of its surroundings.</span>"
		if(tamed == 1)
			msgs += "<span class='notice'>It appears to be passive.</span>"
		if(tamed == 2)
			msgs += "<span class='notice'>It appears to have been tamed.</span>"
		if(tamed != 2) // No need to let people know if it wants to eat something if it's tamed
			if(food_wanted == MEAT)
				msgs += "<span class='notice'>You think you could feed it something...</span>"
			if(food_wanted == CORE)
				msgs += "<span class='notice'>It seems to want to eat something refreshing!</span>"
			if(food_wanted == FLORA)
				msgs += "<span class='notice'>It seems to want to eat something envigorating!</span>"
			if(food_wanted == ORGANS)
				msgs += "<span class='notice'>It seems to want to eat something soft!</span>"
			if(food_wanted == DIAMOND)
				msgs += "<span class='notice'>It seems to want to eat something crunchy!</span>"
		. += msgs.Join("<BR>")

/mob/living/simple_animal/hostile/asteroid/goliathjuv/Life()
	..()
	if(stat != DEAD)
		growth++
		if(tame_progress >= 1 && tamed != 2) // Lose taming progress with time, unless you've been tamed
			tame_progress--
		if(feed_cooldown >= 1) // Lower the cooldown to be fed
			feed_cooldown--
		handle_preattack()
		if(tame_progress <= 599 && tamed != 0) // Become feral if left alone for too long
			tamed = 0
			visible_message("<span class='warning'>[src] looks frenzied!</span>")
			food_wanted = MEAT
		if(tame_progress >= 600 && tamed == 0) // Become neutral
			tamed = 1
			visible_message("<span class='warning'>[src] looks pacified...</span>")
			reroll_food()
		if(tame_progress >= 2400 && !picking_candidates && !key) // Become player controlled
			picking_candidates = TRUE
			becomeaware()
		if(tame_progress >= 2400 && key && tamed == 1)
			to_chat(src, "<span class='biggerdanger'>You have been tamed!</span>")
			to_chat(src, "<span class='danger'>You have been, by being fed and treated well, introduced to the non-aggressive way of living, but you have also been disowned by the creatures you previously coexisted with.</span>")
			tamed = 2
			creator.juvgoliathsspawned--
			creator = null
	if(tamed == 2)
		faction = list("neutral")
	if(tamed == 1)
		faction |= "neutral"
	if(tamed == 0)
		faction = list("mining")
	if(stat != DEAD && (getBruteLoss() || getFireLoss())) // Due to being young, their cells multiply at a quicker rate, allowing them to heal
		adjustBruteLoss(-1)
		adjustFireLoss(-1)
		if(prob(70) && tamed != 2 && tame_progress >= 1) // Lose taming progress if you were hurt
			tame_progress--
	if(!target && creator && prob(70) && stat != DEAD && creator.stat != DEAD && tamed == 0) // Stick around your ancient goliath if you're not chasing after anything and aren't being tamed
		var/turf/T = get_turf(creator)
		var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
		if(!surrounding_turfs.len)
			return
		if(get_dist(src, T) <= 6)
			return
		if(isturf(src.loc) && get_dist(src, T) <= 50)
			LoseTarget()
			Goto(pick(surrounding_turfs), move_to_delay)
			return
	if(growth >= 600 && subadult == 0 && stat != DEAD) // Grow to subadult
		name = "subadult goliath"
		subadult = 1
		maxHealth = maxHealth += 50
		health = health += 50
		speed = 2
		move_to_delay = 4
		desc = "A medium-sized red animal."
		speak_emote = list("growls")
		icon_state = "goliath_subadult"
		icon_living = "goliath_subadult"
		icon_dead = "goliath_subadult_dead"
		ranged = TRUE
		environment_smash = 2
		add_draconian_effect()
	if(growth >= 1200 && subadult == 1 && stat != DEAD) // Grow to adult
		var/mob/living/simple_animal/hostile/asteroid/goliath/beast/G = new /mob/living/simple_animal/hostile/asteroid/goliath/beast(loc)
		G.dir = dir
		if(maxHealth >= 150)
			G.maxHealth = (G.maxHealth += (maxHealth - 150))
			G.adjustBruteLoss(maxHealth - 150)
		if(mind)
			mind.transfer_to(G)
		if(tamed == 2)
			G.faction = list("neutral")
			G.tamed = TRUE
		if(draconian)
			G.draconian = draconian
			G.name = "draconian goliath"
			G.add_draconian_effect()
		qdel(src)
	if((stat == DEAD) && (tamed != 2)) // So that 1) an ancient goliath can't immediately spawn another juvenile goliath if it dies, and 2) can't easily cheese the juvenile goliath taming process
		if(prob(10))
			// 10% chance every cycle to decompose
			visible_message("<span class='notice'>\The dead body of the [src] decomposes!</span>")
			gib()
		if(tamed != 2)
			tame_progress = 0

/mob/living/simple_animal/hostile/asteroid/goliathjuv/Destroy() // When gibbed / deleted, the ancient goliath that spawned it will be able to spawn another.
	..()
	creator.juvgoliathsspawned--

/mob/living/simple_animal/hostile/asteroid/goliathjuv/death()
	..()
	add_draconian_effect(draconian_overlay)

/mob/living/simple_animal/hostile/asteroid/goliathjuv/revive()
	..()
	add_draconian_effect(draconian_overlay)

/mob/living/simple_animal/hostile/asteroid/goliathjuv/proc/reroll_food() // Picking a random preferred food to eat
	var/list/food = list(CORE,FLORA,ORGANS,DIAMOND)
	food_wanted = pick(food)

/mob/living/simple_animal/hostile/asteroid/goliathjuv/proc/becomeaware() // Becoming tamed and player controlled
	visible_message("<span class='notice'>\The [src] looks around...</span>")
	spawn()
		var/list/candidates = pollCandidates("Do you want to play as a tamed young goliath?", ROLE_SENTIENT, 1, 150)
		if(candidates.len)
			var/mob/C = pick(candidates)
			if(C)
				src.key = C.key
				to_chat(src, "<span class='biggerdanger'>You are a young goliath!</span>")
				to_chat(src, "<span class='danger'>You have been, by being fed and treated well, introduced to the non-aggressive way of living, but you have also been disowned by the creatures you previously coexisted with.</span>")
				picking_candidates = FALSE
				tamed = 2
				creator.juvgoliathsspawned--
				creator = null
		if(!src.ckey)
			visible_message("<span class='notice'>\The [src] looks undecided...</span>")
			tame_progress = 2100
			picking_candidates = FALSE
	return

/mob/living/simple_animal/hostile/asteroid/goliathjuv/attackby(obj/item/O, mob/user, params) // Feeding to tame
	if(istype(O, food_wanted))
		if(!stat && feed_cooldown <= 0)
			if(tame_progress <= 599) // Only wants meat
				user.visible_message("<span class='notice'>[user] feeds [O] to [src].</span>")
				user.drop_item()
				qdel(O)
				playsound(get_turf(src), 'sound/items/eatfood.ogg', 50, 0)
				tame_progress += rand(200, 350)
			if((tame_progress >= 600) && (!istype(O, MEAT))) // Needs more specific food
				if(food_wanted == ORGANS && (istype(O, CORE) || istype(O, CYBERORGAN))) // No legion or cyberimp organs
					return
				if(food_wanted == DIAMOND) // So that you don't accidentally feed more than one diamond
					var/obj/item/stack/ore/diamond/D = O
					if(D.amount != 1)
						to_chat(user, "<span class='warning'>\The [src] only wants one diamond!</span>")
						return
				user.visible_message("<span class='notice'>[user] feeds [O] to [src].</span>")
				user.drop_item()
				qdel(O)
				playsound(get_turf(src), 'sound/items/eatfood.ogg', 50, 0)
				if(istype(O, CORE))
					var/obj/item/organ/internal/regenerative_core/R = O
					if(!R.inert)
						tame_progress += rand(250, 450)
					else
						tame_progress += rand(150, 250) // Inert cores don't count a lot
						visible_message("<span class='notice'>\The [src] didn't like [O] too much...</span>")
				if(istype(O, FLORA))
					tame_progress += rand(150, 350)
				if(istype(O, ORGANS) && !istype(O, CORE))
					tame_progress += rand(300, 500)
				if(istype(O, DIAMOND))
					tame_progress += rand(250, 400)
				feed_cooldown = rand(30, 100)
				reroll_food()
		else // If dead or not hungry
			if(stat == DEAD)
				to_chat(user, "<span class='warning'>\The [src] is dead!</span>")
			else if(feed_cooldown >= 1)
				to_chat(user, "<span class='warning'>\The [src] is not hungry yet!</span>")
	else if(istype(O, DRAGONSBLOOD) && draconian <= 1)
		if(!stat)
			user.visible_message("<span class='notice'>[user] feeds [O] to [src].</span>")
			user.drop_item()
			qdel(O)
			playsound(get_turf(src), 'sound/items/drink.ogg', 50, 0)
			tame_progress += rand(950, 1200)
			maxHealth = maxHealth += 100
			health = health += 100
			to_chat(src, "<span class='biggerdanger'>You feel flames coursing through your body!</span>")
			draconian++
			add_draconian_effect()
	else
		..()

/mob/living/simple_animal/hostile/asteroid/goliathjuv/proc/handle_preattack()
	if(ranged_cooldown <= world.time + ranged_cooldown_time * 0.25 && !pre_attack)
		pre_attack++
	if(!pre_attack || stat || AIStatus == AI_IDLE)
		return

/mob/living/simple_animal/hostile/asteroid/goliathjuv/OpenFire()
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)//Screen range check, so you can't get tentacle'd offscreen
		visible_message("<span class='warning'>[src] digs its tentacles under [target]!</span>")
		new /obj/effect/temp_visual/goliath_tentacle/original(tturf, src)
		ranged_cooldown = world.time + ranged_cooldown_time
		pre_attack = FALSE

/mob/living/simple_animal/hostile/asteroid/goliathjuv/proc/add_draconian_effect() // Apply the draconian overlay
	cut_overlay(draconian_overlay)
	var/status
	if(draconian == 0)
		return
	if(stat == DEAD)
		status = "_dead"
	if(subadult == 0)
		draconian_overlay = mutable_appearance('icons/mob/lavaland/lavaland_monsters.dmi', "goliath_glow_juvenile[status]")
	else
		draconian_overlay = mutable_appearance('icons/mob/lavaland/lavaland_monsters.dmi', "goliath_glow_subadult[status]")
	if(draconian == 1)
		draconian_overlay.alpha = 150
	if(draconian == 2)
		draconian_overlay.alpha = 255
	add_overlay(draconian_overlay)

#undef MEAT
#undef CORE
#undef FLORA
#undef ORGANS
#undef DIAMOND
#undef CYBERORGAN
#undef DRAGONSBLOOD
/mob/living/simple_animal/hostile/asteroid/goliath
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
	attack_sound = 'sound/weapons/punch4.ogg'
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_to_delay = 40
	ranged = 1
	ranged_cooldown = 2 //By default, start the Goliath with his cooldown off so that people can run away quickly on first sight
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
	aggro_vision_range = 9
	idle_vision_range = 5
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	var/pre_attack = 0
	var/pre_attack_icon = "Goliath_preattack"
	loot = list(/obj/item/asteroid/goliath_hide{layer = 4.1})

/mob/living/simple_animal/hostile/asteroid/goliath/process_ai()
	..()
	handle_preattack()

/mob/living/simple_animal/hostile/asteroid/goliath/proc/handle_preattack()
	if(ranged_cooldown <= world.time + ranged_cooldown_time * 0.25 && !pre_attack)
		pre_attack++
	if(!pre_attack || stat || AIStatus == AI_IDLE)
		return
	icon_state = pre_attack_icon

/mob/living/simple_animal/hostile/asteroid/goliath/revive()
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	..()

/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire()
	var/tturf = get_turf(target)
	if(get_dist(src, target) <= 7)//Screen range check, so you can't get tentacle'd offscreen
		visible_message("<span class='warning'>The [src.name] digs its tentacles under [target.name]!</span>")
		new /obj/effect/temp_visual/goliath_tentacle/original(tturf, src)
		ranged_cooldown = world.time + ranged_cooldown_time
		icon_state = icon_aggro
		pre_attack = 0
	return

/mob/living/simple_animal/hostile/asteroid/goliath/adjustHealth(damage)
	ranged_cooldown--
	handle_preattack()
	..()

/mob/living/simple_animal/hostile/asteroid/goliath/Aggro()
	vision_range = aggro_vision_range
	handle_preattack()
	if(icon_state != icon_aggro)
		icon_state = icon_aggro
	return

/obj/effect/temp_visual/goliath_tentacle
	name = "Goliath tentacle"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath_tentacle_spawn"
	layer = BELOW_MOB_LAYER
	var/mob/living/spawner

/obj/effect/temp_visual/goliath_tentacle/New(var/loc, mob/living/new_spawner)
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

/obj/effect/temp_visual/goliath_tentacle/original/New(var/loc, mob/living/new_spawner)
	. = ..()
	var/list/directions = cardinal.Copy()
	for(var/i in 1 to 3)
		var/spawndir = pick_n_take(directions)
		var/turf/T = get_step(src, spawndir)
		if(T)
			new /obj/effect/temp_visual/goliath_tentacle(T, new_spawner)

	icon_state = "Goliath_tentacle_wiggle"
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, .proc/trip), 3, TIMER_STOPPABLE)

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
		L.Stun(5)
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

/obj/item/asteroid/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/items.dmi'
	icon_state = "goliath_hide"
	flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = 4

/obj/item/asteroid/goliath_hide/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		if(istype(target, /obj/item/clothing/suit/space/hardsuit/mining) || istype(target, /obj/item/clothing/head/helmet/space/hardsuit/mining) || istype(target, /obj/item/clothing/suit/space/eva/plasmaman/miner) || istype(target, /obj/item/clothing/head/helmet/space/eva/plasmaman/miner))
			var/obj/item/clothing/C = target
			var/current_armor = C.armor
			if(current_armor["melee"] < 60)
				current_armor["melee"] = min(current_armor["melee"] + 10, 60)
				to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
				qdel(src)
			else
				to_chat(user, "<span class='info'>You can't improve [C] any further.</span>")
				return
		if(istype(target, /obj/mecha/working/ripley))
			var/obj/mecha/D = target
			if(D.icon_state != "ripley-open")
				to_chat(user, "<span class='info'>You can't add armour onto the mech while someone is inside!</span>")
				return
			var/list/damage_absorption = D.damage_absorption
			if(damage_absorption["brute"] > 0.3)
				damage_absorption["brute"] = max(damage_absorption["brute"] - 0.1, 0.3)
				damage_absorption["bullet"] = damage_absorption["bullet"] - 0.05
				damage_absorption["fire"] = damage_absorption["fire"] - 0.05
				damage_absorption["laser"] = damage_absorption["laser"] - 0.025
				to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
				qdel(src)
				D.overlays += image("icon"="mecha.dmi", "icon_state"="ripley-g-open")
				D.desc = "Autonomous Power Loader Unit. Its armour is enhanced with some goliath hide plates."
				if(damage_absorption["brute"] == 0.3)
					D.overlays += image("icon"="mecha.dmi", "icon_state"="ripley-g-full-open")
					D.desc = "Autonomous Power Loader Unit. It's wearing a fearsome carapace entirely composed of goliath hide plates - the pilot must be an experienced monster hunter."
			else
				to_chat(user, "<span class='warning'>You can't improve [D] any further!</span>")
				return

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
	butcher_results = list(/obj/item/reagent_containers/food/snacks/goliath = 2, /obj/item/stack/sheet/animalhide/goliath_hide = 1, /obj/item/stack/sheet/bone = 2)
	loot = list()
	stat_attack = 1
	robust_searching = 1
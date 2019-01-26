/mob/living/simple_animal/hostile/asteroid/
	vision_range = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("mining")
	weather_immunities = list("lava","ash")
	obj_damage = 30
	environment_smash = 2
	minbodytemp = 0
	heat_damage_per_tick = 20
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	status_flags = 0
	a_intent = INTENT_HARM
	var/throw_message = "bounces off of"
	var/icon_aggro = null // for swapping to when we get aggressive
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	mob_size = MOB_SIZE_LARGE

/mob/living/simple_animal/hostile/asteroid/Aggro()
	..()
	icon_state = icon_aggro

/mob/living/simple_animal/hostile/asteroid/LoseAggro()
	..()
	if(stat == CONSCIOUS)
		icon_state = icon_living

/mob/living/simple_animal/hostile/asteroid/bullet_act(var/obj/item/projectile/P)//Reduces damage from most projectiles to curb off-screen kills
	if(!stat)
		Aggro()
	if(P.damage < 30 && P.damage_type != BRUTE)
		P.damage = (P.damage / 3)
		visible_message("<span class='danger'>The [P] has a reduced effect on [src]!</span>")
	..()

/mob/living/simple_animal/hostile/asteroid/hitby(atom/movable/AM)//No floor tiling them to death, wiseguy
	if(istype(AM, /obj/item))
		var/obj/item/T = AM
		if(!stat)
			Aggro()
		if(T.throwforce <= 20)
			visible_message("<span class='notice'>The [T.name] [src.throw_message] [src.name]!</span>")
			return
	..()

/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
	desc = "A territorial beast, covered in a thick shell that absorbs energy. Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	projectiletype = /obj/item/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "stares"
	ranged_cooldown_time = 30
	throw_message = "does nothing against the hard shell of"
	vision_range = 2
	speed = 3
	maxHealth = 200
	health = 200
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites into"
	a_intent = INTENT_HARM
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	aggro_vision_range = 9
	idle_vision_range = 2
	turns_per_move = 5
	loot = list(/obj/item/stack/ore/diamond{layer = 4.1},
				/obj/item/stack/ore/diamond{layer = 4.1})

/obj/item/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	temperature = 50

/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(var/new_target)
	if(..()) //we have a target
		if(isliving(target))
			var/mob/living/L = target
			if(L.bodytemperature > 261)
				L.bodytemperature = 261
				visible_message("<span class='danger'>The [src.name]'s stare chills [L.name] to the bone!</span>")

/mob/living/simple_animal/hostile/asteroid/basilisk/ex_act(severity)
	switch(severity)
		if(1.0)
			gib()
		if(2.0)
			adjustBruteLoss(140)
		if(3.0)
			adjustBruteLoss(110)

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
	loot = list(/obj/item/asteroid/goliath_hide{layer = 4.1})

/mob/living/simple_animal/hostile/asteroid/goliath/process_ai()
	..()
	handle_preattack()

/mob/living/simple_animal/hostile/asteroid/goliath/proc/handle_preattack()
	if(ranged_cooldown <= world.time + ranged_cooldown_time * 0.25 && !pre_attack)
		pre_attack++
	if(!pre_attack || stat || AIStatus == AI_IDLE)
		return
	icon_state = "Goliath_preattack"

/mob/living/simple_animal/hostile/asteroid/goliath/revive()
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	..()

/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire()
	var/tturf = get_turf(target)
	if(get_dist(src, target) <= 7)//Screen range check, so you can't get tentacle'd offscreen
		visible_message("<span class='warning'>The [src.name] digs its tentacles under [target.name]!</span>")
		new /obj/effect/goliath_tentacle/original(tturf)
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

/obj/effect/goliath_tentacle/
	name = "Goliath tentacle"
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goliath_tentacle"
	var/latched = 0

/obj/effect/goliath_tentacle/New()
	var/turftype = get_turf(src)
	if(istype(turftype, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = turftype
		M.gets_drilled()
	spawn(20)
		Trip()

/obj/effect/goliath_tentacle/original

/obj/effect/goliath_tentacle/original/New()
	for(var/obj/effect/goliath_tentacle/original/O in loc)//No more GG NO RE from 2+ goliaths simultaneously tentacling you
		if(O != src)
			qdel(src)
	var/list/directions = cardinal.Copy()
	var/counter
	for(counter = 1, counter <= 3, counter++)
		var/spawndir = pick(directions)
		directions -= spawndir
		var/turf/T = get_step(src,spawndir)
		new /obj/effect/goliath_tentacle(T)
	..()


/obj/effect/goliath_tentacle/proc/Trip()
	for(var/mob/living/M in src.loc)
		M.Stun(5)
		M.adjustBruteLoss(rand(10,15))
		latched = 1
		if(src && M)
			visible_message("<span class='danger'>The [src.name] grabs hold of [M.name]!</span>")
	if(!latched)
		qdel(src)
	else
		spawn(50)
			qdel(src)

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
			if(current_armor.["melee"] < 60)
				current_armor.["melee"] = min(current_armor.["melee"] + 10, 60)
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
				if(damage_absorption.["brute"] == 0.3)
					D.overlays += image("icon"="mecha.dmi", "icon_state"="ripley-g-full-open")
					D.desc = "Autonomous Power Loader Unit. It's wearing a fearsome carapace entirely composed of goliath hide plates - the pilot must be an experienced monster hunter."
			else
				to_chat(user, "<span class='warning'>You can't improve [D] any further!</span>")
				return

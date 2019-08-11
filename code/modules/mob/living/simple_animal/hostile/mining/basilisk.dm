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

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	name = "watcher"
	desc = "A levitating, eye-like creature held aloft by winglike formations of sinew. A sharp spine of crystal protrudes from its body."
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_aggro = "watcher"
	icon_dead = "watcher_dead"
	pixel_x = -10
	throw_message = "bounces harmlessly off of"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "impales"
	a_intent = INTENT_HARM
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	stat_attack = 1
	flying = TRUE
	robust_searching = 1
	loot = list()
	butcher_results = list(/obj/item/stack/ore/diamond = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 1)

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/Initialize()
	. = ..()
	if(prob(1))
		if(prob(75))
			new /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing(loc)
		else
			new /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing(loc)
		return INITIALIZE_HINT_QDEL

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing
	name = "magmawing watcher"
	desc = "When raised very close to lava, some watchers adapt to the extreme heat and use lava as both a weapon and wings."
	icon_state = "watcher_magmawing"
	icon_living = "watcher_magmawing"
	icon_aggro = "watcher_magmawing"
	icon_dead = "watcher_magmawing_dead"
	maxHealth = 215 //Compensate for the lack of slowdown on projectiles with a bit of extra health
	health = 215
	light_range = 3
	light_power = 2.5
	light_color = LIGHT_COLOR_ORANGE
	projectiletype = /obj/item/projectile/temp/basilisk/magmawing

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing
	name = "icewing watcher"
	desc = "Very rarely, some watchers will eke out an existence far from heat sources. In the absence of warmth, they become icy and fragile but fire much stronger freezing blasts."
	icon_state = "watcher_icewing"
	icon_living = "watcher_icewing"
	icon_aggro = "watcher_icewing"
	icon_dead = "watcher_icewing_dead"
	maxHealth = 170
	health = 170
	projectiletype = /obj/item/projectile/temp/basilisk/icewing
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/bone = 1) //No sinew; the wings are too fragile to be usable

/obj/item/projectile/temp/basilisk/magmawing
	name = "scorching blast"
	icon_state = "lava"
	damage = 5
	damage_type = BURN
	nodamage = FALSE
	temperature = 500 //Heats you up!

/obj/item/projectile/temp/basilisk/magmawing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if (istype(L))
			L.adjust_fire_stacks(0.1)
			L.IgniteMob()

/obj/item/projectile/temp/basilisk/icewing
	damage = 5
	damage_type = BURN
	nodamage = FALSE

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril
	fromtendril = TRUE
/mob/living/simple_animal/hostile/asteroid/abandoned_minebot
	name = "abandoned minebot"
	desc = "The instructions printed on the side are faded, and the only thing that remains is mechanical bloodlust."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone_offense"
	icon_living = "mining_drone_offense"
	icon_aggro = "mining_drone_alert"
	mob_biotypes = MOB_ROBOTIC
	vision_range = 6
	aggro_vision_range = 7
	status_flags = CANPUSH
	mouse_opacity = MOUSE_OPACITY_ICON
	weather_immunities = list("ash")
	move_to_delay = 10
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 10
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	check_friendly_fire = TRUE
	stop_automated_movement_when_pulled = TRUE
	attacktext = "drills into"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	projectiletype = /obj/item/projectile/kinetic
	projectilesound = 'sound/weapons/kenetic_accel.ogg'
	ranged_cooldown_time = 30
	ranged_message = "fires"
	speak_emote = list("states")
	del_on_death = TRUE
	light_range = 5
	var/sight_flags = SEE_TURFS
	ranged = TRUE
	retreat_distance = 2
	minimum_distance = 1
	deathmessage = "blows apart!"

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/Initialize(mapload)
	. = ..()
	loot += pick(
		/obj/item/borg/upgrade/modkit/chassis_mod,
		/obj/item/borg/upgrade/modkit/tracer/adjustable,
		/obj/item/borg/upgrade/modkit/cooldown,
		/obj/item/borg/upgrade/modkit/damage,
		/obj/item/borg/upgrade/modkit/range)
	var/ore = pick(/obj/item/stack/ore/iron, /obj/item/stack/ore/plasma, /obj/item/stack/ore/glass/basalt)
	var/i = rand(5,15)
	while(i)
		loot += ore
		i--
	loot += list(/obj/effect/decal/cleanable/blood/gibs/robot, /obj/item/pickaxe/drill)

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/GiveTarget(new_target)
	if(..()) //we have a target
		if(isliving(target) && !target.Adjacent(targets_from) && ranged_cooldown <= world.time)
			OpenFire(target)

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/adjustHealth(damage, updating_health)
	do_sparks(3, 1, src)
	. = ..()

// Copied from minebot.dm, to add to the fluff of "Hey! This is a minebot, just broken!"
/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health >= maxHealth * 0.5)
			. += "<span class='warning'>It looks slightly dented.</span>"
		else
			. += "<span class='boldwarning'>It looks severely dented!</span>"
	. += "<span class='notice'><b>[rand(-30,110)]%</b> mod capacity remaining.\nThere is some module installed, using <b>[rand(-5,35)]%</b> capacity.\n...or at least you think.</span>"

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/CanPass(atom/movable/O)
	if(istype(O, /obj/item/projectile/kinetic))
		var/obj/item/projectile/kinetic/K = O
		if(K.kinetic_gun)
			for(var/A in K.kinetic_gun.get_modkits())
				var/obj/item/borg/upgrade/modkit/M = A
				if(istype(M, /obj/item/borg/upgrade/modkit/minebot_passthrough))
					return TRUE
	return ..()

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/emp_act(severity)
	adjustHealth(100 / severity)
	visible_message("<span class='warning'>[src] crackles and buzzes violently!</span>")

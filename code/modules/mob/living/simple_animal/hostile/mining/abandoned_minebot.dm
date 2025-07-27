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
	weather_immunities = list("ash")
	move_to_delay = 10
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 10
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attacktext = "drills into"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	projectiletype = /obj/item/projectile/kinetic
	projectilesound = 'sound/weapons/kenetic_accel.ogg'
	speak_emote = list("states")
	throw_message = "does not go through the armor of"
	del_on_death = TRUE
	light_range = 4
	light_color = LIGHT_COLOR_RED
	ranged = TRUE
	dodging = FALSE // I feel like they are pretty strong as is, no need to dodge.
	retreat_distance = 2
	deathmessage = "blows apart!"
	loot = list(/obj/effect/gibspawner/robot, /obj/item/pickaxe/drill)

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/drop_loot()
	loot += pick(
		/obj/item/borg/upgrade/modkit/chassis_mod,
		/obj/item/borg/upgrade/modkit/tracer/adjustable,
		/obj/item/borg/upgrade/modkit/cooldown,
		/obj/item/borg/upgrade/modkit/damage,
		/obj/item/borg/upgrade/modkit/range)
	var/ore = pick(/obj/item/stack/ore/iron, /obj/item/stack/ore/plasma, /obj/item/stack/ore/glass/basalt)
	new ore(loc, rand(5, 15))
	. = ..()

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/GiveTarget(new_target)
	if(!..())
		return
	if(isliving(target) && !target.Adjacent(targets_from) && ranged_cooldown <= world.time)
		OpenFire(target)

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/adjustHealth(damage, updating_health)
	if(prob(20))
		do_sparks(3, 1, src)
	. = ..()

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/Move(atom/newloc)
	if(newloc && (islava(newloc) || ischasm(newloc))) //minebots aren't lava-resistant. Would be a shame if they just died.
		return FALSE
	return ..()

// Copied from minebot.dm, to add to the fluff of "Hey! This is a minebot, just broken!"
/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health >= maxHealth * 0.5)
			. += "<span class='warning'>It looks slightly dented.</span>"
		else
			. += "<span class='boldwarning'>It looks severely dented!</span>"
	. += "<span class='notice'><b>[rand(-30, 110)]%</b> mod capacity remaining.\nThere is a module installed, using <b>[rand(-5, 35)]%</b> capacity.\n...or at least you think so.</span>"

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/CanPass(atom/movable/O)
	if(!istype(O, /obj/item/projectile/kinetic))
		return ..()
	var/obj/item/projectile/kinetic/K = O
	if(K.kinetic_gun)
		for(var/A in K.kinetic_gun.get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			if(istype(M, /obj/item/borg/upgrade/modkit/minebot_passthrough))
				return TRUE

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/emp_act(severity)
	adjustHealth(100 / severity)
	visible_message("<span class='warning'>[src] crackles and buzzes violently!</span>")

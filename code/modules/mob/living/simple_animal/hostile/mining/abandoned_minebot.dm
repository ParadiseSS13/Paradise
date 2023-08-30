/mob/living/simple_animal/hostile/asteroid/abandoned_minebot
	name = "abandoned minebot"
	desc = "The instructions printed on the side are faded, and the only thing that remains is mechanical bloodlust."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "mining_drone_offense"
	icon_living = "mining_drone_offense"
	icon_aggro = "mining_drone_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ROBOTIC | MOB_BEAST
	vision_range = 4
	aggro_vision_range = 7
	status_flags = CANSTUN|CANKNOCKDOWN|CANPUSH
	mouse_opacity = MOUSE_OPACITY_ICON
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
	projectiletype = /obj/item/projectile/kinetic/miner
	projectilesound = 'sound/weapons/kenetic_accel.ogg'
	ranged_cooldown_time = 30
	ranged_message = "fires"
	a_intent = INTENT_HARM
	speak_emote = list("states")
	del_on_death = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_on = TRUE
	ranged = TRUE
	retreat_distance = 2
	minimum_distance = 1

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/Initialize(mapload)
	. = ..()
	loot += pick(
		/obj/item/borg/upgrade/modkit/minebot_passthrough,
		/obj/item/borg/upgrade/modkit/chassis_mod = 15,
		/obj/item/borg/upgrade/modkit/tracer = 15,
		/obj/item/borg/upgrade/modkit/cooldown = 6,
		/obj/item/borg/upgrade/modkit/damage = 6,
		/obj/item/borg/upgrade/modkit/range = 6)

/mob/living/simple_animal/hostile/asteroid/abandoned_minebot/GiveTarget(new_target)
	if(..()) //we have a target
		if(isliving(target) && !target.Adjacent(targets_from) && ranged_cooldown <= world.time)
			OpenFire(target)

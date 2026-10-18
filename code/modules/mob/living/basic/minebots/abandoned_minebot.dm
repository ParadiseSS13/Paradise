/mob/living/basic/abandoned_minebot
	name = "abandoned minebot"
	desc = "The instructions printed on the side are faded, and the only thing that remains is mechanical bloodlust."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone_offense"
	icon_living = "mining_drone_offense"
	mob_biotypes = MOB_ROBOTIC
	status_flags = CANPUSH
	weather_immunities = list("ash")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 10
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attack_verb_continuous = "drills into"
	attack_verb_simple = "drill into"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	speak_emote = list("states")
	basic_mob_flags = DEL_ON_DEATH
	light_range = 4
	light_color = LIGHT_COLOR_RED
	death_message = "blows apart!"
	faction = list("hostile", "ashwalker", "mining") // no infighting with the local fauna
	ai_controller = /datum/ai_controller/basic_controller/minebot/abandoned_minebot_ranged
	is_ranged = TRUE
	projectile_type = /obj/projectile/kinetic/abandoned_minebot
	projectile_sound = 'sound/weapons/kenetic_accel.ogg'
	ranged_cooldown = 3 SECONDS
	var/obj/item/gun/energy/kinetic_accelerator/minebot/stored_gun

	/// the modkit that the minebot is upgraded with and will drop on death
	var/obj/item/modkit_drop

/mob/living/basic/abandoned_minebot/Initialize(mapload)
	if(!modkit_drop)
		modkit_drop = pick(
			/obj/item/borg/upgrade/modkit/chassis_mod,
			/obj/item/borg/upgrade/modkit/tracer/adjustable,
			/obj/item/borg/upgrade/modkit/cooldown,
			/obj/item/borg/upgrade/modkit/damage,
			/obj/item/borg/upgrade/modkit/range)

	// depending on which modkit is picked, edit the minebot's stats
	switch(modkit_drop)
		if(/obj/item/borg/upgrade/modkit/chassis_mod)
			// have us survive one or two extra un-upgraded PKA shots because of our chassis upgrade
			var/health_buff = rand(40,80)
			maxHealth += health_buff
			health += health_buff
		if(/obj/item/borg/upgrade/modkit/cooldown)
			ranged_cooldown *= 0.8
		if(/obj/item/borg/upgrade/modkit/damage)
			projectile_type = /obj/projectile/kinetic/abandoned_minebot/damage
		if(/obj/item/borg/upgrade/modkit/range)
			projectile_type = /obj/projectile/kinetic/abandoned_minebot/range

	stored_gun = new(src)
	return ..()

/mob/living/basic/abandoned_minebot/drop_loot(message = TRUE)
	var/ore = pick(/obj/item/stack/ore/iron, /obj/item/stack/ore/plasma, /obj/item/stack/ore/glass/basalt)
	new ore(loc, rand(5, 15))
	new modkit_drop(loc)
	return ..()

/mob/living/basic/abandoned_minebot/adjustHealth(damage, updating_health)
	if(prob(20))
		do_sparks(3, 1, src)
	return ..()

/mob/living/basic/abandoned_minebot/Move(atom/newloc, direct, glide_size_override, update_dir)
	if(newloc && (islava(newloc) || ischasm(newloc))) // Minebots aren't lava-resistant. Would be a shame if they just died.
		return FALSE
	return ..()

/mob/living/basic/abandoned_minebot/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
    . = ..()

    if(!. || !proximity_flag || (a_intent == INTENT_HARM))
        return

    if(istype(attack_target, /obj/item/stack/ore))
        var/obj/item/stack/ore/target_ore = attack_target
        target_ore.forceMove(src)

    return ..()

/mob/living/basic/abandoned_minebot/examine(mob/user)
    . = ..()
    if(health < maxHealth)
        if(health >= maxHealth * 0.5)
            . += SPAN_WARNING("It looks slightly dented.")
        else
            . += SPAN_BOLDWARNING("It looks severely dented!")
    // randomizing these percentages for the sake of double takes and not gaming what upgrade is installed
    . += SPAN_NOTICE("<b>[rand(-35, 110)]%</b> mod capacity remaining.")
    . += SPAN_NOTICE("There is a module installed, using <b>[rand(-5, 35)]%</b> capacity.")

/mob/living/basic/abandoned_minebot/CanPass(atom/movable/O)
	if(istype(O, /obj/projectile/kinetic))
		var/obj/projectile/kinetic/K = O
		if(K.kinetic_gun)
			for(var/A in K.kinetic_gun.get_modkits())
				var/obj/item/borg/upgrade/modkit/M = A
				if(istype(M, /obj/item/borg/upgrade/modkit/minebot_passthrough))
					return TRUE
	return ..()

/mob/living/basic/abandoned_minebot/emp_act(severity)
	adjustHealth(100 / severity)
	visible_message(SPAN_WARNING("[src] crackles and buzzes violently!"))

/obj/projectile/kinetic/abandoned_minebot/on_hit(atom/target)
	var/mob/living/basic/abandoned_minebot/minebot = firer
	var/mob/living/victim = target
	if(istype(minebot) && istype(victim, /mob/living/carbon/human) && victim.client)
		// these are pulled from minebot_ai.dm, we're an old, worn-out minebot that has lost its ability to know what to say
		INVOKE_ASYNC(minebot, TYPE_PROC_REF(/atom, atom_say), pick("Sorry.", "My fault.", "Oops.", "Please stop hurting yourself.", "There is no need to do that.", "Your actions are illogical.", "Please make better choices.", "Remember, you have beaten your worst days before.",))
	return ..()

/obj/projectile/kinetic/abandoned_minebot/damage
	damage = 50

/obj/projectile/kinetic/abandoned_minebot/range
	range = 4

/mob/living/basic/abandoned_minebot/Destroy()
	QDEL_NULL(stored_gun)
	return ..()

/mob/living/basic/abandoned_minebot/death()
	robogibs(loc)
	new /obj/item/pickaxe/drill(loc)
	if(modkit_drop)
		new modkit_drop(loc)
	for(var/obj/item/stack/ore/O in contents)
		if(istype(O, /obj/item/stack/ore))
			O.forceMove(loc)
	return ..()

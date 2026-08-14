/mob/living/basic/bot/mulebot/MobBump(mob/bumped_mob) // called when the bot bumps into a mob
	if(mind || !isliving(bumped_mob)) //if there's a sentience controlling the bot, they aren't allowed to harm folks.
		return ..()
	var/mob/living/bumped_living = bumped_mob
	if(wires.is_cut(WIRE_MOB_AVOIDANCE)) // usually just bumps, but if the avoidance wire is cut, knocks them over.
		if(isrobot(bumped_living))
			visible_message(SPAN_DANGER("[src] bumps into [bumped_living]!"))
		else if(bumped_living.KnockDown(8 SECONDS))
			add_attack_logs(src, bumped_living, "knocked down")
			visible_message(SPAN_DANGER("[src] knocks over [bumped_living]!"))
	return ..()

/mob/living/basic/bot/mulebot/on_bot_movement(atom/movable/source, atom/oldloc, dir, forced)
	cell?.use(cell_move_power_usage)
	set_cell_hud()

	if(has_gravity())
		for(var/mob/living/carbon/human/future_pancake in loc)
			if(future_pancake.body_position == LYING_DOWN)
				run_over(future_pancake)

	return ..()

///Checks if the bot is on or if it has charge
/mob/living/basic/bot/mulebot/proc/on_pre_move()
	SIGNAL_HANDLER

	if(!(bot_mode_flags & BOT_MODE_ON))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

	if((cell && (cell.charge < cell_move_power_usage)) || !has_power())
		turn_off()
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

// when mulebot is in the same loc
/mob/living/basic/bot/mulebot/proc/run_over(mob/living/carbon/human/crushed)
	if(!(bot_access_flags & BOT_COVER_EMAGGED) && !wires.is_cut(WIRE_MOB_AVOIDANCE))
		crushed.visible_message(SPAN_NOTICE("[src] slows down to avoid crushing [crushed]."))
		return // Player mules must be emagged before they can trample

	add_attack_logs(src, crushed, "Run over(DAMTYPE: [uppertext(BRUTE)])")
	crushed.visible_message(
		SPAN_DANGER("[src] drives over [crushed]!"),
		SPAN_USERDANGER("[src] drives over you!"),
	)

	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

	var/damage = rand(5, 15)
	var/static/list/zone_damages = list(
		BODY_ZONE_HEAD = 2,
		BODY_ZONE_CHEST = 2,
		BODY_ZONE_L_LEG = 0.5,
		BODY_ZONE_R_LEG = 0.5,
		BODY_ZONE_L_ARM = 0.5,
		BODY_ZONE_R_ARM = 0.5,
	)
	for(var/body_zone in zone_damages)
		crushed.apply_damage(zone_damages[body_zone] * damage, BRUTE, body_zone, run_armor_check(body_zone, MELEE))

	add_mob_blood(crushed)

	var/turf/below_us = get_turf(src)
	crushed.add_mob_blood(crushed)
	crushed.add_splatter_floor(below_us)

	var/list/blood_dna = crushed.get_blood_dna_list()
	if(blood_dna)
		transfer_blood_dna(blood_dna)
		currentBloodColor = crushed.dna.species.blood_color

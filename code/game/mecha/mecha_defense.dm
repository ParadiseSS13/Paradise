/obj/mecha/proc/get_armour_facing(relative_dir)
	switch(relative_dir)
		if(0) // BACKSTAB!
			return facing_modifiers[BACK_ARMOUR]
		if(45, 90, 270, 315)
			return facing_modifiers[SIDE_ARMOUR]
		if(225, 180, 135)
			return facing_modifiers[FRONT_ARMOUR]
	return 1 //always return non-0

/obj/mecha/hulk_damage()
	return 15
    
/obj/mecha/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		spark_system.start()
		switch(damage_flag)
			if("fire")
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL))
			if("melee")
				check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			else
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT))
		if(. >= 5 || prob(33))
			occupant_message("<span class='userdanger'>Taking damage!</span>")
		log_append_to_last("Took [damage_amount] points of damage. Damage type: \"[damage_type]\".",1)

/obj/mecha/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	. = ..()
	var/booster_deflection_modifier = 1
	var/booster_damage_modifier = 1
	if(damage_flag == "bullet" || damage_flag == "laser" || damage_flag == "energy")
		for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/B in equipment)
			if(B.projectile_react())
				booster_deflection_modifier = B.deflect_coeff
				booster_damage_modifier = B.damage_coeff
				break
	else if(damage_flag == "melee")
		for(var/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/B in equipment)
			if(B.attack_react())
				booster_deflection_modifier *= B.deflect_coeff
				booster_damage_modifier *= B.damage_coeff
				break

	if(attack_dir)
		var/facing_modifier = get_armour_facing(dir2angle(attack_dir) - dir2angle(src))
		booster_damage_modifier /= facing_modifier
		booster_deflection_modifier *= facing_modifier
	if(prob(deflect_chance * booster_deflection_modifier))
		visible_message("<span class='danger'>[src]'s armour deflects the attack!</span>")
		log_append_to_last("Armor saved.")
		return 0
	if(.)
		. *= booster_damage_modifier


/obj/mecha/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	log_message("Attack by hand/paw. Attacker - [user].",1)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	playsound(loc, 'sound/weapons/tap.ogg', 40, 1, -1)
	user.visible_message("<span class='danger'>[user] hits [name]. Nothing happens</span>", "<span class='danger'>You hit [name] with no visible effect.</span>")
	log_append_to_last("Armor saved.")

/obj/mecha/attack_alien(mob/living/user)
	log_message("Attack by alien. Attacker - [user].",1)
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	attack_generic(user, 15, BRUTE, "melee", 0)

/obj/mecha/attack_animal(mob/living/simple_animal/user)
	log_message("Attack by simple animal. Attacker - [user].",1)
	if(!user.melee_damage_upper && !user.obj_damage)
		user.custom_emote(1, "[user.friendly] [src].")
		return 0
	else
		var/play_soundeffect = 1
		if(user.environment_smash)
			play_soundeffect = 0
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
		var/animal_damage = rand(user.melee_damage_lower,user.melee_damage_upper)
		if(user.obj_damage)
			animal_damage = user.obj_damage
		animal_damage = min(animal_damage, 20*user.environment_smash)
		attack_generic(user, animal_damage, user.melee_damage_type, "melee", play_soundeffect)
		add_logs(user, src, "attacked")
		return 1



/obj/mecha/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(.)
		check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL, MECHA_INT_TANK_BREACH, MECHA_INT_CONTROL_LOST))
		log_message("Attack by hulk. Attacker - [user].", 1)
		add_attack_logs(user, src, "Punched with hulk powers")

/obj/mecha/blob_act(obj/structure/blob/B)
	take_damage(30, BRUTE, "melee", 0, get_dir(src, B))

/obj/mecha/attack_tk()
	return

/obj/mecha/hitby(atom/movable/A as mob|obj) //wrapper
	log_message("Hit by [A].",1)
	. = ..()


/obj/mecha/bullet_act(obj/item/projectile/Proj) //wrapper
	log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).",1)
	. = ..()

/obj/mecha/ex_act(severity, target)
	log_message("Affected by explosion of severity: [severity].",1)
	if(prob(deflect_chance))
		severity++
		log_append_to_last("Armor saved, changing severity to [severity].")
	. = ..(severity, target)

/obj/mecha/emp_act(severity)
	if(get_charge())
		use_power((cell.charge/3)/(severity*2))
		take_damage(30 / severity, BURN, "energy", 1)
	log_message("EMP detected",1)
	check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)

/obj/mecha/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature>max_temperature)
		log_message("Exposed to dangerous temperature.",1)
		take_damage(5, BURN, 0, 1)

/obj/mecha/attacked_by(obj/item/I, mob/living/user)
	log_message("Attacked by [I]. Attacker - [user]")
	..()

/obj/mecha/mech_melee_attack(obj/mecha/M)
	if(M.damtype == BRUTE || M.damtype == BURN)
		add_logs(M.occupant, src, "attacked", M, "(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")
		. = ..()
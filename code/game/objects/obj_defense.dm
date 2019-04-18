//the essential proc to call when an obj must receive damage of any kind.
/obj/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if(!(resistance_flags & INDESTRUCTIBLE) && obj_integrity > 0)
		damage_amount = run_obj_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration)
		if(damage_amount >= 0.1)
			. = damage_amount
			var/old_integ = obj_integrity
			obj_integrity = max(old_integ - damage_amount, 0)
			if(obj_integrity <= 0)
				var/int_fail = integrity_failure
				if(int_fail && old_integ > int_fail)
					obj_break(damage_flag)
				obj_destruction(damage_flag)
			else if(integrity_failure)
				if(obj_integrity <= integrity_failure)
					obj_break(damage_flag)

//returns the damage value of the attack after processing the obj's various armor protections
/obj/proc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penetration = 0)
	if(!(damage_type in list(BRUTE, BURN)))
		return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor[damage_flag]
	if(armor_protection)		//Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = Clamp(armor_protection - armour_penetration, 0, 100)
	return round(damage_amount * (100 - armor_protection) * 0.01, 0.1)

//the sound played when the obj is damaged.
/obj/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/hitby(atom/movable/AM)
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else if(istype(AM, /obj))
		var/obj/O = AM
		tforce = O.throwforce
	take_damage(tforce, BRUTE, "melee", 1, get_dir(src, AM))

/obj/ex_act(severity)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	switch(severity)
		if(1)
			obj_integrity = 0
			qdel(src)
		if(2)
			take_damage(rand(100, 250), BRUTE, "bomb", 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, "bomb", 0)

/obj/bullet_act(obj/item/projectile/P)
	. = ..()
	playsound(src, P.hitsound, 50, 1)
	visible_message("<span class='danger'>[src] is hit by \a [P]!</span>")
	if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
		take_damage(P.damage, P.damage_type, P.flag, 0, turn(P.dir, 180), P.armour_penetration)

/obj/proc/hulk_damage()
	return 150 //the damage hulks do on punches to this object, is affected by melee armor

/obj/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		..(user, TRUE)
		visible_message("<span class='danger'>[user] smashes [src]!</span>")
		if(density)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		else
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
		take_damage(hulk_damage(), BRUTE, "melee", 0, get_dir(src, user))
		return TRUE
	return FALSE

/obj/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return TRUE

/obj/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	collision_damage(pusher, force, direction)
	return TRUE

/obj/proc/collision_damage(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	var/amt = max(0, ((force - (move_resist * MOVE_FORCE_CRUSH_RATIO)) / (move_resist * MOVE_FORCE_CRUSH_RATIO)) * 10)
	take_damage(amt, BRUTE)

/obj/blob_act(obj/structure/blob/B)
	if(isturf(loc))
		var/turf/T = loc
		if(T.intact && level == 1) //the blob doesn't destroy thing below the floor
			return
	take_damage(400, BRUTE, "melee", 0, get_dir(src, B))

/obj/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	return take_damage(damage_amount, damage_type, damage_flag, sound_effect, get_dir(src, user), armor_penetration)

/obj/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(attack_generic(user, 60, BRUTE, "melee", 0))
		playsound(loc, 'sound/weapons/slash.ogg', 100, 1)

/obj/attack_animal(mob/living/simple_animal/M)
	if((M.a_intent == INTENT_HELP && M.ckey) || (!M.melee_damage_upper && !M.obj_damage))
		M.custom_emote(1, "[M.friendly] [src].")
		return 0
	else
		var/play_soundeffect = 1
		if(M.environment_smash)
			play_soundeffect = 0
		if(M.obj_damage)
			. = attack_generic(M, M.obj_damage, M.melee_damage_type, "melee", play_soundeffect, M.armour_penetration)
		else
			. = attack_generic(M, rand(M.melee_damage_lower,M.melee_damage_upper), M.melee_damage_type, "melee", play_soundeffect, M.armour_penetration)
		if(. && !play_soundeffect)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)

/obj/attack_slime(mob/living/carbon/slime/user)
	if(!user.is_adult)
		return
	attack_generic(user, rand(10, 15), "melee", 1)

/obj/mech_melee_attack(obj/mecha/M)
	M.do_attack_animation(src)
	var/play_soundeffect = 0
	var/mech_damtype = M.damtype
	if(M.selected)
		mech_damtype = M.selected.damtype
		play_soundeffect = 1
	else
		switch(M.damtype)
			if(BRUTE)
				playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
			if(BURN)
				playsound(src, 'sound/items/welder.ogg', 50, 1)
			if(TOX)
				playsound(src, 'sound/effects/spray2.ogg', 50, 1)
				return 0
			else
				return 0
	visible_message("<span class='danger'>[M.name] has hit [src].</span>")
	return take_damage(M.force*3, mech_damtype, "melee", play_soundeffect, get_dir(src, M)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

/obj/singularity_act()
	ex_act(1)
	if(src && !QDELETED(src))
		qdel(src)
	return 2

//// FIRE

/obj/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	if(!burn_state)
		burn_state = ON_FIRE
		SSfires.processing[src] = src
		burn_world_time = world.time + burntime*rand(10,20)
		if(global_overlay)
			overlays += fire_overlay
		return TRUE

/obj/proc/burn()
	empty_object_contents(1, loc)
	var/obj/effect/decal/cleanable/ash/A = new(loc)
	A.desc = "Looks like this used to be a [name] some time ago."
	SSfires.processing -= src
	qdel(src)

/obj/proc/extinguish()
	if(burn_state == ON_FIRE)
		burn_state = FLAMMABLE
		overlays -= fire_overlay
		SSfires.processing -= src

/obj/proc/tesla_act(power)
	being_shocked = TRUE
	var/power_bounced = power * 0.5
	tesla_zap(src, 3, power_bounced)
	addtimer(CALLBACK(src, .proc/reset_shocked), 10)

/obj/proc/reset_shocked()
	being_shocked = FALSE

//the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	qdel(src)

//what happens when the obj's health is below integrity_failure level.
/obj/proc/obj_break(damage_flag)
	return

//what happens when the obj's integrity reaches zero.
/obj/proc/obj_destruction(damage_flag)
	if(damage_flag == BURN)
		burn()
	else
		deconstruct(FALSE)

//changes max_integrity while retaining current health percentage
//returns TRUE if the obj broke, FALSE otherwise
/obj/proc/modify_max_integrity(new_max, can_break = TRUE, damage_type = BRUTE, new_failure_integrity = null)
	var/current_integrity = obj_integrity
	var/current_max = max_integrity

	if(current_integrity != 0 && current_max != 0)
		var/percentage = current_integrity / current_max
		current_integrity = max(1, round(percentage * new_max))	//don't destroy it as a result
		obj_integrity = current_integrity

	max_integrity = new_max

	if(new_failure_integrity != null)
		integrity_failure = new_failure_integrity

	if(can_break && integrity_failure && current_integrity <= integrity_failure)
		obj_break(damage_type)
		return TRUE
	return FALSE

//returns how much the object blocks an explosion
/obj/proc/GetExplosionBlock()
	CRASH("Unimplemented GetExplosionBlock()")

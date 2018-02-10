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
	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor[damage_flag]
	if(armor_protection)		//Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = Clamp(armor_protection - armour_penetration, 0, 100)
	return round(damage_amount * (100 - armor_protection)*0.01, 0.1)

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
	else if(isobj(AM))
		var/obj/O = AM
		tforce = O.throwforce
	take_damage(tforce, BRUTE, "melee", 1, get_dir(src, AM))

/obj/singularity_act()
	ex_act(1)
	if(src && !qdeleted(src))
		qdel(src)
	return 2

//// FIRE

/obj/fire_act(global_overlay=1)
	if(!burn_state)
		burn_state = ON_FIRE
		fire_master.burning += src
		burn_world_time = world.time + burntime*rand(10,20)
		if(global_overlay)
			overlays += fire_overlay
		return 1

/obj/proc/burn()
	empty_object_contents(1, loc)
	var/obj/effect/decal/cleanable/ash/A = new(loc)
	A.desc = "Looks like this used to be a [name] some time ago."
	fire_master.burning -= src
	qdel(src)

/obj/proc/extinguish()
	if(burn_state == ON_FIRE)
		burn_state = FLAMMABLE
		overlays -= fire_overlay
		fire_master.burning -= src

/obj/proc/tesla_act(power)
	being_shocked = TRUE
	var/power_bounced = power * 0.5
	tesla_zap(src, 3, power_bounced)
	addtimer(src, "reset_shocked", 10)

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
	if(damage_flag == "fire")
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

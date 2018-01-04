
/obj/proc/take_damage()
	return

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
//I will need to recode parts of this but I am way too tired atm
/obj/structure/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	light_range = 3
	desc = "Some blob creature thingy"
	density = 0
	opacity = 0
	anchored = 1
	max_integrity = 30
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	var/point_return = 0 //How many points the blob gets back when it removes a blob of that type. If less than 0, blob cannot be removed.
	var/health_timestamp = 0
	var/brute_resist = 0.5 //multiplies brute damage by this
	var/fire_resist = 1 //multiplies burn damage by this
	var/atmosblock = FALSE //if the blob blocks atmos and heat spread
	var/mob/camera/blob/overmind

/obj/structure/blob/New(loc)
	..()
	GLOB.blobs += src
	setDir(pick(GLOB.cardinal))
	update_icon()
	if(atmosblock)
		air_update_turf(1)
	ConsumeTile()

/obj/structure/blob/Destroy()
	if(atmosblock)
		atmosblock = FALSE
		air_update_turf(1)
	GLOB.blobs -= src
	if(isturf(loc)) //Necessary because Expand() is retarded and spawns a blob and then deletes it
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
	return ..()

/obj/structure/blob/BlockSuperconductivity()
	return atmosblock

/obj/structure/blob/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover) && mover.checkpass(PASSBLOB))
		return 1
	return 0

/obj/structure/blob/CanAtmosPass(turf/T)
	return !atmosblock

/obj/structure/blob/CanAStarPass(ID, dir, caller)
	. = 0
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSBLOB)

/obj/structure/blob/process()
	Life()
	return

/obj/structure/blob/blob_act(obj/structure/blob/B)
	return

/obj/structure/blob/proc/Life()
	return

/obj/structure/blob/proc/RegenHealth()
	// All blobs heal over time when pulsed, but it has a cool down
	if(health_timestamp > world.time)
		return 0
	if(obj_integrity < max_integrity)
		obj_integrity = min(max_integrity, obj_integrity + 1)
		update_icon()
		health_timestamp = world.time + 10 // 1 seconds


/obj/structure/blob/proc/Pulse(var/pulse = 0, var/origin_dir = 0, var/a_color)//Todo: Fix spaceblob expand

	set background = BACKGROUND_ENABLED

	RegenHealth()

	if(run_action())//If we can do something here then we dont need to pulse more
		return

	if(pulse > 30)
		return//Inf loop check

	//Looking for another blob to pulse
	var/list/dirs = list(1,2,4,8)
	dirs.Remove(origin_dir)//Dont pulse the guy who pulsed us
	for(var/i = 1 to 4)
		if(!dirs.len)	break
		var/dirn = pick(dirs)
		dirs.Remove(dirn)
		var/turf/T = get_step(src, dirn)
		var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)
		if(!B)
			expand(T,1,a_color)//No blob here so try and expand
			return
		B.adjustcolors(a_color)

		B.Pulse((pulse+1),get_dir(src.loc,T), a_color)
		return
	return


/obj/structure/blob/proc/run_action()
	return 0

/obj/structure/blob/proc/ConsumeTile()
	for(var/atom/A in loc)
		A.blob_act(src)
	if(iswallturf(loc))
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it

/obj/structure/blob/proc/expand(var/turf/T = null, var/prob = 1, var/a_color)
	if(prob && !prob(obj_integrity))
		return
	if(istype(T, /turf/space) && prob(75)) 	return
	if(!T)
		var/list/dirs = list(1,2,4,8)
		for(var/i = 1 to 4)
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			T = get_step(src, dirn)
			if(!(locate(/obj/structure/blob) in T))	break
			else	T = null

	if(!T)	return 0
	var/obj/structure/blob/normal/B = new /obj/structure/blob/normal(src.loc, min(obj_integrity, 30))
	B.color = a_color
	B.density = 1
	if(T.Enter(B,src))//Attempt to move into the tile
		B.density = initial(B.density)
		B.loc = T
	else
		T.blob_act()//If we cant move in hit the turf
		B.loc = null //So we don't play the splat sound, see Destroy()
		qdel(B)

	for(var/atom/A in T)//Hit everything in the turf
		A.blob_act(src)
	return 1

/obj/structure/blob/Crossed(var/mob/living/L, oldloc)
	..()
	L.blob_act(src)

/obj/structure/blob/tesla_act(power)
	..()
	take_damage(power / 400, BURN, "energy")

/obj/structure/blob/hulk_damage()
	return 15

/obj/structure/blob/attack_animal(mob/living/simple_animal/M)
	if(ROLE_BLOB in M.faction) //sorry, but you can't kill the blob as a blobbernaut
		return
	..()

/obj/structure/blob/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/effects/attackblob.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/blob/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	switch(damage_type)
		if(BRUTE)
			damage_amount *= brute_resist
		if(BURN)
			damage_amount *= fire_resist
		if(CLONE)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor[damage_flag]
	damage_amount = round(damage_amount * (100 - armor_protection)*0.01, 0.1)
	if(overmind && damage_flag)
		damage_amount = overmind.blob_reagent_datum.damage_reaction(src, damage_amount, damage_type, damage_flag)
	return damage_amount

/obj/structure/blob/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		update_icon()

/obj/structure/blob/proc/change_to(var/type)
	if(!ispath(type))
		error("[type] is an invalid type for the blob.")
	var/obj/structure/blob/B = new type(src.loc)
	if(!istype(type, /obj/structure/blob/core) || !istype(type, /obj/structure/blob/node))
		B.color = color
	else
		B.adjustcolors(color)
	qdel(src)

/obj/structure/blob/proc/adjustcolors(var/a_color)
	if(a_color)
		color = a_color
	return

/obj/structure/blob/examine(mob/user)
	. = ..()
	. += "It looks like it's made of [get_chem_name()]."


/obj/structure/blob/proc/get_chem_name()
	for(var/mob/camera/blob/B in GLOB.mob_list)
		if(lowertext(B.blob_reagent_datum.color) == lowertext(src.color)) // Goddamit why we use strings for these
			return B.blob_reagent_datum.name
	return "unknown"

/obj/structure/blob/normal
	icon_state = "blob"
	light_range = 0
	obj_integrity = 21 //doesn't start at full health
	max_integrity = 25
	brute_resist = 0.25

/obj/structure/blob/normal/update_icon()
	..()
	if(obj_integrity <= 15)
		icon_state = "blob_damaged"
		name = "fragile blob"
		desc = "A thin lattice of slightly twitching tendrils."
		brute_resist = 0.5
	else if(overmind)
		icon_state = "blob"
		name = "blob"
		desc = "A thick wall of writhing tendrils."
		brute_resist = 0.25
	else
		icon_state = "blob"
		name = "dead blob"
		desc = "A thick wall of lifeless tendrils."
		brute_resist = 0.25

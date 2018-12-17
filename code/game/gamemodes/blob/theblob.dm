//I will need to recode parts of this but I am way too tired atm
/obj/structure/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	light_range = 3
	desc = "Some blob creature thingy"
	density = 0
	opacity = 0
	anchored = 1
	var/health = 30
	var/health_timestamp = 0
	var/brute_resist = 4
	var/fire_resist = 1


/obj/structure/blob/New(loc)
	blobs += src
	src.dir = pick(1, 2, 4, 8)
	src.update_icon()
	..(loc)
	for(var/atom/A in loc)
		A.blob_act(src)
	return


/obj/structure/blob/Destroy()
	blobs -= src
	if(isturf(loc)) //Necessary because Expand() is retarded and spawns a blob and then deletes it
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
	return ..()


/obj/structure/blob/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)	return 1
	if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
	return 0

/obj/structure/blob/CanAStarPass(ID, dir, caller)
	. = 0
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSBLOB)

/obj/structure/blob/process()
	Life()
	return

/obj/structure/blob/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/damage = Clamp(0.01 * exposed_temperature, 0, 4)
	take_damage(damage, BURN)

/obj/structure/blob/blob_act()
	return

/obj/structure/blob/proc/Life()
	return

/obj/structure/blob/proc/RegenHealth()
	// All blobs heal over time when pulsed, but it has a cool down
	if(health_timestamp > world.time)
		return 0
	if(health < initial(health))
		health++
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


/obj/structure/blob/proc/expand(var/turf/T = null, var/prob = 1, var/a_color)
	if(prob && !prob(health))	return
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
	var/obj/structure/blob/normal/B = new /obj/structure/blob/normal(src.loc, min(src.health, 30))
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

/obj/structure/blob/ex_act(severity)
	..()
	var/damage = 150 - 20 * severity
	take_damage(damage, BRUTE)

/obj/structure/blob/bullet_act(var/obj/item/projectile/Proj)
	..()
	take_damage(Proj.damage, Proj.damage_type)
	return 0

/obj/structure/blob/Crossed(var/mob/living/L)
	..()
	L.blob_act(src)

/obj/structure/blob/tesla_act(power)
	..()
	take_damage(power/400, BURN)

/obj/structure/blob/hulk_damage()
	return 15

/obj/structure/blob/attackby(var/obj/item/W, var/mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	visible_message("<span class='danger'>[user] has attacked the [src.name] with \the [W]!</span>")
	if(W.damtype == BURN)
		playsound(src.loc, 'sound/items/welder.ogg', 100, 1)
	take_damage(W.force, W.damtype)

/obj/structure/blob/attack_animal(mob/living/simple_animal/M as mob)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	visible_message("<span class='danger'>\The [M] has attacked the [src.name]!</span>")
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	take_damage(damage, BRUTE)
	return

/obj/structure/blob/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	visible_message("<span class='danger'>[M] has slashed the [src.name]!</span>")
	var/damage = rand(15, 30)
	take_damage(damage, BRUTE)
	return

/obj/structure/blob/take_damage(damage, damage_type)
	if(!damage || damage_type == STAMINA) // Avoid divide by zero errors
		return
	switch(damage_type)
		if(BRUTE)
			damage /= max(brute_resist, 1)
		if(BURN)
			damage /= max(fire_resist, 1)
	health -= damage
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
	..(user)
	to_chat(user, "It looks like it's made of [get_chem_name()].")


/obj/structure/blob/proc/get_chem_name()
	for(var/mob/camera/blob/B in GLOB.mob_list)
		if(lowertext(B.blob_reagent_datum.color) == lowertext(src.color)) // Goddamit why we use strings for these
			return B.blob_reagent_datum.name
	return "unknown"

/obj/structure/blob/normal
	icon_state = "blob"
	light_range = 0
	health = 21

/obj/structure/blob/normal/update_icon()
	if(health <= 0)
		qdel(src)
	else if(health <= 15)
		icon_state = "blob_damaged"
	else
		icon_state = "blob"

/* // Used to create the glow sprites. Remember to set the animate loop to 1, instead of infinite!

var/datum/blob_colour/B = new()

/datum/blob_colour/New()
	..()
	var/icon/I = 'icons/mob/blob.dmi'
	I += rgb(35, 35, 0)
	if(isfile("icons/mob/blob_result.dmi"))
		fdel("icons/mob/blob_result.dmi")
	fcopy(I, "icons/mob/blob_result.dmi")

*/

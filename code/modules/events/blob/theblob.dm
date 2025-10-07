//I will need to recode parts of this but I am way too tired atm

GLOBAL_LIST_EMPTY(blobs)
GLOBAL_LIST_EMPTY(blob_nodes)
GLOBAL_LIST_EMPTY(blob_minions)

/obj/structure/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	light_range = 3
	desc = "Some blob creature thingy."
	anchored = TRUE
	max_integrity = 30
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 80, ACID = 70)
	flags_2 = CRITICAL_ATOM_2
	creates_cover = TRUE
	var/point_return = 0 //How many points the blob gets back when it removes a blob of that type. If less than 0, blob cannot be removed.
	var/health_timestamp = 0
	var/brute_resist = 0.5 //multiplies brute damage by this
	var/fire_resist = 1 //multiplies burn damage by this
	var/atmosblock = FALSE //if the blob blocks atmos and heat spread
	/// If a threshold is reached, resulting in shifting variables
	var/compromised_integrity = FALSE
	var/mob/camera/blob/overmind

/obj/structure/blob/Initialize(mapload)
	. = ..()
	GLOB.blobs += src
	setDir(pick(GLOB.cardinal))
	check_integrity()
	if(atmosblock)
		recalculate_atmos_connectivity()
	ConsumeTile()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/blob/Destroy()
	if(atmosblock)
		atmosblock = FALSE
		recalculate_atmos_connectivity()
	GLOB.blobs -= src
	overmind = null // let us not have gc issues
	if(isturf(loc)) //Necessary because Expand() is screwed up and spawns a blob and then deletes it
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
	return ..()

/obj/structure/blob/get_superconductivity(direction)
	if(atmosblock)
		return FALSE
	return ..()

/obj/structure/blob/CanPass(atom/movable/mover, border_dir)
	return istype(mover) && mover.checkpass(PASSBLOB)

/obj/structure/blob/CanAtmosPass(direction)
	return !atmosblock

/obj/structure/blob/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	. = FALSE
	if(pass_info.is_movable)
		. = . || pass_info.pass_flags & PASSBLOB

/obj/structure/blob/process()
	Life()
	return

/obj/structure/blob/blob_act(obj/structure/blob/B)
	return

/obj/structure/blob/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/kinetic))
		P.damage /= 2
	return ..()

/obj/structure/blob/proc/Life()
	return

/obj/structure/blob/proc/check_integrity()
	return

/obj/structure/blob/proc/update_state()
	return

/obj/structure/blob/proc/RegenHealth()
	// All blobs heal over time when pulsed, but it has a cool down
	if(health_timestamp > world.time)
		return FALSE

	var/turf/T = get_turf(src)
	chemical_attack(T)

	if(obj_integrity < max_integrity)
		obj_integrity = min(max_integrity, obj_integrity + 1)
		check_integrity()

	health_timestamp = world.time + 10 // 1 seconds

/obj/structure/blob/proc/chemical_attack(turf/T)
	for(var/mob/living/L in T)
		if(ROLE_BLOB in L.faction) //no friendly/dead fire
			continue
		if(!overmind)
			continue
		var/mob_protection = L.get_permeability_protection()
		overmind.blob_reagent_datum.reaction_mob(L, REAGENT_TOUCH, 25, 1, mob_protection)
		overmind.blob_reagent_datum.send_message(L)
		L.blob_act(src)

/obj/structure/blob/proc/Pulse(pulse = 0, origin_dir = 0, a_color)//Todo: Fix spaceblob expand
	RegenHealth()

	if(run_action())//If we can do something here then we dont need to pulse more
		return

	if(pulse > 30)
		return//Inf loop check

	//Looking for another blob to pulse
	var/list/dirs = list(NORTH, SOUTH, EAST, WEST)
	dirs.Remove(origin_dir)//Dont pulse the guy who pulsed us
	if(!length(dirs))
		return

	var/dirn = pick_n_take(dirs)
	var/turf/T = get_step(src, dirn)
	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	if(!B)
		expand(T, 1, a_color, overmind)	//No blob here so try and expand
		return

	B.adjustcolors(a_color)
	B.Pulse(pulse + 1, get_dir(loc, T), a_color)

/obj/structure/blob/proc/run_action()
	return FALSE

/obj/structure/blob/proc/ConsumeTile()
	for(var/atom/A in loc)
		A.blob_act(src)
	if(iswallturf(loc))
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it

/obj/structure/blob/proc/expand(turf/T, prob = TRUE, a_color, _overmind, turf/double_target)
	if(prob && !prob(obj_integrity))
		return

	if(isspaceturf(T) && prob(75))
		return

	if(!T)
		var/list/dirs = list(NORTH, SOUTH, EAST, WEST)

		for(var/i = 1 to 4)
			var/dirn = pick_n_take(dirs)
			T = get_step(src, dirn)

			if(!(locate(/obj/structure/blob) in T))
				break
			else
				T = null

	if(!T)
		return FALSE

	var/obj/structure/blob/normal/B = new /obj/structure/blob/normal(src.loc, min(obj_integrity, 30))
	B.color = a_color
	B.density = TRUE
	B.overmind = _overmind

	if(T.Enter(B,src))//Attempt to move into the tile
		B.density = initial(B.density)
		B.loc = T

		if(double_target)
			if(!overmind.can_buy(5))
				overmind.last_attack = world.time
				return

			B.expand(double_target, 0, overmind.blob_reagent_datum.color, overmind)
			overmind.blob_core.chemical_attack(T)
			overmind.last_attack = world.time
	else
		T.blob_act()//If we cant move in hit the turf
		B.loc = null //So we don't play the splat sound, see Destroy()
		qdel(B)

	for(var/atom/A in T)//Hit everything in the turf
		if(isliving(A) && !A.density && overmind) // Crawling mob / small mob? Extra damage.
			var/mob/living/M = A
			var/mob_protection = M.get_permeability_protection()
			overmind.blob_reagent_datum.reaction_mob(M, REAGENT_TOUCH, 25, 1, mob_protection)
			overmind.blob_reagent_datum.send_message(M)
		A.blob_act(src)
	return TRUE

/obj/structure/blob/proc/double_expand(turf/T, prob = TRUE, a_color, mob/camera/blob/incoming_overmind)
	for(var/turf/adjacent in circlerange(T, 1))
		if(adjacent in circlerange(src, 1))
			expand(adjacent, 0, incoming_overmind.blob_reagent_datum.color, incoming_overmind, T)
			incoming_overmind.blob_core.chemical_attack(adjacent)
			color = incoming_overmind.blob_reagent_datum.color
			return

/obj/structure/blob/proc/on_atom_entered(datum/source, atom/movable/entered)
	entered.blob_act(src)

/obj/structure/blob/zap_act(power, zap_flags)
	take_damage(power * 0.0025, BURN, ENERGY)
	power -= power * 0.0025 //You don't get to do it for free
	return ..() //You don't get to do it for free

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
		else
			return 0

	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)

	damage_amount = round(damage_amount * (100 - armor_protection)*0.01, 0.1)
	if(overmind && damage_flag)
		damage_amount = overmind.blob_reagent_datum.damage_reaction(src, damage_amount, damage_type, damage_flag)

	return damage_amount

/obj/structure/blob/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		check_integrity()

/obj/structure/blob/proc/change_to(type)
	if(!ispath(type))
		error("[type] is an invalid type for the blob.")

	var/obj/structure/blob/B = new type(src.loc)
	if(!istype(type, /obj/structure/blob/core) || !istype(type, /obj/structure/blob/node))
		B.color = color
	else
		B.adjustcolors(color)

	qdel(src)

/obj/structure/blob/proc/adjustcolors(a_color)
	if(a_color)
		color = a_color

/obj/structure/blob/examine(mob/user)
	. = ..()
	. += "It looks like it's made of [get_chem_name()]."
	. += "It looks like this chemical does: [get_chem_desc()]"


/obj/structure/blob/proc/get_chem_name()
	for(var/mob/camera/blob/B in GLOB.mob_list)
		if(lowertext(B.blob_reagent_datum.color) == lowertext(src.color)) // Goddamit why we use strings for these
			return B.blob_reagent_datum.name
	return "unknown"

/obj/structure/blob/proc/get_chem_desc()
	for(var/mob/camera/blob/B in GLOB.mob_list)
		if(lowertext(B.blob_reagent_datum.color) == lowertext(src.color)) // Goddamit why we use strings for these
			return B.blob_reagent_datum.description
	return "something unknown"

/obj/structure/blob/hit_by_thrown_mob(mob/living/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	damage *= 0.25 // Lets not have sorium be too much of a blender / rapidly kill itself
	return ..()

/obj/structure/blob/normal
	icon_state = "blob"
	light_range = 0
	obj_integrity = 21 //doesn't start at full health
	max_integrity = 25
	brute_resist = 0.25

/obj/structure/blob/normal/check_integrity()
	var/old_compromised_integrity = compromised_integrity
	if(obj_integrity <= 15)
		compromised_integrity = TRUE
	else
		compromised_integrity = FALSE
	if(old_compromised_integrity != compromised_integrity)
		update_state()
		update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)

/obj/structure/blob/normal/update_state()
	if(compromised_integrity)
		brute_resist = 0.5
	else
		brute_resist = 0.25

/obj/structure/blob/normal/update_name()
	. = ..()
	if(compromised_integrity)
		name = "fragile blob"
	else
		name = "[overmind ? "blob" : "dead blob"]"

/obj/structure/blob/normal/update_desc()
	. = ..()
	if(compromised_integrity)
		desc = "A thin lattice of slightly twitching tendrils."
	else
		desc = "A thick wall of [overmind ? "writhing" : "lifeless"] tendrils."

/obj/structure/blob/normal/update_icon_state()
	if(compromised_integrity)
		icon_state = "blob_damaged"
	else
		icon_state = "blob"

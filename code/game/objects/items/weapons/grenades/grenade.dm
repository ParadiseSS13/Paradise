/obj/item/grenade
	name = "grenade"
	desc = "A hand held grenade with an adjustable timer."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	worn_icon_state = "grenade"
	inhand_icon_state = "grenade"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 20
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	flags_2 = RANDOM_BLOCKER_2
	/// Has the pin been pulled?
	var/active = FALSE
	/// Time between the pin being pulled and detonation.
	var/det_time = 5 SECONDS
	/// Does the grenade show the fuze's time setting on examine?
	var/display_timer = TRUE
	/// Can the grenade's fuze time be changed?
	var/modifiable_timer = TRUE

/obj/item/grenade/examine(mob/user)
	. = ..()
	if(!display_timer)
		return

	if(det_time > 1)
		. += "<span class='notice'>The fuze is set to [det_time / 10] second\s.</span>"
	else
		. += "<span class='warning'>[src] is set for instant detonation.</span>"

	if(modifiable_timer)
		. += "<span class='notice'>Use a screwdriver to modify the time on the fuze.</span>"
	else
		. += "<span class='notice'>The fuze's time cannot be modified.</span>"

/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/proc/clown_check(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='warning'>Huh? How does this thing work?</span>")
		active = TRUE
		icon_state = initial(icon_state) + "_active"
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, TRUE, -3)
		spawn(5)
			if(user)
				user.drop_item()
			prime()
		return FALSE
	return TRUE

/obj/item/grenade/attack_self__legacy__attackchain(mob/user as mob)
	if(active)
		return
	if(!clown_check(user))
		return

	to_chat(user, "<span class='danger'>You prime [src]! [det_time / 10] seconds!</span>")
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	add_fingerprint(user)
	var/turf/bombturf = get_turf(src)
	var/area/A = get_area(bombturf)
	message_admins("[key_name_admin(user)] has primed a [name] for detonation at <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>")
	log_game("[key_name(user)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z])")
	investigate_log("[key_name(user)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z])", INVESTIGATE_BOMB)
	add_attack_logs(user, src, "has primed for detonation", ATKLOG_FEW)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()
	spawn(det_time)
		prime()

/obj/item/grenade/proc/prime()
	return

/obj/item/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.drop_item_to_ground(src)

/obj/item/grenade/screwdriver_act(mob/living/user, obj/item/I)
	if(!modifiable_timer)
		return

	switch(det_time)
		if(1 DECISECONDS)
			det_time = 1 SECONDS
			to_chat(user, "<span class='notice'>You set [src] for 1 second detonation time.</span>")
		if(1 SECONDS)
			det_time = 3 SECONDS
			to_chat(user, "<span class='notice'>You set [src] for 3 second detonation time.</span>")
		if(3 SECONDS)
			det_time = 5 SECONDS
			to_chat(user, "<span class='notice'>You set [src] for 5 second detonation time.</span>")
		if(5 SECONDS)
			det_time = 1 DECISECONDS
			to_chat(user, "<span class='warning'>You set [src] for instant detonation.</span>")
	add_fingerprint(user)
	return TRUE

/obj/item/grenade/attack_hand()
	///We need to clear the walk_to on grabbing a moving grenade to have it not leap straight out of your hand
	GLOB.move_manager.stop_looping(src)
	..()

/obj/item/grenade/Destroy()
	GLOB.move_manager.stop_looping(src)
	return ..()

/obj/item/grenade/cmag_act(mob/user)
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		return FALSE
	ADD_TRAIT(src, TRAIT_CMAGGED, "cmagged grenade")
	to_chat(user, "<span class='warning'>You drip some yellow ooze into [src]. [src] suddenly doesn't want to leave you...</span>")
	AddComponent(/datum/component/boomerang, throw_range, TRUE)
	return TRUE

/obj/item/grenade/uncmag()
	if(!HAS_TRAIT(src, TRAIT_CMAGGED))
		return
	REMOVE_TRAIT(src, TRAIT_CMAGGED, "cmagged grenade")
	DeleteComponent(/datum/component/boomerang)

/obj/item/grenade
	name = "grenade"
	desc = "A hand held grenade with an adjustable timer."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "grenade"
	throw_speed = 4
	throw_range = 20
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	/// Has the pin been pulled?
	var/active = FALSE
	/// Time between the pin being pulled and detonation.
	var/det_time = 5 SECONDS
	/// Does the grenade show the fuze's time setting on examine?
	var/display_timer = TRUE

/obj/item/grenade/examine(mob/user)
	. = ..()
	if(display_timer)
		if(det_time > 1)
			. += "<span class='notice'>The fuze is set to [det_time / 10] second\s.</span>"
		else
			. += "<span class='danger'>[src] is set for instant detonation.</span>"
		. += "<span class='notice'>Use a screwdriver to modify the time on the fuze.</span>"


/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/**
  * Checks if the user is a non-clown.
  *
  * Returns `TRUE` if the user DOES NOT have `TRAIT_CLUMSY`.
  */
/obj/item/grenade/proc/clown_check(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='danger'>Huh? How does this thing work?</span>")
		active = TRUE
		icon_state = initial(icon_state) + "_active"
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		spawn(5)
			if(user)
				user.drop_item()
			prime()
		return FALSE
	return TRUE

/obj/item/grenade/attack_self(mob/user as mob)
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='danger'>You prime [src]! [det_time / 10] seconds!</span>")
			active = TRUE
			icon_state = initial(icon_state) + "_active"
			add_fingerprint(user)
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			message_admins("[key_name_admin(usr)] has primed a [name] for detonation at <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z])")
			investigate_log("[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z])", INVESTIGATE_BOMB)
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
		M.unEquip(src)

/obj/item/grenade/screwdriver_act(mob/living/user, obj/item/I)
	// Grenades without this all are made to have fixed fuze lengths.
	if(display_timer)
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
			det_time = 0.1 SECONDS
			to_chat(user, "<span class='danger'>You set [src] for instant detonation.</span>")
	add_fingerprint(user)
	return TRUE

/obj/item/grenade/attack_hand()
	///We need to clear the walk_to on grabbing a moving grenade to have it not leap straight out of your hand
	walk(src, null, null)
	..()

/obj/item/grenade/Destroy()
	///We need to clear the walk_to on destroy to allow a grenade which uses walk_to or related to properly GC
	walk_to(src, 0)
	return ..()

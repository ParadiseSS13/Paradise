/obj/item/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "grenade"
	throw_speed = 3
	throw_range = 20
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	var/active = FALSE
	var/det_time = 50
	var/display_timer = TRUE

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
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		spawn(5)
			if(user)
				user.drop_item()
			prime()
		return 0
	return 1


/*/obj/item/grenade/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if(istype(target, /obj/item/storage)) return ..() // Trying to put it in a full container
	if(istype(target, /obj/item/gun/grenadelauncher)) return ..()
	if((user.is_in_active_hand(src)) && (!active) && (clown_check(user)) && target.loc != src.loc)
		to_chat(user, "<span class='warning'>You prime the [name]! [det_time/10] seconds!</span>")
		active = TRUE
		icon_state = initial(icon_state) + "_active"
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		spawn(det_time)
			prime()
			return
		user.dir = get_dir(user, target)
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
	return*/


/obj/item/grenade/examine(mob/user)
	. = ..()
	if(display_timer)
		if(det_time > 1)
			. += "The timer is set to [det_time/10] second\s."
		else
			. += "\The [src] is set for instant detonation."

/obj/item/grenade/attack_self(mob/user as mob)
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='warning'>You prime [src]! [det_time/10] seconds!</span>")
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
	switch(det_time)
		if(1)
			det_time = 10
			to_chat(user, "<span class='notice'>You set [src] for 1 second detonation time.</span>")
		if(10)
			det_time = 30
			to_chat(user, "<span class='notice'>You set [src] for 3 second detonation time.</span>")
		if(30)
			det_time = 50
			to_chat(user, "<span class='notice'>You set [src] for 5 second detonation time.</span>")
		if(50)
			det_time = 1
			to_chat(user, "<span class='notice'>You set [src] for instant detonation.</span>")
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

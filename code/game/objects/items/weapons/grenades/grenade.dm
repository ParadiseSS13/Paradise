/obj/item/weapon/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = 2.0
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/active = 0
	var/det_time = 50
	var/display_timer = 1

/obj/item/weapon/grenade/proc/clown_check(var/mob/living/user)
	if((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>Huh? How does this thing work?</span>")
		active = 1
		icon_state = initial(icon_state) + "_active"
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		spawn(5)
			if(user)
				user.drop_item()
			prime()
		return 0
	return 1


/*/obj/item/weapon/grenade/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if(istype(target, /obj/item/weapon/storage)) return ..() // Trying to put it in a full container
	if(istype(target, /obj/item/weapon/gun/grenadelauncher)) return ..()
	if((user.get_active_hand() == src) && (!active) && (clown_check(user)) && target.loc != src.loc)
		to_chat(user, "<span class='warning'>You prime the [name]! [det_time/10] seconds!</span>")
		active = 1
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


/obj/item/weapon/grenade/examine(mob/user)
	..(user)
	if(display_timer)
		if(det_time > 1)
			to_chat(user, "The timer is set to [det_time/10] second\s.")
		else
			to_chat(user, "\The [src] is set for instant detonation.")

/obj/item/weapon/grenade/attack_self(mob/user as mob)
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='warning'>You prime the [name]! [det_time/10] seconds!</span>")
			active = 1
			icon_state = initial(icon_state) + "_active"
			add_fingerprint(user)
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			message_admins("[key_name_admin(usr)] has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z])")
			bombers += "[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z])"
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			spawn(det_time)
				prime()


/obj/item/weapon/grenade/proc/prime()

/obj/item/weapon/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.unEquip(src)


/obj/item/weapon/grenade/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		switch(det_time)
			if("1")
				det_time = 10
				to_chat(user, "<span class='notice'>You set the [name] for 1 second detonation time.</span>")
			if("10")
				det_time = 30
				to_chat(user, "<span class='notice'>You set the [name] for 3 second detonation time.</span>")
			if("30")
				det_time = 50
				to_chat(user, "<span class='notice'>You set the [name] for 5 second detonation time.</span>")
			if("50")
				det_time = 1
				to_chat(user, "<span class='notice'>You set the [name] for instant detonation.</span>")
		add_fingerprint(user)
	..()

/obj/item/weapon/grenade/attack_hand()
	walk(src, null, null)
	..()

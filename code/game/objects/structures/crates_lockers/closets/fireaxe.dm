//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	var/obj/item/twohanded/fireaxe/fireaxe = new/obj/item/twohanded/fireaxe
	icon_state = "fireaxe1000"
	icon_closed = "fireaxe1000"
	icon_opened = "fireaxe1100"
	anchored = 1
	density = 0
	armor = list(melee = 50, bullet = 20, laser = 0, energy = 100, bomb = 10, bio = 100, rad = 100, fire = 90, acid = 50)
	var/open = 0 //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = 1
	var/hitstaken = 0
	locked = 1
	obj_integrity = 150
	max_integrity = 150
	integrity_failure = 50

/obj/structure/closet/fireaxecabinet/New()
	..()
	update_icon()

/obj/structure/closet/fireaxecabinet/Destroy()
	if(fireaxe)
		qdel(fireaxe)
		fireaxe = null
	return ..()

obj/structure/closet/fireaxecabinet/attackby(var/obj/item/O as obj, var/mob/living/user as mob)  //Marker -Agouri
	var/hasaxe = 0       //gonna come in handy later~
	if(fireaxe)
		hasaxe = 1

	if(isrobot(user) || src.locked)
		if(istype(O, /obj/item/multitool))
			to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
			playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
			if(do_after(user, 20 * O.toolspeed, target = src))
				src.locked = 0
				to_chat(user, "<span class = 'caution'> You disable the locking modules.</span>")
				update_icon()
			return
	else if(istype(O, /obj/item/weldingtool) && user.a_intent == INTENT_HELP && !broken)
		if (obj_integrity < max_integrity)
			var/obj/item/weldingtool/WT = O
			to_chat(user, "<span class='notice'>You begin repairing [src].</span>")
			if (WT.remove_fuel(5,user))
				obj_integrity = max_integrity
				update_icon()
				to_chat(user, "<span class='notice'>You repair [src].</span>")
			else
				to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return
	if(istype(O, /obj/item/twohanded/fireaxe) && open)
		if(!fireaxe)
			if(O:wielded)
				to_chat(user, "<span class='warning'>Unwield the axe first.</span>")
				return
			fireaxe = O
			user.drop_item(O)
			src.contents += O
			to_chat(user, "<span class='notice'>You place the fire axe back in the [src.name].</span>")
			update_icon()
		else
			if(broken)
				return
			else
				open = !open
				if(open)
					icon_state = text("fireaxe[][][][]opening",hasaxe,src.open,src.hitstaken,broken)
					spawn(10) update_icon()
				else
					icon_state = text("fireaxe[][][][]closing",hasaxe,src.open,src.hitstaken,broken)
					spawn(10) update_icon()
	else
		if(broken)
			return
		if(istype(O, /obj/item/multitool))
			if(open)
				open = 0
				icon_state = text("fireaxe[][][][]closing",hasaxe,src.open,src.hitstaken,broken)
				spawn(10) update_icon()
				return
			else
				to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
				sleep(50)
				src.locked = 1
				to_chat(user, "<span class='notice'>You re-enable the locking modules.</span>")
				playsound(user, 'sound/machines/lockenable.ogg', 50, 1)
				if(do_after(user, 20 * O.toolspeed, target = src))
					src.locked = 1
					to_chat(user, "<span class = 'caution'> You re-enable the locking modules.</span>")
				return
		else
			open = !open
			if(open)
				icon_state = text("fireaxe[][][][]opening",hasaxe,src.open,src.hitstaken,broken)
				spawn(10) update_icon()
			else
				icon_state = text("fireaxe[][][][]closing",hasaxe,src.open,src.hitstaken,broken)
				spawn(10) update_icon()

/obj/structure/closet/fireaxecabinet/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(broken)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, 1)
			else
				playsound(loc, 'sound/effects/Glasshit.ogg', 90, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

/obj/structure/closet/fireaxecabinet/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	if(open)
		return
	. = ..()
	if(.)
		update_icon()

/obj/structure/closet/fireaxecabinet/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		update_icon()
		broken = TRUE
		playsound(src, 'sound/effects/Glassbr3.ogg', 100, 1)
		new /obj/item/shard(loc)
		new /obj/item/shard(loc)

/obj/structure/closet/fireaxecabinet/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(fireaxe && loc)
			fireaxe.forceMove(loc)
			fireaxe = null
		new /obj/item/stack/sheet/metal(loc, 2)
	qdel(src)

/obj/structure/closet/fireaxecabinet/blob_act(obj/structure/blob/B)
	if(fireaxe)
		fireaxe.forceMove(loc)
		fireaxe = null
	qdel(src)

/obj/structure/closet/fireaxecabinet/attack_hand(mob/user)
	if(open || broken)
		if(fireaxe)
			user.put_in_hands(fireaxe)
			fireaxe = null
			user << "<span class='caution'>You take the fire axe from the [name].</span>"
			src.add_fingerprint(user)
			update_icon()
			return
	if(locked)
		user <<"<span class='warning'> The [name] won't budge!</span>"
		return
	else
		open = !open
		update_icon()
		return

/obj/structure/closet/fireaxecabinet/attack_ai(mob/user)
	toggle_lock(user)
	return

/obj/structure/closet/fireaxecabinet/update_icon()
	cut_overlays()
	if(fireaxe)
		add_overlay("axe")
	if(!open)
		var/hp_percent = obj_integrity/max_integrity * 100
		if(broken)
			add_overlay("glass4")
		else
			switch(hp_percent)
				if(-INFINITY to 40)
					add_overlay("glass3")
				if(40 to 60)
					add_overlay("glass2")
				if(60 to 80)
					add_overlay("glass1")
				if(80 to INFINITY)
					add_overlay("glass")
		if(locked)
			add_overlay("locked")
		else
			add_overlay("unlocked")
	else
		add_overlay("glass_raised")

/obj/structure/closet/fireaxecabinet/proc/toggle_lock(mob/user)
	user << "<span class = 'caution'> Resetting circuitry...</span>"
	playsound(src, 'sound/machines/locktoggle.ogg', 50, 1)
	if(do_after(user, 20, target = src))
		user << "<span class='caution'>You [locked ? "disable" : "re-enable"] the locking modules.</span>"
		locked = !locked
		update_icon()

/obj/structure/closet/fireaxecabinet/verb/toggle_open()
	set name = "Open/Close"
	set category = "Object"
	set src in oview(1)

	if(locked)
		usr <<"<span class='warning'> The [name] won't budge!</span>"
		return
	else
		open = !open
		update_icon()
		return
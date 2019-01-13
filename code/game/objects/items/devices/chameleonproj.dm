/obj/item/chameleon
	name = "chameleon-projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "syndicate=4;magnets=4"
	var/can_use = 1
	var/obj/effect/dummy/chameleon/active_dummy = null
	var/saved_item = /obj/item/cigbutt
	var/saved_icon = 'icons/obj/clothing/masks.dmi'
	var/saved_icon_state = "cigbutt"
	var/saved_overlays = null
	var/saved_underlays = null

/obj/item/chameleon/dropped()
	disrupt()

/obj/item/chameleon/equipped()
	disrupt()

/obj/item/chameleon/attack_self()
	toggle()

/obj/item/chameleon/afterattack(atom/target, mob/user , proximity)
	if(!proximity) return
	if(!active_dummy)
		if(istype(target,/obj/item) && !istype(target, /obj/item/disk/nuclear))
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
			to_chat(user, "<span class='notice'>Scanned [target].</span>")
			saved_item = target.type
			saved_icon = target.icon
			saved_icon_state = target.icon_state
			saved_overlays = target.overlays
			saved_underlays = target.underlays

/obj/item/chameleon/proc/toggle()
	if(!can_use || !saved_item) return
	if(active_dummy)
		eject_all()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		QDEL_NULL(active_dummy)
		to_chat(usr, "<span class='notice'>You deactivate [src].</span>")
		var/obj/effect/overlay/T = new/obj/effect/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		spawn(8)
			qdel(T)
	else
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		var/obj/O = new saved_item(src)
		if(!O) return
		var/obj/effect/dummy/chameleon/C = new/obj/effect/dummy/chameleon(usr.loc)
		C.activate(O, usr, saved_icon, saved_icon_state, saved_overlays, saved_underlays, src)
		qdel(O)
		to_chat(usr, "<span class='notice'>You activate [src].</span>")
		var/obj/effect/overlay/T = new/obj/effect/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		spawn(8)
			qdel(T)

/obj/item/chameleon/proc/disrupt(var/delete_dummy = 1)
	if(active_dummy)
		do_sparks(5, 0, src)
		eject_all()
		if(delete_dummy)
			qdel(active_dummy)
		active_dummy = null
		can_use = 0
		spawn(50) can_use = 1

/obj/item/chameleon/proc/eject_all()
	for(var/atom/movable/A in active_dummy)
		A.loc = active_dummy.loc
		if(ismob(A))
			var/mob/M = A
			M.reset_perspective(null)

/obj/effect/dummy/chameleon
	name = ""
	desc = ""
	density = 0
	anchored = 1
	var/can_move = 1
	var/obj/item/chameleon/master = null

/obj/effect/dummy/chameleon/proc/activate(var/obj/O, var/mob/M, new_icon, new_iconstate, new_overlays, new_underlays, var/obj/item/chameleon/C)
	name = O.name
	desc = O.desc
	icon = new_icon
	icon_state = new_iconstate
	overlays = new_overlays
	underlays = new_underlays
	dir = O.dir
	M.loc = src
	master = C
	master.active_dummy = src

/obj/effect/dummy/chameleon/attackby()
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your chameleon-projector deactivates.</span>")
	master.disrupt()

/obj/effect/dummy/chameleon/attack_hand()
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your chameleon-projector deactivates.</span>")
	master.disrupt()

/obj/effect/dummy/chameleon/ex_act(var/severity) //no longer bomb-proof
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your chameleon-projector deactivates.</span>")
		spawn()
			M.ex_act(severity)
	master.disrupt()

/obj/effect/dummy/chameleon/bullet_act()
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your chameleon-projector deactivates.</span>")
	..()
	master.disrupt()

/obj/effect/dummy/chameleon/relaymove(var/mob/user, direction)
	if(istype(loc, /turf/space) || !direction)
		return //No magical space movement!

	if(can_move)
		can_move = 0
		switch(user.bodytemperature)
			if(300 to INFINITY)
				spawn(10) can_move = 1
			if(295 to 300)
				spawn(13) can_move = 1
			if(280 to 295)
				spawn(16) can_move = 1
			if(260 to 280)
				spawn(20) can_move = 1
			else
				spawn(25) can_move = 1
		step(src, direction)
	return

/obj/effect/dummy/chameleon/Destroy()
	master.disrupt(0)
	return ..()

/obj/item/borg_chameleon
	name = "cyborg chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	var/active = FALSE
	var/activationCost = 300
	var/activationUpkeep = 50
	var/disguise = "landmate"
	var/mob/living/silicon/robot/syndicate/saboteur/S

/obj/item/borg_chameleon/Destroy()
	if(S)
		S.cham_proj = null
	return ..()

/obj/item/borg_chameleon/dropped(mob/user)
	. = ..()
	disrupt(user)

/obj/item/borg_chameleon/equipped(mob/user)
	. = ..()
	disrupt(user)

/obj/item/borg_chameleon/attack_self(mob/living/silicon/robot/syndicate/saboteur/user)
	if(user && user.cell && user.cell.charge >  activationCost)
		if(isturf(user.loc))
			toggle(user)
		else
			to_chat(user, "<span class='warning'>You can't use [src] while inside something!</span>")
	else
		to_chat(user, "<span class='warning'>You need at least [activationCost] charge in your cell to use [src]!</span>")

/obj/item/borg_chameleon/proc/toggle(mob/living/silicon/robot/syndicate/saboteur/user)
	if(active)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, -6)
		to_chat(user, "<span class='notice'>You deactivate [src].</span>")
		deactivate(user)
	else
		to_chat(user, "<span class='notice'>You activate [src].</span>")
		var/start = user.filters.len
		var/X
		var/Y
		var/rsq
		var/i
		var/f
		for(i in 1 to 7)
			do
				X = 60 * rand() - 30
				Y = 60 * rand() - 30
				rsq = X * X + Y * Y
			while(rsq < 100 || rsq > 900)
			user.filters += filter(type = "wave", x = X, y = Y, size = rand() * 2.5 + 0.5, offset = rand())
		for(i in 1 to 7)
			f = user.filters[start+i]
			animate(f, offset = f:offset, time = 0, loop = 3, flags = ANIMATION_PARALLEL)
			animate(offset = f:offset - 1, time = rand() * 20 + 10)
		if(do_after(user, 50, target = user) && user.cell.use(activationCost))
			playsound(src, 'sound/effects/bamf.ogg', 100, 1, -6)
			to_chat(user, "<span class='notice'>You are now disguised as a Nanotrasen engineering cyborg.</span>")
			activate(user)
		else
			to_chat(user, "<span class='warning'>The chameleon field fizzles.</span>")
			do_sparks(3, FALSE, user)
			for(i in 1 to min(7, user.filters.len)) // removing filters that are animating does nothing, we gotta stop the animations first
				f = user.filters[start + i]
				animate(f)
		user.filters = null

/obj/item/borg_chameleon/process()
	if(S)
		if(!S.cell || !S.cell.use(activationUpkeep))
			disrupt(S)
	else
		return PROCESS_KILL

/obj/item/borg_chameleon/proc/activate(mob/living/silicon/robot/syndicate/saboteur/user)
	processing_objects.Add(src)
	S = user
	user.base_icon = disguise
	user.icon_state = disguise
	user.cham_proj = src
	active = TRUE
	user.update_icons()

/obj/item/borg_chameleon/proc/deactivate(mob/living/silicon/robot/syndicate/saboteur/user)
	processing_objects.Remove(src)
	S = user
	user.base_icon = initial(user.base_icon)
	user.icon_state = initial(user.icon_state)
	active = FALSE
	user.update_icons()

/obj/item/borg_chameleon/proc/disrupt(mob/living/silicon/robot/syndicate/saboteur/user)
	if(active)
		to_chat(user, "<span class='danger'>Your chameleon field deactivates.</span>")
		deactivate(user)

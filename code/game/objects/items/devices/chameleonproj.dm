/obj/item/chameleon
	name = "chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	worn_icon_state = "electronic"
	inhand_icon_state = "electronic"
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "syndicate=4;magnets=4"
	var/can_use = TRUE
	var/obj/effect/dummy/chameleon/active_dummy = null
	var/saved_item = /obj/item/cigbutt
	var/saved_icon = 'icons/obj/clothing/masks.dmi'
	var/saved_icon_state = "cigbutt"
	var/saved_overlays = null
	var/saved_underlays = null

/obj/item/chameleon/dropped()
	..()
	disrupt()

/obj/item/chameleon/equipped()
	disrupt()

/obj/item/chameleon/attack_self__legacy__attackchain()
	toggle()

/obj/item/chameleon/afterattack__legacy__attackchain(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(!check_sprite(target))
		return
	if(target.alpha < 255)
		return
	if(target.invisibility != 0)
		return
	if(!active_dummy)
		if(isitem(target) && !istype(target, /obj/item/disk/nuclear))
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, TRUE, -6)
			to_chat(user, "<span class='notice'>Scanned [target].</span>")
			saved_item = target.type
			saved_icon = target.icon
			saved_icon_state = target.icon_state
			saved_overlays = target.overlays
			saved_underlays = target.underlays

/obj/item/chameleon/proc/check_sprite(atom/target)
	return (target.icon_state in icon_states(target.icon))

/obj/item/chameleon/proc/toggle()
	if(!can_use || !saved_item)
		return
	if(active_dummy)
		eject_all()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, TRUE, -6)
		QDEL_NULL(active_dummy)
		to_chat(usr, "<span class='notice'>You deactivate [src].</span>")
		var/obj/effect/overlay/T = new/obj/effect/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		spawn(8)
			qdel(T)
	else
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, TRUE, -6)
		var/obj/O = new saved_item(src)
		if(!O)
			return
		var/obj/effect/dummy/chameleon/C = new/obj/effect/dummy/chameleon(usr.loc)
		C.activate(O, usr, saved_icon, saved_icon_state, saved_overlays, saved_underlays, src)
		qdel(O)
		to_chat(usr, "<span class='notice'>You activate [src].</span>")
		var/obj/effect/overlay/T = new/obj/effect/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		spawn(8)
			qdel(T)

/obj/item/chameleon/proc/disrupt(delete_dummy = 1)
	if(active_dummy)
		do_sparks(5, 0, src)
		eject_all()
		if(delete_dummy)
			qdel(active_dummy)
		active_dummy = null
		can_use = FALSE
		addtimer(VARSET_CALLBACK(src, can_use, TRUE), 5 SECONDS)

/obj/item/chameleon/proc/eject_all()
	for(var/atom/movable/A in active_dummy)
		A.forceMove(active_dummy.loc)

/obj/effect/dummy/chameleon
	name = ""
	desc = ""
	resistance_flags = INDESTRUCTIBLE | FREEZE_PROOF
	var/can_move = TRUE
	var/obj/item/chameleon/master = null

/obj/effect/dummy/chameleon/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_EFFECT_CAN_TELEPORT, ROUNDSTART_TRAIT)

/obj/effect/dummy/chameleon/proc/activate(obj/O, mob/M, new_icon, new_iconstate, new_overlays, new_underlays, obj/item/chameleon/C)
	name = O.name
	desc = O.desc
	icon = new_icon
	icon_state = new_iconstate
	overlays = new_overlays
	underlays = new_underlays
	dir = O.dir
	M.forceMove(src)
	master = C
	master.active_dummy = src

/obj/effect/dummy/chameleon/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your [src] deactivates.</span>")
	master.disrupt()

/obj/effect/dummy/chameleon/attack_hand()
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your [src] deactivates.</span>")
	master.disrupt()

/obj/effect/dummy/chameleon/attack_animal()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_slime()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_alien()
	master.disrupt()

/obj/effect/dummy/chameleon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay)
	master.disrupt() // things like plasmafires, lava, bonfires will disrupt it

/obj/effect/dummy/chameleon/acid_act()
	master.disrupt()

/obj/effect/dummy/chameleon/ex_act(severity) //no longer bomb-proof
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your [src] deactivates.</span>")
		spawn()
			M.ex_act(severity)
	master.disrupt()

/obj/effect/dummy/chameleon/bullet_act()
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your [src] deactivates.</span>")
	..()
	master.disrupt()

/obj/effect/dummy/chameleon/relaymove(mob/user, direction)
	if(!isturf(loc) || isspaceturf(loc) || !direction)
		return // No magical movement!

	if(can_move)
		can_move = FALSE
		switch(user.bodytemperature)
			if(300 to INFINITY)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 1 SECONDS)
			if(295 to 300)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 1.3 SECONDS)
			if(280 to 295)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 1.6 SECONDS)
			if(260 to 280)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 2 SECONDS)
			else
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 2.5 SECONDS)
		step(src, direction)
	return

/obj/effect/dummy/chameleon/Destroy()
	master.disrupt(0)
	return ..()

/obj/item/borg_chameleon
	name = "cyborg chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	w_class = WEIGHT_CLASS_SMALL
	var/active = FALSE
	var/activation_cost = 300
	var/activation_upkeep = 50
	var/image/disguise
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

/obj/item/borg_chameleon/attack_self__legacy__attackchain(mob/living/silicon/robot/syndicate/saboteur/user)
	if(user && user.cell && user.cell.charge > activation_cost)
		if(isturf(user.loc))
			toggle(user)
		else
			to_chat(user, "<span class='warning'>You can't use [src] while inside something!</span>")
	else
		to_chat(user, "<span class='warning'>You need at least [activation_cost] charge in your cell to use [src]!</span>")

/obj/item/borg_chameleon/proc/toggle(mob/living/silicon/robot/syndicate/saboteur/user)
	if(active)
		to_chat(user, "<span class='notice'>You reconfigure [src].</span>")
		activate(user)
		return
	to_chat(user, "<span class='notice'>You activate [src].</span>")
	apply_wibbly_filters(user)
	if(do_after(user, 5 SECONDS, target = user) && user.cell.use(activation_cost))
		activate(user)
	else
		to_chat(user, "<span class='warning'>The chameleon field fizzles.</span>")
		do_sparks(3, FALSE, user)
	remove_wibbly_filters(user)

/obj/item/borg_chameleon/process()
	if(S)
		if(!S.cell || !S.cell.use(activation_upkeep))
			disrupt(S)
		return
	return PROCESS_KILL

/obj/item/borg_chameleon/proc/activate(mob/living/silicon/robot/syndicate/saboteur/user)
	var/static/list/module_options = list(
		"Engineering" = image('icons/mob/robots.dmi', "engi-radial"),
		"Janitor" = image('icons/mob/robots.dmi', "jan-radial"),
		"Medical" = image('icons/mob/robots.dmi', "med-radial"),
		"Mining" = image('icons/mob/robots.dmi', "mining-radial"),
		"Service" = image('icons/mob/robots.dmi', "serv-radial"),
		"Cancel Cloaking" = image('icons/mob/screen_gen.dmi', "x"))
	var/selected_module = show_radial_menu(user, user, module_options, radius = 42)
	if(!selected_module)
		return
	var/examine_text = "you shouldn't see this"
	switch(selected_module)
		if("Mining")
			examine_text = "miner robot module"
		if("Service")
			examine_text = "service robot module"
		if("Medical")
			examine_text = "medical robot module"
		if("Janitor")
			examine_text = "janitorial robot module"
		if("Engineering")
			examine_text = "engineering robot module"
		if("Cancel Cloaking")
			deactivate(user)
			return
	var/module_sprites = user.get_module_sprites(selected_module)
	var/selected_sprite = show_radial_menu(user, user, module_sprites, radius = 42)
	if(!selected_sprite)
		return
	disguise = module_sprites[selected_sprite]
	var/list/name_check = splittext(selected_sprite, "-")
	user.custom_panel = trim(name_check[1])
	START_PROCESSING(SSobj, src)
	S = user
	user.icon = disguise.icon
	user.icon_state = disguise.icon_state
	user.cham_proj = src
	user.module.name = examine_text
	user.bubble_icon = "robot"
	active = TRUE
	user.update_icons()
	playsound(src, 'sound/effects/bamf.ogg', 100, TRUE, -6)
	to_chat(user, "<span class='notice'>You are now disguised as a Nanotrasen [selected_module] cyborg.</span>")

/obj/item/borg_chameleon/proc/deactivate(mob/living/silicon/robot/syndicate/saboteur/user)
	STOP_PROCESSING(SSobj, src)
	S = user
	user.icon = initial(user.icon)
	user.icon_state = initial(user.icon_state)
	user.module.name = initial(user.module.name)
	user.bubble_icon = "syndibot"
	user.custom_panel = null
	active = FALSE
	user.update_icons()

/obj/item/borg_chameleon/proc/disrupt(mob/living/silicon/robot/syndicate/saboteur/user)
	if(active)
		to_chat(user, "<span class='danger'>Your chameleon field deactivates.</span>")
		deactivate(user)

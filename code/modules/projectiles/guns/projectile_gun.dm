/obj/item/gun/projectile
	name = "generic projectile gun"
	origin_tech = "combat=2;materials=2"
	materials = list(MAT_META = 1000)
	/// The type path of the gun's magazine.
	var/mag_type = /obj/item/ammo_box/magazine/m10mm
	/// The magazine currently inside the gun.
	var/obj/item/ammo_box/magazine/magazine
	/// Can the gun's maganzine be reloaded while there's already a magazine inside.
	var/can_tactical = FALSE
	/// The sound it will make when the gun suppression is TRUE
	var/suppressed_sound = 'sound/weapons/gunshots/gunshot_silenced.ogg'

/obj/item/gun/projectile/Initialize(mapload)
	. = ..()
	if(!magazine)
		magazine = new mag_type(src)
	chamber_round()
	update_icon()

/obj/item/gun/projectile/Destroy()
	QDEL_NULL(magazine)
	return ..()

/obj/item/gun/projectile/update_name()
	. = ..()
	if(sawn_state)
		name = "sawn-off [name]"
	else
		name = initial(name)

/obj/item/gun/projectile/update_desc()
	. = ..()
	if(sawn_state)
		desc = sawn_desc
	else
		desc = initial(desc)

/obj/item/gun/projectile/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][suppressed ? "-suppressed" : ""][sawn_state ? "_sawn" : ""]"
	else
		icon_state = "[initial(icon_state)][suppressed ? "-suppressed" : ""][sawn_state ? "_sawn" : ""]"

/obj/item/gun/projectile/update_overlays()
	. = ..()
	if(bayonet && can_bayonet)
		. += knife_overlay

/obj/item/gun/projectile/process_chamber(eject_casing = TRUE, empty_chamber = TRUE)
	var/obj/item/ammo_casing/ammo_chambered = chambered //Find chambered round
	if(!istype(ammo_chambered))
		chamber_round()
		return
	if(eject_casing && !QDELETED(ammo_chambered))
		ammo_chambered.forceMove(get_turf(src)) //Eject casing onto ground.
		ammo_chambered.SpinAnimation(10, 1) //next gen special effects
		playsound(src, chambered.casing_drop_sound, 60, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	if(empty_chamber)
		chambered = null
	chamber_round()
	return

/obj/item/gun/projectile/proc/chamber_round()
	if(chambered || !magazine)
		return
	else if(magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.loc = src
	return

/obj/item/gun/projectile/can_shoot()
	if(!magazine || !magazine.ammo_count(0))
		return 0
	return 1

/obj/item/gun/projectile/proc/can_reload()
	return !magazine

/obj/item/gun/projectile/proc/reload(obj/item/ammo_box/magazine/AM, mob/user)
	user.unequip(AM)
	magazine = AM
	magazine.forceMove(src)
	if(w_class >= WEIGHT_CLASS_NORMAL && !suppressed)
		playsound(src, magin_sound, 50, TRUE)
	else
		playsound(src, magin_sound, 50, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	chamber_round()
	AM.update_icon()
	update_icon()
	if(!user)
		return
	// Update the hand opposite of the one holding ammo (the current one)
	if(user.hand)
		user.update_inv_r_hand()
	else
		user.update_inv_l_hand()
	return

/obj/item/gun/projectile/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/mag = used
		if(!istype(mag, mag_type))
			to_chat(user, SPAN_WARNING("[used] doesn't fit in [src]!"))
			return ITEM_INTERACT_COMPLETE

		if(can_reload())
			reload(mag, user)
			to_chat(user, SPAN_NOTICE("You load a new magazine into [src]."))
			return ITEM_INTERACT_COMPLETE

		if(!can_tactical)
			to_chat(user, SPAN_NOTICE("There's already a magazine in [src]."))
			return ITEM_INTERACT_COMPLETE

		to_chat(user, SPAN_NOTICE("You perform a tactical reload on [src], replacing the magazine."))
		magazine.loc = get_turf(loc)
		magazine.update_icon()
		magazine = null
		reload(mag, user)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/suppressor))
		var/obj/item/suppressor/S = used
		if(!can_suppress)
			to_chat(user, SPAN_WARNING("[src] doesn't have a threaded barrel for [S] to screw onto!"))
			return ITEM_INTERACT_COMPLETE

		if(suppressed)
			to_chat(user, SPAN_WARNING("[src] is already suppressed!"))
			return ITEM_INTERACT_COMPLETE

		if(!user.transfer_item_to(used, src))
			to_chat(user, SPAN_WARNING("[used] is stuck to your hand!"))
			return ITEM_INTERACT_COMPLETE

		to_chat(user, SPAN_NOTICE("You screw [S] onto [src]."))
		playsound(src, 'sound/items/screwdriver.ogg', 40, 1)
		suppressed = S
		S.oldsound = fire_sound
		S.initial_w_class = w_class
		fire_sound = suppressed_sound
		w_class = WEIGHT_CLASS_NORMAL //so pistols do not fit in pockets when suppressed
		update_icon()
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/item/gun/projectile/attack_hand(mob/user)
	if(loc == user)
		if(suppressed && can_unsuppress)
			var/obj/item/suppressor/S = suppressed
			if(!user.is_holding(src))
				..()
				return
			to_chat(user, SPAN_NOTICE("You unscrew [suppressed] from [src]."))
			playsound(src, 'sound/items/screwdriver.ogg', 40, 1)
			user.put_in_hands(suppressed)
			fire_sound = S.oldsound
			w_class = S.initial_w_class
			suppressed = FALSE
			update_icon()
			return
	..()

/obj/item/gun/projectile/handle_activate_self(mob/user)
	var/obj/item/ammo_casing/AC = chambered // Find chambered round.
	if(magazine)
		magazine.loc = get_turf(loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		to_chat(user, SPAN_NOTICE("You pull the magazine out of [src]."))
		playsound(src, magout_sound, 50, 1)
		update_icon()
		return

	if(chambered)
		AC.loc = get_turf(src)
		AC.SpinAnimation(10, 1)
		chambered = null
		to_chat(user, SPAN_NOTICE("You unload the round from [src]'s chamber."))
		playsound(src, 'sound/weapons/gun_interactions/remove_bullet.ogg', 50, 1)
		update_icon()
		return

	to_chat(user, SPAN_NOTICE("There's no magazine in [src]!"))
	return

/obj/item/gun/projectile/examine(mob/user)
	. = ..()
	. += "Has [get_ammo()] round\s remaining."
	. += SPAN_NOTICE("Use in hand to empty the gun's ammo reserves.")

/obj/item/gun/projectile/proc/get_ammo(countchambered = 1)
	var/boolets = 0 //mature var names for mature people
	if(chambered && countchambered)
		boolets++
	if(magazine)
		boolets += magazine.ammo_count()
	return boolets

/obj/item/gun/projectile/suicide_act(mob/user)
	if(chambered && chambered.BB && !chambered.BB.nodamage)
		user.visible_message(SPAN_SUICIDE("[user] is putting the barrel of [src] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide!"))
		sleep(25)
		if(user.is_holding(src))
			process_fire(user, user, 0, zone_override = "head")
			user.visible_message(SPAN_SUICIDE("[user] blows [user.p_their()] brains out with [src]!"))
			return BRUTELOSS
		else
			user.visible_message(SPAN_SUICIDE("[user] panics and starts choking to death!"))
			return OXYLOSS
	else
		user.visible_message(SPAN_SUICIDE("[user] is pretending to blow [user.p_their()] brains out with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(loc, 'sound/weapons/empty.ogg', 50, TRUE, -1)
		return OXYLOSS

/obj/item/gun/projectile/proc/sawoff(mob/user)
	if(sawn_state == SAWN_OFF)
		to_chat(user, SPAN_WARNING("\The [src] is already shortened!"))
		return
	if(bayonet)
		to_chat(user, SPAN_WARNING("You cannot saw-off [src] with [bayonet] attached!"))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("[user] begins to shorten \the [src].", SPAN_NOTICE("You begin to shorten \the [src]..."))

	//if there's any live ammo inside the gun, makes it go off
	if(blow_up(user))
		user.visible_message(SPAN_DANGER("\The [src] goes off!"), SPAN_DANGER("\The [src] goes off in your face!"))
		return

	if(do_after(user, 30, target = src))
		if(sawn_state == SAWN_OFF)
			return
		user.visible_message("[user] shortens \the [src]!", SPAN_NOTICE("You shorten \the [src]."))
		w_class = WEIGHT_CLASS_NORMAL
		inhand_icon_state = "gun" //phil235 is it different with different skin?
		slot_flags &= ~ITEM_SLOT_BACK	//you can't sling it on your back
		slot_flags |= ITEM_SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
		sawn_state = SAWN_OFF
		update_appearance()
		return 1

// Sawing guns related proc
/obj/item/gun/projectile/proc/blow_up(mob/user)
	. = 0
	for(var/obj/item/ammo_casing/AC in magazine.stored_ammo)
		if(AC.BB)
			process_fire(user, user,0)
			. = 1

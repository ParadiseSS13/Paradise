// The ammo/gun is stored in a back slot item
/obj/item/minigunpack
	name = "IK-134 backpack power supply"
	desc = "An IK-134 gatling gun's massive external power source."
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "holstered"
	inhand_icon_state = "satchel-sec"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	/// The stored gun
	var/obj/item/gun/energy/gun/minigun/gun
	/// whether the gun is attached, FALSE is attached, TRUE is the gun is wielded.
	var/armed = FALSE

/obj/item/minigunpack/Initialize(mapload)
	. = ..()
	gun = new(src)
	START_PROCESSING(SSobj, src)

/obj/item/minigunpack/Destroy()
	if(!QDELETED(gun))
		qdel(gun)
	gun = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/// ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/minigunpack/attack_hand(mob/living/carbon/user, list/modifiers)
	if(src.loc != user)
		return ..()
	if(armed)
		to_chat(user, SPAN_WARNING("You are already holding the gun!"))
		return
	if(user.get_item_by_slot(ITEM_SLOT_BACK) == src)
		armed = TRUE
		if(!user.put_in_hands(gun))
			armed = FALSE
			to_chat(user, SPAN_WARNING("You need a free hand to hold the gun!"))
			return
		update_icon(UPDATE_ICON_STATE)

/obj/item/minigunpack/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(armed)
		return
	if(!iscarbon(usr))
		return
	var/mob/living/carbon/M = usr
	if(!M.restrained() && !M.stat)
		switch(over_object.name)
			if("r_hand")
				if(!M.has_right_hand() || !M.unequip(src))
					return
				M.put_in_r_hand(src)
			if("l_hand")
				if(!M.has_left_hand() || !M.unequip(src))
					return
				M.put_in_l_hand(src)
		add_fingerprint(usr)
		return

/obj/item/minigunpack/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_BACK)
		RegisterSignal(user, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))

/obj/item/minigunpack/attackby__legacy__attackchain(obj/item/I, mob/living/user, params)
	. = ..()
	// Don't need armed check, because if you have the gun assume its armed.
	if(I == gun)
		user.drop_item_to_ground(gun, force = TRUE)
	else
		..()

/obj/item/minigunpack/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	if(armed)
		user.drop_item_to_ground(gun, force = TRUE)

/obj/item/minigunpack/update_icon_state()
	icon_state = armed ? "notholstered" : "holstered"
	return ..()

/obj/item/minigunpack/proc/on_borg_charge(datum/source, amount)
	SIGNAL_HANDLER

	gun.cell.give(amount)

/obj/item/minigunpack/proc/attach_gun(mob/user)
	if(!gun)
		gun = new(src)
	gun.forceMove(src)
	armed = FALSE
	if(user)
		to_chat(user, SPAN_NOTICE("You attach \the [gun] to \the [src]."))
	else
		src.visible_message(SPAN_WARNING("\The [gun] snaps back onto \the [src]!"))
	update_icon(UPDATE_ICON_STATE)

/obj/item/gun/energy/gun/minigun
	name = "IK-134 gatling gun"
	desc = "An advanced laser cannon with an incredible rate of fire. Requires a bulky backpack power source to use."
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "minigun_spin"
	inhand_icon_state = "minigun"
	slowdown = 1.5
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	weapon_weight = WEAPON_HEAVY
	ammo_type = list(/obj/item/ammo_casing/energy/laser/minigun)
	cell_type = /obj/item/stock_parts/cell/minigun
	can_charge = FALSE
	selfcharge = TRUE
	charge_delay = 1
	can_fit_in_turrets = FALSE
	shaded_charge = FALSE
	/// Associated ammo pack
	var/obj/item/minigunpack/ammo_pack

/obj/item/gun/energy/gun/minigun/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/minigunpack)) // We should spawn inside an ammo pack so let's use that one.
		return INITIALIZE_HINT_QDEL // No pack, no gun
	ammo_pack = loc
	AddComponent(/datum/component/automatic_fire, 0.1 SECONDS, allow_akimbo = FALSE)

/obj/item/gun/energy/gun/minigun/Destroy()
	if(!QDELETED(ammo_pack))
		qdel(ammo_pack)
	ammo_pack = null
	return ..()

/obj/item/gun/energy/gun/minigun/attack_self__legacy__attackchain(mob/living/user)
	return

/obj/item/gun/energy/gun/minigun/dropped(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	if(ammo_pack)
		ammo_pack.attach_gun(user)
	else
		qdel(src)

/obj/item/stock_parts/cell/minigun
	name = "gatling gun fusion core"
	desc = "Where did these come from?"
	charge = 15000
	maxcharge = 15000

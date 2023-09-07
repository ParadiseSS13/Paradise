/obj/effect/proc_holder/spell/flayer/self/weapon
	name = "Create weapon"
	desc = "This really shouldn't be here"
	power_type = FLAYER_UNOBTAINABLE_POWER
	base_cooldown = 1 SECONDS //This just handles retracting and deploying the weapon, weapon charge will be fully separate
	var/weapon_type
	var/weapon_name_simple
	var/obj/item/weapon_ref


/obj/effect/proc_holder/spell/flayer/self/weapon/cast(list/targets, mob/user)
	if(istype(user.l_hand, weapon_type) || istype(user.r_hand, weapon_type))
		retract(user, TRUE)
		return
	SEND_SIGNAL(user, COMSIG_MOB_WEAPON_APPEARS)
	if(!user.drop_item())
		to_chat(user, "[user.get_active_hand()] is stuck to your hand, you cannot grow a [weapon_name_simple] over it!")
		return FALSE
	if(!weapon_ref)
		weapon_ref = new weapon_type(user, src)
	user.put_in_hands(weapon_ref)
	playsound(get_turf(user), 'sound/mecha/mechmove03.ogg', 50, 1)
	RegisterSignal(user, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(retract), user)
	RegisterSignal(user, COMSIG_MOB_WEAPON_APPEARS, PROC_REF(retract), user)
	return weapon_ref

/obj/effect/proc_holder/spell/flayer/self/weapon/proc/retract(mob/owner, any_hand = TRUE)
	SIGNAL_HANDLER
	if(!any_hand && !istype(owner.get_active_hand(), weapon_type))
		return
	owner.unEquip(weapon_ref, TRUE)
	weapon_ref.forceMove(src)
	owner.update_inv_l_hand()
	owner.update_inv_r_hand()
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)

/**
	START OF INDIVIDUAL WEAPONS
*/

/obj/effect/proc_holder/spell/flayer/self/weapon/swarmprod
	name = "Swarmprod"
	desc = "Add me!"
	power_type = FLAYER_INNATE_POWER
	weapon_type = /obj/item/melee/baton/flayerprod

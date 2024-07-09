/datum/component/ckey_and_role_locked_pickup
	var/pickup_damage
	var/force = 20
	var/list/ckeys = list()
	var/offstation_role
	var/refusal_text

/datum/component/ckey_and_role_locked_pickup/Initialize(offstation_role = TRUE, ckey_whitelist, pickup_damage = 0, refusal_text)
		src.offstation_role = offstation_role
		src.ckeys = ckey_whitelist
		src.pickup_damage = pickup_damage
		src.refusal_text = refusal_text

/datum/component/ckey_and_role_locked_pickup/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(try_pick_up))

/datum/component/ckey_and_role_locked_pickup/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_PICKUP)

/datum/component/ckey_and_role_locked_pickup/proc/try_pick_up(obj/item/I, mob/living/user)

	if(check_role_and_ckey(user))
		return
	user.Weaken(10 SECONDS)
	user.unEquip(I, force, silent = FALSE)
	to_chat(user, span_userdanger(refusal_text))
	if(ishuman(user))
		user.apply_damage(rand(pickup_damage, pickup_damage * 2), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))

/datum/component/ckey_and_role_locked_pickup/proc/check_role_and_ckey(mob/user)
	if(user.client.ckey in ckeys)
		return TRUE

	return user.mind.offstation_role == offstation_role

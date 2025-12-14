/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "A handgun holster."
	icon_state = "holster"
	slot = ACCESSORY_SLOT_UTILITY
	var/list/holster_allow = list(/obj/item/gun)
	var/obj/item/gun/holstered = null
	actions_types = list(/datum/action/item_action/accessory/holster)
	w_class = WEIGHT_CLASS_NORMAL // so it doesn't fit in pockets

/obj/item/clothing/accessory/holster/Destroy()
	if(holstered?.loc == src) // Gun still in the holster
		holstered.forceMove(loc)
	holstered = null
	return ..()

//subtypes can override this to specify what can be holstered
/obj/item/clothing/accessory/holster/proc/can_holster(obj/item/gun/W)
	if(!W.can_holster)
		return FALSE
	else if(!is_type_in_list(W, holster_allow))
		return FALSE
	else
		return TRUE

/obj/item/clothing/accessory/holster/attack_self__legacy__attackchain()
	var/holsteritem = usr.get_active_hand()
	if(!holstered)
		holster(holsteritem, usr)
	else
		unholster(usr)

/obj/item/clothing/accessory/holster/proc/holster(obj/item/I, mob/user as mob)
	if(holstered)
		to_chat(user, SPAN_WARNING("There is already a [holstered] holstered here!"))
		return

	if(!isgun(I))
		to_chat(user, SPAN_WARNING("Only guns can be holstered!"))
		return

	var/obj/item/gun/W = I
	if(!can_holster(W))
		to_chat(user, SPAN_WARNING("This [W.name] won't fit in [src]!"))
		return

	if(!user.canUnEquip(W, 0))
		to_chat(user, SPAN_WARNING("You can't let go of [W]!"))
		return

	holstered = W
	user.unequip(holstered)
	holstered.forceMove(src)
	holstered.add_fingerprint(user)
	user.visible_message(SPAN_NOTICE("[user] holsters [holstered]."), SPAN_NOTICE("You holster [holstered]."))

/obj/item/clothing/accessory/holster/proc/unholster(mob/user as mob)
	if(!holstered)
		return

	if(isobj(user.get_active_hand()) && isobj(user.get_inactive_hand()))
		to_chat(user, SPAN_WARNING("You need an empty hand to draw [holstered]!"))
	else
		if(user.a_intent == INTENT_HARM)
			usr.visible_message(SPAN_WARNING("[user] draws [holstered], ready to shoot!"), \
			SPAN_WARNING("You draw [holstered], ready to shoot!"))
		else
			user.visible_message(SPAN_NOTICE("[user] draws [holstered], pointing it at the ground."), \
			SPAN_NOTICE("You draw [holstered], pointing it at the ground."))
		user.put_in_hands(holstered)
		holstered.add_fingerprint(user)
		holstered = null

/obj/item/clothing/accessory/holster/attack_hand(mob/user as mob)
	if(has_suit)	//if we are part of a suit
		if(holstered)
			unholster(user)
		return

	..(user)

/obj/item/clothing/accessory/holster/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	holster(W, user)

/obj/item/clothing/accessory/holster/emp_act(severity)
	if(holstered)
		holstered.emp_act(severity)
	..()

/obj/item/clothing/accessory/holster/examine(mob/user)
	. = ..()
	if(holstered)
		. += "A [holstered] is holstered here."
	else
		. += "It is empty."

//For the holster hotkey
/obj/item/clothing/accessory/holster/proc/handle_holster_usage(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(!holstered)
		var/obj/item/gun/gun = user.get_active_hand()
		if(!istype(gun))
			to_chat(user, SPAN_WARNING("You need your gun equipped to holster it."))
			return
		holster(gun, user)
	else
		unholster(user)

/obj/item/clothing/accessory/holster/armpit
	desc = "A worn-out handgun holster. Perfect for concealed carry"
	holster_allow = list(/obj/item/gun/projectile, /obj/item/gun/energy/detective)

/obj/item/clothing/accessory/holster/waist
	desc = "A handgun holster. Made of expensive leather."
	worn_icon_state = "holster_low"
	attached_icon_state = "holster_low"

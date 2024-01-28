/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "A handgun holster."
	icon_state = "holster"
	item_color = "holster"
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

/obj/item/clothing/accessory/holster/attack_self()
	var/holsteritem = usr.get_active_hand()
	if(!holstered)
		holster(holsteritem, usr)
	else
		unholster(usr)

/obj/item/clothing/accessory/holster/proc/holster(obj/item/I, mob/user as mob)
	if(holstered)
		to_chat(user, "<span class='warning'>There is already a [holstered] holstered here!</span>")
		return

	if(!istype(I, /obj/item/gun))
		to_chat(user, "<span class='warning'>Only guns can be holstered!</span>")
		return

	var/obj/item/gun/W = I
	if(!can_holster(W))
		to_chat(user, "<span class='warning'>This [W.name] won't fit in [src]!</span>")
		return

	if(!user.canUnEquip(W, 0))
		to_chat(user, "<span class='warning'>You can't let go of [W]!</span>")
		return

	holstered = W
	user.unEquip(holstered)
	holstered.loc = src
	holstered.add_fingerprint(user)
	user.visible_message("<span class='notice'>[user] holsters [holstered].</span>", "<span class='notice'>You holster [holstered].</span>")

/obj/item/clothing/accessory/holster/proc/unholster(mob/user as mob)
	if(!holstered)
		return

	if(isobj(user.get_active_hand()) && isobj(user.get_inactive_hand()))
		to_chat(user, "<span class='warning'>You need an empty hand to draw [holstered]!</span>")
	else
		if(user.a_intent == INTENT_HARM)
			usr.visible_message("<span class='warning'>[user] draws [holstered], ready to shoot!</span></span>", \
			"<span class='warning'>You draw [holstered], ready to shoot!</span>")
		else
			user.visible_message("<span class='notice'>[user] draws [holstered], pointing it at the ground.</span>", \
			"<span class='notice'>You draw [holstered], pointing it at the ground.</span>")
		user.put_in_hands(holstered)
		holstered.add_fingerprint(user)
		holstered = null

/obj/item/clothing/accessory/holster/attack_hand(mob/user as mob)
	if(has_suit)	//if we are part of a suit
		if(holstered)
			unholster(user)
		return

	..(user)

/obj/item/clothing/accessory/holster/attackby(obj/item/W as obj, mob/user as mob, params)
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
			to_chat(user, "<span class='warning'>You need your gun equiped to holster it.</span>")
			return
		holster(gun, user)
	else
		unholster(user)

/obj/item/clothing/accessory/holster/armpit
	name = "shoulder holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry"
	icon_state = "holster"
	item_color = "holster"
	holster_allow = list(/obj/item/gun/projectile, /obj/item/gun/energy/detective)

/obj/item/clothing/accessory/holster/waist
	name = "shoulder holster"
	desc = "A handgun holster. Made of expensive leather."
	icon_state = "holster"
	item_color = "holster_low"

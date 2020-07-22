/obj/item/clothing/accessory/storage
	name = "load bearing equipment"
	desc = "Used to hold things when you don't have enough hands."
	icon_state = "webbing"
	item_color = "webbing"
	slot = ACCESSORY_SLOT_UTILITY
	var/slots = 3
	var/obj/item/storage/internal/hold
	actions_types = list(/datum/action/item_action/accessory/storage)
	w_class = WEIGHT_CLASS_NORMAL // so it doesn't fit in pockets

/obj/item/clothing/accessory/storage/New()
	..()
	hold = new/obj/item/storage/internal(src)
	hold.storage_slots = slots

/obj/item/clothing/accessory/storage/Destroy()
	QDEL_NULL(hold)
	return ..()

/obj/item/clothing/accessory/storage/attack_hand(mob/user as mob)
	if(has_suit)	//if we are part of a suit
		hold.open(user)
		return

	if(hold.handle_attack_hand(user))	//otherwise interact as a regular storage item
		..(user)

/obj/item/clothing/accessory/storage/MouseDrop(obj/over_object as obj)
	if(has_suit)
		return

	if(hold.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/item/clothing/accessory/storage/attackby(obj/item/W as obj, mob/user as mob, params)
	return hold.attackby(W, user, params)

/obj/item/clothing/accessory/storage/emp_act(severity)
	hold.emp_act(severity)
	..()

/obj/item/clothing/accessory/storage/hear_talk(mob/M, list/message_pieces, verb)
	hold.hear_talk(M, message_pieces, verb)
	..()

/obj/item/clothing/accessory/storage/hear_message(mob/M, var/msg, verb, datum/language/speaking)
	hold.hear_message(M, msg)
	..()

/obj/item/clothing/accessory/storage/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/gift/G in src)
		L += G.gift
		if(istype(G.gift, /obj/item/storage))
			L += G.gift:return_inv()
	return L

/obj/item/clothing/accessory/storage/attack_self(mob/user as mob)
	if(has_suit)	//if we are part of a suit
		hold.open(user)
	else
		to_chat(user, "<span class='notice'>You empty [src].</span>")
		var/turf/T = get_turf(src)
		hold.hide_from(usr)
		for(var/obj/item/I in hold.contents)
			hold.remove_from_storage(I, T)
		src.add_fingerprint(user)

/obj/item/clothing/accessory/storage/webbing
	name = "webbing"
	desc = "Sturdy mess of synthcotton belts and buckles, ready to share your burden."
	icon_state = "webbing"
	item_color = "webbing"

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/storage/black_vest
	name = "black webbing vest"
	desc = "Robust black synthcotton vest with lots of pockets to hold whatever you need, but cannot hold in hands."
	icon_state = "vest_black"
	item_color = "vest_black"
	slots = 5

/obj/item/clothing/accessory/storage/brown_vest
	name = "brown webbing vest"
	desc = "Worn brownish synthcotton vest with lots of pockets to unload your hands."
	icon_state = "vest_brown"
	item_color = "vest_brown"
	slots = 5

/obj/item/clothing/accessory/storage/knifeharness
	name = "decorated harness"
	desc = "A heavily decorated harness of sinew and leather with two knife-loops."
	icon_state = "unathiharness2"
	item_color = "unathiharness2"
	slots = 2

/obj/item/clothing/accessory/storage/knifeharness/New()
	..()
	hold.max_combined_w_class = 4
	hold.can_hold = list(/obj/item/hatchet/unathiknife, /obj/item/kitchen/knife)

	new /obj/item/hatchet/unathiknife(hold)
	new /obj/item/hatchet/unathiknife(hold)

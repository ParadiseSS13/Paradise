/obj/item/clothing/suit/storage
	var/obj/item/weapon/storage/internal/pockets

/obj/item/clothing/suit/storage/New()
	..()
	pockets = new/obj/item/weapon/storage/internal(src)
	pockets.storage_slots = 2	//two slots
	pockets.max_w_class = 2		//fit only pocket sized items
	pockets.max_combined_w_class = 4

/obj/item/clothing/suit/storage/Destroy()
	qdel(pockets)
	pockets = null
	return ..()

/obj/item/clothing/suit/storage/attack_hand(mob/user as mob)
	if(pockets.handle_attack_hand(user))
		..(user)

/obj/item/clothing/suit/storage/MouseDrop(obj/over_object as obj)
	if(pockets.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/item/clothing/suit/storage/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	return pockets.attackby(W, user, params)

/obj/item/clothing/suit/storage/emp_act(severity)
	pockets.emp_act(severity)
	..()

/obj/item/clothing/suit/storage/hear_talk(mob/M, var/msg)
	pockets.hear_talk(M, msg)
	..()

/obj/item/clothing/suit/storage/hear_message(mob/M, var/msg)
	pockets.hear_message(M, msg)
	..()

/obj/item/clothing/suit/storage/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/weapon/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src)
		L += G.gift
		if(istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/obj/item/clothing/suit/storage/serialize()
	var/list/data = ..()
	data["pockets"] = pockets.serialize()
	return data

/obj/item/clothing/suit/storage/deserialize(list/data)
	qdel(pockets)
	pockets = list_to_object(data["pockets"], src)

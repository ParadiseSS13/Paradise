/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(access_armory)
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"

/obj/item/storage/lockbox/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/pda))
		if(broken)
			to_chat(user, "<span class='warning'>It appears to be broken.</span>")
			return
		if(check_access(W))
			locked = !locked
			if(locked)
				icon_state = icon_locked
				to_chat(user, "<span class='warning'>You lock \the [src]!</span>")
				return
			else
				icon_state = icon_closed
				to_chat(user, "<span class='warning'>You unlock \the [src]!</span>")
				origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.
				return
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return
	else if((istype(W, /obj/item/card/emag) || (istype(W, /obj/item/melee/energy/blade)) && !broken))
		emag_act(user)
		return
	if(!locked)
		..()
	else
		to_chat(user, "<span class='warning'>It's locked!</span>")
	return


/obj/item/storage/lockbox/show_to(mob/user as mob)
	if(locked)
		to_chat(user, "<span class='warning'>It's locked!</span>")
	else
		..()
	return

/obj/item/storage/lockbox/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(!locked)
		return ..()
	if(!stop_messages)
		to_chat(usr, "<span class='notice'>[src] is locked!</span>")
	return 0

/obj/item/storage/lockbox/emag_act(user as mob)
	if(!broken)
		broken = 1
		locked = 0
		desc = "It appears to be broken."
		icon_state = icon_broken
		to_chat(user, "<span class='notice'>You unlock \the [src].</span>")
		origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.
		return

/obj/item/storage/lockbox/hear_talk(mob/living/M as mob, list/message_pieces)

/obj/item/storage/lockbox/hear_message(mob/living/M as mob, msg)

/obj/item/storage/lockbox/large
	name = "Large lockbox"
	desc = "A large lockbox"
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 4 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 1

/obj/item/storage/lockbox/mindshield
	name = "Lockbox (Mindshield Implants)"
	req_access = list(access_security)

/obj/item/storage/lockbox/mindshield/New()
	..()
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implanter/mindshield(src)

/obj/item/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_access = list(access_security)

/obj/item/storage/lockbox/clusterbang/New()
	..()
	new /obj/item/grenade/clusterbuster(src)

/obj/item/storage/lockbox/medal
	name = "medal box"
	desc = "A locked box used to store medals of honor."
	icon_state = "medalbox+l"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 20
	storage_slots = 12
	req_access = list(access_captain)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"

/obj/item/storage/lockbox/medal/New()
	..()
	new /obj/item/clothing/accessory/medal/gold/heroism(src)
	new /obj/item/clothing/accessory/medal/silver/security(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/nobel_science(src)
	new /obj/item/clothing/accessory/medal/bronze_heart(src)
	new /obj/item/clothing/accessory/medal/conduct(src)
	new /obj/item/clothing/accessory/medal/conduct(src)
	new /obj/item/clothing/accessory/medal/conduct(src)
	new /obj/item/clothing/accessory/medal/gold/captain(src)

/obj/item/storage/lockbox/t4
	name = "lockbox (T4)"
	desc = "Contains three T4 breaching charges."
	req_access = list(access_cent_specops)

/obj/item/storage/lockbox/t4/New()
	..()
	for(var/i = 0, i < 3, i++)
		new /obj/item/grenade/plastic/x4/thermite(src)
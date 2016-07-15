//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = 4
	max_w_class = 3
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(access_armory)
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"


	attackby(obj/item/weapon/W as obj, mob/user as mob, params)
		if(istype(W, /obj/item/weapon/card/id))
			if(src.broken)
				to_chat(user, "<span class='warning'>It appears to be broken.</span>")
				return
			if(src.allowed(user))
				src.locked = !( src.locked )
				if(src.locked)
					src.icon_state = src.icon_locked
					to_chat(user, "<span class='warning'>You lock the [src.name]!</span>")
					return
				else
					src.icon_state = src.icon_closed
					to_chat(user, "<span class='warning'>You unlock the [src.name]!</span>")
					origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.
					return
			else
				to_chat(user, "<span class='warning'>Access Denied</span>")
		else if((istype(W, /obj/item/weapon/card/emag) || istype(W, /obj/item/weapon/melee/energy/blade)) && !broken)
			emag_act(user)
			return
		if(!locked)
			..()
		else
			to_chat(user, "<span class='warning'>It's locked!</span>")
		return


	show_to(mob/user as mob)
		if(locked)
			to_chat(user, "<span class='warning'>It's locked!</span>")
		else
			..()
		return

/obj/item/weapon/storage/lockbox/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(!locked)
		return ..()
	if(!stop_messages)
		to_chat(usr, "<span class='notice'>[src] is locked!</span>")
	return 0

/obj/item/weapon/storage/lockbox/emag_act(user as mob)
	if(!broken)
		broken = 1
		locked = 0
		desc = "It appears to be broken."
		icon_state = src.icon_broken
		to_chat(user, "<span class='notice'>You unlock \the [src].</span>")
		origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.
		return

/obj/item/weapon/storage/lockbox/hear_talk(mob/living/M as mob, msg)

/obj/item/weapon/storage/lockbox/hear_message(mob/living/M as mob, msg)

/obj/item/weapon/storage/lockbox/large
	name = "Large lockbox"
	desc = "A large lockbox"
	max_w_class = 4
	max_combined_w_class = 4 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 1

/obj/item/weapon/storage/lockbox/loyalty
	name = "Lockbox (Mindshield Implants)"
	req_access = list(access_security)

	New()
		..()
		new /obj/item/weapon/implantcase/loyalty(src)
		new /obj/item/weapon/implantcase/loyalty(src)
		new /obj/item/weapon/implantcase/loyalty(src)
		new /obj/item/weapon/implanter/loyalty(src)


/obj/item/weapon/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_access = list(access_security)

	New()
		..()
		new /obj/item/weapon/grenade/clusterbuster(src)


/obj/item/weapon/storage/lockbox/medal
	name = "medal box"
	desc = "A locked box used to store medals of honor."
	icon_state = "medalbox+l"
	item_state = "syringe_kit"
	w_class = 3
	max_w_class = 2
	max_combined_w_class = 20
	storage_slots = 12
	req_access = list(access_captain)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"

	New()
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

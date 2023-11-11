/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(ACCESS_ARMORY)
	var/locked = TRUE
	var/broken = FALSE
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
				if(user.s_active)
					user.s_active.close(user)
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

/obj/item/storage/lockbox/AltClick(mob/user)
	if(!Adjacent(user))
		return
	if(allowed(user))
		locked = !locked
		to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] [src].</span>")
		icon_state = "[locked ? icon_locked : icon_closed]"
	else
		to_chat(user, "<span class='warning'>Access denied.</span>")

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
		broken = TRUE
		locked = FALSE
		desc = "It appears to be broken."
		icon_state = icon_broken
		to_chat(user, "<span class='notice'>You unlock \the [src].</span>")
		origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.
		return

/obj/item/storage/lockbox/hear_talk(mob/living/M as mob, list/message_pieces)

/obj/item/storage/lockbox/hear_message(mob/living/M as mob, msg)

/obj/item/storage/lockbox/mindshield
	name = "Lockbox (Mindshield Implants)"
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/mindshield/populate_contents()
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implanter/mindshield(src)

/obj/item/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/clusterbang/populate_contents()
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
	req_access = list(ACCESS_CAPTAIN)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"

/obj/item/storage/lockbox/medal/populate_contents()
	new /obj/item/clothing/accessory/medal/gold/captain(src)
	new /obj/item/clothing/accessory/medal/silver/leadership(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/heart(src)

/obj/item/storage/lockbox/medal/cc
	name = "central command medal box"
	desc = "A locked box used to store ALL the medals you could ever need."
	max_combined_w_class = 30
	storage_slots = 15
	req_access = list(ACCESS_CENT_COMMANDER)

/obj/item/storage/lockbox/medal/cc/populate_contents()
	new /obj/item/clothing/accessory/medal/gold/heroism(src)
	..()
	new /obj/item/clothing/accessory/medal/gold(src)
	new /obj/item/clothing/accessory/medal/silver(src)
	new /obj/item/clothing/accessory/medal(src)

	// Departmental medals
	new /obj/item/clothing/accessory/medal/security(src)
	new /obj/item/clothing/accessory/medal/science(src)
	new /obj/item/clothing/accessory/medal/engineering(src)
	new /obj/item/clothing/accessory/medal/service(src)
	new /obj/item/clothing/accessory/medal/medical(src)
	new /obj/item/clothing/accessory/medal/legal(src)
	new /obj/item/clothing/accessory/medal/supply(src)

/obj/item/storage/lockbox/medal/hardmode_box
	name = "\improper HRD-MDE program medal box"
	desc = "A locked box used to store medals of pride. Use a fauna research disk on the box to transmit the data and print a medal."
	req_access = list(ACCESS_MINING) //No grubby assistant hands on my hard earned medals
	can_hold = list(/obj/item/clothing/accessory, /obj/item/coin) //Whoops almost gave miners boxes that could store 12 legion cores. Scoped to accessory if they want to store neclaces or hope or something in there. Or a coin collection.
	var/list/completed_fauna = list()
	var/number_of_megafauna = 7 //Increase this if new megafauna are added.

/obj/item/storage/lockbox/medal/hardmode_box/Initialize(mapload)
	. = ..()
	number_of_megafauna = length(subtypesof(/obj/item/disk/fauna_research))

/obj/item/storage/lockbox/medal/hardmode_box/populate_contents()
	return

/obj/item/storage/lockbox/medal/hardmode_box/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/disk/fauna_research))
		var/obj/item/disk/fauna_research/disky = W
		var/obj/item/pride = new disky.output(get_turf(src))
		to_chat(user, "<span class='notice'>[src] accepts [disky], and prints out [pride]!</span>")
		qdel(disky)
		if(!is_type_in_list(pride, completed_fauna))
			completed_fauna += pride.type
			if(length(completed_fauna) == number_of_megafauna)
				to_chat(user, "<span class='notice'>[src] prints out a very fancy medal!</span>")
				var/obj/item/accomplishment = new /obj/item/clothing/accessory/medal/gold/heroism/hardmode_full(get_turf(src))
				user.put_in_hands(accomplishment)
		user.put_in_hands(pride)
		return
	return ..()

/obj/item/storage/lockbox/t4
	name = "lockbox (T4)"
	desc = "Contains three T4 breaching charges."
	req_access = list(ACCESS_CENT_SPECOPS)

/obj/item/storage/lockbox/t4/populate_contents()
	for(var/i in 0 to 2)
		new /obj/item/grenade/plastic/c4/thermite(src)

/obj/item/storage/lockbox/research

/obj/item/storage/lockbox/research/deconstruct(disassembled = TRUE) // Get wrecked, Science nerds
	qdel(src)

/obj/item/storage/lockbox/research/modsuit
	name = "Plating lockbox"
	desc = "A larger lockbox. Looks a bit less secure than other lockboxes."

/obj/item/storage/lockbox/research/modsuit/emp_act(severity) //I want emp to get around it, it's not a gun, I just want people not to always make sec / med modsuits.
	. = ..()
	if(prob(50 / severity))
		locked = FALSE
		icon_state = icon_broken
		origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.

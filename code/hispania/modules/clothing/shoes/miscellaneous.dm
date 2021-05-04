/obj/item/clothing/shoes/jackboots/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/tape_roll))
		var/obj/item/stack/tape_roll/TR = I
		if(TR.use(4))
			to_chat(user, "You tape the soles of [src] to silence your footsteps.")
			if(istype(src, /obj/item/clothing/shoes/jackboots/jacksandals))
				new /obj/item/clothing/shoes/jackboots_silent/jacksandals_silent(get_turf(user))
			else
				new /obj/item/clothing/shoes/jackboots_silent(get_turf(user))
			qdel(src)
	else
		return ..()

/obj/item/clothing/shoes/jackboots_silent
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	can_cut_open = 1
	icon_state = "jackboots"
	item_state = "jackboots"
	item_color = "hosred"
	strip_delay = 50
	put_on_delay = 50
	resistance_flags = NONE

/obj/item/clothing/shoes/jackboots_silent/jacksandals_silent
	name = "jacksandals"
	desc = "Nanotrasen-issue Security combat sandals for combat scenarios. They're jacksandals, however that works."
	can_cut_open = 0
	icon_state = "jacksandal"
	item_color = "jacksandal"

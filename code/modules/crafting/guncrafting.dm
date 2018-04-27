// This file is for projectile weapon crafting. All parts and construction paths will be contained here.
// The weapons themselves are children of other weapons and should be contained in their respective files.

// PARTS //

/obj/item/weaponcrafting/receiver
	name = "modular receiver"
	desc = "A prototype modular receiver and trigger assembly for a firearm."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "receiver"

/obj/item/weaponcrafting/stock
	name = "rifle stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "riflestock"


// CRAFTING //

/obj/item/weaponcrafting/receiver/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W,/obj/item/pipe))
		to_chat(user, "You attach the shotgun barrel to the receiver. The pins seem loose.")
		var/obj/item/weaponcrafting/ishotgunconstruction/I = new /obj/item/weaponcrafting/ishotgunconstruction
		user.unEquip(src)
		user.put_in_hands(I)
		qdel(W)
		qdel(src)
		return

// SHOTGUN //

/obj/item/weaponcrafting/ishotgunconstruction
	name = "slightly conspicuous metal construction"
	desc = "A long pipe attached to a firearm receiver. The pins seem loose."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep1"

/obj/item/weaponcrafting/ishotgunconstruction/attackby(var/obj/item/I, mob/user as mob, params)
	..()
	if(istype(I, /obj/item/screwdriver))
		var/obj/item/weaponcrafting/ishotgunconstruction2/C = new /obj/item/weaponcrafting/ishotgunconstruction2
		user.unEquip(src)
		user.put_in_hands(C)
		to_chat(user, "<span class='notice'>You screw the pins into place, securing the pipe to the receiver.</span>")
		qdel(src)

/obj/item/weaponcrafting/ishotgunconstruction2
	name = "very conspicuous metal construction"
	desc = "A long pipe attached to a trigger assembly."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep1"

/obj/item/weaponcrafting/ishotgunconstruction2/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W,/obj/item/weaponcrafting/stock))
		to_chat(user, "You attach the stock to the receiver-barrel assembly.")
		var/obj/item/weaponcrafting/ishotgunconstruction3/I = new /obj/item/weaponcrafting/ishotgunconstruction3
		user.unEquip(src)
		user.put_in_hands(I)
		qdel(W)
		qdel(src)
		return

/obj/item/weaponcrafting/ishotgunconstruction3
	name = "extremely conspicuous metal construction"
	desc = "A receiver-barrel shotgun assembly with a loose wooden stock. There's no way you can fire it without the stock coming loose."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep2"

/obj/item/weaponcrafting/ishotgunconstruction3/attackby(var/obj/item/I, mob/user as mob, params)
	..()
	if(istype(I, /obj/item/stack/packageWrap))
		var/obj/item/stack/packageWrap/C = I
		if(C.use(5))
			var/obj/item/gun/projectile/revolver/doublebarrel/improvised/W = new /obj/item/gun/projectile/revolver/doublebarrel/improvised
			user.unEquip(src)
			user.put_in_hands(W)
			to_chat(user, "<span class='notice'>You tie the wrapping paper around the stock and the barrel to secure it.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need at least five feet of wrapping paper to secure the stock.</span>")
			return


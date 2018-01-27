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

/obj/item/weaponcrafting/flaregunparts
	name = "flare gun parts"
	desc = "A set of metal parts to make a flare rifle."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "flare_parts"


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
	else if(istype(W,/obj/item/weaponcrafting/flaregunparts))
		to_chat(user, "You loosely attach the flare rifle parts to the receiver. The barrel seem very loose.")
		var/obj/item/weaponcrafting/flaregunconstruction/I = new /obj/item/weaponcrafting/flaregunconstruction
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
	if(istype(I, /obj/item/weapon/screwdriver))
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
			var/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/W = new /obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised
			user.unEquip(src)
			user.put_in_hands(W)
			to_chat(user, "<span class='notice'>You tie the wrapping paper around the stock and the barrel to secure it.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need at least five feet of wrapping paper to secure the stock.</span>")
			return

//Flare Rifle//

/obj/item/weaponcrafting/flaregunconstruction
	name = "slightly assembled flare rifle"
	desc = "A loosely assembled flare rifle. The barrel seem loose."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "flaregunstep1"

/obj/item/weaponcrafting/flaregunconstruction/attackby(var/obj/item/I, mob/user as mob, params)
	..()
	if(istype(I, /obj/item/weapon/wrench))
		var/obj/item/weaponcrafting/flaregunconstruction2/C = new /obj/item/weaponcrafting/flaregunconstruction2
		user.unEquip(src)
		user.put_in_hands(C)
		to_chat(user, "<span class='notice'>You wrench the barrel into place, but now it seems like everything else is loose enough to fall off.</span>")
		qdel(src)

/obj/item/weaponcrafting/flaregunconstruction2
	name = "slightly assembled flare rifle"
	desc = "A loosely assembled flare rifle. The barrel seem loose."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "flaregunstep2"

/obj/item/weaponcrafting/flaregunconstruction2/attackby(var/obj/item/I, mob/user as mob, params)
	..()
	if(istype(I, /obj/item/weapon/screwdriver))
		var/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/flare/W = new /obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/flare
		user.unEquip(src)
		user.put_in_hands(W)
		to_chat(user, "<span class='notice'>You screw all the furniture on the gun, securing it enough to be operational.</span>")
		qdel(src)
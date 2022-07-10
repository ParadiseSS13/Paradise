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

///These gun kits are printed from the protolathe to then be used in making new weapons

// GUN PART KIT //

/obj/item/weaponcrafting/gunkit
	name = "generic gun parts kit"
	desc = "It's an empty gun parts container! Why do you have this?"
	icon = 'icons/obj/improvised.dmi'
	icon_state = "kitsuitcase"

/obj/item/weaponcrafting/gunkit/nuclear
	name = "\improper advanced energy gun parts kit"
	desc = "A suitcase containing the necessary gun parts to tranform a standard energy gun into an advaned energy gun."
	origin_tech = "combat=4;magnets=4;powerstorage=4"

/obj/item/weaponcrafting/gunkit/tesla
	name = "\improper tesla revolver parts kit"
	desc = "A suitcase containing the necessary gun parts to construct a tesla revolver around a laser rifle. Handle with care."
	origin_tech = "combat=4;materials=4;powerstorage=4"

/obj/item/weaponcrafting/gunkit/xray
	name = "\improper x-ray laser gun parts kit"
	desc = "A suitcase containing the necessary gun parts to turn a laser gun into a x-ray laser gun. Do not point most parts directly towards face."
	origin_tech = "combat=6;materials=4;magnets=4;syndicate=1"

/obj/item/weaponcrafting/gunkit/ion
	name = "\improper ion carbine parts kit"
	desc = "A suitcase containing the necessary gun parts to transform a standard energy gun into a ion carbine."
	origin_tech = "combat=4;magnets=4"

/obj/item/weaponcrafting/gunkit/temperature
	name = "\improper temperature gun parts kit"
	desc = "A suitcase containing the necessary gun parts to tranform a standard energy gun into a temperature gun. Fantastic at birthday parties and killing indigenious populations of Ash Walkers."
	origin_tech = "combat=4;materials=4;powerstorage=3;magnets=2"

/obj/item/weaponcrafting/gunkit/decloner
	name = "\improper decloner parts kit"
	desc = "An uttery baffling array of gun parts and technology that somehow turns an energy gun into a decloner. Haircut not included."
	origin_tech = "combat=4;materials=4;biotech=5;plasmatech=6"

/obj/item/weaponcrafting/gunkit/ebow
	name = "\improper energy crossbow parts kit"
	desc = "Highly illegal weapons refurbishment kit that allows you to turn the standard proto-kinetic accelerator into a near-duplicate energy crossbow. Almost like the real thing!"
	origin_tech = "combat=4;magnets=4;syndicate=2"

/obj/item/weaponcrafting/gunkit/immolator
	name = "\improper immolator laser gun parts kit"
	desc = "Take a perfectly functioning laser gun. Butcher the inside of the gun so it runs hot and mean. You now have a immolator laser. You monster."
	origin_tech = "combat=4;magnets=4;powerstorage=3"

/obj/item/weaponcrafting/gunkit/accelerator
	name = "\improper accelerator laser cannon parts kit"
	desc = "A suitcase containing the necessary gun parts to transform a standard laser gun into an accelerator laser cannon."
	origin_tech = "combat=4;magnets=4;powerstorage=3"

/obj/item/weaponcrafting/gunkit/plasma
	name = "\improper plasma pistol parts kit"
	desc = "A suitcase containing the necessary gun parts to transform a standard laser gun into a plasma pistol. Wort, wort, wort!"
	origin_tech = "combat=4;magnets=4;powerstorage=3"

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

/obj/item/weaponcrafting/ishotgunconstruction/attackby(obj/item/I, mob/user as mob, params)
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

/obj/item/weaponcrafting/ishotgunconstruction3/attackby(obj/item/I, mob/user as mob, params)
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


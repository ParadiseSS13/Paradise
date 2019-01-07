/obj/item/stack/telecrystal
	name = "telecrystal"
	desc = "It seems to be pulsing with suspiciously enticing energies."
	description_antag = "Telecrystals can be activated by utilizing them on devices with an actively running uplink. They will not activate on unactivated uplinks."
	singular_name = "telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "telecrystal"
	w_class = WEIGHT_CLASS_TINY
	max_amount = 50
	flags = NOBLUDGEON
	origin_tech = "materials=6;syndicate=1"

/obj/item/stack/telecrystal/attack(mob/target, mob/user)
	if(target == user) //You can't go around smacking people with crystals to find out if they have an uplink or not.
		for(var/obj/item/implant/uplink/I in target)
			if(I && I.imp_in)
				I.hidden_uplink.uses += amount
				use(amount)
				to_chat(user, "<span class='notice'>You press [src] onto yourself and charge your hidden uplink.</span>")

/obj/item/stack/telecrystal/afterattack(obj/item/I, mob/user, proximity)
	if(!proximity)
		return
	if(istype(I) && I.hidden_uplink && I.hidden_uplink.active) //No metagaming by using this on every PDA around just to see if it gets used up.
		I.hidden_uplink.uses += amount
		use(amount)
		to_chat(user, "<span class='notice'>You slot [src] into [I] and charge its internal uplink.</span>")
	else if(istype(I, /obj/item/cartridge/frame))
		var/obj/item/cartridge/frame/cart = I
		if(!cart.charges)
			to_chat(user, "<span class='notice'>[cart] is out of charges, it's refusing to accept [src]</span>")
			return
		cart.telecrystals += amount
		use(amount)
		to_chat(user, "<span class='notice'>You slot [src] into [cart].  The next time it's used, it will also give telecrystals</span>")

/obj/item/stack/telecrystal/five
	amount = 5

/obj/item/stack/telecrystal/twenty
	amount = 20

/obj/item/stack/telecrystal/fifty
	amount = 50

/obj/item/stack/telecrystal
	name = "telecrystal"
	desc = "It seems to be pulsing with suspiciously enticing energies."
	singular_name = "telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "telecrystal"
	w_class = 1
	max_amount = 50
	flags = NOBLUDGEON
	origin_tech = "materials=6;syndicate=1"

/obj/item/stack/telecrystal/afterattack(var/obj/item/I as obj, mob/user as mob, proximity)
	if(!proximity)
		return
	if(istype(I, /obj/item))
		if(I.hidden_uplink && I.hidden_uplink.active) //No metagaming by using this on every PDA around just to see if it gets used up.
			I.hidden_uplink.uses +=1
			use(1)
			user << "<span class='notice'>You slot the [src] into the [I] and charge its internal uplink.</span>"
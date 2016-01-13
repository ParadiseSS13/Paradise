
var/turf/T

/obj/item/weapon/grenade/bananade
	name = "bananade"
	desc = "A yellow grenade."
	w_class = 2.0
	icon = 'icons/obj/grenade.dmi'
	icon_state = "banana"
	item_state = "flashbang"
	var/deliveryamt = 8
	var/spawner_type = /obj/item/weapon/bananapeel

/obj/item/weapon/grenade/bananade/prime()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/items/bikehorn.ogg', 100, 1)
		for(var/mob/living/carbon/human/M in viewers(T, null))
			if(M:eyecheck() <= 0)
				flick("e_flash", M.flash) // flash dose faggots
		for(var/i=1, i<=deliveryamt, i++)
			var/atom/movable/x = new spawner_type
			x.loc = T
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(x, pick(NORTH,SOUTH,EAST,WEST))



	qdel(src)
	return

/obj/item/weapon/grenade/bananade/casing
	name = "bananium casing"
	desc = "A grenade casing made of bananium."
	icon_state = "banana_casing"
	var/fillamt = 0


/obj/item/weapon/grenade/bananade/casing/attackby(var/obj/item/I, mob/user as mob, params)
	if(istype(I, /obj/item/weapon/bananapeel))
		if(fillamt < 9)
			usr << "<span  class='notice'>You add another banana peel to the assembly.</span>"
			fillamt += 1
			qdel(I)
		else
			usr << "<span class='notice'>The bananade is full, screwdriver it shut to lock it down.</span>"
	if(istype(I, /obj/item/weapon/screwdriver))
		if(fillamt)
			var/obj/item/weapon/grenade/bananade/G = new /obj/item/weapon/grenade/bananade
			user.unEquip(src)
			user.put_in_hands(G)
			G.deliveryamt = src.fillamt
			user << "<span  class='notice'>You lock the assembly shut, readying it for HONK.</span>"
			qdel(src)
		else
			usr << "<span class='notice'>You need to add banana peels before you can ready the grenade!.</span>"
	else
		usr << "<span class='notice'>Only banana peels fit in this assembly, up to 9.</span>"
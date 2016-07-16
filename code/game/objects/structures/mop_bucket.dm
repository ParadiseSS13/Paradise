/obj/structure/mopbucket
	desc = "Fill it with water, but don't forget a mop!"
	name = "mop bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	flags = OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	janitorial_equipment += src

/obj/structure/mopbucket/full/New()
	..()
	reagents.add_reagent("water", 100)

/obj/structure/mopbucket/Destroy()
	janitorial_equipment -= src
	return ..()

/obj/structure/mopbucket/examine(mob/user)
	if(..(user, 1))
		to_chat(usr, "[bicon(src)] [src] contains [reagents.total_volume] units of water left!")

/obj/structure/mopbucket/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/mop))
		if(src.reagents.total_volume >= 2)
			src.reagents.trans_to(W, 2)
			to_chat(user, "\blue You wet the mop")
			playsound(src.loc, 'sound/effects/slosh.ogg', 25, 1)
		if(src.reagents.total_volume < 1)
			to_chat(user, "\blue Out of water!")
	return

/obj/structure/mopbucket/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			if(prob(5))
				qdel(src)
				return

/obj/structure/mopbucket
	desc = "Fill it with water, but don't forget a mop!"
	name = "mop bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	container_type = OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/New()
	..()
	create_reagents(100)
	GLOB.janitorial_equipment += src

/obj/structure/mopbucket/full/New()
	..()
	reagents.add_reagent("water", 100)

/obj/structure/mopbucket/Destroy()
	GLOB.janitorial_equipment -= src
	return ..()

/obj/structure/mopbucket/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += "[bicon(src)] [src] contains [reagents.total_volume] units of water left!"

/obj/structure/mopbucket/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/mop))
		if(src.reagents.total_volume >= 2)
			src.reagents.trans_to(W, 2)
			to_chat(user, "<span class='notice'>You wet the mop</span>")
			playsound(src.loc, 'sound/effects/slosh.ogg', 25, 1)
		if(src.reagents.total_volume < 1)
			to_chat(user, "<span class='notice'>Out of water!</span>")
		return
	return ..()

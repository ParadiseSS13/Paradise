//Fluff structures serve no purpose and exist only for enriching the environment. They can be destroyed with a wrench.

/obj/structure/fluff
	name = "fluff structure"
	desc = "Fluffier than a sheep. This shouldn't exist."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "minibar"
	anchored = TRUE
	density = FALSE
	opacity = 0
	var/deconstructible = TRUE

/obj/structure/fluff/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/wrench) && deconstructible)
		user.visible_message("<span class='notice'>[user] starts disassembling [src]...</span>", "<span class='notice'>You start disassembling [src]...</span>")
		playsound(loc, I.usesound, 50, 1)
		if(do_after(src, 50 * I.toolspeed, target = src))
			user.visible_message("<span class='notice'>[user] disassembles [src]!</span>", "<span class='notice'>You break down [src] into scrap metal.</span>")
			playsound(user, 'sound/items/deconstruct.ogg', 50, 1)
			new/obj/item/stack/sheet/metal(drop_location())
			qdel(src)
		return
	..()

/obj/structure/fluff/drake_statue //Ash drake status spawn on either side of the necropolis gate in lavaland.
	name = "drake statue"
	desc = "A towering basalt sculpture of a proud and regal drake. Its eyes are six glowing gemstones."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "drake_statue"
	pixel_x = -16
	density = TRUE
	deconstructible = FALSE
	layer = EDGED_TURF_LAYER

/obj/structure/fluff/drake_statue/falling //A variety of statue in disrepair; parts are broken off and a gemstone is missing
	desc = "A towering basalt sculpture of a drake. Cracks run down its surface and parts of it have fallen off."
	icon_state = "drake_statue_falling"

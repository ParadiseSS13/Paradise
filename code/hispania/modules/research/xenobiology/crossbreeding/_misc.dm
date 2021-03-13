/*
Slimecrossing Items
	General items added by the slimecrossing system.
	Collected here for clarity.
*///Hypercharged slime cell - Charged Yellow

/obj/item/stock_parts/cell/high/slime/hypercharged
	name = "hypercharged slime core"
	desc = "A charged yellow slime extract, infused with even more plasma. It almost hurts to touch."
	maxcharge = 20000 //2 times the normal one.
	chargerate = 750 //1.5 times the normal rate.

//Barrier cube - Chilling Grey
/obj/item/barriercube
	name = "barrier cube"
	desc = "A compressed cube of slime. When squeezed, it grows to massive size!"
	icon = 'icons/hispania/obj/slimecrossing.dmi'
	icon_state = "barriercube"
	w_class = WEIGHT_CLASS_TINY

/obj/item/barriercube/attack_self(mob/user)
	if(locate(/obj/structure/barricade/slime) in get_turf(loc))
		to_chat(user, "<span class='warning'>You can't fit more than one barrier in the same space!</span>")
		return
	to_chat(user, "<span class='notice'>You squeeze [src].</span>")
	var/obj/B = new /obj/structure/barricade/slime(get_turf(loc))
	B.visible_message("<span class='warning'>[src] suddenly grows into a large, gelatinous barrier!</span>")
	qdel(src)

//Slime barricade - Chilling Grey
/obj/structure/barricade/slime
	name = "gelatinous barrier"
	desc = "A huge chunk of grey slime. Bullets might get stuck in it."
	icon = 'icons/hispania/obj/slimecrossing.dmi'
	icon_state = "slimebarrier"
	proj_pass_rate = 40
	max_integrity = 60

//Melting Gel Wall - Chilling Metal
/obj/effect/forcefield/slimewall
	name = "solidified gel"
	desc = "A mass of solidified slime gel - completely impenetrable, but it's melting away!"
	icon = 'icons/hispania/obj/slimecrossing.dmi'
	icon_state = "slimebarrier_thick"
	opacity = TRUE
	lifetime = 100

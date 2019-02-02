///Hispania Ingredients


///cookies by Ume

/obj/item/reagent_containers/food/snacks/cookiedough
	name = "cookie dough"
	desc = "The base for tasty cookies."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "cookiedough"
	list_reagents = list("nutriment" = 5)

// Dough + rolling pin = flat cookie dough
/obj/item/reagent_containers/food/snacks/cookiedough/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/cookiedough_flat(loc)
			to_chat(user, "<span class='notice'>You flatten [src].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to roll it out!</span>")
	else
		..()

/obj/item/reagent_containers/food/snacks/cookiedough_flat
	name = "flat cookie dough"
	desc = "The base for tasty cookies."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "cookiedough_flat"
	list_reagents = list("nutriment" = 5)

//Flat cookie dough + cookie cutter = Raw cookies
/obj/item/reagent_containers/food/snacks/cookiedough_flat/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/cutter))
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/rawcookies(loc)
			to_chat(user, "<span class='notice'>You cut [src] into cookies.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to cut it out!</span>")
	else
		..()

/obj/item/reagent_containers/food/snacks/rawcookies
	name = "raw cookies"
	desc = "Ready for oven!"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "unbaked_cookies"
	list_reagents = list("nutriment" = 5)
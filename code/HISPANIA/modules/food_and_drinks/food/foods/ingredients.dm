///Hispania Ingredients


///cookies by Ume

obj/item/reagent_containers/food/snacks/cookiedough
	var/flat = FALSE
	name = "pastry dough"
	icon = 'icons/hispania/obj/food/food.dmi'
	desc = "The base for tasty cookies."
	icon_state = "cookiedough"
	list_reagents = list("nutriment" = 5, "sugar" = 5)

/obj/item/reagent_containers/food/snacks/cookiedough/update_icon()
    if(flat)
        icon_state = "cookiedough_flat"
        name = "flat pastry dough"
    else
        icon_state = "cookiedough"



// Dough + rolling pin = flat cookie dough // Flat dough + circular cutter = unbaked cookies
/obj/item/reagent_containers/food/snacks/cookiedough/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/rollingpin) && !flat)
		if(isturf(loc))
			to_chat(user, "<span class='notice'>You flatten [src].</span>")
			flat = TRUE
			update_icon()
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to roll it out!</span>")
	else if (istype(I, /obj/item/kitchen/cutter) && flat)
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/rawcookies(loc)
			to_chat(user, "<span class='notice'>You cut [src] into cookies.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to cut it out!</span>")
	else
		return..()


/obj/item/reagent_containers/food/snacks/rawcookies
	name = "raw cookies"
	desc = "Ready for oven!"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "unbaked_cookies"
	list_reagents = list("nutriment" = 5, "sugar" = 5)

/obj/item/reagent_containers/food/snacks/rawcookies/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/choc_pile))
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/rawcookies/chocochips(loc)
			to_chat(user, "<span class='notice'>You sprinkle [I] all over the cookies.</span>")
			qdel(src)
			qdel(I)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to add this</span>")
	else
		return..()

/obj/item/reagent_containers/food/snacks/rawcookies/chocochips
	name = "raw cookies"
	desc = "Ready for oven! They have little pieces of chocolate all over them"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "unbaked_cookies_choco"
	list_reagents = list("nutriment" = 5, "sugar" = 5, "chocolate" = 5)


///Chocolate crumbles/pile
/obj/item/reagent_containers/food/snacks/chocolatebar/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/knife))
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/choc_pile(loc)
			to_chat(user, "<span class='notice'>You cut [src] into little crumbles.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to cut it out!</span>")
	else
		return..()


/////cookies end here
/obj/item/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "meatball"
	filling_color = "#DB0000"
	list_reagents = list("protein" = 4, "vitamin" = 1)
	tastes = list("meat" = 1)
	burns_on_grill = TRUE

/obj/item/reagent_containers/food/snacks/meatball/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/cutlet))
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/raw_sausage(loc)
			to_chat(user, "<span class='notice'>You insert the [I] into the [src].</span>")
			qdel(I)
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface!</span>")
	else
		..()

/obj/item/reagent_containers/food/snacks/meatball/afterattack(atom/A as mob|obj, mob/user,proximity)
	if(istype(A, /obj/item/reagent_containers/food/snacks/cutlet))
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/raw_sausage(loc)
			to_chat(user, "<span class='notice'>You insert the [A] into the [src].</span>")
			qdel(A)
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface!</span>")
	else
		..()

/obj/item/reagent_containers/food/snacks/meatball/human
	name = "strange meatball"

/obj/item/reagent_containers/food/snacks/meatball/xeno
	name = "xenomorph meatball"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/reagent_containers/food/snacks/meatball/bear
	name = "bear meatball"
	tastes = list("meat" = 1, "salmon" = 1)

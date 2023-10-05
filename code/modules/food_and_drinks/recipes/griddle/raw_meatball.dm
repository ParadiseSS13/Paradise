/obj/item/reagent_containers/food/snacks/raw_meatball
	name = "raw meatball"
	desc = "A great meal all round. Not a cord of wood. Kinda raw"
	icon_state = "raw_meatball"
	list_reagents = list("protein"= 2)
	tastes = list("meat" = 1)
	w_class = WEIGHT_CLASS_SMALL
	var/meatball_type = /obj/item/reagent_containers/food/snacks/meatball
	var/patty_type = /obj/item/reagent_containers/food/snacks/raw_patty

/obj/item/reagent_containers/food/snacks/raw_meatball/make_grillable()
	AddComponent(/datum/component/grillable, meatball_type, rand(30 SECONDS, 40 SECONDS), TRUE)

/obj/item/reagent_containers/food/snacks/raw_meatball/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/rollingpin))
		if(isturf(loc))
			new patty_type(loc)
			to_chat(user, "<span class='notice'>You flatten [src].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to flatten it out!</span>")
	else
		..()

/obj/item/reagent_containers/food/snacks/raw_meatball/bear
	name = "raw bear meatball"
	patty_type = /obj/item/reagent_containers/food/snacks/raw_patty/bear
	meatball_type = /obj/item/reagent_containers/food/snacks/meatball/bear

/obj/item/reagent_containers/food/snacks/raw_meatball/xeno
	name = "raw xeno ball"
	patty_type = /obj/item/reagent_containers/food/snacks/raw_patty/xeno
	meatball_type = /obj/item/reagent_containers/food/snacks/meatball/xeno

/obj/item/reagent_containers/food/snacks/raw_meatball/human
	name = "strange raw meatball"
	meatball_type = /obj/item/reagent_containers/food/snacks/meatball/human
	patty_type = /obj/item/reagent_containers/food/snacks/raw_patty/human

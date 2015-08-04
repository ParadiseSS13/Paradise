/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	health = 180
	filling_color = "#FF1C1C"
	New()
		..()
		reagents.add_reagent("protein", 3)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if( \
			istype(W, /obj/item/weapon/kitchenknife) || \
			istype(W, /obj/item/weapon/butch) || \
			istype(W, /obj/item/weapon/scalpel) || \
			istype(W, /obj/item/weapon/kitchen/utensil/knife) \
		)
		new /obj/item/weapon/reagent_containers/food/snacks/rawcutlet(src)
		new /obj/item/weapon/reagent_containers/food/snacks/rawcutlet(src)
		new /obj/item/weapon/reagent_containers/food/snacks/rawcutlet(src)
		user << "You cut the meat in thin strips."
		qdel(src)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/weapon/reagent_containers/food/snacks/meat/human
	name = "-meat"
	var/subjectname = ""
	var/subjectjob = null


/obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	//same as plain meat

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

/obj/item/weapon/reagent_containers/food/snacks/meat/pug
	name = "Pug meat"
	desc = "Tastes like... well you know..."

/obj/item/weapon/reagent_containers/food/snacks/meat/ham
	name = "Ham"
	desc = "Taste like bacon."
	New()
		..()
		reagents.add_reagent("porktonium", 10)
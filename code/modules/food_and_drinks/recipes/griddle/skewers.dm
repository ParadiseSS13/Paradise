/obj/item/kabob_skewer
	name = "kabob skewer"
	desc = "kebab? kabob!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "empty_skewer"
//	var/max_length = 2
	var/list/stored_items = new/list()

/obj/item/kabob_skewer/attack_self()
	for(var/obj/item/I in stored_items)
		I.forceMove(get_turf(src))
		stored_items -= I
	update_icons()
	return ..()

/obj/item/kabob_skewer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/tofu) || istype(I, /obj/item/reagent_containers/food/snacks/meat) || istype(I, /obj/item/reagent_containers/food/snacks/shrimp) || istype(I, /obj/item/reagent_containers/food/snacks/salmonmeat))
		addtoskewer(I, user)
	return..()

/obj/item/kabob_skewer/proc/addtoskewer(obj/item/I, mob/M)
	if(!stored_items.len)
		if(istype(I, /obj/item/reagent_containers/food/snacks/salmonmeat))
			new /obj/item/reagent_containers/food/snacks/raw_fish_skewer(get_turf(src))
			qdel(src)
			qdel(I)
			return
		stored_items += I
		M.unEquip(I)
		I.forceMove(src)
		update_icons()
		return
	if(istype(I, /obj/item/reagent_containers/food/snacks/meat) && istype(stored_items[1], /obj/item/reagent_containers/food/snacks/meat))
		new /obj/item/reagent_containers/food/snacks/raw_monkeykabob(get_turf(src))
		for(var/A in stored_items)
			qdel(A)
		qdel(src)
	else if(istype(I, /obj/item/reagent_containers/food/snacks/tofu) && istype(stored_items[1], /obj/item/reagent_containers/food/snacks/tofu))
		new /obj/item/reagent_containers/food/snacks/raw_tofukabob(get_turf(src))
		for(var/A in stored_items)
			qdel(A)
		qdel(src)
	else if(istype(I, /obj/item/reagent_containers/food/snacks/shrimp) && istype(stored_items[1], /obj/item/reagent_containers/food/snacks/shrimp))
		stored_items += I
		M.unEquip(I)
		I.forceMove(src)
		update_icons()
		if(stored_items.len >= 4)
			new /obj/item/reagent_containers/food/snacks/raw_shrimp_skewer(get_turf(src))
			for(var/A in stored_items)
				qdel(A)
			qdel(src)
			return

/obj/item/kabob_skewer/proc/update_icons()
	if(!stored_items.len)
		icon_state = "empty_skewer"
		return
	for(var/obj/item/I in stored_items)
		if(istype(I, /obj/item/reagent_containers/food/snacks/meat) || istype(I, /obj/item/reagent_containers/food/snacks/tofu))
			icon_state = "skewer_meat_one"
			return
		if(istype(I, /obj/item/reagent_containers/food/snacks/shrimp))
			switch(stored_items.len)
				if(1)
					icon_state = "skewer_shrimp_one"
					return
				if(2)
					icon_state = "skewer_shrimp_two"
					return
				if(3)
					icon_state = "skewer_shrimp_three"
					return
				else
					icon_state = "empty_skewer"
					return

/obj/item/reagent_containers/food/snacks/raw_shrimp_skewer
	name = "raw shrimp skewer"
	desc = "Raw shrimp, yum."
	trash = /obj/item/stack/rods
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimpskewer"
	bitesize = 1
	list_reagents = list("nutriment" = 1)
	tastes = list("shrimp" = 1)

/obj/item/reagent_containers/food/snacks/raw_monkeykabob
	name = "raw meat-kabob"
	icon_state = "kabob"
	desc = "Delicious raw food"
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list("nutriment" = 1)

/obj/item/reagent_containers/food/snacks/raw_tofukabob
	name = "raw tofu-kabob"
	icon_state = "kabob"
	desc = "Uncooked tofu on a stick!"
	trash = /obj/item/stack/rods
	filling_color = "#FFFEE0"
	list_reagents = list("nutriment" = 1)

/obj/item/reagent_containers/food/snacks/raw_fish_skewer
	name = "raw fish skewer"
	desc = "Raw fish, yuck!"
	trash = /obj/item/stack/rods
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishskewer"
	bitesize = 1
	list_reagents = list("protein" = 1)
	tastes = list("shrimp" = 1)

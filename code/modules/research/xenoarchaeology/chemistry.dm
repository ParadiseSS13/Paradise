/obj/item/weapon/reagent_containers/glass/solution_tray
	name = "solution tray"
	desc = "A small, open-topped glass container for delicate research samples. It sports a re-useable strip for labelling with a pen."
	icon = 'icons/obj/device.dmi'
	icon_state = "solution_tray"
	materials = list(MAT_GLASS=5)
	w_class = 1
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 2)
	volume = 2
	flags = OPENCONTAINER

obj/item/weapon/reagent_containers/glass/solution_tray/attackby(obj/item/weapon/W as obj, mob/living/user as mob, params)
	if(istype(W, /obj/item/weapon/pen))
		var/new_label = input("What should the new label be?","Label solution tray")
		if(new_label)
			name = "solution tray ([new_label])"
			to_chat(user, "\blue You write on the label of the solution tray.")
	else
		..(W, user)

/obj/item/weapon/storage/box/solution_trays
	name = "solution tray box"
	icon_state = "solution_trays"

	New()
		..()
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )

/obj/item/weapon/reagent_containers/glass/beaker/oxygen
	name = "beaker 'oxygen'"
	list_reagents = list("oxygen" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/sodium
	name = "beaker 'sodium'"
	list_reagents = list("sodium" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/lithium
	name = "beaker 'lithium'"
	list_reagents = list("lithium" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/water
	name = "beaker 'water'"
	list_reagents = list("water" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/fuel
	name = "beaker 'fuel'"
	list_reagents = list("fuel" = 50)
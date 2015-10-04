
/obj/item/weapon/reagent_containers/glass/bottle/robot
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = OPENCONTAINER
	volume = 60
	var/reagent = ""


/obj/item/weapon/reagent_containers/glass/bottle/robot/epinephrine
	name = "internal epinephrine bottle"
	desc = "A small bottle. Contains epinephrine - used to stabilize patients."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	reagent = "epinephrine"

/obj/item/weapon/reagent_containers/glass/bottle/robot/epinephrine/New()
	..()
	reagents.add_reagent("epinephrine", 60)
	return

/obj/item/weapon/reagent_containers/glass/bottle/robot/charcoal
	name = "internal charcoal bottle"
	desc = "A small bottle of charcoal. Counters poisons and repairs damage."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	reagent = "charcoal"

/obj/item/weapon/reagent_containers/glass/bottle/robot/charcoal/New()
	..()
	reagents.add_reagent("charcoal", 60)
	return
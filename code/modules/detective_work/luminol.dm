/obj/item/weapon/reagent_containers/spray/luminol
	name = "luminol bottle"
	desc = "A bottle containing an odourless, colorless liquid."
	icon = 'icons/obj/device.dmi'
	icon_state = "luminol"
	item_state = "cleaner"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10)
	volume = 250

/obj/item/weapon/reagent_containers/spray/luminol/New()
	..()
	reagents.add_reagent("luminol", 250)
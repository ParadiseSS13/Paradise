/obj/item/weapon/reagent_containers/food/drinks/shaker/fitnessflask
	name = "fitness shaker"
	desc = "Big enough to contain enough protein to get perfectly swole. Don't mind the bits."
	icon = 'hyntatmta/icons/obj/food/fitnesfoodsp.dmi'
	icon_state = "fitness-cup_black"
	volume = 100
	possible_transfer_amounts = "5;10;15;25"
	var/lid_color = "black"



/obj/item/weapon/reagent_containers/food/drinks/shaker/fitnessflask/proteinshake
	name = "protein shake"
	desc = "Big enough to contain enough protein to get perfectly swole. Don't mind the bits."
	volume = 100
	icon_state = "fitness-cup_black"
/obj/item/weapon/reagent_containers/food/drinks/shaker/fitnessflask/proteinshake/New()
	..()
	reagents.add_reagent("nutriment", 30)
	reagents.add_reagent("iron", 10)
	reagents.add_reagent("protein", 15)
	reagents.add_reagent("water", 45)


/obj/item/weapon/reagent_containers/food/condiment/milk/smallcarton
	name = "small milk carton"
	volume = 40
	icon = 'hyntatmta/icons/obj/food/fitnesfoodsp.dmi'
	icon_state = "mini-milk"
/obj/item/weapon/reagent_containers/food/condiment/milk/smallcarton/New()
	..()
	reagents.add_reagent("milk", 30)

/obj/item/weapon/reagent_containers/food/condiment/milk/smallcarton/chocolate/
	name = "small chocolate milk carton"
	desc = "It's milk! This one is in delicious chocolate flavour."
	volume = 40

/obj/item/weapon/reagent_containers/food/condiment/milk/smallcarton/chocolate/New()
	..()
	reagents.add_reagent("chocolate", 10)
	reagents.add_reagent("milk", 30)


/obj/item/weapon/reagent_containers/food/snacks/candy/proteinbar
	name = "protein bar"
	desc = "SwoleMAX brand protein bars, guaranteed to get you feeling perfectly overconfident."
	icon_state = "snackbar"

/obj/item/weapon/reagent_containers/food/snacks/candy/proteinbar
	name = "protein bar"
	desc = "SwoleMAX brand protein bars, guaranteed to get you feeling perfectly overconfident."
	icon = 'hyntatmta/icons/obj/food/fitnesfoodsp.dmi'
	icon_state = "proteinbar"
	bitesize = 5
	list_reagents = list("nutriment" = 9, "protein" = 4, "sugar" = 4)

/obj/item/weapon/reagent_containers/food/pill/dietpill
	name = "diet pill"
	desc = "Guaranteed to get you slim!"
	icon_state = "pill8"
	list_reagents = list("lipolicide" = 15)

/// HISPANIA CANS
/obj/item/reagent_containers/food/drinks/cans/hispania
	icon = 'icons/hispania/obj/drinks.dmi'

/obj/item/reagent_containers/food/drinks/cans/hispania/space_mundet
	name = "Space Mundet"
	desc = "A can of apple juice. Just like in your childhood"
	icon_state = "space_mundet"
	item_state = "space_mundet"
	list_reagents = list("applejuice" = 30)

/obj/item/reagent_containers/food/drinks/cans/hispania/mr_coffe_brown
	name = "Mrs Brown"
	desc = "A can of iced coffe. A weird looking can with a big red star."
	icon_state = "mrs_brown"
	item_state = "mrs_brown"
	list_reagents = list("icecoffee" = 30)

/obj/item/reagent_containers/food/drinks/cans/hispania/behemoth_energy
	name = "Behemoth Energy"
	desc = "Tear into a can of the meanest energy drink on the planet, Behemoth Energy."
	icon_state = "behemoth"
	item_state = "behemoth"
	list_reagents = list("sugar" = 5, "ale" = 10, "sodawater" = 10)

/obj/item/reagent_containers/food/drinks/cans/hispania/behemoth_energy/New()
	..()
	if(prob(30))
		reagents.add_reagent("methamphetamine", 3)

/obj/item/reagent_containers/food/drinks/cans/hispania/behemoth_energy_lite
	name = "Behemoth Energy Zero"
	desc = "Tear into a can of the meanest energy drink on the planet, Behemoth Energy. Yup, Quake was a good  game."
	icon_state = "behemoth_lite"
	item_state = "behemoth_lite"
	list_reagents = list("ale" = 10, "sodawater" = 20)

/obj/item/reagent_containers/food/drinks/cans/hispania/behemoth_energy_lite/New()
	..()
	if(prob(10))
		reagents.add_reagent("methamphetamine", 3)

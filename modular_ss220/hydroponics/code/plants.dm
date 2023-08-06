// Buckwheat
/obj/item/seeds/wheat/oat
	mutatelist = list(/obj/item/seeds/wheat/buckwheat)

/obj/item/seeds/wheat/buckwheat
	name = "пачка семян гречки"
	desc = "Из этого может получиться гречка, а может и нет."
	icon = 'modular_ss220/hydroponics/icons/seeds.dmi'
	icon_state = "seed-buckwheat"
	growing_icon = 'modular_ss220/hydroponics/icons/growing.dmi'
	species = "buckwheat"
	icon_dead = "buckwheat-dead"
	plantname = "Стебли Гречки"
	product = /obj/item/reagent_containers/food/snacks/grown/buckwheat
	mutatelist = list()

/obj/item/reagent_containers/food/snacks/grown/buckwheat
	seed = /obj/item/seeds/wheat/buckwheat
	name = "гречка"
	desc = "Finally, гречка."
	gender = PLURAL
	icon = 'modular_ss220/hydroponics/icons/plants.dmi'
	icon_state = "buckwheat"
	filling_color = "#8E633C"
	bitesize_mod = 2
	tastes = list("гречка" = 1)
	can_distill = FALSE

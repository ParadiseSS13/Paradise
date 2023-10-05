/obj/item/reagent_containers/food/snacks/raw_sausage
	name = "raw sausage"
	desc = "sausig"
	icon_state = "raw_sausage"
	filling_color = "#DB0000"
	list_reagents = list("protein" = 4, "vitamin" = 1)
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/raw_sausage/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/sausage, rand(60 SECONDS, 75 SECONDS), TRUE)
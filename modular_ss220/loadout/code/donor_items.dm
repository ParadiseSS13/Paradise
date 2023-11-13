/obj/item/storage/firstaid/regular/donor
	desc = "Набор первой медицинской помощи за оформление страховки"
	icon_state = "firstaid"

/obj/item/storage/firstaid/regular/donor/populate_contents()
	new /obj/item/reagent_containers/food/pill/patch/styptic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/patch/silver_sulf(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)

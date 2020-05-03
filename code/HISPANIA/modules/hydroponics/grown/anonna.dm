//Semillas
/obj/item/seeds/anonna
	name = "pack of anonna"
	desc = "These seeds grow intoan anonna plant."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "annona-seeds"
	species = "annona"
	plantname = "Anonna Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/anonna
	maturation = 8
	potency = 50
	yield = 5
	potency = 40
	maturation = 4
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/anonna/anonna_reticulata)
	reagents_add = list("vitamin" = 0.08, "plantmatter" = 0.2)

/obj/item/seeds/anonna/anonna_reticulata
	name = "pack of anonna reticulata"
	desc = "These seeds grow into an anonna reticulata plant, the edgy sister of the anonna."
	icon_state = "annonareticulata-seeds"
	species = "annonar"
	plantname = "Anonna Reticulata Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/anonna/reticulata
	mutatelist = list()
	reagents_add = list("mutagen" = 0.05)
	rarity = 40

//Fruta
/obj/item/reagent_containers/food/snacks/grown/anonna
	seed = /obj/item/seeds/anonna
	name = "anonna"
	desc = "Annona species are taprooted, evergreen or semideciduous, tropical trees or shrubs."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "annona"
	tastes = list("sugary" = 1)

/obj/item/reagent_containers/food/snacks/grown/anonna/reticulata
	seed = /obj/item/seeds/anonna/anonna_reticulata
	name = "anonna reticulata"
	desc = "The edgy sister of the anonna."
	icon_state = "annonareticulata"
	tastes = list("sugary" = 1, "edgy" = 1)

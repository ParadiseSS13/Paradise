// From Hispania!
//Semillas
/obj/item/seeds/annona
	name = "pack of annona seeds"
	desc = "These seeds grow intoan annona plant."
	icon_state = "annona-seeds"
	species = "annona"
	plantname = "Annona Tree"
	product = /obj/item/food/grown/annona
	maturation = 8
	potency = 50
	yield = 5
	potency = 40
	maturation = 4
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/annona/annona_reticulata)
	reagents_add = list("vitamin" = 0.08, "plantmatter" = 0.2)

/obj/item/seeds/annona/annona_reticulata
	name = "pack of annona reticulata"
	desc = "These seeds grow into an annona reticulata plant, the edgy sister of the annona."
	icon_state = "annonareticulata-seeds"
	species = "annonar"
	plantname = "Annona Reticulata Tree"
	product = /obj/item/food/grown/annona/reticulata
	mutatelist = list()
	reagents_add = list("mutagen" = 0.05)
	rarity = 40

//Fruta
/obj/item/food/grown/annona
	seed = /obj/item/seeds/annona
	name = "annona"
	desc = "Annona species are taprooted, evergreen or semideciduous, tropical trees or shrubs."
	icon_state = "annona"
	tastes = list("sugary" = 1)

/obj/item/food/grown/annona/reticulata
	seed = /obj/item/seeds/annona/annona_reticulata
	name = "annona reticulata"
	desc = "The edgy sister of the annona."
	icon_state = "annonareticulata"
	tastes = list("sugary" = 1, "edgy" = 1)

//Semillas
/obj/item/seeds/prickly_pear
	name = "pack of prickly pear cactus"
	desc = "These seeds will grow into a prickly pear cactus, it's fruit can be eaten."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "pricklypearlcactus-seed"
	species = "prickly"
	plantname = "Prickly Cactus"
	product = /obj/item/reagent_containers/food/snacks/grown/prickly_pear
	lifespan = 60
	endurance = 25
	yield = 6
	potency = 35
	maturation = 4
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/prickly_pear/san_pedro)
	reagents_add = list("nutriment" = 0.06, "sugar" = 0.02, "cactusjuice" = 0.05)

/obj/item/seeds/prickly_pear/san_pedro
	name = "pack of san pedro cactus"
	desc = "These seeds will grow into a San Pedro cactus."
	icon_state = "sanpedrocactus-seed"
	species = "pedro"
	plantname = "San Pedro Cactus"
	product = /obj/item/reagent_containers/food/snacks/grown/prickly_pear/san_pedro
	mutatelist = list(/obj/item/seeds/prickly_pear/san_pedro/peyote)
	reagents_add = list("nutriment" = 0.06, "sugar" = 0.02, "lsd" = 0.02, "cactusjuice" = 0.05)

/obj/item/seeds/prickly_pear/san_pedro/peyote
	name = "pack of peyote"
	desc = "These seeds grow into a useless decorative peyote cactus."
	icon_state = "peyote-seed"
	species = "peyote"
	plantname = "Peyote Cactus"
	product = /obj/item/reagent_containers/food/snacks/grown/prickly_pear/san_pedro/peyote
	mutatelist = list()
	reagents_add = list("lsd" = 1)

//Fruta
/obj/item/reagent_containers/food/snacks/grown/prickly_pear
	seed = /obj/item/seeds/prickly_pear
	name = "prickly pear"
	desc = "The red fruit or pear of this cactus are also known as tuna."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "pricklypearlcactus"
	tastes = list("sweet" = 1, "bland" = 1)

/obj/item/reagent_containers/food/snacks/grown/prickly_pear/san_pedro
	seed = /obj/item/seeds/prickly_pear/san_pedro
	name = "san pedro cactus"
	desc = "I can see colors now"
	icon_state = "sanpedrocactus"
	force = 7
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 4
	throw_range = 5
	attack_verb = list("hit", "sliced")
	tastes = list("weird" = 1, "watery" = 1)

/obj/item/reagent_containers/food/snacks/grown/prickly_pear/san_pedro/peyote
	seed = /obj/item/seeds/prickly_pear/san_pedro/peyote
	name = "peyote"
	desc = "Now i can see the future, the past and all the true."
	icon_state = "peyote"
	tastes = list("fun" = 1)

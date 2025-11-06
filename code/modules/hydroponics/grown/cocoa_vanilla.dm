// Cocoa Pod
/obj/item/seeds/cocoapod
	name = "pack of cocoa pod seeds"
	desc = "These seeds grow into cacao trees. They look fattening." //SIC: cocoa is the seeds. The trees are spelled cacao.
	icon_state = "seed-cocoapod"
	species = "cocoapod"
	plantname = "Cocao Tree"
	product = /obj/item/food/grown/cocoapod
	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	growthstages = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "cocoapod-grow"
	icon_dead = "cocoapod-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/cocoapod/vanillapod, /obj/item/seeds/cocoapod/bungotree)
	reagents_add = list("cocoa" = 0.25, "plantmatter" = 0.1)

/obj/item/food/grown/cocoapod
	seed = /obj/item/seeds/cocoapod
	name = "cocoa pod"
	desc = "Fattening... Mmmmm... chucklate."
	icon_state = "cocoapod"
	filling_color = "#5F3A13"
	bitesize_mod = 2
	tastes = list("cocoa" = 1)

// Vanilla Pod
/obj/item/seeds/cocoapod/vanillapod
	name = "pack of vanilla pod seeds"
	desc = "These seeds grow into vanilla trees. They look fattening."
	icon_state = "seed-vanillapod"
	species = "vanillapod"
	plantname = "Vanilla Tree"
	product = /obj/item/food/grown/vanillapod
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list()
	reagents_add = list("vanilla" = 0.25, "plantmatter" = 0.1)

/obj/item/food/grown/vanillapod
	seed = /obj/item/seeds/cocoapod/vanillapod
	name = "vanilla pod"
	desc = "Fattening... Mmmmm... vanilla."
	icon_state = "vanillapod"
	filling_color = "#FEFEFE"
	tastes = list("vanilla" = 1)
	distill_reagent = "vanilla" //Takes longer, but you can get even more vanilla from it.

// Bungo Pod

/obj/item/seeds/cocoapod/bungotree
	name = "pack of bungo tree seeds"
	desc = "These seeds grow into bungo trees. They appear to be heavy and almost perfectly spherical."
	icon_state = "seed-bungotree"
	species = "bungotree"
	plantname = "Bungo Tree"
	product = /obj/item/food/grown/bungofruit
	lifespan = 30
	maturation = 4
	yield = 3
	production = 7
	mutatelist = null
	reagents_add = list("enzyme"= 0.1, "nutriment" = 0.1, "bungojuice" = 0.1)
	growthstages = 4
	icon_grow = "bungotree-grow"
	icon_dead = "bungotree-dead"

/obj/item/food/grown/bungofruit
	seed = /obj/item/seeds/cocoapod/bungotree
	name = "bungo fruit"
	desc = "A strange fruit, tough leathery skin protects its juicy flesh and large poisonous seed."
	icon_state = "bungo"
	trash = /obj/item/food/grown/bungopit
	tastes = list("bungo" = 2, "tropical fruitiness" = 1, "an acidic, poisonous tang" = 1)
	distill_reagent = null

/obj/item/food/grown/bungopit
	seed = /obj/item/seeds/cocoapod/bungotree
	name = "bungo pit"
	icon_state = "bungopit"
	desc = "A large seed from a bungo fruit."
	tastes = list("acrid bitterness" = 1)

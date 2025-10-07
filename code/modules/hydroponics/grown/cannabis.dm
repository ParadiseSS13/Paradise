// Cannabis
/obj/item/seeds/cannabis
	name = "pack of cannabis seeds"
	desc = "Taxable."
	icon_state = "seed-cannabis"
	species = "cannabis"
	plantname = "Cannabis Plant"
	product = /obj/item/food/grown/cannabis
	maturation = 8
	potency = 20
	growthstages = 1
	growing_icon = 'icons/goonstation/objects/hydroponics.dmi'
	icon_grow = "cannabis-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "cannabis-dead" // Same for the dead icon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/cannabis/rainbow,
						/obj/item/seeds/cannabis/white)
	reagents_add = list("thc" = 0.15, "cbd" = 0.15)


/obj/item/seeds/cannabis/rainbow
	name = "pack of rainbow weed seeds"
	desc = "These seeds grow into rainbow weed. Groovy."
	icon_state = "seed-megacannabis"
	species = "megacannabis"
	plantname = "Rainbow Weed"
	product = /obj/item/food/grown/cannabis/rainbow
	mutatelist = list(/obj/item/seeds/cannabis/death,
						/obj/item/seeds/cannabis/ultimate)
	reagents_add = list("lsd" = 0.15, "thc" = 0.15, "cbd" = 0.15, "happiness" = 0.15)
	rarity = 40

/obj/item/seeds/cannabis/death
	name = "pack of deathweed seeds"
	desc = "These seeds grow into deathweed. Not groovy."
	icon_state = "seed-blackcannabis"
	species = "blackcannabis"
	plantname = "Deathweed"
	product = /obj/item/food/grown/cannabis/death
	mutatelist = list()
	reagents_add = list("cyanide" = 0.35, "thc" = 0.15, "cbd" = 0.15)
	rarity = 40

/obj/item/seeds/cannabis/white
	name = "pack of lifeweed seeds"
	desc = "I will give unto him that is munchies of the fountain of the cravings of life, freely."
	icon_state = "seed-whitecannabis"
	species = "whitecannabis"
	plantname = "Lifeweed"
	product = /obj/item/food/grown/cannabis/white
	mutatelist = list(/obj/item/seeds/cannabis/death,
						/obj/item/seeds/cannabis/ultimate)
	reagents_add = list("omnizine" = 0.35, "thc" = 0.15, "cbd" = 0.15)
	rarity = 40


/obj/item/seeds/cannabis/ultimate
	name = "pack of omega weed seeds"
	desc = "These seeds grow into omega weed."
	icon_state = "seed-ocannabis"
	species = "ocannabis"
	plantname = "Omega Weed"
	product = /obj/item/food/grown/cannabis/ultimate
	mutatelist = list()
	reagents_add = list("lsd" = 0.05,
						"suicider" = 0.05,
						"space_drugs" = 0.05,
						"mercury" = 0.05,
						"lithium" = 0.05,
						"ephedrine" = 0.05,
						"haloperidol" = 0.05,
						"methamphetamine" = 0.05,
						"thc" = 0.05,
						"cbd" = 0.05,
						"psilocybin" = 0.05,
						"hairgrownium" = 0.05,
						"ectoplasm" = 0.05,
						"bath_salts" = 0.05,
						"itching_powder" = 0.05,
						"crank" = 0.05,
						"krokodil" = 0.05,
						"histamine" = 0.05)
	rarity = 69


// ---------------------------------------------------------------

/obj/item/food/grown/cannabis
	seed = /obj/item/seeds/cannabis
	icon = 'icons/goonstation/objects/hydroponics.dmi'
	name = "cannabis leaf"
	desc = "A common marijuana leaf. Its legal status varies heavily across the polities of the Orion Sector."
	icon_state = "cannabis"
	filling_color = "#00FF00"
	bitesize_mod = 2
	tastes = list("cannabis" = 1)
	wine_power = 0.2


/obj/item/food/grown/cannabis/rainbow
	seed = /obj/item/seeds/cannabis/rainbow
	name = "rainbow cannabis leaf"
	desc = "Is it supposed to be glowing like that...?"
	icon_state = "megacannabis"
	wine_power = 0.6

/obj/item/food/grown/cannabis/death
	seed = /obj/item/seeds/cannabis/death
	name = "death cannabis leaf"
	desc = "Looks a bit dark. Oh well."
	icon_state = "blackcannabis"
	wine_power = 0.4

/obj/item/food/grown/cannabis/white
	seed = /obj/item/seeds/cannabis/white
	name = "white cannabis leaf"
	desc = "It feels smooth and nice to the touch."
	icon_state = "whitecannabis"
	wine_power = 0.1

/obj/item/food/grown/cannabis/ultimate
	seed = /obj/item/seeds/cannabis/ultimate
	name = "omega cannibas leaf"
	desc = "You feel dizzy looking at it. What the fuck?"
	icon_state = "ocannabis"
	wine_power = 0.9

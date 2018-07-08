//Random seeds; stats, traits, and plant type are randomized for each seed.

/obj/item/seeds/random
	name = "pack of strange seeds"
	desc = "Mysterious seeds as strange as their name implies. Spooky"
	icon_state = "seed-x"
	species = "?????"
	plantname = "strange plant"
	product = /obj/item/reagent_containers/food/snacks/grown/random
	icon_grow = "xpod-grow"
	icon_dead = "xpod-dead"
	icon_harvest = "xpod-harvest"
	growthstages = 4

/obj/item/seeds/random/New()
	randomize_stats()
	..()
	if(prob(60))
		add_random_reagents()
	if(prob(50))
		add_random_traits()
	add_random_plant_type(35)

/obj/item/reagent_containers/food/snacks/grown/random
	seed = /obj/item/seeds/random
	name = "strange plant"
	desc = "What could this even be?"
	icon_state = "crunchy"
	bitesize_mod = 2
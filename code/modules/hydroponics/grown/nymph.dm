/obj/item/seeds/nymph
	name = "pack of diona nymph seeds"
	desc = "These seeds grow into diona nymphs."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Nymph Pod"
	product = /obj/item/weapon/grown/holder_spawner/nymph
	lifespan = 50
	endurance = 8
	maturation = 10
	production = 1
	yield = 1

/obj/item/weapon/grown/holder_spawner/nymph
	seed = /obj/item/seeds/nymph
	spawned_thing = /mob/living/simple_animal/diona
// Grass
/obj/item/seeds/grass
	name = "pack of grass seeds"
	desc = "These seeds grow into grass. Yummy!"
	icon_state = "seed-grass"
	species = "grass"
	plantname = "Grass"
	product = /obj/item/reagent_containers/food/snacks/grown/grass
	lifespan = 40
	endurance = 40
	maturation = 2
	production = 5
	yield = 5
	growthstages = 2
	icon_grow = "grass-grow"
	icon_dead = "grass-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/grass/carpet)
	reagents_add = list("plantmatter" = 0.02, "hydrogen" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/grass
	seed = /obj/item/seeds/grass
	name = "grass"
	desc = "Green and lush."
	icon_state = "grassclump"
	filling_color = "#32CD32"
	bitesize_mod = 2
	var/stacktype = /obj/item/stack/tile/grass
	var/tile_coefficient = 0.02 // 1/50
	wine_power = 0.15

/obj/item/reagent_containers/food/snacks/grown/grass/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You prepare the astroturf.</span>")
	var/grassAmt = 1 + round(seed.potency * tile_coefficient) // The grass we're holding
	for(var/obj/item/reagent_containers/food/snacks/grown/grass/G in user.loc) // The grass on the floor
		if(G.type != type)
			continue
		grassAmt += 1 + round(G.seed.potency * tile_coefficient)
		qdel(G)
	var/obj/item/stack/tile/GT = new stacktype(user.loc)
	while(grassAmt > GT.max_amount)
		GT.amount = GT.max_amount
		grassAmt -= GT.max_amount
		GT = new stacktype(user.loc)
	GT.amount = grassAmt
	for(var/obj/item/stack/tile/T in user.loc)
		if((T.type == stacktype) && (T.amount < T.max_amount) && (T != GT))
			T.attackby(GT, user)
	qdel(src)
	return

// Carpet
/obj/item/seeds/grass/carpet
	name = "pack of carpet seeds"
	desc = "These seeds grow into stylish carpet samples."
	icon_state = "seed-carpet"
	species = "carpet"
	plantname = "Carpet"
	product = /obj/item/reagent_containers/food/snacks/grown/grass/carpet
	mutatelist = list()
	rarity = 10

/obj/item/reagent_containers/food/snacks/grown/grass/carpet
	seed = /obj/item/seeds/grass/carpet
	name = "carpet"
	desc = "The textile industry's dark secret."
	icon_state = "carpetclump"
	stacktype = /obj/item/stack/tile/carpet
	can_distill = FALSE

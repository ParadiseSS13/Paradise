/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom
	name = "mushroom"
	bitesize_mod = 2


// Reishi
/obj/item/seeds/reishi
	name = "pack of reishi mycelium"
	desc = "This mycelium grows into something medicinal and relaxing."
	icon_state = "mycelium-reishi"
	species = "reishi"
	plantname = "Reishi"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
	lifespan = 35
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 15
	growthstages = 4
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list("morphine" = 0.35, "charcoal" = 0.35, "nutriment" = 0)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
	seed = /obj/item/seeds/reishi
	name = "reishi"
	desc = "<I>Ganoderma lucidum</I>: A special fungus known for its medicinal and stress relieving properties."
	icon_state = "reishi"
	filling_color = "#FF4500"


// Fly Amanita
/obj/item/seeds/amanita
	name = "pack of fly amanita mycelium"
	desc = "This mycelium grows into something horrible."
	icon_state = "mycelium-amanita"
	species = "amanita"
	plantname = "Fly Amanitas"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	lifespan = 50
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	mutatelist = list(/obj/item/seeds/angel)
	reagents_add = list("psilocybin" = 0.04, "amanitin" = 0.35, "nutriment" = 0)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	seed = /obj/item/seeds/amanita
	name = "fly amanita"
	desc = "<I>Amanita Muscaria</I>: Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	icon_state = "amanita"
	filling_color = "#FF0000"


// Destroying Angel
/obj/item/seeds/angel
	name = "pack of destroying angel mycelium"
	desc = "This mycelium grows into something devastating."
	icon_state = "mycelium-angel"
	species = "angel"
	plantname = "Destroying Angels"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	lifespan = 50
	endurance = 35
	maturation = 12
	production = 5
	yield = 2
	potency = 35
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list("psilocybin" = 0.04, "nutriment" = 0, "amanitin" = 0.3)
	rarity = 30
	origin_tech = "biotech=5"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	seed = /obj/item/seeds/angel
	name = "destroying angel"
	desc = "<I>Amanita Virosa</I>: Deadly poisonous basidiomycete fungus filled with alpha amatoxins."
	icon_state = "angel"
	filling_color = "#C0C0C0"


// Liberty Cap
/obj/item/seeds/liberty
	name = "pack of liberty-cap mycelium"
	desc = "This mycelium grows into liberty-cap mushrooms."
	icon_state = "mycelium-liberty"
	species = "liberty"
	plantname = "Liberty-Caps"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	maturation = 7
	production = 1
	yield = 5
	potency = 15
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list("psilocybin" = 0.25, "nutriment" = 0.02)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	seed = /obj/item/seeds/liberty
	name = "liberty-cap"
	desc = "<I>Psilocybe Semilanceata</I>: Liberate yourself!"
	icon_state = "libertycap"
	filling_color = "#DAA520"


// Plump Helmet
/obj/item/seeds/plump
	name = "pack of plump-helmet mycelium"
	desc = "This mycelium grows into helmets... maybe."
	icon_state = "mycelium-plump"
	species = "plump"
	plantname = "Plump-Helmet Mushrooms"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	maturation = 8
	production = 1
	yield = 4
	potency = 15
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	mutatelist = list(/obj/item/seeds/plump/walkingmushroom)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	seed = /obj/item/seeds/plump
	name = "plump-helmet"
	desc = "<I>Plumus Hellmus</I>: Plump, soft and s-so inviting~"
	icon_state = "plumphelmet"
	filling_color = "#9370DB"


// Walking Mushroom
/obj/item/seeds/plump/walkingmushroom
	name = "pack of walking mushroom mycelium"
	desc = "This mycelium will grow into huge stuff!"
	icon_state = "mycelium-walkingmushroom"
	species = "walkingmushroom"
	plantname = "Walking Mushrooms"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	lifespan = 30
	endurance = 30
	maturation = 5
	yield = 1
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	mutatelist = list()
	reagents_add = list("vitamin" = 0.05, "nutriment" = 0.15)
	rarity = 30

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	seed = /obj/item/seeds/plump/walkingmushroom
	name = "walking mushroom"
	desc = "<I>Plumus Locomotus</I>: The beginning of the great walk."
	icon_state = "walkingmushroom"
	filling_color = "#9370DB"
	origin_tech = "biotech=4;programming=5"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/attack_self(mob/user)
	if(istype(user.loc, /turf/space))
		return
	var/mob/living/simple_animal/hostile/mushroom/M = new /mob/living/simple_animal/hostile/mushroom(user.loc)
	M.maxHealth += round(seed.endurance / 4)
	M.melee_damage_lower += round(seed.potency / 20)
	M.melee_damage_upper += round(seed.potency / 20)
	M.move_to_delay -= round(seed.production / 50)
	M.health = M.maxHealth
	qdel(src)
	to_chat(user, "<span class='notice'>You plant the walking mushroom.</span>")


// Chanterelle
/obj/item/seeds/chanter
	name = "pack of chanterelle mycelium"
	desc = "This mycelium grows into chanterelle mushrooms."
	icon_state = "mycelium-chanter"
	species = "chanter"
	plantname = "Chanterelle Mushrooms"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	lifespan = 35
	endurance = 20
	maturation = 7
	production = 1
	yield = 5
	potency = 15
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list("nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	seed = /obj/item/seeds/chanter
	name = "chanterelle cluster"
	desc = "<I>Cantharellus Cibarius</I>: These jolly yellow little shrooms sure look tasty!"
	icon_state = "chanterelle"
	filling_color = "#FFA500"


// Glowshroom
/obj/item/seeds/glowshroom
	name = "pack of glowshroom mycelium"
	desc = "This mycelium -glows- into mushrooms!"
	icon_state = "mycelium-glowshroom"
	species = "glowshroom"
	plantname = "Glowshrooms"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	lifespan = 100 //ten times that is the delay
	endurance = 30
	maturation = 15
	production = 1
	yield = 3 //-> spread
	potency = 30 //-> brightness
	growthstages = 4
	rarity = 20
	genes = list(/datum/plant_gene/trait/glow, /datum/plant_gene/trait/plant_type/fungal_metabolism)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	mutatelist = list(/obj/item/seeds/glowshroom/glowcap)
	reagents_add = list("radium" = 0.1, "phosphorus" = 0.1, "nutriment" = 0.04)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	seed = /obj/item/seeds/glowshroom
	name = "glowshroom cluster"
	desc = "<I>Mycena Bregprox</I>: This species of mushroom glows in the dark."
	icon_state = "glowshroom"
	filling_color = "#00FA9A"
	var/effect_path = /obj/effect/glowshroom
	origin_tech = "biotech=4;plasmatech=6"
	light_color = "#006622"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user)
	if(istype(user.loc, /turf/space))
		return
	var/obj/effect/glowshroom/planted = new effect_path(user.loc)
	planted.delay = planted.delay - seed.production * 100 //So the delay goes DOWN with better stats instead of up. :I
	planted.endurance = seed.endurance
	planted.yield = seed.yield
	planted.potency = seed.potency
	to_chat(user, "<span class='notice'>You plant [src].</span>")
	qdel(src)


// Glowcap
/obj/item/seeds/glowshroom/glowcap
	name = "pack of glowcap mycelium"
	desc = "This mycelium -powers- into mushrooms!"
	icon_state = "mycelium-glowcap"
	species = "glowcap"
	icon_grow = "glowshroom-grow"
	icon_dead = "glowshroom-dead"
	plantname = "Glowcaps"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/glowcap
	genes = list(/datum/plant_gene/trait/glow, /datum/plant_gene/trait/cell_charge, /datum/plant_gene/trait/plant_type/fungal_metabolism)
	mutatelist = list()
	reagents_add = list("teslium" = 0.1, "nutriment" = 0.04)
	rarity = 30

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/glowcap
	seed = /obj/item/seeds/glowshroom/glowcap
	name = "glowcap cluster"
	desc = "<I>Mycena Ruthenia</I>: This species of mushroom glows in the dark, but aren't bioluminescent. They're warm to the touch..."
	icon_state = "glowcap"
	filling_color = "#00FA9A"
	effect_path = /obj/effect/glowshroom/glowcap
	origin_tech = "biotech=4;powerstorage=6;plasmatech=4"
	light_color = "#8E0300"

// Fungus/Mold
/obj/item/seeds/fungus
	name = "pack of fungus spores"
	desc = "These spores grow into fungus."
	icon_state = "mycelium-tower"
	species = "mold"
	plantname = "Fungus"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/fungus
	yield = 4
	icon_grow = "mold-grow"
	icon_dead = "mold-dead"
	icon_harvest = "mold-harvest"
	growthstages = 3
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	reagents_add = list("fungus" = 0.35)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/fungus
	seed = /obj/item/seeds/fungus
	name = "fungus"
	desc = "A fungus ideal for making antibacterials."
	icon_state = "angel"
	color = "#4f4331"


/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	result = null
	required_reagents = list("soymilk" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/tofu(location)

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("soymilk" = 2, "cocoa" = 2, "sugar" = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)

/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("milk" = 2, "cocoa" = 2, "sugar" = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	result = "soysauce"
	required_reagents = list("soymilk" = 1,"sodiumchloride" = 1, "water" = 8)
	result_amount = 10

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	result = null
	required_reagents = list("milk" = 40)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1

/datum/chemical_reaction/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel(location)

/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	id = "syntiflesh"
	result = null
	required_reagents = list("blood" = 5, "cryoxadone" = 1)
	result_amount = 1

/datum/chemical_reaction/syntiflesh/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/meat/syntiflesh(location)

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	result = "hot_ramen"
	required_reagents = list("water" = 1, "dry_ramen" = 3)
	result_amount = 3

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	result = "hell_ramen"
	required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
	result_amount = 6

/datum/chemical_reaction/doughball
	name = "Ball of dough"
	id = "dough_ball"
	result = "dough_ball"
	required_reagents = list("flour" = 15, "water" = 5)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/dough
	name = "Dough"
	id = "dough"
	result = null
	required_reagents = list("water" = 10, "flour" = 15)
	result_amount = 1
	mix_message = "The ingredients form a dough."

/datum/chemical_reaction/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/food/snacks/dough(location)

///Cookies by Ume

/datum/chemical_reaction/cookiedough
	name = "Dough"
	id = "dough"
	result = null
	required_reagents = list("milk" = 10, "flour" = 10, "sugar" = 5)
	result_amount = 1
	mix_message = "The ingredients form a dough. It smells sweet and yummy."

/datum/chemical_reaction/cookiedough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/food/snacks/cookiedough(location)


/datum/chemical_reaction/corn_syrup
	name = "corn_syrup"
	id = "corn_syrup"
	result = "corn_syrup"
	required_reagents = list("corn_starch" = 1, "sacid" = 1)
	result_amount = 2
	min_temp = 374
	mix_message = "The mixture forms a viscous, clear fluid!"

/datum/chemical_reaction/vhfcs
	name = "vhfcs"
	id = "vhfcs"
	result = "vhfcs"
	required_reagents = list("corn_syrup" = 1)
	required_catalysts = list("enzyme" = 1)
	result_amount = 1
	mix_message = "The mixture emits a sickly-sweet smell."

/datum/chemical_reaction/cola
	name = "cola"
	id = "cola"
	result = "cola"
	required_reagents = list("carbon" = 1, "oxygen" = 1, "water" = 1, "sugar" = 1)
	result_amount = 4
	mix_message = "The mixture begins to fizz."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cheese
	name = "cheese"
	id = "cheese"
	result = "cheese"
	required_reagents = list("vomit" = 1, "milk" = 1)
	result_amount = 1
	mix_message = "The mixture curdles up."

/datum/chemical_reaction/cheese/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='notice'>A faint cheesy smell drifts through the air...</span>")

/datum/chemical_reaction/weird_cheese
	name = "Weird cheese"
	id = "weird_cheese"
	result = "weird_cheese"
	required_reagents = list("green_vomit" = 1, "milk" = 1)
	result_amount = 1
	mix_message = "The disgusting mixture sloughs together horribly, emitting a foul stench."
	mix_sound = 'sound/goonstation/misc/gurggle.ogg'

/datum/chemical_reaction/weird_cheese/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>A horrible smell assaults your nose! What in space is it?</span>")

/datum/chemical_reaction/hydrogenated_soybeanoil
	name = "Partially hydrogenated space-soybean oil"
	id = "hydrogenated_soybeanoil"
	result = "hydrogenated_soybeanoil"
	required_reagents = list("soybeanoil" = 1, "hydrogen" = 1)
	result_amount = 2
	min_temp = 520
	mix_message = "The mixture emits a burnt, oily smell."

/datum/chemical_reaction/meatslurry
	name = "Meat Slurry"
	id = "meatslurry"
	result = "meatslurry"
	required_reagents = list("corn_starch" = 1, "blood" = 1)
	result_amount = 2
	mix_message = "The mixture congeals into a bloody mass."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/gravy
	name = "Gravy"
	id = "gravy"
	result = "gravy"
	required_reagents = list("porktonium" = 1, "corn_starch" = 1, "milk" = 1)
	result_amount = 3
	min_temp = 374
	mix_message = "The substance thickens and takes on a meaty odor."

/datum/chemical_reaction/beff
	name = "Beff"
	id = "beff"
	result = "beff"
	required_reagents = list("hydrogenated_soybeanoil" = 2, "meatslurry" = 1, "plasma" = 1)
	result_amount = 4
	mix_message = "The mixture solidifies, taking a crystalline appearance."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/pepperoni
	name = "Pepperoni"
	id = "pepperoni"
	result = "pepperoni"
	required_reagents = list("beff" = 1, "saltpetre" = 1, "synthflesh" = 1)
	result_amount = 2
	mix_message = "The beff and the synthflesh combine to form a smoky red log."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/enzyme
	name = "Universal enzyme"
	id = "enzyme"
	result = "enzyme"
	required_reagents = list("vomit" = 1, "sugar" = 1)
	result_amount = 2
	min_temp = 750
	mix_message = "The mixture emits a horrible smell as you heat up the contents. Luckily, enzymes don't stink."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/enzyme
	name = "Universal enzyme"
	id = "enzyme"
	result = "enzyme"
	required_reagents = list("green_vomit" = 1, "sugar" = 1)
	result_amount = 2
	min_temp = 750
	mix_message = "The mixture emits a horrible smell as you heat up the contents. Luckily, enzymes don't stink."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

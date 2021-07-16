// foam and foam precursor

/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	result = /datum/reagent/fluorosurfactant
	required_reagents = list(/datum/reagent/fluorine = 2, /datum/reagent/carbon = 2, /datum/reagent/acid = 1)
	result_amount = 5
	mix_message = "A head of foam results from the mixture's constant fizzing."

/datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	result = null
	required_reagents = list(/datum/reagent/fluorosurfactant = 1, /datum/reagent/water = 1)
	result_amount = 2

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	holder.my_atom.visible_message("<span class='warning'>The solution spews out foam!</span>")

	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 0)
	s.start()
	holder.clear_reagents()


/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	id = "metalfoam"
	result = null
	required_reagents = list(/datum/reagent/aluminum = 3, /datum/reagent/fluorosurfactant = 1, /datum/reagent/acid = 1)
	result_amount = 5

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	holder.my_atom.visible_message("<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, MFOAM_ALUMINUM)
	s.start()


/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	result = null
	required_reagents = list(/datum/reagent/iron = 3, /datum/reagent/fluorosurfactant = 1, /datum/reagent/acid = 1)
	result_amount = 5

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	holder.my_atom.visible_message("<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, MFOAM_IRON)
	s.start()


	// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
/datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = "ammonia"
	result = /datum/reagent/ammonia
	required_reagents = list(/datum/reagent/hydrogen = 3, /datum/reagent/nitrogen = 1)
	result_amount = 3
	mix_message = "The mixture bubbles, emitting an acrid reek."

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	result = /datum/reagent/diethylamine
	required_reagents = list (/datum/reagent/ammonia = 1, /datum/reagent/consumable/ethanol = 1)
	result_amount = 2
	min_temp = T0C + 100
	mix_message = "A horrible smell pours forth from the mixture."

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	result = /datum/reagent/space_cleaner
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/water = 1, /datum/reagent/consumable/ethanol = 1)
	result_amount = 3
	mix_message = "Ick, this stuff really stinks. Sure does make the container sparkle though!"

/datum/chemical_reaction/sulfuric_acid
	name = "Sulfuric Acid"
	id = "sacid"
	result = /datum/reagent/acid
	required_reagents = list(/datum/reagent/sulfur = 1, /datum/reagent/oxygen = 1, /datum/reagent/hydrogen = 1)
	result_amount = 2
	mix_message = "The mixture gives off a sharp acidic tang."

/datum/chemical_reaction/plastic_polymers
	name = "plastic polymers"
	id = "plastic_polymers"
	result = null
	required_reagents = list(/datum/reagent/oil = 5, /datum/reagent/acid = 2, /datum/reagent/ash = 3)
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/plastic_polymers/on_reaction(datum/reagents/holder, created_volume)
	var/obj/item/stack/sheet/plastic/P = new /obj/item/stack/sheet/plastic
	P.amount = 10
	P.forceMove(get_turf(holder.my_atom))

/datum/chemical_reaction/lube
	name = "Space Lube"
	id = "lube"
	result = /datum/reagent/lube
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/silicon = 1, /datum/reagent/oxygen = 1)
	result_amount = 3
	mix_message = "The substance turns a striking cyan and becomes oily."

/datum/chemical_reaction/holy_water
	name = "Holy Water"
	id = "holywater"
	result = /datum/reagent/holywater
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/mercury = 1, /datum/reagent/consumable/ethanol/wine = 1)
	result_amount = 3
	mix_message = "The water somehow seems purified. Or maybe defiled."

/datum/chemical_reaction/drying_agent
	name = "Drying agent"
	id = "drying_agent"
	result = /datum/reagent/drying_agent
	required_reagents = list(/datum/reagent/plasma = 2, /datum/reagent/consumable/ethanol = 1, /datum/reagent/sodium = 1)
	result_amount = 3

/datum/chemical_reaction/saltpetre
	name = "saltpetre"
	id = "saltpetre"
	result = /datum/reagent/saltpetre
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 3)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/acetone
	name = "acetone"
	id = "acetone"
	result = /datum/reagent/acetone
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/fuel = 1, /datum/reagent/oxygen = 1)
	result_amount = 3
	mix_message = "The smell of paint thinner assaults you as the solution bubbles."

/datum/chemical_reaction/carpet
	name = "carpet"
	id = "carpet"
	result = /datum/reagent/carpet
	required_reagents = list(/datum/reagent/fungus = 1, /datum/reagent/blood = 1)
	result_amount = 2
	mix_message = "The substance turns thick and stiff, yet soft."


/datum/chemical_reaction/oil
	name = "Oil"
	id = "oil"
	result = /datum/reagent/oil
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/carbon = 1, /datum/reagent/hydrogen = 1)
	result_amount = 3
	mix_message = "An iridescent black chemical forms in the container."

/datum/chemical_reaction/phenol
	name = "phenol"
	id = "phenol"
	result = /datum/reagent/phenol
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/chlorine = 1, /datum/reagent/oil = 1)
	result_amount = 3
	mix_message = "The mixture bubbles and gives off an unpleasant medicinal odor."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/colorful_reagent
	name = "colorful_reagent"
	id = "colorful_reagent"
	result = /datum/reagent/colorful_reagent
	required_reagents = list(/datum/reagent/plasma = 1, /datum/reagent/radium = 1, /datum/reagent/space_drugs = 1, /datum/reagent/medicine/cryoxadone = 1, /datum/reagent/consumable/drink/triple_citrus = 1, /datum/reagent/stabilizing_agent = 1)
	result_amount = 6
	mix_message = "The substance flashes multiple colors and emits the smell of a pocket protector."

/datum/chemical_reaction/corgium
	name = "corgium"
	id = "corgium"
	result = null
	required_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/colorful_reagent = 1, /datum/reagent/medicine/strange_reagent = 1, /datum/reagent/blood = 1)
	result_amount = 3
	min_temp = T0C + 100

/datum/chemical_reaction/corgium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/pet/dog/corgi(location)
	..()

/datum/chemical_reaction/flaptonium
	name = "Flaptonium"
	id = "flaptonium"
	result = null
	required_reagents = list(/datum/reagent/consumable/egg = 1, /datum/reagent/colorful_reagent = 1, /datum/reagent/consumable/chicken_soup = 1, /datum/reagent/medicine/strange_reagent = 1, /datum/reagent/blood = 1)
	result_amount = 5
	min_temp = T0C + 100
	mix_message = "The substance turns an airy sky-blue and foams up into a new shape."

/datum/chemical_reaction/flaptonium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/parrot(location)
	..()

/datum/chemical_reaction/hair_dye
	name = "hair_dye"
	id = "hair_dye"
	result = /datum/reagent/hair_dye
	required_reagents = list(/datum/reagent/colorful_reagent = 1, /datum/reagent/hairgrownium = 1)
	result_amount = 2

/datum/chemical_reaction/hairgrownium
	name = "hairgrownium"
	id = "hairgrownium"
	result = /datum/reagent/hairgrownium
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/medicine/synthflesh = 1, /datum/reagent/medicine/ephedrine = 1)
	result_amount = 3
	mix_message = "The liquid becomes slightly hairy."

/datum/chemical_reaction/super_hairgrownium
	name = "Super Hairgrownium"
	id = "super_hairgrownium"
	result = /datum/reagent/super_hairgrownium
	required_reagents = list(/datum/reagent/iron = 1, /datum/reagent/methamphetamine = 1, /datum/reagent/hairgrownium = 1)
	result_amount = 3
	mix_message = "The liquid becomes amazingly furry and smells peculiar."

/datum/chemical_reaction/soapification
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list(/datum/reagent/liquidgibs = 10, /datum/reagent/lye  = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1


/datum/chemical_reaction/soapification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade(location)

/datum/chemical_reaction/candlefication
	name = "Candlefication"
	id = "candlefication"
	result = null
	required_reagents = list(/datum/reagent/liquidgibs = 5, /datum/reagent/oxygen = 5) //
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/candlefication/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/candle(location)

/datum/chemical_reaction/meatification
	name = "Meatification"
	id = "meatification"
	result = null
	required_reagents = list(/datum/reagent/liquidgibs = 10, /datum/reagent/consumable/nutriment = 10, /datum/reagent/carbon = 10)
	result_amount = 1

/datum/chemical_reaction/meatification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/meat/slab/meatproduct(location)

/datum/chemical_reaction/lye
	name = "lye"
	id = "lye"
	result = /datum/reagent/lye
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1)
	result_amount = 3

/datum/chemical_reaction/love
	name = "pure love"
	id = "love"
	result = /datum/reagent/love
	required_reagents = list(/datum/reagent/hugs = 1, /datum/reagent/consumable/chocolate = 1)
	result_amount = 2
	mix_message = "The substance gives off a lovely scent!"

/datum/chemical_reaction/jestosterone
	name = "Jestosterone"
	id = "jestosterone"
	result = /datum/reagent/jestosterone
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/drink/banana = 1, /datum/reagent/lube = 1, /datum/reagent/space_drugs = 1) //Or one freshly-squeezed clown
	min_temp = T0C + 100
	result_amount = 5
	mix_message = "The substance quickly shifts colour, cycling from red, to yellow, to green, to blue, and finally settles at a vibrant fuchsia."

/datum/chemical_reaction/jestosterone/on_reaction(datum/reagents/holder, created_volume)
	playsound(get_turf(holder.my_atom), 'sound/items/bikehorn.ogg', 50, 1)

/datum/chemical_reaction/royal_bee_jelly
	name = "royal bee jelly"
	id = "royal_bee_jelly"
	result = /datum/reagent/royal_bee_jelly
	required_reagents = list(/datum/reagent/mutagen = 10, /datum/reagent/consumable/honey = 40)
	result_amount = 5

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = "glycerol"
	result = /datum/reagent/glycerol
	required_reagents = list(/datum/reagent/consumable/cornoil = 3, /datum/reagent/acid = 1)
	result_amount = 1

/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	result = /datum/reagent/consumable/condensedcapsaicin
	required_reagents = list(/datum/reagent/consumable/capsaicin = 2)
	required_catalysts = list(/datum/reagent/plasma = 5)
	result_amount = 1

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = "sodiumchloride"
	result = /datum/reagent/consumable/sodiumchloride
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/chlorine = 1, /datum/reagent/water = 1)
	result_amount = 3
	mix_message = "The solution crystallizes with a brief flare of light."

/datum/chemical_reaction/acetaldehyde
	name = "Acetaldehyde"
	id = "acetaldehyde"
	result = /datum/reagent/acetaldehyde
	required_reagents = list(/datum/reagent/chromium = 1, /datum/reagent/oxygen = 1, /datum/reagent/copper = 1, /datum/reagent/consumable/ethanol = 1)
	result_amount = 3
	min_temp = T0C + 275
	mix_message = "It smells like a bad hangover in here."

/datum/chemical_reaction/acetic_acid
	name = "Acetic Acid"
	id = "acetic_acid"
	result = /datum/reagent/acetic_acid
	required_reagents = list(/datum/reagent/acetaldehyde = 1, /datum/reagent/oxygen = 1, /datum/reagent/nitrogen = 4)
	result_amount = 3
	mix_message = "It smells like vinegar and a bad hangover in here."

/datum/chemical_reaction/ice
	name = "Ice"
	id = "ice"
	result = /datum/reagent/consumable/drink/cold/ice
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 1
	max_temp = T0C
	mix_message = "Ice forms as the water freezes."
	mix_sound = null

/datum/chemical_reaction/water
	name = "Water"
	id = "water"
	result = /datum/reagent/water
	required_reagents = list(/datum/reagent/consumable/drink/cold/ice = 1)
	result_amount = 1
	min_temp = T0C + 29 // In Space.....ice melts at 82F...don't ask
	mix_message = "Water pools as the ice melts."
	mix_sound = null

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = /datum/reagent/consumable/virus_food
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/drink/milk = 1, /datum/reagent/oxygen = 1)
	result_amount = 3

/datum/chemical_reaction/virus_food_mutagen
	name = "mutagenic agar"
	id = "mutagenvirusfood"
	result = /datum/reagent/mutagen/mutagenvirusfood
	required_reagents = list(/datum/reagent/mutagen = 1, /datum/reagent/consumable/virus_food = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_diphenhydramine
	name = "virus rations"
	id = "diphenhydraminevirusfood"
	result = /datum/reagent/medicine/diphenhydramine/diphenhydraminevirusfood
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/consumable/virus_food = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_plasma
	name = "virus plasma"
	id = "plasmavirusfood"
	result = /datum/reagent/plasma_dust/plasmavirusfood
	required_reagents = list(/datum/reagent/plasma_dust = 1, /datum/reagent/consumable/virus_food = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_plasma_diphenhydramine
	name = "weakened virus plasma"
	id = "weakplasmavirusfood"
	result = /datum/reagent/plasma_dust/plasmavirusfood/weak
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/plasma_dust/plasmavirusfood = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutagen_sugar
	name = "sucrose agar"
	id = "sugarvirusfood"
	result = /datum/reagent/mutagen/mutagenvirusfood/sugar
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/mutagen/mutagenvirusfood = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutagen_salineglucose
	name = "sucrose agar"
	id = "salineglucosevirusfood"
	result = /datum/reagent/mutagen/mutagenvirusfood/sugar
	required_reagents = list(/datum/reagent/medicine/salglu_solution = 1, /datum/reagent/mutagen/mutagenvirusfood = 1)
	result_amount = 2

/datum/chemical_reaction/mix_virus
	name = "Mix Virus"
	id = "mixvirus"
	required_reagents = list(/datum/reagent/consumable/virus_food = 1)
	required_catalysts = list(/datum/reagent/blood = 1)
	var/level_min = 0
	var/level_max = 2

/datum/chemical_reaction/mix_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Evolve(level_min, level_max)


/datum/chemical_reaction/mix_virus/mix_virus_2
	name = "Mix Virus 2"
	id = "mixvirus2"
	required_reagents = list(/datum/reagent/mutagen = 1)
	level_min = 2
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_3
	name = "Mix Virus 3"
	id = "mixvirus3"
	required_reagents = list(/datum/reagent/plasma_dust = 1)
	level_min = 4
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_4
	name = "Mix Virus 4"
	id = "mixvirus4"
	required_reagents = list(/datum/reagent/uranium = 1)
	level_min = 5
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_5
	name = "Mix Virus 5"
	id = "mixvirus5"
	required_reagents = list(/datum/reagent/mutagen/mutagenvirusfood = 1)
	level_min = 3
	level_max = 3

/datum/chemical_reaction/mix_virus/mix_virus_6
	name = "Mix Virus 6"
	id = "mixvirus6"
	required_reagents = list(/datum/reagent/mutagen/mutagenvirusfood/sugar = 1)
	level_min = 4
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_7
	name = "Mix Virus 7"
	id = "mixvirus7"
	required_reagents = list(/datum/reagent/plasma_dust/plasmavirusfood/weak = 1)
	level_min = 5
	level_max = 5

/datum/chemical_reaction/mix_virus/mix_virus_8
	name = "Mix Virus 8"
	id = "mixvirus8"
	required_reagents = list(/datum/reagent/plasma_dust/plasmavirusfood = 1)
	level_min = 6
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_9
	name = "Mix Virus 9"
	id = "mixvirus9"
	required_reagents = list(/datum/reagent/medicine/diphenhydramine/diphenhydraminevirusfood = 1)
	level_min = 1
	level_max = 1

/datum/chemical_reaction/mix_virus/rem_virus
	name = "Devolve Virus"
	id = "remvirus"
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1)
	required_catalysts = list(/datum/reagent/blood = 1)

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()

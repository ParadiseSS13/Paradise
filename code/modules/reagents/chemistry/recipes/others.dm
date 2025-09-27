// foam and foam precursor

/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	result = "fluorosurfactant"
	required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)
	result_amount = 5
	mix_message = "A head of foam results from the mixture's constant fizzing."

/datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	result = null
	required_reagents = list("fluorosurfactant" = 1, "water" = 1)
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
	required_reagents = list("aluminum" = 3, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	holder.my_atom.visible_message("<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect_system/foam_spread/metal/s = new()
	s.set_up(created_volume, location, holder, METAL_FOAM_ALUMINUM)
	s.start()

/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	result = null
	required_reagents = list("iron" = 3, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	holder.my_atom.visible_message("<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect_system/foam_spread/metal/s = new()
	s.set_up(created_volume, location, holder, METAL_FOAM_IRON)
	s.start()

	// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
/datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = "ammonia"
	result = "ammonia"
	required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
	result_amount = 3
	mix_message = "The mixture bubbles, emitting an acrid reek."

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	result = "diethylamine"
	required_reagents = list ("ammonia" = 1, "ethanol" = 1)
	result_amount = 2
	min_temp = T0C + 100
	mix_message = "A horrible smell pours forth from the mixture."

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	result = "cleaner"
	required_reagents = list("ammonia" = 1, "water" = 1, "ethanol" = 1)
	result_amount = 3
	mix_message = "Ick, this stuff really stinks. Sure does make the container sparkle though!"

/datum/chemical_reaction/sulfuric_acid
	name = "Sulfuric Acid"
	id = "sacid"
	result = "sacid"
	required_reagents = list("sulfur" = 1, "oxygen" = 1, "hydrogen" = 1)
	result_amount = 2
	mix_message = "The mixture gives off a sharp acidic tang."

/datum/chemical_reaction/plastic_polymers
	name = "plastic polymers"
	id = "plastic_polymers"
	result = "molten_plastic"
	required_reagents = list("oil" = 5, "sacid" = 2, "ash" = 3)
	min_temp = T0C + 120
	result_amount = 10
	mix_message = "The mixture clumps up and becomes stringy."

/datum/chemical_reaction/lube
	name = "Space Lube"
	id = "lube"
	result = "lube"
	required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
	result_amount = 3
	mix_message = "The substance turns a striking cyan and becomes oily."

/datum/chemical_reaction/holy_water
	name = "Holy Water"
	id = "holywater"
	result = "holywater"
	required_reagents = list("water" = 1, "mercury" = 1, "wine" = 1)
	result_amount = 3
	mix_message = "The water somehow seems purified. Or maybe defiled."

/datum/chemical_reaction/drying_agent
	name = "Drying agent"
	id = "drying_agent"
	result = "drying_agent"
	required_reagents = list("plasma" = 2, "ethanol" = 1, "sodium" = 1)
	result_amount = 3

/datum/chemical_reaction/saltpetre
	name = "saltpetre"
	id = "saltpetre"
	result = "saltpetre"
	required_reagents = list("potassium" = 1, "nitrogen" = 1, "oxygen" = 3)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/acetone
	name = "acetone"
	id = "acetone"
	result = "acetone"
	required_reagents = list("oil" = 1, "fuel" = 1, "oxygen" = 1)
	result_amount = 3
	mix_message = "The smell of paint thinner assaults you as the solution bubbles."

/datum/chemical_reaction/carpet
	name = "carpet"
	id = "carpet"
	result = "carpet"
	required_reagents = list("fungus" = 1, "blood" = 1)
	result_amount = 2
	mix_message = "The substance turns thick and stiff, yet soft."


/datum/chemical_reaction/oil
	name = "Oil"
	id = "oil"
	result = "oil"
	required_reagents = list("fuel" = 1, "carbon" = 1, "hydrogen" = 1)
	result_amount = 3
	mix_message = "An iridescent black chemical forms in the container."

/datum/chemical_reaction/phenol
	name = "phenol"
	id = "phenol"
	result = "phenol"
	required_reagents = list("water" = 1, "chlorine" = 1, "oil" = 1)
	result_amount = 3
	mix_message = "The mixture bubbles and gives off an unpleasant medicinal odor."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/colorful_reagent
	name = "colorful_reagent"
	id = "colorful_reagent"
	result = "colorful_reagent"
	required_reagents = list("plasma" = 1, "radium" = 1, "space_drugs" = 1, "cryoxadone" = 1, "triple_citrus" = 1, "stabilizing_agent" = 1)
	result_amount = 6
	mix_message = "The substance flashes multiple colors and emits the smell of a pocket protector."

/datum/chemical_reaction/corgium
	name = "corgium"
	id = "corgium"
	result = null
	required_reagents = list("nutriment" = 1, "colorful_reagent" = 1, "lazarus_reagent" = 1, "blood" = 1)
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
	required_reagents = list("egg" = 1, "colorful_reagent" = 1, "chicken_soup" = 1, "lazarus_reagent" = 1, "blood" = 1)
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
	result = "hair_dye"
	required_reagents = list("colorful_reagent" = 1, "hairgrownium" = 1)
	result_amount = 2

/datum/chemical_reaction/hairgrownium
	name = "hairgrownium"
	id = "hairgrownium"
	result = "hairgrownium"
	required_reagents = list("carpet" = 1, "synthflesh" = 1, "ephedrine" = 1)
	result_amount = 3
	mix_message = "The liquid becomes slightly hairy."

/datum/chemical_reaction/super_hairgrownium
	name = "Super Hairgrownium"
	id = "super_hairgrownium"
	result = "super_hairgrownium"
	required_reagents = list("iron" = 1, "methamphetamine" = 1, "hairgrownium" = 1)
	result_amount = 3
	mix_message = "The liquid becomes amazingly furry and smells peculiar."

/datum/chemical_reaction/soapification
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1


/datum/chemical_reaction/soapification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade(location)

/datum/chemical_reaction/candlefication
	name = "Candlefication"
	id = "candlefication"
	result = null
	required_reagents = list("liquidgibs" = 5, "oxygen"  = 5) //
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/candlefication/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/candle(location)

/datum/chemical_reaction/meatification
	name = "Meatification"
	id = "meatification"
	result = null
	required_reagents = list("liquidgibs" = 10, "nutriment" = 10, "carbon" = 10)
	result_amount = 1

/datum/chemical_reaction/meatification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/food/meat/slab/meatproduct(location)

/datum/chemical_reaction/lye
	name = "lye"
	id = "lye"
	result = "lye"
	required_reagents = list("sodium" = 1, "hydrogen" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/love
	name = "pure love"
	id = "love"
	result = "love"
	required_reagents = list("hugs" = 1, "chocolate" = 1)
	result_amount = 2
	mix_message = "The substance gives off a lovely scent!"

/datum/chemical_reaction/jestosterone
	name = "Jestosterone"
	id = "jestosterone"
	result = "jestosterone"
	required_reagents = list("blood" = 1, "sodiumchloride" = 1, "banana" = 1, "lube" = 1, "space_drugs" = 1) //Or one freshly-squeezed clown
	min_temp = T0C + 100
	result_amount = 5
	mix_message = "The substance quickly shifts colour, cycling from red, to yellow, to green, to blue, and finally settles at a vibrant fuchsia."

/datum/chemical_reaction/jestosterone/on_reaction(datum/reagents/holder, created_volume)
	playsound(get_turf(holder.my_atom), 'sound/items/bikehorn.ogg', 50, 1)

/datum/chemical_reaction/mimestrogen
	name = "Mimestrogen"
	id = "mimestrogen"
	result = "mimestrogen"
	required_reagents = list("blood" = 1, "sodiumchloride" = 1, "nothing" = 1, "capulettium_plus" = 1) // Or one freshly-squeezed mime
	min_temp = T0C + 100
	result_amount = 5
	mix_message = "The mixture seems to drain of color before stopping at a dark grey."

/datum/chemical_reaction/royal_bee_jelly
	name = "royal bee jelly"
	id = "royal_bee_jelly"
	result = "royal_bee_jelly"
	required_reagents = list("mutagen" = 10, "honey" = 40)
	result_amount = 5

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = "glycerol"
	result = "glycerol"
	required_reagents = list("cornoil" = 3, "sacid" = 1)
	result_amount = 1

/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	result = "condensedcapsaicin"
	required_reagents = list("capsaicin" = 2)
	required_catalysts = list("plasma" = 5)
	result_amount = 1

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = "sodiumchloride"
	result = "sodiumchloride"
	required_reagents = list("sodium" = 1, "chlorine" = 1, "water" = 1)
	result_amount = 3
	mix_message = "The solution crystallizes with a brief flare of light."

/datum/chemical_reaction/acetaldehyde
	name = "Acetaldehyde"
	id = "acetaldehyde"
	result = "acetaldehyde"
	required_reagents = list("chromium" = 1, "oxygen" = 1, "copper" = 1, "ethanol" = 1)
	result_amount = 3
	min_temp = T0C + 275
	mix_message = "It smells like a bad hangover in here."

/datum/chemical_reaction/acetic_acid
	name = "Acetic Acid"
	id = "acetic_acid"
	result = "acetic_acid"
	required_reagents = list("acetaldehyde" = 1, "oxygen" = 1, "nitrogen" = 4)
	result_amount = 3
	mix_message = "It smells like vinegar and a bad hangover in here."

/datum/chemical_reaction/ice
	name = "Ice"
	id = "ice"
	result = "ice"
	required_reagents = list("water" = 1)
	result_amount = 1
	max_temp = T0C
	mix_message = "Ice forms as the water freezes."
	mix_sound = null

/datum/chemical_reaction/water
	name = "Water"
	id = "water"
	result = "water"
	required_reagents = list("ice" = 1)
	result_amount = 1
	min_temp = T0C + 29 // In Space.....ice melts at 82F...don't ask
	mix_message = "Water pools as the ice melts."
	mix_sound = null

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = "virusfood"
	required_reagents = list("water" = 1, "milk" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/virus_food_mutagen
	name = "mutagenic agar"
	id = "mutagenvirusfood"
	result = "mutagenvirusfood"
	required_reagents = list("mutagen" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_diphenhydramine
	name = "virus rations"
	id = "diphenhydraminevirusfood"
	result = "diphenhydraminevirusfood"
	required_reagents = list("diphenhydramine" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_plasma
	name = "virus plasma"
	id = "plasmavirusfood"
	result = "plasmavirusfood"
	required_reagents = list("plasma_dust" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_plasma_diphenhydramine
	name = "weakened virus plasma"
	id = "weakplasmavirusfood"
	result = "weakplasmavirusfood"
	required_reagents = list("diphenhydramine" = 1, "plasmavirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutagen_sugar
	name = "sucrose agar"
	id = "sugarvirusfood"
	result = "sugarvirusfood"
	required_reagents = list("sugar" = 1, "mutagenvirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutagen_salineglucose
	name = "sucrose agar"
	id = "salineglucosevirusfood"
	result = "sugarvirusfood"
	required_reagents = list("salglu_solution" = 1, "mutagenvirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutadone
	name = "stable agar"
	id = "stable_agar"
	result = "stable_agar"
	required_reagents = list("mutadone" = 1, "virusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_tracker
	name = "Tracking agar"
	id = "tracking_agar"
	result = "tracking_agar"
	required_reagents = list("fluorosurfactant" = 1, "virusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/mix_virus
	name = "Mix Virus"
	id = "mixvirus"
	required_reagents = list("virusfood" = 1)
	required_catalysts = list("blood" = 1)
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
	required_reagents = list("mutagen" = 1)
	level_min = 2
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_3
	name = "Mix Virus 3"
	id = "mixvirus3"
	required_reagents = list("plasma_dust" = 1)
	level_min = 4
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_4
	name = "Mix Virus 4"
	id = "mixvirus4"
	required_reagents = list("uranium" = 1)
	level_min = 5
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_5
	name = "Mix Virus 5"
	id = "mixvirus5"
	required_reagents = list("mutagenvirusfood" = 1)
	level_min = 3
	level_max = 3

/datum/chemical_reaction/mix_virus/mix_virus_6
	name = "Mix Virus 6"
	id = "mixvirus6"
	required_reagents = list("sugarvirusfood" = 1)
	level_min = 4
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_7
	name = "Mix Virus 7"
	id = "mixvirus7"
	required_reagents = list("weakplasmavirusfood" = 1)
	level_min = 5
	level_max = 5

/datum/chemical_reaction/mix_virus/mix_virus_8
	name = "Mix Virus 8"
	id = "mixvirus8"
	required_reagents = list("plasmavirusfood" = 1)
	level_min = 6
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_9
	name = "Mix Virus 9"
	id = "mixvirus9"
	required_reagents = list("diphenhydraminevirusfood" = 1)
	level_min = 1
	level_max = 1

/datum/chemical_reaction/mix_virus/rem_virus
	name = "Devolve Virus"
	id = "remvirus"
	required_reagents = list("diphenhydramine" = 1)
	required_catalysts = list("blood" = 1)

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()

/datum/chemical_reaction/mix_virus/stabilize_virus
	name = "Stabilize Virus"
	id = "stabilize_virus"
	required_reagents = list("stable_agar" = 1)

/datum/chemical_reaction/mix_virus/stabilize_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(istype(D))
			D.evolution_chance = 0

/datum/chemical_reaction/mix_virus/track_virus
	name = "Track Virus"
	id = "track_virus"
	required_reagents = list("tracking_agar" = 1)

/datum/chemical_reaction/mix_virus/track_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(istype(D))
			D.tracker = D.GetDiseaseID()

/datum/chemical_reaction/mix_virus/clear_virus
	name = "Clear Virus"
	id = "clear_virus"
	required_reagents = list("viral_eraser" = 10)

/datum/chemical_reaction/mix_virus/clear_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(istype(D))
			D.tracker = ""
			D.evolution_chance = VIRUS_EVOLUTION_CHANCE

// Someday, maybe add some version of doing science on patient zero to discover the recipees.
/datum/chemical_reaction/zombie
	name = "Anti-Plague Sequence Alpha"
	id = "zombiecure1"
	result = "zombiecure1"
	result_amount = 1
	required_reagents = list("blood" = 1, "diphenhydramine" = 1)
	mix_message = "The mixture into a dark green paste."
	/// The cure level of the reagent, level 4 cure requires level 3 cure, which requires level 2 cure, etc
	var/cure_level = 1
	/// The amount of reagents to pick from get_possible_cures()
	var/amt_req_cures = 1
	/// A virus symptom required to complete this chemical reaction
	var/datum/symptom/required_symptom

/datum/chemical_reaction/zombie/New()
	. = ..()
	var/possible_cures = get_possible_cures()
	if(!length(possible_cures))
		return
	required_reagents = list()
	required_reagents["blood"] = 1
	for(var/i in 1 to amt_req_cures)
		if(!length(possible_cures))
			return
		var/next_cure = pick_n_take(possible_cures)
		required_reagents[next_cure] = 1

/datum/chemical_reaction/zombie/last_can_react_check(datum/reagents/holder)
	var/datum/reagent/blood/blood = locate(/datum/reagent/blood) in holder.reagent_list
	if(!blood || !blood.data)
		return FALSE
	var/datum/disease/zombie/zomb = locate(/datum/disease/zombie) in blood.data["viruses"]
	if(!zomb)
		return FALSE
	if(zomb.cure_stage + 1 > cure_level) // Virus has already been cured to this level
		return FALSE
	if(!required_symptom)
		return TRUE

	for(var/datum/disease/advance/advanced in blood.data["viruses"])
		for(var/datum/symptom/symptom as anything in advanced.symptoms)
			if(istype(symptom, required_symptom))
				return TRUE
	return FALSE

/datum/chemical_reaction/zombie/proc/get_possible_cures()
	return list()

/datum/chemical_reaction/zombie/second
	name = "Anti-Plague Sequence Beta"
	id = "zombiecure2"
	result = "zombiecure2"
	cure_level = 2
	amt_req_cures = 3

/datum/chemical_reaction/zombie/second/get_possible_cures()
	return list("salglu_solution", "toxin", "atropine", "lye", "sodawater", "happiness", "morphine", "teporone")

/datum/chemical_reaction/zombie/third
	name = "Anti-Plague Sequence Gamma"
	id = "zombiecure3"
	result = "zombiecure3"
	cure_level = 3
	amt_req_cures = 3
	required_symptom = /datum/symptom/flesh_eating

/datum/chemical_reaction/zombie/third/get_possible_cures()
	return list("vomit", "jenkem", "charcoal", "egg", "sacid", "facid", "surge", "ultralube", "mitocholide")

/datum/chemical_reaction/zombie/four
	name = "Anti-Plague Sequence Omega"
	id = "zombiecure4"
	result = "zombiecure4"
	cure_level = 4
	amt_req_cures = 2
	required_symptom = /datum/symptom/heal

/datum/chemical_reaction/zombie/four/get_possible_cures()
	return list("colorful_reagent", "bacchus_blessing", "pen_acid", "glyphosate", "lazarus_reagent", "omnizine", "sarin", "ants", "clf3", "sorium", "????", "aranesp")
	// Heres some ideas for making this harder if people ever get too good at curing zombies some day
	// return list("entpoly", "tinlux", "earthsblood", "bath_salts", "rezadone", "rotatium", "krokodil", "fliptonium")

/datum/chemical_reaction/dupe_zomb_cure
	name = "Duplicate Zombie Cure"
	id = "dupe_zomb_cure"
	required_reagents = list("sulfonal" = 1, "sugar" = 1)
	result_amount = 1

/datum/chemical_reaction/dupe_zomb_cure/last_can_react_check(datum/reagents/holder)
	for(var/possible in list("zombiecure4", "zombiecure3", "zombiecure2", "zombiecure1"))
		if(holder.has_reagent(possible))
			result = possible // real time bullshit
			return TRUE
	return FALSE


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

	var/datum/effect/system/foam_spread/s = new()
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

	var/datum/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, MFOAM_ALUMINUM)
	s.start()


/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	result = null
	required_reagents = list("iron" = 3, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	holder.my_atom.visible_message("<span class='warning>The solution spews out a metalic foam!</span>")

	var/datum/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, MFOAM_IRON)
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
	min_temp = 374
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

/datum/chemical_reaction/plastication
	name = "Plastic"
	id = "solidplastic"
	result = null
	required_reagents = list("facid" = 10, "plasticide" = 20)
	result_amount = 1

/datum/chemical_reaction/plastication/on_reaction(datum/reagents/holder)
	var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/mineral/plastic
	M.amount = 10
	M.forceMove(get_turf(holder.my_atom))


/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	id = "space_drugs"
	result = "space_drugs"
	required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)
	result_amount = 3
	mix_message = "Slightly dizzying fumes drift from the solution."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

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

/datum/chemical_reaction/lsd
	name = "Lysergic acid diethylamide"
	id = "lsd"
	result = "lsd"
	required_reagents = list("diethylamine" = 1, "fungus" = 1)
	result_amount = 3
	mix_message = "The mixture turns a rather unassuming color and settles."

/datum/chemical_reaction/drying_agent
	name = "Drying agent"
	id = "drying_agent"
	result = "drying_agent"
	required_reagents = list("plasma" = 2, "ethanol" = 1, "sodium" = 1)
	result_amount = 3
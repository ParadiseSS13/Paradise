/datum/chemical_reaction/formaldehyde
	name = "formaldehyde"
	id = "formaldehyde"
	result = /datum/reagent/formaldehyde
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/oxygen = 1, /datum/reagent/silver = 1)
	result_amount = 3
	min_temp = T0C + 150
	mix_message = "Ugh, it smells like the morgue in here."

/datum/chemical_reaction/neurotoxin2
	name = "neurotoxin2"
	id = "neurotoxin2"
	result = /datum/reagent/neurotoxin2
	required_reagents = list(/datum/reagent/space_drugs = 1)
	result_amount = 1
	min_temp = T0C + 400
	mix_sound = null
	mix_message = null

/datum/chemical_reaction/cyanide
	name = "Cyanide"
	id = "cyanide"
	result = /datum/reagent/cyanide
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/ammonia = 1, /datum/reagent/oxygen = 1)
	result_amount = 3
	min_temp = T0C + 100
	mix_message = "The mixture gives off a faint scent of almonds."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cyanide/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(C.can_breathe_gas())
			C.reagents.add_reagent(/datum/reagent/cyanide, 7)

/datum/chemical_reaction/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	result = /datum/reagent/itching_powder
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/ammonia = 1, /datum/reagent/fungus = 1)
	result_amount = 3
	mix_message = "The mixture congeals and dries up, leaving behind an abrasive powder."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/facid
	name = "Fluorosulfuric Acid"
	id = "facid"
	result = /datum/reagent/acid/facid
	required_reagents = list(/datum/reagent/acid = 1, /datum/reagent/fluorine = 1, /datum/reagent/hydrogen = 1, /datum/reagent/potassium = 1)
	result_amount = 4
	min_temp = T0C + 100
	mix_message = "The mixture deepens to a dark blue, and slowly begins to corrode its container."

/datum/chemical_reaction/initropidril
	name = "Initropidril"
	id = "initropidril"
	result = /datum/reagent/initropidril
	required_reagents = list(/datum/reagent/crank = 1, /datum/reagent/histamine = 1, /datum/reagent/krokodil = 1, /datum/reagent/bath_salts = 1, /datum/reagent/medicine/atropine = 1, /datum/reagent/nicotine = 1, /datum/reagent/medicine/morphine = 1)
	result_amount = 4
	mix_message = "A sweet and sugary scent drifts from the unpleasant milky substance."

/datum/chemical_reaction/sulfonal
	name = "sulfonal"
	id = "sulfonal"
	result = /datum/reagent/sulfonal
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/sulfur = 1)
	result_amount = 3
	mix_message = "The mixture gives off quite a stench."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/lipolicide
	name = "lipolicide"
	id = "lipolicide"
	result = /datum/reagent/lipolicide
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/diethylamine = 1, /datum/reagent/medicine/ephedrine = 1)
	result_amount = 3

/datum/chemical_reaction/sarin
	name = "sarin"
	id = "sarin"
	result = /datum/reagent/sarin
	required_reagents = list(/datum/reagent/chlorine = 1, /datum/reagent/fuel = 1, /datum/reagent/oxygen = 1, /datum/reagent/phosphorus = 1, /datum/reagent/fluorine = 1, /datum/reagent/hydrogen = 1, /datum/reagent/acetone = 1, /datum/reagent/glyphosate/atrazine = 1)
	result_amount = 3
	mix_message = "The mixture yields a colorless, odorless liquid."
	min_temp = T0C + 100
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/sarin/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 2))
		if(C.can_breathe_gas())
			C.reagents.add_reagent(/datum/reagent/sarin, 4)

/datum/chemical_reaction/glyphosate
	name = "glyphosate"
	id = "glyphosate"
	result = /datum/reagent/glyphosate
	required_reagents = list(/datum/reagent/chlorine = 1, /datum/reagent/phosphorus = 1, /datum/reagent/formaldehyde = 1, /datum/reagent/ammonia = 1)
	result_amount = 4

/datum/chemical_reaction/atrazine
	name = "atrazine"
	id = "atrazine"
	result = /datum/reagent/glyphosate/atrazine
	required_reagents = list(/datum/reagent/chlorine = 1, /datum/reagent/hydrogen = 1, /datum/reagent/nitrogen = 1)
	result_amount = 3
	mix_message = "The mixture gives off a harsh odor"

/datum/chemical_reaction/pestkiller // To-Do make this more realistic
	name = "Pest Killer"
	id = "pestkiller"
	result = /datum/reagent/pestkiller
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/consumable/ethanol = 4)
	result_amount = 5
	mix_message = "The mixture gives off a harsh odor"

/datum/chemical_reaction/capulettium
	name = "capulettium"
	id = "capulettium"
	result = /datum/reagent/capulettium
	required_reagents = list(/datum/reagent/neurotoxin2 = 1, /datum/reagent/chlorine = 1, /datum/reagent/hydrogen = 1)
	result_amount = 1
	mix_message = "The smell of death wafts up from the solution."

/datum/chemical_reaction/capulettium_plus
	name = "capulettium_plus"
	id = "capulettium_plus"
	result = /datum/reagent/capulettium_plus
	required_reagents = list(/datum/reagent/capulettium = 1, /datum/reagent/medicine/ephedrine = 1, /datum/reagent/methamphetamine = 1)
	result_amount = 3
	mix_message = "The solution begins to slosh about violently by itself."

/datum/chemical_reaction/teslium
	name = "Teslium"
	id = "teslium"
	result = /datum/reagent/teslium
	required_reagents = list(/datum/reagent/plasma = 1, /datum/reagent/silver = 1, /datum/reagent/blackpowder = 1)
	result_amount = 3
	mix_message = "<span class='danger'>A jet of sparks flies from the mixture as it merges into a flickering slurry.</span>"
	min_temp = T0C + 50
	mix_sound = null

/datum/chemical_reaction/teslium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	do_sparks(6, 1, location)

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	result = /datum/reagent/mutagen
	required_reagents = list(/datum/reagent/radium = 1, /datum/reagent/plasma = 1, /datum/reagent/chlorine = 1)
	result_amount = 3
	mix_message = "The substance turns neon green and bubbles unnervingly."

/datum/chemical_reaction/rotatium
	name = "Rotatium"
	id = "Rotatium"
	result = /datum/reagent/rotatium
	required_reagents = list(/datum/reagent/lsd = 1, /datum/reagent/teslium = 1, /datum/reagent/methamphetamine = 1)
	result_amount = 3
	mix_message = "<span class='danger'>After sparks, fire, and the smell of LSD, the mix is constantly spinning with no stop in sight.</span>"

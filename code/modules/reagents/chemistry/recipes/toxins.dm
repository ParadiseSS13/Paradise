/datum/chemical_reaction/formaldehyde
	name = "formaldehyde"
	id = "formaldehyde"
	result = "formaldehyde"
	required_reagents = list("ethanol" = 1, "oxygen" = 1, "silver" = 1)
	result_amount = 3
	min_temp = T0C + 150
	mix_message = "Ugh, it smells like the morgue in here."

/datum/chemical_reaction/neurotoxin2
	name = "neurotoxin2"
	id = "neurotoxin2"
	result = "neurotoxin2"
	required_reagents = list("space_drugs" = 1)
	result_amount = 1
	min_temp = T0C + 400
	mix_sound = null
	mix_message = null

/datum/chemical_reaction/cyanide
	name = "Cyanide"
	id = "cyanide"
	result = "cyanide"
	required_reagents = list("oil" = 1, "ammonia" = 1, "oxygen" = 1)
	result_amount = 3
	min_temp = T0C + 100
	mix_message = "The mixture gives off a faint scent of almonds."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cyanide/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(C.can_breathe_gas())
			C.reagents.add_reagent("cyanide", 7)

/datum/chemical_reaction/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	result = "itching_powder"
	required_reagents = list("fuel" = 1, "ammonia" = 1, "fungus" = 1)
	result_amount = 3
	mix_message = "The mixture congeals and dries up, leaving behind an abrasive powder."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/facid
	name = "Fluorosulfuric Acid"
	id = "facid"
	result = "facid"
	required_reagents = list("sacid" = 1, "fluorine" = 1, "hydrogen" = 1, "potassium" = 1)
	result_amount = 4
	min_temp = T0C + 100
	mix_message = "The mixture deepens to a dark blue, and slowly begins to corrode its container."

/datum/chemical_reaction/initropidril
	name = "Initropidril"
	id = "initropidril"
	result = "initropidril"
	required_reagents = list("crank" = 1, "histamine" = 1, "krokodil" = 1, "bath_salts" = 1, "atropine" = 1, "nicotine" = 1, "morphine" = 1)
	result_amount = 4
	mix_message = "A sweet and sugary scent drifts from the unpleasant milky substance."

/datum/chemical_reaction/sulfonal
	name = "sulfonal"
	id = "sulfonal"
	result = "sulfonal"
	required_reagents = list("acetone" = 1, "diethylamine" = 1, "sulfur" = 1)
	result_amount = 3
	mix_message = "The mixture gives off quite a stench."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/lipolicide
	name = "lipolicide"
	id = "lipolicide"
	result = "lipolicide"
	required_reagents = list("mercury" = 1, "diethylamine" = 1, "ephedrine" = 1)
	result_amount = 3

/datum/chemical_reaction/sarin
	name = "sarin"
	id = "sarin"
	result = "sarin"
	required_reagents = list("chlorine" = 1, "fuel" = 1, "oxygen" = 1, "phosphorus" = 1, "fluorine" = 1, "hydrogen" = 1, "acetone" = 1, "atrazine" = 1)
	result_amount = 3
	mix_message = "The mixture yields a colorless, odorless liquid."
	min_temp = T0C + 100
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/sarin/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 2))
		if(C.can_breathe_gas())
			C.reagents.add_reagent("sarin", 4)

/datum/chemical_reaction/glyphosate
	name = "glyphosate"
	id = "glyphosate"
	result = "glyphosate"
	required_reagents = list("chlorine" = 1, "phosphorus" = 1, "formaldehyde" = 1, "ammonia" = 1)
	result_amount = 4

/datum/chemical_reaction/atrazine
	name = "atrazine"
	id = "atrazine"
	result = "atrazine"
	required_reagents = list("chlorine" = 1, "hydrogen" = 1, "nitrogen" = 1)
	result_amount = 3
	mix_message = "The mixture gives off a harsh odor"

/datum/chemical_reaction/pestkiller // To-Do make this more realistic
	name = "Pest Killer"
	id = "pestkiller"
	result = "pestkiller"
	required_reagents = list("toxin" = 1, "ethanol" = 4)
	result_amount = 5
	mix_message = "The mixture gives off a harsh odor"

/datum/chemical_reaction/capulettium
	name = "capulettium"
	id = "capulettium"
	result = "capulettium"
	required_reagents = list("neurotoxin2" = 1, "chlorine" = 1, "hydrogen" = 1)
	result_amount = 1
	mix_message = "The smell of death wafts up from the solution."

/datum/chemical_reaction/capulettium_plus
	name = "capulettium_plus"
	id = "capulettium_plus"
	result = "capulettium_plus"
	required_reagents = list("capulettium" = 1, "ephedrine" = 1, "methamphetamine" = 1)
	result_amount = 3
	mix_message = "The solution begins to slosh about violently by itself."

/datum/chemical_reaction/teslium
	name = "Teslium"
	id = "teslium"
	result = "teslium"
	required_reagents = list("plasma" = 1, "silver" = 1, "blackpowder" = 1)
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
	result = "mutagen"
	required_reagents = list("radium" = 1, "plasma" = 1, "chlorine" = 1)
	result_amount = 3
	mix_message = "The substance turns neon green and bubbles unnervingly."

/datum/chemical_reaction/stable_mustagen
	name = "Stable mutagen"
	id = "stable_mutagen"
	result = "stable_mutagen"
	required_reagents = list("mutagen" = 1, "lithium" = 1, "acetone" = 1, "bromine" = 1)
	result_amount = 3
	mix_message = "The substance turns a drab green and begins to bubble."

/datum/chemical_reaction/stable_mustagen/stable_mustagen2
	id = "stable_mutagen2"
	required_reagents = list("mutadone" = 3, "lithium" = 1)
	result_amount = 4

/datum/chemical_reaction/heparin
	name = "Heparin"
	id = "Heparin"
	result = "heparin"
	required_reagents = list("formaldehyde" = 1, "sodium" = 1, "chlorine" = 1, "lithium" = 1)
	result_amount = 4
	mix_message = "The mixture thins and loses all color."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'
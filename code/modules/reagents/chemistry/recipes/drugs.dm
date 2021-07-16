/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	id = "space_drugs"
	result = /datum/reagent/space_drugs
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1)
	result_amount = 3
	mix_message = "Slightly dizzying fumes drift from the solution."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/crank
	name = "Crank"
	id = "crank"
	result = /datum/reagent/crank
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/ammonia = 1, /datum/reagent/lithium = 1, /datum/reagent/acid = 1, /datum/reagent/fuel = 1)
	result_amount = 5
	mix_message = "The mixture violently reacts, leaving behind a few crystalline shards."
	mix_sound = 'sound/goonstation/effects/crystalshatter.ogg'
	min_temp = T0C + 100

/datum/chemical_reaction/crank/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	fireflash(holder.my_atom, 1)
	explosion(T, 0, 0, 2)

/datum/chemical_reaction/krokodil
	name = "Krokodil"
	id = "krokodil"
	result = /datum/reagent/krokodil
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/medicine/morphine = 1, /datum/reagent/space_cleaner = 1, /datum/reagent/potassium = 1, /datum/reagent/phosphorus = 1, /datum/reagent/fuel = 1)
	result_amount = 6
	mix_message = "The mixture dries into a pale blue powder."
	min_temp = T0C + 100
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/methamphetamine
	name = "methamphetamine"
	id = "methamphetamine"
	result = /datum/reagent/methamphetamine
	required_reagents = list(/datum/reagent/medicine/ephedrine = 1, /datum/reagent/iodine = 1, /datum/reagent/phosphorus = 1, /datum/reagent/hydrogen = 1)
	result_amount = 4
	min_temp = T0C + 100

/datum/chemical_reaction/methamphetamine/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(C.can_breathe_gas())
			C.emote("gasp")
			C.AdjustLoseBreath(1)
			C.reagents.add_reagent(/datum/reagent/toxin, 10)
			C.reagents.add_reagent(/datum/reagent/neurotoxin2, 20)

/datum/chemical_reaction/bath_salts
	name = "bath_salts"
	id = "bath_salts"
	result = /datum/reagent/bath_salts
	required_reagents = list(/datum/reagent/questionmark = 1, /datum/reagent/saltpetre = 1, /datum/reagent/msg = 1, /datum/reagent/space_cleaner = 1, /datum/reagent/consumable/enzyme = 1, /datum/reagent/consumable/mugwort = 1, /datum/reagent/mercury = 1)
	result_amount = 6
	min_temp = T0C + 100
	mix_message = "Tiny cubic crystals precipitate out of the mixture. Huh."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/jenkem
	name = "Jenkem"
	id = "jenkem"
	result = /datum/reagent/jenkem
	required_reagents = list(/datum/reagent/fishwater/toiletwater = 1, /datum/reagent/ammonia = 1, /datum/reagent/water = 1)
	result_amount = 3
	mix_message = "The mixture ferments into a filthy morass."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/jenkem/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(C.can_breathe_gas())
			C.reagents.add_reagent(/datum/reagent/jenkem, 25)

/datum/chemical_reaction/aranesp
	name = "Aranesp"
	id = "aranesp"
	result = /datum/reagent/aranesp
	required_reagents = list(/datum/reagent/medicine/epinephrine = 1, /datum/reagent/medicine/atropine = 1, /datum/reagent/medicine/insulin = 1)
	result_amount = 3

/datum/chemical_reaction/fliptonium
	name = "fliptonium"
	id = "fliptonium"
	result = /datum/reagent/fliptonium
	required_reagents = list(/datum/reagent/medicine/ephedrine = 1, /datum/reagent/liquid_dark_matter = 1, /datum/reagent/consumable/chocolate = 1, /datum/reagent/ginsonic = 1)
	result_amount = 4
	mix_message = "The mixture swirls around excitedly!"

/datum/chemical_reaction/lsd
	name = "Lysergic acid diethylamide"
	id = "lsd"
	result = /datum/reagent/lsd
	required_reagents = list(/datum/reagent/diethylamine = 1, /datum/reagent/fungus = 1)
	result_amount = 3
	mix_message = "The mixture turns a rather unassuming color and settles."

/datum/chemical_reaction/lube/ultra
	name = "Ultra-Lube"
	id = "ultralube"
	result = /datum/reagent/lube/ultra
	required_reagents = list(/datum/reagent/lube = 2, /datum/reagent/formaldehyde = 1, /datum/reagent/cryostylane = 1)
	result_amount = 2
	mix_message = "The mixture darkens and appears to partially vaporize into a chilling aerosol."

/datum/chemical_reaction/surge
	name = "Surge"
	id = "surge"
	result = /datum/reagent/surge
	required_reagents = list(/datum/reagent/thermite = 3, /datum/reagent/uranium = 1, /datum/reagent/fluorosurfactant = 1, /datum/reagent/acid = 1)
	result_amount = 6
	mix_message = "The mixture congeals into a metallic green gel that crackles with electrical activity."

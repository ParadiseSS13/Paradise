/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	id = "space_drugs"
	result = "space_drugs"
	required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)
	result_amount = 3
	mix_message = "Slightly dizzying fumes drift from the solution."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/crank
	name = "Crank"
	id = "crank"
	result = "crank"
	required_reagents = list("diphenhydramine" = 1, "ammonia" = 1, "lithium" = 1, "sacid" = 1, "fuel" = 1)
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
	result = "krokodil"
	required_reagents = list("diphenhydramine" = 1, "morphine" = 1, "cleaner" = 1, "potassium" = 1, "phosphorus" = 1, "fuel" = 1)
	result_amount = 6
	mix_message = "The mixture dries into a pale blue powder."
	min_temp = T0C + 100
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/methamphetamine
	name = "methamphetamine"
	id = "methamphetamine"
	result = "methamphetamine"
	required_reagents = list("ephedrine" = 1, "iodine" = 1, "phosphorus" = 1, "hydrogen" = 1)
	result_amount = 4
	min_temp = T0C + 100

/datum/chemical_reaction/methamphetamine/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(C.can_breathe_gas())
			C.emote("gasp")
			C.AdjustLoseBreath(2 SECONDS)
			C.reagents.add_reagent("toxin", 10)
			C.reagents.add_reagent("neurotoxin2", 20)

/datum/chemical_reaction/pump_up
	name = "pump up"
	id = "pump_up"
	result = "pump_up"
	required_reagents = list("epinephrine" = 1, "coffee" = 2, "nicotine" = 1)
	result_amount = 4
	mix_message = "The mixture congeals into a black paste"

/datum/chemical_reaction/bath_salts
	name = "bath_salts"
	id = "bath_salts"
	result = "bath_salts"
	required_reagents = list("????" = 1, "saltpetre" = 1, "msg" = 1, "cleaner" = 1, "enzyme" = 1, "sodiumchloride" = 1, "mercury" = 1)
	result_amount = 6
	min_temp = T0C + 100
	mix_message = "Tiny cubic crystals precipitate out of the mixture. Huh."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/jenkem
	name = "Jenkem"
	id = "jenkem"
	result = "jenkem"
	required_reagents = list("toiletwater" = 1, "ammonia" = 1, "water" = 1)
	result_amount = 3
	mix_message = "The mixture ferments into a filthy morass."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/jenkem/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(C.can_breathe_gas())
			C.reagents.add_reagent("jenkem", 25)

/datum/chemical_reaction/aranesp
	name = "Aranesp"
	id = "aranesp"
	result = "aranesp"
	required_reagents = list("epinephrine" = 1, "atropine" = 1, "insulin" = 1)
	result_amount = 3

/datum/chemical_reaction/fliptonium
	name = "fliptonium"
	id = "fliptonium"
	result = "fliptonium"
	required_reagents = list("ephedrine" = 1, "liquid_dark_matter" = 1, "chocolate" = 1, "ginsonic" = 1)
	result_amount = 4
	mix_message = "The mixture swirls around excitedly!"

/datum/chemical_reaction/lsd
	name = "Lysergic acid diethylamide"
	id = "lsd"
	result = "lsd"
	required_reagents = list("diethylamine" = 1, "fungus" = 1)
	result_amount = 3
	mix_message = "The mixture turns a rather unassuming color and settles."

/datum/chemical_reaction/lube/ultra
	name = "Ultra-Lube"
	id = "ultralube"
	result = "ultralube"
	required_reagents = list("lube" = 2, "formaldehyde" = 1, "cryostylane" = 1)
	result_amount = 2
	mix_message = "The mixture darkens and appears to partially vaporize into a chilling aerosol."

/datum/chemical_reaction/surge
	name = "Surge"
	id = "surge"
	result = "surge"
	required_reagents = list("thermite" = 3, "uranium" = 1, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 6
	mix_message = "The mixture congeals into a metallic green gel that crackles with electrical activity."

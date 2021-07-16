/datum/chemical_reaction/hydrocodone
	name = "Hydrocodone"
	id = "hydrocodone"
	result = /datum/reagent/medicine/hydrocodone
	required_reagents = list(/datum/reagent/medicine/morphine = 1, /datum/reagent/acid = 1, /datum/reagent/water = 1, /datum/reagent/oil = 1)
	result_amount = 2

/datum/chemical_reaction/mitocholide
	name = "mitocholide"
	id = "mitocholide"
	result = /datum/reagent/medicine/mitocholide
	required_reagents = list(/datum/reagent/medicine/synthflesh = 1, /datum/reagent/medicine/cryoxadone = 1, /datum/reagent/plasma = 1)
	result_amount = 3

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	result = /datum/reagent/medicine/cryoxadone
	required_reagents = list(/datum/reagent/cryostylane = 1, /datum/reagent/plasma = 1, /datum/reagent/acetone = 1, /datum/reagent/mutagen = 1)
	result_amount = 4
	mix_message = "The solution bubbles softly."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	result = /datum/reagent/medicine/spaceacillin
	required_reagents = list(/datum/reagent/fungus = 1, /datum/reagent/consumable/ethanol = 1)
	result_amount = 2
	mix_message = "The solvent extracts an antibiotic compound from the fungus."

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	id = "rezadone"
	result = /datum/reagent/medicine/rezadone
	required_reagents = list(/datum/reagent/carpotoxin = 1, /datum/reagent/medicine/spaceacillin = 1, /datum/reagent/copper = 1)
	result_amount = 3

/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	result = /datum/reagent/medicine/sterilizine
	required_reagents = list(/datum/reagent/medicine/antihol = 2, /datum/reagent/chlorine = 1)
	result_amount = 3

/datum/chemical_reaction/charcoal
	name = "Charcoal"
	id = "charcoal"
	result = /datum/reagent/medicine/charcoal
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/sodiumchloride = 1)
	result_amount = 2
	mix_message = "The mixture yields a fine black powder."
	min_temp = T0C + 100
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	result = /datum/reagent/medicine/silver_sulfadiazine
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/silver = 1, /datum/reagent/sulfur = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)
	result_amount = 5
	mix_message = "A strong and cloying odor begins to bubble from the mixture."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/salglu_solution
	name = "Saline-Glucose Solution"
	id = "salglu_solution"
	result = /datum/reagent/medicine/salglu_solution
	required_reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/water = 1, /datum/reagent/consumable/sugar = 1)
	result_amount = 3

/datum/chemical_reaction/heparin
	name = "Heparin"
	id = "Heparin"
	result = /datum/reagent/heparin
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/meatslurry = 1, /datum/reagent/phenol = 1, /datum/reagent/acid = 1)
	result_amount = 2

/datum/chemical_reaction/synthflesh
	name = "Synthflesh"
	id = "synthflesh"
	result = /datum/reagent/medicine/synthflesh
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/carbon = 1, /datum/reagent/medicine/styptic_powder = 1)
	result_amount = 3
	mix_message = "The mixture knits together into a fibrous, bloody mass."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	result = /datum/reagent/medicine/styptic_powder
	required_reagents = list(/datum/reagent/aluminum = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1, /datum/reagent/acid = 1)
	result_amount = 4
	mix_message = "The solution yields an astringent powder."

/datum/chemical_reaction/calomel
	name = "Calomel"
	id = "calomel"
	result = /datum/reagent/medicine/calomel
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/chlorine = 1)
	result_amount = 2
	min_temp = T0C + 100
	mix_message = "Stinging vapors rise from the solution."

/datum/chemical_reaction/potass_iodide
	name = "Potassium Iodide"
	id = "potass_iodide"
	result = /datum/reagent/medicine/potass_iodide
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/iodine = 1)
	result_amount = 2
	mix_message = "The solution settles calmly and emits gentle fumes."

/datum/chemical_reaction/pen_acid
	name = "Pentetic Acid"
	id = "pen_acid"
	result = /datum/reagent/medicine/pen_acid
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/chlorine = 1, /datum/reagent/ammonia = 1, /datum/reagent/formaldehyde = 1, /datum/reagent/sodium = 1, /datum/reagent/cyanide = 1)
	result_amount = 6
	mix_message = "The substance becomes very still, emitting a curious haze."

/datum/chemical_reaction/sal_acid
	name = "Salicyclic Acid"
	id = "sal_acid"
	result = /datum/reagent/medicine/sal_acid
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/phenol = 1, /datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/acid = 1)
	result_amount = 5
	mix_message = "The mixture crystallizes."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	result = /datum/reagent/medicine/salbutamol
	required_reagents = list(/datum/reagent/medicine/sal_acid = 1, /datum/reagent/lithium = 1, /datum/reagent/aluminum = 1, /datum/reagent/bromine = 1, /datum/reagent/ammonia = 1)
	result_amount = 5
	mix_message = "The solution bubbles freely, creating a head of bluish foam."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	result = /datum/reagent/medicine/perfluorodecalin
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/fluorine = 1, /datum/reagent/oil = 1)
	result_amount = 3
	min_temp = T0C + 100
	mix_message = "The mixture rapidly turns into a dense pink liquid."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	result = /datum/reagent/medicine/ephedrine
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/oil = 1, /datum/reagent/hydrogen = 1, /datum/reagent/diethylamine = 1)
	result_amount = 4
	mix_message = "The solution fizzes and gives off toxic fumes."

/datum/chemical_reaction/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	result = /datum/reagent/medicine/diphenhydramine
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/carbon = 1, /datum/reagent/bromine = 1, /datum/reagent/diethylamine = 1, /datum/reagent/consumable/ethanol = 1)
	result_amount = 4
	mix_message = "The mixture fizzes gently."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/oculine
	name = "Oculine"
	id = "oculine"
	result = /datum/reagent/medicine/oculine
	required_reagents = list(/datum/reagent/medicine/atropine = 1, /datum/reagent/medicine/spaceacillin = 1, /datum/reagent/medicine/salglu_solution = 1)
	result_amount = 3
	mix_message = "The mixture settles, becoming a milky white."

/datum/chemical_reaction/atropine
	name = "Atropine"
	id = "atropine"
	result = /datum/reagent/medicine/atropine
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/phenol = 1, /datum/reagent/acid = 1)
	result_amount = 5
	mix_message = "A horrid smell like something died drifts from the mixture."

/datum/chemical_reaction/epinephrine
	name = "Epinephrine"
	id = "epinephrine"
	result = /datum/reagent/medicine/epinephrine
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1, /datum/reagent/hydrogen = 1)
	result_amount = 6
	mix_message = "Tiny white crystals precipitate out of the solution."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/strange_reagent
	name = "Strange Reagent"
	id = "strange_reagent"
	result = /datum/reagent/medicine/strange_reagent
	required_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/holywater = 1, /datum/reagent/mutagen = 1)
	result_amount = 3
	mix_message = "The substance begins moving on its own somehow."

/datum/chemical_reaction/life
	name = "Life"
	id = "life"
	result = null
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/medicine/synthflesh = 1, /datum/reagent/blood = 1)
	result_amount = 1
	min_temp = T0C + 100

/datum/chemical_reaction/life/on_reaction(datum/reagents/holder, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Life (hostile)") //defaults to HOSTILE_SPAWN

/datum/chemical_reaction/life/friendly
	name = "Life (Friendly)"
	id = "life_friendly"
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/medicine/synthflesh = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/life/friendly/on_reaction(datum/reagents/holder, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Life (friendly)", FRIENDLY_SPAWN)

/datum/chemical_reaction/mannitol
	name = "Mannitol"
	id = "mannitol"
	result = /datum/reagent/medicine/mannitol
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/hydrogen = 1, /datum/reagent/water = 1)
	result_amount = 3
	mix_message = "The mixture bubbles slowly, making a slightly sweet odor."

/datum/chemical_reaction/mutadone
	name = "Mutadone"
	id = "mutadone"
	result = /datum/reagent/medicine/mutadone
	required_reagents = list(/datum/reagent/mutagen = 1, /datum/reagent/acetone = 1, /datum/reagent/bromine = 1)
	result_amount = 3
	mix_message = "A foul astringent liquid emerges from the reaction."

/datum/chemical_reaction/antihol
	name = "antihol"
	id = "antihol"
	result = /datum/reagent/medicine/antihol
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/charcoal = 1)
	result_amount = 2
	mix_message = "A minty and refreshing smell drifts from the effervescent mixture."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/teporone
	name = "Teporone"
	id = "teporone"
	result = /datum/reagent/medicine/teporone
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/silicon = 1, /datum/reagent/plasma = 1)
	result_amount = 2
	mix_message = "The mixture turns an odd lavender color."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/haloperidol
	name = "Haloperidol"
	id = "haloperidol"
	result = /datum/reagent/medicine/haloperidol
	required_reagents = list(/datum/reagent/chlorine = 1, /datum/reagent/fluorine = 1, /datum/reagent/aluminum = 1, /datum/reagent/medicine/potass_iodide = 1, /datum/reagent/oil = 1)
	result_amount = 4
	mix_message = "The chemicals mix into an odd pink slush."

/datum/chemical_reaction/ether
	name = "Ether"
	id = "ether"
	result = /datum/reagent/medicine/ether
	required_reagents = list(/datum/reagent/acid = 1, /datum/reagent/consumable/ethanol = 1, /datum/reagent/oxygen = 1)
	result_amount = 1
	mix_message = "The mixture yields a pungent odor, which makes you tired."

/datum/chemical_reaction/degreaser
	name = "Degreaser"
	id = "degreaser"
	result = /datum/reagent/medicine/degreaser
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/medicine/sterilizine = 1)
	result_amount = 2

/datum/chemical_reaction/liquid_solder
	name = "Liquid Solder"
	id = "liquid_solder"
	result = /datum/reagent/medicine/liquid_solder
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/copper = 1, /datum/reagent/silver = 1)
	result_amount = 3
	min_temp = T0C + 100
	mix_message = "The solution gently swirls with a metallic sheen."

/datum/chemical_reaction/menthol
	name = "Menthol"
	id = "menthol"
	result = /datum/reagent/medicine/menthol
	required_reagents = list(/datum/reagent/consumable/mint = 1, /datum/reagent/consumable/ethanol = 1)
	result_amount = 1
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'
	min_temp = T0C + 50
	mix_message = "Large white crystals precipitate out of the mixture."

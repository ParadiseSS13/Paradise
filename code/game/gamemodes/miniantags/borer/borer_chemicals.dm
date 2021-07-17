/datum/borer_chem
	var/chemtype
	var/chemdesc = "This is a chemical"
	var/chemuse = 30
	var/quantity = 10

/datum/borer_chem/capulettium_plus
	chemtype = /datum/reagent/capulettium_plus
	chemdesc = "Silences and masks pulse."

/datum/borer_chem/charcoal
	chemtype = /datum/reagent/medicine/charcoal
	chemdesc = "Slowly heals toxin damage, also slowly removes other chemicals."

/datum/borer_chem/epinephrine
	chemtype = /datum/reagent/medicine/epinephrine
	chemdesc = "Stabilizes critical condition and slowly heals suffocation damage."

/datum/borer_chem/fliptonium
	chemtype = /datum/reagent/fliptonium
	chemdesc = "Causes uncontrollable flipping."
	chemuse = 50

/datum/borer_chem/hydrocodone
	chemtype = /datum/reagent/medicine/hydrocodone
	chemdesc = "An extremely strong painkiller."

/datum/borer_chem/mannitol
	chemtype = /datum/reagent/medicine/mannitol
	chemdesc = "Heals brain damage."

/datum/borer_chem/methamphetamine
	chemtype = /datum/reagent/methamphetamine
	chemdesc = "Reduces stun times and increases stamina. Deals small amounts of brain damage."
	chemuse = 50

/datum/borer_chem/mitocholide
	chemtype = /datum/reagent/medicine/mitocholide
	chemdesc = "Heals internal organ damage."

/datum/borer_chem/salbutamol
	chemtype = /datum/reagent/medicine/salbutamol
	chemdesc = "Heals suffocation damage."

/datum/borer_chem/salglu_solution
	chemtype = /datum/reagent/medicine/salglu_solution
	chemdesc = "Slowly heals brute and burn damage, also slowly restores blood."

/datum/borer_chem/spaceacillin
	chemtype = /datum/reagent/medicine/spaceacillin
	chemdesc = "Slows progression of diseases and fights infections."

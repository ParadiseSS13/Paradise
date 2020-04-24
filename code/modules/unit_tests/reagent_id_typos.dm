

/datum/unit_test/reagent_id_typos

/datum/unit_test/reagent_id_typos/Run()
	for(var/I in GLOB.chemical_reactions_list)
		for(var/V in GLOB.chemical_reactions_list[I])
			var/datum/chemical_reaction/R = V
			for(var/id in (R.required_reagents + R.required_catalysts))
				if(!GLOB.chemical_reagents_list[id])
					Fail("Unknown chemical id \"[id]\" in recipe [R.type]")

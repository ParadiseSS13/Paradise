/datum/unit_test/spell_targeting/Run()
	var/list/bad_spells = list()
	for(var/obj/effect/proc_holder/spell/S as anything in typesof(/obj/effect/proc_holder/spell))
		if(initial(S.name) == "Spell")
			continue // Skip abstract spells
		S = new S
		if(!S.targeting)
			bad_spells += S
	if(length(bad_spells))
		Fail("Spells without targeting found: [bad_spells.Join(", ")]")

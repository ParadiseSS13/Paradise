/obj/effect/proc_holder/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing diseases, removing toxins and radiation, and resetting our genetic code completely."
	helptext = "Can be used while unconscious."
	chemical_cost = 20
	dna_cost = 1
	req_stat = UNCONSCIOUS

//Heals the things that the other regenerative abilities don't.
/obj/effect/proc_holder/changeling/panacea/sting_action(var/mob/user)

	user << "<span class='notice'>We cleanse impurities from our form.</span>"
	user.reagents.add_reagent("mutadone", 10)
	user.reagents.add_reagent("potass_iodide", 10)
	user.reagents.add_reagent("charcoal", 20)

	if(istype(user, /mob/living/carbon))
		var/mob/living/carbon/C = user
		if(C.virus2.len)
			for (var/ID in C.virus2)
				var/datum/disease2/disease/V = C.virus2[ID]
				C.antibodies |= V.antigen

	feedback_add_details("changeling_powers","AP")
	return 1
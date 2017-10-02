/obj/effect/proc_holder/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing diseases, removing parasites, sobering us, purging toxins and radiation, and resetting our genetic code completely."
	helptext = "Can be used while unconscious."
	chemical_cost = 20
	dna_cost = 1
	req_stat = UNCONSCIOUS

//Heals the things that the other regenerative abilities don't.
/obj/effect/proc_holder/changeling/panacea/sting_action(var/mob/user)

	to_chat(user, "<span class='notice'>We cleanse impurities from our form.</span>")

	var/mob/living/simple_animal/borer/B = user.has_brain_worms()
	if(B)
		B.leave_host()
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.vomit(0)
			to_chat(user, "<span class='notice'>We expel a parasite from our form.</span>")

	var/obj/item/organ/internal/body_egg/egg = user.get_int_organ(/obj/item/organ/internal/body_egg)
	if(egg)
		egg.remove(user)
		if(iscarbon(user))
			var/mob/living/carbon/human/C = user
			C.vomit()
		egg.forceMove(get_turf(user))

	user.reagents.add_reagent("mutadone", 10)
	user.reagents.add_reagent("potass_iodide", 10)
	user.reagents.add_reagent("charcoal", 20)
	user.reagents.add_reagent("antihol", 10)
	user.reagents.add_reagent("mannitol", 25)

	for(var/thing in user.viruses)
		var/datum/disease/D = thing
		if(D.severity == NONTHREAT)
			continue
		D.cure()

	feedback_add_details("changeling_powers","AP")
	return 1
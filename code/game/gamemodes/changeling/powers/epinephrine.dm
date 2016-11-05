/obj/effect/proc_holder/changeling/epinephrine
	name = "Epinephrine Overdose"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	helptext = "Removes all stuns instantly and adds a short-term reduction in further stuns. Can be used while unconscious. Continued use poisons the body."
	chemical_cost = 30
	dna_cost = 2
	req_human = 1
	req_stat = UNCONSCIOUS

//Recover from stuns.
/obj/effect/proc_holder/changeling/epinephrine/sting_action(var/mob/living/user)

	if(user.lying)
		to_chat(user, "<span class='notice'>We arise.</span>")
	else
		to_chat(user, "<span class='notice'>Adrenaline rushes through us.</span>")
	user.WakeUp()
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.lying = 0
	user.update_canmove()
	user.reagents.add_reagent("synaptizine", 20)
	user.adjustStaminaLoss(-75)

	feedback_add_details("changeling_powers","UNS")
	return 1

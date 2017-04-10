/obj/effect/proc_holder/changeling/fleshmend
	name = "Fleshmend"
	desc = "Our flesh rapidly regenerates, healing our wounds."
	helptext = "Heals a moderate amount of damage over a short period of time. Can be used while unconscious."
	chemical_cost = 25
	dna_cost = 2
	req_stat = UNCONSCIOUS

//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/obj/effect/proc_holder/changeling/fleshmend/sting_action(var/mob/living/user)
	to_chat(user, "<span class='notice'>We begin to heal rapidly.</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.restore_blood()
		H.shock_stage = 0
		spawn(1)
			H.fixblood()
	spawn(0)
		for(var/i = 0, i<10,i++)
			user.heal_overall_damage(10, 10)
			user.adjustOxyLoss(-10)
			sleep(10)

	feedback_add_details("changeling_powers","RR")
	return 1
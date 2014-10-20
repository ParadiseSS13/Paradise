/datum/reagent/antidepressant/dextromethorphan
	name = "Dextromethorphan"
	id = "dextromethorphan"
	description = "Cough medicine."
	reagent_state = LIQUID
	color = "#FF1111"
	custom_metabolism = 0.25
	data = 0

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		if(!data) data = 1
		data++

		switch(data)
			if(1 to 20)
				M << "\red Light Dose.."
			if(20 to 40)
				M << "\red Medium Dose.."
				if(prob(10)) M.emote(pick("giggle"))
			if(40 to 80)
				M << "\red High Dose.."
				M.druggy = max(M.druggy, 30)
				if(prob(5)) M.emote(pick("twitch_s", "giggle"))
			if(80 to INFINITY)
				M << "\red Overdose.."
				M.druggy = max(M.druggy, 30)
				if(prob(10)) M.emote(pick("twitch","giggle"))
				M:paralysis = max(M:paralysis, 30)
				M.hallucination = max(M.hallucination, 30)

/datum/chemical_reaction/dextromethorphan
	name = "Dextromethorphan"
	id = "dextromethorphan"
	result = "dextromethorphan"
	required_reagents = list("cryptobiolin" = 1, "hydrogen" = 1, "carbon" = 1)
	result_amount = 3
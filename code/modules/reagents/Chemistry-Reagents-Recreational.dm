/datum/reagent/antidepressant/dextromethorphan
	name = "Dextromethorphan"
	id = "dextromethorphan"
	description = "Cough medicine."
	reagent_state = LIQUID
	color = "#FF1111"
	custom_metabolism = 0.01
	data = 0
	var/message = 0

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		if(!data) data = 0
		if(!message) message = 0
		data += custom_metabolism
		switch(data + src.volume)
			if(1 to 5)
				if(message == 0)
					M << "\red Your throat feels better and you stop coughing."
					//The coughing check is made in carbon/human/emote.dm where it checks after this reagent.
					message = 1
			if(5 to 10)
				if(message < 2)
					M << "\red You feel full of strength and energy! You're getting restless!"
					message = 2
				if(prob(5)) M.emote(pick("giggle"))
			if(10 to 20)
				if(message < 3)
					M << "\red Your heartrate is racing. You feel euphoric!"
					message = 3
				M.druggy = max(M.druggy, 15)
				if(prob(5)) M.emote(pick("twitch_s", "giggle"))
			if(20 to INFINITY)
				if(message < 4)
					M << "\red Your heart is racing and your body won't respond properly. You almost feel like you're on autopilot."
					message = 4
				M.druggy = max(M.druggy, 15)
				if(prob(10)) M.emote(pick("twitch","giggle","drool"))
				if(prob(10)) M:weakened = max(M:weakened, 10)
				M.hallucination = max(M.hallucination, 5)
		..()
		return

/datum/chemical_reaction/dextromethorphan
	name = "Dextromethorphan"
	id = "dextromethorphan"
	result = "dextromethorphan"
	required_reagents = list("cryptobiolin" = 1, "hydrogen" = 1, "carbon" = 1)
	result_amount = 3

/datum/reagent/antidepressant/mdma
	name = "MDMA"
	id = "mdma"
	description = "MDMA is one of the most popular recreational psychoactives, most commonly sold in the form of 'ecstasy' tablets. It is known for its empathogenic, euphoric, and stimulant effects, and has also been used in psychotherapy."
	reagent_state = LIQUID
	color = "#EEEEEE"
	custom_metabolism = 0.01
	data = 0
	var/message = 0

/* Not finished -Mel
	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		if(!data) data = 0
		if(!message) message = 0
		data += custom_metabolism
		switch(data + src.volume)
			if(1 to 5)
				if(message == 0)
					M << "\red Your heart rate increases. Your senses all seem more amplified. You start to feel... euphoric."
					message = 1
				M.druggy = max(M.druggy, 15)
				if(prob(5)) M.emote(pick("giggle"))
			if(5 to 10)
				if(message < 2)
					M << "\red Your heart rate increases. Your senses all seem more amplified. You start to feel... euphoric."
					message = 2
				M.druggy = max(M.druggy, 15)
				if(prob(5)) M.emote(pick("giggle"))
			if(10 to 20)
				if(message < 3)
					M << "\red Your heart rate increases. Your senses all seem more amplified. You start to feel... euphoric."
					message = 3
				M.druggy = max(M.druggy, 15)
				if(prob(5)) M.emote(pick("giggle"))
			if(20 to INFINITY)
				if(message < 4)
					M << "\red That was probably too much..."
					message = 4
				M.druggy = max(M.druggy, 15)
				if(prob(10)) M.emote(pick("twitch","giggle","drool"))
				if(prob(10)) M:weakened = max(M:weakened, 10)
				M.hallucination = max(M.hallucination, 5)
		..()
		return

/datum/chemical_reaction/mdma
	name = "MDMA"
	id = "mdma"
	result = "mdma"
	required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1, "sugar" = 1)
	result_amount = 3
*/
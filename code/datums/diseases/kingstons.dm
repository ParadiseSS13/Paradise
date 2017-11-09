/datum/disease/kingstons
	name = "Kingstons"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "Milk."
	cures = list("milk")
	cure_chance = 75
	agent = "NYA Virus"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "If left untreated the subject will turn into a felonid. In felines it has..OTHER..effects."
	severity = MEDIUM

/datum/disease/kingstons/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				if(affected_mob.get_species() == "Tajaran")
					to_chat(affected_mob, "<span class='danger'>You feel good.</span>")
				else
					to_chat(affected_mob, "<span class='danger'>You feel like playing with string.</span>")
		if(2)
			if(prob(10))
				if(affected_mob.get_species() == "Tajaran")
					to_chat(affected_mob, "<span class='danger'>Something in your throat itches.</span>")
				else
					to_chat(affected_mob, "<span class='danger'>You NEED to find a mouse.</span>")
		if(3)
			if(prob(10))
				if(affected_mob.get_species() == "Tajaran")
					to_chat(affected_mob, "<span class='danger'>You feel something in your throat!.</span>")
					affected_mob.emote("cough")
				else
					affected_mob.say( pick( list("Mew", "meow", "Nya!") ) )
		if(4)
			if(prob(5))
				if(affected_mob.get_species() == "Tajaran")
					affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up a hairball!</span>", \
													"<span class='userdanger'>You cough up a hairball!</span>")
					affected_mob.Stun(5)
				else
					affected_mob.visible_message("<span class='danger'>[affected_mob] form contorts into something more feline!!</span>", \
													"<span class='userdanger'>YOU TURN INTO A TAJARAN!</span>")
					var/mob/living/carbon/human/catface = affected_mob
					catface.set_species("Tajaran")
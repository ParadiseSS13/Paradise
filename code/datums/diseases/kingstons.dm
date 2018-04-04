/datum/disease/kingstons
	name = "Kingstons Syndrome"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "Milk"
	cures = list("milk")
	cure_chance = 50
	agent = "Nya Virus"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "If left untreated the subject will turn into a feline. In felines it has... OTHER... effects."
	severity = DANGEROUS

/datum/disease/kingstons/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				if(affected_mob.get_species() == "Tajaran")
					to_chat(affected_mob, "<span class='notice'>You feel good.</span>")
				else
					to_chat(affected_mob, "<span class='notice'>You feel like playing with string.</span>")
		if(2)
			if(prob(10))
				if(affected_mob.get_species() == "Tajaran")
					to_chat(affected_mob, "<span class='danger'>Something in your throat itches.</span>")
				else
					to_chat(affected_mob, "<span class='danger'>You NEED to find a mouse.</span>")
		if(3)
			if(prob(10))
				if(affected_mob.get_species() == "Tajaran")
					to_chat(affected_mob, "<span class='danger'>You feel something in your throat!</span>")
					affected_mob.emote("cough")
				else
					affected_mob.say(pick(list("Mew", "Meow!", "Nya!~")))
		if(4)
			if(prob(5))
				if(affected_mob.get_species() == "Tajaran")
					affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up a hairball!</span>", \
													"<span class='userdanger'>You cough up a hairball!</span>")
					affected_mob.Stun(5)
				else
					affected_mob.visible_message("<span class='danger'>[affected_mob]'s form contorts into something more feline!</span>", \
													"<span class='userdanger'>YOU TURN INTO A TAJARAN!</span>")
					var/mob/living/carbon/human/catface = affected_mob
					catface.set_species("Tajaran")


/datum/disease/kingstons/advanced
	name = "Advanced Kingstons Syndrome"
	spread_text = "Airborne"
	cure_text = "Plasma"
	cures = list("plasma")
	cure_chance = 50
	agent = "AMB45DR Bacteria"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "If left untreated the subject will mutate to a different species."
	severity = BIOHAZARD
	var/list/virspecies = list("Human", "Tajaran", "Unathi", "Skrell", "Vulpkanin")//no karma races sorrys.
	var/list/virsuffix = list("pox", "rot", "flu", "cough", "-gitis", "cold", "rash", "itch", "decay")
	var/chosentype
	var/chosensuff

/datum/disease/kingstons/advanced/New()
	chosentype = pick(virspecies)
	chosensuff = pick(virsuffix)

	name = "[chosentype] [chosensuff]"

/datum/disease/kingstons/advanced/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>You feel awkward.</span>")
		if(2)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You itch.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your skin starts to flake!</span>")

		if(4)
			if(prob(5))
				if(affected_mob.get_species() != chosentype)
					affected_mob.visible_message("<span class='danger'>[affected_mob]'s skin splits and form contorts!</span>", \
													"<span class='userdanger'>Your body mutates into a [chosentype]!</span>")
					var/mob/living/carbon/human/twisted = affected_mob
					twisted.set_species(chosentype)
				else
					affected_mob.visible_message("<span class='danger'>[affected_mob] scratches at thier skin!</span>", \
													"<span class='userdanger'>You scratch your skin to try not to itch!</span>")
					affected_mob.adjustBruteLoss(-5)
					affected_mob.adjustStaminaLoss(5)
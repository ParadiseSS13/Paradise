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
				if(istajaran(affected_mob))
					to_chat(affected_mob, "<span class='notice'>You feel good.</span>")
				else
					to_chat(affected_mob, "<span class='notice'>You feel like playing with string.</span>")
		if(2)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, "<span class='danger'>Something in your throat itches.</span>")
				else
					to_chat(affected_mob, "<span class='danger'>You NEED to find a mouse.</span>")
		if(3)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, "<span class='danger'>You feel something in your throat!</span>")
					affected_mob.emote("cough")
				else
					affected_mob.say(pick(list("Mew", "Meow!", "Nya!~")))
		if(4)
			if(prob(5))
				if(istajaran(affected_mob))
					affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up a hairball!</span>", \
													"<span class='userdanger'>You cough up a hairball!</span>")
					affected_mob.Stun(5)
				else
					affected_mob.visible_message("<span class='danger'>[affected_mob]'s form contorts into something more feline!</span>", \
													"<span class='userdanger'>YOU TURN INTO A TAJARAN!</span>")
					var/mob/living/carbon/human/catface = affected_mob
					catface.set_species(/datum/species/tajaran)


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
	var/list/virspecies = list(/datum/species/human, /datum/species/tajaran, /datum/species/unathi,/datum/species/skrell, /datum/species/vulpkanin) //no karma races sorrys.
	var/list/virsuffix = list("pox", "rot", "flu", "cough", "-gitis", "cold", "rash", "itch", "decay")
	var/datum/species/chosentype
	var/chosensuff

/datum/disease/kingstons/advanced/New()
	chosentype = pick(virspecies)
	chosensuff = pick(virsuffix)

	name = "[initial(chosentype.name)] [chosensuff]"

/datum/disease/kingstons/advanced/stage_act()
	..()
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/twisted = affected_mob
		switch(stage)
			if(1)
				if(prob(10))
					to_chat(twisted, "<span class='notice'>You feel awkward.</span>")
			if(2)
				if(prob(10))
					to_chat(twisted, "<span class='danger'>You itch.</span>")
			if(3)
				if(prob(10))
					to_chat(twisted, "<span class='danger'>Your skin starts to flake!</span>")

			if(4)
				if(prob(5))
					if(!istype(twisted.dna.species, chosentype))
						twisted.visible_message("<span class='danger'>[twisted]'s skin splits and form contorts!</span>", \
														"<span class='userdanger'>Your body mutates into a [initial(chosentype.name)]!</span>")
						twisted.set_species(chosentype)
					else
						twisted.visible_message("<span class='danger'>[twisted] scratches at thier skin!</span>", \
														"<span class='userdanger'>You scratch your skin to try not to itch!</span>")
						twisted.adjustBruteLoss(-5)
						twisted.adjustStaminaLoss(5)

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
	severity = VIRUS_BIOHAZARD

/datum/disease/kingstons/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(1)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, SPAN_NOTICE("You feel good."))
				else
					to_chat(affected_mob, SPAN_NOTICE("You feel like playing with string."))
		if(2)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, SPAN_DANGER("Something in your throat itches."))
				else
					to_chat(affected_mob, SPAN_DANGER("You NEED to find a mouse."))
		if(3)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, SPAN_DANGER("You feel something in your throat!"))
					affected_mob.emote("cough")
				else
					affected_mob.say(pick("Mew", "Meow!", "Nya!~"))
		if(4)
			if(prob(5))
				if(istajaran(affected_mob))
					affected_mob.visible_message(SPAN_DANGER("[affected_mob] coughs up a hairball!"), \
													SPAN_USERDANGER("You cough up a hairball!"))
					affected_mob.Stun(10 SECONDS)
				else
					affected_mob.visible_message(SPAN_DANGER("[affected_mob]'s form contorts into something more feline!"), \
													SPAN_USERDANGER("YOU TURN INTO A TAJARAN!"))
					var/mob/living/carbon/human/catface = affected_mob
					catface.set_species(/datum/species/tajaran, retain_damage = TRUE, keep_missing_bodyparts = TRUE)

// Not a subtype of regular Kingstons as it would inherit its `stage_act()`
/datum/disease/kingstons_advanced
	name = "Advanced Kingstons Syndrome"
	medical_name = "Advanced Kingstons Syndrome"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "Plasma"
	cures = list("plasma")
	cure_chance = 50
	agent = "AMB45DR Bacteria"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "If left untreated the subject will mutate to a different species."
	severity = VIRUS_BIOHAZARD
	var/list/virspecies = list(/datum/species/human, /datum/species/tajaran, /datum/species/unathi,/datum/species/skrell, /datum/species/vulpkanin, /datum/species/diona,
		/datum/species/slime, /datum/species/kidan, /datum/species/drask, /datum/species/grey, /datum/species/moth, /datum/species/skulk) // No IPCs (not organic), or vox+plasmemes because of air requirements
	var/list/virsuffix = list("pox", "rot", "flu", "cough", "-gitis", "cold", "rash", "itch", "decay")
	var/datum/species/chosentype
	var/chosensuff

/datum/disease/kingstons_advanced/New()
	chosentype = pick(virspecies)
	chosensuff = pick(virsuffix)

	name = "[initial(chosentype.name)] [chosensuff]"

/datum/disease/kingstons_advanced/stage_act()
	if(!..())
		return FALSE
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/twisted = affected_mob
	switch(stage)
		if(1)
			if(prob(10))
				to_chat(twisted, SPAN_NOTICE("You feel awkward."))
		if(2)
			if(prob(10))
				to_chat(twisted, SPAN_DANGER("You itch."))
		if(3)
			if(prob(10))
				to_chat(twisted, SPAN_DANGER("Your skin starts to flake!"))
		if(4)
			if(!prob(5))
				return

			if(!istype(twisted.dna.species, chosentype))
				twisted.visible_message(
					SPAN_DANGER("[twisted]'s skin splits and form contorts!"),
					SPAN_USERDANGER("Your body mutates into a [initial(chosentype.name)]!")
				)
				twisted.set_species(chosentype, retain_damage = TRUE, keep_missing_bodyparts = TRUE)
				return

			twisted.visible_message(
				SPAN_DANGER("[twisted] scratches at their skin!"),
				SPAN_USERDANGER("You scratch your skin to try not to itch!")
			)
			twisted.adjustBruteLoss(5)
			twisted.adjustStaminaLoss(5)

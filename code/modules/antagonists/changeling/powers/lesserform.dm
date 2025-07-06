/datum/action/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey. Costs 5 chemicals."
	helptext = "The transformation greatly reduces our size, allowing us to slip out of cuffs and climb through vents."
	button_icon_state = "lesser_form"
	chemical_cost = 5
	dna_cost = 2
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/utility

//Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!user)
		return FALSE

	var/mob/living/carbon/human/H = user

	if(!istype(H) || !H.dna.species.primitive_form)
		to_chat(H, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return FALSE

	var/brute_damage = H.getBruteLoss() * 0.66 // To offset the 1.5 brute/burn mod that monkeys have
	var/burn_damage = H.getFireLoss() * 0.66

	H.visible_message("<span class='warning'>[H] transforms!</span>")
	to_chat(H, "<span class='warning'>Our genes cry out!</span>")
	H.flavor_text = ""
	H.monkeyize()

	H.adjustBruteLoss(brute_damage)
	H.adjustFireLoss(burn_damage)

	cling.give_power(new /datum/action/changeling/humanform)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

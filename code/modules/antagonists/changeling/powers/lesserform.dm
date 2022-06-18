/datum/action/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey. Costs 5 chemicals."
	helptext = "The transformation greatly reduces our size, allowing us to slip out of cuffs and climb through vents."
	button_icon_state = "lesser_form"
	chemical_cost = 5
	dna_cost = 1
	genetic_damage = 3
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER

//Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	if(user.has_brain_worms())
		to_chat(user, "<span class='warning'>We cannot perform this ability at the present time!</span>")
		return FALSE

	var/mob/living/carbon/human/H = user

	if(!istype(H) || !H.dna.species.primitive_form)
		to_chat(H, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return FALSE

	H.visible_message("<span class='warning'>[H] transforms!</span>")
	cling.genetic_damage = 30
	to_chat(H, "<span class='warning'>Our genes cry out!</span>")
	H.monkeyize()

	cling.give_power(new /datum/action/changeling/humanform)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

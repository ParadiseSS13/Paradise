/datum/action/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey. Costs 5 chemicals."
	helptext = "The transformation greatly reduces our size, allowing us to slip out of cuffs and climb through vents."
	button_icon_state = "lesser_form"
	power_type = CHANGELING_PURCHASABLE_POWER
	chemical_cost = 5
	genetic_damage = 33
	dna_cost = 1
	req_human = TRUE


/**
 * Transform into a monka.
 */
/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	if(user.has_brain_worms())
		to_chat(user, span_warning("Alien intelligence in our body prevents transformation!"))
		return FALSE

	if(!user.dna.species.primitive_form)
		to_chat(user, span_warning("We cannot perform this ability in this form!"))
		return FALSE

	user.visible_message(span_warning("[user] transforms!"), span_warning("Our genes cry out!"))
	remove_changeling_mutations(user)
	user.monkeyize()

	cling.give_power(new /datum/action/changeling/humanform)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE


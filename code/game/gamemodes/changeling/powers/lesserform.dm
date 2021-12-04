/datum/action/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey. Costs 5 chemicals."
	helptext = "The transformation greatly reduces our size, allowing us to slip out of cuffs and climb through vents."
	button_icon_state = "lesser_form"
	chemical_cost = 5
	dna_cost = 1
	genetic_damage = 3
	req_human = 1

// Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(var/mob/living/carbon/human/user)
	if(!user)
		return 0

	var/datum/changeling/changeling = user.mind.changeling

	if(user.has_brain_worms())
		to_chat(user, "<span class='warning'>We cannot perform this ability at the present time!</span>")
		return

	if(!istype(user) || !user.dna.species.primitive_form)
		to_chat(user, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return

	user.visible_message("<span class='warning'>[user] transforms!</span>")

	// Add genetic damage to add cooldown.
	changeling.geneticdamage = 30

	to_chat(user, "<span class='warning'>Our genes cry out!</span>")
	user.monkeyize()

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return 1


// Grant human form on purchase. Required to humanize if monkeyized using DNA-Injector.
/datum/action/changeling/lesserform/on_purchase(var/mob/user)
	..()
	var/datum/changeling/changeling = user.mind.changeling

	var/datum/action/changeling/humanform/HF = new
	changeling.purchasedpowers += HF
	HF.Grant(user)

	return

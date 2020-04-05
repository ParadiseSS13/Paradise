/datum/action/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey. Costs 5 chemicals."
	helptext = "The transformation greatly reduces our size, allowing us to slip out of cuffs and climb through vents."
	button_icon_state = "lesser_form"
	chemical_cost = 5
	dna_cost = 1
	genetic_damage = 3
	req_human = 1

//Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(var/mob/living/carbon/human/user)
	var/datum/changeling/changeling = user.mind.changeling
	if(!user)
		return 0
	if(user.has_brain_worms())
		to_chat(user, "<span class='warning'>We cannot perform this ability at the present time!</span>")
		return

	var/mob/living/carbon/human/H = user

	if(!istype(H) || !H.dna.species.primitive_form)
		to_chat(H, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return

	H.visible_message("<span class='warning'>[H] transforms!</span>")
	changeling.geneticdamage = 30
	to_chat(H, "<span class='warning'>Our genes cry out!</span>")
	H.monkeyize()

	var/datum/action/changeling/humanform/HF = new
	changeling.purchasedpowers += HF
	HF.Grant(user)

	feedback_add_details("changeling_powers","LF")
	return 1

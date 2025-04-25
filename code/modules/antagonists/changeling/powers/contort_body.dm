/datum/action/changeling/contort_body
	name = "Contort Body"
	desc = "We contort our body, allowing us to fit in and under things we normally wouldn't be able to. Costs 25 chemicals."
	button_overlay_icon_state = "contort_body"
	chemical_cost = 25
	dna_cost = 4
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/utility
	var/organ_quality = ORGAN_NORMAL

/datum/action/changeling/contort_body/xenobiology
	desc = "We contort our body, allowing us to fit in and under things we normally wouldn't be able to."
	chemical_cost = 0
	var/cooldown = 5 MINUTES
	var/next_activation = 0

/datum/action/changeling/contort_body/Remove(mob/M)
	deactivate()
	..()

/datum/action/changeling/contort_body/sting_action(mob/living/user)
	if(HAS_TRAIT_FROM(user, TRAIT_CONTORTED_BODY, CHANGELING_TRAIT))
		deactivate(user)
		return TRUE

	ADD_TRAIT(user, TRAIT_CONTORTED_BODY, CHANGELING_TRAIT)
	RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(deactivate))
	to_chat(user, "<span class='notice'>We contort our form to allow us to fit in and under things we normally wouldn't be able to.</span>")
	if(IS_HORIZONTAL(user))
		user.layer = TURF_LAYER + 0.2

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/contort_body/proc/deactivate(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_CONTORTED_BODY))
		return
	REMOVE_TRAIT(user, TRAIT_CONTORTED_BODY, CHANGELING_TRAIT)
	UnregisterSignal(user, COMSIG_MOB_DEATH)
	if(IS_HORIZONTAL(user))
		user.layer = initial(user.layer)
	to_chat(user, "<span class='notice'>Our body stiffens and returns to form.</span>")
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))

/datum/action/changeling/contort_body/xenobiology/sting_action(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_CONTORTED_BODY))
		deactivate(user)
		return TRUE
	if(next_activation >= world.time)
		to_chat(user, "<span class='warning'>We're too tired and sore to contort again so soon!</span>")
		return TRUE
	if(organ_quality == ORGAN_DAMAGED)
		if(prob(100))
			var/obj/item/organ/external/limb_to_break = pick(user.bodyparts)
			limb_to_break.fracture()
	var/duration = 30 SECONDS
	if(organ_quality == ORGAN_PRISTINE)
		duration = 1 MINUTES
	next_activation = world.time + cooldown
	addtimer(CALLBACK(src, PROC_REF(deactivate), user), duration)
	. = ..()


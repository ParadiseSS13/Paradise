/datum/action/changeling/environmental_adaptation
	name = "Environmental Adaptation"
	desc = "Our skin pigmentations rapidly change to suit the environment around us. Needs 10 chemicals in-storage to toggle. Slows down our chemical regeneration by 15%"
	helptext = "Allows us to darken and change the translucency of our pigmentation. \
	The translucent effect works best in dark environments and garments. Can be toggled on and off."
	button_icon_state = "enviro_adaptation"
	dna_cost = 2
	chemical_cost = 10
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/utility

	req_human = TRUE
	//// is ability active (we are invisible)?
	var/is_active = FALSE
	/// How much we slow chemical regeneration while active, in chems per second
	var/recharge_slowdown = 0.15
	var/chem_recharge_slowdown = 0

/datum/action/changeling/environmental_adaptation/Destroy(force, ...)
	if(ishuman(cling.owner.current))
		var/mob/living/carbon/human/H = cling.owner.current
		H.set_alpha_tracking(ALPHA_VISIBLE, src)
	return ..()

/datum/action/changeling/environmental_adaptation/sting_action(mob/living/carbon/human/cling) //SHOULD always be human, because req_human = TRUE
	..()
	is_active = !is_active
	if(is_active)
		enable_ability(cling)
	else
		disable_ability(cling)


/datum/action/changeling/environmental_adaptation/proc/enable_ability(mob/living/carbon/human/cling) //Enable the adaptation
	cling.set_alpha_tracking(65, src, update_alpha = FALSE)
	animate(cling, alpha = cling.get_alpha(), time = 3 SECONDS)
	cling.visible_message("<span class='warning'>[cling]'s skin suddenly starts becoming translucent!</span>", \
					"<span class='notice'>We adapt our pigmentation to suit the environment around us.</span>")
	var/datum/antagonist/changeling/changeling_data = cling.mind?.has_antag_datum(/datum/antagonist/changeling)
	changeling_data?.chem_recharge_slowdown -= recharge_slowdown //Slows down chem regeneration

/datum/action/changeling/environmental_adaptation/proc/disable_ability(mob/living/carbon/human/cling) //Restore the adaptation
	cling.set_alpha_tracking(ALPHA_VISIBLE, src, update_alpha = FALSE)
	animate(cling, alpha = cling.get_alpha(), time = 3 SECONDS)
	cling.visible_message(
		"<span class='warning'>[cling] appears from thin air!</span>",
		"<span class='notice'>We stop concentration on our pigmentation, allowing it to return to normal.</span>",
	)
	animate(cling, color = null, time = 3 SECONDS)
	var/datum/antagonist/changeling/changeling_data = cling.mind?.has_antag_datum(/datum/antagonist/changeling)
	changeling_data?.chem_recharge_slowdown += recharge_slowdown

/datum/action/changeling/darkness_adaptation
	name = "Darkness Adaptation"
	desc = "Our skin pigmentation and eyes rapidly changes to suit the darkness. Needs 10 chemicals in-storage to toggle. Slows down our chemical regeneration by 15%"
	helptext = "Allows us to darken and change the translucency of our pigmentation, and adapt our eyes to see in dark conditions, \
	The translucent effect works best in dark enviroments and garments. Can be toggled on and off."
	button_icon_state = "darkness_adaptation"
	dna_cost = 2
	chemical_cost = 10
	recharge_slowdown = 0
	category = /datum/changeling_power_category/utility

	req_human = TRUE
	//// is ability active (we are invisible)?
	var/is_active = FALSE
	/// How much we slow chemical regeneration while active, in chems per second
	var/recharge_slowdown = 0.15

/datum/action/changeling/darkness_adaptation/sting_action(mob/living/carbon/human/cling) //SHOULD always be human, because req_human = TRUE
	..()
	is_active = !is_active
	if(is_active)
		enable_ability(cling)
	else
		disable_ability(cling)


/datum/action/changeling/darkness_adaptation/proc/enable_ability(mob/living/carbon/human/cling) //Enable the adaptation
	animate(cling, alpha = 65,time = 3 SECONDS)
	cling.visible_message("<span class='warning'>[cling]'s skin suddenly starts becoming translucent!</span>", \
					"<span class='notice'>We are now far more stealthy and better at seeing in the dark.</span>")
	var/datum/antagonist/changeling/changeling_data = cling.mind?.has_antag_datum(/datum/antagonist/changeling)
	changeling_data?.chem_recharge_slowdown -= recharge_slowdown //Slows down chem regeneration

/datum/action/changeling/darkness_adaptation/proc/disable_ability(mob/living/carbon/human/cling) //Restore the adaptation
	animate(cling, alpha = 255, time = 3 SECONDS)
	cling.visible_message(
		"<span class='warning'>[cling] appears from thin air!</span>",
		"<span class='notice'>We are now appearing normal and lost the ability to see in the dark.</span>",
	)
	animate(cling, color = null, time = 3 SECONDS)
	var/datum/antagonist/changeling/changeling_data = cling.mind?.has_antag_datum(/datum/antagonist/changeling)
	changeling_data?.chem_recharge_slowdown += recharge_slowdown()

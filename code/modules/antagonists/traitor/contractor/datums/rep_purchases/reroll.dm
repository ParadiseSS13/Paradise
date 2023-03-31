/**
  * # Rep Purchase - Contract Reroll
  */
/datum/rep_purchase/reroll
	name = "Contract Reroll"
	description = "Replaces your inactive contracts with new ones, containing a new target and extraction zones."
	cost = 2

/datum/rep_purchase/reroll/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	var/eligible = FALSE
	for(var/c in hub.contracts)
		var/datum/syndicate_contract/C = c
		if(C.status == CONTRACT_STATUS_INACTIVE)
			eligible = TRUE
			break
	if(!eligible)
		to_chat(user, "<span class='warning'>There are no inactive contracts that can be rerolled.</span>")
		return FALSE
	return ..()

/datum/rep_purchase/reroll/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	..()
	var/changed = 0
	for(var/c in hub.contracts)
		var/datum/syndicate_contract/C = c
		if(C.status == CONTRACT_STATUS_INACTIVE && C.generate())
			changed++
	hub.contractor_uplink?.message_holder("Agent, we have replaced [changed] contract\s with new ones.")

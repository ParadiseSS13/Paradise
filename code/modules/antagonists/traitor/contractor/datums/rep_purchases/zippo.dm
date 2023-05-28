/**
  * # Rep Purchase - Contractor Zippo Lighter
  */
/datum/rep_purchase/item/zippo
	name = "Contractor Zippo Lighter"
	description = "An unique black and gold zippo lighter with no purpose other than showing off. You must complete all your contracts in order to buy this."
	cost = 0
	stock = 1
	item_type = /obj/item/lighter/zippo/contractor

/datum/rep_purchase/item/zippo/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	var/eligible = TRUE
	for(var/c in hub.contracts)
		var/datum/syndicate_contract/C = c
		if(C.status != CONTRACT_STATUS_COMPLETED)
			eligible = FALSE
			break
	if(!eligible)
		to_chat(user, "<span class='warning'>All of your contracts must be completed to be eligible for this item.</span>")
		return FALSE
	return ..()

/obj/item/lighter/zippo/contractor
	name = "contractor zippo lighter"
	desc = "An unique black and gold zippo commonly carried by elite Syndicate agents."
	icon_state = "contractorzippo"
	item_state = "contractorzippo"
	icon_on = "contractorzippoon"
	icon_off = "contractorzippo"

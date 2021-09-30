/**
  * # Rep Purchase - Contractor Balloon
  */
/datum/rep_purchase/item/balloon
	name = "Contractor Balloon"
	description = "An unique black and gold balloon with no purpose other than showing off. All contracts must be completed in the hardest location to unlock this."
	cost = 12
	stock = 1
	item_type = /obj/item/toy/syndicateballoon/contractor

/datum/rep_purchase/item/balloon/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	var/eligible = TRUE
	for(var/c in hub.contracts)
		var/datum/syndicate_contract/C = c
		if(C.status != CONTRACT_STATUS_COMPLETED || C.chosen_difficulty != EXTRACTION_DIFFICULTY_HARD)
			eligible = FALSE
			break
	if(!eligible)
		to_chat(user, "<span class='warning'>All of your contracts must be completed in the hardest location to be eligible for this item.</span>")
		return FALSE
	return ..()

/obj/item/toy/syndicateballoon/contractor
	name = "contractor balloon"
	desc = "A black and gold balloon carried only by legendary Syndicate agents."
	icon_state = "contractorballoon"
	item_state = "contractorballoon"

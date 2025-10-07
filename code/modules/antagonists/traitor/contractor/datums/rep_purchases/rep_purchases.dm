/**
  * # Rep Purchases MARK: Tools
  */
/datum/rep_purchase/item/baton
	name = "Replacement Contractor Baton"
	description = "A compact, specialised baton issued to Syndicate contractors. Applies light electrical shocks to targets. Never know when you will get disarmed."
	cost = 2
	stock = 2
	item_type = /obj/item/melee/classic_baton/telescopic/contractor

/datum/rep_purchase/item/fulton
	name = "Fulton Extraction Kit"
	description = "A balloon that can be used to extract equipment or personnel to a Fulton Recovery Beacon. Anything not bolted down can be moved. Link the pack to a beacon by using the pack in hand. Beacon can be placed inside the station, but the Fulton will not work inside the station."
	cost = 1
	stock = 1
	item_type = /obj/item/storage/box/syndie_kit/fulton_kit

/obj/item/storage/box/syndie_kit/fulton_kit
	name = "fulton extraction kit"

/obj/item/storage/box/syndie_kit/fulton_kit/populate_contents()
	new /obj/item/extraction_pack(src)
	new /obj/item/fulton_core(src)

/datum/rep_purchase/item/flare
	name = "Emergency extraction kit"
	description = "A kit that comes with an emergency escape flare, which will allow you to teleport to any beacon after a short activation delay. Also comes with a Syndicate teleporter beacon that only these flares and emagged teleporters can target."
	cost = 2
	stock = 3
	item_type = /obj/item/storage/box/syndie_kit/escape_flare

/datum/rep_purchase/item/pinpointer
	name = "Contractor Pinpointer"
	description = "A low accuracy pinpointer that can track anyone in the sector without the need for suit sensors. Can only be used by the first person to activate it."
	cost = 1
	stock = 2
	item_type = /obj/item/pinpointer/crew/contractor

/**
  * # Rep Purchase MARK: Assorted Badassery
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

/datum/rep_purchase/item/zippo
	name = "Contractor Zippo Lighter"
	description = "An unique black and gold zippo lighter with no purpose other than showing off."
	cost = 12
	stock = 1
	item_type = /obj/item/lighter/zippo/contractor

/obj/item/lighter/zippo/contractor
	name = "contractor zippo lighter"
	desc = "An unique black and gold zippo commonly carried by elite Syndicate agents."
	icon_state = "zippo-contractor"
	inhand_icon_state = "zippo-black"

/**
  * # Rep Purchase MARK: Actions
  */
/datum/rep_purchase/blackout
	name = "Blackout"
	description = "Overloads the station's power net, shorting random APCs."
	cost = 3
	// Settings
	/// How long a contractor must wait before calling another blackout, in deciseconds.
	var/static/cooldown = 45 MINUTES
	// Variables
	/// Static cooldown variable for blackouts.
	var/static/next_blackout = -1

/datum/rep_purchase/blackout/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	if(next_blackout > world.time)
		var/timeleft = (next_blackout - world.time) / 10
		to_chat(user, "<span class='warning'>Another blackout may not be requested for [seconds_to_clock(timeleft)].</span>")
		return FALSE
	return ..()

/datum/rep_purchase/blackout/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	..()
	next_blackout = world.time + cooldown
	power_failure()

/datum/rep_purchase/reroll
	name = "Contract Reroll"
	description = "Replaces your inactive contracts with new ones, containing a new target and extraction zones."
	cost = 2

/datum/rep_purchase/reroll/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	var/eligible = FALSE
	for(var/datum/syndicate_contract/C as anything in hub.contracts)
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
	for(var/datum/syndicate_contract/C as anything in hub.contracts)
		if(C.status == CONTRACT_STATUS_INACTIVE && C.generate())
			changed++
	hub.contractor_uplink?.message_holder("Agent, we have replaced [changed] contract\s with new ones.")



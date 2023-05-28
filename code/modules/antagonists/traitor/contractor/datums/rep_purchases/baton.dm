/**
  * # Rep Purchase - Contractor Baton and upgrades
  */
/datum/rep_purchase/item/baton
	name = "Replacement Contractor Baton"
	description = "A compact, specialised baton issued to Syndicate contractors. Applies light electrical shocks to targets. Never know when you will get disarmed."
	cost = 2
	stock = 2
	item_type = /obj/item/melee/classic_baton/telescopic/contractor

/datum/rep_purchase/item/baton_cuffup
	name = "Baton Cuff Upgrade"
	description = "Using technology reverse-engineered from some alien batons we had lying around, you can now cuff people using your baton. Due to technical limitations, only cable cuffs work, and they need to be loaded into the baton manually."
	cost = 2
	stock = 1
	item_type = /obj/item/baton_upgrade/cuff

/datum/rep_purchase/item/baton_muteup
	name = "Baton Mute Upgrade"
	description = "A relatively new advancement in completely proprietary baton technology, this baton upgrade will mute anyone hit for about five seconds."
	cost = 2
	stock = 1
	item_type = /obj/item/baton_upgrade/mute

/datum/rep_purchase/item/baton_focusup //avote said to remove this
	name = "Baton Focus Upgrade"
	description = "When applied to a baton, it will exhaust the target even more, should they be the target of your current contract."
	cost = 2
	stock = 1
	item_type = /obj/item/baton_upgrade/focus

/datum/rep_purchase/item/baton_antidropup
	name = "Baton Antidrop Upgrade"
	description = "An experimental and extremely undertested technology that activates a system of spikes that burrow into the skin when user extends baton, preventing the user to drop it. That will hurt.."
	cost = 2
	stock = 1
	item_type = /obj/item/baton_upgrade/antidrop

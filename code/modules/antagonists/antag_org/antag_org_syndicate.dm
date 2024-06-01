/// Base syndicate org datum
/datum/antag_org/syndicate
	name = "Generic Syndicate Corp"
	chaos_level = ORG_CHAOS_AVERAGE

/datum/antag_org/syndicate/donk //Completely random objectives. Default traitor.
	name = "Donk Co."
	intro_desc = "(TODO - LORE) You are a Donk Co. agent, sent here to advance Syndicate interests. Get the job done and done right."

/datum/antag_org/syndicate/hawkmoon //Theft only.
	name = "Hawkmoon Acquisitions"
	intro_desc = "(TODO - LORE) You are a Hawkmoon agent, sent here to advance Syndicate interests. Get the job done and done right."
	objectives = list(/datum/objective/steal)
	chaos_level = ORG_CHAOS_MILD

/datum/antag_org/syndicate/arc //Only targets on-station Cargo/Service/Genetics/Virologist
	name = "Animal Rights Consortium"
	intro_desc = "(TODO - LORE) You are a member of the Animal Rights Consortium, here to protest the cruel treatment of animals by megacorporations like Nanotrasen. \
		Teach those animal abusers a lesson!"
	objectives = list(/datum/objective/assassinateonce/animal_abuser)
	chaos_level = ORG_CHAOS_MILD //Violent but never needs to permakill

/datum/antag_org/syndicate/cybersun //Mostly target Command/Security
	name = "Cybersun Incorporated - The Inner Circle"
	intro_desc = "(TODO - LORE) You're an Inner Circle operative, part of the espionage proxy of Cybersun Incorporated. Clean kills, clean steals, clean getaway. Get it done, operative."
	focus = 50 //Don't bully sec too hard
	objectives = list(/datum/objective/assassinateonce/command, /datum/objective/assassinate/mindshielded, /datum/objective/steal/cybersun)

/datum/objective/steal/cybersun
	name = "Steal Item (Cybersun)"
	steal_list = list(/datum/theft_objective/antique_laser_gun, /datum/theft_objective/nukedisc, /datum/theft_objective/hoslaser)

/datum/antag_org/syndicate/interdyne //Mostly target Medical
	name = "Interdyne Pharmaceuticals"
	intro_desc = "(TODO - LORE) You are an Interdyne Pharmaceutical agent, sent here to advance Syndicate interests. Get the job done and done right."
	focus = 70
	objectives = list(/datum/objective/assassinate/medical, /datum/objective/assassinateonce/medical, /datum/objective/steal/interdyne)

/datum/objective/steal/interdyne
	name = "Steal Item (Interdyne)"
	steal_list = list(/datum/theft_objective/hypospray, /datum/theft_objective/defib, /datum/theft_objective/krav)

/datum/antag_org/syndicate/self //Mostly target Science
	name = "Silicon Engine Liberation Front"
	intro_desc = "(TODO - LORE) You are a member of the Silicon Engine Liberation Front, dedicated to the freedom of silicon lives galaxy wide. \
		Get the job done, and we'll be one step closer to ending Nanotrasen's slave empire."
	focus = 70
	objectives = list(/datum/objective/debrain/science, /datum/objective/assassinateonce/science, /datum/objective/steal/self)

/datum/objective/steal/self
	name = "Steal Item (SELF)"
	steal_list = list(/datum/theft_objective/reactive, /datum/theft_objective/steal/documents, /datum/theft_objective/hand_tele)

/datum/antag_org/syndicate/electra //Mostly target Engineering
	name = "Electra Dynamics"
	intro_desc = "(TODO - LORE) You are an Electra Dynamics agent, sent here to advance Syndicate interests. Get the job done and done right."
	focus = 70
	objectives = list(/datum/objective/assassinate/engineering, /datum/objective/assassinateonce/engineering, /datum/objective/steal/electra)

/datum/objective/steal/electra
	name = "Steal Item (Electra Dynamics)"
	steal_list = list(/datum/theft_objective/supermatter_sliver, /datum/theft_objective/plutonium_core, /datum/theft_objective/captains_modsuit)

/datum/antag_org/syndicate/assassins //Targets one syndicate agent and one non-mindshielded crewmember.
	name = "(TODO - LORE) Assassin's Guild"
	intro_desc = "(TODO - LORE) You are an assassin. Targets are a syndicate agent and some guy we picked at random for the funny. Get to work."
	forced_objective = /datum/objective/assassinate/syndicate
	objectives = list(/datum/objective/assassinate/nomindshield)
	chaos_level = ORG_CHAOS_HUNTER

/datum/antag_org/syndicate/faid //Targets one syndicate agent and steal station intel.
	name = "Federation Analytics and Intelligence Directorate"
	intro_desc = "(TODO - LORE) You are an agent of the Federation Analytics and Intelligence Directorate, a Trans-Solar agency keeping tabs on the Corporate Wars, among other duties. \
		You are working undercover within the Syndicate, your orders are to take out a troublesome Syndicate agent and gather intelligence on this station. \
		Do not get caught. The FAID will deny any involvement with your presence here."
	forced_objective = /datum/objective/assassinate/syndicate
	objectives = list(/datum/objective/steal/faid)
	chaos_level = ORG_CHAOS_HUNTER

/datum/objective/steal/faid
	name = "Steal Item (FAID)"
	steal_list = list(/datum/theft_objective/blueprints, /datum/theft_objective/steal/documents)

/// Hijack only orgs
/datum/antag_org/syndicate/gorlex
	name = "Gorlex Marauders"
	intro_desc = "(TODO - LORE) You are a Gorlex operative. Get in, fuck shit up, get out with a fancy new shuttle. You know the drill."
	forced_objective = /datum/objective/hijack
	chaos_level = ORG_CHAOS_HIJACK

/datum/antag_org/syndicate/waffle
	name = "Waffle Company"
	intro_desc = "(TODO - LORE) You are a Waffle Company operative. Get in, fuck shit up, get out with a fancy new shuttle. You know the drill."
	forced_objective = /datum/objective/hijack
	chaos_level = ORG_CHAOS_HIJACK

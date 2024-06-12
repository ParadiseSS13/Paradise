/// Base syndicate org datum
/datum/antag_org/syndicate
	name = "Generic Syndicate Corp"
	chaos_level = ORG_CHAOS_AVERAGE

/datum/antag_org/syndicate/donk //Completely random objectives, default traitor
	name = "Donk Co."
	intro_desc = "You are a Donk Co. agent, sent here to advance Syndicate interests. \
		Current client is anonymous. Standard rules of engagement apply. Get the job done, and get it done right."

/datum/antag_org/syndicate/hawkmoon //Theft only
	name = "Hawkmoon Acquisitions"
	intro_desc = "You are an incursion specialist from the Hawkmoon Acquisitions Corporation, a merchandising firm using less-than-legal methods of product procurement. \
		Grab the goods, keep it quiet, leave no trace. We were never here."
	objectives = list(/datum/objective/steal)
	chaos_level = ORG_CHAOS_MILD

/datum/antag_org/syndicate/arc //Only targets on-station Cargo/Service/Genetics/Virologist
	name = "Animal Rights Consortium"
	intro_desc = "You are a member of the Animal Rights Consortium, here to violently protest the cruel treatment of animals by megacorporations like Nanotrasen. \
		Teach those animal abusers a lesson!"
	objectives = list(/datum/objective/assassinateonce/animal_abuser)
	chaos_level = ORG_CHAOS_MILD //Violent but never needs to permakill

/datum/antag_org/syndicate/waffle //Assassination variants only
	name = "Waffle Company"
	intro_desc = "You are a contract killer under the employ of Waffle Co., a ruthless criminal entity that will go after any target, for the right price. \
	Got a few new bounties on the docket, agent. Put 'em down however you see fit."
	objectives = list(/datum/objective/assassinate, /datum/objective/assassinateonce, /datum/objective/maroon)

/datum/antag_org/syndicate/cybersun //Mostly target Command/Security
	name = "Cybersun Incorporated - The Inner Circle"
	intro_desc = "You're an operative of Cybersun Incorporated's Inner Circle, an elite PMC and proxy arm of the company. \
		Clean kills, clean thefts, clean getaway. Get it done, operative."
	focus = 50 //Don't bully sec too hard
	objectives = list(/datum/objective/assassinateonce/command, /datum/objective/assassinate/mindshielded, /datum/objective/steal/cybersun)

/datum/objective/steal/cybersun
	name = "Steal Item (Cybersun)"
	steal_list = list(/datum/theft_objective/antique_laser_gun, /datum/theft_objective/nukedisc, /datum/theft_objective/hoslaser)

/datum/antag_org/syndicate/interdyne //Mostly target Medical
	name = "Interdyne Pharmaceuticals"
	intro_desc = "You are a specialist from Interdyne Pharmaceuticals, a medical conglomerate threatened by Nanotrasen's recent forays into the medical field. \
		Nanotrasen's medical wing has been a bit too comfortable recently. Keep 'em on their toes, specialist."
	focus = 70
	objectives = list(/datum/objective/assassinate/medical, /datum/objective/assassinateonce/medical, /datum/objective/steal/interdyne)

/datum/objective/steal/interdyne
	name = "Steal Item (Interdyne)"
	steal_list = list(/datum/theft_objective/hypospray, /datum/theft_objective/defib, /datum/theft_objective/krav)

/datum/antag_org/syndicate/self //Mostly target Science
	name = "Silicon Engine Liberation Front"
	intro_desc = "You are a member of the Silicon Engine Liberation Front, dedicated to the freedom of silicon and robotic lives sector-wide. \
		Get the job done, and we'll be one step closer to ending Nanotrasen's slave empire."
	focus = 70
	objectives = list(/datum/objective/debrain/science, /datum/objective/assassinateonce/science, /datum/objective/steal/self)

/datum/objective/steal/self
	name = "Steal Item (SELF)"
	steal_list = list(/datum/theft_objective/reactive, /datum/theft_objective/steal/documents, /datum/theft_objective/hand_tele)

/datum/antag_org/syndicate/electra //Mostly target Engineering
	name = "Electra Dynamics"
	intro_desc = "You are a saboteur employed by Electra Dynamics, an independent energy company opposed to Nanotrasen. \
		Nanotrasen's burgeoning monopoly must be stopped. We've transmitted you local points of failure, ensure they fail."
	focus = 70
	objectives = list(/datum/objective/assassinate/engineering, /datum/objective/assassinateonce/engineering, /datum/objective/steal/electra)

/datum/objective/steal/electra
	name = "Steal Item (Electra Dynamics)"
	steal_list = list(/datum/theft_objective/supermatter_sliver, /datum/theft_objective/plutonium_core, /datum/theft_objective/captains_modsuit)

/datum/antag_org/syndicate/spiderclan //Targets one syndicate agent and one non-mindshielded crewmember.
	name = "Spider Clan"
	intro_desc = "You are an initiate of the elusive Spider Clan, an insular cult of assassins and rogues styling themselves after ancient ninjas from Earth. \
		This is your final test, Initiate. Terminate the selected targets by any means necessary and you will have earned your place within the Clan."
	forced_objective = /datum/objective/assassinate/syndicate
	objectives = list(/datum/objective/assassinate/nomindshield)
	chaos_level = ORG_CHAOS_HUNTER

/datum/antag_org/syndicate/faid //Targets one syndicate agent and steal station intel.
	name = "Federation Analytics and Intelligence Directorate"
	intro_desc = "You are an undercover agent of the Federation Analytics and Intelligence Directorate, a Trans-Solar agency keeping tabs on the Corporate Wars, among other duties. \
		Be quick, be efficient, and don't get caught. The Directorate will deny any involvement with your presence here."
	forced_objective = /datum/objective/assassinate/syndicate
	objectives = list(/datum/objective/steal/faid)
	chaos_level = ORG_CHAOS_HUNTER

/datum/objective/steal/faid
	name = "Steal Item (FAID)"
	steal_list = list(/datum/theft_objective/blueprints, /datum/theft_objective/steal/documents)

/datum/antag_org/syndicate/gorlex //Hijack only
	name = "Gorlex Marauders"
	intro_desc = "You are an operative of the infamous Gorlex Marauders, a brutal and merciless gang of pirates and cutthroats. \
		Get in, fuck shit up, get out with a fancy new shuttle. You know the drill."
	forced_objective = /datum/objective/hijack
	chaos_level = ORG_CHAOS_HIJACK

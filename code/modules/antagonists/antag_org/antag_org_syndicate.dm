/// Base syndicate org datum
/datum/antag_org/syndicate
	name = "Buggy Syndicate Corp, ahelp this please"
	chaos_level = ORG_CHAOS_AVERAGE

/datum/antag_org/syndicate/donk // Completely random objectives, default traitor
	name = "Donk Co."
	intro_desc = "You are a Donk Co. agent, sent here to advance Syndicate interests. \
		Current client is anonymous. Standard rules of engagement apply. Get the job done, and get it done right."

/datum/antag_org/syndicate/hawkmoon // Theft only
	name = "Hawkmoon Acquisitions"
	intro_desc = "You are an incursion specialist from the Hawkmoon Acquisitions Corporation, a merchandising firm using less-than-legal methods of product procurement. \
		Grab the goods, keep it quiet, leave no trace. We were never here."
	objectives = list(/datum/objective/steal)
	chaos_level = ORG_CHAOS_MILD

/datum/antag_org/syndicate/arc // Only targets on-station Cargo/Service/Genetics/Virologist
	name = "Animal Rights Consortium"
	intro_desc = "You are a member of the Animal Rights Consortium, here to violently protest the cruel treatment of animals by megacorporations like Nanotrasen. \
		Teach them a lesson!"
	objectives = list(/datum/objective/assassinateonce/arc)
	chaos_level = ORG_CHAOS_MILD // Violent but never needs to permakill

/datum/antag_org/syndicate/waffle // Assassination variants only
	name = "Waffle Company"
	intro_desc = "You are a contract killer under the employ of Waffle Co., a ruthless criminal entity that will go after any target, for the right price. \
	Got a few new bounties on the docket, agent. Put 'em down however you see fit."
	objectives = list(/datum/objective/assassinate, /datum/objective/assassinateonce, /datum/objective/maroon)

/datum/antag_org/syndicate/cybersun // Mostly target Command/Security
	name = "Cybersun Incorporated - The Inner Circle"
	intro_desc = "You're an operative of Cybersun Incorporated's Inner Circle, an elite PMC and proxy arm of the company. \
		Clean kills, clean thefts, clean getaway. Get it done, operative."
	focus = 50 // Don't bully sec too hard
	targeted_departments = list(DEPARTMENT_COMMAND, DEPARTMENT_SECURITY)
	theft_targets = list(
		/datum/theft_objective/antique_laser_gun,
		/datum/theft_objective/nukedisc,
		/datum/theft_objective/hoslaser,
		/datum/theft_objective/captains_saber,
		/datum/theft_objective/capmedal
	)

/datum/antag_org/syndicate/interdyne // Mostly target Medical
	name = "Interdyne Pharmaceuticals"
	intro_desc = "You are a specialist from Interdyne Pharmaceuticals, a medical conglomerate threatened by Nanotrasen's recent forays into the medical field. \
		Nanotrasen's medical wing has been a bit too comfortable recently. Keep 'em on their toes, specialist."
	focus = 70
	targeted_departments = list(DEPARTMENT_MEDICAL)
	theft_targets = list(/datum/theft_objective/hypospray, /datum/theft_objective/defib, /datum/theft_objective/krav, /datum/theft_objective/engraved_dusters)

/datum/antag_org/syndicate/self // Mostly target Science
	name = "Silicon Engine Liberation Front"
	intro_desc = "You are a member of the Silicon Engine Liberation Front, dedicated to the freedom of silicon and robotic lives sector-wide. \
		Get the job done, and we'll be one step closer to ending Nanotrasen's slave empire."
	focus = 70
	targeted_departments = list(DEPARTMENT_SCIENCE)
	theft_targets = list(/datum/theft_objective/reactive, /datum/theft_objective/documents, /datum/theft_objective/hand_tele, /datum/theft_objective/anomalous_particulate)

/datum/antag_org/syndicate/electra // Mostly target Engineering
	name = "Electra Dynamics"
	intro_desc = "You are a saboteur employed by Electra Dynamics, an independent energy company opposed to Nanotrasen. \
		Nanotrasen's burgeoning monopoly must be stopped. We've transmitted you local points of failure, ensure they fail."
	focus = 70
	targeted_departments = list(DEPARTMENT_ENGINEERING)
	theft_targets = list(/datum/theft_objective/supermatter_sliver, /datum/theft_objective/plutonium_core, /datum/theft_objective/captains_modsuit, /datum/theft_objective/magboots, /datum/theft_objective/anomalous_particulate)

/datum/antag_org/syndicate/spiderclan // Targets one syndicate agent and one non-mindshielded crewmember.
	name = "Spider Clan"
	intro_desc = "You are an initiate of the elusive Spider Clan, an insular cult of assassins and rogues styling themselves after ancient ninjas from Earth. \
		This is your final test, Initiate. Terminate the selected targets by any means necessary, and you will have earned your place within the Clan."
	forced_objectives = list(/datum/objective/assassinate/syndicate, /datum/objective/assassinate/nomindshield)
	chaos_level = ORG_CHAOS_HUNTER

/datum/antag_org/syndicate/faid // Targets one syndicate agent and steal station intel.
	name = "Federation Analytics and Intelligence Directorate"
	intro_desc = "You are an undercover agent of the Federation Analytics and Intelligence Directorate, a Trans-Solar agency keeping tabs on the Corporate Wars, among other duties. \
		Be quick, be efficient, and don't get caught. The Directorate will deny any involvement with your presence here."
	forced_objectives = list(/datum/objective/assassinate/syndicate, /datum/objective/steal)
	theft_targets = list(/datum/theft_objective/blueprints, /datum/theft_objective/documents)
	chaos_level = ORG_CHAOS_HUNTER

/datum/antag_org/syndicate/gorlex // Hijack only
	name = "Gorlex Marauders"
	intro_desc = "You are an operative of the infamous Gorlex Marauders, a brutal and merciless gang of pirates and cutthroats. \
		Get in, fuck shit up, get out with a fancy new shuttle. You know the drill."
	forced_objectives = list(/datum/objective/hijack)
	chaos_level = ORG_CHAOS_HIJACK

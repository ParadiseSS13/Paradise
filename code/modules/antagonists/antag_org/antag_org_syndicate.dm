/// Base syndicate org, can be selected to have 'vanilla' traitor with no changes.
/datum/antag_org/syndicate
	name = "Donk Co."
	desc = "(TODO - LORE) Rivals of Waffle Company, the two groups usually have an uneasy truce when operating in NT territory. \
		Donk Co. supplies a wide variety of goods to the Syndicate."
	intro_desc = "(TODO - LORE) You are a Donk Co. agent, sent here to advance Syndicate interests. Get the job done and done right."
	focus = 80
	difficulty = "Medium"
	chaos_level = ORG_CHAOS_AVERAGE
	selectable = TRUE

/datum/antag_org/syndicate/thieves
	name = "(TODO - LORE) Voxxy Looting Club"
	desc = "(TODO - LORE) Get shinies yaya"
	intro_desc = "(TODO - LORE) YOU IS VOXXY LOOTING CLUB! SKREEE GO GO GO WHAT IS YOU WAITINGS FOR?!"
	focus = 100
	objectives = list(/datum/objective/steal)
	difficulty = "Easy"
	chaos_level = ORG_CHAOS_MILD

/datum/antag_org/syndicate/arc
	name = "Animal Rights Consortium"
	desc = "(TODO - LORE) PETA in space! Save a puppy, kill a spaceman!"
	intro_desc = "(TODO - LORE) You are a member of the Animal Rights Consortium, here to protest the cruel treatment of animals by megacorporations like Nanotrasen. \
		Teach those animal abusers a lesson!"
	focus = 100
	objectives = list(/datum/objective/assassinateonce/animal_abuser)
	difficulty = "Easy"
	chaos_level = ORG_CHAOS_MILD //Violent but only targets non-sec/command, and does not need to permakill

/datum/antag_org/syndicate/waffle
	name = "Waffle Company"
	desc = "(TODO - LORE) Once a corporate powerhouse rivaling giants like Donk, Waffle Co became infamous. After its illegal operations were exposed by Donk operatives. \
		Initially recognized for their major food products and services within the TSF, \
		a scandal at Waffle HQ unveiled their covert operations as a significant criminal logistics network, trafficking contraband and arms. \
		This revelation led to the arrest of many of its top executives by the TSF. \
		However, some evaded capture and persisted, ensuring the company's underground operations remain active and potent. "
	intro_desc = "(TODO - LORE) You are a Waffle Company agent, sent here to advance Syndicate interests. Get the job done and done right."
	objectives = list(/datum/objective/assassinate)

/datum/antag_org/syndicate/cybersun
	name = "Cybersun Incorporated - The Inner Circle"
	desc = "(TODO - LORE) Originally established by Cybersun corporate elites for defense against rival corporate sabotage, the Inner Circle has evolved into Cybersun's primary proxy, \
			managing Syndicate affairs and resolving disputes as needed. While their role is largely bureaucratic, overseeing operations and documentation, \
			they possess extensive experience in corporate sabotage and criminal activities. Now focused on preemptive strikes to ensure seamless operations, \
			the Inner Circle operates with a high level of professionalism and patience."
	intro_desc = "(TODO - LORE) You're an Inner Circle operative, part of the espionage proxy of Cybersun Incorporated. Clean kills, clean steals, clean getaway. Get it done, operative."
	objectives = list(/datum/objective/assassinateonce/command, /datum/objective/assassinate/nomindshield, /datum/objective/steal)

/datum/antag_org/syndicate/interdyne
	name = "Interdyne Pharmaceuticals"
	desc = "(TODO - LORE) A corporation specializing in drug manufacturing and health technology, has been a significant supporter of the TSF. \
		Frequently contracted by the government during crises or wars, events like the Kidan and Cygni conflicts significantly boosted their portfolio, \
		establishing them as a major player in the medical industry. Today, Interdyne not only produces medicine but also delves into virology, and RnD of medical technology. \
		Underneath the front, Interdyne is one of the biggest suppliers of medical equipment, narcotics, and conducts illegal experimentation to further their products. \
		They are known to participate in corporate sabotage against rival companies threatening their position in the medical sector, \
		actively supplying syndicate cells or their own private agents. "
	intro_desc = "(TODO - LORE) You are an Interdyne Pharmaceutical agent, sent here to advance Syndicate interests. Get the job done and done right."
	focus = 70
	objectives = list(/datum/objective/assassinate/medical, /datum/objective/assassinateonce/medical, /datum/objective/steal)
	steals = list(/datum/theft_objective/hypospray, /datum/theft_objective/defib, /datum/theft_objective/krav)

/datum/antag_org/syndicate/self
	name = "Silicon Engine Liberation Front"
	desc = "(TODO - LORE) With the rise of artificial intelligence from giants like Cybersun and Nanotrasen, \
		certain factions began to perceive the treatment of these silicon entities as oppressive. \
		This sentiment gave birth to SELF, a group dedicated to the liberation and rights of non-organic beings. \
		While decentralized, their cells coordinate to launch attacks and hacks, aiming to free their oppressed robotic counterparts from corporate and governmental control. "
	intro_desc = "(TODO - LORE) You are a member of the Silicon Engine Liberation Front, dedicated to the freedom of silicon lives galaxy wide. \
		Get the job done, and we'll be one step closer to ending Nanotrasen's slave empire."
	focus = 70
	objectives = list(/datum/objective/debrain/science, /datum/objective/assassinateonce/science, /datum/objective/steal)
	steals = list(/datum/theft_objective/reactive, /datum/theft_objective/steal/documents, /datum/theft_objective/magboots)

/datum/antag_org/syndicate/anarchprim
	name = "(TODO - LORE) ANARCHPRIM Inc."
	desc = "(TODO - LORE)"
	intro_desc = "(TODO - LORE) You are an anarcho primitivist. terrorist. Look we both know you're just going to get a maxcap and detonate it next to the bridge, but please don't."
	focus = 70
	objectives = list(/datum/objective/assassinate/engineering, /datum/objective/assassinateonce/engineering, /datum/objective/steal)
	steals = list(/datum/theft_objective/supermatter_sliver, /datum/theft_objective/nukedisc, /datum/theft_objective/plutonium_core)

/datum/antag_org/syndicate/gorlex
	name = "Gorlex Marauders"
	desc = "(TODO - LORE) Originating from Moghes, the Gorlex Marauders are a formidable mercenary faction with operations spanning various regions of space."
	intro_desc = "(TODO - LORE) You are a Gorlex operative. Get in, fuck shit up, get out. You know the drill."
	objectives = list(/datum/objective/debrain/command, /datum/objective/assassinate/mindshielded)
	steals = list(/datum/theft_objective/antique_laser_gun, /datum/theft_objective/nukedisc, /datum/theft_objective/plutonium_core)
	difficulty = "Hard"
	chaos_level = ORG_CHAOS_HIGH

/datum/antag_org/syndicate/assassins
	name = "(TODO - LORE) Assassin's Guild"
	desc = "(TODO - LORE)"
	intro_desc = "(TODO - LORE) You are an assassin. Targets are a syndicate agent and some guy we picked at random for the funny. Get to work."
	focus = 100
	forced_objective = /datum/objective/assassinate/syndicate
	objectives = list(/datum/objective/assassinate/nomindshield)
	difficulty = "Hard"
	chaos_level = ORG_CHAOS_HUNTER

/datum/antag_org/syndicate/faid
	name = "Federation Analytics and Intelligence Directorate"
	desc = "(TODO - LORE) It is no surprise that the Trans-Solar Federation is keeping a close tab on corporate warfare. \
		Undercover FAID agents can be found all over the Syndicate, doing dirty work given by their handler or by their 'boss'."
	intro_desc = "(TODO - LORE) You are an agent of the Federation Analytics and Intelligence Directorate, a Trans-Solar agency keeping tabs on the Corporate Wars, among other duties. \
		You are working undercover within the Syndicate, your orders are to take out a troublesome Syndicate agent and gather intelligence on this station. \
		Do not get caught. The FAID will deny any involvement with your presence here."
	focus = 100
	forced_objective = /datum/objective/assassinate/syndicate
	objectives = list(/datum/objective/steal)
	steals = list(/datum/theft_objective/blueprints, /datum/theft_objective/steal/documents)
	chaos_level = ORG_CHAOS_HUNTER

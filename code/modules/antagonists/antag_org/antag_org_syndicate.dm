/// Base syndicate org, can be selected to have 'vanilla' traitor with no changes.
/datum/antag_org/syndicate
	name = "Donk Co."
	desc = "(TODO - LORE) Rivals of Waffle Company, the two groups usually have an uneasy truce when operating in NT territory. \
		Donk Co. supplies a wide variety of goods to the Syndicate."
	intro_desc = "(TODO - LORE) You are a Donk Co. agent, sent here to advance Syndicate interests. Get the job done and done right."
	focus = 80
	difficulty = ORG_DIFFICULTY_MEDIUM
	chaos_level = ORG_CHAOS_AVERAGE
	selectable = TRUE

/datum/antag_org/syndicate/hawkmoon
	name = "Hawkmoon Acquisitions"
	desc = "Having only been founded in the last decade, Hawkmoon Acquisitions is a small, up-and-coming logistics company in the Orion Sector. \
		Specializing in expensive but discreet private courier services, they aren’t well known, but decently well respected. \
		Most aren’t unaware that Hawkmoon is just a front for a much larger, much darker network of thieves, fixers, and black markets that run throughout the underworld of Orion. \
		Those that they have contacts with, particularly the Syndicate, value their services and their skill at 'collecting' exactly what the buyer needs, through any means. \
		They have been rumored to be responsible for several high-profile thefts throughout the sector, \
		but there never seems to be enough evidence or witnesses to pin anything on Hawkmoon themselves, much to the annoyance of FAID and similar organizations."
	intro_desc = "(TODO - LORE) You are a Hawkmoon agent, sent here to advance Syndicate interests. Get the job done and done right."
	focus = 100
	objectives = list(/datum/objective/steal)
	difficulty = ORG_DIFFICULTY_EASY
	chaos_level = ORG_CHAOS_MILD

/datum/antag_org/syndicate/arc
	name = "Animal Rights Consortium"
	desc = "(TODO - LORE) PETA in space! Save a puppy, kill a spaceman!"
	intro_desc = "(TODO - LORE) You are a member of the Animal Rights Consortium, here to protest the cruel treatment of animals by megacorporations like Nanotrasen. \
		Teach those animal abusers a lesson!"
	focus = 100
	objectives = list(/datum/objective/assassinateonce/animal_abuser)
	difficulty = ORG_DIFFICULTY_EASY
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
	objectives = list(/datum/objective/assassinate/medical, /datum/objective/assassinateonce/medical, /datum/objective/steal/interdyne)

/datum/objective/steal/interdyne
	name = "Steal Item (Interdyne)"
	steal_list = list(/datum/theft_objective/hypospray, /datum/theft_objective/defib, /datum/theft_objective/krav)

/datum/antag_org/syndicate/self
	name = "Silicon Engine Liberation Front"
	desc = "(TODO - LORE) With the rise of artificial intelligence from giants like Cybersun and Nanotrasen, \
		certain factions began to perceive the treatment of these silicon entities as oppressive. \
		This sentiment gave birth to SELF, a group dedicated to the liberation and rights of non-organic beings. \
		While decentralized, their cells coordinate to launch attacks and hacks, aiming to free their oppressed robotic counterparts from corporate and governmental control. "
	intro_desc = "(TODO - LORE) You are a member of the Silicon Engine Liberation Front, dedicated to the freedom of silicon lives galaxy wide. \
		Get the job done, and we'll be one step closer to ending Nanotrasen's slave empire."
	focus = 70
	objectives = list(/datum/objective/debrain/science, /datum/objective/assassinateonce/science, /datum/objective/steal/self)

/datum/objective/steal/self
	name = "Steal Item (SELF)"
	steal_list = list(/datum/theft_objective/reactive, /datum/theft_objective/steal/documents, /datum/theft_objective/magboots)

/datum/antag_org/syndicate/electra
	name = "Electra Dynamics"
	desc = "(TODO - LORE) A Trans-Solar Federation based corporation, Electra Dynamics is a construction and energy supplier \
		that rose to prominence by investing heavily in the colonization of the Sol system during the pre-FTL era. \
		It holds a share in power systems across the sector, especially on Mercury \
		where they worked extensively to create the mining colonies and stations that are active to this day. \
		Electra Dynamics expertise in power generation and infrastructure has allowed it to remain competitive in the market, \
		often clashing with rivals like Nanotrasen over power installations and colony construction contracts. \
		However, the rise of Nanotrasen as a megacorporation has put Electra Dynamics at a disadvantage, \
		as rival innovative power sources increasingly threaten Electra's market share. \
		Nanotrasen's SM engine, in particular, has been a source of concern for Electra, \
		with its executives publicly criticizing it as a 'ticking bomb', to disuade public appeal. \
		However, this hardly stopped the interest of goverment officals investing into it, \
		to replace old Elektra power facilities for what felt like a more powerful energy source by their rival. \
		In a bid to regain its foothold and prevent technological obsolescence, \
		Electra Dynamics has resorted to using proxies to infiltrate and work in operations with the Syndicate. \
		Their primary objective is clear, to tarnish Nanotrasen's reputation in the engineering field and to acquire critical information for their advantage, \
		particularly regarding the secretive SM formula, with the aim of potentially reverse-engineering it."

	intro_desc = "(TODO - LORE) You are an Electra Dynamics agent, sent here to advance Syndicate interests. Get the job done and done right."
	focus = 70
	objectives = list(/datum/objective/assassinate/engineering, /datum/objective/assassinateonce/engineering, /datum/objective/steal/electra)

/datum/objective/steal/electra
	name = "Steal Item (Electra Dynamics)"
	steal_list = list(/datum/theft_objective/supermatter_sliver, /datum/theft_objective/blueprints, /datum/theft_objective/steal/documents)

/datum/antag_org/syndicate/gorlex
	name = "Gorlex Marauders"
	desc = "(TODO - LORE) Originating from Moghes, the Gorlex Marauders are a formidable mercenary faction with operations spanning various regions of space."
	intro_desc = "(TODO - LORE) You are a Gorlex operative. Get in, fuck shit up, get out with a fancy new shuttle. You know the drill."
	forced_objective = /datum/objective/hijack
	difficulty = ORG_DIFFICULTY_HARD
	chaos_level = ORG_CHAOS_HIJACK

/datum/antag_org/syndicate/assassins
	name = "(TODO - LORE) Assassin's Guild"
	desc = "(TODO - LORE)"
	intro_desc = "(TODO - LORE) You are an assassin. Targets are a syndicate agent and some guy we picked at random for the funny. Get to work."
	focus = 100
	forced_objective = /datum/objective/assassinate/syndicate
	objectives = list(/datum/objective/assassinate/nomindshield)
	difficulty = ORG_DIFFICULTY_HARD
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
	objectives = list(/datum/objective/steal/faid)
	chaos_level = ORG_CHAOS_HUNTER

/datum/objective/steal/faid
	name = "Steal Item (FAID)"
	steal_list = list(/datum/theft_objective/blueprints, /datum/theft_objective/steal/documents)

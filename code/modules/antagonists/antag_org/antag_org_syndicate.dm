/// Base syndicate org, can be selected to have 'vanilla' traitor with no changes.
/datum/antag_org/syndicate
	name = "Donk Co."
	desc = "(TODO - LORE) Rivals of Waffle Company, the two groups usually have an uneasy truce when operating in NT territory."
	you_are = "a Donk Co. agent"
	intro_desc = "(TODO - LORE) You have your orders, get to work, agent."
	difficulty = "Medium"
	chaos_level = ORG_CHAOS_AVERAGE
	selectable = TRUE

/datum/antag_org/syndicate/gorlex_marauders
	name = "Gorlex Marauders"
	desc = "(TODO - LORE) Originating from Moghes, the Gorlex Marauders are a formidable mercenary faction with operations spanning various regions of space."
	you_are = "a Gorlex operative"
	intro_desc = "(TODO - LORE) Get in, fuck shit up, get out. You know the drill."
	objectives = list(/datum/objective/debrain/command, /datum/objective/assassinate/mindshielded)
	steals = list(/datum/theft_objective/antique_laser_gun, /datum/theft_objective/nukedisc, /datum/theft_objective/plutonium_core)
	discount = list(/datum/uplink_item/suits/modsuit_elite, /datum/uplink_item/dangerous/sword, /datum/uplink_item/dangerous/revolver)
	difficulty = "Hard"
	chaos_level = ORG_CHAOS_HIGH

/datum/law/crime
	/// The crime code
	var/code = "00"
	/// Name of the crime
	var/name = "Unnamed Crime"
	/// Description of the crime
	var/desc = "No description."
	/// Severity tier of the crime
	var/severity = "minor"
	/// Minimum amount of time, in minutes
	var/min_time = 0
	/// Maximum amount of time, in minutes
	var/max_time = 5

/datum/law/crime/minor
	severity = "minor"
	min_time = 0
	max_time = 5

/datum/law/crime/medium
	severity = "medium"
	min_time = 5
	max_time = 10

/datum/law/crime/major
	severity = "major"
	min_time = 10
	max_time = 15

// category 00

/datum/law/crime/minor/damage_station_assets
	code = "00"
	name = "Damage to Station Assets"
	desc = "To deliberately damage the station or station property to a minor degree with malicious intent."

/datum/law/crime/medium/workplace_hazard
	code = "00"
	name = "Workplace Hazard"
	desc = "To endanger the crew or station through negligent but not deliberately malicious actions."

/datum/law/crime/major/sabotage
	code = "00"
	name = "Sabotage"
	desc = "To hinder the work of the crew or station through malicious actions."

// category 01

/datum/law/crime/medium/kidnapping
	code = "01"
	name = "Kidnapping"
	desc = "To hold a crewmember under duress or against their will."

// category 02

/datum/law/crime/minor/battery
	code = "02"
	name = "Battery"
	desc = "To use minor physical force against someone without intent to seriously injure them."

/datum/law/crime/medium/assault
	code = "02"
	name = "Assault"
	desc = "To use excessive physical force against someone without the apparent intent to kill them."

/datum/law/crime/major/aggravated_assault
	code = "02"
	name = "Aggravated Assault"
	desc = "To use excessive physical force resulting in severe or life-threatening harm."

// category 03

/datum/law/crime/minor/drug_possession
	code = "03"
	name = "Drug Possession"
	desc = "The unauthorized possession of recreational use drugs such as ambrosia, krokodil, crank, meth, aranesp, bath salts, or THC."

/datum/law/crime/medium/narcotics_distribution
	code = "03"
	name = "Narcotics Distribution"
	desc = "To distribute narcotics and other controlled substances. This includes ambrosia and space drugs. It is not illegal for them to be grown."

// category 04

/datum/law/crime/medium/weapon_possession
	code = "04"
	name = "Possession of a Weapon"
	desc = "To be in possession of a dangerous item that is not part of one's job."

/datum/law/crime/major/restricted_weapon
	code = "04"
	name = "Possession of a Restricted Weapon"
	desc = "To be in unauthorized possession of restricted weapons/items such as: Guns, Batons, Harmful Chemicals, Non-Beneficial Explosives, Combat Implants (Anti-Drop, CNS Rebooter, Razorwire), MODsuit Modules (Power Kick, Stealth)."

// category 05

/datum/law/crime/minor/indecent_exposure
	code = "05"
	name = "Indecent Exposure"
	desc = "To be intentionally and publicly unclothed."

/datum/law/crime/medium/rioting
	code = "05"
	name = "Rioting"
	desc = "To partake in an unauthorized and disruptive assembly of crewmen."

/datum/law/crime/major/inciting_riot
	code = "05"
	name = "Inciting a Riot"
	desc = "To attempt to stir the crew into a riot."

// category 06

/datum/law/crime/minor/abuse_equipment
	code = "06"
	name = "Abuse of Equipment"
	desc = "To utilize security/non-lethal equipment in an illegitimate fashion."

/datum/law/crime/medium/abuse_confiscated
	code = "06"
	name = "Abuse of Confiscated Equipment"
	desc = "To take and use equipment confiscated as evidence."

/datum/law/crime/major/contraband_possession
	code = "06"
	name = "Possession of Contraband"
	desc = "To be in the possession of contraband items."

// category 07

/datum/law/crime/minor/petty_theft
	code = "07"
	name = "Petty Theft"
	desc = "To take items from areas one lacks access to or to take items belonging to others or the station as a whole."

/datum/law/crime/medium/robbery
	code = "07"
	name = "Robbery"
	desc = "To steal items from another's person."

/datum/law/crime/major/theft
	code = "07"
	name = "Theft"
	desc = "To steal restricted or dangerous items from either an area or one's person."

// category 08

/datum/law/crime/minor/trespass
	code = "08"
	name = "Trespass"
	desc = "To be in an area which a person lacks authorized ID access for. This counts for general areas of the station."

/datum/law/crime/major/major_trespass
	code = "08"
	name = "Major Trespass"
	desc = "Being in a restricted area without prior authorization. This includes Security areas, Command areas (including EVA), the Engine Room, Atmos, or Toxins Research."

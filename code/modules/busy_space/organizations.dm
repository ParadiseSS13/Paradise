//Datums for different companies that can be used by busy_space
/datum/lore/organization
	var/name = ""				// Organization's name
	var/short_name = ""			// Organization's shortname (Nanotrasen for "Nanotrasen Incorporated")
	var/acronym = ""			// Organization's acronym, e.g. 'NT' for Nanotrasen'.
	var/desc = ""				// One or two paragraph description of the organization, but only current stuff.  Currently unused.
	var/history = ""			// Historical description of the organization's origins  Currently unused.
	var/work = ""				// Short description of their work, eg "an arms manufacturer"
	var/headquarters = ""		// Location of the organization's HQ.  Currently unused.
	var/motto = ""				// A motto/jingle/whatever, if they have one.  Currently unused.

	var/list/ship_prefixes = list()	//Some might have more than one! Like Nanotrasen. Value is the mission they perform, e.g. ("ABC" = "mission desc")
	var/list/ship_names = list(		//Names of spaceships.  This is a mostly generic list that all the other organizations inherit from if they don't have anything better.
		"Kestrel",
		"Beacon",
		"Signal",
		"Freedom",
		"Glory",
		"Axiom",
		"Eternal",
		"Icarus",
		"Harmony",
		"Light",
		"Discovery",
		"Endeavour",
		"Explorer",
		"Swift",
		"Dragonfly",
		"Ascendant",
		"Tenacious",
		"Pioneer",
		"Hawk",
		"Haste",
		"Radiant",
		"Luminous",
		"Gallant",
		"Dependable",
		"Indomitable",
		"Guardian",
		"Resolution",
		"Fearless",
		"Amazon",
		"Relentless",
		"Inspire",
		"Implacable",
		"Steadfast",
		"Leviathan",
		"Dauntless",
		"Adroit",
		"Mistral",
		"Typhoon",
		"Titan",
		"Kupua",
		"Alchemist",
		"Cuirass",
		"Citadel",
		"Rondelle",
		"Camail",
		"Ocrea",
		"Ram",
		"Crest",
		"Tanko",
		"Pommel",
		"Kissaki",
		"Cavalier",
		"Anelace",
		"Flint",
		"Xiphos",
		"Parrot",
		"Chamber",
		"Annellet",
		"Cestus",
		"Talwar")
	var/list/destination_names = list()	//Names of static holdings that the organization's ships visit regularly.
	var/autogenerate_destination_names = TRUE

/datum/lore/organization/New()
	..()
	if(autogenerate_destination_names) // Lets pad out the destination names.
		var/i = rand(6, 10)
		var/list/star_names = list(
			"Sol", "Alpha Centauri", "Sirius", "Vega", "Regulus", "Vir", "Algol", "Aldebaran",
			"Delta Doradus", "Menkar", "Geminga", "Elnath", "Gienah", "Mu Leporis", "Nyx", "Tau Ceti",
			"Wazn", "Alphard", "Phact", "Altair", "Mauna", "Jargon", "Xarxis", "Hestia", "Dalstis", "Cygni", "Haverick", "Corvus", "Sancere", "Cydoni", "Kaliban", "Midway", "Dansik", "Branwyn")
		var/list/destination_types = list("dockyard", "station", "vessel", "waystation", "telecommunications satellite", "spaceport", "distress beacon", "anomaly", "colony", "outpost")
		while(i)
			destination_names.Add("a [pick(destination_types)] in [pick(star_names)]")
			i--

//////////////////////////////////////////////////////////////////////////////////

// TSCs
/datum/lore/organization/tsc/nanotrasen
	name = "Nanotrasen Incorporated"
	short_name = "Nanotrasen"
	acronym = "NT"
	desc = "The largest shareholder in the galactic plasma markets, Nanotrasen is a research and mining corporation which specializes in\
	 FTL technologies and weapon systems. Frowned upon by most governments due to their shady business tactics and poor ethics record,\
	  Nanotrasen is often seen as a necessary evil for maintaining access to the often volatile plasma market. Nanotrasen was originally\
	   incorporated on Earth with their headquarters situated on Mars, however they have recently moved most of their operations to the Epsilon Eridani sector."
	history = "" // To be written someday.
	work = "research giant"
	headquarters = "Mars"
	motto = ""

	ship_prefixes = list("NSV" = "exploration", "NTV" = "hauling", "NDV" = "patrol", "NRV" = "emergency response")
	// Note that the current station being used will be pruned from this list upon being instantiated
	destination_names = list(
		"NAS Trurl in Epsilon Eridani",
		"NAS Crescent in Tau Ceti",
		"NSS Exodus in Tau Ceti",
		"NSS Antiqua in Darsing",
		"NRS Orion in Sol",
		"NSS Vector in Omicron Ceti",
		"NBS Anansi in Omicron Ceti",
		"NSS Redemption in Sirius",
		"NDS Inferno in Tau Ceti",
		"NAB Smythside Central Headquarters on Earth",
		"NAB North Cimmeria Central Offices on Mars",
	)

/datum/lore/organization/tsc/nanotrasen/New()
	..()
	spawn(1) // BYOND shenanigans means using_map is not initialized yet.  Wait a tick.
		// Get rid of the current map from the list, so ships flying in don't say they're coming to the current map.
		var/string_to_test = "[GLOB.using_map.station_name] in [GLOB.using_map.starsys_name]"
		if(string_to_test in destination_names)
			destination_names.Remove(string_to_test)


/datum/lore/organization/tsc/donk
	name = "Donk Corporation"
	short_name = "Donk Co."
	acronym = "DC"
	desc = "The infamous rival of the well-known Waffle Corporation, Donk Co. is a company specializing in food delivery systems and brand-name food\
	products such as Donk Pockets. While generally seen as a neutral actor, Donk Corporation has been known to work both with Nanotrasen and\
	the Syndicate when it suits them - often acting as the primary logistical supplier for the Epsilon Eridani sector.\
	Donk Corporation is better known for recent high-profile litigation alleging that their food products are used for illicit drug distribution.\
	While the trial is ongoing, it has been repeatedly delayed due to incidents of methamphetamine poisoning."
	history = ""
	work = "food company that establishes and maintains delivery supply chains"
	headquarters = ""
	motto = "Now with 20% more donk!"

	ship_prefixes = list("D-Co." = "transportation")
	destination_names = list()

/datum/lore/organization/tsc/hephaestus
	name = "Hephaestus Industries"
	short_name = "Hephaestus"
	acronym = "HI"
	desc = ""
	history = ""
	work = "arms manufacturer"
	headquarters = ""
	motto = ""

	ship_prefixes = list("HTV" = "freight", "HTV" = "munitions resupply")
	destination_names = list(
		"a SolGov dockyard on Luna"
		)

/datum/lore/organization/tsc/waffle
	name = "Waffle Corporation"
	short_name = "Waffle Co."
	acronym = "WC"
	desc = "The once prominent competitor of Donk Corporation, Waffle Co. is well-known for its popular line of Waffle Co.\
	brand waffles and their use of violent tactics against competitors - often bribing, extorting, blackmailing or sabotaging businesses\
	that pose a direct or indirect threat to their market share. They have recently fallen on hard times primarily due to to\
	severe mismanagement which lead to much of their private arsenal being swindled by a pirate faction known as the Gorlex Marauders.\
	Waffle Co. commonly engages in smear campaigns against Donk Co., maintaining that the original recipe for Donk Pockets was stolen from them."
	history = ""
	work = "food logistics and marketing firm"
	headquarters = ""
	motto = "Now that's a Waffle Co. Waffle!"

	ship_prefixes = list("W-Co." = "transportation")
	destination_names = list()


/datum/lore/organization/tsc/einstein
	name = "Einstein Engines Incorporated"
	short_name = "Einstein Inc."
	acronym = "EEI"
	desc = "An Engineering firm specializing in alternative fuel-technologies for FTL travel,\
	Einstein Engines is an up and coming player in the galactic FTL and energy markets.\
	As their research into alternative FTL fuel threatens both Nanotrasen's relative stranglehold on plasma as well as The Syndicate's vested\
	interest in the market, they are often the target of industrial sabotage by both Nanotrasen and The Syndicate.\
	Most of their contracts are based outside of the Epsilon Eridani sector, and they are frequently commissioned by smaller firms to retrofit new\
	and existing colonies, space stations, and outposts."
	history = ""
	work = "engineering firm specializing in engine technology"
	headquarters = "Jargon 4"
	motto = ""

	ship_prefixes = list("EE-T" = "transportation")
	destination_names = list()

/datum/lore/organization/tsc/zeng_hu
	name = "Zeng-Hu pharmaceuticals"
	short_name = "Zeng-Hu"
	acronym = "ZH"
	desc = ""
	history = ""
	work = "pharmaceuticals company"
	headquarters = ""
	motto = ""

	ship_prefixes = list("ZTV" = "transportation", "ZMV" = "medical resupply")
	destination_names = list()

/datum/lore/organization/tsc/biotech
	name = "Biotech Solutions"
	short_name = "Biotech"
	acronym = "BTS"
	desc = "A company specializing in the field of synthetic biology, BioTech solutions is at the forefront of providing cutting-edge prosthetics,\
	augmentations, and gene-therapy solutions. Their extensive list of patents and the highly secretive nature of their work often puts them at odds\
	with companies such as Nanotrasen, who commonly reverse-engineer their products. BioTech Solutions is often the victim of industrial sabotage by\
	Cybersun Industries and often relies on planetary governments for asset protection. BioTech Solutions also owns a number of prominent subsidiaries,\
	such as Bishop Cybernetics, Hesphiastos Industries, and Xion Manufacturing Group."
	history = ""
	work = "medical company specializing in prosthetics and pharmaceuticals"
	headquarters = "Xarxis 5"
	motto = ""

	ship_prefixes = list("CIND-T" = "transportation")
	destination_names = list()

/datum/lore/organization/tsc/ward_takahashi
	name = "Ward-Takahashi General Manufacturing Conglomerate"
	short_name = "Ward-Takahashi"
	acronym = "WT"
	desc = ""
	history = ""
	work = "electronics manufacturer"
	headquarters = ""
	motto = ""

	ship_prefixes = list("WTV" = "freight")
	destination_names = list(
	""
	)

/datum/lore/organization/tsc/cybersun
	name = "Cybersun Industries"
	short_name = "Cybersun Ind."
	acronym = "CI"
	desc = "Cybersun Industries is a biotechnology company that primarily specializes on the research and development of human-enhancing augmentations.\
	They are better known for their aggressive corporate tactics and are known to often subsidize pirate bands to commit acts of industrial sabotage.\
	Cybersun Industries is usually the target of conspiracy theorists due to their development of the first mindslave implant, as well as their open financing of,\
	and involvement in, The Syndicate. They are one of Nanotrasen's largest detractors, and a direct competitor to BioTech Solutions."
	history = ""
	work = "RND company specializing in augmentations and implants."
	headquarters = "Luna"
	motto = ""

	ship_prefixes = list("CIND-T" = "transportation")
	destination_names = list()

/datum/lore/organization/tsc/bishop
	name = "Bishop Cybernetics"
	short_name = "Bishop"
	acronym = "BC"
	desc = ""
	history = ""
	work = "cybernetics and augmentation manufacturer"
	headquarters = ""
	motto = ""

	ship_prefixes = list("BTV" = "transportation")
	destination_names = list()

/datum/lore/organization/tsc/morpheus
	name = "Morpheus Cyberkinetics"
	short_name = "Morpheus"
	acronym = "MC"
	desc = "The only large corporation run by positronic intelligences, Morpheus caters almost exclusively to their sensibilities \
	and needs. A product of the synthetic colony of Shelf, Morpheus eschews traditional advertising to keep their prices low and \
	relied on word of mouth among positronics to reach their current economic dominance. Morpheus in exchange lobbies heavily for \
	positronic rights, sponsors positronics through their Jans-Fhriede test, and tends to other positronic concerns to earn them \
	the good-will of the positronics, and the ire of those who wish to exploit them."
	history = ""
	work = "cybernetics manufacturer"
	headquarters = ""
	motto = ""

	ship_prefixes = list("MTV" = "freight")
	// Culture names, because Anewbe told me so.
	ship_names = list(
		"Nervous Energy",
		"Prosthetic Conscience",
		"Revisionist",
		"Trade Surplus",
		"Flexible Demeanour",
		"Just Read The Instructions",
		"Limiting Factor",
		"Cargo Cult",
		"Gunboat Diplomat",
		"A Ship With A View",
		"Cantankerous",
		"Never Talk To Strangers",
		"Sacrificial Victim",
		"Unwitting Accomplice",
		"Bad For Business",
		"Just Testing",
		"Yawning Angel",
		"Liveware Problem",
		"Very Little Gravitas Indeed",
		"Zero Gravitas",
		"Gravitas Free Zone",
		"Absolutely No You-Know-What",
		"Existence Is Pain",
		"Screw Loose",
		"Limiting Factor",
		"So Much For Subtley",
		"Unfortunate Conflict Of Evidence",
		"Prime Mover",
		"Reasonable Excuse",
		"Honest Mistake",
		"Appeal To Reason",
		"My First Ship II",
		"Hidden Income",
		"Anything Legal Considered",
		"New Toy",
		"Me, I'm Always Counting",
		"Great White Snark",
		"No Shirt No Shoes",
		"Callsign"
	)
	destination_names = list(
		"a dockyard on New Canaan"
	)

/datum/lore/organization/tsc/xion
	name = "Xion Manufacturing Group"
	short_name = "Xion"
	desc = ""
	history = ""
	work = "industrial equipment manufacturer"
	headquarters = ""
	motto = ""

	ship_prefixes = list("XTV" = "hauling")
	destination_names = list()

/datum/lore/organization/tsc/shellguard
	name = "Shellguard Munitions"
	short_name = "Shellguard"
	acronym = "SM"
	desc = "The brainchild of a colonial war veteran, Shellguard Munitions is an arms manufacturer and private military contractor specializing\
	in anti-synthetic weapon systems and platforms. Initially a smaller private military force only serving frontier colonies,\
	Shellguard Munitions has become a household name due to its involvement in resolving the Haverick AI crisis in 2552.\
	Using its recently earned fame, the company has made a successful foray into the market of robotics and is highly regarded for the toughness \
	and reliability of their hardware. Despite being frequently contracted by the Trans-Solar Federation, Shellguard Munitions is known to\
	sell their services to the highest corporate bidder."
	history = ""
	work = "anti-synthetic arms manufacturer and PMC"
	headquarters = "Colony of Haverick"
	motto = ""

	ship_prefixes = list("BTS-T" = "transportation")
	destination_names = list()

// Governments


/datum/lore/organization/gov/solgov
	name = "Trans-Solar Federation"
	short_name = "SolGov"
	acronym = "TSF"
	desc = "Colloquially known as SolGov, the TSF is an authoritarian republic that manages the areas in and around the Sol system.\
	Despite being a highly militant organization headed by the government of Earth,\
	SolGov is usually conservative with its power and mostly serves as a mediator and peacekeeper in galactic affairs."
	history = "" // Todo
	work = "governing polity of humanity's Confederation"
	headquarters = "Earth"
	motto = ""
	autogenerate_destination_names = TRUE

	ship_prefixes = list("FTV" = "transporation", "FDV" = "diplomatic", "FSF" = "freight", "FIV" = "interception", "FDV" = "defense", "FCV-A" = "carrier", "FBB" = "battleship")
	destination_names = list(
		"Venus",
		"Earth",
		"Luna",
		"Mars",
		"Titan",
		"Ahdomai",
		"Kelune",
		"Dalstadt",
		"New Canaan",
		"Jargon 4",
		"Hoorlm",
		"Xarxis 5",
		"Aurum",
		"Moghes",
		"Haverick",
		"Darsing",
		"Norfolk",
		"Boron",
		"Iluk")

/datum/lore/organization/gov/tajara
	name = "The Alchemist's Council"
	short_name = "The Council"
	acronym = "AC"
	desc = "The Alchemist's Council is a science-oriented organization of scholars, researchers, and entrepreneurs. \
	Though dedicated to industrializing the Tajaran world of Ahdomai, it is seen as one of the few remaining centralized powers of the Tajara peoples \
	due to the collapse of Ahdomai's provisional government."
	history = "" // Todo
	work = "science body that oversees Tajara economic and research policy"
	headquarters = "Ahdomai"
	motto = ""
	autogenerate_destination_names = TRUE

	ship_prefixes = list("ACS" = "transportation", "ADV" = "diplomatic", "ACF" = "freight")
	destination_names = list(
		"Ahdomai",
		"Iluk")


/datum/lore/organization/gov/vulp
	name = "The Assembly"
	short_name = "Assembly"
	acronym = "ASB"
	desc = "A unifying body created to stave off extinction from a solar event,\
	The Assembly is the loose federal coalition of the Vulpkanin. It holds little centralized authority and mostly serves as a diplomatic body,\
	primarily concerned with facilitating trade between Vulpkanin colonies and Nanotrasen."
	history = "" // Todo
	work = "governing body of the Vulpakanin"
	headquarters = "Kelune and Dalstadt"
	motto = ""
	autogenerate_destination_names = TRUE

	ship_prefixes = list("ATV" = "transportation", "ADV" = "diplomatic", "ACF" = "freight")
	destination_names = list(
		"Kelune",
		"Dalstadt",
		"New Canaan")

/datum/lore/organization/gov/synth
	name = "Synthetic Union"
	short_name = "Synthetica"
	acronym = "SYN"
	desc = "A defensive coalition of synthetics based out of New Canaan,\
			 the Synthetic Union is an organization which aims to establish and consolidate synthetic rights across the galaxy.\
			  Despite its synth oriented focus, the Synthetic Union has cordial relations with most governing bodies."
	history = "" // Todo
	work = "Union of Machines"
	headquarters = "New Canaan"
	motto = ""
	autogenerate_destination_names = TRUE

	ship_prefixes = list("01" = "transportation", "10" = "diplomatic", "112" = "freight")//copyed from solgov until new ones can be thought of
	destination_names = list(
		"Luna",
		"Dalstadt",
		"New Canaan",
		"Jargon 4",
		"Haverick",
		"Darsing",
		"Norfolk")

/datum/lore/organization/gov/grey
	name = "The Technocracy"
	short_name = "Technocracy"
	acronym = "AYY"
	desc = "The Technocracy is a science council that operates based off the principles of a meritocracy.\
	The organization's leadership is highly competitive, and is headed by the most psionically gifted members of the Grey species.\
	The Technocracy, though enigmatic in its dealings, has cordial relations with almost all other galactic bodies."
	history = "" // Todo
	work = "Grey Council"
	headquarters = ""
	motto = ""
	autogenerate_destination_names = TRUE

	ship_prefixes = list("TC-T" = "transportation", "TC-D" = "diplomatic", "TC-F" = "freight")
	destination_names = list(
		"Venus",
		"Earth",
		"Luna",
		"Mars",
		"Titan",
		"Ahdomai",
		"Kelune",
		"Dalstadt",
		"New Canaan",
		"Jargon 4",
		"Hoorlm",
		"Xarxis 5",
		"Aurum",
		"Moghes",
		"Haverick",
		"Darsing",
		"Norfolk",
		"Boron",
		"Iluk")

/datum/lore/organization/gov/vox
	name = "The Shoal"
	short_name = "Shoal"
	acronym = "SHA"
	desc = "The Shoal is the primary ark ship of the reclusive Vox species.\
	Little is known about The Shoal's political structure as Vox typically shy away from diplomatic engagements.\
	Subsequently, it is considered a politically neutral entity in galactic affairs by most governments."
	history = "" // Todo
	work = "Traders"
	headquarters = "Shoal"
	motto = ""
	autogenerate_destination_names = FALSE

	ship_prefixes = list("Legitimate Transport" = "transportation", "Legitimate Trader" = "freight", "Legitimate Diplomatic Vessel" = "raider")
	destination_names = list(
		"Ahdomai",
		"Kelune",
		"Dalstadt",
		"New Canaan",
		"Jargon 4",
		"Hoorlm",
		"Xarxis 5",
		"Aurum",
		"Moghes",
		"Haverick",
		"Darsing")

/datum/lore/organization/tsc/skrell
	name = "Skrellian Central Authority"
	short_name = "Skrellian CA."
	acronym = "SCA"
	desc = "The primary governing body of the Skrellian homeworld of Jargon 4,\
	the SCA oversees all foreign and domestic policy for the Skrell and their colonies. The Skrellian Central Authority is better known for its\
	active role in the largest military alliance in the galaxy, the Human-Skrellian Alliance."
	history = ""
	work = "oversees Skrell worlds"
	headquarters = "Jargon 4"
	motto = ""

	ship_prefixes = list("SCA-V." = "transportation", "SCA-F" = "freight", "HSA-D" = "diplomatic")
	destination_names = list(
		"Venus",
		"Earth",
		"Luna",
		"Mars",
		"Titan",
		"Aurumn",
		"Jargon 4",
		"Xarxis 5",
		"Haverick",
		"Darsing",
		"Norfolk")

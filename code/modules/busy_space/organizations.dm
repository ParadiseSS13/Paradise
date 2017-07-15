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
		"Luminous"
		)
	var/list/destination_names = list()	//Names of static holdings that the organization's ships visit regularly.
	var/autogenerate_destination_names = TRUE

/datum/lore/organization/New()
	..()
	if(autogenerate_destination_names) // Lets pad out the destination names.
		var/i = rand(6, 10)
		var/list/star_names = list(
			"Sol", "Alpha Centauri", "Sirius", "Vega", "Regulus", "Vir", "Algol", "Aldebaran",
			"Delta Doradus", "Menkar", "Geminga", "Elnath", "Gienah", "Mu Leporis", "Nyx", "Tau Ceti",
			"Wazn", "Alphard", "Phact", "Altair")
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
	desc = "Nanotrasen is one of the foremost research and development companies in SolGov space. \
	Originally focused on consumer products, their swift move into the field of Plasma has lead to \
	them being the foremost experts on the substance and its uses. In the modern day, Nanotrasen prides \
	itself on being an early adopter to as many new technologies as possible, often offering the newest \
	products to their employees. In an effort to combat complaints about being 'guinea pigs', Nanotrasen \
	also offers one of the most comprehensive medical plans in SolGov space, up to and including cloning \
	and therapy.\
	<br><br>\
	NT's most well known products are its plasma based creations, especially those used in Cryotherapy. \
	It also boasts an prosthetic line, which is provided to its employees as needed, and is used as an incentive \
	for newly tested posibrains to remain with the company."
	history = "" // To be written someday.
	work = "research giant"
	headquarters = "Earth"
	motto = ""

	ship_prefixes = list("NSV" = "exploration", "NTV" = "hauling", "NDV" = "patrol", "NRV" = "emergency response")
	// Note that the current station being used will be pruned from this list upon being instantiated
	destination_names = list(
		"NSS Exodus in Nyx",
		"NCS Northern Star in Vir",
		"NCS Southern Cross in Vir",
		"NDV Icarus in Nyx",
		"an asteroid orbiting Kara",
		"an asteroid orbiting Rota",
		)

/datum/lore/organization/tsc/nanotrasen/New()
	..()
	spawn(1) // BYOND shenanigans means using_map is not initialized yet.  Wait a tick.
		// Get rid of the current map from the list, so ships flying in don't say they're coming to the current map.
		var/string_to_test = "[using_map.station_name] in [using_map.starsys_name]"
		if(string_to_test in destination_names)
			destination_names.Remove(string_to_test)



/datum/lore/organization/tsc/hephaestus
	name = "Hephaestus Industries"
	short_name = "Hephaestus"
	acronym = "HI"
	desc = "Hephaestus Industries is the largest supplier of arms, ammunition, and small military vehicles in Sol space. \
	Hephaestus products have a reputation for reliability, and the corporation itself has a noted tendency to stay removed \
	from corporate politics. They enforce their neutrality with the help of a fairly large asset-protection contingent which \
	prevents any contracting polities from using their own materiel against them. SolGov itself is one of Hephastus� largest \
	bulk contractors owing to the above factors."
	history = ""
	work = "arms manufacturer"
	headquarters = ""
	motto = ""

	ship_prefixes = list("HTV" = "freight", "HTV" = "munitions resupply")
	destination_names = list(
		"a SolGov dockyard on Luna"
		)

/datum/lore/organization/tsc/vey_med
	name = "Vey Medical"
	short_name = "Vey Med"
	acronym = "VM"
	desc = "Vey-Med is one of the newer TSCs on the block and is notable for being largely owned and operated by Skrell. \
	Despite the suspicion and prejudice leveled at them for their alien origin, Vey-Med has obtained market dominance in \
	the sale of medical equipment-- from surgical tools to large medical devices to the Odysseus trauma response mecha \
	and everything in between. Their equipment tends to be top-of-the-line, most obviously shown by their incredibly \
	human-like FBP designs. Vey�s rise to stardom came from their introduction of ressurective cloning, although in \
	recent years they�ve been forced to diversify as their patents expired and Nanotrasen-made medications became \
	essential to modern cloning."
	history = ""
	work = "medical equipment supplier"
	headquarters = ""
	motto = ""

	ship_prefixes = list("VTV" = "transportation", "VMV" = "medical resupply")
	destination_names = list(
	"a outpost on Jargon 4"
	)

/datum/lore/organization/tsc/zeng_hu
	name = "Zeng-Hu pharmaceuticals"
	short_name = "Zeng-Hu"
	acronym = "ZH"
	desc = "Zeng-Hu is an old TSC, based in the Sol system. Until the discovery of Plasma, Zeng-Hu maintained a stranglehold \
	on the market for medications, and many household names are patentted by Zeng-Hu-- Bicaridyne, Dylovene, Tricordrizine, \
	and Dexalin all came from a Zeng-Hu medical laboratory. Zeng-Hu�s fortunes have been in decline as Nanotrasen�s near monopoly \
	on plasma research cuts into their R&D and Vey-Med�s superior medical equipment effectively decimated their own equipment \
	interests. The three-way rivalry between these companies for dominance in the medical field is well-known and a matter of \
	constant economic speculation."
	history = ""
	work = "pharmaceuticals company"
	headquarters = ""
	motto = ""

	ship_prefixes = list("ZTV" = "transportation", "ZMV" = "medical resupply")
	destination_names = list()

/datum/lore/organization/tsc/ward_takahashi
	name = "Ward-Takahashi General Manufacturing Conglomerate"
	short_name = "Ward-Takahashi"
	acronym = "WT"
	desc = "Ward-Takahashi focuses on the sale of small consumer electronics, with its computers, communicators, \
	and even mid-class automobiles a fixture of many households. Less famously, Ward-Takahashi also supplies most \
	of the AI cores on which vital control systems are mounted, and it is this branch of their industry that has \
	led to their tertiary interest in the development and sale of high-grade AI systems. Ward-Takahashi�s economies \
	of scale frequently steal market share from Nanotrasen�s high-price products, leading to a bitter rivalry in the \
	consumer electronics market."
	history = ""
	work = "electronics manufacturer"
	headquarters = ""
	motto = ""

	ship_prefixes = list("WTV" = "freight")
	destination_names = list(
	"a station near Kelune"
	)

/datum/lore/organization/tsc/bishop
	name = "Bishop Cybernetics"
	short_name = "Bishop"
	acronym = "BC"
	desc = "Bishop�s focus is on high-class, stylish cybernetics. A favorite among transhumanists (and a b�te noire for \
	bioconservatives), Bishop manufactures not only prostheses but also brain augmentation, synthetic organ replacements, \
	and odds and ends like implanted wrist-watches. Their business model tends towards smaller, boutique operations, giving \
	it a reputation for high price and luxury, with Bishop cyberware often rivalling Vey-Med�s for cost. Bishop�s reputation \
	for catering towards the interests of human augmentation enthusiasts instead of positronics have earned it ire from the \
	Positronic Rights Group and puts it in ideological (but not economic) competition with Morpheus Cyberkinetics."
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
		"Size Isn't Everything",
		"Yawning Angel",
		"Liveware Problem",
		"Very Little Gravitas Indeed",
		"Zero Gravitas",
		"Gravitas Free Zone",
		"Absolutely No You-Know-What",
		"Existence Is Pain",
		"Screw Loose",
		"Of Course I Still Love You",
		"Limiting Factor",
		"So Much For Subtley",
		"Unfortunate Conflict Of Evidence",
		"Prime Mover",
		"Boo!",
		"Reasonable Excuse",
		"Honest Mistake",
		"Appeal To Reason",
		"My First Ship II",
		"Hidden Income",
		"Anything Legal Considered",
		"New Toy",
		"Me, I'm Always Counting",
		"Just Five More Minutes",
		"Are You Feeling It",
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
	desc = "Xion, quietly, controls most of the market for industrial equipment. Their portfolio includes mining exosuits, \
	factory equipment, rugged positronic chassis, and other pieces of equipment vital to the function of the economy. Xion \
	keeps its control of the market by leasing, not selling, their equipment, and through infamous and bloody patent protection \
	lawsuits. Xion are noted to be a favorite contractor for SolGov engineers, owing to their low cost and rugged design."
	history = ""
	work = "industrial equipment manufacturer"
	headquarters = ""
	motto = ""

	ship_prefixes = list("XTV" = "hauling")
	destination_names = list()

// Governments


/datum/lore/organization/gov/solgov
	name = "Solar Confederate Government"
	short_name = "SolGov"
	acronym = "SCG"
	desc = "Colloquially known as SolGov, the TSF is an authoritarian republic that manages the areas in and around the Sol system.\
			 Despite being a highly militant organization headed by the government of Earth,\
			 SolGov is usually conservative with its power and mostly serves as a mediator and peacekeeper in galactic affairs."
	history = "" // Todo
	work = "governing polity of humanity's Confederation"
	headquarters = "Luna"
	motto = "Nil Mortalibus Ardui Est" // Latin, because latin.  Says 'Nothing is too steep for mortals'.
	autogenerate_destination_names = TRUE

	ship_prefixes = list("FSS-T" = "transportation", "FSS-D" = "diplomatic", "FSS-F" = "freight")
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
		"Moghes"
	)

/datum/lore/organization/gov/tajara
	name = "The Alchemist's Council"
	short_name = "The Council"
	acronym = "AC"
	desc = "The Alchemist's Council is a science-oriented organization of scholars, researchers, and entrepreneurs. \
			Though dedicated to industrializing the Tajaran world of Ahdomai, it is seen as one of the few remaining centralized powers of the Tajara peoples \
			due to the collapse of Ahdomai's provisional government."
	history = "" // Todo
	work = "governing boyd of the Tajara"
	headquarters = "Ahdomai"
	motto = ""
	autogenerate_destination_names = TRUE

	ship_prefixes = list("FSS-T" = "transportation", "FSS-D" = "diplomatic", "FSS-F" = "freight")//copyed from solgov until new ones can be thought of
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
		"Moghes"
	)

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

	ship_prefixes = list("FSS-T" = "transportation", "FSS-D" = "diplomatic", "FSS-F" = "freight")//copyed from solgov until new ones can be thought of
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
		"Moghes"
	)

/datum/lore/organization/gov/synth
	name = "Synthetic Union"
	short_name = "Synthtica"
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
		"Moghes"
	)

/datum/lore/organization/gov/grey
	name = "The Technocracy"
	short_name = "Technocracy"
	acronym = "AYY"
	desc = "A defensive coalition of synthetics based out of New Canaan,\
			 the Synthetic Union is an organization which aims to establish and consolidate synthetic rights across the galaxy.\
			  Despite its synth oriented focus, the Synthetic Union has cordial relations with most governing bodies."
	history = "" // Todo
	work = "Grey Council"
	headquarters = ""
	motto = ""
	autogenerate_destination_names = TRUE

	ship_prefixes = list("GT" = "transportation", "GD" = "diplomatic", "GF" = "freight")//copyed from solgov until new ones can be thought of
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
		"Moghes"
	)

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

	ship_prefixes = list("Legitimate Transport" = "transportation", "Legitimate Trader" = "freight")
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
		"Moghes"
	)
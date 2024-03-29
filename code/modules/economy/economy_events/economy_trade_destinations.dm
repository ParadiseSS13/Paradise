
GLOBAL_LIST_EMPTY(weighted_randomevent_locations)
GLOBAL_LIST_EMPTY(weighted_mundaneevent_locations)

/datum/trade_destination
	var/name = ""
	var/description = ""
	var/distance = 0
	var/list/willing_to_buy = list()
	var/list/willing_to_sell = list()
	var/can_shuttle_here = 0		//one day crew from the exodus will be able to travel to this destination
	var/list/viable_random_events = list()
	var/list/temp_price_change[TRADE_GOOD_BIOMEDICAL]
	var/list/viable_mundane_events = list()

/datum/trade_destination/proc/get_custom_eventstring(event_type)
	return null

//distance is measured in AU and co-relates to travel time
/datum/trade_destination/centcomm
	name = "CentComm"
	description = "Nanotrasen's administrative centre for Tau Ceti."
	distance = 1.2
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RANDOM_STORY_SECURITY_BREACH, RANDOM_STORY_CORPORATE_ATTACK, RANDOM_STORY_AI_LIBERATION)
	viable_mundane_events = list(RANDOM_STORY_ELECTION, RANDOM_STORY_RESIGNATION, RANDOM_STORY_CELEBRITY_DEATH)

/datum/trade_destination/anansi
	name = "NSS Anansi"
	description = "Medical station ran by Second Green Cross (but owned by NT) for handling emergency cases from nearby colonies."
	distance = 1.7
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RANDOM_STORY_SECURITY_BREACH, RANDOM_STORY_CULT_CELL_REVEALED, RANDOM_STORY_BIOHAZARD_OUTBREAK, RANDOM_STORY_PIRATES, RANDOM_STORY_ALIEN_RAIDERS)
	viable_mundane_events = list(RANDOM_STORY_RESEARCH_BREAKTHROUGH, RANDOM_STORY_RESEARCH_BREAKTHROUGH, RANDOM_STORY_BARGAINS, RANDOM_STORY_GOSSIP)

/datum/trade_destination/anansi/get_custom_eventstring(event_type)
	if(event_type == RANDOM_STORY_RESEARCH_BREAKTHROUGH)
		return "Thanks to research conducted on the NSS Anansi, Second Green Cross Society wishes to announce a major breakthough in the field of \
		[pick("mind-machine interfacing","neuroscience","nano-augmentation","genetics")]. Nanotrasen is expected to announce a co-exploitation deal within the fortnight."
	return null

/datum/trade_destination/icarus
	name = "NMV Icarus"
	description = "Corvette assigned to patrol the station's local space."
	distance = 0.1
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RANDOM_STORY_SECURITY_BREACH, RANDOM_STORY_AI_LIBERATION, RANDOM_STORY_PIRATES)

/datum/trade_destination/redolant
	name = "OAV Redolant"
	description = "Osiris Atmospherics station in orbit around the only gas giant insystem. They retain tight control over shipping rights, and Osiris warships protecting their prize are not an uncommon sight in Tau Ceti."
	distance = 0.6
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RANDOM_STORY_INDUSTRIAL_ACCIDENT, RANDOM_STORY_PIRATES, RANDOM_STORY_CORPORATE_ATTACK)
	viable_mundane_events = list(RANDOM_STORY_RESEARCH_BREAKTHROUGH, RANDOM_STORY_RESEARCH_BREAKTHROUGH)

/datum/trade_destination/redolant/get_custom_eventstring(event_type)
	if(event_type == RANDOM_STORY_RESEARCH_BREAKTHROUGH)
		return "Thanks to research conducted on the OAV Redolant, Osiris Atmospherics wishes to announce a major breakthough in the field of \
		[pick("plasma research","high energy flux capacitance","super-compressed materials","theoretical particle physics")]. Nanotrasen is expected to announce a co-exploitation deal within the fortnight."
	return null

/datum/trade_destination/beltway
	name = "Beltway mining chain"
	description = "A co-operative effort between Beltway and Nanotrasen to exploit the rich outer asteroid belt of the Tau Ceti system."
	distance = 7.5
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RANDOM_STORY_PIRATES, RANDOM_STORY_INDUSTRIAL_ACCIDENT)
	viable_mundane_events = list(RANDOM_STORY_TOURISM)

/datum/trade_destination/biesel
	name = "Biesel"
	description = "Large ship yards, strong economy and a stable, well-educated populace, Biesel largely owes allegiance to Sol / Vessel Contracting and begrudgingly tolerates NT. Capital is Lowell City."
	distance = 2.3
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RANDOM_STORY_RIOTS, RANDOM_STORY_INDUSTRIAL_ACCIDENT, RANDOM_STORY_BIOHAZARD_OUTBREAK, RANDOM_STORY_CULT_CELL_REVEALED, RANDOM_STORY_FESTIVAL, RANDOM_STORY_MOURNING)
	viable_mundane_events = list(RANDOM_STORY_BARGAINS, RANDOM_STORY_GOSSIP, RANDOM_STORY_SONG_DEBUT, RANDOM_STORY_MOVIE_RELEASE, RANDOM_STORY_ELECTION, RANDOM_STORY_TOURISM, RANDOM_STORY_RESIGNATION, RANDOM_STORY_CELEBRITY_DEATH)

/datum/trade_destination/new_gibson
	name = "New Gibson"
	description = "Heavily industrialised rocky planet containing the majority of the planet-bound resources in the system, New Gibson is torn by unrest and has very little wealth to call it's own except in the hands of the corporations who jostle with NT for control."
	distance = 6.6
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RANDOM_STORY_RIOTS, RANDOM_STORY_INDUSTRIAL_ACCIDENT, RANDOM_STORY_BIOHAZARD_OUTBREAK, RANDOM_STORY_CULT_CELL_REVEALED, RANDOM_STORY_FESTIVAL, RANDOM_STORY_MOURNING)
	viable_mundane_events = list(RANDOM_STORY_ELECTION, RANDOM_STORY_TOURISM, RANDOM_STORY_RESIGNATION)

/datum/trade_destination/luthien
	name = "Luthien"
	description = "A small colony established on a feral, untamed world (largely jungle). Savages and wild beasts attack the outpost regularly, although NT maintains tight military control."
	distance = 8.9
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RANDOM_STORY_WILD_ANIMAL_ATTACK, RANDOM_STORY_CULT_CELL_REVEALED, RANDOM_STORY_FESTIVAL, RANDOM_STORY_MOURNING, RANDOM_STORY_ANIMAL_RIGHTS_RAID, RANDOM_STORY_ALIEN_RAIDERS)
	viable_mundane_events = list(RANDOM_STORY_ELECTION, RANDOM_STORY_TOURISM, RANDOM_STORY_BIG_GAME_HUNTERS, RANDOM_STORY_RESIGNATION)

/datum/trade_destination/reade
	name = "Reade"
	description = "A cold, metal-deficient world, NT maintains large pastures in whatever available space in an attempt to salvage something from this profitless colony."
	distance = 7.5
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RANDOM_STORY_WILD_ANIMAL_ATTACK, RANDOM_STORY_CULT_CELL_REVEALED, RANDOM_STORY_FESTIVAL, RANDOM_STORY_MOURNING, RANDOM_STORY_ANIMAL_RIGHTS_RAID, RANDOM_STORY_ALIEN_RAIDERS)
	viable_mundane_events = list(RANDOM_STORY_ELECTION, RANDOM_STORY_TOURISM, RANDOM_STORY_BIG_GAME_HUNTERS, RANDOM_STORY_RESIGNATION)


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

//distance is measured in AU and co-relates to travel time
/datum/trade_destination/centcomm
	name = "CentComm"
	description = "Nanotrasen's administrative centre for Tau Ceti."
	distance = 1.2
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(
		/datum/event_news/economic/ai_liberation,
		/datum/event_news/economic/corporate_attack,
		/datum/event_news/economic/security_breach,
	)
	viable_mundane_events = list(
		/datum/event_news/celebrity_death,
		/datum/event_news/election,
		/datum/event_news/resignation,
	)

/datum/event_news/research_breakthrough/anansi

/datum/event_news/research_breakthrough/anansi/generate()
	. = ..()
	title = "Major Breakthrough on NSS Anansi"
	body = "Thanks to research conducted on the NSS Anansi, Second Green Cross Society wishes to announce a major breakthrough in the field of \
		[pick("mind-machine interfacing","neuroscience","nano-augmentation","genetics")]. Nanotrasen is expected to announce a co-exploitation deal within the fortnight."

/datum/trade_destination/anansi
	name = "NSS Anansi"
	description = "Medical station ran by Second Green Cross (but owned by NT) for handling emergency cases from nearby colonies."
	distance = 1.7
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(
		/datum/event_news/economic/alien_raiders,
		/datum/event_news/economic/biohazard_outbreak,
		/datum/event_news/economic/cult_cell_revealed,
		/datum/event_news/economic/pirates,
		/datum/event_news/economic/security_breach,
	)
	viable_mundane_events = list(
		/datum/event_news/bargains,
		/datum/event_news/gossip,
		/datum/event_news/research_breakthrough/anansi,
	)

/datum/trade_destination/icarus
	name = "NMV Icarus"
	description = "Corvette assigned to patrol the station's local space."
	distance = 0.1
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(
		/datum/event_news/economic/ai_liberation,
		/datum/event_news/economic/pirates,
		/datum/event_news/economic/security_breach,
	)

/datum/event_news/research_breakthrough/redolant/generate()
	. = ..()
	title = "Major Breakthrough on OAV Redolant"
	body = "Thanks to research conducted on the OAV Redolant, Osiris Atmospherics wishes to announce a major breakthrough in the field of \
		[pick("plasma research","high energy flux capacitance","super-compressed materials","theoretical particle physics")]. Nanotrasen is expected to announce a co-exploitation deal within the fortnight."

/datum/trade_destination/redolant
	name = "OAV Redolant"
	description = "Osiris Atmospherics station in orbit around the only gas giant in system. They retain tight control over shipping rights, and Osiris warships protecting their prize are not an uncommon sight in Tau Ceti."
	distance = 0.6
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(
		/datum/event_news/economic/corporate_attack,
		/datum/event_news/economic/industrial_accident,
		/datum/event_news/economic/pirates,
	)
	viable_mundane_events = list(
		/datum/event_news/research_breakthrough,
	)

/datum/trade_destination/beltway
	name = "Beltway mining chain"
	description = "A co-operative effort between Beltway and Nanotrasen to exploit the rich outer asteroid belt of the Tau Ceti system."
	distance = 7.5
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(
		/datum/event_news/economic/industrial_accident,
		/datum/event_news/economic/pirates,
	)
	viable_mundane_events = list(
		/datum/event_news/tourism,
	)

/datum/trade_destination/biesel
	name = "Biesel"
	description = "Large ship yards, strong economy and a stable, well-educated populace, Biesel largely owes allegiance to Sol / Vessel Contracting and begrudgingly tolerates NT. Capital is Lowell City."
	distance = 2.3
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(
		/datum/event_news/economic/biohazard_outbreak,
		/datum/event_news/economic/cult_cell_revealed,
		/datum/event_news/economic/festival,
		/datum/event_news/economic/industrial_accident,
		/datum/event_news/economic/mourning,
		/datum/event_news/economic/riots,
	)
	viable_mundane_events = list(
		/datum/event_news/bargains,
		/datum/event_news/celebrity_death,
		/datum/event_news/election,
		/datum/event_news/gossip,
		/datum/event_news/movie_release,
		/datum/event_news/resignation,
		/datum/event_news/song_debut,
		/datum/event_news/tourism,
	)

/datum/trade_destination/new_gibson
	name = "New Gibson"
	description = "Heavily industrialized rocky planet containing the majority of the planet-bound resources in the system, New Gibson is torn by unrest and has very little wealth to call it's own except in the hands of the corporations who jostle with NT for control."
	distance = 6.6
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(
		/datum/event_news/economic/biohazard_outbreak,
		/datum/event_news/economic/cult_cell_revealed,
		/datum/event_news/economic/festival,
		/datum/event_news/economic/industrial_accident,
		/datum/event_news/economic/mourning,
		/datum/event_news/economic/riots,
	)
	viable_mundane_events = list(
		/datum/event_news/election,
		/datum/event_news/resignation,
		/datum/event_news/tourism,
	)

/datum/trade_destination/luthien
	name = "Luthien"
	description = "A small colony established on a feral, untamed world (largely jungle). Savages and wild beasts attack the outpost regularly, although NT maintains tight military control."
	distance = 8.9
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(
		/datum/event_news/economic/alien_raiders,
		/datum/event_news/economic/animal_rights_raid,
		/datum/event_news/economic/cult_cell_revealed,
		/datum/event_news/economic/festival,
		/datum/event_news/economic/mourning,
		/datum/event_news/economic/wild_animal_attack,
	)
	viable_mundane_events = list(
		/datum/event_news/big_game_hunters,
		/datum/event_news/election,
		/datum/event_news/resignation,
		/datum/event_news/tourism,
	)

/datum/trade_destination/reade
	name = "Reade"
	description = "A cold, metal-deficient world, NT maintains large pastures in whatever available space in an attempt to salvage something from this profitless colony."
	distance = 7.5
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(
		/datum/event_news/economic/alien_raiders,
		/datum/event_news/economic/animal_rights_raid,
		/datum/event_news/economic/cult_cell_revealed,
		/datum/event_news/economic/festival,
		/datum/event_news/economic/mourning,
		/datum/event_news/economic/wild_animal_attack,
	)
	viable_mundane_events = list(
		/datum/event_news/big_game_hunters,
		/datum/event_news/election,
		/datum/event_news/resignation,
		/datum/event_news/tourism,
	)

/datum/trade_destination/xarxis
	name = "Xarxis"
	description = "The ocean planet of Xarxis is the homeworld of the gelatinous Slime People."
	distance = 6
	viable_random_events = list(
		/datum/event_news/economic/alien_raiders,
		/datum/event_news/economic/cult_cell_revealed,
		/datum/event_news/economic/industrial_accident,
		/datum/event_news/economic/festival,
		/datum/event_news/economic/mourning,
		/datum/event_news/economic/wild_animal_attack,
	)
	viable_mundane_events = list(
		/datum/event_news/election,
		/datum/event_news/research_breakthrough
	)

/datum/trade_destination/adhomai
	name = "Adhomai"
	description = "The Tajaran homeworld of Adhomai is a chilly tundra world dominated by taiga forests and snow-capped mountain ranges."
	distance = 1.6
	viable_random_events = list(
		/datum/event_news/economic/alien_raiders,
		/datum/event_news/economic/cult_cell_revealed,
		/datum/event_news/economic/festival,
		/datum/event_news/economic/industrial_accident,
		/datum/event_news/economic/mourning,
		/datum/event_news/economic/wild_animal_attack,
	)
	viable_mundane_events = list(
		/datum/event_news/big_game_hunters,
		/datum/event_news/election,
		/datum/event_news/resignation,
		/datum/event_news/tourism,
	)

/datum/trade_destination/qerballak
	name = "Qerballak"
	description = "The largest Skrell-majority nation in Orion, and one of the Spur's oldest extant states; the Royal Domain of Qerballak is a decentralized constitutional monarchy."
	distance = 4.5
	viable_random_events = list(
		/datum/event_news/economic/alien_raiders,
		/datum/event_news/economic/cult_cell_revealed,
		/datum/event_news/economic/festival,
		/datum/event_news/economic/industrial_accident,
		/datum/event_news/economic/mourning,
		/datum/event_news/economic/wild_animal_attack,
	)
	viable_mundane_events = list(
		/datum/event_news/big_game_hunters,
		/datum/event_news/election,
		/datum/event_news/resignation,
		/datum/event_news/tourism,
	)

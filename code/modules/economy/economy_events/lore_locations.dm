
GLOBAL_LIST_EMPTY(weighted_randomevent_locations)
GLOBAL_LIST_EMPTY(weighted_mundaneevent_locations)

/datum/lore_location
	var/name = ""
	var/description = ""
	var/list/viable_random_events = list()
	var/list/viable_mundane_events = list()

// MARK: Nanotrasen
/datum/lore_location/free_eridani_republic
	name = "Free Eridani Republic"
	description = "A puppet state controlled by Nanotrasen and centered around Epsilon Eridani. It is a laissez-faire free market corporatocracy with countless corporate entities operating within.\
	Regulations and laws are far looser than in any other major power, provided that no one steps on the toes of Nanotrasen."
	viable_random_events = list(
	/datum/event_news/placeholder_event
	)
	viable_mundane_events = list(
	/datum/event_news/generic_faction_anti_piracy,
	/datum/event_news/generic_faction_hyperspace_phenomina,
	)

/datum/lore_location/epsilon_eridani // YOU ARE HERE!
	name = "Epsilon Eridani"
	description = "The core system of the Free Eridani Repiblic, and the most profitable of Nanotrasen's holdings by a considerable margin. Centuries ago during the initial colonization of the system by the TSF, \
	the entire system disappeared in a massive bluespace translocation event and remained missing until a few years after the Cygini Crisis, when it reappeared hundreds of lightyears from its original location. \
	The characteristics of star and its orbiting planets all perfectly matched old records, and the remains of the original colonies were located, all having been wiped out centuries prior. \
	What did change was the sudden appearance of Epsilon Eridani II, colloqually known as \"Lavaland\". The bluespace phenomina and extreme mineral wealth of Lavaland prompted Nanotrasen to move in to \
	secure it for themselves, despite the considerable risks of operating in and around the planet."
	viable_random_events = list(
	/datum/event_news/generic_faction_anti_piracy,
	)
	viable_mundane_events = list(
	/datum/event_news/tourism,
	)

/datum/lore_location/centcomm
	name = "NAS Trurl"
	description = "Nanotrasen's administrative centre for Epsilon Eridani, usually referred to as \"Central Command\" or \"CentComm\"."
	viable_random_events = list(
	/datum/event_news/security_breach,
	)
	viable_mundane_events = list(
	/datum/event_news/tourism,
	)

/datum/lore_location/anansi
	name = "NSS Anansi"
	description = "Medical station ran by Second Green Cross (but owned by Nanotrasen) for handling emergency cases from nearby colonies."
	viable_random_events = list(
	/datum/event_news/virus_outbreak,
	/datum/event_news/blob_outbreak,
	/datum/event_news/terror_spider_outbreak,
	/datum/event_news/flock_outbreak,
	/datum/event_news/the_wizard,
	/datum/event_news/corporate_attack,
	/datum/event_news/nanotrasen_protests_stopped,
	)
	viable_mundane_events = list(
	/datum/event_news/security_breach,
	/datum/event_news/research_breakthrough_anansi,
	)

/datum/lore_location/icarus
	name = "NSV Icarus"
	description = "A corvette assigned to patrol the station's local space. It has several wings of experimental combat drones to assist in patrols."
	viable_random_events = list(
	/datum/event_news/the_wizard,
	/datum/event_news/corporate_attack,
	)
	viable_mundane_events = list(
	/datum/event_news/security_breach,
	)

/datum/lore_location/new_gibson
	name = "New Gibson"
	description = "A heavily industrialized rocky planet in the Free Eridani Republic containing extensive mining operations and other heavy industry. \
	New Gibson is torn by unrest and has very little wealth to call it's own, as despite the considerable value of the minerals and goods it produces, \
	corporate monopolies over all services has created a very efficient machine for putting whatever money workers manage to make right back into the hands that pay them."
	viable_random_events = list(
		/datum/event_news/nanotrasen_protests_stopped,
		/datum/event_news/riots,
		/datum/event_news/riots_stopped,
		/datum/event_news/security_breach,
		/datum/event_news/pirates,
		/datum/event_news/corporate_attack,
		/datum/event_news/alien_raiders,
		/datum/event_news/virus_outbreak,
		/datum/event_news/cult_cell_revealed,
		/datum/event_news/cult_ritual_stopped,
		/datum/event_news/vampire_attack,
		/datum/event_news/mindflayer_attack,
		/datum/event_news/changeling_attack,
	)
	viable_mundane_events = list(
		/datum/event_news/industrial_accident,
	)

/datum/lore_location/luthien
	name = "Luthien"
	description = "A feral, untamed world (largely jungle) within the Free Eridani Republic. A few heavilly fortified colonies dot the planet. \
	Many species of rare flora and fauna provide exciting research and pharmaceutical potential, and the planet is popular with thrill-seeking hunters and explorers. \
	Wild beasts attack the colonies regularly, although the tight military control maintained by Nanotrasen ensures mostly nominal safety and high public order."
	viable_random_events = list(
		/datum/event_news/virus_outbreak,
		/datum/event_news/alien_raiders,
		/datum/event_news/animal_rights_raid,
		/datum/event_news/ai_liberation,
		/datum/event_news/security_breach,
		/datum/event_news/corporate_attack,
		/datum/event_news/wild_animal_attack,
		/datum/event_news/celebrity_death,
	)
	viable_mundane_events = list(
		/datum/event_news/big_game_hunters,
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
	)

/datum/lore_location/reade
	name = "Reade"
	description = "A cold, metal-deficient world, Nanotrasen maintains large pastures in whatever available space in an attempt to salvage something from this profitless colony."
	viable_random_events = list(
		/datum/event_news/alien_raiders,
		/datum/event_news/animal_rights_raid,
		/datum/event_news/wild_animal_attack,
	)
	viable_mundane_events = list(
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
	)

// MARK: TSF
/datum/lore_location/tsf
	name = "Trans-Solar Federation"
	description = "The TSF, sometimes known as SolGov, is a unitary federal democracy and one of the largest superpowers in the Orion Arm. \
	Nanotrasen is technically incorporated here, but in reality prefers to base its critical operations away from SolGov's prying eyes."
	viable_random_events = list(
	/datum/event_news/tsf_new_fleet,
	)
	viable_mundane_events = list(
	/datum/event_news/generic_faction_anti_piracy,
	/datum/event_news/generic_faction_nanotrasen_fuel_cost,
	)

/datum/lore_location/earth
	name = "Earth"
	description = "The temperate planet of Earth is the homeworld of Humanity and the capitol of the Trans-Solar Federation."
	viable_random_events = list(
		/datum/event_news/industrial_accident,
		/datum/event_news/nanotrasen_protests,
		/datum/event_news/research_breakthrough,
	)
	viable_mundane_events = list(
		/datum/event_news/gossip,
		/datum/event_news/movie_release,
		/datum/event_news/song_debut,
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
		/datum/event_news/celebrity_death,
	)

/datum/lore_location/xarxis
	name = "Xarxis"
	description = "The ocean planet of Xarxis is the homeworld of the gelatinous Slime People. Due to its eccentric orbit, \
	it was once plagued by an unstable climate until Xarxis and the TSF constructed an orbital mirror and shade array to even out variations in solar gain."
	viable_random_events = list(
		/datum/event_news/industrial_accident,
		/datum/event_news/nanotrasen_protests,
		/datum/event_news/wild_animal_attack,
		/datum/event_news/research_breakthrough,
	)
	viable_mundane_events = list(
		/datum/event_news/gossip,
		/datum/event_news/movie_release,
		/datum/event_news/song_debut,
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
		/datum/event_news/celebrity_death,
		/datum/event_news/big_game_hunters,
	)

/datum/lore_location/biesel
	name = "Biesel"
	description = "Located in Tau Ceti. Large shipyards, strong economy and a stable, well-educated populace. Biesel owes allegiance to the Trans-Solar Federation and begrudgingly tolerates Nanotrasen."
	viable_random_events = list(
		/datum/event_news/industrial_accident,
		/datum/event_news/nanotrasen_protests,
		/datum/event_news/virus_outbreak,
		/datum/event_news/cult_cell_revealed,
		/datum/event_news/vampire_attack,
		/datum/event_news/mindflayer_attack,
		/datum/event_news/changeling_attack,
		/datum/event_news/security_breach,
		/datum/event_news/ai_liberation,
		/datum/event_news/research_breakthrough,
	)
	viable_mundane_events = list(
		/datum/event_news/gossip,
		/datum/event_news/movie_release,
		/datum/event_news/song_debut,
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
		/datum/event_news/celebrity_death,
		/datum/event_news/big_game_hunters,
	)

// MARK: USSP
/datum/lore_location/ussp
	name = "Union of Soviet Socialist Planets"
	description = "The USSP is federation of communist states that broke off from the TSF during the Cygni Crisis. \
	It maintains massive armed forces thanks to widespread conscription, allowing it to fend off larger powers and intimidate smaller ones. \
	Despite being ideologically opposed to everything Nanotrasen stands for, it is forced to conduct business with it thanks to Nanotrasen's near monopoly on the Plasma market."
	viable_random_events = list(
	/datum/event_news/ussp_mobilization,
	/datum/event_news/ussp_nian_deal,
	)
	viable_mundane_events = list(
	/datum/event_news/generic_faction_anti_piracy,
	/datum/event_news/generic_faction_nanotrasen_fuel_cost,
	/datum/event_news/generic_faction_hyperspace_phenomina,
	)

/datum/lore_location/cygini
	name = "Cygini Prime"
	description = "The snowswept planet of Cygini Prime was the birthplace of the Union of Soviet Socialist Planets during the Cygini Crisis, and continues to be its capitol. \
	It is a heavily industrialized world that maintains higher standards of living many surrounding USSP systems."
	viable_random_events = list(
		/datum/event_news/industrial_accident,
		/datum/event_news/nanotrasen_protests,
		/datum/event_news/research_breakthrough,
	)
	viable_mundane_events = list(
		/datum/event_news/movie_release,
		/datum/event_news/song_debut,
		/datum/event_news/celebrity_death,
	)

// MARK: Domain
/datum/lore_location/qerballak
	name = "Royal Domain of Qerballak"
	description = "The largest Skrell-majority nation in Orion, and one of the Spur's oldest extant states; the Royal Domain of Qerballak is a decentralized constitutional monarchy."
	viable_random_events = list(
	/datum/event_news/qerballak_monarch_decree,
	)
	viable_mundane_events = list(
	/datum/event_news/generic_faction_anti_piracy,
	/datum/event_news/generic_faction_nanotrasen_fuel_cost,
	/datum/event_news/generic_faction_hyperspace_phenomina,
	)

/datum/lore_location/crown
	name = "The Crown"
	description = "The Skrellian homeworld is a mostly water-covered planet dotted with island chains and atols, the great Skrellian cities are found beneath the oceans. \
	This seat of power of the Royal Domain of Qerballak's monarch."
	viable_random_events = list(
		/datum/event_news/nanotrasen_protests,
		/datum/event_news/research_breakthrough,
	)
	viable_mundane_events = list(
		/datum/event_news/gossip,
		/datum/event_news/movie_release,
		/datum/event_news/song_debut,
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
		/datum/event_news/celebrity_death,
	)

// MARK: Skkulakin
// Silver Collective
/datum/lore_location/silver_collective
	name = "Silver Collective"
	description = "The Collective is an ancient and powerful theocratic state that encompasses most of the Skkulakin species. Centred around the Brightworld of Votum-Accorium, \
	it has remained reclusive from the politics of the Orion Arm until a recent plasma crisis forced to open official dialogue with Nanotrasen."
	viable_random_events = list(
	/datum/event_news/silver_collective_interdiction
	)
	viable_mundane_events = list(
	/datum/event_news/generic_faction_anti_piracy,
	/datum/event_news/generic_faction_nanotrasen_fuel_cost,
	/datum/event_news/generic_faction_hyperspace_phenomina,
	)

/datum/lore_location/votum_accorium 
	name = "Votum-Accorium"
	description = "The mysterious homeworld of the Skkulakin, and the most important of their Brightworlds. The sprawling cities of this planet are fortresses against an eternal siege of whiteout blizards"
	viable_random_events = list(
		/datum/event_news/industrial_accident,
		/datum/event_news/wild_animal_attack,
		/datum/event_news/research_breakthrough,
		/datum/event_news/security_breach,
	)
	viable_mundane_events = list(
		/datum/event_news/big_game_hunters,
		/datum/event_news/movie_release,
		/datum/event_news/song_debut,
	)

// Artificers' Union
/datum/lore_location/artificers_union
	name = "Artificers' Union"
	description = "An officially sanctioned offshoot of the Silver Collective, the Artificer's Union is a secular state that operates a conventional corporate economy with government mediation. \
	It has existed long enough to have developed a substantially different technology base from its progenitor."
	viable_random_events = list(
	/datum/event_news/artificers_union_concrete_shortage
	)
	viable_mundane_events = list(
	/datum/event_news/generic_faction_anti_piracy,
	/datum/event_news/generic_faction_nanotrasen_fuel_cost,
	/datum/event_news/generic_faction_hyperspace_phenomina,
	)

// MARK: Kidan Anarchy
/datum/lore_location/kidan_anarchy
	name = "Kidan Anarchy"
	description = "The shattered remains of the once-proud Kidan Empire. It is now composed of many smaller kingdoms, all vying against each other for dominance and the right to reunite the empire under their banner. \
	While the chaos of the initial decades after the Kidan War has declined considerably, continued feuding and wars between the many Kidan kingdoms ensures the name continues to stick."
	viable_random_events = list(
	/datum/event_news/kidan_anarchy_dynastic_war,
	)
	viable_mundane_events = list(
	/datum/event_news/generic_faction_hyperspace_phenomina,
	)

/datum/lore_location/aurum
	name = "Aurum"
	description = "The barren homeworld of the Kidan. Once covered in sprawling hives and pastures for rearing diona nymphs, \
	it was subjected to a cataclysmic nuclear bombardment at the end of the Siege of Aurum in the closing act of the Kidan War. \
	Centuries later it remains mostly uninhabited, with only a sparse few archeological and scientific outposts dotting the surface."
	viable_random_events = list(
	/datum/event_news/aurum_unexploded_nuke,
	)
	viable_mundane_events = list(
	/datum/event_news/placeholder_event,
	)

// MARK: League of Kelune
/datum/lore_location/league_of_kelune
	name = "League of Kelune"
	description = "A cooperative organization of various Vulpkanin states. Kelune has limited actual power but wields considerable diplomatic influence and respect among its peer nations. \
	It is believed to be home to considerable reserves of unexploited plasma. Sabotage, and a mixture of poltical pressure and preferential prices for plasma fuel has thus far \
	rendered developing substantial domestic plasma extraction uneconomical."
	viable_random_events = list(
	/datum/event_news/league_of_kelune_silver_collective_talks
	)
	viable_mundane_events = list(
	/datum/event_news/generic_faction_anti_piracy,
	/datum/event_news/generic_faction_nanotrasen_fuel_cost,
	/datum/event_news/generic_faction_hyperspace_phenomina,
	)

/datum/lore_location/kelune
	name = "Kelune"
	description = "The adopted homeworld of the Vulpkanin, settled after the loss of their original homeworld of Altam. \
	It is a moon of a large gas giant, kept habitable thanks to tidal heating and a thick terraformed atmosphere."
	viable_random_events = list(
		/datum/event_news/industrial_accident,
		/datum/event_news/wild_animal_attack,
		/datum/event_news/changeling_attack,
		/datum/event_news/research_breakthrough,
	)
	viable_mundane_events = list(
		/datum/event_news/gossip,
		/datum/event_news/movie_release,
		/datum/event_news/song_debut,
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
		/datum/event_news/celebrity_death,
		/datum/event_news/big_game_hunters,
	)

// MARK: Other Locs
/**
/datum/lore_location/vox_arkship
	name = "Sunborn Sanctuary of Mended Hopes, Hardened by Cosmic Sands, Esteemed Heart of the Sanguine Void, Wizened by Victories, of Many Trees and Branches"
	description = "A vox arkship currently located near the Free Eridani Republic, but located firmly in neutral space. Many vox working at Epsilon Eridani originate from here."
	viable_random_events = list(
	/datum/event_news/placeholder_event
	)
	viable_mundane_events = list(
	/datum/event_news/placeholder_event
	)

/datum/lore_location/diona_reef
	name = "Diona Reef EE-N-03"
	description = "A large diona reef drifting through interstellar space near the Free Eridani Republic. \
	It is a living structure composed of millions of indivdual diona nymphs all connected in a single gestalt conciousness."
	viable_random_events = list(
	/datum/event_news/placeholder_event
	)
	viable_mundane_events = list(
	/datum/event_news/placeholder_event
	)
*/

/datum/lore_location/dom
	name = "Dom"
	description = "The Nian homeworld of Dom is tidally locked in orbit around a red dwarf star. \
	The light side is a mostly uninhabitable desert, while the dark side is a slightly more survivable tundra. \
	Most life can be found on the border region between these two zones, known as The Gloom."
	viable_random_events = list(
		/datum/event_news/nanotrasen_protests,
		/datum/event_news/alien_raiders,
		/datum/event_news/cult_cell_revealed,
		/datum/event_news/cult_ritual_stopped,
		/datum/event_news/industrial_accident,
		/datum/event_news/wild_animal_attack,
		/datum/event_news/research_breakthrough,
		/datum/event_news/security_breach,
	)
	viable_mundane_events = list(
		/datum/event_news/gossip,
		/datum/event_news/movie_release,
		/datum/event_news/song_debut,
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
		/datum/event_news/celebrity_death,
		/datum/event_news/big_game_hunters,
	)

/datum/lore_location/mauna_b
	name = "Mauna-b"
	description = "The adopted homeworld of the Grey, ruled over by The Technocracy. Mauna-b's equator is covered in enclosed colonies connected to each other by a sprawling rapid transit network."
	viable_random_events = list(
		/datum/event_news/security_breach,
		/datum/event_news/research_breakthrough,
	)
	viable_mundane_events = list(
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
	)

/datum/lore_location/new_canaan

	name = "New Canaan"
	description = "The adopted homeworld of IPCs, granted to them by Nanotrasen. The frigid and polluted climate of New Canaan does not bother the IPCs that call it home."
	viable_random_events = list(
		/datum/event_news/industrial_accident,
		/datum/event_news/mindflayer_attack,
		/datum/event_news/security_breach,
		/datum/event_news/research_breakthrough,
	)
	viable_mundane_events = list(
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
	)

/datum/lore_location/boron

	name = "Boron 2"
	description = "The homeworld of the Plasmamen, most notable for its extremely rich plasma reserves, oceans of liquid plasma, and atmosphere of plasma. Its primary export is plasma."
	viable_random_events = list(
		/datum/event_news/industrial_accident,
	)
	viable_mundane_events = list(
		/datum/event_news/nt_admiral_resignation,
	)

/datum/lore_location/moghes
	name = "Moghes"
	description = "The war-torn arid planet of Moghes is home to the Unathi."
	viable_random_events = list(
		/datum/event_news/moghes_clan_war,
		/datum/event_news/alien_raiders,
		/datum/event_news/cult_cell_revealed,
		/datum/event_news/industrial_accident,
		/datum/event_news/wild_animal_attack,
	)
	viable_mundane_events = list(
		/datum/event_news/big_game_hunters,
		/datum/event_news/tourism,
	)

/datum/lore_location/hoorlm
	name = "Hoorlm"
	description = "An iceball covered in ice sheets kilometers thick. Liquid water exists deep underground thanks to hydrothermal activity. The Drask call this planet home, living in massive subterranian cities."
	viable_random_events = list(
		/datum/event_news/research_breakthrough,
	)
	viable_mundane_events = list(
		/datum/event_news/nanotrasen_protests,
		/datum/event_news/gossip,
		/datum/event_news/movie_release,
		/datum/event_news/song_debut,
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
		/datum/event_news/celebrity_death,
	)

/datum/lore_location/adhomai
	name = "Adhomai"
	description = "The Tajaran homeworld of Adhomai is a chilly tundra world dominated by taiga forests and snow-capped mountain ranges."
	viable_random_events = list(
		/datum/event_news/nanotrasen_protests,
		/datum/event_news/alien_raiders,
		/datum/event_news/riots,
		/datum/event_news/riots_stopped,
		/datum/event_news/cult_cell_revealed,
		/datum/event_news/industrial_accident,
		/datum/event_news/wild_animal_attack,
	)
	viable_mundane_events = list(
		/datum/event_news/gossip,
		/datum/event_news/movie_release,
		/datum/event_news/song_debut,
		/datum/event_news/nt_admiral_resignation,
		/datum/event_news/tourism,
		/datum/event_news/celebrity_death,
		/datum/event_news/big_game_hunters,
	)

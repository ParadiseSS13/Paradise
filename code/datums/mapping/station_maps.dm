/datum/map/boxstation
	fluff_name = "NSS Cyberiad"
	technical_name = "BoxStation"
	map_path = "_maps/map_files/stations/boxstation.dmm"
	webmap_url = "https://webmap.affectedarc07.co.uk/maps/paradise/cyberiad/"
	welcome_sound = 'sound/AI/welcome_cyberiad.ogg'
	mundane_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/carp_migration/koi,	12),
	)
	moderate_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/carp_migration, 10, , TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/rogue_drone, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/solar_flare, 12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/meteor_wave, 8, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/dust/meaty, 8, _first_run_time = 40 MINUTES),
	)
	major_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/aurora_caelus, 5, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration/whale, 10, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/immovable_rod, 9, TRUE, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration, 13, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/meteor_wave, 9, TRUE, _first_run_time = 40 MINUTES),
	)

/datum/map/metastation
	fluff_name = "NSS Cerebron"
	technical_name = "MetaStation"
	map_path = "_maps/map_files/stations/metastation.dmm"
	webmap_url = "https://webmap.affectedarc07.co.uk/maps/paradise/metastation/"
	welcome_sound = 'sound/AI/welcome_cerebron.ogg'
	mundane_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/carp_migration/koi,	12),
	)
	moderate_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/carp_migration, 10, , TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/rogue_drone, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/solar_flare, 12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/meteor_wave, 8, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/dust/meaty, 8, _first_run_time = 40 MINUTES),
	)
	major_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/aurora_caelus, 5, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration/whale, 10, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/immovable_rod, 9, TRUE, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration, 13, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/meteor_wave, 9, TRUE, _first_run_time = 40 MINUTES),
	)

/datum/map/deltastation
	fluff_name = "NSS Kerberos"
	technical_name = "DeltaStation"
	map_path = "_maps/map_files/stations/deltastation.dmm"
	webmap_url = "https://webmap.affectedarc07.co.uk/maps/paradise/deltastation/"
	welcome_sound = 'sound/AI/welcome_kerberos.ogg'
	mundane_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/carp_migration/koi,	12),
	)
	moderate_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/carp_migration, 10, , TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/rogue_drone, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/solar_flare, 12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/meteor_wave, 8, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/dust/meaty, 8, _first_run_time = 40 MINUTES),
	)
	major_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/aurora_caelus, 5, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration/whale, 10, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/immovable_rod, 9, TRUE, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration, 13, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/meteor_wave, 9, TRUE, _first_run_time = 40 MINUTES),
	)

/datum/map/cerestation
	fluff_name = "NSS Farragus"
	technical_name = "CereStation"
	map_path = "_maps/map_files/stations/cerestation.dmm"
	webmap_url = "https://webmap.affectedarc07.co.uk/maps/paradise/cerestation/"
	min_players_random = 60
	welcome_sound = 'sound/AI/welcome_farragus.ogg'
	voteable = FALSE
	mundane_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/carp_migration/koi,	12),
	)
	moderate_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/carp_migration, 10, , TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/rogue_drone, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/solar_flare, 12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/meteor_wave, 8, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/dust/meaty, 8, _first_run_time = 40 MINUTES),
	)
	major_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/aurora_caelus, 5, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration/whale, 10, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/immovable_rod, 9, TRUE, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration, 13, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/meteor_wave, 9, TRUE, _first_run_time = 40 MINUTES),
	)

/datum/map/emeraldstation
	fluff_name = "NSS Diagoras"
	technical_name = "EmeraldStation"
	map_path = "_maps/map_files/stations/emeraldstation.dmm"
	webmap_url = "https://webmap.affectedarc07.co.uk/maps/paradise/emeraldstation/"
	min_players_random = 60
	welcome_sound = 'sound/AI/welcome_diagoras.ogg'
	voteable = FALSE
	mundane_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/carp_migration/koi,	12),
	)
	moderate_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/carp_migration, 10, , TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/rogue_drone, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/solar_flare, 12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/meteor_wave, 8, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/dust/meaty, 8, _first_run_time = 40 MINUTES),
	)
	major_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/aurora_caelus, 5, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration/whale, 10, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/immovable_rod, 9, TRUE, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration, 13, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/meteor_wave, 9, TRUE, _first_run_time = 40 MINUTES),
	)

#warn adjust all these before release

/datum/map/prototypestation
	fluff_name = "Avernus Complex"
	technical_name = "PrototypeStation"
	map_path = "_maps/map_files/stations/prototypestation.dmm"
	linkage = UNAFFECTED
	level_names = list(
		SUB_STATION,
		MAIN_STATION,
	)
	level_traits = list(
		list(STATION_LEVEL, STATION_CONTACT, REACHABLE_BY_CREW, AI_OK, ZTRAIT_LOWER_LEVEL),
		list(STATION_LEVEL, STATION_CONTACT, REACHABLE_BY_CREW, AI_OK, ZTRAIT_UPPER_LEVEL, ZTRAIT_WINTER_LEVEL),
	)
	moderate_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/sleet_storm, 12),
	)

/datum/map/omegastation
	fluff_name = "NSS Legaria"
	technical_name = "OmegaStation"
	map_path = "_maps/map_files/stations/omegastation.dmm"
	webmap_url = "https://webmap.affectedarc07.co.uk/maps/paradise/omegastation/"
	max_players_random = 25
	mundane_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/carp_migration/koi,	12),
	)
	moderate_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/carp_migration, 10, , TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/rogue_drone, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/solar_flare, 12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/meteor_wave, 8, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/dust/meaty, 8, _first_run_time = 40 MINUTES),
	)
	major_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/aurora_caelus, 5, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration/whale, 10, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/immovable_rod, 9, TRUE, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration, 13, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/meteor_wave, 9, TRUE, _first_run_time = 40 MINUTES),
	)

/datum/map/test_tiny
	fluff_name = "test_tiny"
	technical_name = "test_tiny"
	map_path = "_maps/map_files/test_tiny/test_tiny.dmm"
	voteable = FALSE

/datum/map/test_tgui
	fluff_name = "test_tgui"
	technical_name = "test_tgui"
	map_path = "_maps/map_files/test_tiny/test_tgui.dmm"
	voteable = FALSE

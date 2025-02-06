/datum/antag_scenario/team/vox_raiders
	name = "Vox Raider"
	config_tag = "vox_raiders"
	abstract = FALSE
	antag_role = ROLE_VOX_RAIDER
	antag_special_role = SPECIAL_ROLE_VOX_RAIDER
	antag_datum = /datum/antagonist/vox_raider
	required_players = 45
	cost = 45
	candidates_required = 2
	antag_team = /datum/team/vox_raiders
	weight = 1
	antag_cap = 4	// 1 команда на сценарий из 2-4 воксов
	team_size = 4
	candidates_required = 2
	execution_once = TRUE

	is_crew_antag = FALSE
	landmark_type = /obj/effect/landmark/spawner/vox_raider
	possible_species = list("Vox")
	recommended_species_active_pref = list("Vox")
	recommended_species_mod = 8


/datum/antag_scenario/team/vox_raiders/equip_character(datum/mind/mind)
	. = ..()
	var/mob/living/carbon/human/H = mind.current
	if(H)
		H.equipOutfit(/datum/outfit/vox)
		H.faction = list("Vox")
	mind.offstation_role = TRUE

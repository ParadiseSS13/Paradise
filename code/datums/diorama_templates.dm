/datum/map_template/diorama
	var/description
	var/diorama_id

/datum/map_template/diorama/snowy
	name = "Snowy Diorama"
	description = "'Santa's Secret Surprise' by haydenredacted"
	mappath = "_maps/map_files/dioramas/snowy_diorama.dmm"

/datum/map_template/diorama/lavaland
	name = "Lavaland Diorama"
	description = "'A Day on Lavaland' by haydenredacted"
	mappath = "_maps/map_files/dioramas/lavaland_diorama.dmm"

/datum/map_template/diorama/byod
	name = "Build Your Own Diorama"
	description = "'Build Your Own Diorama' by haydenredacted"
	mappath = "_maps/map_files/dioramas/byod_diorama.dmm"

/obj/item/paper/diorama/byod
	name = "screw you, i quit, make your own damn diorama"

/datum/map_template/diorama/vet
	name = "Vet Visit Diorama"
	description = "'Vet Visit Diorama' by haydenredacted"
	mappath = "_maps/map_files/dioramas/vet_diorama.dmm"

/datum/map_template/diorama/borg
	name = "A Cyborg's Creation Diorama"
	description = "'A Cyborg's Creation Diorama' by haydenredacted"
	mappath = "_maps/map_files/dioramas/borg_diorama.dmm"

/datum/map_template/diorama/decisions
	name = "Making Decisions Diorama"
	description = "'Making Decisions' by Alfalfa Scout"
	mappath = "_maps/map_files/dioramas/making_decisions_diorama.dmm"

/obj/structure/diorama_sign
	name = "Diorama Sign"
	desc = ""
	icon_state = "floor_sign"

/// Areas are preferred to be made here instead of using pre-existing ones so nothing is connected to anything on a non CC z-level.
/area/centcom/diorama
	name = "Blank Diorama"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/centcom/diorama/borg
	name = "Borg Diorama"

/area/centcom/diorama/lavaland
	name = "Lavaland Diorama"
	icon_state = "explored"

/area/centcom/diorama/snowy
	name = "Snowy Diorama"
	icon_state = "yellow"

/area/centcom/diorama/byod
	name = "Build Your Own Diorama"

/area/centcom/diorama/vet
	name = "Vet Visit Diorama"

/area/centcom/diorama/decisions
	name = "Makign Decisions Diorama"
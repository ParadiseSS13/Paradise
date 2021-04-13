// IPC Monitors that use eyes/optics
/datum/sprite_accessory/body_markings/head/optics
	// Standard Optics
	name = "Humanoid Optics"
	icon = 'icons/mob/sprite_accessories/ipc/ipc_optics.dmi'
	icon_state = "optics"
	species_allowed = list("Machine")
	models_allowed = list("Bishop Cybernetics", "Hesphiastos Industries", "Nanotrasen Modular Mechanics", "Ward-Takahashi", "Xion Manufacturing Group", "Zeng-Hu Pharmaceuticals", "Zeng-Hu Spirit")

/datum/sprite_accessory/body_markings/head/optics/bishop_alt
	name = "Bishop Cybernetics Optics"
	icon_state = "bishop_alt_optics"
	models_allowed = list("Bishop Knight")

/datum/sprite_accessory/body_markings/head/optics/morpheus_alt
	name = "Morpheus Cyberkinetics Optics"
	icon_state = "morpheus_alt_optics"
	models_allowed = list("Cyberkinetics Sport")

/datum/sprite_accessory/body_markings/head/optics/wardtakahashi_alt
	name = "Ward-Takahashi Optics"
	icon_state = "wardtakahashi_alt_optics"
	models_allowed = list("Alternative Efficiency")

/datum/sprite_accessory/body_markings/head/optics/xion_alt
	name = "Xion Manufacturing Group Optics"
	icon_state = "xion_alt_optics"
	models_allowed = list("Economy Standard")

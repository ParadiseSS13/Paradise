/obj/effect/landmark/spawner/vox_raider
	name = "Vox Raider"
	icon = 'modular_ss220/antagonists/icons/landmark.dmi'
	icon_state = "vox_raider"

/obj/effect/landmark/spawner/vox_raider/Initialize(mapload)
	. = ..()
	GLOB.raider_spawn += src

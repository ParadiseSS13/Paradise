/obj/effect/landmark/awaystart
	name = "awaystart"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "Assistant"

INITIALIZE_IMMEDIATE(/obj/effect/landmark/awaystart) //Without this away missions break

/obj/effect/landmark/awaystart/Initialize(mapload)
	GLOB.awaydestinations.Add(src)
	return ..()

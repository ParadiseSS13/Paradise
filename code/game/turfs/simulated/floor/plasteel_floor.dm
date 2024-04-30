/turf/simulated/floor/plasteel
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/simulated/floor/plasteel/update_icon_state()
	if(!broken && !burnt)
		icon_state = icon_regular_floor

/turf/simulated/floor/plasteel/get_broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/simulated/floor/plasteel/airless
	name = "airless floor"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_LATTICE)

/turf/simulated/floor/plasteel/airless/Initialize(mapload)
	. = ..()
	name = "floor"

/// For bomb testing range
/turf/simulated/floor/plasteel/airless/indestructible

/turf/simulated/floor/plasteel/airless/indestructible/ex_act(severity)
	return

/turf/simulated/floor/plasteel/goonplaque
	name = "Commemorative Plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."
	icon_state = "plaque"

/turf/simulated/floor/plasteel/goonplaque/memorial
	name = "Memorial Plaque"
	desc = "\"This is a plaque in honour of those who died in the great space lube airlock incident.\" Scratched in beneath that is a crude image of a clown and a spaceman. The spaceman is slipping. The clown is laughing."

/turf/simulated/floor/plasteel/goonplaque/commission
	name = "Commission Plaque"
	desc = "Epsilon Eridani Sector - 'Meta' Class Outpost - Commissioned 11/03/2557 - NSS Cerebron"

/turf/simulated/floor/plasteel/goonplaque/nosey
	name = "Nosey little bastard aren't you?"
	desc = "Nosey little bastard aren't you?"

/turf/simulated/floor/plasteel/goonplaque/violence
	name = "Violence Free Area"
	desc = "Violence Free Area"

//TODO: Make subtypes for all normal turf icons
/turf/simulated/floor/plasteel/white
	icon_state = "white"
/turf/simulated/floor/plasteel/white/side
	icon_state = "whitehall"
/turf/simulated/floor/plasteel/white/corner
	icon_state = "whitecorner"

/turf/simulated/floor/plasteel/dark
	icon_state = "darkfull"

/turf/simulated/floor/plasteel/dark/telecomms
	nitrogen = 100
	oxygen = 0
	temperature = 80

/turf/simulated/floor/plasteel/dark/nitrogen
	nitrogen = 100
	oxygen = 0

/turf/simulated/floor/plasteel/freezer
	icon_state = "freezerfloor"

/turf/simulated/floor/plasteel/stairs
	icon_state = "stairs"
/turf/simulated/floor/plasteel/stairs/left
	icon_state = "stairs-l"
/turf/simulated/floor/plasteel/stairs/medium
	icon_state = "stairs-m"
/turf/simulated/floor/plasteel/stairs/right
	icon_state = "stairs-r"
/turf/simulated/floor/plasteel/stairs/old
	icon_state = "stairs-old"

/turf/simulated/floor/plasteel/grimy
	icon_state = "grimy"

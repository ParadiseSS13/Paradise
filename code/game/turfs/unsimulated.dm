/turf/unsimulated
	intact = 1
	name = "command"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/unsimulated/can_lay_cable()
	return 0

/turf/unsimulated/rpd_act()
	return

/turf/unsimulated/acid_act(acidpwr, acid_volume, acid_id)
	return 0

/turf/unsimulated/floor/plating/vox
	icon_state = "plating"
	name = "plating"
	nitrogen = 100
	oxygen = 0

/turf/unsimulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	temperature = T0C
	footstep_sounds = list(
	"human" = list('sound/effects/footstep/carpet3.ogg','sound/effects/footstep/carpet5.ogg'),
	"xeno"  = list('sound/effects/footstep/carpet3.ogg','sound/effects/footstep/carpet5.ogg')
	)

/turf/unsimulated/floor/plating/snow/concrete
	name = "concrete"
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete"

/turf/unsimulated/floor/plating/snow/ex_act(severity)
	return

/turf/unsimulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/unsimulated/floor/plating/airless/Initialize(mapload)
	. = ..()
	name = "plating"

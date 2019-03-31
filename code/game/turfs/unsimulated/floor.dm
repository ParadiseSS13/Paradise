/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/floor/grass
	name = "grass patch"
	icon_state = "grass1"

/turf/unsimulated/floor/grass/New()
	..()
	icon_state = "grass[rand(1,4)]"

/turf/unsimulated/floor/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/unsimulated/floor/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/unsimulated/floor/abductor/New()
	..()
	icon_state = "alienpod[rand(1,9)]"

/turf/unsimulated/floor/vox
	icon_state = "dark"
	nitrogen = 100
	oxygen = 0

/turf/unsimulated/floor/carpet
	name = "Carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	smooth = SMOOTH_TRUE
	canSmoothWith = null

	footstep_sounds = list(
		"human" = list('sound/effects/footstep/carpet_human.ogg'),
		"xeno"  = list('sound/effects/footstep/carpet_xeno.ogg')
	)

/turf/unsimulated/floor/wood
	icon_state = "wood"

	footstep_sounds = list(
		"human" = list('sound/effects/footstep/wood_all.ogg'), //@RonaldVanWonderen of Freesound.org
		"xeno"  = list('sound/effects/footstep/wood_all.ogg')  //@RonaldVanWonderen of Freesound.org
	)

/turf/unsimulated/floor/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon = 'icons/turf/floors.dmi'
	icon_state = "necro1"
	baseturf = /turf/unsimulated/floor/necropolis
	oxygen = 14
	nitrogen = 23
	temperature = 300

/turf/unsimulated/floor/necropolis/Initialize()
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/unsimulated/floor/necropolis/air
	oxygen = 0
	nitrogen = 0
	temperature = T20C

/turf/unsimulated/floor/boss //you put stone tiles on this and use it as a base
	name = "necropolis floor"
	icon = 'icons/turf/floors/boss_floors.dmi'
	icon_state = "boss"
	baseturf = /turf/unsimulated/floor/boss
	oxygen = 14
	nitrogen = 23
	temperature = 300

/turf/unsimulated/floor/boss/air
	oxygen = 0
	nitrogen = 0
	temperature = T20C

/turf/unsimulated/floor/hierophant
	icon_state = "hierophant1"
	oxygen = 14
	nitrogen = 23
	temperature = 300
	desc = "A floor with a square pattern. It's faintly cool to the touch."

/turf/unsimulated/floor/hierophant/two
	icon_state = "hierophant2"

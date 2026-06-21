// Some various defines used in the heretic sacrifice map.

/// A global assoc list of all landmarks that denote a heretic sacrifice location. [string heretic path] = [landmark].
GLOBAL_LIST_EMPTY(heretic_sacrifice_landmarks)

/// Lardmarks meant to designate where heretic sacrifices are sent.
/obj/effect/landmark/heretic
	name = "default heretic sacrifice landmark"
	icon_state = "x"
	/// What path this landmark is intended for.
	var/for_heretic_path = PATH_START

/obj/effect/landmark/heretic/Initialize(mapload)
	. = ..()
	GLOB.heretic_sacrifice_landmarks[for_heretic_path] = src

/obj/effect/landmark/heretic/Destroy()
	GLOB.heretic_sacrifice_landmarks[for_heretic_path] = null
	return ..()

/obj/effect/landmark/heretic/ash
	name = "ash heretic sacrifice landmark"
	for_heretic_path = PATH_ASH

/obj/effect/landmark/heretic/flesh
	name = "flesh heretic sacrifice landmark"
	for_heretic_path = PATH_FLESH

/obj/effect/landmark/heretic/void
	name = "void heretic sacrifice landmark"
	for_heretic_path = PATH_VOID

/obj/effect/landmark/heretic/rust
	name = "rust heretic sacrifice landmark"
	for_heretic_path = PATH_RUST

/obj/effect/landmark/heretic/lock
	name = "lock heretic sacrifice landmark"
	for_heretic_path = PATH_LOCK

/obj/effect/landmark/heretic/moon
	name = "moon heretic sacrifice landmark"
	for_heretic_path = PATH_MOON

/obj/effect/landmark/heretic/cosmic
	name = "cosmic heretic sacrifice landmark"
	for_heretic_path = PATH_COSMIC

/obj/effect/landmark/heretic/blade
	name = "blade heretic sacrifice landmark"
	for_heretic_path = PATH_BLADE


/obj/structure/signpost/void
	name = "signpost at the edge of the universe"
	desc = "A direction in the directionless cosmos."
	/// Brightness of the signpost.
	var/range = 2
	/// Light power of the signpost.
	var/power = 0.8

/obj/structure/signpost/void/Initialize(mapload)
	. = ..()
	set_light(range, power)

// Some VERY dim lights, used for the void sacrifice realm.
/obj/machinery/light/very_dim
	nightshift_allowed = FALSE
	brightness_color = "#d6b6a6ff"
	brightness_range = 3
	brightness_power = 0.5

/obj/machinery/light/very_dim/directional/north
	dir = NORTH

/obj/machinery/light/very_dim/directional/south
	dir = SOUTH

/obj/machinery/light/very_dim/directional/east
	dir = EAST

/obj/machinery/light/very_dim/directional/west
	dir = WEST

// Rooms for where heretic sacrifices send people.
/area/centcom/heretic_sacrifice
	name = "Mansus"
	icon_state = "heretic"
	sound_environment = SOUND_ENVIRONMENT_CAVE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/centcom/heretic_sacrifice/Initialize(mapload)
	ambientsounds = list('sound/ambience/ambireebe1.ogg',
						'sound/ambience/ambireebe2.ogg',
						'sound/ambience/ambireebe3.ogg',)
	return ..()

/area/centcom/heretic_sacrifice/ash //also, the default
	name = "Mansus Ash Gate"

/area/centcom/heretic_sacrifice/void
	name = "Mansus Void Gate"
	sound_environment = SOUND_ENVIRONMENT_UNDERWATER

/area/centcom/heretic_sacrifice/void/Initialize(mapload)
	ambientsounds = list('sound/ambience/ambireebe1.ogg',
						'sound/ambience/ambireebe2.ogg',
						'sound/ambience/ambireebe3.ogg',
						'sound/ambience/antag/heretic/VoidsEmbrace.ogg' //a little void, in the end...
						)
	return ..()

/area/centcom/heretic_sacrifice/flesh
	name = "Mansus Flesh Gate"
	sound_environment = SOUND_ENVIRONMENT_STONEROOM

/area/centcom/heretic_sacrifice/rust
	name = "Mansus Rust Gate"
	sound_environment = SOUND_ENVIRONMENT_SEWER_PIPE

/area/centcom/heretic_sacrifice/lock
	name = "Mansus Lock Gate"
	sound_environment = SOUND_ENVIRONMENT_PSYCHOTIC

/area/centcom/heretic_sacrifice/cosmic
	name = "Mansus Cosmic Gate"
	sound_environment = SOUND_ENVIRONMENT_UNDERWATER

/area/centcom/heretic_sacrifice/blade
	name = "Mansus Blade Gate"
	sound_environment = SOUND_ENVIRONMENT_ARENA

/area/centcom/heretic_sacrifice/moon
	name = "Mansus Moon Gate"
	sound_environment = SOUND_ENVIRONMENT_AUDITORIUM

/area/centcom/heretic_sacrifice/moon/Initialize(mapload)
	ambientsounds = list('sound/ambience/ambireebe1.ogg',
						'sound/ambience/ambireebe2.ogg',
						'sound/ambience/ambireebe3.ogg',
						'sound/effects/moon_parade.ogg' //a little moon, why not
						)
	return ..()

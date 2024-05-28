
/datum/mob_type
	var/name = "Typeless"
	var/list/weakness = list()
	var/list/resistance = list()
	var/list/immunity = list()

	//Type-based spawn preferences (to eliminate copy-pasting the same area and turf lists on each mob type)
	var/list/area_blacklist = list()	//areas to be avoided
	var/list/area_whitelist = list()	//areas to be more preferred
	var/list/turf_blacklist = list()	//turf types to be avoided
	var/list/turf_whitelist = list()	//turf types to be more preferred

//Type defines, to avoid spelling mistakes
/datum/mob_type/fire
	name = "Fire"
	weakness = list(NANOMOB_TYPE_WATER,
					NANOMOB_TYPE_ROCK,
					NANOMOB_TYPE_GROUND)
	resistance = list(NANOMOB_TYPE_BUG,
					NANOMOB_TYPE_FIRE,
					NANOMOB_TYPE_GRASS,
					NANOMOB_TYPE_ICE,
					NANOMOB_TYPE_STEEL)
	area_blacklist = list(/area/station/public/toilet,
						/area/station/science/server/coldroom)
	area_whitelist = list(/area/station/maintenance/turbine,
						/area/station/maintenance/incinerator,
						/area/station/service/kitchen)
	turf_blacklist = list(/turf/simulated/floor/beach/water)

/datum/mob_type/water
	name = "Water"
	weakness = list(NANOMOB_TYPE_ELECTRIC,
					NANOMOB_TYPE_GRASS)
	resistance = list(NANOMOB_TYPE_FIRE,
					NANOMOB_TYPE_ICE,
					NANOMOB_TYPE_STEEL,
					NANOMOB_TYPE_WATER)
	area_blacklist = list(/area/station/maintenance/turbine,
						/area/station/maintenance/incinerator,
						/area/station/service/kitchen)
	area_whitelist = list(/area/station/public/toilet)
	turf_whitelist = list(/turf/simulated/floor/beach/water)

/datum/mob_type/grass
	name = "Grass"
	weakness = list(NANOMOB_TYPE_FIRE,
					NANOMOB_TYPE_BUG,
					NANOMOB_TYPE_POISON,
					NANOMOB_TYPE_ICE,
					NANOMOB_TYPE_FLYING)
	resistance = list(NANOMOB_TYPE_WATER,
					NANOMOB_TYPE_GRASS,
					NANOMOB_TYPE_ELECTRIC,
					NANOMOB_TYPE_GROUND)
	area_blacklist = list(/area/station/science)
	area_whitelist = list(/area/station/service/hydroponics,
						/area/station/public/construction) // dont ask me why grass types can appear in construction sites, I'm just migrating areas
	turf_whitelist = list(/turf/simulated/floor/grass)

/datum/mob_type/electric
	name = "Electric"
	weakness = list(NANOMOB_TYPE_GROUND)
	resistance = list(NANOMOB_TYPE_ELECTRIC,
					NANOMOB_TYPE_FLYING,
					NANOMOB_TYPE_STEEL)
	area_whitelist = list(/area/station/engineering/engine,
						/area/station/science/server,
						/area/station/maintenance,
						/area/station/turret_protected/ai,
						/area/station/turret_protected/ai_upload,
						/area/station/turret_protected/aisat/interior,
						/area/station/aisat,
						/area/station/science/robotics)
	turf_whitelist = list(/turf/simulated/floor/bluegrid)

/datum/mob_type/ground
	name = "Ground"
	weakness = list(NANOMOB_TYPE_WATER,
					NANOMOB_TYPE_GRASS,
					NANOMOB_TYPE_ICE)
	resistance = list(NANOMOB_TYPE_ROCK,
					NANOMOB_TYPE_POISON)
	immunity = list(NANOMOB_TYPE_ELECTRIC)

/datum/mob_type/rock
	name = "Rock"
	weakness = list(NANOMOB_TYPE_WATER,
					NANOMOB_TYPE_GRASS,
					NANOMOB_TYPE_GROUND,
					NANOMOB_TYPE_FIGHTING,
					NANOMOB_TYPE_STEEL)
	resistance = list(NANOMOB_TYPE_FIRE,
					NANOMOB_TYPE_FLYING,
					NANOMOB_TYPE_POISON,
					NANOMOB_TYPE_NORMAL)
	area_whitelist = list(/area/station/supply,
						/area/station/maintenance/disposal)
	turf_whitelist = list(/turf/simulated/wall,
						/turf/simulated/floor/mineral)

/datum/mob_type/bug
	name = "Bug"
	weakness = list(NANOMOB_TYPE_FIRE,
					NANOMOB_TYPE_ROCK,
					NANOMOB_TYPE_FLYING)
	resistance = list(NANOMOB_TYPE_GRASS,
					NANOMOB_TYPE_GROUND,
					NANOMOB_TYPE_FIGHTING)
	area_blacklist = list(/area/station/science)
	area_whitelist = list(/area/station/service/hydroponics,
						/area/station/public/construction) // dont ask me why bug types can appear in construction sites, I'm just migrating areas
	turf_whitelist = list(/turf/simulated/floor/grass)

/datum/mob_type/poison
	name = "Poison"
	weakness = list(NANOMOB_TYPE_GROUND,
					NANOMOB_TYPE_PSYCHIC)
	resistance = list(NANOMOB_TYPE_GRASS,
					NANOMOB_TYPE_BUG,
					NANOMOB_TYPE_POISON,
					NANOMOB_TYPE_FIGHTING)
	area_blacklist = list(/area/station/medical,
						/area/station/service/janitor)
	area_whitelist = list(/area/station/medical/virology,
						/area/station/science,
						/area/station/command/office/rd,
						/area/station/maintenance/asmaint2)

/datum/mob_type/normal
	name = "Normal"
	weakness = list(NANOMOB_TYPE_FIGHTING)
	immunity = list(NANOMOB_TYPE_GHOST)

/datum/mob_type/fighting
	name = "Fighting"
	weakness = list(NANOMOB_TYPE_PSYCHIC,
					NANOMOB_TYPE_FLYING)
	resistance = list(NANOMOB_TYPE_ROCK,
					NANOMOB_TYPE_BUG,
					NANOMOB_TYPE_DARK)
	area_blacklist = list(/area/station/medical)
	area_whitelist = list(/area/station/service/bar,
						/area/station/public/fitness,
						/area/station/security)
	turf_whitelist = list(/turf/simulated/floor/wood)

/datum/mob_type/psychic
	name = "Psychic"
	weakness = list(NANOMOB_TYPE_BUG,
					NANOMOB_TYPE_GHOST,
					NANOMOB_TYPE_DARK)
	resistance = list(NANOMOB_TYPE_FIGHTING,
					NANOMOB_TYPE_PSYCHIC)
	area_blacklist = list(/area/station/science,
						/area/station/command/office/rd,
						/area/station/maintenance/asmaint2,
						/area/station/command/teleporter,
						/area/station/command/gateway)
	area_whitelist = list(/area/station/service/library,
						/area/station/service/chapel,
						/area/station/medical/psych)

/datum/mob_type/ghost
	name = "Ghost"
	weakness = list(NANOMOB_TYPE_GHOST,
					NANOMOB_TYPE_DARK)
	resistance = list(NANOMOB_TYPE_BUG,
					NANOMOB_TYPE_POISON)
	immunity = list(NANOMOB_TYPE_NORMAL,
					NANOMOB_TYPE_FIGHTING)
	area_whitelist = list(/area/station/medical/morgue,
						/area/station/service/chapel,
						/area/station/medical/cloning)

/datum/mob_type/ice
	name = "Ice"
	weakness = list(NANOMOB_TYPE_FIRE,
					NANOMOB_TYPE_ROCK,
					NANOMOB_TYPE_FIGHTING,
					NANOMOB_TYPE_STEEL)
	resistance = list(NANOMOB_TYPE_ICE)
	area_blacklist = list(/area/station/maintenance/turbine,
						/area/station/maintenance/incinerator,
						/area/station/service/kitchen)
	area_whitelist = list(/area/station/science/server/coldroom)

/datum/mob_type/flying
	name = "Flying"
	weakness = list(NANOMOB_TYPE_ELECTRIC,
					NANOMOB_TYPE_ROCK,
					NANOMOB_TYPE_ICE)
	resistance = list(NANOMOB_TYPE_GRASS,
					NANOMOB_TYPE_BUG,
					NANOMOB_TYPE_FIGHTING)
	immunity = list(NANOMOB_TYPE_GROUND)
	area_blacklist = list(/area/station/maintenance)
	area_whitelist = list(/area/station/hallway)

/datum/mob_type/bluespace
	name = "Bluespace"
	weakness = list(NANOMOB_TYPE_ICE,
					NANOMOB_TYPE_BLUESPACE)
	resistance = list(NANOMOB_TYPE_FIRE,
					NANOMOB_TYPE_WATER,
					NANOMOB_TYPE_GRASS,
					NANOMOB_TYPE_ELECTRIC)

/datum/mob_type/dark
	name = "Dark"
	weakness = list(NANOMOB_TYPE_BUG,
					NANOMOB_TYPE_FIGHTING)
	resistance = list(NANOMOB_TYPE_GHOST,
					NANOMOB_TYPE_DARK)
	immunity = list(NANOMOB_TYPE_PSYCHIC)
	area_blacklist = list(/area/station/engineering/solar,
						/area/station/maintenance/auxsolarport,
						/area/station/maintenance/starboardsolar,
						/area/station/maintenance/portsolar,
						/area/station/maintenance/auxsolarstarboard,
						/area/station/service/clown)
	area_whitelist = list(/area/station/maintenance,
						/area/station/service/mime)
	turf_blacklist = list(/turf/simulated/floor/light)

/datum/mob_type/steel
	name = "Steel"
	weakness = list(NANOMOB_TYPE_FIRE,
					NANOMOB_TYPE_GROUND,
					NANOMOB_TYPE_FIGHTING)
	resistance = list(NANOMOB_TYPE_GRASS,
					NANOMOB_TYPE_ROCK,
					NANOMOB_TYPE_BUG,
					NANOMOB_TYPE_NORMAL,
					NANOMOB_TYPE_PSYCHIC,
					NANOMOB_TYPE_ICE,
					NANOMOB_TYPE_FLYING,
					NANOMOB_TYPE_BLUESPACE,
					NANOMOB_TYPE_STEEL)
	immunity = list(NANOMOB_TYPE_POISON)

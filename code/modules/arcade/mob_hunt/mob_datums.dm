
#define TYPE_FIRE /datum/mob_type/fire
#define TYPE_WATER /datum/mob_type/water
#define TYPE_GRASS /datum/mob_type/grass
#define TYPE_ELECTRIC /datum/mob_type/electric
#define TYPE_GROUND /datum/mob_type/ground
#define TYPE_ROCK /datum/mob_type/rock
#define TYPE_BUG /datum/mob_type/bug
#define TYPE_POISON /datum/mob_type/poison
#define TYPE_NORMAL /datum/mob_type/normal
#define TYPE_FIGHTING /datum/mob_type/fighting
#define TYPE_PSYCHIC /datum/mob_type/psychic
#define TYPE_GHOST /datum/mob_type/ghost
#define TYPE_ICE /datum/mob_type/ice
#define TYPE_FLYING /datum/mob_type/flying
#define TYPE_BLUESPACE /datum/mob_type/bluespace
#define TYPE_DARK /datum/mob_type/dark
#define TYPE_STEEL /datum/mob_type/steel

/datum/mob_hunt
	//GENERAL STATS AND VARIABLES
	var/mob_name = "Generic Mob"			//the mob's original name (its species/type/whatever)
	var/nickname = ""						//the mob's nickname (if given by the owner)
	var/run_chance = 0						//percent chance the mob will escape capture attempts (higher is obviously more likely to get away)

	//COMBAT STATS AND VARIABLES
	var/level = 0							//actual level of this mob (don't set this, it gets overwritten in New())
	var/min_level = 1						//minimum level of this mob (used for randomizing the actual level)
	var/max_level = 1						//maximum level of this mob (used for randomizing the actual level)
	//the types of the mob will be used for battles to determine damage resistance or weakness (mob_type_datums.dm)
	var/datum/mob_type/primary_type			//Make sure you set this or the mob will be unable to deal damage and will take absurd damage in battles
	var/datum/mob_type/secondary_type		//Don't set if not a dual-type mob so the mob will only calculate damage based on primary type
	var/base_attack = 5						//base damage dealt by the mob's attacks for battling (effectively damage dealt at level 0)
	var/base_health = 5						//base health of the mob for battling (effectively max health at level 0)
	var/attack_multiplier = 1				//how much additional damage per level the mob deals (level * attack_multiplier)
	var/health_multiplier = 1				//how much additional health per level the mob gets (level * health_multiplier) for calculating max health
	var/health = list(0, 0)					//health[1] is the mob's current health, health[2] is the mob's max health (calculated in New())

	//SPAWN PREFERENCES AND VARIABLES
	var/list/area_blacklist = list()		//list of areas this mob can NOT spawn in (such as the bridge)
	var/list/turf_blacklist = list()		//list of turfs this mob can NOT spawn on (such as wood floors)
	var/list/area_whitelist = list()		//list of areas this mob is more likely to spawn in (can be used to reinclude subtypes of blacklisted areas)
	var/list/turf_whitelist = list()		//list of turfs this mob is more likely to spawn on (can be used to reinclude subtypes of blacklisted turfs)
	var/x_coord = 0							//gets set and sent to the game server to spawn its avatar (generated in select_spawn)
	var/y_coord = 0							//gets set and sent to the game server to spawn its avatar (generated in select_spawn)
	var/lifetime = 6000						//number of deciseconds the mob will remain before despawning (REMEMBER: DECISECONDS! So 6000 is 600 seconds which is 10 minutes)
	var/is_shiny = 0						//if this gets set at spawn (super rare), the mob is considered "shiny" and will use the shiny icon_state and holographic cards

	//the icon file for mob_hunt stuff is 'icons/effects/mob_hunt.dmi' so reference that for the following vars
	var/icon_state_normal = "placeholder"	//the icon_state for this mob's normal version
	var/icon_state_shiny = "placeholder"	//the icon_state for this mob's rare shiney version

	var/is_trap = 0							//if this gets set, the mob is a booby-trap and will electrocute any players that dare attempt to catch it

/datum/mob_hunt/New(set_trap = 0, trap_x = 0, trap_y=0, no_register = 0)
	level = rand(min_level, max_level)
	health[2] = base_health + (level * health_multiplier)
	if(prob(1) && prob(1))
		is_shiny = 1
	if(no_register)		//for booster pack cards
		return
	if(mob_hunt_server)
		if(set_trap)
			is_trap = 1
			x_coord = trap_x
			y_coord = trap_y
			mob_hunt_server.register_trap(src)
		else if(select_spawn())
			mob_hunt_server.register_spawn(src)
		else	//if we aren't a trap and can't spawn, delete the datum to avoid buildups
			qdel(src)
	else
		qdel(src)

/datum/mob_hunt/proc/select_spawn()
	var/list/possible_areas = list()
	for(var/areapath in the_station_areas)
		possible_areas += typesof(areapath)
	for(var/areapath in area_blacklist)
		possible_areas -= typesof(areapath)
	for(var/areapath in area_whitelist)
		possible_areas += typesof(areapath)		//yes, this means some areas may be included multiple times, which simply increases their likelihood of being chosen
	if(!possible_areas.len)
		log_admin("No possible areas to spawn [type] found. Possible code/mapping error?")
		return 0
	var/list/possible_turfs = list()
	var/turf/T
	while(possible_areas.len)
		//randomly select an area from our possible_areas list to try spawning in, then remove it from possible_areas so it won't get picked over and over forever.
		var/area/spawn_area = locate(pick_n_take(possible_areas))
		if(!spawn_area)
			break
		//clear and generate a fresh list of turfs in the selected area, weighted based on white/black lists
		possible_turfs.Cut()
		for(var/turf/PT in spawn_area)
			var/value = 1
			if(is_type_in_list(PT, turf_whitelist))		//if whitelisted, we have a significant bonus to our weight
				value += 2
			if(is_type_in_list(PT, turf_blacklist))		//blacklisting only removes 1 value (weight), so whitelisted subtypes are still more likely than normal turfs
				value -= 1								//but non-whitelisted turfs will be disqualified
			if(!value)
				continue
			possible_turfs[PT] = value
		if(!possible_turfs.len)		//If we don't have any possible turfs, this attempt was a failure. Try again.
			continue
		//if we got this far, we're spawning on this attempt, hooray!
		T = pickweight(possible_turfs)
		x_coord = T.x
		y_coord = T.y
		break
	if(T)
		to_chat(world, "DEBUGGING: [type] spawning at ([x_coord], [y_coord])")
		return 1
	else
	//if we get to this, we failed every attempt to find a suitable turf for EVERY area in our list of possible areas. DAMN.
		log_admin("No acceptable turfs to spawn [type] on could be located. Possible code/mapping error, or someone replaced/destroyed all the acceptable turf types?")
		return 0

/datum/mob_hunt/proc/calc_dam_multiplier(datum/mob_type/attack_type)
	if(!primary_type)
		return 99		//typeless mobs are weak to everything since they shouldn't exist
	if(!attack_type)	//typeless attacks will return a multiplier of 1 in case we want to use this for calculating unmodified damage for some reason (UI maybe?)
		return 1

	var/multiplier = 1
	if(attack_type in primary_type.immunity)
		return 0		//a single immunity negates all damage
	else if(attack_type in primary_type.resistance)
		multiplier *= 0.5
	else if(attack_type in primary_type.weakness)
		multiplier *= 2
	else
		multiplier *= 1

	if(!secondary_type)		//if we don't have a second type, we're done here
		return multiplier
	if(attack_type in secondary_type.immunity)
		return 0		//a single immunity negates all damage
	else if(attack_type in secondary_type.resistance)
		multiplier *= 0.5
	else if(attack_type in secondary_type.weakness)
		multiplier *= 2
	else
		multiplier *= 1
	return multiplier

/datum/mob_hunt/proc/take_damage(raw_damage, datum/mob_type/attack_type)
	var/message = ""
	var/multiplier = calc_dam_multiplier(attack_type)
	var/total_damage = raw_damage * multiplier
	if(!health[1])	//it's already downed, quit hitting it
		return null
	health[1] = max(health[1] - total_damage, 0)
	switch(multiplier)
		if(0)
			message += "The attack is completely ineffective! "
		if(0.25)
			message += "It's barely effective... "
		if(0.5)
			message += "It's not very effective... "
		if(2)
			message += "It's super effective! "
		if(4)
			message += "It's ultra effective! "
	if(!health[1])
		message += "[nickname ? nickname : mob_name] is downed!"
	return message

/datum/mob_hunt/proc/levelup()
	var/message = ""
	level++
	if(level > max_level)		//This is where we would trigger an evolution, when those are added (need to add evolved forms first)
		level = max_level		//for now though, we'll just cap them back at their max_level
		message += "[nickname ? nickname : mob_name] can't get any stronger right now!"
	else

		health[2] = base_health + (level * health_multiplier)
		message += "[nickname ? nickname : mob_name] has reached level [level]!"

/datum/mob_hunt/proc/get_type1()
	if(!primary_type)
		return "Typeless"
	else
		return initial(primary_type.name)

/datum/mob_hunt/proc/get_type2()
	if(!secondary_type)
		return null
	else
		return initial(secondary_type.name)


/datum/mob_hunt/nemabug
	mob_name = "Nemabug"
	run_chance = 50
	min_level = 1
	max_level = 10
	primary_type = TYPE_BUG
	icon_state_normal = "nemabug"
	icon_state_shiny = "nemabug_shiny"
	area_blacklist = list(/area/toxins)
	turf_blacklist = list()
	area_whitelist = list(/area/hydroponics,
						/area/hallway/secondary/construction)
	turf_whitelist = list(/turf/simulated/floor/grass)
	lifetime = 6000

/datum/mob_hunt/stoutquill
	mob_name = "Stoutquill"
	run_chance = 50
	min_level = 5
	max_level = 15
	primary_type = TYPE_ICE
	icon_state_normal = "stoutquill"
	icon_state_shiny = "stoutquill_shiny"
	area_blacklist = list(/area/maintenance/turbine,
						/area/maintenance/incinerator,
						/area/crew_quarters/kitchen)
	turf_blacklist = list()
	area_whitelist = list(/area/toxins/server_coldroom)
	turf_whitelist = list()
	lifetime = 4500

/datum/mob_hunt/spectra
	mob_name = "Spectra"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_POISON
	icon_state_normal = "spectra"
	icon_state_shiny = "spectra_shiny"
	area_blacklist = list(/area/medical,
						/area/security/medbay,
						/area/janitor)
	turf_blacklist = list()
	area_whitelist = list(/area/medical/virology,
						/area/toxins,
						/area/medical/research,
						/area/medical/research_shuttle_dock,
						/area/crew_quarters/hor,
						/area/maintenance/asmaint2)
	turf_whitelist = list()
	lifetime = 6000

/datum/mob_hunt/dunny
	mob_name = "Dunny"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_FIRE
	icon_state_normal = "dunny"
	icon_state_shiny = "dunny_shiny"
	area_blacklist = list(/area/crew_quarters/toilet,
						/area/crew_quarters/sleep_male/toilet_male,
						/area/crew_quarters/sleep_female/toilet_female,
						/area/crew_quarters/locker/locker_toilet,
						/area/toxins/server_coldroom)
	turf_blacklist = list(/turf/simulated/floor/beach/water)
	area_whitelist = list(/area/maintenance/turbine,
						/area/maintenance/incinerator,
						/area/crew_quarters/kitchen)
	turf_whitelist = list()
	lifetime = 6000

/datum/mob_hunt/buffsel
	mob_name = "Buffsel"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_ROCK
	icon_state_normal = "buffsel"
	icon_state_shiny = "buffsel_shiny"
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list(/area/quartermaster,
						/area/maintenance/disposal)
	turf_whitelist = list(/turf/simulated/wall,
						/turf/simulated/floor/mineral)
	lifetime = 6000

/datum/mob_hunt/quarrel
	mob_name = "Quarrel"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_NORMAL
	icon_state_normal = "quarrel"
	icon_state_shiny = "quarrel_shiny"
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list()
	turf_whitelist = list()
	lifetime = 6000

/datum/mob_hunt/vulerrt
	mob_name = "Vulerrt"
	run_chance = 50
	min_level = 5
	max_level = 15
	primary_type = TYPE_DARK
	icon_state_normal = "vulerrt"
	icon_state_shiny = "vulerrt_shiny"
	area_blacklist = list(/area/solar,
						/area/maintenance/auxsolarport,
						/area/maintenance/starboardsolar,
						/area/maintenance/portsolar,
						/area/maintenance/auxsolarstarboard,
						/area/clownoffice)
	turf_blacklist = list(/turf/simulated/floor/light)
	area_whitelist = list(/area/maintenance,
						/area/assembly/assembly_line,
						/area/mimeoffice)
	turf_whitelist = list()
	lifetime = 4500

/datum/mob_hunt/strudel
	mob_name = "Strudel"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_ELECTRIC
	icon_state_normal = "strudel"
	icon_state_shiny = "strudel_shiny"
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list(/area/engine,
						/area/toxins/server,
						/area/maintenance,
						/area/turret_protected/ai,
						/area/turret_protected/ai_upload,
						/area/turret_protected/aisat_interior,
						/area/aisat,
						/area/assembly)
	turf_whitelist = list(/turf/simulated/floor/bluegrid)
	lifetime = 4500

/datum/mob_hunt/folstick
	mob_name = "Folstick"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_WATER
	icon_state_normal = "folstick"
	icon_state_shiny = "folstick_shiny"
	area_blacklist = list(/area/maintenance/turbine,
						/area/maintenance/incinerator,
						/area/crew_quarters/kitchen)
	turf_blacklist = list()
	area_whitelist = list(/area/crew_quarters/toilet,
						/area/crew_quarters/sleep_male/toilet_male,
						/area/crew_quarters/sleep_female/toilet_female,
						/area/crew_quarters/locker/locker_toilet)
	turf_whitelist = list(/turf/simulated/floor/beach/water)
	lifetime = 6000

/datum/mob_hunt/glimmerflare
	mob_name = "Glimmerflare"
	run_chance = 50
	min_level = 5
	max_level = 15
	primary_type = TYPE_PSYCHIC
	icon_state_normal = "glimmerflare"
	icon_state_shiny = "glimmerflare_shiny"
	area_blacklist = list(/area/toxins,
						/area/medical/research,
						/area/medical/research_shuttle_dock,
						/area/crew_quarters/hor,
						/area/maintenance/asmaint2,
						/area/teleporter,
						/area/gateway)
	turf_blacklist = list()
	area_whitelist = list(/area/library,
						/area/chapel,
						/area/medical/psych)
	turf_whitelist = list()
	lifetime = 4500

/datum/mob_hunt/leecoon
	mob_name = "Leecoon"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_GRASS
	icon_state_normal = "leecoon"
	icon_state_shiny = "leecoon_shiny"
	area_blacklist = list(/area/toxins)
	turf_blacklist = list()
	area_whitelist = list(/area/hydroponics,
						/area/hallway/secondary/construction)
	turf_whitelist = list(/turf/simulated/floor/grass)
	lifetime = 6000

/datum/mob_hunt/halk
	mob_name = "Halk"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_FLYING
	icon_state_normal = "halk"
	icon_state_shiny = "halk_shiny"
	area_blacklist = list(/area/maintenance)
	turf_blacklist = list()
	area_whitelist = list(/area/hallway,
						/area/escapepodbay,
						/area/engine/mechanic_workshop,
						/area/security/podbay)
	turf_whitelist = list()
	lifetime = 6000

/datum/mob_hunt/gooby
	mob_name = "Gooby"
	run_chance = 65
	min_level = 5
	max_level = 20
	primary_type = TYPE_ELECTRIC
	secondary_type = TYPE_BUG
	icon_state_normal = "gooby"
	icon_state_shiny = "gooby_shiny"
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list(/area/engine,
						/area/toxins/server,
						/area/maintenance,
						/area/turret_protected/ai,
						/area/turret_protected/ai_upload,
						/area/turret_protected/aisat_interior,
						/area/aisat,
						/area/assembly)
	turf_whitelist = list(/turf/simulated/floor/bluegrid)
	lifetime = 3000

/datum/mob_hunt/mob_14
	mob_name = "Mob 14"
	run_chance = 50
	min_level = 5
	max_level = 10
	primary_type = TYPE_NORMAL
	secondary_type = TYPE_NORMAL
	icon_state_normal = ""
	icon_state_shiny = ""
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list()
	turf_whitelist = list()
	lifetime = 6000

/datum/mob_hunt/relish
	mob_name = "Relish"
	run_chance = 65
	min_level = 5
	max_level = 20
	primary_type = TYPE_FIRE
	secondary_type = TYPE_GROUND
	icon_state_normal = "relish"
	icon_state_shiny = "relish_shiny"
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list()
	turf_whitelist = list()
	lifetime = 3000

/datum/mob_hunt/mob_16
	mob_name = "Mob 14"
	run_chance = 50
	min_level = 5
	max_level = 10
	primary_type = TYPE_NORMAL
	secondary_type = TYPE_NORMAL
	icon_state_normal = ""
	icon_state_shiny = ""
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list()
	turf_whitelist = list()
	lifetime = 6000

/datum/mob_hunt/gitten
	mob_name = "Gitten"
	run_chance = 65
	min_level = 5
	max_level = 20
	primary_type = TYPE_WATER
	secondary_type = TYPE_POISON
	icon_state_normal = "gitten"
	icon_state_shiny = "gitten_shiny"
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list()
	turf_whitelist = list()
	lifetime = 3000

/datum/mob_hunt/nai
	mob_name = "Nai"
	run_chance = 65
	min_level = 5
	max_level = 20
	primary_type = TYPE_GRASS
	secondary_type = TYPE_NORMAL
	icon_state_normal = "nai"
	icon_state_shiny = "nai_shiny"
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list()
	turf_whitelist = list()
	lifetime = 3000

/datum/mob_hunt/pyroghast
	mob_name = "Pyroghast"
	run_chance = 65
	min_level = 5
	max_level = 20
	primary_type = TYPE_FIRE
	secondary_type = TYPE_GHOST
	icon_state_normal = "pyroghast"
	icon_state_shiny = "pyroghast"
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list()
	turf_whitelist = list()
	lifetime = 4500

/datum/mob_hunt/starslam
	mob_name = "Starslam"
	run_chance = 65
	min_level = 5
	max_level = 20
	primary_type = TYPE_FIGHTING
	secondary_type = TYPE_ICE
	icon_state_normal = "starslam"
	icon_state_shiny = "starslam_shiny"
	area_blacklist = list(/area/medical)
	turf_blacklist = list()
	area_whitelist = list(/area/crew_quarters/bar,
						/area/crew_quarters/fitness,
						/area/security)
	turf_whitelist = list(/turf/simulated/floor/wood)
	lifetime = 2500

/datum/mob_hunt/pheron
	mob_name = "Pheron"
	run_chance = 85
	min_level = 10
	max_level = 20
	primary_type = TYPE_BLUESPACE
	icon_state_normal = "pheron"
	icon_state_shiny = "pheron_shiny"
	area_blacklist = list()
	turf_blacklist = list()
	area_whitelist = list()
	turf_whitelist = list()
	lifetime = 2000
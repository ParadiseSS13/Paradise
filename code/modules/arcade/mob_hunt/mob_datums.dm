
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
	var/exp = 0								//number of battles the mob has won towards the next level (resets to 0 on level-up)
	var/exp_to_level = 3					//number of battles the mob must win to level up (in case we want to make some mobs harder or easier to level)
	//the types of the mob will be used for battles to determine damage resistance or weakness (mob_type_datums.dm)
	var/datum/mob_type/primary_type			//Make sure you set this or the mob will be unable to deal damage and will take absurd damage in battles
	var/datum/mob_type/secondary_type		//Don't set if not a dual-type mob so the mob will only calculate damage based on primary type
	var/base_attack = 5						//base damage dealt by the mob's attacks for battling (effectively damage dealt at level 0)
	var/base_health = 5						//base health of the mob for battling (effectively max health at level 0)
	var/attack_multiplier = 1				//how much additional damage per level the mob deals (level * attack_multiplier)
	var/health_multiplier = 1				//how much additional health per level the mob gets (level * health_multiplier) for calculating max health
	var/cur_health = 0
	var/max_health = 0

	//SPAWN PREFERENCES AND VARIABLES
	//A note on mob spawn preferences: The mob types also have preferences, which are handled prior to per-mob preferences, so ultimately you use a combined set of preferences
	var/list/area_blacklist = list()		//list of areas this mob can NOT spawn in (such as the bridge)
	var/list/turf_blacklist = list()		//list of turfs this mob can NOT spawn on (such as wood floors)
	var/list/area_whitelist = list()		//list of areas this mob is more likely to spawn in (can be used to reinclude subtypes of blacklisted areas)
	var/list/turf_whitelist = list()		//list of turfs this mob is more likely to spawn on (can be used to reinclude subtypes of blacklisted turfs)
	var/turf/spawn_point					//gets set and sent to the game server to spawn its avatar (generated in select_spawn or assigned via set_trap)
	var/lifetime = 6000						//number of deciseconds the mob will remain before despawning (REMEMBER: DECISECONDS! So 6000 is 600 seconds which is 10 minutes)
	var/is_shiny = 0						//if this gets set at spawn (super rare), the mob is considered "shiny" and will use the shiny icon_state and holographic cards

	//the icon file for mob_hunt stuff is 'icons/effects/mob_hunt.dmi' so reference that for the following vars
	var/icon_state_normal = "placeholder"	//the icon_state for this mob's normal version
	var/icon_state_shiny = "placeholder"	//the icon_state for this mob's rare shiney version

	var/is_trap = 0							//if this gets set, the mob is a booby-trap and will electrocute any players that dare attempt to catch it

/datum/mob_hunt/New(set_trap = 0, turf/trap_turf = null, no_register = 0)
	if(set_trap)
		level = max_level
		is_trap = 1
		spawn_point = trap_turf
	else
		level = rand(min_level, max_level)
	if(prob(1) && prob(1))
		is_shiny = 1
	max_health = base_health + (level * health_multiplier)
	cur_health = max_health
	if(primary_type)
		primary_type = new primary_type()
	if(secondary_type)
		secondary_type = new secondary_type()
	if(no_register)		//for booster pack cards
		return
	if(SSmob_hunt)
		if(set_trap)
			if(SSmob_hunt.register_trap(src))
				return
		else if(select_spawn())
			if(SSmob_hunt.register_spawn(src))
				return
	qdel(src)	//if you reach this, the datum is just pure clutter, so delete it

/datum/mob_hunt/proc/select_spawn()
	var/list/possible_areas = get_possible_areas()
	if(!possible_areas.len)
		log_admin("No possible areas to spawn [type] found. Possible code/mapping error?")
		return 0
	while(possible_areas.len)
		//randomly select an area from our possible_areas list to try spawning in, then remove it from possible_areas so it won't get picked over and over forever.
		var/area/spawn_area = locate(pickweight(possible_areas))
		possible_areas -= spawn_area
		if(!spawn_area)
			break
		//clear and generate a fresh list of turfs in the selected area, weighted based on white/black lists
		var/list/possible_turfs = get_possible_turfs(spawn_area)
		if(!possible_turfs.len)		//If we don't have any possible turfs, this attempt was a failure. Try again.
			continue
		//if we got this far, we're spawning on this attempt, hooray!
		spawn_point = pickweight(possible_turfs)
		break
	if(!spawn_point)
	//if we get to this, we failed every attempt to find a suitable turf for EVERY area in our list of possible areas. DAMN.
		log_admin("No acceptable turfs to spawn [type] on could be located. Possible code/mapping error, or someone replaced/destroyed all the acceptable turf types?")
		return 0
	return 1

/datum/mob_hunt/proc/get_possible_areas()
	var/list/possible_areas = list()
	//setup, sets all station areas (and subtypes) to weight 1
	for(var/A in GLOB.the_station_areas)
		if(A == /area/holodeck)	//don't allow holodeck areas as possible spawns since it will allow it to spawn in the holodeck rooms on z2 as well
			continue
		if(A in possible_areas)
			continue
		for(var/areapath in typesof(A))
			possible_areas[areapath] = 1
	//primary type preferences
	if(primary_type)
		for(var/A in primary_type.area_whitelist)
			for(var/areapath in typesof(A))
				possible_areas[areapath] += 4
		for(var/A in primary_type.area_blacklist)
			for(var/areapath in typesof(A))
				possible_areas[areapath] -= 2
	//secondary type preferences
	if(secondary_type)
		for(var/A in secondary_type.area_whitelist)
			for(var/areapath in typesof(A))
				possible_areas[areapath] += 4
		for(var/A in secondary_type.area_blacklist)
			for(var/areapath in typesof(A))
				possible_areas[areapath] -= 2
	//mob preferences
	for(var/A in area_whitelist)
		for(var/areapath in typesof(A))
			possible_areas[areapath] += 4
	for(var/A in area_blacklist)
		for(var/areapath in typesof(A))
			possible_areas[areapath] -= 2
	//removes "bad areas" which shouldn't be on-station but are subtypes of station areas. probably should the unused ones and consider repathing the rest
	var/list/bad_areas = list(subtypesof(/area/construction), /area/solar/derelict_starboard, /area/solar/derelict_aft, /area/solar/constructionsite)
	for(var/A in bad_areas)
		possible_areas -= A
	//weight check, remove negative or zero weight areas from the list, then return the list.
	for(var/areapath in possible_areas)
		//remove any areas that shouldn't be on the station-level
		if(possible_areas[areapath] < 1)
			possible_areas -= areapath
			continue
	return possible_areas

/datum/mob_hunt/proc/get_possible_turfs(area/spawn_area)
	if(!spawn_area)
		return list()
	var/list/possible_turfs = list()
	//setup, sets all turfs in spawn_area to weight 1
	for(var/turf/T in spawn_area)
		if(!is_station_level(T.z))		//mobs will only consider station-level turfs for spawning. Largely here so we won't have to worry about mapping errors or mobs on the derelict solars
			continue
		possible_turfs[T] = 1
		//primary type preferences
		if(primary_type)
			if(is_type_in_list(T, primary_type.turf_whitelist))
				possible_turfs[T] += 4
			if(is_type_in_list(T, primary_type.turf_blacklist))
				possible_turfs[T] -= 2
		//secondary type preferences
		if(secondary_type)
			if(is_type_in_list(T, secondary_type.turf_whitelist))
				possible_turfs[T] += 4
			if(is_type_in_list(T, secondary_type.turf_blacklist))
				possible_turfs[T] -= 2
		//mob preferences
		if(is_type_in_list(T, turf_whitelist))
			possible_turfs[T] += 4
		if(is_type_in_list(T, turf_blacklist))
			possible_turfs[T] -= 2
		//weight check, remove negative or zero weight turfs from the list, then return the list
		if(possible_turfs[T] < 1)
			possible_turfs -= T
	return possible_turfs

/datum/mob_hunt/proc/calc_def_multiplier(datum/mob_type/attack_type)
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
	var/multiplier = calc_def_multiplier(attack_type)
	var/total_damage = raw_damage * multiplier
	if(!cur_health)	//it's already downed, quit hitting it
		return null
	if(!total_damage)
		message += "The attack is completely ineffective! "
	else
		cur_health = max(cur_health - total_damage, 0)
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
			if(99)
				message += pick("REKT! ", "DUNKED! ", "DEFENSE BREAK! ", "WOMBO-COMBO'D!")
	if(!cur_health)
		message += "[nickname ? nickname : mob_name] is downed!"
	return message

/datum/mob_hunt/proc/get_raw_damage()
	return (level * attack_multiplier)

/datum/mob_hunt/proc/get_attack_type()
	var/datum/mob_type/attack_type = primary_type
	if(secondary_type && prob(40))
		attack_type = secondary_type
	return attack_type

/datum/mob_hunt/proc/gain_exp()
	exp++
	var/message = "[nickname ? nickname : mob_name] gained EXP! ([exp] / [exp_to_level] EXP)"
	if(exp >= exp_to_level)
		message = levelup()
	return message

/datum/mob_hunt/proc/levelup()
	var/message = ""
	level++
	exp = 0
	if(level > max_level)		//This is where we would trigger an evolution, when those are added (need to add evolved forms first)
		level = max_level		//for now though, we'll just cap them back at their max_level
		message += "[nickname ? nickname : mob_name] can't get any stronger right now!"
	else
		max_health = base_health + (level * health_multiplier)
		cur_health = max_health		//full heal on level-up
		message += "[nickname ? nickname : mob_name] has reached level [level]!"
	return message

/datum/mob_hunt/proc/get_type1()
	if(!primary_type)
		return "Typeless"
	else
		return primary_type.name

/datum/mob_hunt/proc/get_type2()
	if(!secondary_type)
		return null
	else
		return secondary_type.name


/datum/mob_hunt/nemabug
	mob_name = "Nemabug"
	run_chance = 50
	min_level = 1
	max_level = 10
	primary_type = TYPE_BUG
	icon_state_normal = "nemabug"
	icon_state_shiny = "nemabug_shiny"
	lifetime = 6000

/datum/mob_hunt/stoutquill
	mob_name = "Stoutquill"
	run_chance = 50
	min_level = 5
	max_level = 15
	primary_type = TYPE_ICE
	icon_state_normal = "stoutquill"
	icon_state_shiny = "stoutquill_shiny"
	lifetime = 4500

/datum/mob_hunt/spectra
	mob_name = "Spectra"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_POISON
	icon_state_normal = "spectra"
	icon_state_shiny = "spectra_shiny"
	lifetime = 6000

/datum/mob_hunt/dunny
	mob_name = "Dunny"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_FIRE
	icon_state_normal = "dunny"
	icon_state_shiny = "dunny_shiny"
	lifetime = 6000

/datum/mob_hunt/buffsel
	mob_name = "Buffsel"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_ROCK
	icon_state_normal = "buffsel"
	icon_state_shiny = "buffsel_shiny"
	lifetime = 6000

/datum/mob_hunt/quarrel
	mob_name = "Quarrel"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_NORMAL
	icon_state_normal = "quarrel"
	icon_state_shiny = "quarrel_shiny"
	lifetime = 6000

/datum/mob_hunt/vulerrt
	mob_name = "Vulerrt"
	run_chance = 50
	min_level = 5
	max_level = 15
	primary_type = TYPE_DARK
	icon_state_normal = "vulerrt"
	icon_state_shiny = "vulerrt_shiny"
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
	lifetime = 4500

/datum/mob_hunt/folstick
	mob_name = "Folstick"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_WATER
	icon_state_normal = "folstick"
	icon_state_shiny = "folstick_shiny"
	lifetime = 6000

/datum/mob_hunt/glimmerflare
	mob_name = "Glimmerflare"
	run_chance = 50
	min_level = 5
	max_level = 15
	primary_type = TYPE_PSYCHIC
	icon_state_normal = "glimmerflare"
	icon_state_shiny = "glimmerflare_shiny"
	lifetime = 4500

/datum/mob_hunt/leecoon
	mob_name = "Leecoon"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_GRASS
	icon_state_normal = "leecoon"
	icon_state_shiny = "leecoon_shiny"
	lifetime = 6000

/datum/mob_hunt/halk
	mob_name = "Halk"
	run_chance = 35
	min_level = 1
	max_level = 10
	primary_type = TYPE_FLYING
	icon_state_normal = "halk"
	icon_state_shiny = "halk_shiny"
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
	lifetime = 3000

/datum/mob_hunt/pandoom
	mob_name = "Pandoom"
	run_chance = 50
	min_level = 5
	max_level = 15
	primary_type = TYPE_GHOST
	icon_state_normal = "pandoom"
	icon_state_shiny = "pandoom_shiny"
	lifetime = 4500

/datum/mob_hunt/relish
	mob_name = "Relish"
	run_chance = 65
	min_level = 5
	max_level = 20
	primary_type = TYPE_FIRE
	secondary_type = TYPE_GROUND
	icon_state_normal = "relish"
	icon_state_shiny = "relish_shiny"
	lifetime = 3000

/datum/mob_hunt/xofine
	mob_name = "Xofine"
	run_chance = 50
	min_level = 5
	max_level = 10
	primary_type = TYPE_FIRE
	secondary_type = TYPE_NORMAL
	icon_state_normal = "xofine"
	icon_state_shiny = "xofine_shiny"
	lifetime = 3000

/datum/mob_hunt/gitten
	mob_name = "Gitten"
	run_chance = 65
	min_level = 5
	max_level = 20
	primary_type = TYPE_WATER
	secondary_type = TYPE_POISON
	icon_state_normal = "gitten"
	icon_state_shiny = "gitten_shiny"
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

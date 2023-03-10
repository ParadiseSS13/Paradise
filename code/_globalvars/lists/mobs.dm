//Languages/species/whitelist. //Languages and species fit with mobs right
GLOBAL_LIST_EMPTY(all_species)
GLOBAL_LIST_EMPTY(all_languages)
GLOBAL_LIST_EMPTY(language_keys)					// Table of say codes for all languages
GLOBAL_LIST_EMPTY(all_superheroes)
GLOBAL_LIST_EMPTY(whitelisted_species)

GLOBAL_LIST_EMPTY(clients)							//list of all clients
GLOBAL_LIST_EMPTY(admins)							//list of all clients whom are admins
GLOBAL_LIST_EMPTY(deadmins)							//list of all clients who have used the de-admin verb.
GLOBAL_LIST_EMPTY(directory)							//list of all ckeys with associated client
GLOBAL_LIST_EMPTY(stealthminID)						//reference list with IDs that store ckeys, for stealthmins

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

GLOBAL_LIST_EMPTY(player_list)				//List of all mobs **with clients attached**. Excludes /mob/new_player
GLOBAL_LIST_EMPTY(mob_list)					//List of all mobs, including clientless
GLOBAL_LIST_EMPTY(silicon_mob_list)			//List of all silicon mobs, including clientless
GLOBAL_LIST_EMPTY(mob_living_list)			//all instances of /mob/living and subtypes
GLOBAL_LIST_EMPTY(carbon_list)				//all instances of /mob/living/carbon and subtypes, notably does not contain simple animals
GLOBAL_LIST_EMPTY(human_list)				//all instances of /mob/living/carbon/human and subtypes
GLOBAL_LIST_EMPTY(spirits)					//List of all the spirits, including Masks
GLOBAL_LIST_EMPTY(alive_mob_list)			//List of all alive mobs, including clientless. Excludes /mob/new_player
GLOBAL_LIST_EMPTY(dead_mob_list)				//List of all dead mobs, including clientless. Excludes /mob/new_player
GLOBAL_LIST_EMPTY(respawnable_list)			//List of all mobs, dead or in mindless creatures that still be respawned.
GLOBAL_LIST_EMPTY(non_respawnable_keys)	//List of ckeys that are excluded from respawning for remainder of round.
GLOBAL_LIST_INIT(simple_animals, list(list(), list(), list(), list()))			//One for each AI_* status define, List of all simple animals, including clientless
GLOBAL_LIST_EMPTY(bots_list) 					//List of all bots(beepsky, medibots,etc)
GLOBAL_LIST_EMPTY(morphs_alive_list)

GLOBAL_LIST_EMPTY(med_hud_users)
GLOBAL_LIST_EMPTY(sec_hud_users)
GLOBAL_LIST_EMPTY(antag_hud_users)
GLOBAL_LIST_EMPTY(surgeries_list)
GLOBAL_LIST_EMPTY(hear_radio_list)			//Mobs that hear the radio even if there's no client

GLOBAL_LIST_EMPTY(human_names_list)			//List of names for all humans that have ever entered the round

GLOBAL_LIST_EMPTY(taipan_players_active)	//List of all Taipan operatives active

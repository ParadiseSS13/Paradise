//Languages/species/whitelist. //Languages and species fit with mobs right
var/global/list/all_species[0]
var/global/list/all_languages[0]
var/global/list/language_keys[0]					// Table of say codes for all languages
var/global/list/all_superheroes[0]
var/global/list/all_nations[0]
var/global/list/whitelisted_species = list()

var/list/clients = list()							//list of all clients
var/list/admins = list()							//list of all clients whom are admins
var/list/deadmins = list()							//list of all clients who have used the de-admin verb.
var/list/directory = list()							//list of all ckeys with associated client
var/list/stealthminID = list()						//reference list with IDs that store ckeys, for stealthmins

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

var/global/list/player_list = list()				//List of all mobs **with clients attached**. Excludes /mob/new_player
var/global/list/mob_list = list()					//List of all mobs, including clientless
var/global/list/silicon_mob_list = list() //List of all silicon mobs, including clientless
var/global/list/spirits = list()					//List of all the spirits, including Masks
var/global/list/living_mob_list = list()			//List of all alive mobs, including clientless. Excludes /mob/new_player
var/global/list/dead_mob_list = list()				//List of all dead mobs, including clientless. Excludes /mob/new_player
var/global/list/respawnable_list = list()				//List of all mobs, dead or in mindless creatures that still be respawned.

//global var of unsafe-to-spawn-on-reaction mobs
var/global/list/blocked_mobs = list(/mob/living/simple_animal,
			/mob/living/simple_animal/hostile,
			/mob/living/simple_animal/hostile/pirate,
			/mob/living/simple_animal/hostile/pirate/ranged,
			/mob/living/simple_animal/hostile/russian,
			/mob/living/simple_animal/hostile/russian/ranged,
			/mob/living/simple_animal/hostile/syndicate,
			/mob/living/simple_animal/hostile/syndicate/melee,
			/mob/living/simple_animal/hostile/syndicate/melee/space,
			/mob/living/simple_animal/hostile/syndicate/ranged,
			/mob/living/simple_animal/hostile/syndicate/ranged/space,
			/mob/living/simple_animal/hostile/alien/queen/large,
			/mob/living/simple_animal/hostile/retaliate,
			/mob/living/simple_animal/hostile/retaliate/clown,
			/mob/living/simple_animal/hostile/mushroom,
			/mob/living/simple_animal/hostile/asteroid,
			/mob/living/simple_animal/hostile/asteroid/basilisk,
			/mob/living/simple_animal/hostile/asteroid/goldgrub,
			/mob/living/simple_animal/hostile/asteroid/goliath,
			/mob/living/simple_animal/hostile/asteroid/hivelord,
			/mob/living/simple_animal/hostile/asteroid/hivelordbrood,
			/mob/living/simple_animal/hostile/carp/holocarp,
			/mob/living/simple_animal/hostile/mining_drone,
			/mob/living/simple_animal/hostile/spaceWorm,
			/mob/living/simple_animal/hostile/spaceWorm/wormHead,
			/mob/living/simple_animal/ascendant_shadowling,
			/mob/living/simple_animal/slaughter,
			/mob/living/simple_animal/hostile/retaliate/araneus,
			/mob/living/simple_animal/hostile/syndicate/ranged/orion,
			/mob/living/simple_animal/hostile/statue,
			/mob/living/simple_animal/hostile/guardian,
			/mob/living/simple_animal/hostile/guardian/fire,
			/mob/living/simple_animal/hostile/guardian/healer,
			/mob/living/simple_animal/hostile/guardian/punch,
			/mob/living/simple_animal/hostile/guardian/punch/sealpunch,
			/mob/living/simple_animal/hostile/guardian/healer/sealhealer,
			/mob/living/simple_animal/hostile/guardian/ranged,
			/mob/living/simple_animal/hostile/guardian/bomb,
			/mob/living/simple_animal/hostile/winter/santa,
			/mob/living/simple_animal/hostile/winter/santa/stage_1,
			/mob/living/simple_animal/hostile/winter/santa/stage_2,
			/mob/living/simple_animal/hostile/winter/santa/stage_3,
			/mob/living/simple_animal/hostile/winter/santa/stage_4,
			/mob/living/simple_animal/hostile/alien/maid
			)

var/global/list/med_hud_users = list()
var/global/list/sec_hud_users = list()
var/global/list/antag_hud_users = list()
var/global/list/surgeries_list = list()
		//items that ask to be called every cycle

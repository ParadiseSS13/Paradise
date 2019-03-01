GLOBAL_LIST_INIT(portals, list())					//for use by portals
GLOBAL_LIST(cable_list)								//Index for all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_LIST(chemical_reactions_list)			//list of all /datum/chemical_reaction datums. Used during chemical reactions
GLOBAL_LIST(chemical_reagents_list)				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
GLOBAL_LIST_INIT(landmarks_list, list())				//list of all landmarks created
GLOBAL_LIST_INIT(surgery_steps, list())				//list of all surgery steps  |BS12
GLOBAL_LIST_INIT(side_effects, list())				//list of all medical sideeffects types by thier names |BS12
GLOBAL_LIST_INIT(mechas_list, list())				//list of all mechs. Used by hostile mobs target tracking.
GLOBAL_LIST_INIT(spacepods_list, list())				//list of all space pods. Used by hostile mobs target tracking.
GLOBAL_LIST_INIT(joblist, list())					//list of all jobstypes, minus borg and AI
GLOBAL_LIST_INIT(airlocks, list())					//list of all airlocks
GLOBAL_LIST_INIT(singularities, list())				//list of all singularities
GLOBAL_LIST_INIT(janitorial_equipment, list())		//list of janitorial equipment
GLOBAL_LIST_INIT(crafting_recipes, list()) //list of all crafting recipes
GLOBAL_LIST_INIT(prisoncomputer_list, list())
GLOBAL_LIST_INIT(cell_logs, list())
GLOBAL_LIST_INIT(navigation_computers, list())

GLOBAL_LIST_INIT(all_areas, list())
GLOBAL_LIST_INIT(machines, list())
GLOBAL_LIST_INIT(fast_processing, list())
GLOBAL_LIST_INIT(processing_power_items, list()) //items that ask to be called every cycle
GLOBAL_LIST_INIT(rcd_list, list()) //list of Rapid Construction Devices.

GLOBAL_LIST_INIT(apcs, list())
GLOBAL_LIST_INIT(air_alarms, list())
GLOBAL_LIST_INIT(power_monitors, list())
GLOBAL_LIST_INIT(all_vent_pumps, list())

GLOBAL_LIST_INIT(navbeacons, list())					//list of all bot nagivation beacons, used for patrolling.
GLOBAL_LIST_INIT(deliverybeacons, list())			//list of all MULEbot delivery beacons.
GLOBAL_LIST_INIT(deliverybeacontags, list())			//list of all tags associated with delivery beacons.

GLOBAL_LIST_INIT(beacons, list())
GLOBAL_LIST_INIT(shuttle_caller_list, list())  		//list of all communication consoles, comms consoles circuit and AIs, for automatic shuttle calls when there are none.
GLOBAL_LIST_INIT(tracked_implants, list())			//list of all current implants that are tracked to work out what sort of trek everyone is on. Sadly not on lavaworld not implemented...
GLOBAL_LIST_INIT(pinpointer_list, list())			//list of all pinpointers. Used to change stuff they are pointing to all at once.
GLOBAL_LIST_INIT(nuclear_uplink_list, list())			//list of all existing nuke ops uplinks
GLOBAL_LIST_INIT(abductor_equipment, list())			//list of all abductor equipment
GLOBAL_LIST_INIT(global_intercoms, list())			//list of all intercomms, across all z-levels
GLOBAL_LIST_INIT(global_radios, list())				//list of all radios, across all z-levels

GLOBAL_LIST_INIT(meteor_list, list())				//list of all meteors
GLOBAL_LIST_INIT(poi_list, list())					//list of points of interest for observe/follow
GLOBAL_LIST_INIT(active_jammers, list())             // List of active radio jammers

GLOBAL_LIST_INIT(active_diseases, list()) 			//List of Active disease in all mobs; purely for quick referencing.

GLOBAL_LIST_EMPTY(mob_spawners) 		    // All mob_spawn objects

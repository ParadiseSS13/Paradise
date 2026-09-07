GLOBAL_LIST_EMPTY(portals)					//for use by portals
GLOBAL_LIST(cable_list)								//Index for all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_LIST(chemical_reactions_list)			//list of all /datum/chemical_reaction datums. Used during chemical reactions
GLOBAL_LIST(chemical_reagents_list)				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
GLOBAL_LIST_EMPTY(landmarks_list)				//list of all landmarks created
GLOBAL_LIST_EMPTY(surgery_steps)				//list of all surgery steps  |BS12
GLOBAL_LIST_EMPTY(mechas_list)				//list of all mechs. Used by hostile mobs target tracking.
GLOBAL_LIST_EMPTY(joblist)					//list of all jobstypes, minus borg and AI
GLOBAL_LIST_EMPTY(airlocks)					//list of all airlocks
GLOBAL_LIST_EMPTY(singularities)				//list of all singularities
GLOBAL_LIST_EMPTY(janitorial_equipment)		//list of janitorial equipment
GLOBAL_LIST_EMPTY(crafting_recipes) //list of all crafting recipes
GLOBAL_LIST_EMPTY(prisoncomputer_list)
GLOBAL_LIST_EMPTY(celltimers_list) // list of all cell timers
GLOBAL_LIST_EMPTY(cell_logs)
GLOBAL_LIST_EMPTY(navigation_computers)
GLOBAL_LIST_EMPTY(hierophant_walls)
GLOBAL_LIST_EMPTY(pandemics)

GLOBAL_LIST_EMPTY(all_areas)
GLOBAL_LIST_EMPTY_TYPED(all_unique_areas, /area) // List of all unique areas. AKA areas with there_can_be_many = FALSE
GLOBAL_LIST_EMPTY(telescreens) /// List of entertainment telescreens connected to the "news" cameranet
GLOBAL_LIST_EMPTY(rcd_list) //list of Rapid Construction Devices.

GLOBAL_LIST_EMPTY(apcs)
GLOBAL_LIST_EMPTY(air_alarms)
GLOBAL_LIST_EMPTY(power_monitors)
GLOBAL_LIST_EMPTY(all_vent_pumps)
GLOBAL_LIST_EMPTY(all_scrubbers)

GLOBAL_LIST_EMPTY(navbeacons)					//list of all bot nagivation beacons, used for patrolling.
GLOBAL_LIST_EMPTY(deliverybeacons)			//list of all MULEbot delivery beacons.
GLOBAL_LIST_EMPTY(deliverybeacontags)			//list of all tags associated with delivery beacons.

GLOBAL_LIST_EMPTY(beacons)
GLOBAL_LIST_EMPTY(shuttle_caller_list)  		//list of all communication consoles, comms consoles circuit and AIs, for automatic shuttle calls when there are none.
GLOBAL_LIST_EMPTY(tracked_implants)			//list of all current implants that are tracked to work out what sort of trek everyone is on. Sadly not on lavaworld not implemented...
GLOBAL_LIST_EMPTY(pinpointer_list)			//list of all pinpointers. Used to change stuff they are pointing to all at once.
GLOBAL_LIST_EMPTY(nuke_list)				//list of (real) nukes
GLOBAL_LIST_EMPTY(syndi_nuke_list)			//list of syndicate nukes
GLOBAL_LIST_EMPTY(nad_list)					//list of (real) nuclear authentication disks
GLOBAL_LIST_EMPTY(nuclear_uplink_list)			//list of all existing nuke ops uplinks
GLOBAL_LIST_EMPTY(abductor_equipment)			//list of all abductor equipment
GLOBAL_LIST_EMPTY(global_intercoms)			//list of all intercomms, across all z-levels
GLOBAL_LIST_EMPTY(global_radios)				//list of all radios, across all z-levels

GLOBAL_LIST_EMPTY(meteor_list)				//list of all meteors
GLOBAL_LIST_EMPTY(poi_list)					//list of points of interest for observe/follow
GLOBAL_LIST_EMPTY(active_jammers)             // List of active radio jammers
GLOBAL_LIST_EMPTY(mirrors) //list of all mirrors and mirror shields.
GLOBAL_LIST_EMPTY(arc_emitters) 					//list of all arc emitters

GLOBAL_LIST_EMPTY(active_diseases) 			//List of Active disease in all mobs; purely for quick referencing.

GLOBAL_LIST_EMPTY(mob_spawners) 		    // All mob_spawn objects

GLOBAL_LIST_EMPTY(engine_beacon_list)

GLOBAL_LIST_EMPTY(landline_phones)

/// List of wire colors for each object type of that round. One for airlocks, one for vendors, etc.
GLOBAL_LIST_EMPTY(wire_color_directory) // This is an associative list with the `holder_type` as the key, and a list of colors as the value.

var/global/list/portals = list()					//for use by portals
var/global/list/cable_list = list()					//Index for all cables, so that powernets don't have to look through the entire world all the time
var/global/list/chemical_reactions_list				//list of all /datum/chemical_reaction datums. Used during chemical reactions
var/global/list/chemical_reagents_list				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
var/global/list/landmarks_list = list()				//list of all landmarks created
var/global/list/surgery_steps = list()				//list of all surgery steps  |BS12
var/global/list/side_effects = list()				//list of all medical sideeffects types by thier names |BS12
var/global/list/mechas_list = list()				//list of all mechs. Used by hostile mobs target tracking.
var/global/list/spacepods_list = list()				//list of all space pods. Used by hostile mobs target tracking.
var/global/list/joblist = list()					//list of all jobstypes, minus borg and AI
var/global/list/airlocks = list()					//list of all airlocks
var/global/list/singularities = list()				//list of all singularities
var/global/list/janitorial_equipment = list()		//list of janitorial equipment

var/global/list/aibots = list() // AI controlled bots
var/global/list/table_recipes = list() //list of all table craft recipes

var/global/list/all_areas = list()
var/global/list/machines = list()
var/global/list/processing_power_items = list() //items that ask to be called every cycle
var/global/list/rcd_list = list() //list of Rapid Construction Devices.

var/global/list/apcs = list()
var/global/list/air_alarms = list()
var/global/list/power_monitors = list()

var/global/list/tracking_implants = list()			//list of all tracking implants to work out what treks everyone are on. Sadly not on lavaworld not implemented...
var/global/list/beacons = list()
var/global/list/shuttle_caller_list = list()  		//list of all communication consoles and AIs, for automatic shuttle calls when there are none.
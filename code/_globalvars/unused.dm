var/skipupdate = 0

var/shuttlecoming = 0
var/forceblob = 0
var/datum/debug/debugobj

var/list/liftable_structures = list(\
	/obj/machinery/autolathe, \
	/obj/machinery/constructable_frame, \
	/obj/machinery/portable_atmospherics/hydroponics, \
	/obj/machinery/computer, \
	/obj/machinery/optable, \
	/obj/structure/dispenser, \
	/obj/machinery/gibber, \
	/obj/machinery/kitchen_machine/microwave, \
	/obj/machinery/vending, \
	/obj/machinery/seed_extractor, \
	/obj/machinery/space_heater, \
	/obj/machinery/recharge_station, \
	/obj/machinery/flasher, \
	/obj/structure/stool, \
	/obj/structure/closet, \
	/obj/machinery/photocopier, \
	/obj/structure/filingcabinet, \
	/obj/structure/reagent_dispensers, \
	/obj/machinery/portable_atmospherics/canister)

var/starticon = null
var/midicon = null
var/endicon = null
var/datum/air_tunnel/air_tunnel1/SS13_airtunnel = null
var/going = 1.0
var/datum/engine_eject/engine_eject_control = null
//	list/traitors = list()	//traitor list
//	list/traitobj = list(  )
var/airtunnel_start = 68 // default
var/airtunnel_stop = 68 // default
var/airtunnel_bottom = 72 // default
// reverse_dir[dir] = reverse of dir


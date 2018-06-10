//--------------------------------------------
// Omni device port types
//--------------------------------------------
#define ATM_NONE	0
#define ATM_INPUT	1
#define ATM_OUTPUT	2

#define ATM_O2		3
#define ATM_N2		4
#define ATM_CO2		5
#define ATM_P		6	//Plasma
#define ATM_N2O		7

//--------------------------------------------
// Omni port datum
//
// Used by omni devices to manage connections
//  to other atmospheric objects.
//--------------------------------------------
/datum/omni_port
	var/obj/machinery/atmospherics/omni/master
	var/dir
	var/update = 1
	var/mode = 0
	var/concentration = 0
	var/con_lock = 0
	var/transfer_moles = 0
	var/datum/gas_mixture/air
	var/obj/machinery/atmospherics/node
	var/datum/pipeline/parent

/datum/omni_port/New(var/obj/machinery/atmospherics/omni/M, var/direction = NORTH)
	..()
	dir = direction
	if(istype(M))
		master = M
	air = new
	air.volume = 200

/datum/omni_port/proc/connect()
	if(node)
		return
	master.atmos_init()
	if(node)
		node.atmos_init()
		node.addMember(master)
	master.build_network()

/datum/omni_port/proc/disconnect()
	if(node)
		node.disconnect(master)
		node = null
		master.nullifyPipenet(parent)

//--------------------------------------------
// Need to find somewhere else for these
//--------------------------------------------

//returns a text string based on the direction flag input
// if capitalize is true, it will return the string capitalized
// otherwise it will return the direction string in lower case
/proc/dir_name(var/dir, var/capitalize = 0)
	var/string = null
	switch(dir)
		if(NORTH)
			string = "North"
		if(SOUTH)
			string = "South"
		if(EAST)
			string = "East"
		if(WEST)
			string = "West"

	if(!capitalize && string)
		string = lowertext(string)

	return string

//returns a direction flag based on the string passed to it
// case insensitive
/proc/dir_flag(var/dir)
	dir = lowertext(dir)
	switch(dir)
		if("north")
			return NORTH
		if("south")
			return SOUTH
		if("east")
			return EAST
		if("west")
			return WEST
		else
			return 0
		
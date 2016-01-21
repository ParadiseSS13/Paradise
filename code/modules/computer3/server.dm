/*
	Todo:
	I can probably get away with a global list on servers that contains database sort of stuff
	(replacing the datacore probably)
	with the justification that they loadbalance and duplicate data across each other.  As long as
	one server-type computer exists, the station will still have access to datacore-type info.

	I can doubtless use this for station alerts as well, which is good, because I was sort of
	wondering how the hell I was going to port that.

	Also todo: Server computers should maybe generate heat the way the R&D server does?
	At least the rack computer probably should.
*/

/obj/machinery/computer3/server
	name			= "server"
	icon			= 'icons/obj/computer3.dmi'
	icon_state		= "serverframe"
	show_keyboard	= 0

/obj/machinery/computer3/server/rack
	name = "server rack"
	icon_state = "rackframe"

	spawn_parts = list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/radio/subspace)

	update_icon()
		//overlays.Cut()
		return

	attack_hand() // Racks have no screen, only AI can use them
		return

/datum/map_template/shuttle/emergency/lance/preload()
	message_admins("Preloading [name]!")
	var/obj/docking_port/stationary/CCport
	CCport = SSshuttle.getDock("emergency_away")
	CCport.setDir(4)
	CCport.forceMove(locate(117, 80, 1))
	CCport.height = 50
	CCport.dheight = 0
	CCport.width = 19
	CCport.dwidth = 9
	var/obj/docking_port/stationary/CCtransit
	CCtransit = SSshuttle.getDock("emergency_transit")
	CCtransit.setDir(2)
	CCtransit.forceMove(locate(179, 166, 1))
	CCtransit.height = 50
	CCtransit.dheight = 0
	CCtransit.width = 19
	CCtransit.dwidth = 9
	var/obj/docking_port/stationary/syndicate
	syndicate = SSshuttle.getDock("emergency_syndicate")
	syndicate.setDir(8)
	syndicate.forceMove(locate(91, 159, 1))
	syndicate.height = 50
	syndicate.dheight = 0
	syndicate.width = 19
	syndicate.dwidth = 9
	qdel(SSshuttle.getDock("emergency_home"), TRUE)
	SSshuttle.emergency_locked_in = TRUE

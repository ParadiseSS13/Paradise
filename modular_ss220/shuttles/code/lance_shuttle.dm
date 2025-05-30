/datum/map_template/shuttle/emergency/lance/preload()
	message_admins("Preloading [name]!")
	var/obj/docking_port/stationary/CCport = SSshuttle.getDock("emergency_away")
	CCport.forceMove(locate(105, 83, 1))
	CCport.height = 50
	CCport.dheight = 0
	CCport.width = 19
	CCport.dwidth = 9
	var/obj/docking_port/stationary/syndicate = SSshuttle.getDock("emergency_syndicate")
	syndicate.setDir(8)
	syndicate.forceMove(locate(91, 159, 1))
	syndicate.height = 50
	syndicate.dheight = 0
	syndicate.width = 19
	syndicate.dwidth = 9
	var/obj/docking_port/stationary/home = SSshuttle.getDock("emergency_home")
	SSshuttle.stationary_docking_ports -= home
	qdel(home, TRUE)
	SSshuttle.emergency_locked_in = TRUE

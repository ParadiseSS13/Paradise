/obj/docking_port/mobile
	var/fly_sound = 'modular_ss220/aesthetics_sounds/sound/shuttle/hyperspace_mini.ogg'

/datum/controller/subsystem/shuttle/moveShuttle(shuttleId, dockId, timed, mob/user)
	. = ..()
	if(. == 0)
		var/obj/docking_port/mobile/M = getShuttle(shuttleId)
		M.areaInstance << M.fly_sound

/area/ai_monitored
	name = "AI Monitored Area"
	var/list/motioncameras = list()
	var/list/motionTargets = list()
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/ai_monitored/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/machinery/camera/M in src)
			if(M.isMotion())
				motioncameras.Add(M)
				M.AddComponent(/datum/component/proximity_monitor)
				M.set_area_motion(src)

/area/ai_monitored/Entered(atom/movable/O)
	..()
	if(ismob(O) && length(motioncameras))
		for(var/X in motioncameras)
			var/obj/machinery/camera/cam = X
			cam.newTarget(O)
			return

/area/ai_monitored/Exited(atom/movable/O)
	..()
	if(ismob(O) && length(motioncameras))
		for(var/X in motioncameras)
			var/obj/machinery/camera/cam = X
			cam.lostTargetRef(O.UID())
			return



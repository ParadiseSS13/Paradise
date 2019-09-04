/area/ai_monitored
	name = "AI Monitored Area"
	var/obj/machinery/camera/motioncamera = null


/area/ai_monitored/Initialize(mapload)
	. = ..()
	if(mapload)
		for (var/obj/machinery/camera/M in src)
			if(M.isMotion())
				motioncamera = M
				M.area_motion = src

/area/ai_monitored/Entered(atom/movable/O)
	..()
	if(ismob(O) && motioncamera)
		motioncamera.newTarget(O)

/area/ai_monitored/Exited(atom/movable/O)
	if(ismob(O) && motioncamera)
		motioncamera.lostTarget(O)



/area/station/engineering/engine/poweralert(state, source)
	if(state != poweralm)
		investigate_log("has a power alarm!", INVESTIGATE_SINGULO)
	..()

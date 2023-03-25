/area/engine/engineering/poweralert(state, obj/source)
	if(state != poweralm)
		source.investigate_log("has a power alarm!", INVESTIGATE_ENGINE)
	..()

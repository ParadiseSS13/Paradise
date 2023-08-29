SUBSYSTEM_DEF(cleaning_decals)
	name = "Cleaning decals"
	flags = SS_BACKGROUND | SS_NO_INIT
	priority = FIRE_PRIORITY_CLEANING_DEC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS
	cpu_display = SS_CPUDISPLAY_LOW
	offline_implications = "Space cleaner wont clean anymore. No immediate action is needed."
	///list of atoms and cleaning time info
	var/list/cleaning_decals = list()

/datum/controller/subsystem/cleaning_decals/fire(resumed)
	for(var/data in cleaning_decals)
		var/obj/effect/decal/cleanable/C = data[1]
		var/clean_time = data[2]
		if(QDELETED(C))
			cleaning_decals.Remove(data)
			continue
		var/iter = clean_time / (1 SECONDS)
		C.alpha -= (255 / iter)

/datum/controller/subsystem/cleaning_decals/proc/clean_soon(obj/effect/decal/cleanable/C, clean_time)
	cleaning_decals.Add(list(list(C, clean_time)))
	QDEL_IN(C, clean_time)

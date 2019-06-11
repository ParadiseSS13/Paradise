#define LOC_FPMAINT 0
#define LOC_FPMAINT1 1

#define HEADCRAB_NORMAL 0
#define HEADCRAB_SPECIAL 1
#define HEADCRAB_CLOWN 2

/datum/event/headcrabs
	announceWhen = 10
	endWhen = 11
	var/location
	var/locstring
	var/headcrab

/datum/event/headcrabs/start()

	location = rand(0,1)
	var/list/turf/simulated/floor/turfs = list()
	var/spawn_area_type
	switch(location)
		if(LOC_FPMAINT)
			spawn_area_type = /area/maintenance/fpmaint2
			locstring = "Arrivals North Maintenance"
		if(LOC_FPMAINT1)
			spawn_area_type = /area/maintenance/fpmaint2
			locstring = "Arrivals North Maintenance"

	for(var/areapath in typesof(spawn_area_type))
		var/area/A = locate(areapath)
		for(var/turf/simulated/floor/F in A.contents)
			if(turf_clear(F))
				turfs += F

	var/list/spawn_types = list()
	var/max_number
	headcrab = rand(0,1)
	switch(headcrab)
		if(HEADCRAB_NORMAL)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab)
			max_number = 12
		if(HEADCRAB_SPECIAL)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab)
			max_number = 12

	spawn(0)
		var/num = rand(2,max_number)
		while(turfs.len > 0 && num > 0)
			var/turf/simulated/floor/T = pick(turfs)
			turfs.Remove(T)
			num--
			var/spawn_type = pick(spawn_types)
			new spawn_type(T)


/datum/event/headcrabs/announce()
	event_announcement.Announce("Bioscans indicate that creatues have been breeding in [locstring]. Clear them out, before this starts to affect productivity.", "Lifesign Alert")

#undef LOC_FPMAINT
#undef LOC_FPMAINT1

#undef HEADCRAB_NORMAL
#undef HEADCRAB_SPECIAL
#undef HEADCRAB_CLOWN
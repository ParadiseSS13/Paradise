#define LOC_ATMOS_CONTROL 0
#define LOC_FPMAINT 1
#define LOC_FPMAINT2 2
#define LOC_FSMAINT 3
#define LOC_FSMAINT2 4
#define LOC_ASMAINT 5
#define LOC_ASMAINT2 6
#define LOC_APMAINT 7
#define LOC_MAINTCENTRAL 8
#define LOC_FORE 9
#define LOC_STARBOARD 10
#define LOC_PORT 11
#define LOC_AFT 12
#define LOC_STORAGE 13
#define LOC_DISPOSAL 14
#define LOC_GENETICS 15
#define LOC_ELECTRICAL 16
#define LOC_ABANDONEDBAR 17
#define LOC_ELECTRICAL_SHOP 18
#define LOC_GAMBLING_DEN 19

#define HEADCRAB_NORMAL 0
/*#define HEADCRAB_SPECIAL 1
#define HEADCRAB_CLOWN 2 */ //Planned for the future

/datum/event/headcrabs
	announceWhen = 10
	endWhen = 11
	var/location
	var/locstring
	var/headcrab

/datum/event/headcrabs/start()

	location = rand(0,19)
	var/list/turf/simulated/floor/turfs = list()
	var/spawn_area_type
	switch(location)
		if(LOC_ATMOS_CONTROL)	
			spawn_area_type = /area/maintenance/atmos_control
			locstring = "Atmospherics Maintenance"
		if(LOC_FPMAINT)
			spawn_area_type = /area/maintenance/fpmaint
			locstring = "EVA Maintenance"
		if(LOC_FPMAINT2)
			spawn_area_type = /area/maintenance/fpmaint2
			locstring = "Arrivals North Maintenance"
		if(LOC_FSMAINT)
			spawn_area_type = /area/maintenance/fsmaint
			locstring = "Dormitory Maintenance"
		if(LOC_FSMAINT2)
			spawn_area_type = /area/maintenance/fsmaint2
			locstring = "Bar Maintenance"
		if(LOC_ASMAINT)
			spawn_area_type = /area/maintenance/asmaint
			locstring = "Medbay Maintenance"
		if(LOC_ASMAINT2)
			spawn_area_type = /area/maintenance/asmaint2
			locstring = "Science Maintenance"
		if(LOC_APMAINT)
			spawn_area_type = /area/maintenance/apmaint
			locstring = "Cargo Maintenance"
		if(LOC_MAINTCENTRAL)
			spawn_area_type = /area/maintenance/maintcentral
			locstring = "Bridge Maintenance"
		if(LOC_FORE)
			spawn_area_type = /area/maintenance/fore
			locstring = "Fore Maintenance"
		if(LOC_STARBOARD)
			spawn_area_type = /area/maintenance/starboard
			locstring = "Starboard Maintenance"
		if(LOC_PORT)
			spawn_area_type = /area/maintenance/port
			locstring = "Locker Room Maintenance"
		if(LOC_AFT)
			spawn_area_type = /area/maintenance/aft
			locstring = "Engineering Maintenance"
		if(LOC_STORAGE)
			spawn_area_type = /area/maintenance/storage
			locstring = "Atmospherics Maintenance"
		if(LOC_DISPOSAL)
			spawn_area_type = /area/maintenance/disposal
			locstring = "Waste Disposal"
		if(LOC_GENETICS)
			spawn_area_type = /area/maintenance/genetics
			locstring = "Genetics Maintenance"
		if(LOC_ELECTRICAL)
			spawn_area_type = /area/maintenance/electrical
			locstring = "Electrical Maintenance"
		if(LOC_ABANDONEDBAR)
			spawn_area_type = /area/maintenance/abandonedbar
			locstring = "Maintenance Bar"
		if(LOC_ELECTRICAL_SHOP)
			spawn_area_type = /area/maintenance/electrical_shop
			locstring ="Electronics Den"
		if(LOC_GAMBLING_DEN)
			spawn_area_type = /area/maintenance/gambling_den
			locstring = "Gambling Den"
	for(var/areapath in typesof(spawn_area_type))
		var/area/A = locate(areapath)
		for(var/turf/simulated/floor/F in A.contents)
			if(turf_clear(F))
				turfs += F

	var/list/spawn_types = list()
	var/max_number
	headcrab = 0 //rand(0,x) for the future
	switch(headcrab) //Switch is for the future
		if(HEADCRAB_NORMAL)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab)
			max_number = 6

	spawn(0)
		var/num = rand(2,max_number)
		while(turfs.len > 0 && num > 0)
			var/turf/simulated/floor/T = pick(turfs)
			turfs.Remove(T)
			num--
			var/spawn_type = pick(spawn_types)
			new spawn_type(T)


/datum/event/headcrabs/announce()
	event_announcement.Announce("Bioscans indicate that creatures have been breeding in [locstring]. Clear them out, before this starts to affect productivity", "Lifesign Alert")

#undef LOC_ATMOS_CONTROL
#undef LOC_FPMAINT
#undef LOC_FPMAINT2
#undef LOC_FSMAINT
#undef LOC_FSMAINT2
#undef LOC_ASMAINT
#undef LOC_ASMAINT2
#undef LOC_APMAINT
#undef LOC_MAINTCENTRAL
#undef LOC_FORE
#undef LOC_STARBOARD 
#undef LOC_PORT 
#undef LOC_AFT 
#undef LOC_STORAGE 
#undef LOC_DISPOSAL 
#undef LOC_GENETICS 
#undef LOC_ELECTRICAL 
#undef LOC_ABANDONEDBAR 
#undef LOC_ELECTRICAL_SHOP 
#undef LOC_GAMBLING_DEN 

#undef HEADCRAB_NORMAL

#define HEADCRAB_NORMAL 0
#define HEADCRAB_FASTMIX 1
#define HEADCRAB_FAST 2
#define HEADCRAB_POISONMIX 3
#define HEADCRAB_POISON 4
#define HEADCRAB_SPAWNER 5

/datum/event/headcrabs
	announceWhen = 10
	endWhen = 11
	var/locstring
	var/headcrab_type

/datum/event/headcrabs/start()
	var/list/availableareas = list()
	for(var/area/maintenance/A in world)
		availableareas += A	
	var/area/randomarea = pick(availableareas)
	var/list/turf/simulated/floor/turfs = list()
	for(var/turf/simulated/floor/F in randomarea)
		if(turf_clear(F))
			turfs += F
	var/list/spawn_types = list()
	var/max_number
	headcrab_type = rand(0, 5)
	switch(headcrab_type) 
		if(HEADCRAB_NORMAL)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab)
			max_number = 6
		if(HEADCRAB_FASTMIX)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/fast)
			max_number = 8
		if(HEADCRAB_FAST)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab/fast)
			max_number = 6
		if(HEADCRAB_POISONMIX)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/poison)
			max_number = 4
		if(HEADCRAB_POISON)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab/poison)
			max_number = 3
		if(HEADCRAB_SPAWNER)
			spawn_types = list(/obj/structure/spawner/headcrab)
			max_number = 2


	var/num = rand(2,max_number)

	while(turfs.len > 0 && num > 0)
		var/turf/simulated/floor/T = pick(turfs)
		turfs.Remove(T)
		num--
		var/spawn_type = pick(spawn_types)
		new spawn_type(T)


/datum/event/headcrabs/announce()
	event_announcement.Announce("Bioscans indicate that headcrabs have been breeding on the station. Clear them out, before this starts to affect productivity", "Lifesign Alert")

#undef HEADCRAB_NORMAL
#undef HEADCRAB_FASTMIX
#undef HEADCRAB_FAST
#undef HEADCRAB_POISONMIX
#undef HEADCRAB_POISON
#undef HEADCRAB_SPAWNER
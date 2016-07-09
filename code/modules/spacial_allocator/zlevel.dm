/datum/zlevel
	var/flags = 0
	var/dirt_count = 0
	var/zpos
	var/list/init_list = list()

/datum/zlevel/New(z)
	zpos = z

/datum/zlevel/proc/resume_init()
	if(dirt_count > 0)
		throw EXCEPTION("Init told to resume when z-level still dirty. Z level: '[zpos]'")
	log_debug("Releasing freeze on z-level '[zpos]'!")
	log_debug("Beginning initialization!")
	var/list/our_atoms = init_list // OURS NOW!!! (Keeping this list to ourselves will prevent hijack)
	init_list = list()
	var/list/late_maps = list()
	var/list/pipes = list()
	var/list/cables = list()
	var/watch = start_watch()
	for(var/schmoo in our_atoms)
		var/atom/movable/AM = schmoo
		if(AM) // to catch stuff like the nuke disk that no longer exists

			// This can mess with our state - we leave these for last
			if(istype(AM, /obj/effect/landmark/map_loader))
				late_maps.Add(AM)
				continue
			AM.initialize()
			if(istype(AM, /obj/machinery/atmospherics))
				pipes.Add(AM)
			else if(istype(AM, /obj/structure/cable))
				cables.Add(AM)
	log_debug("Primary initialization finished in [stop_watch(watch)]s.")
	our_atoms.Cut()
	if(pipes.len)
		do_pipes(pipes)
	if(cables.len)
		do_cables(cables)
	if(late_maps.len)
		do_late_maps(late_maps)

/datum/zlevel/proc/do_pipes(list/pipes)
	var/watch = start_watch()
	log_debug("Building pipenets on z-level '[zpos]'!")
	for(var/schmoo in pipes)
		var/obj/machinery/atmospherics/machine = schmoo
		if(machine)
			machine.build_network()
	pipes.Cut()
	log_debug("Took [stop_watch(watch)]s")

/datum/zlevel/proc/do_cables(list/cables)
	var/watch = start_watch()
	log_debug("Building powernets on z-level '[zpos]'!")
	for(var/schmoo in cables)
		var/obj/structure/cable/C = schmoo
		if(C)
			makepowernet_for(C)
	cables.Cut()
	log_debug("Took [stop_watch(watch)]s")

/datum/zlevel/proc/do_late_maps(list/late_maps)
	var/watch = start_watch()
	log_debug("Loading map templates on z-level '[zpos]'!")
	zlevels.add_dirt(zpos) // Let's not repeatedly resume init for each template
	for(var/schmoo in late_maps)
		var/obj/effect/landmark/map_loader/ML = schmoo
		if(ML)
			ML.initialize()
	late_maps.Cut()
	zlevels.remove_dirt(zpos)
	log_debug("Took [stop_watch(watch)]s")

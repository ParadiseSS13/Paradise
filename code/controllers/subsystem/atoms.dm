#define BAD_INIT_QDEL_BEFORE 1
#define BAD_INIT_DIDNT_INIT 2
#define BAD_INIT_SLEPT 4
#define BAD_INIT_NO_HINT 8

SUBSYSTEM_DEF(atoms)
	name = "Atoms"
	init_order = INIT_ORDER_ATOMS
	flags = SS_NO_FIRE

	var/old_initialized

	var/list/late_loaders

	var/list/BadInitializeCalls = list()


/datum/controller/subsystem/atoms/Initialize(timeofday)
	setupgenetics()
	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()



/datum/controller/subsystem/atoms/proc/InitializeAtoms(list/atoms, noisy = TRUE)
	if(initialized == INITIALIZATION_INSSATOMS)
		return

	initialized = INITIALIZATION_INNEW_MAPLOAD

	LAZYINITLIST(late_loaders)

	var/watch = start_watch()
	if(noisy)
		log_startup_progress("Initializing atoms...")
	else
		log_debug("Initializing atoms...")
	var/count
	var/list/mapload_arg = list(TRUE)
	if(atoms)
		count = atoms.len
		for(var/I in atoms)
			var/atom/A = I
			if(A && !A.initialized)
				InitAtom(I, mapload_arg)
				CHECK_TICK
	else
		count = 0
		for(var/atom/A in world)
			if(!A.initialized)
				InitAtom(A, mapload_arg)
				++count
				CHECK_TICK

	if(noisy)
		log_startup_progress("	Initialized [count] atoms in [stop_watch(watch)]s")
	else
		log_debug("	Initialized [count] atoms in [stop_watch(watch)]s")
	pass(count)

	initialized = INITIALIZATION_INNEW_REGULAR

	if(late_loaders.len)
		watch = start_watch()
		if(noisy)
			log_startup_progress("Late-initializing atoms...")
		else
			log_debug("Late-initializing atoms...")
		for(var/I in late_loaders)
			var/atom/A = I
			A.LateInitialize()
		if(noisy)
			log_startup_progress("	Late initialized [late_loaders.len] atoms in [stop_watch(watch)]s")
		else
			log_debug("	Late initialized [late_loaders.len] atoms in [stop_watch(watch)]s")
		late_loaders.Cut()

/datum/controller/subsystem/atoms/proc/InitAtom(atom/A, list/arguments)
	var/the_type = A.type
	if(QDELING(A))
		BadInitializeCalls[the_type] |= BAD_INIT_QDEL_BEFORE
		return TRUE

	var/start_tick = world.time

	var/result = A.Initialize(arglist(arguments))

	if(start_tick != world.time)
		BadInitializeCalls[the_type] |= BAD_INIT_SLEPT

	var/qdeleted = FALSE

	if(result != INITIALIZE_HINT_NORMAL)
		switch(result)
			if(INITIALIZE_HINT_LATELOAD)
				if(arguments[1])	//mapload
					late_loaders += A
				else
					A.LateInitialize()
			if(INITIALIZE_HINT_QDEL)
				qdel(A)
				qdeleted = TRUE
			else
				BadInitializeCalls[the_type] |= BAD_INIT_NO_HINT

	if(!A)	//possible harddel
		qdeleted = TRUE
	else if(!A.initialized)
		BadInitializeCalls[the_type] |= BAD_INIT_DIDNT_INIT

	return qdeleted || QDELING(A)

/datum/controller/subsystem/atoms/proc/map_loader_begin()
	old_initialized = initialized
	initialized = INITIALIZATION_INSSATOMS

/datum/controller/subsystem/atoms/proc/map_loader_stop()
	initialized = old_initialized

/datum/controller/subsystem/atoms/Recover()
	initialized = SSatoms.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	old_initialized = SSatoms.old_initialized
	BadInitializeCalls = SSatoms.BadInitializeCalls

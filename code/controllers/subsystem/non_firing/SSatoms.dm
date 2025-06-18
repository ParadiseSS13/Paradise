SUBSYSTEM_DEF(atoms)
	name = "Atoms"
	init_order = INIT_ORDER_ATOMS
	flags = SS_NO_FIRE

	var/old_initialized

	var/list/late_loaders

	var/list/BadInitializeCalls = list()


/datum/controller/subsystem/atoms/Initialize()
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
	var/count
	var/list/mapload_arg = list(TRUE)
	if(atoms)
		count = length(atoms)
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
		log_startup_progress("Initialized [count] atoms in [stop_watch(watch)]s")

	initialized = INITIALIZATION_INNEW_REGULAR

	if(length(late_loaders))
		watch = start_watch()
		if(noisy)
			log_startup_progress("Late-initializing atoms...")
		for(var/I in late_loaders)
			var/atom/A = I
			A.LateInitialize()
			CHECK_TICK
		if(noisy)
			log_startup_progress("Late initialized [length(late_loaders)] atoms in [stop_watch(watch)]s")
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
	else
		SEND_SIGNAL(A, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)
		var/atom/location = A.loc
		if(location)
			SEND_SIGNAL(location, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, A, arguments[1])

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



/client/proc/debug_atom_init()
	set name = "Atom Init Log"
	set category = "Debug"
	set desc = "Shows what failed to init this round"

	if(!check_rights(R_DEBUG | R_VIEWRUNTIMES))
		return

	var/list/html_data = list()
	html_data += "<h1>Bad Initialize() Calls</h1><table border='1'><tr><th scope='col'>Type</th><th scope='col'>Qdeleted before init</th><th scope='col'>Did not init</th><th scope='col'>Slept during init</th><th scope='col'>No init hint</th></tr>"

	for(var/typepath in SSatoms.BadInitializeCalls)
		var/val = SSatoms.BadInitializeCalls[typepath]

		html_data += "<tr><td>[typepath]</td><td>[val & BAD_INIT_QDEL_BEFORE ? "X" : "&nbsp;"]</td><td>[val & BAD_INIT_DIDNT_INIT ? "X" : "&nbsp;"]</td><td>[val & BAD_INIT_SLEPT ? "X" : "&nbsp;"]</td><td>[val & BAD_INIT_NO_HINT ? "X" : "&nbsp;"]</td></tr>"

	html_data += "</table>"

	usr << browse(html_data.Join(), "window=initdebug")


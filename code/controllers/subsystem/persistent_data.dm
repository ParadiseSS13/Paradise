/**
  * # Persistent Data Subsystem
  *
  * Provides a centralised handler for persistent data reading and writing.
  * The subsystem does not do any actual spawning itself, as this focuses on objects and mobs
  * Should anything that is turf persistence related added in, that can be chucked into this SS
  * Its quite a simple subsystem. For now, anyways.
  *
  */
SUBSYSTEM_DEF(persistent_data)
	name = "Persistent Data"
	init_order = INIT_ORDER_PERSISTENCE // -95 | Loads after EVERYTHING else
	flags = SS_NO_FIRE
	/// List of atoms registered into the subsystem for persistent data storage. Can be anything at all
	var/list/registered_atoms = list()

/datum/controller/subsystem/persistent_data/Initialize()
	// Load all the data of registered atoms
	for(var/atom/A in registered_atoms)
		A.persistent_load()
	loadTurfs()
	loadObjects()
	return ..()

/datum/controller/subsystem/persistent_data/Shutdown()
	// Save all the data of registered atoms
	for(var/atom/A in registered_atoms)
		A.persistent_save()

/datum/controller/subsystem/persistent_data/proc/loadTurfs()
	log_startup_progress("DB >> loading turfs...")
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT
			x,y,z,
			data,
			air
		FROM
			rs_world_turfs
	"})
	query.Execute()
	while(query.NextRow())
		var/list/data = json_decode(query.item[4])
		var/turf_path = text2path(data["type"])
		var/turf/T = locate(text2num(query.item[1]),text2num(query.item[2]),text2num(query.item[3]))
		log_startup_progress("DB >> spawning turf [turf_path] at [T.x],[T.y],[T.z]")
		T.ChangeTurf(turf_path)
		T.deserialize(data)
	qdel(query)

/datum/controller/subsystem/persistent_data/proc/loadObjects()
	log_startup_progress("DB >> loading objs/mobs...")
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT
			x,y,z,
			data,
			uid
		FROM
			rs_world_objects
	"})
	query.Execute()
	while(query.NextRow())
		var/list/data = json_decode(query.item[4])
		var/turf_path = text2path(data["type"])
		var/turf/T = locate(text2num(query.item[1]),text2num(query.item[2]),text2num(query.item[3]))
		var/atom/A = list_to_object(data, T)
		A.db_uid = text2num(query.item[5])
		log_startup_progress("DB >> spawning [turf_path] at [A.x],[A.y],[A.z]")
		if(istype(A, /obj))
			var/obj/O = A
			O?.update_icon()
		if(ismob(A))
			A.pixel_x = 0
			A.pixel_y = 0
	qdel(query)


/**
  * Proc to register an atom with SSpersistent_data
  *
  * This will add any provided atom to the list of registered atoms, and add it to the Initialization queue
  * If the system has already initialized, it calls persistent_load() at that moment
  *
  * Arguments:
  * * A - Atom to register
  */
/datum/controller/subsystem/persistent_data/proc/register(atom/A)
	registered_atoms |= A
	if(initialized)
		A.persistent_load()

/**
  * Atom Persistent Loader
  *
  * Overridden on every atom which needs to load persistent data
  */
/atom/proc/persistent_load()
	stack_trace("peristent_load() called on an atom which does not have persistent data storage!")

/**
  * Atom Persistent Saver
  *
  * Overridden on every atom which needs to save persistent data
  */
/atom/proc/persistent_save()
	stack_trace("peristent_save() called on an atom which does not have persistent data storage!")


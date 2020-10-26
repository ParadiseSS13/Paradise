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
		A.PersistentLoad()
	return ..()

/datum/controller/subsystem/persistent_data/Shutdown()
	// Save all the data of registered atoms
	for(var/atom/A in registered_atoms)
		A.PersistentSave()


/**
  * Proc to register an atom with SSpersistent_data
  *
  * This will add any provided atom to the list of registered atoms, and add it to the Initialization queue
  * If the system has already initialized, it calls PersistentLoad() at that moment
  *
  * Arguments:
  * * A - Atom to register
  */
/datum/controller/subsystem/persistent_data/proc/register(atom/A)
	registered_atoms |= A
	if(initialized)
		A.PersistentLoad()

/**
  * Atom Persistent Loader
  *
  * Overridden on every atom which needs to load persistent data
  */
/atom/proc/PersistentLoad()
	stack_trace("PeristentLoad() called on an atom which does not have persistent data storage!")

/**
  * Atom Persistent Saver
  *
  * Overridden on every atom which needs to save persistent data
  */
/atom/proc/PersistentSave()
	stack_trace("PeristentSave() called on an atom which does not have persistent data storage!")


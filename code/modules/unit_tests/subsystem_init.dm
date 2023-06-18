/datum/unit_test/subsystem_init/Run()
	var/datum/controller/subsystem/base_ss
	var/default_offline_implications = initial(base_ss.offline_implications)
	for(var/datum/controller/subsystem/SS as anything in Master.subsystems)
		if((SS.flags & SS_NO_INIT) && (SS.flags & SS_NO_FIRE))
			Fail("[SS]([SS.type]) is a subsystem which is set to not initialize or fire. Use a global datum instead an SS.")

		if(!(SS.flags & SS_NO_FIRE) && SS.offline_implications == default_offline_implications)
			Fail("[SS]([SS.type]) is a subsystem which fires but has no offline implications set.")

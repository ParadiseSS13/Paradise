var/global/datum/controller/failsafe/failsafe

/datum/controller/failsafe // This thing pretty much just keeps poking the controllers.
	processing_interval = 100 // Poke the controllers every 10 seconds.

	/*
	 * Controller alert level.
	 * For every poke that fails this is raised by 1.
	 * When it reaches 5 the MC is replaced with a new one
	 * (effectively killing any controller process() and starting a new one).
	 */

	// master
	var/masterControllerIteration = 0
	var/masterControllerAlertLevel = 0

/datum/controller/failsafe/New()
	. = ..()

	// There can be only one failsafe. Out with the old in with the new (that way we can restart the Failsafe by spawning a new one).
	if(failsafe != src)
		if(istype(failsafe))
			recover()
			qdel(failsafe)

		failsafe = src

	//failsafe.process()

/datum/controller/failsafe/proc/process()
	processing = 1

	spawn(0)
		set background = BACKGROUND_ENABLED

		while(1) // More efficient than recursivly calling ourself over and over. background = 1 ensures we do not trigger an infinite loop.
			iteration++

			sleep(processing_interval)

/datum/controller
	var/name
	// The object used for the clickable stat() button.
	var/obj/effect/statclick/statclick

/datum/controller/proc/Initialize()

//cleanup actions
/datum/controller/proc/Shutdown()

//when we enter dmm_suite.load_map
/datum/controller/proc/StartLoadingMap()

//when we exit dmm_suite.load_map
/datum/controller/proc/StopLoadingMap()

/datum/controller/proc/Recover()

/datum/controller/proc/stat_entry()

/**
 * Standardized method for tracking startup times.
 */
/datum/controller/proc/log_startup_progress(message)
	Master.last_init_info = "([name]): [message]"
	to_chat(world,
		type = MESSAGE_TYPE_DEBUG,
		html = "<span class='danger'><small>\[[name]]</small> [message]</span>",
		confidential = TRUE)
	log_world("\[[name]] [message]")

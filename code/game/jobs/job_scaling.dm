/hook/roundstart/proc/jobscaling()
	sleep(10 SECONDS) // give everyone time to finish spawning, and the lag to die down
	var/playercount = length(GLOB.clients)
	var/highpop_trigger = 80

//	if(using_map&&using_map.name=="Ragnarok")								// This code is used to use the necessary job_scaling for Ragnarok. Unless the config is moved into
//		log_debug("NSS Ragnarok loading, running jobs_ragnarok config");	// the main code system, it will generate a Travis Merge Conflict as the config/jobs_ragnarok.txt is
//		job_master.LoadJobs("config/jobs_ragnarok.txt")						// not defined. Add config and un-note lines to use. Add an else to the next line in order to finish code
	if(playercount >= highpop_trigger)
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - loading highpop job config");
		job_master.LoadJobs("config/jobs_highpop.txt")
	else
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - keeping standard job config");
	return 1
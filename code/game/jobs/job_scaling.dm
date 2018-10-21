/hook/roundstart/proc/jobscaling()
	sleep(10 SECONDS) // give everyone time to finish spawning, and the lag to die down
	var/playercount = length(GLOB.clients)
	var/highpop_trigger = 80

	if(playercount >= highpop_trigger)
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - loading highpop job config");
		job_master.LoadJobs("config/jobs_highpop.txt")
	else
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - keeping standard job config");
	return 1
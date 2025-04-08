/datum/game_test/job_defines

/datum/game_test/job_defines/Run()
	validate()

/datum/game_test/job_defines/proc/validate()
	if(JOBCAT_LAST_ENGSEC == 0)
		Fail("JOBCAT_LAST_ENGSEC overflow! Please optimize job flags. Any change will also cause SQL migration.")

	if(JOBCAT_LAST_MEDSCI == 0)
		Fail("JOBCAT_LAST_MEDSCI overflow! Please optimize job flags. Any change will also cause SQL migration.")

	if(JOBCAT_LAST_SUPPORT == 0)
		Fail("JOBCAT_LAST_SUPPORT overflow! Please optimize job flags. Any change will also cause SQL migration.")

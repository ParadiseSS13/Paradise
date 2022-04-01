// Returns a reason if M is banned from rank, returns null otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(!M || !M.client || !rank)
		return null

	if(GLOB.configuration.jobs.guest_job_ban && IsGuestKey(M.key))
		return "Guest Job-ban"

	if(rank in M.client.jbh.job_bans)
		var/datum/job_ban/JB = M.client.jbh.job_bans[rank]
		return JB.reason

	return null

// Gets all the job bans for a ckey incase they are offline
/proc/get_jobbans_for_offline_ckey(ckey)
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT job FROM ban
		WHERE ckey LIKE :ckey AND ((bantype LIKE 'JOB_TEMPBAN' AND expiration_time > NOW()) OR (bantype LIKE 'JOB_PERMABAN')) AND ISNULL(unbanned)
		ORDER BY bantime DESC LIMIT 100"},
		list("ckey" = ckey)
	)

	if(!query.warn_execute())
		qdel(query)
		return FALSE

	var/list/jobs = list()

	while(query.NextRow())
		jobs += query.item[1]

	return jobs

/client/verb/displayjobbans()
	set category = "OOC"
	set name = "Display Current Jobbans"
	set desc = "Displays all of your current jobbans."

	// Ok. I know this verb here is scoped to client, I know.
	// But sometimes when executing, the src will be a mob
	// I have no idea why, but this is a workaround.
	jbh.reload_jobbans(usr.client)

	if(!length(jbh.job_bans))
		to_chat(src, "<span class='warning'>You have no active jobbans!</span>")
		return

	for(var/ban in jbh.job_bans)
		var/datum/job_ban/JB = jbh.job_bans[ban] // Remember. Its assoc.
		switch(JB.bantype)
			if("JOB_PERMABAN")
				to_chat(src, "<span class='warning'>[JB.bantype]: [JB.job] - REASON: [JB.reason], by [JB.a_ckey]; [JB.bantime]</span>")
			if("JOB_TEMPBAN")
				to_chat(src, "<span class='warning'>[JB.bantype]: [JB.job] - REASON: [JB.reason], by [JB.a_ckey]; [JB.bantime]; [JB.duration]; expires [JB.expiration_time]</span>")

	if(GLOB.configuration.url.banappeals_url)
		to_chat(src, "<span class='warning'>You can appeal the bans at: [GLOB.configuration.url.banappeals_url]</span>")


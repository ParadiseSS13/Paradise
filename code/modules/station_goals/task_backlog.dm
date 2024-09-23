/datum/station_goal/clear_task_backlog
	name = "Clear Task Backlog"
	var/goal = 10

/datum/station_goal/clear_task_backlog/get_report()
	return {"<b>Clear Task Backlog</b><br>
	The last few weeks have been extremely profitable for Nanotrasen, but
	we've got so many things to do that we're getting a bit overwhelmed.<br>
	<br>
	We need you to pick up the slack. Use the Request Consoles on your
	station to get Secondary Goals, and complete at least [goal] of them.
	<br>
	<br>
	-Nanotrasen Accounting"}

/datum/station_goal/clear_task_backlog/check_completion()
	if(..())
		return TRUE
	var/count = 0
	for(var/datum/station_goal/secondary/S in SSticker.mode.secondary_goals)
		if(S.completed)
			count++
	return count >= goal

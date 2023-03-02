//TODO
// Admin button to override with your own
// Sabotage objective for tators
// Multiple goals with less impact but more department focused

/datum/station_goal
	var/name = "Generic Goal"
	var/weight = 1 //In case of multiple goals later.
	var/required_crew = 10
	var/list/gamemode_blacklist = list()
	var/completed = FALSE
	var/report_message = "Complete this goal."
	var/list/obj/item/paper/papers_list = list()
	var/list/datum/supply_packs/supply_list = list()

/datum/station_goal/proc/send_report()
	var/directive = "Nanotrasen Directive [pick(GLOB.phonetic_alphabet)] \Roman[rand(1,50)]"
	GLOB.priority_announcement.Announce("Поступила приоритетная директива Нанотрейзен. Отправлены подробности проекта «[name]».", "Приоритетное оповещение.", 'sound/AI/commandreport.ogg')
	print_command_report("<div style='text-align:center;'><img src='ntlogo.png'>" + "<h3>[directive]</h3></div><hr>" + get_report(), "[directive]", FALSE, src)
	on_report()

/datum/station_goal/proc/on_report()
	//Additional unlocks/changes go here
	return

/datum/station_goal/proc/get_report()
	return report_message

/datum/station_goal/proc/check_completion()
	return completed

/datum/station_goal/proc/print_result()
	if(check_completion())
		to_chat(world, "<b>Station Goal</b>: [name]:  <span class='greenannounce'>Completed!</span>")
	else
		to_chat(world, "<b>Station Goal</b>: [name]: <span class='boldannounce'>Failed!</span>")

/datum/station_goal/Destroy()
	SSticker.mode.station_goals -= src
	QDEL_LIST(papers_list)
	for(var/datum/supply_packs/P in supply_list)
		P.special_enabled = FALSE
	. = ..()

/datum/station_goal/Topic(href, href_list)
	..()

	if(!check_rights(R_EVENT))
		return

	if(href_list["announce"])
		on_report()
		send_report()
	else if(href_list["remove"])
		qdel(src)

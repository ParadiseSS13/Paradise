

//WIP machine that serves as a power sink, to make it useful
/obj/machinery/power/bluespace_tap
	name = "Bluespace mining tap"
	icon = 'icons/obj/stationobjs.dmi'//TODO
	use_power = NO_POWER_USE	//don't pull automatic power
	idle_power_usage = 10
	active_power_usage = 500//value that will be multiplied with mining level to generate actual power use
	var/level = 0	//the level the machine is set to mine at. 0 means off
	var/points = 0	//mining points
	interact_offline = 1




/obj/machinery/power/bluespace_tap/Topic(href, href_list)
	if(..())
		return 1




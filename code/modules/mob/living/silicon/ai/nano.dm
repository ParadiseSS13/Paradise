/mob/living/silicon/ai
  var/obj/nano_module/crew_monitor/crew_monitor

/mob/living/silicon/ai/proc/init_subsystems()
	crew_monitor = new(src)

/mob/living/silicon/ai/proc/nano_crew_monitor()
	set category = "AI Commands"
	set name = "Crew Monitor"

	crew_monitor.ui_interact(usr)
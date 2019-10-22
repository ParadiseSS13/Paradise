var/list/PASS_list = list()

/obj/item/assembly/timer/pass
	name = "Personal Alert Safety System"
	desc = "A device that plays a very loud alarm if it isn't moved for 30 seconds."
	icon_state = "timer"
	var/lastloc = null
	var/loca = null
	var/alarm = 0
	var/list/pass_sounds = list('sound/effects/alert.ogg' = 1)



/obj/item/assembly/timer/pass/Initialize
	. = ..()
	AddComponent(/datum/component/squeak, pass_sounds, 100)


/obj/item/assembly/timer/pass/describe()
	if(timing)
		return "The PASS will go off in [time] seconds if not moved!"
	return "The timer is set for [time] seconds."


/obj/item/assembly/timer/pass/process()
	if(alarm == 1)
		playsound(loca,'sound/effects/alert.ogg', 150, 1)
	if(timing && (time > 0))
		loca = get_turf(src)
		if(loca == lastloc)
			time -= 2 // 2 seconds per process()
		else
			time = set_time
			alarm = 0
		lastloc = loca

	if(timing && time <= 0)
		timing = repeat
		timer_end()
		alarm = 1
		time = set_time


/obj/machinery/computer/monitor
	name = "power monitoring console"
	desc = "Used to monitor power levels across the station."
	icon_screen = "power"
	icon_keyboard = "power_key"
	use_power = 2
	idle_power_usage = 20
	active_power_usage = 80
	light_color = LIGHT_COLOR_ORANGE
	circuit = /obj/item/weapon/circuitboard/powermonitor
	var/datum/powernet/powernet = null
	var/datum/nano_module/power_monitor/power_monitor

/obj/machinery/computer/monitor/New()
	power_monitor = new(src)	
	powernet = find_powernet()
		
	..()
	
/obj/machinery/computer/monitor/process() 
	if(!powernet)
		powernet = find_powernet()
	..()
			
/obj/machinery/computer/monitor/proc/find_powernet() 
	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		return attached.get_powernet()
			
/obj/machinery/computer/monitor/attack_ai(mob/user)
	attack_hand(user)
	ui_interact(user)
	
/obj/machinery/computer/monitor/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	power_monitor.ui_interact(user, ui_key, ui, force_open)

/obj/machinery/computer/monitor/interact(mob/user)
	power_monitor.ui_interact(user)
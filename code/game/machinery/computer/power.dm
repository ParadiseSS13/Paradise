/obj/machinery/computer/monitor
	name = "power monitoring console"
	desc = "Used to monitor power levels across the station."
	icon_screen = "power"
	icon_keyboard = "power_key"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 80
	light_color = LIGHT_COLOR_ORANGE
	circuit = /obj/item/circuitboard/powermonitor
	var/datum/powernet/powernet = null
	var/datum/nano_module/power_monitor/power_monitor
	var/is_secret_monitor = FALSE

/obj/machinery/computer/monitor/secret //Hides the power monitor (such as ones on ruins & CentCom) from PDA's to prevent metagaming.
	name = "outdated power monitoring console"
	desc = "It monitors power levels across the local powernet."
	circuit = /obj/item/circuitboard/powermonitor/secret
	is_secret_monitor = TRUE

/obj/machinery/computer/monitor/New()
	..()
	GLOB.power_monitors += src
	GLOB.power_monitors = sortAtom(GLOB.power_monitors)
	power_monitor = new(src)

/obj/machinery/computer/monitor/Initialize()
	..()
	GLOB.powermonitor_repository.update_cache()
	powernet = find_powernet()

/obj/machinery/computer/monitor/Destroy()
	GLOB.power_monitors -= src
	GLOB.powermonitor_repository.update_cache()
	QDEL_NULL(power_monitor)
	return ..()

/obj/machinery/computer/monitor/power_change()
	..()
	GLOB.powermonitor_repository.update_cache()

/obj/machinery/computer/monitor/proc/find_powernet()
	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		return attached.powernet

/obj/machinery/computer/monitor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/monitor/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	// Update the powernet
	powernet = find_powernet()
	ui_interact(user)

/obj/machinery/computer/monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	power_monitor.ui_interact(user, ui_key, ui, force_open)

/obj/machinery/computer/monitor/interact(mob/user)
	power_monitor.ui_interact(user)

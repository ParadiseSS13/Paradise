//Controlling the reactor.

/obj/machinery/computer/reactor
	name = "reactor control console"
	desc = "Scream"
	light_color = "#55BA55"
	light_power = 1
	light_range = 3
	icon_state = "computer"
	icon_screen = "power"
	icon_keyboard = null
	var/obj/machinery/atmospherics/trinary/nuclear_reactor/reactor = null
	var/id = "default_reactor_for_lazy_mappers"

/obj/machinery/computer/reactor/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(link_to_reactor)), 10 SECONDS)

/obj/machinery/computer/reactor/proc/link_to_reactor()
	for(var/obj/machinery/atmospherics/trinary/nuclear_reactor/asdf in GLOB.machines)
		if(asdf.id && asdf.id == id)
			reactor = asdf
			return TRUE
	return FALSE

#define FREQ_RBMK_CONTROL 1439.69

/obj/machinery/computer/reactor/control_rods
	name = "control rod management computer"
	desc = "A computer which can remotely raise / lower the control rods of a reactor."
	icon_screen = "engie_cams"

/obj/machinery/computer/reactor/control_rods/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/reactor/control_rods/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RbmkControlRods", name, master_ui, state)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/reactor/control_rods/ui_act(action, params)
	if(..())
		return
	if(!reactor)
		return
	if(action == "input")
		var/input = text2num(params["target"])
		reactor.desired_k = CLAMP(input, 0, 3)

/obj/machinery/computer/reactor/control_rods/ui_data(mob/user)
	var/list/data = list()
	data["control_rods"] = 0
	data["k"] = 0
	data["desiredK"] = 0
	if(reactor)
		data["k"] = reactor.K
		data["desiredK"] = reactor.desired_k
		data["control_rods"] = 100 - (reactor.desired_k / 3 * 100) //Rod insertion is extrapolated as a function of the percentage of K
	return data

/obj/machinery/computer/reactor/stats
	name = "reactor statistics console"
	desc = "A console for monitoring the statistics of a nuclear reactor."
	icon_screen = "power"
	var/next_stat_interval = 0
	var/list/psiData = list()
	var/list/powerData = list()
	var/list/tempInputData = list()
	var/list/tempOutputdata = list()

/obj/machinery/computer/reactor/stats/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/reactor/stats/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RbmkStats", name, master_ui, state)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/reactor/stats/process()
	if(world.time >= next_stat_interval)
		next_stat_interval = world.time + 1 SECONDS //You only get a slow tick.
		psiData += (reactor) ? reactor.pressure : 0
		if(psiData.len > 100) //Only lets you track over a certain timeframe.
			psiData.Cut(1, 2)
		powerData += (reactor) ? reactor.power*10 : 0 //We scale up the figure for a consistent:tm: scale
		if(powerData.len > 100) //Only lets you track over a certain timeframe.
			powerData.Cut(1, 2)
		tempInputData += (reactor) ? reactor.last_coolant_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempInputData.len > 100) //Only lets you track over a certain timeframe.
			tempInputData.Cut(1, 2)
		tempOutputdata += (reactor) ? reactor.last_output_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempOutputdata.len > 100) //Only lets you track over a certain timeframe.
			tempOutputdata.Cut(1, 2)

/obj/machinery/computer/reactor/stats/ui_data(mob/user)
	var/list/data = list()
	data["powerData"] = powerData
	data["psiData"] = psiData
	data["tempInputData"] = tempInputData
	data["tempOutputdata"] = tempOutputdata
	data["coolantInput"] = reactor ? reactor.last_coolant_temperature : 0
	data["coolantOutput"] = reactor ? reactor.last_output_temperature : 0
	data["power"] = reactor ? reactor.power : 0
	data ["psi"] = reactor ? reactor.pressure : 0
	return data

/obj/machinery/computer/reactor/fuel_rods
	name = "Reactor Fuel Management Console"
	desc = "A console which can remotely raise fuel rods out of nuclear reactors."
	icon_screen = "forensics"

/obj/machinery/computer/reactor/fuel_rods/attack_hand(mob/living/user)
	. = ..()
	if(!reactor)
		return FALSE
	if(reactor.power > 20)
		to_chat(user, "<span class='warning'>You cannot remove fuel from [reactor] when it is above 20% power.</span>")
		return FALSE
	if(!reactor.fuel_rods.len)
		to_chat(user, "<span class='warning'>[reactor] does not have any fuel rods loaded.</span>")
		return FALSE
	var/atom/movable/fuel_rod = input(usr, "Select a fuel rod to remove", "[src]", null) as null|anything in reactor.fuel_rods
	if(!fuel_rod)
		return
	playsound(src, pick('sound/effects/rbmk/switch.ogg','sound/effects/rbmk/switch2.ogg','sound/effects/rbmk/switch3.ogg'), 100, FALSE)
	playsound(reactor, 'sound/effects/rbmk/crane_1.wav', 100, FALSE)
	fuel_rod.forceMove(get_turf(reactor))
	reactor.fuel_rods -= fuel_rod

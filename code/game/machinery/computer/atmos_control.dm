GLOBAL_LIST_EMPTY(gas_sensors)

/obj/machinery/atmospherics/air_sensor
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF
	name = "gas sensor"

	anchored = TRUE
	var/state = 0
	var/bolts = TRUE

	on = TRUE
	var/output = 3
	//Flags:
	// 1 for pressure
	// 2 for temperature
	// Output >= 4 includes gas composition
	// 4 for oxygen concentration
	// 8 for toxins concentration
	// 16 for nitrogen concentration
	// 32 for carbon dioxide concentration

/obj/machinery/atmospherics/air_sensor/Initialize(mapload)
	. = ..()
	GLOB.gas_sensors += src

/obj/machinery/atmospherics/air_sensor/Destroy()
	GLOB.gas_sensors -= src
	return ..()

/obj/machinery/atmospherics/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"

#warn multitool_act
/obj/machinery/atmospherics/air_sensor/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/multitool))
		return TRUE

	if(istype(W, /obj/item/wrench))
		if(bolts)
			to_chat(usr, "[src] is bolted to the floor! You can't detach it like this.")
			return TRUE

		playsound(loc, W.usesound, 50, 1)
		to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")

		if(do_after(user, 40 * W.toolspeed, target = src))
			user.visible_message("[user] unfastens \the [src].", "<span class='notice'>You have unfastened \the [src].</span>", "You hear ratchet.")
			new /obj/item/pipe_gsensor(src.loc)
			qdel(src)
			return TRUE

		return

	return ..()

/obj/machinery/computer/general_air_control
	name = "air sensor monitor"
	icon = 'icons/obj/computer.dmi'
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/air_management
	// Map set vars
	/// List of sensors to autolink to. Key = sensor_id, Value = sensor display name
	var/list/autolink_sensors = list()

	// Instanced vars. These are /tmp/ to avoid mappers trying to set them
	/// List of sensor names to UIDs to be used in the display
	var/tmp/list/sensor_name_uid_map = list()

/obj/machinery/computer/general_air_control/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD // Do all our work in here

/obj/machinery/computer/general_air_control/LateInitialize()
	for(var/obj/machinery/atmospherics/air_sensor/AS as anything in GLOB.gas_sensors)
		for(var/sensor_id in autolink_sensors)
			if(AS.autolink_id == sensor_id)
				sensor_name_uid_map[autolink_sensors[sensor_id]]  = AS.UID()

	if(!length(sensor_name_uid_map))
		stack_trace("[src] at [x],[y],[z] failed to initialise its air sensors.")

/obj/machinery/computer/general_air_control/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/general_air_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// We can use the same template here for sensors and for tanks with inlets/outlets with TGUI memes
		ui = new(user, src, ui_key, "AtmosTankControl", name, 400, 400, master_ui, state)
		ui.open()


/obj/machinery/computer/general_air_control/large_tank_control
	circuit = /obj/item/circuitboard/large_tank_control

	// Map set vars
	/// Autolink ID of the chamber inlet injector
	var/inlet_injector_autolink_id
	/// Autolink ID of the chamber outlet vent
	var/outlet_vent_autolink_id

	// Instanced vars. These are /tmp/ to avoid mappers trying to set them
	/// The runtime UID of the inlet injector
	var/tmp/inlet_injector_uid
	/// The runtime UID of the outlet vent
	var/tmp/outlet_vent_uid

	var/pressure_setting = ONE_ATMOSPHERE * 45

#warn multitool act
/*
/obj/machinery/computer/general_air_control/large_tank_control/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/multitool))
		update_multitool_menu(user)
		return TRUE

	return ..()
*/

#warn needs TGUIing
/*
/obj/machinery/computer/general_air_control/large_tank_control/proc/bollocks()
	var/output = "piss"
	//if(signal.data)
	//	input_info = signal.data // Attempting to fix intake control -- TLE

	output += "<h2>Tank Control System</h2><BR>"
	if(input_tag)
		if(input_info)
			var/power = (input_info["power"])
			var/volume_rate = input_info["volume_rate"]
			output += {"
<fieldset>
	<legend>Input (<A href='?src=[UID()];in_refresh_status=1'>Refresh</A>)</legend>
	<table>
		<tr>
			<th>State:</th>
			<td><A href='?src=[UID()];in_toggle_injector=1'>[power?("Injecting"):("On Hold")]</A></td>
		</tr>
		<tr>
			<th>Rate:</th>
			<td>[volume_rate] L/sec</td>
		</tr>
	</table>
</fieldset>
"}
		else
			output += "<FONT color='red'>ERROR: Can not find input port</FONT> <A href='?src=[UID()];in_refresh_status=1'>Search</A><BR>"

	if(output_tag)
		if(output_info)
			var/power = (output_info["power"])
			var/output_pressure = output_info["internal"]
			output += {"
<fieldset>
	<legend>Output (<A href='?src=[UID()];out_refresh_status=1'>Refresh</A>)</legend>
	<table>
		<tr>
			<th>State:</th>
			<td><A href='?src=[UID()];out_toggle_power=1'>[power?("Open"):("On Hold")]</A></td>
		</tr>
		<tr>
			<th>Max Output Pressure:</th>
			<td><A href='?src=[UID()];out_set_pressure=1'>[output_pressure]</A> kPa</td>
		</tr>
	</table>
</fieldset>
"}
		else
			output += "<FONT color='red'>ERROR: Can not find output port</FONT> <A href='?src=[UID()];out_refresh_status=1'>Search</A><BR>"
	return output
	*/

/obj/machinery/computer/general_air_control/large_tank_control/Topic(href, href_list)
	if(..())
		return TRUE

	add_fingerprint(usr)

	if(href_list["out_set_pressure"])
		var/response=input(usr,"Set new pressure, in kPa. \[0-[50*ONE_ATMOSPHERE]\]") as num
		pressure_setting = text2num(response)
		pressure_setting = clamp(pressure_setting, 0, 50*ONE_ATMOSPHERE)


	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	/*
	if(href_list["in_refresh_status"])
		input_info = null
		signal.data = list ("tag" = input_tag, "status" = 1)

	else if(href_list["in_toggle_injector"])
		input_info = null
		signal.data = list ("tag" = input_tag, "power_toggle" = 1)

	else if(href_list["out_refresh_status"])
		output_info = null
		signal.data = list ("tag" = output_tag, "status" = 1)

	else if(href_list["out_toggle_power"])
		output_info = null
		signal.data = list ("tag" = output_tag, "power_toggle" = 1)

	else if(href_list["out_set_pressure"])
		output_info = null
		signal.data = list ("tag" = output_tag, "set_internal_pressure" = "[pressure_setting]")
	/*else
		testing("Bad Topic() to GAC \"[src.name]\": [href]")
		return*/ // NOPE. // disabling because it spams when multitool menus are used

	signal.data["sigtype"] = "command"
	updateUsrDialog()
	*/



// Central atmos control //
/obj/machinery/computer/atmoscontrol
	name = "\improper central atmospherics computer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "atmos_key"
	icon_screen = "tank"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/atmoscontrol
	req_access = list(ACCESS_ATMOSPHERICS)
	var/datum/ui_module/atmos_control/atmos_control

/obj/machinery/computer/atmoscontrol/Initialize(mapload)
	. = ..()
	atmos_control = new(src)

/obj/machinery/computer/atmoscontrol/Destroy()
	QDEL_NULL(atmos_control)
	return ..()

/obj/machinery/computer/atmoscontrol/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/atmoscontrol/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	atmos_control.ui_interact(user, ui_key, ui, force_open)

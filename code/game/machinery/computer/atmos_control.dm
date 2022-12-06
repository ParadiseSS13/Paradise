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

/obj/machinery/atmospherics/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"

/obj/machinery/atmospherics/air_sensor/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/multitool))
		update_multitool_menu(user)
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

/obj/machinery/atmospherics/air_sensor/process_atmos()
	if(on)
		if(!radio_connection)
			return

		// DIEEEEEEEE
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["timestamp"] = world.time

		var/datum/gas_mixture/air_sample = return_air()

		if(output & 1)
			signal.data["pressure"] = num2text(round(air_sample.return_pressure(),0.1),)
		if(output & 2)
			signal.data["temperature"] = round(air_sample.temperature,0.1)

		if(output > 4)
			var/total_moles = air_sample.total_moles()
			if(total_moles > 0)
				if(output & 4)
					signal.data["oxygen"] = round(100*air_sample.oxygen/total_moles,0.1)
				if(output & 8)
					signal.data["toxins"] = round(100*air_sample.toxins/total_moles,0.1)
				if(output & 16)
					signal.data["nitrogen"] = round(100*air_sample.nitrogen/total_moles,0.1)
				if(output & 32)
					signal.data["carbon_dioxide"] = round(100*air_sample.carbon_dioxide/total_moles,0.1)
			else
				signal.data["oxygen"] = 0
				signal.data["toxins"] = 0
				signal.data["nitrogen"] = 0
				signal.data["carbon_dioxide"] = 0
		signal.data["sigtype"]="status"
		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/air_sensor/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/air_sensor/Initialize(mapload)
	. = ..()
	set_frequency(frequency)

/obj/machinery/atmospherics/air_sensor/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)

	radio_connection = null
	return ..()


/obj/machinery/computer/general_air_control
	icon = 'icons/obj/computer.dmi'
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/air_management
	req_one_access_txt = "24;10"

	name = "Computer"

	frequency = ATMOS_VENTSCRUB
	var/show_sensors=1
	var/list/sensors = list()
	Mtoollink = TRUE

	var/list/sensor_information = list()

/obj/machinery/computer/general_air_control/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)

	radio_connection = null
	return ..()

/obj/machinery/computer/general_air_control/attack_hand(mob/user)
	if(..(user))
		return

	var/datum/browser/popup = new(user, "gac", name, 400, 400)
	popup.set_content(return_text())
	popup.open(FALSE)
	user.set_machine(src)
	onclose(user, "gac")

/obj/machinery/computer/general_air_control/process()
	..()

	if(!sensors)
		//warning("[src.type] at [x],[y],[z] has null sensors.  Please fix.")//commenting this line out because the admins will get a warning like this every time somebody builds another GAC
		sensors = list()

	updateUsrDialog()

/obj/machinery/computer/general_air_control/attackby(I as obj, user as mob, params)
	if(istype(I, /obj/item/multitool))
		update_multitool_menu(user)
		return TRUE

	return ..()


/obj/machinery/computer/general_air_control/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]
	if(!id_tag || !sensors || !sensors.Find(id_tag))
		return

	sensor_information[id_tag] = signal.data

/obj/machinery/computer/general_air_control/proc/return_text()
	var/sensor_data
	if(show_sensors)
		if(length(sensors))
			for(var/id_tag in sensors)
				var/long_name = sensors[id_tag]
				var/list/data = sensor_information[id_tag]
				var/sensor_part = "<fieldset><legend>[long_name]</legend>"

				if(data)
					sensor_part += "<table>"
					if(data["pressure"])
						sensor_part += "<tr><th>Pressure:</th><td>[data["pressure"]] kPa</td></tr>"

					if(data["temperature"])
						sensor_part += "<tr><th>Temperature:</th><td>[data["temperature"]] K</td></tr>"

					if(data["oxygen"]||data["toxins"]||data["nitrogen"]||data["carbon_dioxide"])
						sensor_part += "<tr><th>Gas Composition :</th><td><ul>"
						if(data["oxygen"])
							sensor_part += "<li>[data["oxygen"]]% O<sub>2</sub></li>"

						if(data["nitrogen"])
							sensor_part += "<li>[data["nitrogen"]]% N</li>"

						if(data["carbon_dioxide"])
							sensor_part += "<li>[data["carbon_dioxide"]]% CO<sub>2</sub></li>"

						if(data["toxins"])
							sensor_part += "<li>[data["toxins"]]% Plasma</li>"

						sensor_part += "</ul></td></tr>"
					sensor_part += "</table>"

				else
					sensor_part += "<FONT color='red'>[long_name] can not be found!</FONT><BR>"
				sensor_part += "</fieldset>"
				sensor_data += sensor_part

		else
			sensor_data = "<em>No sensors connected.</em>"

	var/output = {"
		<style type="text/css">
	html,body {
	font-family:sans-serif,verdana;
	font-size:smaller;
	color:#fff;
	}
	h1 {
	border-bottom:1px solid maroon;
	}
	table {
	border-spacing: 0;
	border-collapse: collapse;
	}
	td, th {
	margin: 0;
	font-size: small;
	border-bottom: 1px solid #ccc;
	padding: 3px;
	}

	th {
	text-align:right;
	}

	fieldset {
	border:1px solid #ccc;
	background: #333;
	}
	legend {
	font-weight:bold;
	}
		</style>
	[show_sensors ? "<h2>Sensor Data:</h2>" + sensor_data : ""]
	"}

	return output

/obj/machinery/computer/general_air_control/large_tank_control
	circuit = /obj/item/circuitboard/large_tank_control

	var/input_tag
	var/output_tag

	var/list/input_info
	var/list/output_info

	var/list/input_linkable=list(
		/obj/machinery/atmospherics/unary/outlet_injector,
		/obj/machinery/atmospherics/unary/vent_pump
	)

	var/list/output_linkable=list(
		/obj/machinery/atmospherics/unary/vent_pump
	)

	var/pressure_setting = ONE_ATMOSPHERE * 45

/obj/machinery/computer/general_air_control/large_tank_control/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/multitool))
		update_multitool_menu(user)
		return TRUE

	return ..()

#warn needs TGUIing
/obj/machinery/computer/general_air_control/large_tank_control/return_text()
	var/output = ..()
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

/obj/machinery/computer/general_air_control/large_tank_control/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]

	if(input_tag == id_tag)
		input_info = signal.data
		updateUsrDialog()

	else if(output_tag == id_tag)
		output_info = signal.data
		updateUsrDialog()

	else
		..(signal)

/obj/machinery/computer/general_air_control/large_tank_control/proc/request_device_refresh(device)
	send_signal(list("tag" = device, "status"))

/obj/machinery/computer/general_air_control/large_tank_control/proc/send_signal(list/data)
	if(!radio_connection)
		return

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data=data
	signal.data["sigtype"] = "command"
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/computer/general_air_control/large_tank_control/Topic(href, href_list)
	if(..())
		return TRUE

	add_fingerprint(usr)

	if(href_list["out_set_pressure"])
		var/response=input(usr,"Set new pressure, in kPa. \[0-[50*ONE_ATMOSPHERE]\]") as num
		pressure_setting = text2num(response)
		pressure_setting = clamp(pressure_setting, 0, 50*ONE_ATMOSPHERE)

	if(!radio_connection)
		return FALSE

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

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
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)
	updateUsrDialog()



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

/obj/machinery/computer/atmoscontrol/laptop
	name = "atmospherics laptop"
	desc = "Cheap Nanotrasen laptop."
	icon_state = "medlaptop"
	density = FALSE

/obj/machinery/computer/atmoscontrol/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/atmoscontrol/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	atmos_control.ui_interact(user, ui_key, ui, force_open)

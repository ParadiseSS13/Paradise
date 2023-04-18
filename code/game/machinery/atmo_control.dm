/obj/machinery/air_sensor
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF
	name = "gas sensor"

	anchored = 1
	var/state = 0
	var/bolts = 1

	var/id_tag
	frequency = ATMOS_TANKS_FREQ

	var/on = 1
	var/output = 3
	//Flags:
	// 1 for pressure
	// 2 for temperature
	// Output >= 4 includes gas composition
	// 4 for oxygen concentration
	// 8 for toxins concentration
	// 16 for nitrogen concentration
	// 32 for carbon dioxide concentration

/obj/machinery/air_sensor/update_icon()
	icon_state = "gsensor[on]"

/obj/machinery/air_sensor/proc/toggle_out_flag(bitflag_value)
	if(!(bitflag_value in list(1, 2, 4, 8, 16, 32)))
		return 0
	if(output & bitflag_value)
		output &= ~bitflag_value
	else
		output |= bitflag_value

/obj/machinery/air_sensor/proc/toggle_bolts()
	bolts = !bolts
	if(bolts)
		visible_message("You hear a quite click as the [src] bolts to the floor", "You hear a quite click")
	else
		visible_message("You hear a quite click as the [src]'s floor bolts raise", "You hear a quite click")

/obj/machinery/air_sensor/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu.interact(user, I)

/obj/machinery/air_sensor/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(bolts)
		to_chat(user, "[src] is bolted to the floor! You can't detach it like this.")
		return
	playsound(loc, I.usesound, 50, 1)
	to_chat(user, "<span class='notice'>You begin to unfasten [src]...</span>")
	if(do_after(user, 40 * I.toolspeed * gettoolspeedmod(user), target = src))
		user.visible_message("[user] unfastens [src].", "<span class='notice'>You have unfastened [src].</span>", "You hear ratchet.")
		new /obj/item/pipe_gsensor(loc)
		qdel(src)

/obj/machinery/air_sensor/process_atmos()
	if(on)
		if(!radio_connection)
			return
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time

		var/datum/gas_mixture/air_sample = return_air()

		if(output&1)
			signal.data["pressure"] = num2text(round(air_sample.return_pressure(),0.1),)
		if(output&2)
			signal.data["temperature"] = round(air_sample.temperature,0.1)

		if(output>4)
			var/total_moles = air_sample.total_moles()
			if(total_moles > 0)
				if(output&4)
					signal.data["oxygen"] = round(100*air_sample.oxygen/total_moles,0.1)
				if(output&8)
					signal.data["toxins"] = round(100*air_sample.toxins/total_moles,0.1)
				if(output&16)
					signal.data["nitrogen"] = round(100*air_sample.nitrogen/total_moles,0.1)
				if(output&32)
					signal.data["carbon_dioxide"] = round(100*air_sample.carbon_dioxide/total_moles,0.1)
			else
				signal.data["oxygen"] = 0
				signal.data["toxins"] = 0
				signal.data["nitrogen"] = 0
				signal.data["carbon_dioxide"] = 0
		signal.data["sigtype"]="status"
		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/air_sensor/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/air_sensor/Initialize()
	. = ..()
	SSair.atmos_machinery += src
	set_frequency(frequency)

/obj/machinery/air_sensor/Destroy()
	SSair.atmos_machinery -= src
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/air_sensor/init_multitool_menu()
	multitool_menu = new /datum/multitool_menu/idtag/freq/air_sensor(src)

/obj/machinery/computer/general_air_control
	icon = 'icons/obj/machines/computer.dmi'
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/air_management
	req_access = list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS)

	name = "Computer"

	frequency = ATMOS_TANKS_FREQ
	var/show_sensors=1
	var/list/sensors
	var/list/sensor_information

/obj/machinery/computer/general_air_control/Initialize()
	. = ..()
	if(!sensors)
		sensors = list()
	if(!sensor_information)
		sensor_information = list()
	set_frequency(frequency)

/obj/machinery/computer/general_air_control/init_multitool_menu()
	multitool_menu = new /datum/multitool_menu/idtag/freq/general_air_control(src)

/obj/machinery/computer/general_air_control/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/computer/general_air_control/attack_hand(mob/user)
	if(..(user))
		return
	var/html=return_text()
	var/datum/browser/popup = new(user, "gac", name, 400, 400)
	popup.set_content(html)
	popup.open(0)
	user.set_machine(src)
	onclose(user, "gac")

/obj/machinery/computer/general_air_control/process()
	..()
	if(!sensors)
		//warning("[src.type] at [x],[y],[z] has null sensors.  Please fix.")//commenting this line out because the admins will get a warning like this every time somebody builds another GAC
		sensors = list()
	src.updateUsrDialog()

/obj/machinery/computer/general_air_control/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu.interact(user, I)

/obj/machinery/computer/general_air_control/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]
	if(!id_tag || !sensors || !sensors.Find(id_tag)) return

	sensor_information[id_tag] = signal.data

/obj/machinery/computer/general_air_control/proc/return_text()
	var/sensor_data
	if(show_sensors)
		if(sensors.len)
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

	var/output = {"<meta charset="UTF-8">
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

/obj/machinery/computer/general_air_control/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/computer/general_air_control/large_tank_control
	circuit = /obj/item/circuitboard/large_tank_control
	req_access = list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS)

	var/input_tag
	var/output_tag

	var/list/input_info
	var/list/output_info

	var/list/input_linkable
	var/list/output_linkable

	var/pressure_setting = ONE_ATMOSPHERE * 45

/obj/machinery/computer/general_air_control/large_tank_control/Initialize()
	. = ..()
	input_linkable = list(
		/obj/machinery/atmospherics/unary/outlet_injector,
		/obj/machinery/atmospherics/unary/vent_pump,
	)
	output_linkable=list(
		/obj/machinery/atmospherics/unary/vent_pump,
	)

/obj/machinery/computer/general_air_control/large_tank_control/init_multitool_menu()
	multitool_menu = new /datum/multitool_menu/idtag/freq/general_air_control/large_tank_control(src)

/obj/machinery/computer/general_air_control/large_tank_control/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu.interact(user, I)

/obj/machinery/computer/general_air_control/large_tank_control/proc/can_link_to_input(obj/device_to_link)
	if(is_type_in_list(device_to_link, input_linkable))
		return TRUE
	return FALSE

/obj/machinery/computer/general_air_control/large_tank_control/proc/can_link_to_output(obj/device_to_link)
	if(is_type_in_list(device_to_link, output_linkable))
		return TRUE
	return FALSE

/obj/machinery/computer/general_air_control/large_tank_control/proc/link_input(obj/device_to_link)
	if(istype(device_to_link, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_pump/input_vent_pump = device_to_link
		input_tag = input_vent_pump.id_tag
		send_signal(list(
			"tag" = input_tag,
			"direction" = 1, // Release
			"checks"    = 0,  // No pressure checks.
		))
	else if(istype(device_to_link, /obj/machinery/atmospherics/unary/outlet_injector))
		var/obj/machinery/atmospherics/unary/vent_pump/input_outlet_injector = device_to_link
		input_tag = input_outlet_injector.id_tag
	else
		return FALSE
	input_info = null
	return TRUE

/obj/machinery/computer/general_air_control/large_tank_control/proc/link_output(obj/device_to_link)
	if(istype(device_to_link, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_pump/output_vent_pump = device_to_link
		output_tag = output_vent_pump.id_tag
		send_signal(list(
			"tag" = output_tag,
			"direction" = 0, // Siphon
			"checks"    = 2  // Internal pressure checks.
		))
	else
		return FALSE
	output_info = null
	return TRUE

/obj/machinery/computer/general_air_control/large_tank_control/proc/unlink_input()
	input_tag = null
	input_info = null

/obj/machinery/computer/general_air_control/large_tank_control/proc/unlink_output()
	output_tag = null
	output_info = null

/obj/machinery/computer/general_air_control/large_tank_control/process()
	..()
	if(!input_info && input_tag)
		request_device_refresh(input_tag)
	if(!output_info && output_tag)
		request_device_refresh(output_tag)

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
	send_signal(list("tag"=device, "status"))

/obj/machinery/computer/general_air_control/large_tank_control/proc/send_signal(list/data)
	if(!radio_connection)
		return
	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data=data
	signal.data["sigtype"]="command"
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/computer/general_air_control/large_tank_control/Topic(href, href_list)
	if(..())
		return 1

	add_fingerprint(usr)

	if(href_list["out_set_pressure"])
		var/response=input(usr,"Set new pressure, in kPa. \[0-[50*ONE_ATMOSPHERE]\]") as num
		pressure_setting = text2num(response)
		pressure_setting = between(0, pressure_setting, 50*ONE_ATMOSPHERE)

	if(!radio_connection)
		return 0
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
	src.updateUsrDialog()

/obj/machinery/computer/general_air_control/fuel_injection
	icon = 'icons/obj/machines/computer.dmi'
	icon_screen = "atmos"
	circuit = /obj/item/circuitboard/injector_control

	var/device_tag
	var/list/device_info

	var/automation = 0

	var/cutoff_temperature = 2000
	var/on_temperature = 1200

/obj/machinery/computer/general_air_control/fuel_injection/process()
	if(automation)
		if(!radio_connection)
			return 0

		var/injecting = 0
		for(var/id_tag in sensor_information)
			var/list/data = sensor_information[id_tag]
			if(data["temperature"])
				if(data["temperature"] >= cutoff_temperature)
					injecting = 0
					break
				if(data["temperature"] <= on_temperature)
					injecting = 1

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src

		signal.data = list(
			"tag" = device_tag,
			"power" = injecting,
			"sigtype"="command"
		)

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	..()

/obj/machinery/computer/general_air_control/fuel_injection/return_text()
	var/output = ..()
	output += "<fieldset><legend>Fuel Injection System (<A href='?src=[UID()];refresh_status=1'>Refresh</A>)</legend>"
	if(device_info)
		var/power = device_info["power"]
		var/volume_rate = device_info["volume_rate"]
		output += {"<table>
		<tr>
			<th>Status:</th>
			<td>[power?"Injecting":"On Hold"]</td>
		</tr>
		<tr>
			<th>Rate:</th>
			<td>[volume_rate] L/sec</td>
		</tr>
		<tr>
			<th>Automated Fuel Injection:</th>
			<td><A href='?src=[UID()];toggle_automation=1'>[automation?"Engaged":"Disengaged"]</A></td>
		</tr>"}

		if(automation)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\atmo_control.dm:372: output += "Automated Fuel Injection: <A href='?src=[UID()];toggle_automation=1'>Engaged</A><BR>"
			output += {"
			<tr>
				<td colspan="2">Injector Controls Locked Out</td>
			</tr>"}
			// END AUTOFIX
		else

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\atmo_control.dm:375: output += "Automated Fuel Injection: <A href='?src=[UID()];toggle_automation=1'>Disengaged</A><BR>"
			output += {"
			<tr>
				<th>Injector:</th>
				<td><A href='?src=[UID()];toggle_injector=1'>Toggle Power</A> <A href='?src=[UID()];injection=1'>Inject (1 Cycle)</A></td>
			</td>"}
			// END AUTOFIX
		output += "</table>"
	else
		output += {"<p style="color:red"><b>ERROR:</b> Can not find device. <A href='?src=[UID()];refresh_status=1'>Search</A></p>"}
	output += "</fieldset>"

	return output

/obj/machinery/computer/general_air_control/fuel_injection/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]

	if(device_tag == id_tag)
		device_info = signal.data
	else
		..(signal)

/obj/machinery/computer/general_air_control/fuel_injection/Topic(href, href_list)
	if(..())
		return

	if(href_list["refresh_status"])
		device_info = null
		if(!radio_connection)
			return 0

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data = list(
			"tag" = device_tag,
			"status",
			"sigtype"="command"
		)
		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	if(href_list["toggle_automation"])
		automation = !automation

	if(href_list["toggle_injector"])
		device_info = null
		if(!radio_connection)
			return 0

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data = list(
			"tag" = device_tag,
			"power_toggle",
			"sigtype"="command"
		)

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	if(href_list["injection"])
		if(!radio_connection)
			return 0

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data = list(
			"tag" = device_tag,
			"inject",
			"sigtype"="command"
		)

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/air_sensor
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF
	name = "gas sensor"
	req_one_access_txt = "24;10"

	anchored = 1
	var/state = 0
	var/bolts = 1

	var/id_tag
	var/frequency = ATMOS_VENTSCRUB
	Mtoollink = 1
	settagwhitelist = list("id_tag")

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

	var/datum/radio_frequency/radio_connection

/obj/machinery/air_sensor/update_icon()
	icon_state = "gsensor[on]"

/obj/machinery/air_sensor/multitool_menu(var/mob/user, var/obj/item/multitool/P)
	return {"
	<b>Main</b>
	<ul>
		<li><b>Frequency:</b> <a href="?src=[UID()];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=[UID()];set_freq=[initial(frequency)]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag")]</li>
		<li>Floor Bolts: <a href="?src=[UID()];toggle_bolts=1">[bolts ? "Enabled" : "Disabled"]</a>
		<li>Monitor Pressure: <a href="?src=[UID()];toggle_out_flag=1">[output&1 ? "Yes" : "No"]</a>
		<li>Monitor Temperature: <a href="?src=[UID()];toggle_out_flag=2">[output&2 ? "Yes" : "No"]</a>
		<li>Monitor Oxygen Concentration: <a href="?src=[UID()];toggle_out_flag=4">[output&4 ? "Yes" : "No"]</a>
		<li>Monitor Plasma Concentration: <a href="?src=[UID()];toggle_out_flag=8">[output&8 ? "Yes" : "No"]</a>
		<li>Monitor Nitrogen Concentration: <a href="?src=[UID()];toggle_out_flag=16">[output&16 ? "Yes" : "No"]</a>
		<li>Monitor Carbon Dioxide Concentration: <a href="?src=[UID()];toggle_out_flag=32">[output&32 ? "Yes" : "No"]</a>
	</ul>"}

/obj/machinery/air_sensor/multitool_topic(var/mob/user, var/list/href_list, var/obj/O)
	. = ..()
	if(.)
		return .

	if("toggle_out_flag" in href_list)
		var/bitflag_value = text2num(href_list["toggle_out_flag"])//this is a string normally
		if(!(bitflag_value in list(1, 2, 4, 8, 16, 32))) //Here to prevent breaking the sensors with HREF exploits
			return 0
		if(output&bitflag_value)//the bitflag is on ATM
			output &= ~bitflag_value
		else//can't not be off
			output |= bitflag_value
		return TRUE
	if("toggle_bolts" in href_list)
		bolts = !bolts
		if(bolts)
			visible_message("You hear a quite click as the [src] bolts to the floor", "You hear a quite click")
		else
			visible_message("You hear a quite click as the [src]'s floor bolts raise", "You hear a quite click")
		return TRUE

/obj/machinery/air_sensor/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/multitool))
		update_multitool_menu(user)
		return 1
	if(istype(W, /obj/item/wrench))
		if(bolts)
			to_chat(usr, "The [src] is bolted to the floor! You can't detach it like this.")
			return 1
		playsound(loc, W.usesound, 50, 1)
		to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
		if(do_after(user, 40 * W.toolspeed, target = src))
			user.visible_message("[user] unfastens \the [src].", "<span class='notice'>You have unfastened \the [src].</span>", "You hear ratchet.")
			new /obj/item/pipe_gsensor(src.loc)
			qdel(src)
			return 1
		return
	return ..()

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


/obj/machinery/air_sensor/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/air_sensor/Initialize()
	..()
	SSair.atmos_machinery += src
	set_frequency(frequency)

/obj/machinery/air_sensor/Destroy()
	SSair.atmos_machinery -= src
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

	var/frequency = ATMOS_VENTSCRUB
	var/show_sensors=1
	var/list/sensors = list()
	Mtoollink = 1

	var/list/sensor_information = list()
	var/datum/radio_frequency/radio_connection

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

/obj/machinery/computer/general_air_control/attackby(I as obj, user as mob, params)
	if(istype(I, /obj/item/multitool))
		update_multitool_menu(user)
		return 1
	return ..()


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

/obj/machinery/computer/general_air_control/proc/set_frequency(new_frequency)
		SSradio.remove_object(src, frequency)
		frequency = new_frequency
		radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/computer/general_air_control/Initialize()
	..()
	set_frequency(frequency)

/obj/machinery/computer/general_air_control/multitool_menu(mob/user, obj/item/multitool/P)
	var/dat= {"
	<b>Main</b>
	<ul>
	<li><b>Frequency:</b> <a href="?src=[UID()];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=[UID()];set_freq=[initial(frequency)]">Reset</a>)</li>
	</ul>
	<b>Sensors:</b>
	<ul>"}
	for(var/id_tag in sensors)
		dat += {"<li><a href="?src=[UID()];edit_sensor=[id_tag]">[sensors[id_tag]]</a></li>"}
	dat += {"<li><a href="?src=[UID()];add_sensor=1">\[+\]</a></li></ul>"}
	return dat

/obj/machinery/computer/general_air_control/multitool_topic(mob/user,list/href_list,obj/O)
	. = ..()
	if(.) return .
	if("add_sensor" in href_list)

		// Make a list of all available sensors on the same frequency
		var/list/sensor_list = list()
		for(var/obj/machinery/air_sensor/G in GLOB.machines)
			if(!isnull(G.id_tag) && G.frequency == frequency)
				sensor_list|=G.id_tag
		if(!sensor_list.len)
			to_chat(user, "<span class=\"warning\">No sensors on this frequency.</span>")
			return FALSE

		// Have the user pick one of them and name its label
		var/sensor = input(user, "Select a sensor:", "Sensor Data") as null|anything in sensor_list
		if(!sensor)
			return FALSE
		var/label = reject_bad_name( input(user, "Choose a sensor label:", "Sensor Label")  as text|null, allow_numbers=1)
		if(!label)
			return FALSE

		// Add the sensor's information to general_air_controler
		sensors[sensor] = label
		return TRUE

	if("edit_sensor" in href_list)
		var/list/sensor_list = list()
		for(var/obj/machinery/air_sensor/G in GLOB.machines)
			if(!isnull(G.id_tag) && G.frequency == frequency)
				sensor_list|=G.id_tag
		if(!sensor_list.len)
			to_chat(user, "<span class=\"warning\">No sensors on this frequency.</span>")
			return FALSE
		var/label = sensors[href_list["edit_sensor"]]
		var/sensor = input(user, "Select a sensor:", "Sensor Data", href_list["edit_sensor"]) as null|anything in sensor_list
		if(!sensor)
			return FALSE
		sensors.Remove(href_list["edit_sensor"])
		sensors[sensor] = label
		return TRUE

/obj/machinery/computer/general_air_control/unlinkFrom(mob/user, obj/O)
	..()
	if("id_tag" in O.vars && (istype(O,/obj/machinery/air_sensor) || istype(O, /obj/machinery/meter)))
		sensors.Remove(O:id_tag)
		return 1
	return 0

/obj/machinery/computer/general_air_control/linkMenu(obj/O)
	if(isLinkedWith(O))
		return

	var/dat=""

	if(istype(O,/obj/machinery/air_sensor) || istype(O, /obj/machinery/meter))
		dat += " <a href='?src=[UID()];link=1'>\[New Sensor\]</a> "
	return dat

/obj/machinery/computer/general_air_control/canLink(obj/O, list/context)
	if(istype(O,/obj/machinery/air_sensor) || istype(O, /obj/machinery/meter))
		return O:id_tag

/obj/machinery/computer/general_air_control/isLinkedWith(obj/O)
	if(istype(O,/obj/machinery/air_sensor) || istype(O, /obj/machinery/meter))
		return O:id_tag in sensors

/obj/machinery/computer/general_air_control/linkWith(mob/user, obj/O, link/context)
	sensors[O:id_tag] = reject_bad_name(clean_input(user, "Choose a sensor label:", "Sensor Label"), allow_numbers=1)
	return 1

/obj/machinery/computer/general_air_control/large_tank_control
	circuit = /obj/item/circuitboard/large_tank_control
	req_one_access_txt = "24;10"
	settagwhitelist = list("input_tag", "output_tag")

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
		return 1
	return ..()


/obj/machinery/computer/general_air_control/large_tank_control/multitool_menu(mob/user, obj/item/multitool/P)
	var/dat= {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=[UID()];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=[UID()];set_freq=[initial(frequency)]">Reset</a>)</li>
		<li>[format_tag("Input","input_tag")]</li>
		<li>[format_tag("Output","output_tag")]</li>
	</ul>
	<b>Sensors:</b>
	<ul>"}
	for(var/id_tag in sensors)
		dat += {"<li><a href="?src=[UID()];edit_sensor=[id_tag]">[sensors[id_tag]]</a></li>"}
	dat += {"<li><a href="?src=[UID()];add_sensor=1">\[+\]</a></li></ul>"}
	return dat


/obj/machinery/computer/general_air_control/large_tank_control/linkWith(mob/user, obj/O, list/context)
	if(context["slot"]=="input" && is_type_in_list(O,input_linkable))
		input_info = null
		if(istype(O,/obj/machinery/atmospherics/unary/vent_pump))
			send_signal(list("tag"=input_tag,
				"direction"=1, // Release
				"checks"   =0  // No pressure checks.
				))
		return 1
	if(context["slot"]=="output" && is_type_in_list(O,output_linkable))
		output_tag = O:id_tag
		output_info = null
		if(istype(O,/obj/machinery/atmospherics/unary/vent_pump))
			send_signal(list("tag"=output_tag,
				"direction"=0, // Siphon
				"checks"   =2  // Internal pressure checks.
				))
		return 1

/obj/machinery/computer/general_air_control/large_tank_control/unlinkFrom(mob/user, obj/O)
	if("id_tag" in O.vars)
		if(O:id_tag == input_tag)
			input_tag=null
			input_info=null
			return 1
		if(O:id_tag == output_tag)
			output_tag=null
			output_info=null
			return 1
	return 0

/obj/machinery/computer/general_air_control/large_tank_control/linkMenu(obj/O)
	var/dat=""
	if(canLink(O,list("slot"="input")))
		dat += " <a href='?src=[UID()];link=1;slot=input'>\[Link @ Input\]</a> "
	if(canLink(O,list("slot"="output")))
		dat += " <a href='?src=[UID()];link=1;slot=output'>\[Link @ Output\]</a> "
	return dat

/obj/machinery/computer/general_air_control/large_tank_control/canLink(obj/O, list/context)
	return (context["slot"]=="input" && is_type_in_list(O,input_linkable)) || (context["slot"]=="output" && is_type_in_list(O,output_linkable))

/obj/machinery/computer/general_air_control/large_tank_control/isLinkedWith(obj/O)
	if(O:id_tag == input_tag)
		return 1
	if(O:id_tag == output_tag)
		return 1
	return 0

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
	icon = 'icons/obj/computer.dmi'
	icon_screen = "atmos"
	circuit = /obj/item/circuitboard/injector_control

	var/device_tag
	var/list/device_info

	var/automation = 0

	var/cutoff_temperature = 2000
	var/on_temperature = 1200

/obj/machinery/computer/general_air_control/fuel_injection/attackby(I as obj, user as mob, params)
	if(istype(I, /obj/item/multitool))
		update_multitool_menu(user)
		return 1
	return ..()

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

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
	var/list/sensors = list()

/obj/machinery/computer/general_air_control/attack_hand(mob/user)
	if(..(user))
		return
	#warn aa todo - tgui

	var/datum/browser/popup = new(user, "gac", name, 400, 400)
	popup.open(FALSE)
	user.set_machine(src)

/obj/machinery/computer/general_air_control/large_tank_control
	circuit = /obj/item/circuitboard/large_tank_control

	var/input_tag
	var/output_tag

	var/list/input_info
	var/list/output_info

	var/list/input_linkable = list(
		/obj/machinery/atmospherics/unary/outlet_injector,
		/obj/machinery/atmospherics/unary/vent_pump
	)

	var/list/output_linkable = list(
		/obj/machinery/atmospherics/unary/vent_pump
	)

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

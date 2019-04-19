/obj/machinery/computer/general_air_control/atmos_automation
	icon = 'icons/obj/computer.dmi'
	icon_screen = "area_atmos"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/atmos_automation
	req_one_access_txt = "24;10"
	Mtoollink = 1

	show_sensors = 0
	var/on = 0

	name = "Atmospherics Automations Console"

	var/list/datum/automation/automations = list()

/obj/machinery/computer/general_air_control/atmos_automation/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]
	if(!id_tag)
		return

	sensor_information[id_tag] = signal.data

/obj/machinery/computer/general_air_control/atmos_automation/process()
	if(on)
		for(var/datum/automation/A in automations)
			A.process()

/obj/machinery/computer/general_air_control/atmos_automation/update_icon()
	icon_state = initial(icon_state)
	// Broken
	if(stat & BROKEN)
		icon_state += "b"

	// Powered
	else if(stat & NOPOWER)
		icon_state = initial(icon_state)
		icon_state += "0"
	else if(on)
		icon_state += "_active"

/obj/machinery/computer/general_air_control/atmos_automation/proc/request_device_refresh(device)
	send_signal(list("tag"=device, "status"))

/obj/machinery/computer/general_air_control/atmos_automation/proc/send_signal(list/data, filter = RADIO_ATMOSIA)//filter's here so the AAC can cross communicate to things like vents, which have a different filter
	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data=data
	signal.data["sigtype"]="command"
	signal.data["advcontrol"]=1//AAC balancing, you need to manually get up to the machine to make it listen to this
	radio_connection.post_signal(src, signal, range = 8, filter = filter)

/obj/machinery/computer/general_air_control/atmos_automation/proc/selectValidChildFor(datum/automation/parent, mob/user, list/valid_returntypes)
	var/list/choices=list()
	for(var/childtype in automation_types)
		var/datum/automation/A = new childtype(src)
		if(A.returntype == null)
			continue
		if(!(A.returntype in valid_returntypes))
			continue
		choices[A.name]=A
	if(choices.len==0)
		testing("Unable to find automations with returntype in [english_list(valid_returntypes)]!")
		return 0
	var/label=input(user, "Select new automation:", "Automations", "Cancel") as null|anything in choices
	if(!label)
		return 0
	return choices[label]

/obj/machinery/computer/general_air_control/atmos_automation/return_text()
	var/out=..()

	if(on)
		out += "<a href=\"?src=[UID()];on=1\" style=\"font-size:large;font-weight:bold;color:red;\">RUNNING</a>"
	else
		out += "<a href=\"?src=[UID()];on=1\" style=\"font-size:large;font-weight:bold;color:green;\">STOPPED</a>"

	out += {"
		<h2>Automations</h2>
		<p>\[
		<a href="?src=[UID()];add=1">
			Add
		</a>
		|
		<a href="?src=[UID()];reset=*">
			Reset All
		</a>
		|
		<a href="?src=[UID()];remove=*">
			Clear
		</a>
		\]</p>
		<p>\[
		<a href="?src=[UID()];dump=1">
			Export
		</a>
		|
		<a href="?src=[UID()];read=1">
			Import
		</a>
		\]</p>"}
	if(automations.len==0)
		out += "<i>No automations present.</i>"
	else
		for(var/datum/automation/A in automations)
			out += {"
				<fieldset>
					<legend>
						<a href="?src=[UID()];label=\ref[A]">[A.label]</a>
						(<a href="?src=[UID()];reset=\ref[A]">Reset</a> |
						<a href="?src=[UID()];remove=\ref[A]">&times;</a>)
					</legend>
					[A.GetText()]
				</fieldset>
			"}
	return out

/obj/machinery/computer/general_air_control/atmos_automation/Topic(href,href_list)
	if(..())
		return 1

	if(href_list["on"])
		on = !on
		updateUsrDialog()
		update_icon()
		return 1

	if(href_list["add"])
		var/new_child=selectValidChildFor(null,usr,list(0))
		if(!new_child)
			return 1
		automations += new_child
		updateUsrDialog()
		return 1

	if(href_list["label"])
		var/datum/automation/A=locate(href_list["label"])
		if(!A) return 1
		var/nl=input(usr, "Please enter a label for this automation task.") as text|null
		if(!nl) return 1
		nl	= copytext(sanitize(nl), 1, 50)
		A.label=nl
		updateUsrDialog()
		return 1

	if(href_list["reset"])
		if(href_list["reset"]=="*")
			for(var/datum/automation/A in automations)
				if(!A) continue
				A.OnReset()
		else
			var/datum/automation/A=locate(href_list["reset"])
			if(!A) return 1
			A.OnReset()
		updateUsrDialog()
		return 1

	if(href_list["remove"])
		if(href_list["remove"]=="*")
			var/confirm=alert("Are you sure you want to remove ALL automations?","Automations","Yes","No")
			if(confirm == "No") return 0
			for(var/datum/automation/A in automations)
				if(!A) continue
				A.OnRemove()
				automations.Remove(A)
		else
			var/datum/automation/A=locate(href_list["remove"])
			if(!A) return 1
			A.OnRemove()
			automations.Remove(A)
		updateUsrDialog()
		return 1

	if(href_list["read"])
		var/code = input("Input exported AAC code.","Automations","") as message|null
		if(!code) return 0
		ReadCode(code)
		updateUsrDialog()
		return 1

	if(href_list["dump"])
		input("Exported AAC code:","Automations",DumpCode()) as message|null
		return 0

/obj/machinery/computer/general_air_control/atmos_automation/proc/MakeCompare(datum/automation/a, datum/automation/b, comparetype)
	var/datum/automation/compare/compare=new(src)
	compare.comparator = comparetype
	compare.children[1] = a
	compare.children[2] = b
	return compare

/obj/machinery/computer/general_air_control/atmos_automation/proc/MakeNumber(value)
	var/datum/automation/static_value/val = new(src)
	val.value=value
	return val

/obj/machinery/computer/general_air_control/atmos_automation/proc/MakeGetSensorData(sns_tag,field)
	var/datum/automation/get_sensor_data/sensor=new(src)
	sensor.sensor=sns_tag
	sensor.field=field
	return sensor

/obj/machinery/computer/general_air_control/atmos_automation/proc/DumpCode()
	var/list/json[0]
	for(var/datum/automation/A in automations)
		json += list(A.Export())
	return json_encode(json)

/obj/machinery/computer/general_air_control/atmos_automation/proc/ReadCode(jsonStr)
	automations.Cut()
	var/list/json = json_decode(jsonStr)
	if(json.len>0)
		for(var/list/cData in json)
			if(isnull(cData) || !("type" in cData))
				testing("AAC: Null cData in root JS array.")
				continue
			var/Atype=text2path(cData["type"])
			if(!(Atype in automation_types))
				testing("AAC: Unrecognized Atype [Atype].")
				continue
			var/datum/automation/A = new Atype(src)
			A.Import(cData)
			automations += A

/obj/machinery/computer/general_air_control/atmos_automation/burnchamber
	var/injector_tag="inc_in"
	var/output_tag="inc_out"
	var/sensor_tag="inc_sensor"
	frequency=AIRLOCK_FREQ
	var/temperature=1000

/obj/machinery/computer/general_air_control/atmos_automation/burnchamber/New()
	..()

	// On State
	// Pretty much this:
	/*
		if(get_sensor("inc_sensor","temperature") < 200)
			set_injector_state("inc_in",1)
			set_vent_pump_power("inc_out",0)
		else
			set_vent_pump_power("inc_out",1
	*/

	var/datum/automation/get_sensor_data/sensor=new(src)
	sensor.sensor=sensor_tag
	sensor.field="temperature"

	var/datum/automation/static_value/val = new(src)
	val.value=temperature - 800

	var/datum/automation/compare/compare=new(src)
	compare.comparator = "Less Than"
	compare.children[1] = sensor
	compare.children[2] = val

	var/datum/automation/set_injector_power/inj_on=new(src)
	inj_on.injector=injector_tag
	inj_on.state=1

	var/datum/automation/set_vent_pump_power/vp_on=new(src)
	vp_on.vent_pump=output_tag
	vp_on.state=1

	var/datum/automation/set_vent_pump_power/vp_off=new(src)
	vp_off.vent_pump=output_tag
	vp_off.state=0

	var/datum/automation/if_statement/i = new (src)
	i.label = "Fuel Injector On"
	i.condition = compare
	i.children_then.Add(inj_on)
	i.children_then.Add(vp_off)
	i.children_else.Add(vp_on)

	automations += i

	// Off state
	/*
		if(get_sensor("inc_sensor","temperature") > 1000)
			set_injector_state("inc_in",0)
	*/
	sensor=new(src)
	sensor.sensor=sensor_tag
	sensor.field="temperature"

	val = new(src)
	val.value=temperature

	compare=new(src)
	compare.comparator = "Greater Than"
	compare.children[1] = sensor
	compare.children[2] = val

	var/datum/automation/set_injector_power/inj_off=new(src)
	inj_off.injector=injector_tag
	inj_off.state=0

	i = new (src)
	i.label = "Fuel Injector Off"
	i.condition = compare
	i.children_then.Add(inj_off)

	automations += i

/obj/machinery/computer/general_air_control/atmos_automation/air_mixing
	var/n2_injector_tag="air_n2_in"
	var/o2_injector_tag="air_o2_in"
	var/output_tag="air_out"
	var/sensor_tag="air_sensor"
	frequency=ATMOS_DISTRO_FREQ
	var/temperature=1000

/obj/machinery/computer/general_air_control/atmos_automation/air_mixing/New()
	..()
	buildO2()
	buildN2()
	buildOutletVent()

/obj/machinery/computer/general_air_control/atmos_automation/air_mixing/proc/buildO2()
	///////////////////////////////////////////////////////////////
	// Oxygen Injection
	///////////////////////////////////////////////////////////////

	var/datum/automation/set_injector_power/inj_on=new(src)
	inj_on.injector=o2_injector_tag
	inj_on.state=1

	var/datum/automation/set_injector_power/inj_off=new(src)
	inj_off.injector=o2_injector_tag
	inj_off.state=0

	var/datum/automation/if_statement/i = new (src)
	i.label = "Oxygen Injection"
	i.condition = MakeCompare(
		MakeGetSensorData(sensor_tag,"oxygen"),
		MakeNumber(20),
		"Less Than or Equal to"
	)
	i.children_then.Add(inj_on)
	i.children_else.Add(inj_off)

	automations += i

/obj/machinery/computer/general_air_control/atmos_automation/air_mixing/proc/buildN2()
	///////////////////////////////////////////////////////////////
	// Nitrogen Injection
	///////////////////////////////////////////////////////////////
	/*
	if(get_sensor_data("pressure") < 100)
		injector_on()
	else
		if(get_sensor_data("pressure") > 5000)
			injector_off()
	*/

	var/datum/automation/set_injector_power/inj_on=new(src)
	inj_on.injector=n2_injector_tag
	inj_on.state=1

	var/datum/automation/set_injector_power/inj_off=new(src)
	inj_off.injector=n2_injector_tag
	inj_off.state=0

	var/datum/automation/if_statement/if_on = new (src)
	if_on.label = "Nitrogen Injection"
	if_on.condition = MakeCompare(
		MakeGetSensorData(sensor_tag,"pressure"),
		MakeNumber(100),
		"Less Than"
	)
	if_on.children_then.Add(inj_on)


	var/datum/automation/if_statement/if_off=new(src)
	if_off.condition=MakeCompare(
		MakeGetSensorData(sensor_tag,"pressure"),
		MakeNumber(5000),
		"Greater Than"
	)
	if_off.children_then.Add(inj_off)

	if_on.children_else.Add(if_off)

	automations += if_on

/obj/machinery/computer/general_air_control/atmos_automation/air_mixing/proc/buildOutletVent()
	///////////////////////////////////////////////////////////////
	// Outlet Management
	///////////////////////////////////////////////////////////////
	/*
		if(get_sensor_data("pressure") >= 5000 && get_sensor_data("oxygen") >= 20)
			vent_on()
		else
			if(get_sensor_data("oxygen") < 20 || get_sensor_data("pressure") < 100)
				vent_off()
	*/

	var/datum/automation/set_vent_pump_power/vp_on=new(src)
	vp_on.vent_pump=output_tag
	vp_on.state=1

	var/datum/automation/set_vent_pump_power/vp_off=new(src)
	vp_off.vent_pump=output_tag
	vp_off.state=0

	var/datum/automation/if_statement/if_on=new(src)
	if_on.label="Air Output"

	var/datum/automation/and/and_on=new(src)
	and_on.children.Add(
		MakeCompare(
			MakeGetSensorData(sensor_tag,"pressure"),
			MakeNumber(5000),
			"Greater Than or Equal to"
		)
	)
	and_on.children.Add(
		MakeCompare(
			MakeGetSensorData(sensor_tag,"oxygen"),
			MakeNumber(20),
			"Greater Than or Equal to"
		)
	)
	if_on.condition=and_on
	if_on.children_then.Add(vp_on)

	//////////////////////////////

	var/datum/automation/if_statement/if_off=new(src)

	var/datum/automation/or/or_off=new(src)
	or_off.children.Add(
		MakeCompare(
			MakeGetSensorData(sensor_tag,"pressure"),
			MakeNumber(100),
			"Less Than"
		)
	)
	or_off.children.Add(
		MakeCompare(
			MakeGetSensorData(sensor_tag,"oxygen"),
			MakeNumber(20),
			"Less Than"
		)
	)
	if_off.condition=or_off
	if_off.children_then.Add(vp_off)

	if_on.children_else.Add(if_off)

	automations += if_on

/datum/automation/set_vent_pump_mode
	name="Vent Pump: Mode"

	var/vent_pump = null
	var/mode = "stabilize"
	var/vent_type = 0//0 for unary vents, 1 for DP vents

	var/list/modes = list("stabilize","purge")

	Export()
		var/list/json = ..()
		json["vent_pump"] = vent_pump
		json["mode"] = mode
		json["vent_type"] = vent_type
		return json

	Import(var/list/json)
		..(json)
		vent_pump = json["vent_pump"]
		mode = json["mode"]
		vent_type = text2num(json["vent_type"])

	process()
		if(vent_pump)
			var/dirvalue = (mode == "stabilize" ? 1 : mode == "purge" ? 0 : 1)
			parent.send_signal(list("tag" = vent_pump, "direction" = dirvalue), filter = (vent_type ? RADIO_ATMOSIA : RADIO_FROM_AIRALARM))
		return 0

	GetText()
		return "Set <a href=\"?src=\ref[src];toggle_type=1\">[vent_type ? "Dual-Port" : "Unary"]</a> vent pump <a href=\"?src=\ref[src];set_vent_pump=1\">[fmtString(vent_pump)]</a> mode to <a href=\"?src=\ref[src];set_mode=1\">[mode]</a>."

	Topic(href,href_list)
		if(..())
			return 1

		if(href_list["set_mode"])
			mode = input("Select a mode to put this pump into.",mode) in modes
			parent.updateUsrDialog()
			return 1

		if(href_list["set_vent_pump"])
			var/list/injector_names = list()
			if(!vent_type)
				for(var/obj/machinery/atmospherics/unary/vent_pump/I in machines)
					if(!isnull(I.id_tag) && I.frequency == parent.frequency)
						injector_names |= I.id_tag
			else
				for(var/obj/machinery/atmospherics/binary/dp_vent_pump/I in world)
					//world << "test"
					if(!isnull(I.id_tag) && I.frequency == parent.frequency)
						injector_names |= I.id_tag

			vent_pump = input("Select a vent:", "Vent Pumps", vent_pump) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1

		if(href_list["toggle_type"])
			vent_type = !vent_type
			parent.updateUsrDialog()
			return 1

/datum/automation/set_vent_pump_power
	name="Vent Pump: Power"

	var/vent_pump = null
	var/state = 0
	var/mode = 0//0 for unary vents, 1 for DP vents.

	Export()
		var/list/json = ..()
		json["vent_pump"] = vent_pump
		json["state"] = state
		json["mode"] = mode
		return json

	Import(var/list/json)
		..(json)
		vent_pump = json["vent_pump"]
		state = text2num(json["state"])
		mode = text2num(json["mode"])

	process()
		if(vent_pump)
			parent.send_signal(list ("tag" = vent_pump, "power" = state), filter = (mode ? RADIO_ATMOSIA : RADIO_FROM_AIRALARM))

	GetText()
		return "Set <a href=\"?src=\ref[src];toggle_mode=1\">[mode ? "Dual-Port" : "Unary"]</a> vent pump <a href=\"?src=\ref[src];set_vent_pump=1\">[fmtString(vent_pump)]</a> power to <a href=\"?src=\ref[src];set_power=1\">[state ? "on" : "off"]</a>."

	Topic(href,href_list)
		if(..())
			return 1

		if(href_list["set_power"])
			state = !state
			parent.updateUsrDialog()
			return 1

		if(href_list["set_vent_pump"])
			var/list/injector_names=list()
			if(!mode)
				for(var/obj/machinery/atmospherics/unary/vent_pump/I in machines)
					if(!isnull(I.id_tag) && I.frequency == parent.frequency)
						injector_names|=I.id_tag
			else
				for(var/obj/machinery/atmospherics/binary/dp_vent_pump/I in world)
					if(!isnull(I.id_tag) && I.frequency == parent.frequency)
						injector_names|=I.id_tag
			vent_pump = input("Select a vent:", "Vent Pumps", vent_pump) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1

		if(href_list["toggle_mode"])
			mode = !mode
			parent.updateUsrDialog()
			return 1

/datum/automation/set_vent_pump_pressure//controls the internal/external pressure bounds of a vent pump.
	name = "Vent Pump: Pressure Settings"

	var/vent_pump = null
	var/intpressureout = 0//these 2 are for DP vents, if it's a unary vent you're sending to it will take intpressureout as var
	var/intpressurein = 0
	var/extpressure = 0
	var/mode = 0//0 for unary vents, 1 for DP vents.

	Export()
		var/list/json = ..()
		json["vent_pump"] = vent_pump
		json["intpressureout"] = intpressureout
		json["intpressurein"] = intpressurein
		json["extpressure"] = extpressure
		json["mode"] = mode
		return json

	Import(var/list/json)
		..(json)
		vent_pump = json["vent_pump"]
		intpressureout = text2num(json["intpressureout"])
		intpressurein = text2num(json["intpressurein"])
		extpressure = text2num(json["extpressure"])
		mode = text2num(json["mode"])

	New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
		..(aa)

	process()
		if(vent_pump)
			var/list/data = list( \
				"tag" = vent_pump, \
			)
			var/filter = RADIO_ATMOSIA
			if(mode)//it's a DP vent
				if(intpressurein)
					data.Add(list("set_input_pressure" = intpressurein))
				if(intpressureout)
					data.Add(list("set_output_pressure" = intpressureout))
				if(extpressure)
					data.Add(list("set_external_pressure" = extpressure))

			else
				if(intpressureout)
					data.Add(list("set_internal_pressure" = intpressureout))
				if(extpressure)
					data.Add(list("set_external_pressure" = extpressure))
				filter = RADIO_FROM_AIRALARM

			parent.send_signal(data, filter)

	GetText()
		if(mode)//DP vent
			return {"Set <a href=\"?src=\ref[src];swap_modes=1\">dual-port</a> vent pump <a href=\"?src=\ref[src];set_vent_pump=1\">[fmtString(vent_pump)]</a>
				pressure bounds: internal outwards: <a href=\"?src=\ref[src];set_intpressure_out=1">[fmtString(intpressureout)]</a>
				internal inwards: <a href=\"?src=\ref[src];set_intpressure_in=1">[fmtString(intpressurein)]</a>
				external: <a href=\"?src=\ref[src];set_external=1">[fmtString(extpressure)]</a>
			"}//well that was a lot to type
		else
			return {"Set <a href=\"?src=\ref[src];swap_modes=1\">unary</a> vent pump <a href=\"?src=\ref[src];set_vent_pump=1\">[fmtString(vent_pump)]</a>
				pressure bounds: internal: <a href=\"?src=\ref[src];set_intpressure_out=1">[fmtString(intpressureout)]</a>
				external: <a href=\"?src=\ref[src];set_external=1">[fmtString(extpressure)]</a>
			"}//copy paste FTW

	Topic(href, href_list)
		if(..())
			return 1

		if(href_list["set_vent_pump"])
			var/list/injector_names=list()
			if(mode)//DP vent selection
				for(var/obj/machinery/atmospherics/binary/dp_vent_pump/I in world)
					if(!isnull(I.id_tag) && I.frequency == parent.frequency)
						injector_names|=I.id_tag
			else
				for(var/obj/machinery/atmospherics/unary/vent_pump/I in machines)
					if(!isnull(I.id_tag) && I.frequency == parent.frequency)
						injector_names|=I.id_tag
			vent_pump = input("Select a vent:", "Vent Pumps", vent_pump) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1

		if(href_list["set_intpressure_out"])
			var/response = input("Set new pressure, in kPa. \[0-[50*ONE_ATMOSPHERE]\]") as num
			intpressureout = text2num(response)
			intpressureout = between(0, intpressureout, 50*ONE_ATMOSPHERE)
			parent.updateUsrDialog()
			return 1

		if(href_list["set_intpressure_in"])
			var/response = input("Set new pressure, in kPa. \[0-[50*ONE_ATMOSPHERE]\]") as num
			intpressurein = text2num(response)
			intpressurein = between(0, intpressurein, 50*ONE_ATMOSPHERE)
			parent.updateUsrDialog()
			return 1

		if(href_list["set_external"])
			var/response = input(usr,"Set new pressure, in kPa. \[0-[50*ONE_ATMOSPHERE]\]") as num
			extpressure = text2num(response)
			extpressure = between(0, extpressure, 50*ONE_ATMOSPHERE)
			parent.updateUsrDialog()
			return 1

		if(href_list["swap_modes"])
			mode = !mode
			vent_pump = null//if we don't clear this is could get glitchy, by which I mean not at all, whatever, stay clean
			parent.updateUsrDialog()
			return 1

/datum/automation/set_vent_pressure_checks
	name = "Vent Pump: Pressure Checks"

	var/vent_pump = null
	var/checks = 1
	var/mode = 0//1 for DP vent, 0 for unary vent
/*
checks bitflags
1 = external
2 = internal in (regular internal for unaries)
4 = internal out (ignored by unaries)
*/


	Export()
		var/list/json = ..()
		json["vent_pump"] = vent_pump
		json["checks"] = checks
		json["mode"] = mode
		return json

	Import(var/list/json)
		..(json)
		vent_pump = json["vent_pump"]
		checks = text2num(json["checks"])
		mode = text2num(json["mode"])

	New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
		..(aa)

	process()
		if(vent_pump)
			parent.send_signal(list("tag" = vent_pump, "checks" = checks), filter = (mode ? RADIO_ATMOSIA : RADIO_FROM_AIRALARM))//not gonna bother with a sanity check here, there *should* not be any problems

	GetText()
		if(mode)
			return {"Set <a href=\"?src=\ref[src];swap_modes=1\">dual-port</a> vent pump <a href=\"?src=\ref[src];set_vent_pump=1\">[fmtString(vent_pump)]</a> pressure checks to:
				external <a href=\"?src=\ref[src];togglecheck=1\">[checks&1 ? "Enabled" : "Disabled"]</a>
				internal inwards <a href=\"?src=\ref[src];togglecheck=2\">[checks&2 ? "Enabled" : "Disabled"]</a>
				internal outwards <a href=\"?src=\ref[src];togglecheck=4\">[checks&4 ? "Enabled" : "Disabled"]</a>
			"}
		else
			return {"Set <a href=\"?src=\ref[src];swap_modes=1\">unary</a> vent pump <a href=\"?src=\ref[src];set_vent_pump=1\">[fmtString(vent_pump)]</a> pressure checks to:
				external: <a href=\"?src=\ref[src];togglecheck=1\">[checks&1 ? "Enabled" : "Disabled"]</a>,
				internal: <a href=\"?src=\ref[src];togglecheck=2\">[checks&2 ? "Enabled" : "Disabled"]</a>
			"}

	Topic(href, href_list)
		if(..())
			return 1

		if(href_list["set_vent_pump"])
			var/list/injector_names=list()
			if(mode)//DP vent selection
				for(var/obj/machinery/atmospherics/binary/dp_vent_pump/I in world)
					if(!isnull(I.id_tag) && I.frequency == parent.frequency)
						injector_names|=I.id_tag
			else
				for(var/obj/machinery/atmospherics/unary/vent_pump/I in machines)
					if(!isnull(I.id_tag) && I.frequency == parent.frequency)
						injector_names|=I.id_tag
			vent_pump = input("Select a vent:", "Vent Pumps", vent_pump) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1

		if(href_list["swap_modes"])
			mode = !mode
			vent_pump = null//if we don't clear this is could get glitchy, by which I mean not at all, whatever, stay clean
			if(!mode && checks&4)//disable this bitflag since we're switching to unaries
				checks &= ~4
			parent.updateUsrDialog()
			return 1

		if(href_list["togglecheck"])
			var/bitflagvalue = text2num(href_list["togglecheck"])
			if(mode)
				if(!(bitflagvalue in list(1, 2, 4)))
					return 0
			else if(!(bitflagvalue in list(1, 2)))
				return 0

			if(checks&bitflagvalue)//the bitflag is on ATM
				checks &= ~bitflagvalue
			else//can't not be off
				checks |= bitflagvalue
			parent.updateUsrDialog()
			return 1


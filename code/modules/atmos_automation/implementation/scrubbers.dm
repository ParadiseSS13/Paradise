/datum/automation/set_scrubber_mode
	name="Scrubber: Mode"

	var/scrubber=null
	var/mode=1

	Export()
		var/list/json = ..()
		json["scrubber"]=scrubber
		json["mode"]=mode
		return json

	Import(var/list/json)
		..(json)
		scrubber = json["scrubber"]
		mode = text2num(json["mode"])

	New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
		..(aa)
		children=list(null)

	process()
		if(scrubber)
			parent.send_signal(list ("tag" = scrubber, "sigtype"="command", "scrubbing"=mode),filter = RADIO_FROM_AIRALARM)
		return 0

	GetText()
		return "Set Scrubber <a href=\"?src=[UID()];set_scrubber=1\">[fmtString(scrubber)]</a> mode to <a href=\"?src=[UID()];set_mode=1\">[mode?"Scrubbing":"Syphoning"]</a>."

	Topic(href,href_list)
		if(..()) return
		if(href_list["set_mode"])
			mode=!mode
			parent.updateUsrDialog()
			return 1
		if(href_list["set_scrubber"])
			var/list/injector_names=list()
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S in machines)
				if(!isnull(S.id_tag) && S.frequency == parent.frequency)
					injector_names|=S.id_tag
			scrubber = input("Select a scrubber:", "Scrubbers", scrubber) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1

/datum/automation/set_scrubber_power
	name="Scrubber: Power"

	var/scrubber=null
	var/state=0

	Export()
		var/list/json = ..()
		json["scrubber"]=scrubber
		json["state"]=state
		return json

	Import(var/list/json)
		..(json)
		scrubber = json["scrubber"]
		state = text2num(json["state"])

	New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
		..(aa)

	process()
		if(scrubber)
			parent.send_signal(list ("tag" = scrubber, "sigtype"="command", "power"=state),filter = RADIO_FROM_AIRALARM)

	GetText()
		return  "Set Scrubber <a href=\"?src=[UID()];set_scrubber=1\">[fmtString(scrubber)]</a> power to <a href=\"?src=[UID()];set_power=1\">[state ? "on" : "off"]</a>."

	Topic(href,href_list)
		if(..()) return
		if(href_list["set_power"])
			state = !state
			parent.updateUsrDialog()
			return 1
		if(href_list["set_scrubber"])
			var/list/injector_names=list()
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S in machines)
				if(!isnull(S.id_tag) && S.frequency == parent.frequency)
					injector_names|=S.id_tag
			scrubber = input("Select a scrubber:", "Scrubbers", scrubber) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1

var/global/list/gas_labels=list(
	"co2" = "CO<sub>2</sub>",
	"tox" = "Plasma",
	"n2o" = "N<sub>2</sub>O",
	"o2"  = "O<sub>2</sub>",
	"n2"  = "N<sub>2</sub>"
)
/datum/automation/set_scrubber_gasses
	name="Scrubber: Gasses"

	var/scrubber=null
	var/list/gasses=list(
		"co2" = 1,
		"tox" = 0,
		"n2o" = 0,
		"o2"  = 0,
		"n2"  = 0
	)

	Export()
		var/list/json = ..()
		json["scrubber"]=scrubber
		json["gasses"]=gasses
		return json

	Import(var/list/json)
		..(json)
		scrubber = json["scrubber"]

		var/list/newgasses=json["gasses"]
		for(var/key in newgasses)
			gasses[key]=newgasses[key]


	New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
		..(aa)

	process()
		if(scrubber)
			var/list/data = list ("tag" = scrubber, "sigtype"="command")
			for(var/gas in gasses)
				data[gas+"_scrub"]=gasses[gas]
			parent.send_signal(data,filter = RADIO_FROM_AIRALARM)

	GetText()
		var/txt = "Set Scrubber <a href=\"?src=[UID()];set_scrubber=1\">[fmtString(scrubber)]</a> to scrub "
		for(var/gas in gasses)
			txt += " [gas_labels[gas]] (<a href=\"?src=[UID()];tog_gas=[gas]\">[gasses[gas] ? "on" : "off"]</a>),"
		return txt

	Topic(href,href_list)
		if(..()) return
		if(href_list["tog_gas"])
			var/gas = href_list["tog_gas"]
			if(!(gas in gasses))
				return
			gasses[gas] = !gasses[gas]
			parent.updateUsrDialog()
			return 1
		if(href_list["set_scrubber"])
			var/list/injector_names=list()
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S in machines)
				if(!isnull(S.id_tag) && S.frequency == parent.frequency)
					injector_names|=S.id_tag
			scrubber = input("Select a scrubber:", "Scrubbers", scrubber) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1
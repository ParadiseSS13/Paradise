/datum/automation/set_emitter_power
	name = "Emitter: Set Power"
	var/emitter=null
	var/on=0

	Export()
		var/list/json = ..()
		json["emitter"]=emitter
		json["on"]=on
		return json

	Import(var/list/json)
		..(json)
		emitter = json["emitter"]
		on = text2num(json["on"])

	process()
		if(emitter)
			parent.send_signal(list("tag" = emitter, "command"="set", "state" = on, "hiddenprints" = parent.fingerprintshidden))
		return 0

	GetText()
		return "Set emitter <a href=\"?src=[UID()];set_subject=1\">[fmtString(emitter)]</a> to <a href=\"?src=[UID()];set_power=1\">[on?"on":"off"]</a>."

	Topic(href,href_list)
		if(..())
			return 1
		if(href_list["set_power"])
			on=!on
			parent.updateUsrDialog()
			return 1
		if(href_list["set_subject"])
			var/list/emitters=list()
			for(var/obj/machinery/power/emitter/E in machines)
				if(!isnull(E.id_tag) && E.frequency == parent.frequency)
					emitters|=E.id_tag
			if(emitters.len==0)
				to_chat(usr, "<span class='warning'>Unable to find any emitters on this frequency.</span>")
				return
			emitter = input("Select an emitter:", "Emitter", emitter) as null|anything in emitters
			parent.updateUsrDialog()
			return 1
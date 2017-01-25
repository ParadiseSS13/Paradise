/datum/wires/nuclearbomb
	holder_type = /obj/machinery/nuclearbomb
	random = 1
	wire_count = 7

var/const/NUCLEARBOMB_WIRE_LIGHT		= 1
var/const/NUCLEARBOMB_WIRE_TIMING		= 2
var/const/NUCLEARBOMB_WIRE_SAFETY		= 4

/datum/wires/nuclearbomb/CanUse(var/mob/living/L)
	var/obj/machinery/nuclearbomb/N = holder
	if(N.panel_open)
		return 1
	return 0

/datum/wires/nuclearbomb/GetInteractWindow()
	var/obj/machinery/nuclearbomb/N = holder
	. += ..()
	. += "<BR>The device is [N.timing ? "shaking!" : "still."]<BR>"
	. += "The device is is [N.safety ? "quiet" : "whirring"].<BR>"
	. += "The lights are [N.lighthack ? "static" : "functional"].<BR>"

/datum/wires/nuclearbomb/UpdatePulsed(var/index)
	var/obj/machinery/nuclearbomb/N = holder
	switch(index)
		if(NUCLEARBOMB_WIRE_LIGHT)
			N.lighthack = !N.lighthack
			spawn(100)
				N.lighthack = !N.lighthack
		if(NUCLEARBOMB_WIRE_TIMING)
			if(N.timing)
				spawn
					message_admins("[key_name_admin(usr)] pulsed a nuclear bomb's detonation wire, causing it to explode (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[holder.x];Y=[holder.y];Z=[holder.z]'>JMP</a>)")
					N.explode()
		if(NUCLEARBOMB_WIRE_SAFETY)
			N.safety = !N.safety
			spawn(100)
				N.safety = !N.safety
				if(N.safety == 1)
					if(!N.is_syndicate)
						set_security_level(N.previous_level)
					N.visible_message("\blue The [N] quiets down.")
					if(!N.lighthack)
						if(N.icon_state == "nuclearbomb2")
							N.icon_state = "nuclearbomb1"
				else
					N.visible_message("\blue The [N] emits a quiet whirling noise!")
				
/datum/wires/nuclearbomb/UpdateCut(var/index, var/mended)
	var/obj/machinery/nuclearbomb/N = holder
	switch(index)
		if(NUCLEARBOMB_WIRE_SAFETY)
			if(N.timing)
				spawn
					message_admins("[key_name_admin(usr)] cut a nuclear bomb's timing wire, causing it to explode (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[holder.x];Y=[holder.y];Z=[holder.z]'>JMP</a>)")
					N.explode()
		if(NUCLEARBOMB_WIRE_TIMING)
			if(!N.lighthack)
				if(N.icon_state == "nuclearbomb2")
					N.icon_state = "nuclearbomb1"
			N.timing = 0
			bomb_set = 0
		if(NUCLEARBOMB_WIRE_LIGHT)
			N.lighthack = !N.lighthack

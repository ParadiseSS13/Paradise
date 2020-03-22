/datum/wires/nuclearbomb
	holder_type = /obj/machinery/nuclearbomb
	random = 1
	wire_count = 7

#define NUCLEARBOMB_WIRE_LIGHT 1
#define NUCLEARBOMB_WIRE_TIMING 2
#define NUCLEARBOMB_WIRE_SAFETY 4

/datum/wires/nuclearbomb/GetWireName(index)
	switch(index)
		if(NUCLEARBOMB_WIRE_LIGHT)
			return "Bomb Light"

		if(NUCLEARBOMB_WIRE_TIMING)
			return "Bomb Timing"

		if(NUCLEARBOMB_WIRE_SAFETY)
			return "Bomb Safety"

/datum/wires/nuclearbomb/CanUse(mob/living/L)
	var/obj/machinery/nuclearbomb/N = holder
	if(N.panel_open)
		return 1
	return 0

/datum/wires/nuclearbomb/get_status()
	. = ..()
	var/obj/machinery/nuclearbomb/N = holder
	. += "The device is [N.timing ? "shaking!" : "still."]"
	. += "The device is is [N.safety ? "quiet" : "whirring"]."
	. += "The lights are [N.lighthack ? "static" : "functional"]."

/datum/wires/nuclearbomb/UpdatePulsed(index)
	var/obj/machinery/nuclearbomb/N = holder
	switch(index)
		if(NUCLEARBOMB_WIRE_LIGHT)
			N.lighthack = !N.lighthack
			updateUIs()
			spawn(100)
				N.lighthack = !N.lighthack
				updateUIs()
		if(NUCLEARBOMB_WIRE_TIMING)
			if(N.timing)
				message_admins("[key_name_admin(usr)] pulsed a nuclear bomb's detonation wire, causing it to explode (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[holder.x];Y=[holder.y];Z=[holder.z]'>JMP</a>)")
				N.explode()
		if(NUCLEARBOMB_WIRE_SAFETY)
			N.safety = !N.safety
			updateUIs()
			spawn(100)
				N.safety = !N.safety
				if(N.safety == 1)
					if(!N.is_syndicate)
						set_security_level(N.previous_level)
					N.visible_message("<span class='notice'>The [N] quiets down.</span>")
					if(!N.lighthack)
						if(N.icon_state == "nuclearbomb2")
							N.icon_state = "nuclearbomb1"
				else
					N.visible_message("<span class='notice'>The [N] emits a quiet whirling noise!</span>")
				updateUIs()

/datum/wires/nuclearbomb/UpdateCut(index, mended)
	var/obj/machinery/nuclearbomb/N = holder
	switch(index)
		if(NUCLEARBOMB_WIRE_SAFETY)
			if(N.timing)
				message_admins("[key_name_admin(usr)] cut a nuclear bomb's timing wire, causing it to explode (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[holder.x];Y=[holder.y];Z=[holder.z]'>JMP</a>)")
				N.explode()
		if(NUCLEARBOMB_WIRE_TIMING)
			if(!N.lighthack)
				if(N.icon_state == "nuclearbomb2")
					N.icon_state = "nuclearbomb1"
			N.timing = 0
			GLOB.bomb_set = 0
		if(NUCLEARBOMB_WIRE_LIGHT)
			N.lighthack = !N.lighthack

/datum/wires/nuclearbomb/proc/updateUIs()
	SSnanoui.update_uis(src)
	if(holder)
		SSnanoui.update_uis(holder)


////////////////////////////////////
///// Rendering stats window ///////
////////////////////////////////////

/obj/mecha/proc/get_stats_html()
	var/output = {"<html>
						<meta charset="UTF-8">
						<head><title>[name] data</title>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Lucida Console",monospace; font-size: 12px;}
						hr {border: 1px solid #0f0; color: #0f0; background-color: #0f0;}
						a {padding:2px 5px;;color:#0f0;}
						.wr {margin-bottom: 5px;}
						.header {cursor:pointer;}
						.open, .closed {background: #32CD32; color:#000; padding:1px 2px;}
						.links a {margin-bottom: 2px;padding-top:3px;}
						.visible {display: block;}
						.hidden {display: none;}
						</style>
						<script language='javascript' type='text/javascript'>
						[JS_BYJAX]
						[JS_DROPDOWNS]
						function ticker() {
						    setInterval(function(){
						        window.location='byond://?src=[UID()]&update_content=1';
						    }, 1000);
						}

						window.onload = function() {
							dropdowns();
							ticker();
						}
						</script>
						</head>
						<body>
						<div id='content'>
						[get_stats_part()]
						</div>
						<div id='eq_list'>
						[get_equipment_list()]
						</div>
						<hr>
						<div id='commands'>
						[get_commands()]
						</div>
						</body>
						</html>
					 "}
	return output


/obj/mecha/proc/report_internal_damage()
	var/output = null
	var/list/dam_reports = list(
										"[MECHA_INT_FIRE]" = "<font color='red'><b>INTERNAL FIRE</b></font>",
										"[MECHA_INT_TEMP_CONTROL]" = "<font color='red'><b>LIFE SUPPORT SYSTEM MALFUNCTION</b></font>",
										"[MECHA_INT_TANK_BREACH]" = "<font color='red'><b>GAS TANK BREACH</b></font>",
										"[MECHA_INT_CONTROL_LOST]" = "<font color='red'><b>COORDINATION SYSTEM CALIBRATION FAILURE</b></font> - <a href='?src=[UID()];repair_int_control_lost=1'>Recalibrate</a>",
										"[MECHA_INT_SHORT_CIRCUIT]" = "<font color='red'><b>SHORT CIRCUIT</b></font>"
										)
	for(var/tflag in dam_reports)
		var/intdamflag = text2num(tflag)
		if(hasInternalDamage(intdamflag))
			output += dam_reports[tflag]
			output += "<br />"
	if(return_pressure() > WARNING_HIGH_PRESSURE)
		output += "<font color='red'><b>DANGEROUSLY HIGH CABIN PRESSURE</b></font><br />"
	return output


/obj/mecha/proc/get_stats_part()
	var/integrity = obj_integrity/max_integrity*100
	var/cell_charge = get_charge()
	var/tank_pressure = internal_tank ? round(internal_tank.return_pressure(),0.01) : "None"
	var/tank_temperature = internal_tank ? internal_tank.return_temperature() : "Unknown"
	var/tank_temperature_c = internal_tank ? internal_tank.return_temperature() - T0C : "Unknown"
	var/cabin_pressure = round(return_pressure(),0.01)
	. = "[report_internal_damage()]"
	. += "[integrity<30?"<font color='red'><b>DAMAGE LEVEL CRITICAL</b></font><br>":null]"
	. += "<b>Integrity: </b> [integrity]%<br>"
	. += "<b>Powercell charge: </b>[isnull(cell_charge)?"No powercell installed":"[cell.percent()]%"]<br>"
	. += "<b>Air source: </b>[use_internal_tank?"Internal Airtank":"Environment"]<br>"
	. += "<b>Airtank pressure: </b>[tank_pressure]kPa<br>"
	. += "<b>Airtank temperature: </b>[tank_temperature]&deg;K|[tank_temperature_c]&deg;C<br>"
	. += "<b>Cabin pressure: </b>[cabin_pressure>WARNING_HIGH_PRESSURE ? "<font color='red'>[cabin_pressure]</font>": cabin_pressure]kPa<br>"
	. += "<b>Cabin temperature: </b> [return_temperature()]&deg;K|[return_temperature() - T0C]&deg;C<br>"
	. += "<b>Lights: </b>[lights?"on":"off"]<br>"
	. += "[dna ? "<b>DNA-locked:</b><br> <span style='font-size:10px;letter-spacing:-1px;'>[dna]</span> \[<a href='?src=[UID()];reset_dna=1'>Reset</a>\]<br>" : ""]"
	. += "[defense_action.owner ? "<b>Defence Mode: </b> [defence_mode ? "Enabled" : "Disabled"]<br>" : ""]"
	. += "[overload_action.owner ? "<b>Leg Actuators Overload: </b> [leg_overload_mode ? "Enabled" : "Disabled"]<br>" : ""]"
	. += "[thrusters_action.owner ? "<b>Thrusters: </b> [thrusters_active ? "Enabled" : "Disabled"]<br>" : ""]"
	. += "[smoke_action.owner ? "<b>Smoke: </b> [smoke]<br>" : ""]"
	. += "[zoom_action.owner ? "<b>Zoom: </b> [zoom_mode ? "Enabled" : "Disabled"]<br>" : ""]"
	. += "[phasing_action.owner ? "<b>Phase Modulator: </b> [phasing ? "Enabled" : "Disabled"]<br>" : ""]"

/obj/mecha/proc/get_commands()
	. = "<div class='wr'>"
	. += "<div class='header'>Electronics</div>"
	. += "<div class='links'>"
	. += "<a href='?src=[UID()];toggle_lights=1'>Toggle Lights</a><br>"
	. += "<b>Radio settings:</b><br>"
	. += "Microphone: <a href='?src=[UID()];rmictoggle=1'><span id='rmicstate'>[radio.broadcasting?"Engaged":"Disengaged"]</span></a><br>"
	. += "Speaker: <a href='?src=[UID()];rspktoggle=1'><span id='rspkstate'>[radio.listening?"Engaged":"Disengaged"]</span></a><br>"
	. += "Frequency:"
	. += "<a href='?src=[UID()];rfreq=-10'>-</a>"
	. += "<a href='?src=[UID()];rfreq=-2'>-</a>"
	. += "<span id='rfreq'>[format_frequency(radio.frequency)]</span>"
	. += "<a href='?src=[UID()];rfreq=2'>+</a>"
	. += "<a href='?src=[UID()];rfreq=10'>+</a><br>"
	. += "</div>"
	. += "</div>"
	. += "<div class='wr'>"
	. += "<div class='header'>Airtank</div>"
	. += "<div class='links'>"
	. += "<a href='?src=[UID()];toggle_airtank=1'>Toggle Internal Airtank Usage</a><br>"
	. += "</div>"
	. += "</div>"
	. += "<div class='wr'>"
	. += "<div class='header'>Permissions & Logging</div>"
	. += "<div class='links'>"
	. += "<a href='?src=[UID()];toggle_id_upload=1'><span id='t_id_upload'>[add_req_access?"L":"Unl"]ock ID upload panel</span></a><br>"
	. += "<a href='?src=[UID()];toggle_maint_access=1'><span id='t_maint_access'>[maint_access?"Forbid":"Permit"] maintenance protocols</span></a><br>"
	. += "<a href='?src=[UID()];dna_lock=1'>DNA-lock</a><br>"
	. += "<a href='?src=[UID()];view_log=1'>View internal log</a><br>"
	. += "<a href='?src=[UID()];change_name=1'>Change exosuit name</a><br>"
	. += "</div>"
	. += "</div>"
	. += "<div id='equipment_menu'>[get_equipment_menu()]</div>"
	. += "<hr>"
	. += "<a href='?src=[UID()];eject=1'>Eject</a><br>"

/obj/mecha/proc/get_equipment_menu() //outputs mecha html equipment menu
	. = ""
	if(equipment.len)
		. += "<div class='wr'>"
		. += "<div class='header'>Equipment</div>"
		. += "<div class='links'>"
		for(var/obj/item/mecha_parts/mecha_equipment/W in equipment)
			. += "[W.name] <a href='?src=[W.UID()];detach=1'>Detach</a><br>"
		. += "<b>Available equipment slots:</b> [max_equip-equipment.len]"
		. += "</div></div>"

/obj/mecha/proc/get_equipment_list() //outputs mecha equipment list in html
	if(!equipment.len)
		return
	. = "<b>Equipment:</b><div style=\"margin-left: 15px;\">"
	for(var/obj/item/mecha_parts/mecha_equipment/MT in equipment)
		. += "<div id='\ref[MT]'>[MT.get_equip_info()]</div>"
	. += "</div>"


/obj/mecha/proc/get_log_html()
	var/output = {"<html><meta charset="UTF-8"><head><title>[name] Log</title></head><body style='font: 13px 'Courier', monospace;'>"}
	for(var/list/entry in log)
		output += {"<div style='font-weight: bold;'>[time2text(entry["time"],"DDD MMM DD hh:mm:ss")] 2555</div>
						<div style='margin-left:15px; margin-bottom:10px;'>[entry["message"]]</div>
						"}
	output += "</body></html>"
	return output

/obj/mecha/proc/get_log_tgui()
	var/list/data = list()
	for(var/list/entry in log)
		data.Add(list(list(
			"time" = time2text(entry["time"], "hh:mm:ss"),
			"message" = entry["message"],
		)))
	return data

/obj/mecha/proc/output_access_dialog(obj/item/card/id/id_card, mob/user)
	if(!id_card || !user) return
	var/output = {"<html>
						<meta charset="UTF-8">
						<head><style>
						h1 {font-size:15px;margin-bottom:4px;}
						body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
						a {color:#0f0;}
						</style>
						</head>
						<body>
						<h1>Following keycodes are present in this system:</h1>"}
	for(var/a in operation_req_access)
		output += "[get_access_desc(a)] - <a href='?src=[UID()];del_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Delete</a><br>"

	output += "<a href='?src=[UID()];del_all_req_access=1;user=\ref[user];id_card=\ref[id_card]'><br><b>Delete All</b></a><br>"

	output += "<hr><h1>Following keycodes were detected on portable device:</h1>"
	for(var/a in id_card.access)
		if(a in operation_req_access) continue
		if(!get_access_desc(a))
			continue //there's some strange access without a name
		output += "[get_access_desc(a)] - <a href='?src=[UID()];add_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Add</a><br>"

	output += "<a href='?src=[UID()];add_all_req_access=1;user=\ref[user];id_card=\ref[id_card]'><br><b>Add All</b></a><br>"
	output += "<hr><a href='?src=[UID()];finish_req_access=1;user=\ref[user]'>Finish</a> <font color='red'>(Warning! The ID upload panel will be locked. It can be unlocked only through Exosuit Interface.)</font>"
	output += "</body></html>"
	user << browse(output, "window=exosuit_add_access")
	onclose(user, "exosuit_add_access")
	return

/obj/mecha/proc/output_maintenance_dialog(obj/item/card/id/id_card,mob/user)
	if(!id_card || !user) return
	var/output = {"<html>
						<meta charset="UTF-8">
						<head>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
						a {padding:2px 5px; background:#32CD32;color:#000;display:block;margin:2px;text-align:center;text-decoration:none;}
						</style>
						</head>
						<body>
						[add_req_access?"<a href='?src=[UID()];req_access=1;id_card=\ref[id_card];user=\ref[user]'>Edit operation keycodes</a>":null]
						[maint_access?"<a href='?src=[UID()];maint_access=1;id_card=\ref[id_card];user=\ref[user]'>Initiate/Stop maintenance protocol</a>":null]
						[(state>0) ?"<a href='?src=[UID()];set_internal_tank_valve=1;user=\ref[user]'>Set Cabin Air Pressure</a>":null]
						</body>
						</html>"}
	user << browse(output, "window=exosuit_maint_console")
	onclose(user, "exosuit_maint_console")
	return


////////////////////////////////
/////// Messages and Log ///////
////////////////////////////////

/obj/mecha/proc/occupant_message(message as text)
	if(message)
		if(occupant && occupant.client)
			to_chat(occupant, "[bicon(src)] [message]")
	return

/obj/mecha/proc/log_message(message as text,red=null)
	log.len++
	log[log.len] = list("time"=world.timeofday,"message"="[red?"<font color='red'>":null][message][red?"</font>":null]")
	return log.len

/obj/mecha/proc/log_append_to_last(message as text,red=null)
	var/list/last_entry = log[log.len]
	last_entry["message"] += "<br>[red?"<font color='red'>":null][message][red?"</font>":null]"
	return


/////////////////
///// Topic /////
/////////////////

/obj/mecha/Topic(href, href_list)
	..()
	if(href_list["update_content"])
		if(usr != occupant)	return
		send_byjax(occupant,"exosuit.browser","content",get_stats_part())
		return
	if(href_list["close"])
		return
	if(usr.stat > 0)
		return
	var/datum/topic_input/afilter = new /datum/topic_input(href,href_list)
	if(href_list["select_equip"])
		if(usr != occupant)	return
		var/obj/item/mecha_parts/mecha_equipment/equip = afilter.getObj("select_equip")
		if(equip)
			selected = equip
			occupant_message("You switch to [equip]")
			visible_message("[src] raises [equip]")
			send_byjax(occupant, "exosuit.browser", "eq_list", get_equipment_list())
		return
	if(href_list["eject"])
		if(usr != occupant)	return
		go_out()
		return
	if(href_list["toggle_lights"])
		if(usr != occupant)	return
		toggle_lights()
		return
	if(href_list["toggle_airtank"])
		if(usr != occupant)	return
		toggle_internal_tank()
		return
	if(href_list["rmictoggle"])
		if(usr != occupant)	return
		radio.broadcasting = !radio.broadcasting
		send_byjax(occupant,"exosuit.browser","rmicstate",(radio.broadcasting?"Engaged":"Disengaged"))
		return
	if(href_list["rspktoggle"])
		if(usr != occupant)	return
		radio.listening = !radio.listening
		send_byjax(occupant,"exosuit.browser","rspkstate",(radio.listening?"Engaged":"Disengaged"))
		return
	if(href_list["rfreq"])
		if(usr != occupant)	return
		var/new_frequency = (radio.frequency + afilter.getNum("rfreq"))
		if((radio.frequency < PUBLIC_LOW_FREQ || radio.frequency > PUBLIC_HIGH_FREQ))
			new_frequency = sanitize_frequency(new_frequency)
		radio.set_frequency(new_frequency)
		send_byjax(occupant,"exosuit.browser","rfreq","[format_frequency(radio.frequency)]")
		return
	if(href_list["view_log"])
		if(usr != occupant)	return
		occupant << browse(get_log_html(), "window=exosuit_log")
		onclose(occupant, "exosuit_log")
		return
	if(href_list["change_name"])
		if(usr != occupant)	return
		var/newname = strip_html_simple(input(occupant,"Choose new exosuit name","Rename exosuit",initial(name)) as text, MAX_NAME_LEN)
		if(newname && trim(newname))
			name = newname
			log_game("[key_name(occupant)] has renamed an exosuit [newname]")
		else
			alert(occupant, "nope.avi")
		return
	if(href_list["toggle_id_upload"])
		if(usr != occupant)	return
		add_req_access = !add_req_access
		send_byjax(occupant,"exosuit.browser","t_id_upload","[add_req_access?"L":"Unl"]ock ID upload panel")
		return
	if(href_list["toggle_maint_access"])
		if(usr != occupant)	return
		if(state)
			occupant_message("<font color='red'>Maintenance protocols in effect</font>")
			return
		maint_access = !maint_access
		send_byjax(occupant,"exosuit.browser","t_maint_access","[maint_access?"Forbid":"Permit"] maintenance protocols")
		return
	if(href_list["req_access"] && add_req_access)
		if(!in_range(src, usr))	return
		output_access_dialog(afilter.getObj("id_card"),afilter.getMob("user"))
		return
	if(href_list["maint_access"] && maint_access)
		if(!in_range(src, usr))	return
		var/mob/user = afilter.getMob("user")
		if(user)
			if(state==0)
				state = 1
				to_chat(user, "The securing bolts are now exposed.")
				if(occupant)
					occupant.throw_alert("locked", /obj/screen/alert/mech_maintenance)
			else if(state==1)
				state = 0
				to_chat(user, "The securing bolts are now hidden.")
				if(occupant)
					occupant.clear_alert("locked")
			output_maintenance_dialog(afilter.getObj("id_card"),user)
		return
	if(href_list["set_internal_tank_valve"] && state >=1)
		if(!in_range(src, usr))	return
		var/mob/user = afilter.getMob("user")
		if(user)
			var/new_pressure = input(user,"Input new output pressure","Pressure setting",internal_tank_valve) as num
			if(new_pressure)
				internal_tank_valve = new_pressure
				to_chat(user, "The internal pressure valve has been set to [internal_tank_valve]kPa.")
	if(href_list["add_req_access"] && add_req_access && afilter.getObj("id_card"))
		if(!in_range(src, usr))	return
		operation_req_access += afilter.getNum("add_req_access")
		output_access_dialog(afilter.getObj("id_card"),afilter.getMob("user"))
		return
	if(href_list["add_all_req_access"] && add_req_access && afilter.getObj("id_card"))
		if(!in_range(src, usr))
			return
		var/obj/item/card/id/mycard = afilter.getObj("id_card")
		var/list/myaccess = mycard.access
		for(var/a in myaccess)
			if(get_access_desc(a))
				operation_req_access += a
		output_access_dialog(afilter.getObj("id_card"),afilter.getMob("user"))
		return
	if(href_list["del_req_access"] && add_req_access && afilter.getObj("id_card"))
		if(!in_range(src, usr))	return
		operation_req_access -= afilter.getNum("del_req_access")
		output_access_dialog(afilter.getObj("id_card"),afilter.getMob("user"))
		return
	if(href_list["del_all_req_access"] && add_req_access && afilter.getObj("id_card"))
		if(!in_range(src, usr))
			return
		operation_req_access = list()
		output_access_dialog(afilter.getObj("id_card"),afilter.getMob("user"))
		return
	if(href_list["finish_req_access"])
		if(!in_range(src, usr))	return
		add_req_access = 0
		var/mob/user = afilter.getMob("user")
		user << browse(null,"window=exosuit_add_access")
		return
	if(href_list["dna_lock"])
		if(usr != occupant)
			return
		if(occupant && !iscarbon(occupant))
			to_chat(occupant, "<span class='danger'>You do not have any DNA!</span>")
			return
		dna = occupant.dna.unique_enzymes
		occupant_message("You feel a prick as the needle takes your DNA sample.")
		return
	if(href_list["reset_dna"])
		if(usr != occupant)	return
		dna = null
	if(href_list["repair_int_control_lost"])
		if(usr != occupant)	return
		occupant_message("Recalibrating coordination system.")
		log_message("Recalibration of coordination system started.")
		var/T = loc
		spawn(100)
			if(T == loc)
				clearInternalDamage(MECHA_INT_CONTROL_LOST)
				occupant_message("<font color='blue'>Recalibration successful.</font>")
				log_message("Recalibration of coordination system finished with 0 errors.")
			else
				occupant_message("<font color='red'>Recalibration failed.</font>")
				log_message("Recalibration of coordination system failed with 1 error.",1)

	//debug
	/*
	if(href_list["debug"])
		if(href_list["set_i_dam"])
			setInternalDamage(afilter.getNum("set_i_dam"))
		if(href_list["clear_i_dam"])
			clearInternalDamage(afilter.getNum("clear_i_dam"))
		return
	*/

	return

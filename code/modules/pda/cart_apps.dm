/datum/data/pda/app/status_display
	name = "Status Display"
	icon = "list-alt"
	template = "pda_status_display"
	category = "Utilities"

	var/message1	// used for status_displays
	var/message2

/datum/data/pda/app/status_display/update_ui(mob/user as mob, list/data)
	data["records"] = list(
		"message1" = message1 ? message1 : "(none)",
		"message2" = message2 ? message2 : "(none)")

/datum/data/pda/app/status_display/ui_act(action, list/params)
	if(..())
		return

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	. = TRUE
	switch(action)
		if("Status")
			switch(params["statdisp"])
				if("message")
					post_status("message", message1, message2)
				if("alert")
					post_status("alert", params["alert"])
				if("setmsg1")
					message1 = clean_input("Line 1", "Enter Message Text", message1)
				if("setmsg2")
					message2 = clean_input("Line 2", "Enter Message Text", message2)
				else
					post_status(params["statdisp"])

/datum/data/pda/app/status_display/proc/post_status(command, data1, data2)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(DISPLAY_FREQ)
	if(!frequency)
		return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			var/mob/user = pda.fingerprintslast
			if(istype(pda.loc, /mob/living))
				name = pda.loc
			log_admin("STATUS: [user] set status screen with [pda]. Message: [data1] [data2]")
			message_admins("STATUS: [user] set status screen with [pda]. Message: [data1] [data2]")

		if("alert")
			status_signal.data["picture_state"] = data1

	spawn(0)
		frequency.post_signal(src, status_signal)


/datum/data/pda/app/signaller
	name = "Signaler System"
	icon = "rss"
	template = "pda_signaler"
	category = "Utilities"

/datum/data/pda/app/signaller/update_ui(mob/user as mob, list/data)
	if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/signal))
		var/obj/item/integrated_radio/signal/R = pda.cartridge.radio
		data["frequency"] = R.frequency
		data["code"] = R.code
		data["minFrequency"] = PUBLIC_LOW_FREQ
		data["maxFrequency"] = PUBLIC_HIGH_FREQ

/datum/data/pda/app/signaller/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/signal))
		var/obj/item/integrated_radio/signal/R = pda.cartridge.radio

		switch(action)
			if("signal")
				spawn(0)
					R.send_signal("ACTIVATE")

			if("freq")
				var/new_frequency = sanitize_frequency(text2num(params["freq"]) * 10)
				R.set_frequency(new_frequency)

			if("code")
				R.code = clamp(text2num(params["code"]), 1, 100)

/datum/data/pda/app/power
	name = "Power Monitor"
	icon = "bolt"
	template = "pda_power"
	category = "Engineering"
	update = PDA_APP_UPDATE_SLOW

	var/datum/ui_module/power_monitor/digital/pm = new

/datum/data/pda/app/power/update_ui(mob/user as mob, list/data)
	data.Add(pm.ui_data())

// All 4 args are important here because proxying matters
/datum/data/pda/app/power/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	. = TRUE
	// Observe
	pm.ui_act(action, params, ui, state)

/datum/data/pda/app/crew_records
	var/datum/data/record/general_records = null

/datum/data/pda/app/crew_records/update_ui(mob/user as mob, list/data)
	var/list/records = list()

	if(general_records && (general_records in GLOB.data_core.general))
		data["records"] = records
		records["general"] = general_records.fields
		return records
	else
		for(var/A in sortRecord(GLOB.data_core.general))
			var/datum/data/record/R = A
			if(R)
				records += list(list(Name = R.fields["name"], "uid" = "[R.UID()]"))
		data["recordsList"] = records
		data["records"] = null
		return null

/datum/data/pda/app/crew_records/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	if(pda && !pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	switch(action)
		if("Records")
			var/datum/data/record/R = locateUID(params["target"])
			if(R && (R in GLOB.data_core.general))
				load_records(R)
			return
		if("Back")
			general_records = null
			has_back = FALSE
			return

/datum/data/pda/app/crew_records/proc/load_records(datum/data/record/R)
	general_records = R
	has_back = TRUE

/datum/data/pda/app/crew_records/medical
	name = "Medical Records"
	icon = "heartbeat"
	template = "pda_medical"
	category = "Medical"

	var/datum/data/record/medical_records = null

/datum/data/pda/app/crew_records/medical/update_ui(mob/user as mob, list/data)
	var/list/records = ..()
	if(!records)
		return

	if(medical_records && (medical_records in GLOB.data_core.medical))
		records["medical"] = medical_records.fields

	return records

/datum/data/pda/app/crew_records/medical/load_records(datum/data/record/R)
	..(R)
	for(var/A in GLOB.data_core.medical)
		var/datum/data/record/E = A
		if(E && (E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
			medical_records = E
			break

/datum/data/pda/app/crew_records/security
	name = "Security Records"
	icon = "id-badge"
	template = "pda_security"
	category = "Security"

	var/datum/data/record/security_records = null

/datum/data/pda/app/crew_records/security/update_ui(mob/user as mob, list/data)
	var/list/records = ..()
	if(!records)
		return

	if(security_records && (security_records in GLOB.data_core.security))
		records["security"] = security_records.fields

	return records

/datum/data/pda/app/crew_records/security/load_records(datum/data/record/R)
	..(R)
	for(var/A in GLOB.data_core.security)
		var/datum/data/record/E = A
		if(E && (E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
			security_records = E
			break

/datum/data/pda/app/secbot_control
	name = "Security Bot Access"
	icon = "rss"
	template = "pda_secbot"
	category = "Security"

/datum/data/pda/app/secbot_control/update_ui(mob/user as mob, list/data)
	var/list/botsData = list()
	var/list/beepskyData = list()
	if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/beepsky))
		var/obj/item/integrated_radio/beepsky/SC = pda.cartridge.radio
		beepskyData["active"] = SC.active ? sanitize(SC.active.name) : null
		has_back = SC.active ? 1 : 0
		if(SC.active && !isnull(SC.botstatus))
			var/area/loca = SC.botstatus["loca"]
			var/loca_name = sanitize(loca.name)
			beepskyData["botstatus"] = list("loca" = loca_name, "mode" = SC.botstatus["mode"])
		else
			beepskyData["botstatus"] = list("loca" = null, "mode" = -1)
		var/botsCount=0
		if(SC.botlist && SC.botlist.len)
			for(var/mob/living/simple_animal/bot/B in SC.botlist)
				botsCount++
				if(B.loc)
					botsData[++botsData.len] = list("Name" = sanitize(B.name), "Location" = sanitize(B.loc.loc.name), "uid" = "[B.UID()]")

		if(!botsData.len)
			botsData[++botsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "uid"= null)

		beepskyData["bots"] = botsData
		beepskyData["count"] = botsCount

	else
		beepskyData["active"] = 0
		botsData[++botsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "uid"= null)
		beepskyData["botstatus"] = list("loca" = null, "mode" = null)
		beepskyData["bots"] = botsData
		beepskyData["count"] = 0
		has_back = 0

	data["beepsky"] = beepskyData

/datum/data/pda/app/secbot_control/ui_act(action, list/params)
	if(..())
		return

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	. = TRUE

	// Aight listen up. Its time for a comment rant again.
	// The old way of doing this was to proxy things directly from the NanoUI into the PDA's cartridge's radio Topic() function directly
	// It was AWFUL and took me 30 minutes to even understand
	// This is in no way a good solution, but it works atleast
	// Why do we rely on this whole "magical radio system" anyways
	// Hell, I would rather take GLOBs with direct interactions over this
	// WHYYYYYYYYYYYYYYY -aa07

	switch(action)
		if("Back")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/beepsky))
				pda.cartridge.radio.Topic(null, list(op = "botlist"))
		if("Rescan")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/beepsky))
				pda.cartridge.radio.Topic(null, list(op = "scanbots"))
		if("AccessBot")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/beepsky))
				pda.cartridge.radio.Topic(null, list(op = "control", bot = params["uid"]))
		if("Stop")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/beepsky))
				pda.cartridge.radio.Topic(null, list(op = "stop"))
		if("Go")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/beepsky))
				pda.cartridge.radio.Topic(null, list(op = "go"))
		if("Home")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/beepsky))
				pda.cartridge.radio.Topic(null, list(op = "home"))
		if("Summon")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/beepsky))
				pda.cartridge.radio.Topic(null, list(op = "summon"))

/datum/data/pda/app/mule_control
	name = "Delivery Bot Control"
	icon = "truck"
	template = "pda_mule"
	category = "Quartermaster"

/datum/data/pda/app/mule_control/update_ui(mob/user as mob, list/data)
	var/list/muleData = list()
	var/list/mulebotsData = list()
	if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
		var/obj/item/integrated_radio/mule/QC = pda.cartridge.radio
		muleData["active"] = QC.active ? sanitize(QC.active.name) : null
		has_back = QC.active ? 1 : 0
		if(QC.active && !isnull(QC.botstatus))
			var/area/loca = QC.botstatus["loca"]
			var/loca_name = sanitize(loca.name)
			muleData["botstatus"] =  list("loca" = loca_name, "mode" = QC.botstatus["mode"],"home"=QC.botstatus["home"],"powr" = QC.botstatus["powr"],"retn" =QC.botstatus["retn"], "pick"=QC.botstatus["pick"], "load" = QC.botstatus["load"], "dest" = sanitize(QC.botstatus["dest"]))

		else
			muleData["botstatus"] = list("loca" = null, "mode" = -1,"home"=null,"powr" = null,"retn" =null, "pick"=null, "load" = null, "dest" = null)


		var/mulebotsCount=0
		for(var/mob/living/simple_animal/bot/B in QC.botlist)
			mulebotsCount++
			if(B.loc)
				mulebotsData[++mulebotsData.len] = list("Name" = sanitize(B.name), "Location" = sanitize(B.loc.loc.name), "uid" = "[B.UID()]")

		if(!mulebotsData.len)
			mulebotsData[++mulebotsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "uid"= null)

		muleData["bots"] = mulebotsData
		muleData["count"] = mulebotsCount

	else
		muleData["botstatus"] =  list("loca" = null, "mode" = -1,"home"=null,"powr" = null,"retn" =null, "pick"=null, "load" = null, "dest" = null)
		muleData["active"] = 0
		mulebotsData[++mulebotsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "uid"= null)
		muleData["bots"] = mulebotsData
		muleData["count"] = 0
		has_back = 0

	data["mulebot"] = muleData

/datum/data/pda/app/mule_control/ui_act(action, list/params)
	if(..())
		return

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	. = TRUE

	// Heres the exact same shit as before, but worse
	// See L257 to L263 for explanation

	switch(action)
		if("Back")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
				pda.cartridge.radio.Topic(null, list(op = "botlist"))
		if("Rescan")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
				pda.cartridge.radio.Topic(null, list(op = "scanbots"))
		if("AccessBot")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
				pda.cartridge.radio.Topic(null, list(op = "control", bot = params["uid"]))
		if("Unload")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
				pda.cartridge.radio.Topic(null, list(op = "unload"))
		if("SetDest")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
				pda.cartridge.radio.Topic(null, list(op = "setdest"))
		if("SetAutoReturn")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
				pda.cartridge.radio.Topic(null, list(op = params["autoReturnType"])) // "retoff" or "reton"
		if("SetAutoPickup")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
				pda.cartridge.radio.Topic(null, list(op = params["autoPickupType"])) // "pickoff" or "pickon"
		if("Stop")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
				pda.cartridge.radio.Topic(null, list(op = "stop"))
		if("Start")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
				pda.cartridge.radio.Topic(null, list(op = "start"))
		if("ReturnHome")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/integrated_radio/mule))
				pda.cartridge.radio.Topic(null, list(op = "home"))

/datum/data/pda/app/supply
	name = "Supply Records"
	icon = "archive"
	template = "pda_supplyrecords"
	category = "Quartermaster"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/supply/update_ui(mob/user as mob, list/data)
	var/list/supplyData = list()

	if(SSshuttle.supply.mode == SHUTTLE_CALL)
		supplyData["shuttle_moving"] = 1

	if(is_station_level(SSshuttle.supply.z))
		supplyData["shuttle_loc"] = "Station"
	else
		supplyData["shuttle_loc"] = "CentCom"

	supplyData["shuttle_time"] = "([SSshuttle.supply.timeLeft(600)] Mins)"

	var/supplyOrderCount = 0
	var/list/supplyOrderData = list()
	for(var/S in SSshuttle.shoppinglist)
		var/datum/supply_order/SO = S
		supplyOrderCount++
		supplyOrderData[++supplyOrderData.len] = list("Number" = SO.ordernum, "Name" = html_encode(SO.object.name), "ApprovedBy" = SO.orderedby, "Comment" = html_encode(SO.comment))

	if(!supplyOrderData.len)
		supplyOrderData[++supplyOrderData.len] = list("Number" = null, "Name" = null, "OrderedBy"=null)

	supplyData["approved"] = supplyOrderData
	supplyData["approved_count"] = supplyOrderCount

	var/requestCount = 0
	var/list/requestData = list()
	for(var/S in SSshuttle.requestlist)
		var/datum/supply_order/SO = S
		requestCount++
		requestData[++requestData.len] = list("Number" = SO.ordernum, "Name" = html_encode(SO.object.name), "OrderedBy" = SO.orderedby, "Comment" = html_encode(SO.comment))

	if(!requestData.len)
		requestData[++requestData.len] = list("Number" = null, "Name" = null, "orderedBy" = null, "Comment" = null)

	supplyData["requests"] = requestData
	supplyData["requests_count"] = requestCount

	data["supply"] = supplyData

/datum/data/pda/app/janitor
	name = "Custodial Locator"
	icon = "trash"
	template = "pda_janitor"
	category = "Utilities"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/janitor/update_ui(mob/user as mob, list/data)
	var/list/JaniData = list()
	var/turf/cl = get_turf(pda)

	if(cl)
		JaniData["user_loc"] = list("x" = cl.x, "y" = cl.y)
	else
		JaniData["user_loc"] = list("x" = 0, "y" = 0)

	var/list/MopData = list()
	for(var/obj/item/mop/M in GLOB.janitorial_equipment)
		var/turf/ml = get_turf(M)
		if(ml)
			if(ml.z != cl.z)
				continue
			var/direction = get_dir(pda, M)
			MopData[++MopData.len] = list ("x" = ml.x, "y" = ml.y, "dir" = uppertext(dir2text(direction)), "status" = M.reagents.total_volume ? "Wet" : "Dry")

	var/list/BucketData = list()
	for(var/obj/structure/mopbucket/B in GLOB.janitorial_equipment)
		var/turf/bl = get_turf(B)
		if(bl)
			if(bl.z != cl.z)
				continue
			var/direction = get_dir(pda,B)
			BucketData[++BucketData.len] = list ("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "volume" = B.reagents.total_volume, "max_volume" = B.reagents.maximum_volume)

	var/list/CbotData = list()
	for(var/mob/living/simple_animal/bot/cleanbot/B in GLOB.bots_list)
		var/turf/bl = get_turf(B)
		if(bl)
			if(bl.z != cl.z)
				continue
			var/direction = get_dir(pda,B)
			CbotData[++CbotData.len] = list("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.on ? "Online" : "Offline")

	var/list/CartData = list()
	for(var/obj/structure/janitorialcart/B in GLOB.janitorial_equipment)
		var/turf/bl = get_turf(B)
		if(bl)
			if(bl.z != cl.z)
				continue
			var/direction = get_dir(pda,B)
			CartData[++CartData.len] = list("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "volume" = B.reagents.total_volume, "max_volume" = B.reagents.maximum_volume)

	JaniData["mops"] = MopData.len ? MopData : null
	JaniData["buckets"] = BucketData.len ? BucketData : null
	JaniData["cleanbots"] = CbotData.len ? CbotData : null
	JaniData["carts"] = CartData.len ? CartData : null
	data["janitor"] = JaniData

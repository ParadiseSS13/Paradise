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

/datum/data/pda/app/status_display/Topic(href, list/href_list)
	switch(href_list["choice"])
		if("Status")
			switch(href_list["statdisp"])
				if("message")
					post_status("message", message1, message2)
				if("alert")
					post_status("alert", href_list["alert"])
				if("setmsg1")
					message1 = input("Line 1", "Enter Message Text", message1) as text|null
				if("setmsg2")
					message2 = input("Line 2", "Enter Message Text", message2) as text|null
				else
					post_status(href_list["statdisp"])

/datum/data/pda/app/status_display/proc/post_status(var/command, var/data1, var/data2)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)
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
	template = "pda_signaller"
	category = "Utilities"

/datum/data/pda/app/signaller/update_ui(mob/user as mob, list/data)
	if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/radio/integrated/signal))
		var/obj/item/radio/integrated/signal/R = pda.cartridge.radio
		data["signal_freq"] = format_frequency(R.frequency)
		data["signal_code"] = R.code

/datum/data/pda/app/signaller/Topic(href, list/href_list)
	if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/radio/integrated/signal))
		var/obj/item/radio/integrated/signal/R = pda.cartridge.radio

		switch(href_list["choice"])
			if("Send Signal")
				spawn(0)
					R.send_signal("ACTIVATE")

			if("Signal Frequency")
				var/new_frequency = sanitize_frequency(R.frequency + text2num(href_list["sfreq"]))
				R.set_frequency(new_frequency)

			if("Signal Code")
				R.code += text2num(href_list["scode"])
				R.code = round(R.code)
				R.code = min(100, R.code)
				R.code = max(1, R.code)

/datum/data/pda/app/power
	name = "Power Monitor"
	icon = "exclamation-triangle"
	template = "pda_power"
	category = "Engineering"
	update = PDA_APP_UPDATE_SLOW

	var/obj/machinery/computer/monitor/powmonitor = null

/datum/data/pda/app/power/update_ui(mob/user as mob, list/data)
	update = PDA_APP_UPDATE_SLOW

	if(powmonitor && !isnull(powmonitor.powernet))
		data["records"] = list(
			"powerconnected" = 1,
			"poweravail" = powmonitor.powernet.avail,
			"powerload" = num2text(powmonitor.powernet.viewload, 10),
			"powerdemand" = powmonitor.powernet.load,
			"apcs" = apc_repository.apc_data(powmonitor))
		has_back = 1
	else
		data["records"] = list(
			"powerconnected" = 0,
			"powermonitors" = powermonitor_repository.powermonitor_data())
		has_back = 0

/datum/data/pda/app/power/Topic(href, list/href_list)
	switch(href_list["choice"])
		if("Power Select")
			var/pref = href_list["target"]
			powmonitor = locate(pref)
			update = PDA_APP_UPDATE
		if("Back")
			powmonitor = null
			update = PDA_APP_UPDATE

/datum/data/pda/app/crew_records
	var/datum/data/record/general_records = null

/datum/data/pda/app/crew_records/update_ui(mob/user as mob, list/data)
	var/list/records[0]

	if(general_records && (general_records in data_core.general))
		data["records"] = records
		records["general"] = general_records.fields
		return records
	else
		for(var/A in sortRecord(data_core.general))
			var/datum/data/record/R = A
			if(R)
				records += list(list(Name = R.fields["name"], "ref" = "\ref[R]"))
		data["recordsList"] = records
		return null

/datum/data/pda/app/crew_records/Topic(href, list/href_list)
	switch(href_list["choice"])
		if("Records")
			var/datum/data/record/R = locate(href_list["target"])
			if(R && (R in data_core.general))
				load_records(R)
		if("Back")
			general_records = null
			has_back = 0

/datum/data/pda/app/crew_records/proc/load_records(datum/data/record/R)
	general_records = R
	has_back = 1

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

	if(medical_records && (medical_records in data_core.medical))
		records["medical"] = medical_records.fields

	return records

/datum/data/pda/app/crew_records/medical/load_records(datum/data/record/R)
	..(R)
	for(var/A in data_core.medical)
		var/datum/data/record/E = A
		if(E && (E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
			medical_records = E
			break

/datum/data/pda/app/crew_records/security
	name = "Security Records"
	icon = "tags"
	template = "pda_security"
	category = "Security"

	var/datum/data/record/security_records = null

/datum/data/pda/app/crew_records/security/update_ui(mob/user as mob, list/data)
	var/list/records = ..()
	if(!records)
		return

	if(security_records && (security_records in data_core.security))
		records["security"] = security_records.fields

	return records

/datum/data/pda/app/crew_records/security/load_records(datum/data/record/R)
	..(R)
	for(var/A in data_core.security)
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
	var/botsData[0]
	var/beepskyData[0]
	if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/radio/integrated/beepsky))
		var/obj/item/radio/integrated/beepsky/SC = pda.cartridge.radio
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
					botsData[++botsData.len] = list("Name" = sanitize(B.name), "Location" = sanitize(B.loc.loc.name), "ref" = "\ref[B]")

		if(!botsData.len)
			botsData[++botsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "ref"= null)

		beepskyData["bots"] = botsData
		beepskyData["count"] = botsCount

	else
		beepskyData["active"] = 0
		botsData[++botsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "ref"= null)
		beepskyData["botstatus"] = list("loca" = null, "mode" = null)
		beepskyData["bots"] = botsData
		beepskyData["count"] = 0
		has_back = 0

	data["beepsky"] = beepskyData

/datum/data/pda/app/secbot_control/Topic(href, list/href_list)
	switch(href_list["choice"])
		if("Back")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/radio/integrated/beepsky))
				pda.cartridge.radio.Topic(null, list(radiomenu = "1", op = "botlist"))

/datum/data/pda/app/mule_control
	name = "Delivery Bot Control"
	icon = "truck"
	template = "pda_mule"
	category = "Quartermaster"

/datum/data/pda/app/mule_control/update_ui(mob/user as mob, list/data)
	var/muleData[0]
	var/mulebotsData[0]
	if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/radio/integrated/mule))
		var/obj/item/radio/integrated/mule/QC = pda.cartridge.radio
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
				mulebotsData[++mulebotsData.len] = list("Name" = sanitize(B.name), "Location" = sanitize(B.loc.loc.name), "ref" = "\ref[B]")

		if(!mulebotsData.len)
			mulebotsData[++mulebotsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "ref"= null)

		muleData["bots"] = mulebotsData
		muleData["count"] = mulebotsCount

	else
		muleData["botstatus"] =  list("loca" = null, "mode" = -1,"home"=null,"powr" = null,"retn" =null, "pick"=null, "load" = null, "dest" = null)
		muleData["active"] = 0
		mulebotsData[++mulebotsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "ref"= null)
		muleData["bots"] = mulebotsData
		muleData["count"] = 0
		has_back = 0

	data["mulebot"] = muleData

/datum/data/pda/app/mule_control/Topic(href, list/href_list)
	switch(href_list["choice"])
		if("Back")
			if(pda.cartridge && istype(pda.cartridge.radio, /obj/item/radio/integrated/mule))
				pda.cartridge.radio.Topic(null, list(radiomenu = "1", op = "botlist"))

/datum/data/pda/app/supply
	name = "Supply Records"
	icon = "file-text-o"
	template = "pda_supply"
	category = "Quartermaster"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/supply/update_ui(mob/user as mob, list/data)
	var/supplyData[0]

	if(shuttle_master.supply.mode == SHUTTLE_CALL)
		supplyData["shuttle_moving"] = 1

	// TODO: Tie into space manager
	if(shuttle_master.supply.z != ZLEVEL_STATION)
		supplyData["shuttle_loc"] = "station"
	else
		supplyData["shuttle_loc"] = "centcom"

	supplyData["shuttle_time"] = "([shuttle_master.supply.timeLeft(600)] Mins)"

	var/supplyOrderCount = 0
	var/supplyOrderData[0]
	for(var/S in shuttle_master.shoppinglist)
		var/datum/supply_order/SO = S
		supplyOrderCount++
		supplyOrderData[++supplyOrderData.len] = list("Number" = SO.ordernum, "Name" = html_encode(SO.object.name), "ApprovedBy" = SO.orderedby, "Comment" = html_encode(SO.comment))

	if(!supplyOrderData.len)
		supplyOrderData[++supplyOrderData.len] = list("Number" = null, "Name" = null, "OrderedBy"=null)

	supplyData["approved"] = supplyOrderData
	supplyData["approved_count"] = supplyOrderCount

	var/requestCount = 0
	var/requestData[0]
	for(var/S in shuttle_master.requestlist)
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
	icon = "trash-o"
	template = "pda_janitor"
	category = "Utilities"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/janitor/update_ui(mob/user as mob, list/data)
	var/JaniData[0]
	var/turf/cl = get_turf(pda)

	if(cl)
		JaniData["user_loc"] = list("x" = cl.x, "y" = cl.y)
	else
		JaniData["user_loc"] = list("x" = 0, "y" = 0)
	var/MopData[0]
	for(var/obj/item/weapon/mop/M in janitorial_equipment)
		var/turf/ml = get_turf(M)
		if(ml)
			if(ml.z != cl.z)
				continue
			var/direction = get_dir(pda, M)
			MopData[++MopData.len] = list ("x" = ml.x, "y" = ml.y, "dir" = uppertext(dir2text(direction)), "status" = M.reagents.total_volume ? "Wet" : "Dry")

	if(!MopData.len)
		MopData[++MopData.len] = list("x" = 0, "y" = 0, dir=null, status = null)


	var/BucketData[0]
	for(var/obj/structure/mopbucket/B in janitorial_equipment)
		var/turf/bl = get_turf(B)
		if(bl)
			if(bl.z != cl.z)
				continue
			var/direction = get_dir(pda,B)
			BucketData[++BucketData.len] = list ("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.reagents.total_volume/100)

	if(!BucketData.len)
		BucketData[++BucketData.len] = list("x" = 0, "y" = 0, dir=null, status = null)

	var/CbotData[0]
	for(var/mob/living/simple_animal/bot/cleanbot/B in simple_animal_list)
		var/turf/bl = get_turf(B)
		if(bl)
			if(bl.z != cl.z)
				continue
			var/direction = get_dir(pda,B)
			CbotData[++CbotData.len] = list("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.on ? "Online" : "Offline")


	if(!CbotData.len)
		CbotData[++CbotData.len] = list("x" = 0, "y" = 0, dir=null, status = null)
	var/CartData[0]
	for(var/obj/structure/janitorialcart/B in janitorial_equipment)
		var/turf/bl = get_turf(B)
		if(bl)
			if(bl.z != cl.z)
				continue
			var/direction = get_dir(pda,B)
			CartData[++CartData.len] = list("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.reagents.total_volume/100)
	if(!CartData.len)
		CartData[++CartData.len] = list("x" = 0, "y" = 0, dir=null, status = null)

	JaniData["mops"] = MopData
	JaniData["buckets"] = BucketData
	JaniData["cleanbots"] = CbotData
	JaniData["carts"] = CartData
	data["janitor"] = JaniData

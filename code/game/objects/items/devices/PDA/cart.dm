/obj/item/weapon/cartridge
	name = "generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = 1

	var/obj/item/radio/integrated/radio = null
	var/access_security = 0
	var/access_engine = 0
	var/access_atmos = 0
	var/access_medical = 0
	var/access_clown = 0
	var/access_mime = 0
	var/access_janitor = 0
//	var/access_flora = 0
	var/access_reagent_scanner = 0
	var/access_remote_door = 0 // Control some blast doors remotely!!
	var/remote_door_id = ""
	var/access_status_display = 0
	var/access_quartermaster = 0
	var/access_detonate_pda = 0
	var/access_hydroponics = 0
	var/charges = 0
	var/mode = null
	var/menu
	var/datum/data/record/active1 = null //General
	var/datum/data/record/active2 = null //Medical
	var/datum/data/record/active3 = null //Security
	var/obj/machinery/computer/monitor/powmonitor = null // Power Monitor
	var/list/powermonitors = list()
	var/message1	// used for status_displays
	var/message2
	var/list/stored_data = list()

/obj/item/weapon/cartridge/engineering
	name = "Power-ON Cartridge"
	icon_state = "cart-e"
	access_engine = 1

/obj/item/weapon/cartridge/atmos
	name = "BreatheDeep Cartridge"
	icon_state = "cart-a"
	access_atmos = 1

/obj/item/weapon/cartridge/medical
	name = "Med-U Cartridge"
	icon_state = "cart-m"
	access_medical = 1

/obj/item/weapon/cartridge/chemistry
	name = "ChemWhiz Cartridge"
	icon_state = "cart-chem"
	access_reagent_scanner = 1

/obj/item/weapon/cartridge/security
	name = "R.O.B.U.S.T. Cartridge"
	icon_state = "cart-s"
	access_security = 1

/obj/item/weapon/cartridge/security/initialize()
	radio = new /obj/item/radio/integrated/beepsky(src)
	..()

/obj/item/weapon/cartridge/detective
	name = "D.E.T.E.C.T. Cartridge"
	icon_state = "cart-s"
	access_security = 1
	access_medical = 1


/obj/item/weapon/cartridge/janitor
	name = "CustodiPRO Cartridge"
	desc = "The ultimate in clean-room design."
	icon_state = "cart-j"
	access_janitor = 1

/obj/item/weapon/cartridge/lawyer
	name = "P.R.O.V.E. Cartridge"
	icon_state = "cart-s"
	access_security = 1

/obj/item/weapon/cartridge/clown
	name = "Honkworks 5.0"
	icon_state = "cart-clown"
	access_clown = 1
	charges = 5

/obj/item/weapon/cartridge/mime
	name = "Gestur-O 1000"
	icon_state = "cart-mi"
	access_mime = 1
	charges = 5
/*
/obj/item/weapon/cartridge/botanist
	name = "Green Thumb v4.20"
	icon_state = "cart-b"
	access_flora = 1
*/

/obj/item/weapon/cartridge/signal
	name = "generic signaler cartridge"
	desc = "A data cartridge with an integrated radio signaler module."

/obj/item/weapon/cartridge/signal/toxins
	name = "Signal Ace 2"
	desc = "Complete with integrated radio signaler!"
	icon_state = "cart-tox"
	access_reagent_scanner = 1
	access_atmos = 1

/obj/item/weapon/cartridge/signal/initialize()
	radio = new /obj/item/radio/integrated/signal(src)
	..()

/obj/item/weapon/cartridge/quartermaster
	name = "Space Parts & Space Vendors Cartridge"
	desc = "Perfect for the Quartermaster on the go!"
	icon_state = "cart-q"
	access_quartermaster = 1

/obj/item/weapon/cartridge/quartermaster/initialize()
	radio = new /obj/item/radio/integrated/mule(src)
	..()

/obj/item/weapon/cartridge/head
	name = "Easy-Record DELUXE"
	icon_state = "cart-h"
	access_status_display = 1

/obj/item/weapon/cartridge/hop
	name = "HumanResources9001"
	icon_state = "cart-h"
	access_status_display = 1
	access_quartermaster = 1
	access_janitor = 1
	access_security = 1

/obj/item/weapon/cartridge/hop/initialize()
	radio = new /obj/item/radio/integrated/mule(src)
	..()

/obj/item/weapon/cartridge/hos
	name = "R.O.B.U.S.T. DELUXE"
	icon_state = "cart-hos"
	access_status_display = 1
	access_security = 1

/obj/item/weapon/cartridge/hos/initialize()
	radio = new /obj/item/radio/integrated/beepsky(src)
	..()

/obj/item/weapon/cartridge/ce
	name = "Power-On DELUXE"
	icon_state = "cart-ce"
	access_status_display = 1
	access_engine = 1
	access_atmos = 1

/obj/item/weapon/cartridge/cmo
	name = "Med-U DELUXE"
	icon_state = "cart-cmo"
	access_status_display = 1
	access_reagent_scanner = 1
	access_medical = 1

/obj/item/weapon/cartridge/rd
	name = "Signal Ace DELUXE"
	icon_state = "cart-rd"
	access_status_display = 1
	access_reagent_scanner = 1
	access_atmos = 1

/obj/item/weapon/cartridge/rd/initialize()
	radio = new /obj/item/radio/integrated/signal(src)
	..()		

/obj/item/weapon/cartridge/captain
	name = "Value-PAK Cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	access_quartermaster = 1
	access_janitor = 1
	access_engine = 1
	access_security = 1
	access_medical = 1
	access_reagent_scanner = 1
	access_status_display = 1
	access_atmos = 1

/obj/item/weapon/cartridge/captain/initialize()
	radio = new /obj/item/radio/integrated/beepsky(src)
	..()		

/obj/item/weapon/cartridge/supervisor
	name = "Easy-Record DELUXE"
	icon_state = "cart-h"
	access_status_display = 1
	access_security = 1

/obj/item/weapon/cartridge/centcom
	name = "Value-PAK Cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	access_quartermaster = 1
	access_janitor = 1
	access_engine = 1
	access_security = 1
	access_medical = 1
	access_reagent_scanner = 1
	access_status_display = 1
	access_atmos = 1

/obj/item/weapon/cartridge/centcom/initialize()
	radio = new /obj/item/radio/integrated/beepsky(src)
	..()

/obj/item/weapon/cartridge/syndicate
	name = "Detomatix Cartridge"
	icon_state = "cart"
	access_remote_door = 1
	access_detonate_pda = 1
	remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!	//don't ask about the name, testing.
	charges = 4

/obj/item/weapon/cartridge/proc/post_status(var/command, var/data1, var/data2)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)
	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			if(loc)
				var/obj/item/PDA = loc
				var/mob/user = PDA.fingerprintslast
				if(istype(PDA.loc,/mob/living))
					name = PDA.loc
				log_admin("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")
				message_admins("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")

		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)


/*
	This generates the nano values of the cart menus.
	Because we close the UI when we insert a new cart
	we don't have to worry about null values on items
	the user can't access.  Well, unless they are href hacking.
	But in that case their UI will just lock up.
*/


/obj/item/weapon/cartridge/proc/create_NanoUI_values(mob/user as mob)
	var/values[0]

	/*		Signaler (Mode: 40)				*/


	if(istype(radio,/obj/item/radio/integrated/signal) && (mode==40))
		var/obj/item/radio/integrated/signal/R = radio
		values["signal_freq"] = format_frequency(R.frequency)
		values["signal_code"] = R.code


	/*		Station Display (Mode: 42)			*/

	if(mode==42)
		values["message1"] = message1 ? message1 : "(none)"
		values["message2"] = message2 ? message2 : "(none)"



	/*		Power Monitor (Mode: 43 / 433)			*/
	if(mode==43 || mode==433)						
		values["powermonitors"] = powermonitor_repository.powermonitor_data()

		if (powmonitor && !isnull(powmonitor.powernet))
			values["powerconnected"] = 1
			values["poweravail"] = powmonitor.powernet.avail
			values["powerload"] = num2text(powmonitor.powernet.viewload,10)
			values["powerdemand"] = powmonitor.powernet.load
			values["apcs"] = apc_repository.apc_data(powmonitor)
		else
			values["powerconnected"] = 0





	/*		General Records (Mode: 44 / 441 / 45 / 451)	*/
	if(mode == 44 || mode == 441 || mode == 45 || mode ==451)
		if(istype(active1, /datum/data/record) && (active1 in data_core.general))
			values["general"] = active1.fields
			values["general_exists"] = 1

		else

			values["general_exists"] = 0



	/*		Medical Records (Mode: 44 / 441)	*/

	if(mode == 44 || mode == 441)
		var/medData[0]
		for(var/datum/data/record/R in sortRecord(data_core.general))
			medData[++medData.len] = list(Name = R.fields["name"],"ref" = "\ref[R]")
		values["medical_records"] = medData

		if(istype(active2, /datum/data/record) && (active2 in data_core.medical))
			values["medical"] = active2.fields
			values["medical_exists"] = 1
		else
			values["medical_exists"] = 0

	/*		Security Records (Mode:45 / 451)	*/

	if(mode == 45 || mode == 451)
		var/secData[0]
		for (var/datum/data/record/R in sortRecord(data_core.general))
			secData[++secData.len] = list(Name = R.fields["name"], "ref" = "\ref[R]")
		values["security_records"] = secData

		if(istype(active3, /datum/data/record) && (active3 in data_core.security))
			values["security"] = active3.fields
			values["security_exists"] = 1
		else
			values["security_exists"] = 0

	/*		Security Bot Control (Mode: 46)		*/

	if(mode==46)
		var/botsData[0]
		var/beepskyData[0]
		if(istype(radio,/obj/item/radio/integrated/beepsky))
			var/obj/item/radio/integrated/beepsky/SC = radio
			beepskyData["active"] = SC.active
			if(SC.active && !isnull(SC.botstatus))
				var/area/loca = SC.botstatus["loca"]
				var/loca_name = sanitize(loca.name)
				beepskyData["botstatus"] = list("loca" = loca_name, "mode" = SC.botstatus["mode"])
			else
				beepskyData["botstatus"] = list("loca" = null, "mode" = -1)
			var/botsCount=0
			if(SC.botlist && SC.botlist.len)
				for(var/obj/machinery/bot/B in SC.botlist)
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

		values["beepsky"] = beepskyData


	/*		MULEBOT Control	(Mode: 48)		*/

	if(mode==48)
		var/muleData[0]
		var/mulebotsData[0]
		if(istype(radio,/obj/item/radio/integrated/mule))
			var/obj/item/radio/integrated/mule/QC = radio
			muleData["active"] = QC.active
			if(QC.active && !isnull(QC.botstatus))
				var/area/loca = QC.botstatus["loca"]
				var/loca_name = sanitize(loca.name)
				muleData["botstatus"] =  list("loca" = loca_name, "mode" = QC.botstatus["mode"],"home"=QC.botstatus["home"],"powr" = QC.botstatus["powr"],"retn" =QC.botstatus["retn"], "pick"=QC.botstatus["pick"], "load" = QC.botstatus["load"], "dest" = sanitize(QC.botstatus["dest"]))

			else
				muleData["botstatus"] = list("loca" = null, "mode" = -1,"home"=null,"powr" = null,"retn" =null, "pick"=null, "load" = null, "dest" = null)


			var/mulebotsCount=0
			for(var/obj/machinery/bot/B in QC.botlist)
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

		values["mulebot"] = muleData



	/*	Supply Shuttle Requests Menu (Mode: 47)		*/

	if(mode==47)
		var/supplyData[0]
		var/datum/shuttle/ferry/supply/shuttle = supply_controller.shuttle
		if (shuttle)
			supplyData["shuttle_moving"] = shuttle.has_arrive_time()
			supplyData["shuttle_eta"] = shuttle.eta_minutes()
			supplyData["shuttle_loc"] = shuttle.at_station() ? "Station" : "Dock"
		var/supplyOrderCount = 0
		var/supplyOrderData[0]
		for(var/S in supply_controller.shoppinglist)
			var/datum/supply_order/SO = S

			supplyOrderData[++supplyOrderData.len] = list("Number" = SO.ordernum, "Name" = html_encode(SO.object.name), "ApprovedBy" = SO.orderedby, "Comment" = html_encode(SO.comment))
		if(!supplyOrderData.len)
			supplyOrderData[++supplyOrderData.len] = list("Number" = null, "Name" = null, "OrderedBy"=null)

		supplyData["approved"] = supplyOrderData
		supplyData["approved_count"] = supplyOrderCount

		var/requestCount = 0
		var/requestData[0]
		for(var/S in supply_controller.requestlist)
			var/datum/supply_order/SO = S
			requestCount++
			requestData[++requestData.len] = list("Number" = SO.ordernum, "Name" = html_encode(SO.object.name), "OrderedBy" = SO.orderedby, "Comment" = html_encode(SO.comment))
		if(!requestData.len)
			requestData[++requestData.len] = list("Number" = null, "Name" = null, "orderedBy" = null, "Comment" = null)

		supplyData["requests"] = requestData
		supplyData["requests_count"] = requestCount


		values["supply"] = supplyData



	/* 	Janitor Supplies Locator  (Mode: 49)      */
	if(mode==49)
		var/JaniData[0]
		var/turf/cl = get_turf(src)

		if(cl)
			JaniData["user_loc"] = list("x" = cl.x, "y" = cl.y)
		else
			JaniData["user_loc"] = list("x" = 0, "y" = 0)
		var/MopData[0]
		for(var/obj/item/weapon/mop/M in world)
			var/turf/ml = get_turf(M)
			if(ml)
				if(ml.z != cl.z)
					continue
				var/direction = get_dir(src, M)
				MopData[++MopData.len] = list ("x" = ml.x, "y" = ml.y, "dir" = uppertext(dir2text(direction)), "status" = M.reagents.total_volume ? "Wet" : "Dry")

		if(!MopData.len)
			MopData[++MopData.len] = list("x" = 0, "y" = 0, dir=null, status = null)


		var/BucketData[0]
		for(var/obj/structure/mopbucket/B in world)
			var/turf/bl = get_turf(B)
			if(bl)
				if(bl.z != cl.z)
					continue
				var/direction = get_dir(src,B)
				BucketData[++BucketData.len] = list ("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.reagents.total_volume/100)

		if(!BucketData.len)
			BucketData[++BucketData.len] = list("x" = 0, "y" = 0, dir=null, status = null)

		var/CbotData[0]
		for(var/obj/machinery/bot/cleanbot/B in world)
			var/turf/bl = get_turf(B)
			if(bl)
				if(bl.z != cl.z)
					continue
				var/direction = get_dir(src,B)
				CbotData[++CbotData.len] = list("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.on ? "Online" : "Offline")


		if(!CbotData.len)
			CbotData[++CbotData.len] = list("x" = 0, "y" = 0, dir=null, status = null)
		var/CartData[0]
		for(var/obj/structure/stool/bed/chair/cart/janicart/B in world)
			var/turf/bl = get_turf(B)
			if(bl)
				if(bl.z != cl.z)
					continue
				var/direction = get_dir(src,B)
				CartData[++CartData.len] = list("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.reagents.total_volume/100)
		if(!CartData.len)
			CartData[++CartData.len] = list("x" = 0, "y" = 0, dir=null, status = null)




		JaniData["mops"] = MopData
		JaniData["buckets"] = BucketData
		JaniData["cleanbots"] = CbotData
		JaniData["carts"] = CartData
		values["janitor"] = JaniData

	return values





/obj/item/weapon/cartridge/Topic(href, href_list)
	..()

	if (!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr.unset_machine()
		usr << browse(null, "window=pda")
		return




	switch(href_list["choice"])
		if("Medical Records")
			var/datum/data/record/R = locate(href_list["target"])
			var/datum/data/record/M = locate(href_list["target"])
			loc:mode = 441
			mode = 441
			if (R in data_core.general)
				for (var/datum/data/record/E in data_core.medical)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						M = E
						break
				active1 = R
				active2 = M

		if("Security Records")
			var/datum/data/record/R = locate(href_list["target"])
			var/datum/data/record/S = locate(href_list["target"])
			loc:mode = 451
			mode = 451
			if (R in data_core.general)
				for (var/datum/data/record/E in data_core.security)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						S = E
						break
				active1 = R
				active3 = S

		if("Send Signal")
			spawn( 0 )
				radio:send_signal("ACTIVATE")
				return

		if("Signal Frequency")
			var/new_frequency = sanitize_frequency(radio:frequency + text2num(href_list["sfreq"]))
			radio:set_frequency(new_frequency)

		if("Signal Code")
			radio:code += text2num(href_list["scode"])
			radio:code = round(radio:code)
			radio:code = min(100, radio:code)
			radio:code = max(1, radio:code)

		if("Status")
			switch(href_list["statdisp"])
				if("message")
					post_status("message", message1, message2)
				if("alert")
					post_status("alert", href_list["alert"])
				if("setmsg1")
					message1 = input("Line 1", "Enter Message Text", message1) as text|null
					updateSelfDialog()
				if("setmsg2")
					message2 = input("Line 2", "Enter Message Text", message2) as text|null
					updateSelfDialog()
				else
					post_status(href_list["statdisp"])
		if("Power Select")
			var/pref = href_list["target"]
			powmonitor = locate(pref)
			loc:mode = 433
			mode = 433

	return 1

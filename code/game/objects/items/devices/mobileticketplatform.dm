
/obj/item/device/ticket_machine
	name = "handheld ticket dispenser"
	desc = "A device that allows for security personnel to issue tickes for violation of Space Law."
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT

	var/ticketreason = null
	var/ticketamount = null
	var/ticketdescription = null
	var/screen = 0
	var/ticketid = null

	var/obj/item/weapon/card/id/ID
	var/datum/money_account/linked_account
	var/datum/money_account/D
	var/datum/spacelaw/selecteddatum
	var/datum/spacelaw/C

	var/list/committedcrimes = list()
	var/printing = 0
	req_access = list(access_brig)

obj/item/device/ticket_machine/New()
	..()
	linked_account = department_accounts["Security"]

/obj/item/device/ticket_machine/proc/reset() //Reset the device
	ticketamount = null
	ID = null
	ticketreason = null
	ticketdescription = null
	ticketid = null
	screen = 0
	printing = 0

/obj/item/device/ticket_machine/attackby(obj/O, mob/user, params) //Get credentials
	if(istype(O, /obj/item/weapon/card/id))
		visible_message("<span class='info'>[user] swipes a card through [src].</span>")
		if(ID)
			to_chat(user, "<span class='warning'>Identification Card already scanned!</span>")
		else
			ID = O
			D = get_money_account(ID.associated_account_number)
			to_chat(user, "<span class='warning'>Identification Card scanned!</span>")

///////////////////////////////////////////////////////PAYMENT/////////////////////////////////////////////////

/obj/item/device/ticket_machine/proc/pay_ticket(mob/user)
	printing = 1
	screen = 4
	sleep(50)
	if(linked_account)
		if(ticketamount <= D.money)
			playsound(src, 'sound/machines/chime.ogg', 50, 1)
			visible_message("[bicon(src)] The [src] chimes.")
			D.money -= ticketamount
			linked_account.money += ticketamount

			var/datum/transaction/T = new()
			T.target_name = "[linked_account.owner_name]"
			T.purpose = "[ticketreason]"
			T.amount = "[ticketamount]"
			T.source_terminal = src
			T.date = current_date_string
			T.time = worldtime2text()
			D.transaction_log.Add(T)

			T = new()
			T.target_name = D.owner_name
			T.purpose = "[ticketreason]"
			T.amount = "[ticketamount]"
			T.source_terminal = src
			T.date = current_date_string
			T.time = worldtime2text()
			linked_account.transaction_log.Add(T)
			print_ticket(usr)
		else
			to_chat(user, "<span class='warning'>Unable to process requests. User account contains insuffecient funds. Incarceration is suggested.</span>")
			reset()
	else
		to_chat(user, "<span class='warning'>Unable to access account. Check security settings and try again.</span>")
	screen = 0
///////////////////////////////////////////////////////TICKETS AND CHARGES/////////////////////////////////////////////////

/obj/item/device/ticket_machine/proc/clearstringandtime()
	ticketreason = ""//Empty the string list so we can fill it again
	ticketamount = 0
	ticketdescription = ""

	for(C in committedcrimes)
		ticketreason += "#[C.name], "
		ticketamount += C.max_fine
		ticketdescription += "[C.reason], "

/obj/item/device/ticket_machine/proc/print_ticket(mob/user) // Ticket Reciepts
		var/ticketid = rand(1111,9999)
		var/entry = {"<center><h3>Infringement Notice #[ticketid]<br></h3></center><small><b>Issued to:	</b>[ID.registered_name]<br><b>Rank:	</b>[ID.rank] <br><b>Issued at:	</b> [worldtime2text()]<br>
					 <b>Charged with:	</b>[ticketreason]<br><b>Reason for the ticket:	</b>[ticketdescription]<br><b>Ticket Amount (Cr):	</b>[ticketamount]<br><b>Issuing Officer:</b>	[usr]</small>"}
		to_chat(user, "Printing the log, standby...")
		spawn(50)
		playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)

		var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
		P.name = "Ticket [ticketid] - [ID.registered_name] at: [worldtime2text()]"
		P.info += {"<center>[station_name()] - Security Department</center>
				[entry]
				"}
		user.put_in_hands(P)
		ticket_logs.Add(P)
		reset()

/obj/item/device/ticket_machine/proc/add_charge(mob/user)

	switch(alert("Select Action to Proceed.", "Space Law", "Custom Crime", "Minor Crimes", "Abort"))
		if("Abort")
			return

		if("Custom Crime")
			selecteddatum = new /datum/spacelaw
			selecteddatum.name = input(user, "Please select custom article to add for [ID.registered_name]") as null|text

			if(selecteddatum.name)
				selecteddatum.max_fine = input(user, "Please select amount to the fine for [ID.registered_name]. Current fine is [ticketamount].") as num
			else
				return

			if(selecteddatum.max_fine >= 0)
				selecteddatum.reason = stripped_multiline_input(user, "Please state the reason for the ticket for [ID.registered_name]")
			else
				to_chat(user,"<span class='warning'>Fine cannot be lower than 0!</span>")
				return

		if("Minor Crimes")
			selecteddatum = new /datum/spacelaw/minor
			selecteddatum.name = input(user, "Please select custom article to add for [ID.registered_name]") as null|anything in selecteddatum.listofcrimes
			selecteddatum.reason = input(user, "Please state the reason for the ticket for [ID.registered_name]") as null|text

	if(!selecteddatum.name)
		return
	else
		committedcrimes.Add(selecteddatum)
		clearstringandtime()
		return 1

/obj/item/device/ticket_machine/proc/remove_charge(mob/user)
	if(committedcrimes.len)
		var/datum/spacelaw/removecrime = input(usr, "Please select charge to remove for [ID.registered_name]") as null|anything in committedcrimes
		if(isnull(removecrime))
			to_chat(user,"<span class='warning'>Please select a proper charge to remove!</span>")
			return
		else
			committedcrimes -= removecrime
			clearstringandtime()
	else
		to_chat(user,"<span class='warning'>No charges to remove!</span>")

///////////////////////////////////////////////////////UI/////////////////////////////////////////////////

/obj/item/device/ticket_machine/attack_self(var/mob/user)
	if(..())
		return

	if(is_away_level(z))
		to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
		return

	add_fingerprint(user)
	user.set_machine(src)
	interact(user)

/obj/item/device/ticket_machine/interact(mob/user as mob)
	var/dat

	if(screen == 0)
		dat = {"<h1>Please select option:</h1><br>
				<h2><a href='?src=[UID()];screen=1'>View Issued Tickets</a><h2>
				<h2><a href='?src=[UID()];screen=2'>Issue Ticket</a><h2>"}

	if(screen == 1)
		dat = "<center><h1>Issued Ticket(s):</h1></center>"
		for(var/obj/item/weapon/paper/P in ticket_logs)
			if(ticket_logs.len)
				dat += "[P.info]<hr>"
			else
				dat += "<h2>No issued tickets.</h2>"
		dat += "<b>Menu:</b>"
		dat += "<br><a href='?src=[UID()];screen=0'>Back</a><br>"

	if(screen == 2)
		if(!ID)
			dat = {"<h1>Please swipe the ID of the detainee to begin ticketing.</h1><br>
					<h2><a href='?src=[UID()];screen=2'>Refresh</a><h2>
					<a href='?src=[UID()];screen=0'>Back</a><br>"}
		else
			dat = {"<center><h3>Mobile Ticketing Platform v.1.062</h3><h1><br>Identification Field:</h1></center>
					<b>Name:	</b><i>[ID.registered_name]</i><br><b>Rank:	</b><i>[ID.rank]</i><br><b>Account number:	</b><i>[ID.associated_account_number]</i><br>
					<center><h1>Information Field:</h1></center>
					<b>Charged with violation of:	</b><i>[ticketreason]</i><br>
					<b>Charged with amount of (Cr):	</b><i>[ticketamount]</i><br>
					<b>Reason for the ticket:	</b><i>[ticketdescription]</i><br>
					<b>Issuing Officer:	</b>[usr]
					<hr><b>Menu:</b><br>
					<a href='?src=[UID()];action=addcharge'>Add Charge</a><br>
					<a href='?src=[UID()];action=removecharge'>Remove Charge</a><br>
					<h1><a href='?src=[UID()];action=printticket'>Authorize Ticket</a></h1>
					<br><a href='?src=[UID()];action=abort'>Abort</a>
					<br><a href='?src=[UID()];screen=0'>Back</a><br>"}

	if(screen == 4)
		dat = "<h1>Processing Request Standby...</h1>"

	var/datum/browser/popup = new(user, "menu", name, 400, 400)
	popup.set_content(dat)
	popup.open()
	onclose(user, "menu")

/obj/item/device/ticket_machine/Topic(href, href_list) //Button actions
	..()
	if(!allowed(usr) && !usr.can_admin_interact())
		return 1

	if(href_list["screen"])
		screen = text2num(href_list["screen"])

	if(href_list["action"])
		switch(href_list["action"])
			if("printticket")
				if(ID && ticketreason && ticketamount)
					if(!printing)
						pay_ticket(usr)	//Payment of tickets
					else
						to_chat(usr,"<span class='warning'>[src] is already processing, please wait!</span>")
				else
					to_chat(usr, "<span class='warning'>Cannot issue ticket without all credentials!</span>")
			if("addcharge")
				add_charge(usr)
			if("removecharge")
				remove_charge(usr)
			if("abort")
				reset()
	if(usr)
		attack_self(usr)
	return
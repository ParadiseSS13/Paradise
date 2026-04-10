#define CRIME_100 250
#define CRIME_200 500

/obj/item/fine_scanner
	name = "fine scanner"
	desc = "Swipe an ID card to issue a fine."
	icon = 'icons/obj/device.dmi'
	icon_state = "fine_scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 300, MAT_GLASS = 140)
	new_attack_chain = TRUE
	/// Built in radio used to message about crime
	var/obj/item/radio/Radio
	/// The selected crime setting
	var/crime_setting = CRIME_100
	/// linked money account database to this scanner. Usually the station database
	var/datum/money_account_database/main_station/account_database
	/// The linked account. This will usually be security unless admins tinker
	var/linked_account
	/// The sound the machine makes on a success
	var/fine_sound = 'sound/machines/chime.ogg'
	/// The sound the machine makes on a fail
	var/fail_sound = 'sound/machines/synth_no.ogg'

/obj/item/fine_scanner/Initialize(mapload)
	. = ..()
	account_database = GLOB.station_money_database
	linked_account = account_database.get_account_by_department(DEPARTMENT_SECURITY)
	Radio = new /obj/item/radio(src)
	Radio.listening = FALSE
	Radio.config(list("Security" = 0))
	Radio.follow_target = src

/obj/item/fine_scanner/Destroy()
	linked_account = null
	return ..()

/obj/item/fine_scanner/activate_self(mob/user)
	. = ..()
	var/selection = tgui_input_list(user, "Please select a crime tier:", "Select Crime Tier", list("Minor: 100", "Medium: 200"), "100")
	if(!Adjacent(user))
		return
	if(!selection)
		return
	switch(selection)
		if("Minor: 100")
			crime_setting = CRIME_100
		if("Medium: 200")
			crime_setting = CRIME_200

/obj/item/fine_scanner/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ..()
	if(istype(used, /obj/item/card/id))
		var/crime_string = tgui_input_text(user, "Enter the crime being fined for.", "Issue Fine")
		if(!Adjacent(user))
			return
		if(!account_database)
			account_database = GLOB.station_money_database
			linked_account = account_database.get_account_by_department(DEPARTMENT_SECURITY)
		// Needs to ensure it actually is connected, in case there is no database.
		if(account_database)
			linked_account = account_database.get_account_by_department(DEPARTMENT_SECURITY)
			issue_fine(user, used, crime_string)

/obj/item/fine_scanner/proc/issue_fine(mob/living/user, obj/item/card/id/C, crime_string)
	if(!crime_string || crime_string == "")
		crime_string = "(NO CRIME LISTED.)"
	visible_message(SPAN_NOTICE("[user] swipes a card through [src]."))
	var/datum/money_account/D = GLOB.station_money_database.find_user_account(C.associated_account_number, include_departments = FALSE)
	if(!D)
		visible_message("[bicon(src)][SPAN_WARNING("[src] buzzes as its display flashes \"Invalid Account Link.\"")]", SPAN_NOTICE("You hear something buzz."))
		playsound(src, fail_sound, 50, TRUE)
		return
	if(!GLOB.station_money_database.charge_account(D, crime_setting, "Security Fine", user.name, FALSE, FALSE))
		visible_message("[bicon(src)][SPAN_WARNING("[src] buzzes as its display flashes \"Insufficient funds.\"")]", SPAN_NOTICE("You hear something buzz."))
		playsound(src, fail_sound, 50, TRUE)
		return
	GLOB.station_money_database.credit_account(linked_account, crime_setting, "Security Fine", user.name, FALSE)
	playsound(src, fine_sound, 50, TRUE)
	Radio.autosay("<b>[C.registered_name] has paid a fine of [crime_setting] for the crime of [crime_string]. Fine issued by [user.name].</b>", "Automatic Fine System", "Security")
	print_report(user, C, crime_string)

/obj/item/fine_scanner/proc/print_report(mob/living/user, obj/item/card/id/card, crime_string)
	for(var/obj/machinery/computer/prisoner/C in GLOB.prisoncomputer_list)
		var/obj/item/paper/P = new /obj/item/paper(C.loc)
		P.name = "Fine log - [card.registered_name] [station_time_timestamp()]"
		P.info =  "<center><b>Fine record</b></center><br><hr><br>"
		P.info += {"<center>[station_name()] - Security Department</center><br>
					<center><small><b>Admission data:</b></small></center><br>
					<small><b>Log generated at:</b>		[station_time_timestamp()]<br>
					<b>Detainee:</b>		[card.registered_name]<br>
					<b>Fine Amount:</b>		[crime_setting]<br>
					<b>Charge(s):</b>	[crime_string]<br>
					<b>Arresting Officer:</b>		[user.name]<br><hr><br>
					<small>This log file was generated automatically upon activation of a fine scanner.</small>"}
		playsound(C.loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)

	var/obj/item/paper/P = new /obj/item/paper(src)
	P.name = "Fine ticket - [card.registered_name] [station_time_timestamp()]"
	P.info =  "<center><b>Fine record</b></center><br><hr><br>"
	P.info += {"<center>[station_name()] - Security Department</center><br>
				<center><small><b>Admission data:</b></small></center><br>
				<small><b>Log generated at:</b>		[station_time_timestamp()]<br>
				<b>Detainee:</b>		[card.registered_name]<br>
				<b>Fine Amount:</b>		[crime_setting]<br>
				<b>Charge(s):</b>	[crime_string]<br>
				<b>Arresting Officer:</b>		[user.name]<br><hr><br>
				<small>This log file was generated automatically upon activation of a fine scanner.</small>"}
	playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
	user.put_in_hands(P)

#undef CRIME_100
#undef CRIME_200

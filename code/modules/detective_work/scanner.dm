//CONTAINS: Detective's Scanner

// TODO: Split everything into easy to manage procs.

/obj/item/detective_scanner
	name = "Ручной детективный анализатор"
	desc = "Анализатор, способный выдать отчет по человеку, исходя из имени, ДНК или отпечатков пальцев."
	icon = 'icons/goonstation/objects/objects.dmi'
	icon_state = "detscanner"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "electronic"
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	origin_tech = "engineering=4;biotech=2;programming=5"
	var/scanning = FALSE
	var/list/log = list()
	actions_types = list(/datum/action/item_action/print_forensic_report, /datum/action/item_action/clear_records)

/obj/item/detective_scanner/attack_self(mob/user)
	var/search = input(user, "Введите имя, отпечатки пальцев или код ДНК.", "Найти запись", "")

	if(!search || user.stat || user.incapacitated())
		return

	search = lowertext(search) //This is here so that it doesn't run 'lowertext()' until the checks have passed.

	var/name
	var/fingerprint = "ОТПЕЧАТКИ НЕ НАЙДЕНЫ"
	var/dna = "ДНК НЕ НАЙДЕНО"

	// I really, really wish I didn't have to split this into two seperate loops. But the datacore is awful.

	for(var/record in GLOB.data_core.general) // Search in the 'general' datacore
		var/datum/data/record/S = record
		if(S && (search == lowertext(S.fields["fingerprint"]) || search == lowertext(S.fields["name"]))) // Get Fingerprint and Name
			name = S.fields["name"]
			fingerprint = S.fields["fingerprint"]
			break

	for(var/record in GLOB.data_core.medical) // Then search in the 'medical' datacore
		var/datum/data/record/M = record
		if(M && (search == lowertext(M.fields["b_dna"]) || name == M.fields["name"])) // Get Blood DNA
			dna = M.fields["b_dna"]

			if(fingerprint == "ОТПЕЧАТКИ НЕ НАЙДЕНЫ") // We have searched for DNA, and so do not have the relevant information from the fingerprint records.
				name = M.fields["name"]
				for(var/gen_record in GLOB.data_core.general)
					var/datum/data/record/S = gen_record
					if(S && (name == S.fields["name"]))
						fingerprint = S.fields["fingerprint"]
						break
			else //Eveything's been set, break the loop
				break

	if(name)
		to_chat(user, "<span class='notice'>Совпадение найдено в записях станции: <b>[name]</b></span><br>\
		<i>Отпечатки пальцев:</i><span class='notice'> [fingerprint]</span><br>\
		<i>ДНК:</i><span class='notice'> [dna]</span>")
	else
		to_chat(user, "<span class='warning'>В записях станции не найдено совпадений.</span>")

/obj/item/detective_scanner/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/print_forensic_report)
		print_scanner_report()
	else
		clear_scanner()

/obj/item/detective_scanner/proc/print_scanner_report()
	if(length(log) && !scanning)
		scanning = TRUE
		to_chat(usr, "<span class='notice'>Printing report, please wait...</span>")
		playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)

		addtimer(CALLBACK(src, .proc/make_paper, log), 10 SECONDS) // Create our paper
		log = list() // Clear the logs
		scanning = FALSE
	else
		to_chat(usr, "<span class='warning'>The scanner has no logs or is in use.</span>")

/obj/item/detective_scanner/proc/make_paper(log) // Moved to a proc because 'spawn()' is evil
	var/obj/item/paper/P = new(get_turf(src))
	P.name = "paper- 'Scanner Report'"
	P.info = "<center><font size='6'><B>Scanner Report</B></font></center><HR><BR>"
	P.info += jointext(log, "<BR>")
	P.info += "<HR><B>Notes:</B><BR>"
	P.info_links = P.info

	if(ismob(loc))
		var/mob/M = loc
		M.put_in_hands(P)
		to_chat(M, "<span class='notice'>Report printed. Log cleared.</span>")


/obj/item/detective_scanner/proc/clear_scanner()
	if(length(log) && !scanning)
		log = list()
		playsound(loc, 'sound/machines/ding.ogg', 40)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, usr, "<span class='notice'>Scanner logs cleared.</span>"), 1.5 SECONDS) //Timer so that it clears on the 'ding'
	else
		to_chat(usr, "<span class='warning'>The scanner has no logs or is in use.</span>")


/obj/item/detective_scanner/attack()
	return

/obj/item/detective_scanner/afterattack(atom/A, mob/user)
	scan(A, user)

/obj/item/detective_scanner/proc/scan(atom/scan_atom, mob/user)

	if(!scanning)
		// Can remotely scan objects and mobs.
		if(!(scan_atom in view(world.view, user)))
			return
		if(loc != user)
			return

		scanning = TRUE

		user.visible_message("[user] points [src] at [scan_atom] and performs a forensic scan.",
		"<span class='notice'>You scan [scan_atom]. The scanner is now analysing the results...</span>")


		// GATHER INFORMATION

		//Make our lists
		var/list/fingerprints = list()
		var/list/blood = list()
		var/list/fibers = list()
		var/list/reagents = list()
		var/found_spy_device = FALSE

		var/target_name = scan_atom.name

		// Start gathering

		if(length(scan_atom.blood_DNA))
			blood = scan_atom.blood_DNA.Copy()

		if(length(scan_atom.suit_fibers))
			fibers = scan_atom.suit_fibers.Copy()

		if(ishuman(scan_atom))

			var/mob/living/carbon/human/H = scan_atom
			if(istype(H.dna, /datum/dna) && !H.gloves)
				fingerprints += md5(H.dna.uni_identity)

		else if(!ismob(scan_atom))

			if(length(scan_atom.fingerprints))
				fingerprints = scan_atom.fingerprints.Copy()

			// Only get reagents from non-mobs.
			if(scan_atom.reagents && length(scan_atom.reagents.reagent_list))

				for(var/datum/reagent/R in scan_atom.reagents.reagent_list)
					reagents[R.name] = R.volume

					// Get blood data from the blood reagent.
					if(istype(R, /datum/reagent/blood))

						if(R.data["blood_DNA"] && R.data["blood_type"])
							var/blood_DNA = R.data["blood_DNA"]
							var/blood_type = R.data["blood_type"]
							blood[blood_DNA] = blood_type

			if(istype(scan_atom, /obj/item/clothing))
				var/obj/item/clothing/scanned_clothing = scan_atom
				if(scanned_clothing.spy_spider_attached)
					found_spy_device = TRUE

		// We gathered everything. Slowly display the results to the holder of the scanner.
		var/found_something = FALSE
		add_log("<B>[station_time_timestamp()][get_timestamp()] - [target_name]</B>", FALSE)

		// Fingerprints
		if(length(fingerprints))
			sleep(30)
			add_log("<span class='info'><B>Prints:</B></span>")
			for(var/finger in fingerprints)
				add_log("[finger]")
			found_something = TRUE

		// Blood
		if(length(blood))
			sleep(30)
			add_log("<span class='info'><B>Blood:</B></span>")
			found_something = TRUE
			for(var/B in blood)
				add_log("Type: <font color='red'>[blood[B]]</font> DNA: <font color='red'>[B]</font>")

		//Fibers
		if(length(fibers))
			sleep(30)
			add_log("<span class='info'><B>Fibers:</B></span>")
			for(var/fiber in fibers)
				add_log("[fiber]")
			found_something = TRUE

		//Reagents
		if(length(reagents))
			sleep(30)
			add_log("<span class='info'><B>Reagents:</B></span>")
			for(var/R in reagents)
				add_log("Reagent: <font color='red'>[R]</font> Volume: <font color='red'>[reagents[R]]</font>")
			found_something = TRUE

		if(found_spy_device)
			sleep(10)
			add_log("<span class='info'><B>Найдено шпионское устройство!</B></span>")
			if(!(/obj/item/clothing/proc/remove_spy_spider in scan_atom.verbs))
				scan_atom.verbs += /obj/item/clothing/proc/remove_spy_spider

		// Get a new user
		var/mob/holder = null
		if(ismob(loc))
			holder = loc

		if(!found_something)
			add_log("<I># No forensic traces found #</I>", FALSE) // Don't display this to the holder user
			if(holder)
				to_chat(holder, "<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on [scan_atom]!</span>")
		else
			if(holder)
				to_chat(holder, "<span class='notice'>You finish scanning [scan_atom].</span>")

		add_log("---------------------------------------------------------", FALSE)
		scanning = FALSE

/obj/item/detective_scanner/proc/add_log(msg, broadcast = TRUE)
	if(scanning)
		if(broadcast && ismob(loc))
			var/mob/M = loc
			to_chat(M, msg)
		log += "&nbsp;&nbsp;[msg]"
	else
		CRASH("[src] \ref[src] is adding a log when it was never put in scanning mode!")

/proc/get_timestamp()
	return time2text(world.time + 432000, ":ss")

//CONTAINS: Detective's Scanner

// TODO: Split everything into easy to manage procs.

/obj/item/device/detective_scanner
	name = "forensic scanner"
	desc = "Used to remotely scan objects and biomass for DNA and fingerprints. Can print a report of the findings."
	icon = 'icons/goonstation/objects/objects.dmi'
	icon_state = "detscanner"
	w_class = 3
	item_state = "electronic"
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	origin_tech = "magnets=4;biotech=2"
	var/scanning = 0
	var/list/log = list()
	actions_types = list(/datum/action/item_action/print_report)

/obj/item/device/detective_scanner/attack_self(var/mob/user)
	var/search = input(user, "Enter name, fingerprint or blood DNA.", "Find record", "")

	if(!search || user.stat || user.incapacitated())
		return

	search = lowertext(search)

	var/name
	var/fingerprint = "FINGERPRINT NOT FOUND"
	var/dna = "BLOOD DNA NOT FOUND"

	// I really, really wish I didn't have to split this into two seperate loops. But the datacore is awful.

	for(var/record in data_core.general)
		var/datum/data/record/S = record
		if(S && (search == lowertext(S.fields["fingerprint"]) || search == lowertext(S.fields["name"])))
			name = S.fields["name"]
			fingerprint = S.fields["fingerprint"]
			continue

	for(var/record in data_core.medical)
		var/datum/data/record/M = record
		if(M && ( search == lowertext(M.fields["b_dna"]) || name == M.fields["name"]) )
			dna = M.fields["b_dna"]

			if(fingerprint == "FINGERPRINT NOT FOUND") // We have searched by DNA, and do not have the relevant information from the fingerprint records.
				name = M.fields["name"]
				for(var/gen_record in data_core.general)
					var/datum/data/record/S = gen_record
					if(S && (name == S.fields["name"]))
						fingerprint = S.fields["fingerprint"]
						continue
			continue

	if(name)
		to_chat(user, "<span class='notice'>Match found in station records: <b>[name]</b></span><br>\
		<i>Fingerprint:</i><span class='notice'> [fingerprint]</span><br>\
		<i>Blood DNA:</i><span class='notice'> [dna]</span>")
		return

	to_chat(user, "<span class='warning'>No match found in station records.</span>")

/obj/item/device/detective_scanner/ui_action_click()
	print_scanner_report()

/obj/item/device/detective_scanner/proc/print_scanner_report()
	if(log.len && !scanning)
		scanning = 1
		to_chat(usr, "<span class='notice'>Printing report, please wait...</span>")
		playsound(loc, "sound/goonstation/machines/printer_thermal.ogg", 50, 1)
		spawn(100)

			// Create our paper
			var/obj/item/weapon/paper/P = new(get_turf(src))
			P.name = "paper- 'Scanner Report'"
			P.info = "<center><font size='6'><B>Scanner Report</B></font></center><HR><BR>"
			P.info += jointext(log, "<BR>")
			P.info += "<HR><B>Notes:</B><BR>"
			P.info_links = P.info

			if(ismob(loc))
				var/mob/M = loc
				M.put_in_hands(P)
				to_chat(M, "<span class='notice'>Report printed. Log cleared.<span>")

			// Clear the logs
			log = list()
			scanning = 0
	else
		to_chat(usr, "<span class='notice'>The scanner has no logs or is in use.</span>")


/obj/item/device/detective_scanner/attack(mob/living/M as mob, mob/user as mob)
	return


/obj/item/device/detective_scanner/afterattack(atom/A, mob/user as mob, proximity)
	scan(A, user)

/obj/item/device/detective_scanner/proc/scan(var/atom/A, var/mob/user)

	if(!scanning)
		// Can remotely scan objects and mobs.
		if(!in_range(A, user) && !(A in view(world.view, user)))
			return
		if(loc != user)
			return

		scanning = 1

		user.visible_message("\The [user] points the [src.name] at \the [A] and performs a forensic scan.")
		to_chat(user, "<span class='notice'>You scan \the [A]. The scanner is now analysing the results...</span>")


		// GATHER INFORMATION

		//Make our lists
		var/list/fingerprints = list()
		var/list/blood = list()
		var/list/fibers = list()
		var/list/reagents = list()

		var/target_name = A.name

		// Start gathering

		if(A.blood_DNA && A.blood_DNA.len)
			blood = A.blood_DNA.Copy()

		if(A.suit_fibers && A.suit_fibers.len)
			fibers = A.suit_fibers.Copy()

		if(ishuman(A))

			var/mob/living/carbon/human/H = A
			if(istype(H.dna, /datum/dna) && !H.gloves)
				fingerprints += md5(H.dna.uni_identity)

		else if(!ismob(A))

			if(A.fingerprints && A.fingerprints.len)
				fingerprints = A.fingerprints.Copy()

			// Only get reagents from non-mobs.
			if(A.reagents && A.reagents.reagent_list.len)

				for(var/datum/reagent/R in A.reagents.reagent_list)
					reagents[R.name] = R.volume

					// Get blood data from the blood reagent.
					if(istype(R, /datum/reagent/blood))

						if(R.data["blood_DNA"] && R.data["blood_type"])
							var/blood_DNA = R.data["blood_DNA"]
							var/blood_type = R.data["blood_type"]
							blood[blood_DNA] = blood_type

		// We gathered everything. Create a fork and slowly display the results to the holder of the scanner.

		spawn(0)

			var/found_something = 0
			add_log("<B>[worldtime2text()][get_timestamp()] - [target_name]</B>", 0)

			// Fingerprints
			if(fingerprints && fingerprints.len)
				sleep(30)
				add_log("<span class='info'><B>Prints:</B></span>")
				for(var/finger in fingerprints)
					add_log("[finger]")
				found_something = 1

			// Blood
			if(blood && blood.len)
				sleep(30)
				add_log("<span class='info'><B>Blood:</B></span>")
				found_something = 1
				for(var/B in blood)
					add_log("Type: <font color='red'>[blood[B]]</font> DNA: <font color='red'>[B]</font>")

			//Fibers
			if(fibers && fibers.len)
				sleep(30)
				add_log("<span class='info'><B>Fibers:</B></span>")
				for(var/fiber in fibers)
					add_log("[fiber]")
				found_something = 1

			//Reagents
			if(reagents && reagents.len)
				sleep(30)
				add_log("<span class='info'><B>Reagents:</B></span>")
				for(var/R in reagents)
					add_log("Reagent: <font color='red'>[R]</font> Volume: <font color='red'>[reagents[R]]</font>")
				found_something = 1

			// Get a new user
			var/mob/holder = null
			if(ismob(src.loc))
				holder = src.loc

			if(!found_something)
				add_log("<I># No forensic traces found #</I>", 0) // Don't display this to the holder user
				if(holder)
					to_chat(holder, "<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on \the [target_name]!</span>")
			else
				if(holder)
					to_chat(holder, "<span class='notice'>You finish scanning \the [target_name].</span>")

			add_log("---------------------------------------------------------", 0)
			scanning = 0
			return

/obj/item/device/detective_scanner/proc/add_log(var/msg, var/broadcast = 1)
	if(scanning)
		if(broadcast && ismob(loc))
			var/mob/M = loc
			to_chat(M, msg)
		log += "&nbsp;&nbsp;[msg]"
	else
		CRASH("[src] \ref[src] is adding a log when it was never put in scanning mode!")

/proc/get_timestamp()
	return time2text(world.time + 432000, ":ss")

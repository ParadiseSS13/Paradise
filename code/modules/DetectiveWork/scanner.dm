//CONTAINS: Detective's Scanner

// TODO: Split everything into easy to manage procs.

/obj/item/device/detective_scanner
	name = "forensic scanner"
	desc = "Used to remotely scan objects and biomass for DNA and fingerprints. Can print a report of the findings."
	icon_state = "forensic1"
	w_class = 3.0
	item_state = "electronic"
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	origin_tech = "magnets=4;biotech=2"
	var/scanning = 0
	var/list/log = list()

/obj/item/device/detective_scanner/attack_self(var/mob/user)
	if(log.len && !scanning)
		scanning = 1
		user << "<span class='notice'>Printing report, please wait...</span>"

		spawn(100)

			// Create our paper
			var/obj/item/weapon/paper/P = new(get_turf(src))
			P.name = "paper- 'Scanner Report'"
			P.info = "<center><font size='6'><B>Scanner Report</B></font></center><HR><BR>"
			P.info += list2text(log, "<BR>")
			P.info += "<HR><B>Notes:</B><BR>"
			P.info_links = P.info

			if(ismob(loc))
				var/mob/M = loc
				M.put_in_hands(P)
				M << "<span class='notice'>Report printed. Log cleared.<span>"

			// Clear the logs
			log = list()
			scanning = 0
	else
		user << "<span class='notice'>The scanner has no logs or is in use.</span>"

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
		user << "<span class='notice'>You scan \the [A]. The scanner is now analysing the results...</span>"


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
			if (istype(H.dna, /datum/dna) && !H.gloves)
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
			if (blood && blood.len)
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
					holder << "<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on \the [target_name]!</span>"
			else
				if(holder)
					holder << "<span class='notice'>You finish scanning \the [target_name].</span>"

			add_log("---------------------------------------------------------", 0)
			scanning = 0
			return

/obj/item/device/detective_scanner/proc/add_log(var/msg, var/broadcast = 1)
	if(scanning)
		if(broadcast && ismob(loc))
			var/mob/M = loc
			M << msg
		log += "&nbsp;&nbsp;[msg]"
	else
		CRASH("[src] \ref[src] is adding a log when it was never put in scanning mode!")

/proc/get_timestamp()
	return time2text(world.time + 432000, ":ss")
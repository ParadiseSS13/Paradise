/datum/data/pda/utility/flashlight
	name = "Enable Flashlight"
	icon = "lightbulb-o"

	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 2 //Luminosity for the flashlight function

/datum/data/pda/utility/flashlight/start()
	fon = !fon
	name = fon ? "Disable Flashlight" : "Enable Flashlight"
	pda.update_shortcuts()
	pda.set_light(fon ? f_lum : 0)
	pda.update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)
	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

/datum/data/pda/utility/honk
	name = "Honk Synthesizer"
	icon = "smile-o"
	category = "Clown"

	var/last_honk //Also no honk spamming that's bad too

/datum/data/pda/utility/honk/start()
	if(!(last_honk && world.time < last_honk + 20))
		playsound(pda.loc, 'sound/items/bikehorn.ogg', 50, 1)
		last_honk = world.time

/datum/data/pda/utility/toggle_door
	name = "Toggle Door"
	icon = "external-link-alt"
	var/remote_door_id = ""

/datum/data/pda/utility/toggle_door/start()
	for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
		if(M.id_tag == remote_door_id)
			if(M.density)
				M.open()
			else
				M.close()
	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

/datum/data/pda/utility/scanmode/medical
	base_name = "Med Scanner"
	icon = "heart-o"

/datum/data/pda/utility/scanmode/medical/scan_mob(mob/living/M, mob/living/user)
	user.visible_message(SPAN_NOTICE("[user] analyzes [M]'s vitals."), SPAN_NOTICE("You analyze [M]'s vitals."))

	healthscan(user, M, 1)

/datum/data/pda/utility/scanmode/dna
	base_name = "DNA Scanner"
	icon = "link"

/datum/data/pda/utility/scanmode/dna/scan_mob(mob/living/C as mob, mob/living/user as mob)
	var/list/messages = list()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!istype(H.dna, /datum/dna))
			messages.Add(SPAN_NOTICE("No fingerprints found on [H]"))
		else
			messages.Add(SPAN_NOTICE("[H]'s Fingerprints: [md5(H.dna.uni_identity)]"))
	if(length(messages))
		to_chat(user, chat_box_regular(messages.Join("<br>")))
	scan_blood(C, user)

/datum/data/pda/utility/scanmode/dna/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	scan_blood(A, user)

/datum/data/pda/utility/scanmode/dna/proc/scan_blood(atom/A, mob/user)
	var/list/messages = list()
	if(!A.blood_DNA)
		messages.Add(SPAN_NOTICE("No blood found on [A]"))
		if(A.blood_DNA)
			qdel(A.blood_DNA)
	else
		messages.Add(SPAN_NOTICE("Blood found on [A]. Analysing..."))
		spawn(15)
		for(var/blood in A.blood_DNA)
			messages.Add(SPAN_NOTICE("Blood type: [A.blood_DNA[blood]]\nDNA: [blood]"))
	to_chat(user, chat_box_regular(messages.Join("<br>")))

/datum/data/pda/utility/scanmode/rad_scanner
	base_name = "Radiation Scanner"
	icon = "exclamation-circle"

/datum/data/pda/utility/scanmode/rad_scanner/scan_mob(mob/living/C as mob, mob/living/user as mob)
	var/list/messages = list()
	C.visible_message(SPAN_WARNING("[user] has analyzed [C]'s radiation levels!"))

	messages.Add(SPAN_NOTICE("Analyzing Results for [C]:"))
	if(C.radiation)
		messages.Add(SPAN_NOTICE("Radiation Level: [C.radiation > 0 ? "</span><span class='danger'>[C.radiation]" : "0"]"))
	else
		messages.Add(SPAN_NOTICE("No radiation detected."))
	to_chat(user, chat_box_regular(messages.Join("<br>")))

/datum/data/pda/utility/scanmode/reagent
	base_name = "Reagent Scanner"
	icon = "flask"

/datum/data/pda/utility/scanmode/reagent/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	var/list/messages = list()
	if(!isnull(A.reagents))
		if(length(A.reagents.reagent_list) > 0)
			var/reagents_length = length(A.reagents.reagent_list)
			messages.Add(SPAN_NOTICE("[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found."))
			for(var/datum/reagent/R in A.reagents.reagent_list)
				if(R.id != "blood")
					messages.Add(SPAN_NOTICE("\t [R]"))
				else
					var/blood_type = R.data["blood_type"]
					messages.Add(SPAN_NOTICE("\t [R] [blood_type]"))
		else
			messages.Add(SPAN_NOTICE("No active chemical agents found in [A]."))
	else
		messages.Add(SPAN_NOTICE("No significant chemical agents found in [A]."))
	to_chat(user, chat_box_regular(messages.Join("<br>")))

/datum/data/pda/utility/scanmode/gas
	base_name = "Gas Scanner"
	icon = "tachometer-alt"

/datum/data/pda/utility/scanmode/gas/scan_atom(atom/A, mob/user)
	atmos_scan(user=user, target=A, silent=FALSE, print=TRUE)

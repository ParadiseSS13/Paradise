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
	icon = "external-link"
	var/remote_door_id = ""

/datum/data/pda/utility/toggle_door/start()
	for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
		if(M.id_tag == remote_door_id)
			if(M.density)
				M.open()
			else
				M.close()

/datum/data/pda/utility/scanmode/medical
	base_name = "Med Scanner"
	icon = "heart-o"

/datum/data/pda/utility/scanmode/medical/scan_mob(mob/living/M, mob/living/user)
	user.visible_message("<span class='notice'>[user] analyzes [M]'s vitals.</span>", "<span class='notice'>You analyze [M]'s vitals.</span>")

	healthscan(user, M, 1)

/datum/data/pda/utility/scanmode/dna
	base_name = "DNA Scanner"
	icon = "link"

/datum/data/pda/utility/scanmode/dna/scan_mob(mob/living/C as mob, mob/living/user as mob)
	if(istype(C, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = C
		if(!istype(H.dna, /datum/dna))
			to_chat(user, "<span class='notice'>No fingerprints found on [H]</span>")
		else
			to_chat(user, "<span class='notice'>[H]'s Fingerprints: [md5(H.dna.uni_identity)]</span>")
	scan_blood(C, user)

/datum/data/pda/utility/scanmode/dna/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	scan_blood(A, user)

/datum/data/pda/utility/scanmode/dna/proc/scan_blood(atom/A, mob/user)
	if(!A.blood_DNA)
		to_chat(user, "<span class='notice'>No blood found on [A]</span>")
		if(A.blood_DNA)
			qdel(A.blood_DNA)
	else
		to_chat(user, "<span class='notice'>Blood found on [A]. Analysing...</span>")
		spawn(15)
			for(var/blood in A.blood_DNA)
				to_chat(user, "<span class='notice'>Blood type: [A.blood_DNA[blood]]\nDNA: [blood]</span>")

/datum/data/pda/utility/scanmode/halogen
	base_name = "Halogen Counter"
	icon = "exclamation-circle"

/datum/data/pda/utility/scanmode/halogen/scan_mob(mob/living/C as mob, mob/living/user as mob)
	C.visible_message("<span class='warning'>[user] has analyzed [C]'s radiation levels!</span>")

	user.show_message("<span class='notice'>Analyzing Results for [C]:</span>")
	if(C.radiation)
		user.show_message("<span class='notice'>Radiation Level: [C.radiation > 0 ? "</span><span class='danger'>[C.radiation]" : "0"]</span>")
	else
		user.show_message("<span class='notice'>No radiation detected.</span>")

/datum/data/pda/utility/scanmode/reagent
	base_name = "Reagent Scanner"
	icon = "flask"

/datum/data/pda/utility/scanmode/reagent/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	if(!isnull(A.reagents))
		if(A.reagents.reagent_list.len > 0)
			var/reagents_length = A.reagents.reagent_list.len
			to_chat(user, "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.</span>")
			for(var/datum/reagent/R in A.reagents.reagent_list)
				if(R.id != "blood")
					to_chat(user, "<span class='notice'>\t [R]</span>")
				else
					var/blood_type = R.data["blood_type"]
					to_chat(user, "<span class='notice'>\t [R] [blood_type]</span>")
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in [A].</span>")
	else
		to_chat(user, "<span class='notice'>No significant chemical agents found in [A].</span>")

/datum/data/pda/utility/scanmode/gas
	base_name = "Gas Scanner"
	icon = "tachometer"

/datum/data/pda/utility/scanmode/gas/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	if(istype(A, /obj/item/tank))
		var/obj/item/tank/T = A
		pda.atmosanalyzer_scan(T.air_contents, user, T)
	else if(istype(A, /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/T = A
		pda.atmosanalyzer_scan(T.air_contents, user, T)
	else if(istype(A, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/T = A
		pda.atmosanalyzer_scan(T.parent.air, user, T)
	else if(istype(A, /obj/machinery/power/rad_collector))
		var/obj/machinery/power/rad_collector/T = A
		if(T.P)
			pda.atmosanalyzer_scan(T.P.air_contents, user, T)
	else if(istype(A, /obj/item/flamethrower))
		var/obj/item/flamethrower/T = A
		if(T.ptank)
			pda.atmosanalyzer_scan(T.ptank.air_contents, user, T)
	else if(istype(A, /obj/machinery/portable_atmospherics/scrubber/huge))
		var/obj/machinery/portable_atmospherics/scrubber/huge/T = A
		pda.atmosanalyzer_scan(T.air_contents, user, T)
	else if(istype(A, /obj/machinery/atmospherics/unary/tank))
		var/obj/machinery/atmospherics/unary/tank/T = A
		pda.atmosanalyzer_scan(T.air_contents, user, T)

/datum/data/pda/utility/scanmode/notes
	base_name = "Note Scanner"
	icon = "clipboard"
	var/datum/data/pda/app/notekeeper/notes

/datum/data/pda/utility/scanmode/notes/start()
	. = ..()
	notes = pda.find_program(/datum/data/pda/app/notekeeper)

/datum/data/pda/utility/scanmode/notes/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	if(notes && istype(A, /obj/item/paper))
		var/obj/item/paper/P = A
		var/list/brlist = list("p", "/p", "br", "hr", "h1", "h2", "h3", "h4", "/h1", "/h2", "/h3", "/h4")

		// JMO 20140705: Makes scanned document show up properly in the notes. Not pretty for formatted documents,
		// as this will clobber the HTML, but at least it lets you scan a document. You can restore the original
		// notes by editing the note again. (Was going to allow you to edit, but scanned documents are too long.)
		var/raw_scan = sanitize_simple(P.info, list("\t" = "", "ÿ" = ""))
		var/formatted_scan = ""
		// Scrub out the tags (replacing a few formatting ones along the way)
		// Find the beginning and end of the first tag.
		var/tag_start = findtext(raw_scan, "<")
		var/tag_stop = findtext(raw_scan, ">")
		// Until we run out of complete tags...
		while(tag_start && tag_stop)
			var/pre = copytext(raw_scan, 1, tag_start) // Get the stuff that comes before the tag
			var/tag = lowertext(copytext(raw_scan, tag_start + 1, tag_stop)) // Get the tag so we can do intellegent replacement
			var/tagend = findtext(tag, " ") // Find the first space in the tag if there is one.
			// Anything that's before the tag can just be added as is.
			formatted_scan = formatted_scan + pre
			// If we have a space after the tag (and presumably attributes) just crop that off.
			if(tagend)
				tag = copytext(tag, 1, tagend)
			if(tag in brlist) // Check if it's I vertical space tag.
				formatted_scan = formatted_scan + "<br>" // If so, add some padding in.
			raw_scan = copytext(raw_scan, tag_stop + 1) // continue on with the stuff after the tag
			// Look for the next tag in what's left
			tag_start = findtext(raw_scan, "<")
			tag_stop = findtext(raw_scan, ">")
		// Anything that is left in the page. just tack it on to the end as is
		formatted_scan = formatted_scan + raw_scan
		// If there is something in there already, pad it out.
		if(length(notes.note) > 0)
			notes.note += "<br><br>"
		// Store the scanned document to the notes
		notes.note += "Scanned Document. Edit to restore previous notes/delete scan.<br>----------<br>" + formatted_scan + "<br>"
		// notehtml ISN'T set to allow user to get their old notes back. A better implementation would add a "scanned documents"
		// feature to the PDA, which would better convey the availability of the feature, but this will work for now.
		// Inform the user
		to_chat(user, "<span class='notice'>Paper scanned and OCRed to notekeeper.</span>")//concept of scanning paper copyright brainoblivion 2009

	else
		to_chat(user, "<span class='warning'>Error scanning [A].</span>")

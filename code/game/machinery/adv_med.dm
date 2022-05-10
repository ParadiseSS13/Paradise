/obj/machinery/sleeper/bodyscanner
	name = "body scanner"
	icon_state = "bodyscanner_open"
	base_icon = "bodyscanner"
	light_color = "#00FF00"
	beaker_slot = FALSE
	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/mindshield, /obj/item/implant/tracking, /obj/item/implant/health)

/obj/machinery/sleeper/bodyscanner/detailed_examine()
	return "The advanced scanner detects and reports internal injuries such as bone fractures, internal bleeding, and organ damage. \
			This is useful if you are about to perform surgery.<br>\
			<br>\
			Click your target with Grab intent, then click on the scanner to place them in it. Click the red terminal to operate. \
			Right-click the scanner and click 'Eject Occupant' to remove them. You can enter the scanner yourself in a similar way, using the 'Enter Body Scanner' \
			verb."

/obj/machinery/sleeper/bodyscanner/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/bodyscanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/sleeper/bodyscanner/ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)
	..()

/obj/machinery/sleeper/bodyscanner/verb/move_inside_scanner()
	set name = "Enter Body Scanner"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0 || !(ishuman(usr)))
		return
	if(!permitted_check(usr, usr))
		return
	visible_message("[usr] starts climbing into [src].")
	if(do_after(usr, 20, target = usr))
		if(occupant)
			to_chat(usr, "<span class='boldnotice'>[src] is already occupied!</span>")
			return
		usr.stop_pulling()
		usr.forceMove(src)
		occupant = usr
		update_icon()

/obj/machinery/sleeper/bodyscanner/move_inside()
	set hidden = TRUE

/obj/machinery/sleeper/bodyscanner/remove_beaker()
	set hidden = TRUE

/obj/machinery/sleeper/bodyscanner/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BodyScanner", "Body Scanner", 690, 600)
		ui.open()

/obj/machinery/sleeper/bodyscanner/ui_data(mob/user)
	var/list/data = list()

	data["occupied"] = occupant ? TRUE : FALSE

	var/occupantData[0]
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth

		var/found_disease = FALSE
		for(var/thing in occupant.viruses)
			var/datum/disease/D = thing
			if(D.visibility_flags & HIDDEN_SCANNER || D.visibility_flags & HIDDEN_PANDEMIC)
				continue
			if(istype(D, /datum/disease/critical))
				continue
			found_disease = TRUE
			break
		occupantData["hasVirus"] = found_disease

		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()

		occupantData["radLoss"] = occupant.radiation
		occupantData["cloneLoss"] = occupant.getCloneLoss()
		occupantData["brainLoss"] = occupant.getBrainLoss()
		occupantData["paralysis"] = occupant.paralysis
		occupantData["paralysisSeconds"] = round(occupant.paralysis * 0.25)
		occupantData["bodyTempC"] = occupant.bodytemperature-T0C
		occupantData["bodyTempF"] = (((occupant.bodytemperature-T0C) * 1.8) + 32)

		occupantData["hasBorer"] = occupant.has_brain_worms()

		var/bloodData[0]
		bloodData["hasBlood"] = FALSE
		if(!(NO_BLOOD in occupant.dna.species.species_traits))
			bloodData["hasBlood"] = TRUE
			bloodData["volume"] = occupant.blood_volume
			bloodData["percent"] = round(((occupant.blood_volume / BLOOD_VOLUME_NORMAL)*100))
			bloodData["pulse"] = occupant.get_pulse(GETPULSE_TOOL)
			bloodData["bloodLevel"] = occupant.blood_volume
			bloodData["bloodMax"] = occupant.max_blood
		occupantData["blood"] = bloodData

		var/implantData[0]
		for(var/obj/item/implant/I in occupant)
			if(I.implanted && is_type_in_list(I, known_implants))
				var/implantSubData[0]
				implantSubData["name"] = sanitize(I.name)
				implantData.Add(list(implantSubData))
		occupantData["implant"] = implantData
		occupantData["implant_len"] = implantData.len

		var/extOrganData[0]
		for(var/obj/item/organ/external/E in occupant.bodyparts)
			var/organData[0]
			organData["name"] = E.name
			organData["open"] = E.open
			organData["germ_level"] = E.germ_level
			organData["bruteLoss"] = E.brute_dam
			organData["fireLoss"] = E.burn_dam
			organData["totalLoss"] = E.brute_dam + E.burn_dam
			organData["maxHealth"] = E.max_damage
			organData["bruised"] = E.min_bruised_damage
			organData["broken"] = E.min_broken_damage

			var/shrapnelData[0]
			for(var/obj/I in E.embedded_objects)
				var/shrapnelSubData[0]
				shrapnelSubData["name"] = I.name

				shrapnelData.Add(list(shrapnelSubData))

			organData["shrapnel"] = shrapnelData
			organData["shrapnel_len"] = shrapnelData.len

			var/organStatus[0]
			if(E.status & ORGAN_BROKEN)
				organStatus["broken"] = E.broken_description
			if(E.is_robotic())
				organStatus["robotic"] = TRUE
			if(E.status & ORGAN_SPLINTED)
				organStatus["splinted"] = TRUE
			if(E.status & ORGAN_DEAD)
				organStatus["dead"] = TRUE

			organData["status"] = organStatus

			if(istype(E, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
				organData["lungRuptured"] = TRUE

			if(E.status & ORGAN_INT_BLEEDING)
				organData["internalBleeding"] = TRUE

			extOrganData.Add(list(organData))

		occupantData["extOrgan"] = extOrganData

		var/intOrganData[0]
		for(var/obj/item/organ/internal/I in occupant.internal_organs)
			var/organData[0]
			organData["name"] = I.name
			organData["desc"] = I.desc
			organData["germ_level"] = I.germ_level
			organData["damage"] = I.damage
			organData["maxHealth"] = I.max_damage
			organData["bruised"] = I.min_bruised_damage
			organData["broken"] = I.min_broken_damage
			organData["robotic"] = I.is_robotic()
			organData["dead"] = (I.status & ORGAN_DEAD)

			intOrganData.Add(list(organData))

		occupantData["intOrgan"] = intOrganData

		occupantData["blind"] = HAS_TRAIT(occupant, TRAIT_BLIND)
		occupantData["colourblind"] = HAS_TRAIT(occupant, TRAIT_COLORBLIND)
		occupantData["nearsighted"] = HAS_TRAIT(occupant, TRAIT_NEARSIGHT)

	data["occupant"] = occupantData
	return data

/obj/machinery/sleeper/bodyscanner/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = TRUE
	switch(action)
		if("ejectify")
			eject()
		if("print_p")
			visible_message("<span class='notice'>[src] rattles and prints out a sheet of paper.</span>")
			var/obj/item/paper/P = new /obj/item/paper(loc)
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
			var/name = occupant ? occupant.name : "Unknown"
			P.info = "<CENTER><B>Body Scan - [name]</B></CENTER><BR>"
			P.info += "<b>Time of scan:</b> [station_time_timestamp()]<br><br>"
			P.info += "[generate_printing_text()]"
			P.info += "<br><br><b>Notes:</b><br>"
			P.name = "Body Scan - [name]"
		else
			return FALSE

/obj/machinery/sleeper/bodyscanner/proc/generate_printing_text()
	var/dat = ""

	dat = "<font color='blue'><b>Occupant Statistics:</b></font><br>" //Blah obvious
	if(istype(occupant)) //is there REALLY someone in there?
		var/t1
		switch(occupant.stat) // obvious, see what their status is
			if(0)
				t1 = "Conscious"
			if(1)
				t1 = "Unconscious"
			else
				t1 = "*dead*"
		dat += "[occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"]\tHealth %: [occupant.health], ([t1])</font><br>"

		var/found_disease = FALSE
		for(var/thing in occupant.viruses)
			var/datum/disease/D = thing
			if(D.visibility_flags & HIDDEN_SCANNER || D.visibility_flags & HIDDEN_PANDEMIC)
				continue
			found_disease = TRUE
			break
		if(found_disease)
			dat += "<font color='red'>Disease detected in occupant.</font><BR>"

		var/extra_font = null
		extra_font = (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Brute Damage %: [occupant.getBruteLoss()]</font><br>"

		extra_font = (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Respiratory Damage %: [occupant.getOxyLoss()]</font><br>"

		extra_font = (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Toxin Content %: [occupant.getToxLoss()]</font><br>"

		extra_font = (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\t-Burn Severity %: [occupant.getFireLoss()]</font><br>"

		extra_font = (occupant.radiation < 10 ?"<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tRadiation Level %: [occupant.radiation]</font><br>"

		extra_font = (occupant.getCloneLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tGenetic Tissue Damage %: [occupant.getCloneLoss()]<br>"

		extra_font = (occupant.getBrainLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tApprox. Brain Damage %: [occupant.getBrainLoss()]<br>"

		dat += "Paralysis Summary %: [occupant.paralysis] ([round(occupant.paralysis / 4)] seconds left!)<br>"
		dat += "Body Temperature: [occupant.bodytemperature-T0C]&deg;C ([occupant.bodytemperature*1.8-459.67]&deg;F)<br>"

		dat += "<hr>"

		if(occupant.has_brain_worms())
			dat += "Large growth detected in frontal lobe, possibly cancerous. Surgical removal is recommended.<br>"

		var/blood_percent =  round((occupant.blood_volume / BLOOD_VOLUME_NORMAL))
		blood_percent *= 100

		extra_font = (occupant.blood_volume > 448 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tBlood Level %: [blood_percent] ([occupant.blood_volume] units)</font><br>"

		if(occupant.reagents)
			dat += "Epinephrine units: [occupant.reagents.get_reagent_amount("Epinephrine")] units<BR>"
			dat += "Ether: [occupant.reagents.get_reagent_amount("ether")] units<BR>"

			extra_font = (occupant.reagents.get_reagent_amount("silver_sulfadiazine") < 30 ? "<font color='black'>" : "<font color='red'>")
			dat += "[extra_font]\tSilver Sulfadiazine: [occupant.reagents.get_reagent_amount("silver_sulfadiazine")]</font><br>"

			extra_font = (occupant.reagents.get_reagent_amount("styptic_powder") < 30 ? "<font color='black'>" : "<font color='red'>")
			dat += "[extra_font]\tStyptic Powder: [occupant.reagents.get_reagent_amount("styptic_powder")] units<BR>"

			extra_font = (occupant.reagents.get_reagent_amount("salbutamol") < 30 ? "<font color='black'>" : "<font color='red'>")
			dat += "[extra_font]\tSalbutamol: [occupant.reagents.get_reagent_amount("salbutamol")] units<BR>"

		dat += "<hr><table border='1'>"
		dat += "<tr>"
		dat += "<th>Organ</th>"
		dat += "<th>Burn Damage</th>"
		dat += "<th>Brute Damage</th>"
		dat += "<th>Other Wounds</th>"
		dat += "</tr>"

		for(var/obj/item/organ/external/e in occupant.bodyparts)
			dat += "<tr>"
			var/AN = ""
			var/open = ""
			var/infected = ""
			var/dead = ""
			var/robot = ""
			var/imp = ""
			var/bled = ""
			var/splint = ""
			var/internal_bleeding = ""
			var/lung_ruptured = ""
			if(e.status & ORGAN_INT_BLEEDING)
				internal_bleeding = "<br>Internal bleeding"
			if(istype(e, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
				lung_ruptured = "Lung ruptured:"
			if(e.status & ORGAN_SPLINTED)
				splint = "Splinted:"
			if(e.status & ORGAN_BROKEN)
				AN = "[e.broken_description]:"
			if(e.status & ORGAN_DEAD)
				dead = "DEAD:"
			if(e.is_robotic())
				robot = "Robotic:"
			if(e.open)
				open = "Open:"
			switch(e.germ_level)
				if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
					infected = "Mild Infection:"
				if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
					infected = "Mild Infection+:"
				if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
					infected = "Mild Infection++:"
				if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
					infected = "Acute Infection:"
				if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
					infected = "Acute Infection+:"
				if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 399)
					infected = "Acute Infection++:"
				if(INFECTION_LEVEL_TWO + 400 to INFINITY)
					infected = "Septic:"

			var/unknown_body = 0
			for(var/I in e.embedded_objects)
				unknown_body++

			if(unknown_body || e.hidden)
				imp += "Unknown body present:"
			if(!AN && !open && !infected && !imp)
				AN = "None:"
			dat += "<td>[e.name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured][dead]</td>"
			dat += "</tr>"
		for(var/obj/item/organ/internal/i in occupant.internal_organs)
			var/mech = i.desc
			var/infection = "None"
			var/dead = ""
			if(i.status & ORGAN_DEAD)
				dead = "DEAD:"
			switch(i.germ_level)
				if(1 to INFECTION_LEVEL_ONE + 200)
					infection = "Mild Infection:"
				if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
					infection = "Mild Infection+:"
				if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
					infection = "Mild Infection++:"
				if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
					infection = "Acute Infection:"
				if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
					infection = "Acute Infection+:"
				if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 399)
					infection = "Acute Infection++:"
				if(INFECTION_LEVEL_TWO + 400 to INFINITY)
					infection = "Septic:"

			dat += "<tr>"
			dat += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>[infection]:[mech][dead]</td><td></td>"
			dat += "</tr>"
		dat += "</table>"
		if(HAS_TRAIT(occupant, TRAIT_BLIND))
			dat += "<font color='red'>Cataracts detected.</font><BR>"
		if(HAS_TRAIT(occupant, TRAIT_COLORBLIND))
			dat += "<font color='red'>Photoreceptor abnormalities detected.</font><BR>"
		if(HAS_TRAIT(occupant, TRAIT_NEARSIGHT))
			dat += "<font color='red'>Retinal misalignment detected.</font><BR>"
	else
		dat += "[src] is empty."

	return dat

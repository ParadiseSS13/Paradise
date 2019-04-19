/obj/machinery/bodyscanner
	name = "body scanner"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "bodyscanner-open"
	density = TRUE
	dir = WEST
	anchored = TRUE
	idle_power_usage = 1250
	active_power_usage = 2500

	light_color = "#00FF00"
	var/obj/machinery/body_scanconsole/console = null
	var/mob/living/carbon/occupant = null
	var/locked

/obj/machinery/bodyscanner/Destroy()
	go_out()
	if(console)
		console.connected = null
		console = null
	return ..()

/obj/machinery/bodyscanner/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/bodyscanner/process()
	for(var/mob/M as mob in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
		if(M == occupant)
			continue
		else
			M.forceMove(loc)

/obj/machinery/bodyscanner/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/bodyscanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/bodyscanner/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/bodyscanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/bodyscanner/attackby(obj/item/I, mob/user)
	if(isscrewdriver(I))
		if(occupant)
			to_chat(user, "<span class='notice'>The maintenance panel is locked.</span>")
			return
		default_deconstruction_screwdriver(user, "bodyscanner-o", "bodyscanner-open", I)
		return

	if(iswrench(I))
		if(occupant)
			to_chat(user, "<span class='notice'>The scanner is occupied.</span>")
			return
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		if(dir == EAST)
			setDir(WEST)
		else
			setDir(EAST)
		playsound(loc, I.usesound, 50, 1)
		return

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/TYPECAST_YOUR_SHIT = I
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		if(!ismob(TYPECAST_YOUR_SHIT.affecting))
			return
		if(occupant)
			to_chat(user, "<span class='notice'>The scanner is already occupied!</span>")
			return
		for(var/mob/living/carbon/slime/M in range(1, TYPECAST_YOUR_SHIT.affecting))
			if(M.Victim == TYPECAST_YOUR_SHIT.affecting)
				to_chat(user, "<span class='danger'>[TYPECAST_YOUR_SHIT.affecting.name] has a fucking slime attached to [TYPECAST_YOUR_SHIT.affecting.p_them()], deal with that first.</span>")
				return
		var/mob/M = TYPECAST_YOUR_SHIT.affecting
		if(M.abiotic())
			to_chat(user, "<span class='notice'>Subject cannot have abiotic items on.</span>")
			return
		M.forceMove(src)
		occupant = M
		icon_state = "body_scanner_1"
		add_fingerprint(user)
		qdel(TYPECAST_YOUR_SHIT)
		return

	return ..()


/obj/machinery/bodyscanner/MouseDrop_T(mob/living/carbon/human/O, mob/user as mob)
	if(!istype(O))
		return 0 //not a mob
	if(user.incapacitated())
		return 0 //user shouldn't be doing things
	if(O.anchored)
		return 0 //mob is anchored???
	if(get_dist(user, src) > 1 || get_dist(user, O) > 1)
		return 0 //doesn't use adjacent() to allow for non-cardinal (fuck my life)
	if(!ishuman(user) && !isrobot(user))
		return 0 //not a borg or human
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return 0 //panel open
	if(occupant)
		to_chat(user, "<span class='notice'>[src] is already occupied.</span>")
		return 0 //occupied

	if(O.buckled)
		return 0
	if(O.abiotic())
		to_chat(user, "<span class='notice'>Subject cannot have abiotic items on.</span>")
		return 0
	for(var/mob/living/carbon/slime/M in range(1, O))
		if(M.Victim == O)
			to_chat(user, "<span class='danger'>[O] has a fucking slime attached to [O.p_them()], deal with that first.</span>")
			return 0

	if(O == user)
		visible_message("[user] climbs into [src].")
	else
		visible_message("[user] puts [O] into the body scanner.")

	O.forceMove(src)
	occupant = O
	icon_state = "bodyscanner"
	add_fingerprint(user)

/obj/machinery/bodyscanner/relaymove(mob/user as mob)
	if(user.incapacitated())
		return 0 //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if(usr.incapacitated())
		return
	go_out()
	add_fingerprint(usr)

/obj/machinery/bodyscanner/proc/go_out()
	if(!occupant || locked)
		return
	occupant.forceMove(loc)
	occupant = null
	icon_state = "body_scanner_0"
	// eject trash the occupant dropped
	for(var/atom/movable/A in contents - component_parts)
		A.forceMove(loc)

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(loc)
				A.ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					A.ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					A.ex_act(severity)
				qdel(src)
				return

/obj/machinery/bodyscanner/blob_act()
	if(prob(50))
		var/atom/movable/A = occupant
		go_out()
		A.blob_act()
		qdel(src)

/obj/machinery/bodyscanner/narsie_act()
	go_out()
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	qdel(src)

/obj/machinery/bodyscanner/attack_animal(var/mob/living/simple_animal/M)//Stop putting hostile mobs in things guise
	if(M.environment_smash)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] smashes [src] apart!</span>")
		go_out()
		qdel(src)
	return

/obj/machinery/body_scanconsole
	name = "Body Scanner Console"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "bodyscannerconsole"
	density = 1
	anchored = 1
	dir = WEST
	idle_power_usage = 250
	active_power_usage = 500
	var/obj/machinery/bodyscanner/connected = null
	var/delete
	var/temphtml
	var/printing = null
	var/printing_text = null
	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/mindshield, /obj/item/implant/tracking, /obj/item/implant/health)

/obj/machinery/body_scanconsole/power_change()
	if(stat & BROKEN)
		icon_state = "bodyscannerconsole-p"
	else if(powered() && !panel_open)
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			icon_state = "bodyscannerconsole-p"
			stat |= NOPOWER

/obj/machinery/body_scanconsole/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/bodyscanner_console(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()
	findscanner()

/obj/machinery/body_scanconsole/Destroy()
	if(connected)
		connected.console = null
		connected = null
	return ..()

/obj/machinery/body_scanconsole/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/body_scanconsole/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/body_scanconsole/attack_animal(var/mob/living/simple_animal/M)//Stop putting hostile mobs in things guise
	if(M.environment_smash)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] smashes [src] apart!</span>")
		qdel(src)
	return

/obj/machinery/body_scanconsole/proc/findscanner()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		// Try to find a scanner in that direction
		var/temp = locate(/obj/machinery/bodyscanner, get_step(src, dir))
		if(temp)
			connected = temp
			connected.console = src
			break


/obj/machinery/body_scanconsole/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "bodyscannerconsole-p", "bodyscannerconsole", I))
		return

	if(iswrench(I))
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		if(dir == EAST)
			setDir(WEST)
		else
			setDir(EAST)
		playsound(loc, I.usesound, 50, 1)
		return

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return
	else
		return ..()

/obj/machinery/body_scanconsole/attack_ai(user)
	return attack_hand(user)

/obj/machinery/body_scanconsole/attack_ghost(user)
	return attack_hand(user)

/obj/machinery/body_scanconsole/attack_hand(user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	if(!connected)
		findscanner()

	ui_interact(user)


/obj/machinery/body_scanconsole/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "adv_med.tmpl", "Body Scanner", 690, 600)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/body_scanconsole/ui_data(mob/user, datum/topic_state/state)
	var/data[0]

	data["connected"] = connected ? 1 : 0

	if(!connected)
		return data

	data["occupied"] = connected.occupant ? 1 : 0

	var/occupantData[0]
	if(connected.occupant)
		var/mob/living/carbon/human/H = connected.occupant
		occupantData["name"] = H.name
		occupantData["stat"] = H.stat
		occupantData["health"] = H.health
		occupantData["maxHealth"] = H.maxHealth

		var/found_disease = FALSE
		for(var/thing in H.viruses)
			var/datum/disease/D = thing
			if(D.visibility_flags & HIDDEN_SCANNER || D.visibility_flags & HIDDEN_PANDEMIC)
				continue
			found_disease = TRUE
			break
		occupantData["hasVirus"] = found_disease

		occupantData["bruteLoss"] = H.getBruteLoss()
		occupantData["oxyLoss"] = H.getOxyLoss()
		occupantData["toxLoss"] = H.getToxLoss()
		occupantData["fireLoss"] = H.getFireLoss()

		occupantData["radLoss"] = H.radiation
		occupantData["cloneLoss"] = H.getCloneLoss()
		occupantData["brainLoss"] = H.getBrainLoss()
		occupantData["paralysis"] = H.paralysis
		occupantData["paralysisSeconds"] = round(H.paralysis / 4)
		occupantData["bodyTempC"] = H.bodytemperature-T0C
		occupantData["bodyTempF"] = (((H.bodytemperature-T0C) * 1.8) + 32)

		occupantData["hasBorer"] = H.has_brain_worms()

		var/bloodData[0]
		bloodData["hasBlood"] = 0
		if(ishuman(H) && !(NO_BLOOD in H.dna.species.species_traits))
			bloodData["hasBlood"] = 1
			bloodData["volume"] = H.blood_volume
			bloodData["percent"] = round(((H.blood_volume / BLOOD_VOLUME_NORMAL)*100))
			bloodData["pulse"] = H.get_pulse(GETPULSE_TOOL)
			bloodData["bloodLevel"] = H.blood_volume
			bloodData["bloodMax"] = H.max_blood
		occupantData["blood"] = bloodData

		var/implantData[0]
		for(var/obj/item/implant/I in H)
			if(I.implanted && is_type_in_list(I, known_implants))
				var/implantSubData[0]
				implantSubData["name"] = sanitize(I.name)
				implantData.Add(list(implantSubData))
		occupantData["implant"] = implantData
		occupantData["implant_len"] = implantData.len

		var/extOrganData[0]
		for(var/obj/item/organ/external/E in H.bodyparts)
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
				organStatus["robotic"] = 1
			if(E.status & ORGAN_SPLINTED)
				organStatus["splinted"] = 1
			if(E.status & ORGAN_DEAD)
				organStatus["dead"] = 1

			organData["status"] = organStatus

			if(istype(E, /obj/item/organ/external/chest) && H.is_lung_ruptured())
				organData["lungRuptured"] = 1

			if(E.internal_bleeding)
				organData["internalBleeding"] = 1

			extOrganData.Add(list(organData))

		occupantData["extOrgan"] = extOrganData

		var/intOrganData[0]
		for(var/obj/item/organ/internal/I in H.internal_organs)
			var/organData[0]
			organData["name"] = I.name
			organData["desc"] = I.desc
			organData["germ_level"] = I.germ_level
			organData["damage"] = I.damage
			organData["maxHealth"] = I.max_damage
			organData["bruised"] = I.min_broken_damage
			organData["broken"] = I.min_bruised_damage
			organData["robotic"] = I.is_robotic()
			organData["dead"] = (I.status & ORGAN_DEAD)

			intOrganData.Add(list(organData))

		occupantData["intOrgan"] = intOrganData

		occupantData["blind"] = (H.disabilities & BLIND)
		occupantData["colourblind"] = (H.disabilities & COLOURBLIND)
		occupantData["nearsighted"] = (H.disabilities & NEARSIGHTED)

	data["occupant"] = occupantData
	return data

/obj/machinery/body_scanconsole/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["ejectify"])
		connected.eject()

	if(href_list["print_p"])
		generate_printing_text()

		if(!(printing) && printing_text)
			printing = 1
			visible_message("<span class='notice'>[src] rattles and prints out a sheet of paper.</span>")
			var/obj/item/paper/P = new /obj/item/paper(loc)
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
			P.info = "<CENTER><B>Body Scan - [href_list["name"]]</B></CENTER><BR>"
			P.info += "<b>Time of scan:</b> [station_time_timestamp()]<br><br>"
			P.info += "[printing_text]"
			P.info += "<br><br><b>Notes:</b><br>"
			P.name = "Body Scan - [href_list["name"]]"
			printing = null
			printing_text = null

/obj/machinery/body_scanconsole/proc/generate_printing_text()
	var/dat = ""

	if(connected)
		var/mob/living/carbon/human/occupant = connected.occupant
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
				var/robot = ""
				var/imp = ""
				var/bled = ""
				var/splint = ""
				var/internal_bleeding = ""
				var/lung_ruptured = ""
				if(e.internal_bleeding)
					internal_bleeding = "<br>Internal bleeding"
				if(istype(e, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
					lung_ruptured = "Lung ruptured:"
				if(e.status & ORGAN_SPLINTED)
					splint = "Splinted:"
				if(e.status & ORGAN_BROKEN)
					AN = "[e.broken_description]:"
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
					if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 400)
						infected = "Acute Infection++:"
					if(INFECTION_LEVEL_THREE to INFINITY)
						infected = "Septic:"

				var/unknown_body = 0
				for(var/I in e.embedded_objects)
					unknown_body++

				if(unknown_body || e.hidden)
					imp += "Unknown body present:"
				if(!AN && !open && !infected & !imp)
					AN = "None:"
				dat += "<td>[e.name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured]</td>"
				dat += "</tr>"
			for(var/obj/item/organ/internal/i in occupant.internal_organs)
				var/mech = i.desc
				var/infection = "None"
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
					if(INFECTION_LEVEL_TWO + 300 to INFINITY)
						infection = "Acute Infection++:"

				dat += "<tr>"
				dat += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>[infection]:[mech]</td><td></td>"
				dat += "</tr>"
			dat += "</table>"
			if(occupant.disabilities & BLIND)
				dat += "<font color='red'>Cataracts detected.</font><BR>"
			if(occupant.disabilities & COLOURBLIND)
				dat += "<font color='red'>Photoreceptor abnormalities detected.</font><BR>"
			if(occupant.disabilities & NEARSIGHTED)
				dat += "<font color='red'>Retinal misalignment detected.</font><BR>"
		else
			dat += "[src] is empty."
	else
		dat = "<font color='red'> Error: No Body Scanner connected.</font>"

	printing_text = dat

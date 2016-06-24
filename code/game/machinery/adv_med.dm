/obj/machinery/bodyscanner
	var/mob/living/carbon/occupant
	var/locked
	name = "body scanner"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "bodyscanner-open"
	density = 1
	dir = 8
	anchored = 1
	idle_power_usage = 1250
	active_power_usage = 2500

	light_color = "#00FF00"

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
			M.forceMove(src.loc)

/obj/machinery/bodyscanner/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/bodyscanner(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/bodyscanner/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/bodyscanner(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/bodyscanner/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)
	if (istype(G, /obj/item/weapon/screwdriver))
		if(src.occupant)
			to_chat(user, "<span class='notice'>The maintenance panel is locked.</span>")
			return
		default_deconstruction_screwdriver(user, "bodyscanner-o", "bodyscanner-open", G)
		return

	if (istype(G, /obj/item/weapon/wrench))
		if(src.occupant)
			to_chat(user, "<span class='notice'>The scanner is occupied.</span>")
			return
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		if(dir == 4)
			dir = 8
		else
			dir = 4
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		return

	if(exchange_parts(user, G))
		return

	if(istype(G, /obj/item/weapon/crowbar))
		default_deconstruction_crowbar(G)
		return

	if(istype(G, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/TYPECAST_YOUR_SHIT = G
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
				to_chat(user, "<span class='danger'>[TYPECAST_YOUR_SHIT.affecting.name] has a fucking slime attached to them, deal with that first.</span>")
				return
		var/mob/M = TYPECAST_YOUR_SHIT.affecting
		if(M.abiotic())
			to_chat(user, "<span class='notice'>Subject cannot have abiotic items on.</span>")
			return
		/*if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src*///THIS IS FUCKING POINTLESS BECAUSE OF ON-LIFE() FUCKING RESET_VIEW() AHHHHHHHHHHGGGGGGGGGG
		M.forceMove(src)
		occupant = M
		icon_state = "body_scanner_1"
		add_fingerprint(user)
		qdel(G)


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
		to_chat(user, "<span class='notice'>\The [src] is already occupied.</span>")
		return 0 //occupied

	if(O.buckled)
		return 0
	if(O.abiotic())
		to_chat(user, "<span class='notice'>Subject cannot have abiotic items on.</span>")
		return 0
	for(var/mob/living/carbon/slime/M in range(1, O))
		if(M.Victim == O)
			to_chat(user, "<span class='danger'>[O] has a fucking slime attached to them, deal with that first.</span>")
			return 0

	if(O == user)
		visible_message("[user] climbs into \the [src].")
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
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
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
				A.forceMove(src.loc)
				A.ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					A.ex_act(severity)
				qdel(src)
				return

/obj/machinery/bodyscanner/blob_act()
	if(prob(50))
		var/atom/movable/A = occupant
		go_out()
		A.blob_act()
		qdel(src)

/obj/machinery/bodyscanner/attack_animal(var/mob/living/simple_animal/M)//Stop putting hostile mobs in things guise
	if(M.environment_smash)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] smashes [src] apart!</span>")
		go_out()
		qdel(src)
	return

/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/delete
	var/temphtml
	name = "Body Scanner Console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "bodyscannerconsole"
	density = 1
	anchored = 1
	dir = 8
	idle_power_usage = 250
	active_power_usage = 500
	var/printing = null
	var/printing_text = null
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/loyalty, /obj/item/weapon/implant/tracking)

/obj/machinery/body_scanconsole/power_change()
	if(stat & BROKEN)
		icon_state = "bodyscannerconsole-p"
	else if(powered() && !panel_open)
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "bodyscannerconsole-p"
			stat |= NOPOWER

/obj/machinery/body_scanconsole/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/bodyscanner_console(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()
	findscanner()

/obj/machinery/body_scanconsole/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
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
	var/obj/machinery/bodyscanner/bodyscannernew = null
	// Loop through every direction
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		// Try to find a scanner in that direction
		var/temp = locate(/obj/machinery/bodyscanner, get_step(src, dir))
		if(!isnull(temp))
			bodyscannernew = temp
	src.connected = bodyscannernew
	return


/obj/machinery/body_scanconsole/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob, params)
	if (istype(G, /obj/item/weapon/screwdriver))
		default_deconstruction_screwdriver(user, "bodyscannerconsole-p", "bodyscannerconsole", G)
		return

	if (istype(G, /obj/item/weapon/wrench))
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		if(dir == 4)
			dir = 8
		else
			dir = 4
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)

	if(exchange_parts(user, G))
		return

	default_deconstruction_crowbar(G)

/obj/machinery/body_scanconsole/attack_ai(user as mob)
	return attack_hand(user)

/obj/machinery/body_scanconsole/attack_ghost(user as mob)
	return attack_hand(user)

/obj/machinery/body_scanconsole/attack_hand(user as mob)
	if(stat & (NOPOWER|BROKEN))
		return

	if (panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	if(!src.connected)
		findscanner()

	ui_interact(user)


/obj/machinery/body_scanconsole/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data["connected"] = connected ? 1 : 0

	if(connected)
		data["occupied"] = connected.occupant ? 1 : 0

		var/occupantData[0]
		if(connected.occupant)
			var/mob/living/carbon/human/H = connected.occupant
			occupantData["name"] = H.name
			occupantData["stat"] = H.stat
			occupantData["health"] = H.health
			occupantData["maxHealth"] = H.maxHealth

			occupantData["hasVirus"] = H.viruses.len

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
			if(ishuman(H) && H.vessel && !(H.species && H.species.flags & NO_BLOOD))
				var/blood_volume = round(H.vessel.get_reagent_amount("blood"))
				bloodData["hasBlood"] = 1
				bloodData["volume"] = blood_volume
				bloodData["percent"] = round(((blood_volume / 560)*100))
				bloodData["pulse"] = H.get_pulse(GETPULSE_TOOL)
				bloodData["bloodLevel"] = round(H.vessel.get_reagent_amount("blood"))
				bloodData["bloodMax"] = H.max_blood
			occupantData["blood"] = bloodData

			var/implantData[0]
			for(var/obj/item/weapon/implant/I in H)
				if(I.implanted && is_type_in_list(I, known_implants))
					var/implantSubData[0]
					implantSubData["name"] = sanitize(I.name)
					implantData.Add(list(implantSubData))
			occupantData["implant"] = implantData
			occupantData["implant_len"] = implantData.len

			var/extOrganData[0]
			for(var/obj/item/organ/external/E in H.organs)
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
				for(var/obj/I in E.implants)
					var/shrapnelSubData[0]
					shrapnelSubData["name"] = I.name

					shrapnelData.Add(list(shrapnelSubData))

				organData["shrapnel"] = shrapnelData
				organData["shrapnel_len"] = shrapnelData.len

				var/organStatus[0]
				if(E.status & ORGAN_DESTROYED)
					organStatus["destroyed"] = 1
				if(E.status & ORGAN_BROKEN)
					organStatus["broken"] = E.broken_description
				if(E.status & ORGAN_ROBOT)
					organStatus["robotic"] = 1
				if(E.status & ORGAN_SPLINTED)
					organStatus["splinted"] = 1
				if(E.status & ORGAN_BLEEDING)
					organStatus["bleeding"] = 1
				if(E.status & ORGAN_DEAD)
					organStatus["dead"] = 1

				organData["status"] = organStatus

				if(istype(E, /obj/item/organ/external/chest) && H.is_lung_ruptured())
					organData["lungRuptured"] = 1

				for(var/datum/wound/W in E.wounds)
					if(W.internal)
						organData["internalBleeding"] = 1
						break

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
				organData["robotic"] = I.robotic
				organData["dead"] = (I.status & ORGAN_DEAD)

				intOrganData.Add(list(organData))

			occupantData["intOrgan"] = intOrganData

			occupantData["blind"] = (H.sdisabilities & BLIND)
			occupantData["nearsighted"] = (H.disabilities & NEARSIGHTED)

		data["occupant"] = occupantData

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "adv_med.tmpl", "Body Scanner", 690, 600)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/machinery/body_scanconsole/Topic(href, href_list)
	if(..())
		return 1

	if (href_list["ejectify"])
		src.connected.eject()

	if (href_list["print_p"])
		generate_printing_text()

		if (!(printing) && printing_text)
			printing = 1
			visible_message("<span class='notice'>\The [src] rattles and prints out a sheet of paper.</span>")
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(loc)
			playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
			P.info = "<CENTER><B>Body Scan - [href_list["name"]]</B></CENTER><BR>"
			P.info += "<b>Time of scan:</b> [worldtime2text(world.time)]<br><br>"
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

			if(occupant.viruses.len)
				dat += "<font color='red'>Viral pathogen detected in blood stream.</font><BR>"

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

			if(occupant.vessel)
				var/blood_volume = round(occupant.vessel.get_reagent_amount("blood"))
				var/blood_percent =  blood_volume / 560
				blood_percent *= 100

				extra_font = (blood_volume > 448 ? "<font color='blue'>" : "<font color='red'>")
				dat += "[extra_font]\tBlood Level %: [blood_percent] ([blood_volume] units)</font><br>"

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

			for(var/obj/item/organ/external/e in occupant.organs)
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
				for(var/datum/wound/W in e.wounds) if(W.internal)
					internal_bleeding = "<br>Internal bleeding"
					break
				if(istype(e, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
					lung_ruptured = "Lung ruptured:"
				if(e.status & ORGAN_SPLINTED)
					splint = "Splinted:"
				if(e.status & ORGAN_BLEEDING)
					bled = "Bleeding:"
				if(e.status & ORGAN_BROKEN)
					AN = "[e.broken_description]:"
				if(e.status & ORGAN_ROBOT)
					robot = "Prosthetic:"
				if(e.open)
					open = "Open:"
				switch (e.germ_level)
					if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
						infected = "Mild Infection:"
					if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
						infected = "Mild Infection+:"
					if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
						infected = "Mild Infection++:"
					if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
						infected = "Acute Infection:"
					if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
						infected = "Acute Infection+:"
					if (INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 400)
						infected = "Acute Infection++:"
					if (INFECTION_LEVEL_THREE to INFINITY)
						infected = "Septic:"

				var/unknown_body = 0
				for(var/I in e.implants)
					unknown_body++

				if(unknown_body || e.hidden)
					imp += "Unknown body present:"
				if(!AN && !open && !infected & !imp)
					AN = "None:"
				if(!(e.status & ORGAN_DESTROYED))
					dat += "<td>[e.name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured]</td>"
				else
					dat += "<td>[e.name]</td><td>-</td><td>-</td><td>Not Found</td>"
				dat += "</tr>"
			for(var/obj/item/organ/internal/i in occupant.internal_organs)
				var/mech = i.desc
				var/infection = "None"
				switch (i.germ_level)
					if (1 to INFECTION_LEVEL_ONE + 200)
						infection = "Mild Infection:"
					if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
						infection = "Mild Infection+:"
					if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
						infection = "Mild Infection++:"
					if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
						infection = "Acute Infection:"
					if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
						infection = "Acute Infection+:"
					if (INFECTION_LEVEL_TWO + 300 to INFINITY)
						infection = "Acute Infection++:"

				dat += "<tr>"
				dat += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>[infection]:[mech]</td><td></td>"
				dat += "</tr>"
			dat += "</table>"
			if(occupant.sdisabilities & BLIND)
				dat += "<font color='red'>Cataracts detected.</font><BR>"
			if(occupant.disabilities & NEARSIGHTED)
				dat += "<font color='red'>Retinal misalignment detected.</font><BR>"
		else
			dat += "\The [src] is empty."
	else
		dat = "<font color='red'> Error: No Body Scanner connected.</font>"

	printing_text = dat

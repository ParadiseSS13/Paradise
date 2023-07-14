/obj/machinery/bodyscanner
	name = "body scanner"
	desc = "A sophisticated device which reports most internal and external injuries."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "bodyscanner-open"
	density = TRUE
	dir = WEST
	anchored = TRUE
	idle_power_consumption = 1250
	active_power_consumption = 2500
	light_color = "#00FF00"
	var/mob/living/carbon/human/occupant
	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/mindshield, /obj/item/implant/tracking, /obj/item/implant/health)

/obj/machinery/bodyscanner/examine(mob/user)
	. = ..()
	if(occupant)
		if(occupant.is_dead())
			. += "<span class='warning'>You see [occupant.name] inside. [occupant.p_they(TRUE)] [occupant.p_are()] dead!</span>"
		else
			. += "<span class='notice'>You see [occupant.name] inside.</span>"
	if(Adjacent(user))
		. += "<span class='notice'>You can <b>Alt-Click</b> to eject the current occupant. <b>Click-drag</b> someone to the scanner to place them inside.</span>"


/obj/machinery/bodyscanner/Destroy()
	go_out()
	return ..()

/obj/machinery/bodyscanner/power_change()
	if(!..())
		return
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

/obj/machinery/bodyscanner/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/bodyscanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/bodyscanner/update_icon_state()
	if(occupant)
		icon_state = "bodyscanner"
	else
		icon_state = "bodyscanner-open"

/obj/machinery/bodyscanner/attackby(obj/item/I, mob/user)
	if(exchange_parts(user, I))
		return

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/TYPECAST_YOUR_SHIT = I
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		if(!ishuman(TYPECAST_YOUR_SHIT.affecting))
			return
		if(occupant)
			to_chat(user, "<span class='notice'>The scanner is already occupied!</span>")
			return
		if(TYPECAST_YOUR_SHIT.affecting.has_buckled_mobs()) //mob attached to us
			to_chat(user, "<span class='warning'>[TYPECAST_YOUR_SHIT.affecting] will not fit into [src] because [TYPECAST_YOUR_SHIT.affecting.p_they()] [TYPECAST_YOUR_SHIT.affecting.p_have()] a fucking slime latched onto [TYPECAST_YOUR_SHIT.affecting.p_their()] head.</span>")
			return
		var/mob/living/carbon/human/M = TYPECAST_YOUR_SHIT.affecting
		if(M.abiotic())
			to_chat(user, "<span class='notice'>Subject may not hold anything in their hands.</span>")
			return
		M.forceMove(src)
		occupant = M
		playsound(src, 'sound/machines/podclose.ogg', 5)
		update_icon(UPDATE_ICON_STATE)
		add_fingerprint(user)
		qdel(TYPECAST_YOUR_SHIT)
		SStgui.update_uis(src)
		return

	return ..()

/obj/machinery/bodyscanner/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/bodyscanner/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "bodyscanner-o", "bodyscanner-open", I))
		return TRUE

/obj/machinery/bodyscanner/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(occupant)
		to_chat(user, "<span class='notice'>The scanner is occupied.</span>")
		return
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	setDir(turn(dir, -90))

/obj/machinery/bodyscanner/MouseDrop_T(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return FALSE //not human
	if(user.incapacitated())
		return FALSE //user shouldn't be doing things
	if(H.anchored)
		return FALSE //mob is anchored???
	if(get_dist(user, src) > 1 || get_dist(user, H) > 1)
		return FALSE //doesn't use adjacent() to allow for non-cardinal (fuck my life)
	if(!ishuman(user) && !isrobot(user))
		return FALSE //not a borg or human
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return TRUE //panel open
	if(occupant)
		to_chat(user, "<span class='notice'>[src] is already occupied.</span>")
		return TRUE //occupied
	if(H.buckled)
		return FALSE
	if(H.abiotic())
		to_chat(user, "<span class='notice'>Subject may not hold anything in their hands.</span>")
		return TRUE
	if(H.has_buckled_mobs()) //mob attached to us
		to_chat(user, "<span class='warning'>[H] will not fit into [src] because [H.p_they()] [H.p_have()] a slime latched onto [H.p_their()] head.</span>")
		return TRUE

	if(H == user)
		visible_message("[user] climbs into [src].")
	else
		visible_message("[user] puts [H] into the body scanner.")

	H.forceMove(src)
	occupant = H
	playsound(src, 'sound/machines/podclose.ogg', 5)
	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(user)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/bodyscanner/attack_ai(user)
	return attack_hand(user)

/obj/machinery/bodyscanner/attack_ghost(user)
	ui_interact(user)

/obj/machinery/bodyscanner/attack_hand(user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(occupant == user)
		return // you cant reach that

	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	ui_interact(user)

/obj/machinery/bodyscanner/relaymove(mob/user)
	if(user.incapacitated())
		return FALSE //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/bodyscanner/AltClick(mob/user)
	if(issilicon(user))
		eject()
		return
	if(!Adjacent(user) || !ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	eject()

/obj/machinery/bodyscanner/proc/eject(mob/user)
	go_out()
	add_fingerprint(user)

/obj/machinery/bodyscanner/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(loc)
	occupant = null
	playsound(src, 'sound/machines/podopen.ogg', 5)
	update_icon(UPDATE_ICON_STATE)
	// eject trash the occupant dropped
	for(var/atom/movable/A in contents - component_parts)
		A.forceMove(loc)
	SStgui.update_uis(src)

/obj/machinery/bodyscanner/force_eject_occupant(mob/target)
	go_out()

/obj/machinery/bodyscanner/ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)
	..()

/obj/machinery/bodyscanner/handle_atom_del(atom/A)
	..()
	if(A == occupant)
		occupant = null
		updateUsrDialog()
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/bodyscanner/narsie_act()
	go_out()
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	qdel(src)

/obj/machinery/bodyscanner/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BodyScanner", "Body Scanner", 690, 600)
		ui.open()

/obj/machinery/bodyscanner/ui_data(mob/user)
	var/list/data = list()

	data["occupied"] = occupant ? TRUE : FALSE

	var/occupantData[0]
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = HAS_TRAIT(occupant, TRAIT_FAKEDEATH) ? DEAD : occupant.stat
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
		occupantData["drunkenness"] = (occupant.get_drunkenness() / 10)
		occupantData["bodyTempC"] = occupant.bodytemperature-T0C
		occupantData["bodyTempF"] = (((occupant.bodytemperature-T0C) * 1.8) + 32)

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

			if(E.status & ORGAN_BURNT)
				organData["burnWound"] = TRUE

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

/obj/machinery/bodyscanner/ui_act(action, params)
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
			P.info = "<center><b>Patient: [name]</b></center>"
			P.info += "<center><b>Time of scan:</b> [station_time_timestamp()]</center><br>"
			P.info += "[generate_printing_text()]"
			P.info += "<br><br><b>Notes:</b><br>"
			P.name = "Body Scan - [name]"
		else
			return FALSE

/obj/machinery/bodyscanner/proc/generate_printing_text()
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
				t1 = "*Dead*"
		dat += "[occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"]\tHealth: [occupant.health]% ([t1])</font><br>"

		var/extra_font = null

		var/blood_percent =  round((occupant.blood_volume / BLOOD_VOLUME_NORMAL) * 100, 1)

		extra_font = (occupant.blood_volume > 448 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tBlood Level: [blood_percent]% ([occupant.blood_volume] units)</font><br>"

		extra_font = (occupant.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT && occupant.bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tBody Temperature: [occupant.bodytemperature-T0C]&deg;C ([occupant.bodytemperature*1.8-459.67]&deg;F)</font><br>"

		extra_font = (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tBrute Damage: [occupant.getBruteLoss()]</font><br>"

		extra_font = (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tRespiratory Damage: [occupant.getOxyLoss()]</font><br>"

		extra_font = (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tToxin Damage: [occupant.getToxLoss()]</font><br>"

		extra_font = (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tBurn Severity: [occupant.getFireLoss()]</font><br>"

		extra_font = (occupant.radiation < 10 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tRadiation Level: [occupant.radiation] rads</font><br>"

		extra_font = (occupant.getCloneLoss() < 1 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tCellular Tissue Damage: [occupant.getCloneLoss()]</font><br>"

		extra_font = (occupant.getBrainLoss() < 1 ? "<font color='blue'>" : "<font color='red'>")
		dat += "[extra_font]\tApprox. Brain Damage: [occupant.getBrainLoss()]</font><br>"

		var/found_disease = FALSE
		for(var/thing in occupant.viruses)
			var/datum/disease/D = thing
			if(D.visibility_flags & HIDDEN_SCANNER || D.visibility_flags & HIDDEN_PANDEMIC)
				continue
			found_disease = TRUE
			break
		if(found_disease)
			dat += "<font color='red'>Disease detected in occupant.</font><br>"

		if(HAS_TRAIT(occupant, TRAIT_BLIND))
			dat += "<font color='red'>Cataracts detected.</font><br>"
		if(HAS_TRAIT(occupant, TRAIT_COLORBLIND))
			dat += "<font color='red'>Photoreceptor abnormalities detected.</font><br>"
		if(HAS_TRAIT(occupant, TRAIT_NEARSIGHT))
			dat += "<font color='red'>Retinal misalignment detected.</font><br>"

		dat += "<hr>"
		dat += "<table border='1' style='width:100%'>"
		dat += "<tr>"
		dat += "<th style='width:30%'>Body Part</th>"
		dat += "<th style='width:10%'>Burn Damage</th>"
		dat += "<th style='width:10%'>Brute Damage</th>"
		dat += "<th>Injuries</th>"
		dat += "</tr>"

		for(var/obj/item/organ/external/e in occupant.bodyparts)
			dat += "<tr>"
			var/list/ailments = list()

			if(e.status & ORGAN_INT_BLEEDING)
				ailments |= "Internal Bleeding"
			if(istype(e, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
				ailments |= "Lung Ruptured"
			if(e.status & ORGAN_SPLINTED)
				ailments |= "Splinted"
			if(e.status & ORGAN_BROKEN)
				ailments |= "[e.broken_description]"
			if(e.status & ORGAN_SALVED)
				ailments |= "Salved"
			if(e.status & ORGAN_BURNT)
				ailments |= "Critical Burn"
			if(e.status & ORGAN_DEAD)
				ailments |= "Dead"
			if(e.is_robotic())
				ailments |= "Robotic"
			if(e.open)
				ailments |= "Open"
			switch(e.germ_level)
				if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
					ailments |= "Mild Infection"
				if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
					ailments |= "Mild Infection+"
				if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
					ailments |= "Mild Infection++"
				if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
					ailments |= "Acute Infection"
				if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
					ailments |= "Acute Infection+"
				if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 399)
					ailments |= "Acute Infection++"
				if(INFECTION_LEVEL_TWO + 400 to INFINITY)
					ailments |= "Septic"

			var/unknown_body = 0
			for(var/I in e.embedded_objects)
				unknown_body++

			if(unknown_body || e.hidden)
				ailments |= "Unknown body present"

			dat += "<td>[e.name]</td>"
			dat += "<td>[e.burn_dam]</td>"
			dat += "<td>[e.brute_dam]</td>"
			dat += "<td>[jointext(ailments, "<br>")]</td>"
			dat += "</tr>"
		dat += "</table>"
		dat += "<br>"

		dat += "<table border='1' style='width:100%'>"
		dat += "<tr>"
		dat += "<th style='width:30%'>Organ</th>"
		dat += "<th style='width:10%'>Damage</th>"
		dat += "<th>Injuries</th>"
		dat += "</tr>"

		for(var/obj/item/organ/internal/i in occupant.internal_organs)
			var/list/ailments = list()

			if(i.status & ORGAN_DEAD)
				ailments |= "Dead"
			switch(i.germ_level)
				if(1 to INFECTION_LEVEL_ONE + 200)
					ailments |= "Mild Infection"
				if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
					ailments |= "Mild Infection+"
				if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
					ailments |= "Mild Infection++"
				if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
					ailments |= "Acute Infection"
				if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
					ailments |= "Acute Infection+"
				if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 399)
					ailments |= "Acute Infection++"
				if(INFECTION_LEVEL_TWO + 400 to INFINITY)
					ailments |= "Septic"
			dat += "<tr>"
			dat += "<td>[i.name]</td>"
			dat += "<td>[i.damage]</td>"
			dat += "<td>[jointext(ailments, "<br>")]</td>"
			dat += "</tr>"
		dat += "</table>"

	else
		dat += "[src] is empty."

	return dat

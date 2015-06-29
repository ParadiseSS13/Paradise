/obj/machinery/bodyscanner
	var/mob/living/carbon/occupant
	var/locked
	name = "Body Scanner"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "bodyscanner-open"
	density = 1
	dir = 8
	anchored = 1
	idle_power_usage = 1250
	active_power_usage = 2500

	light_color = "#00FF00"

	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			set_light(2)
		else
			set_light(0)

/obj/machinery/bodyscanner/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/bodyscanner(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/stack/cable_coil(src, 2)
	RefreshParts()

/obj/machinery/bodyscanner/RefreshParts()

/obj/machinery/bodyscanner/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)
	if (istype(G, /obj/item/weapon/screwdriver))
		if(src.occupant)
			user << "<span class='notice'>The maintenance panel is locked.</span>"
			return
		default_deconstruction_screwdriver(user, "bodyscanner-o", "bodyscanner-open", G)
		return

	if (istype(G, /obj/item/weapon/wrench))
		if(src.occupant)
			user << "<span class='notice'>The scanner is occupied.</span>"
			return
		if(panel_open)
			user << "<span class='notice'>Close the maintenance panel first.</span>"
			return
		if(dir == 4)
			dir = 8
		else
			dir = 4
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)

	if(exchange_parts(user, G))
		return

	default_deconstruction_crowbar(G)

	if(istype(G, /obj/item/weapon/grab))
		if(panel_open)
			user << "\blue <b>Close the maintenance panel first.</b>"
			return
		if(!ismob(G:affecting))
			return
		if (src.occupant)
			user << "\blue <B>The scanner is already occupied!</B>"
			return
		for(var/mob/living/carbon/slime/M in range(1,G:affecting))
			if(M.Victim == G:affecting)
				usr << "[G:affecting.name] will not fit into the sleeper because they have a slime latched onto their head."
				return
		var/mob/M = G:affecting
		if (M.abiotic())
			user << "\blue <B>Subject cannot have abiotic items on.</B>"
			return
		if (M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		src.icon_state = "body_scanner_1"
		src.add_fingerprint(user)
		//G = null
		del(G)
		return

/obj/machinery/bodyscanner/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(!istype(O))
		return
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(panel_open)
		user << "\blue <B>Close the maintenance panel first.</B>"
		return
	if(occupant)
		user << "\blue <B>The body scanner is already occupied!</B>"
		return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		user << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			usr << "[L.name] will not fit into the body scanner because they have a slime latched onto their head."
			return
	if(L == user)
		visible_message("[user] climbs into the body scanner.", 3)
	else
		visible_message("[user] puts [L.name] into the body scanner.", 3)

	if (L.client)
		L.client.perspective = EYE_PERSPECTIVE
		L.client.eye = src
	L.loc = src
	src.occupant = L
	src.icon_state = "bodyscanner"
	src.add_fingerprint(user)
	return

/*/obj/machinery/bodyscanner/allow_drop()
	return 0*/

/obj/machinery/bodyscanner/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if (usr.stat != 0)
		return
	if (src.occupant)
		usr << "\blue <B>The scanner is already occupied!</B>"
		return
	if (panel_open)
		usr << "\blue <B>Close the maintenance panel first.</B>"
		return
	if (usr.abiotic())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "bodyscanner"
	for(var/obj/O in src)
		//O = null
		del(O)
		//Foreach goto(124)
	src.add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "body_scanner_0"
	return

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/bodyscanner/blob_act()
	if(prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/loyalty, /obj/item/weapon/implant/tracking)
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
	component_parts += new /obj/item/weapon/circuitboard/bodyscanner_console(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/stack/cable_coil(src, 2)
	RefreshParts()
	findscanner()

/obj/machinery/body_scanconsole/RefreshParts()

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
		del(src)

/obj/machinery/body_scanconsole/proc/findscanner()
	spawn( 5 )
		var/obj/machinery/bodyscanner/bodyscannernew = null
		// Loop through every direction
		for(dir in list(NORTH,EAST,SOUTH,WEST))
			// Try to find a scanner in that direction
			bodyscannernew = locate(/obj/machinery/bodyscanner, get_step(src, dir))
		src.connected = bodyscannernew
		return
	return

/*

/obj/machinery/body_scanconsole/process() //not really used right now
	if(stat & (NOPOWER|BROKEN))
		return
	//use_power(250) // power stuff

//	var/mob/M //occupant
//	if (!( src.status )) //remove this
//		return
//	if ((src.connected && src.connected.occupant)) //connected & occupant ok
//		M = src.connected.occupant
//	else
//		if (istype(M, /mob))
//		//do stuff
//		else
///			src.temphtml = "Process terminated due to lack of occupant in scanning chamber."
//			src.status = null
//	src.updateDialog()
//	return

*/

/obj/machinery/body_scanconsole/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob, params)
	if (istype(G, /obj/item/weapon/screwdriver))
		default_deconstruction_screwdriver(user, "bodyscannerconsole-p", "bodyscannerconsole", G)
		return

	if (istype(G, /obj/item/weapon/wrench))
		if(panel_open)
			user << "<span class='notice'>Close the maintenance panel first.</span>"
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
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attack_hand(user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if (panel_open)
		user << "<span class='notice'>Close the maintenance panel first.</span>"
		return
	if(!src.connected)
		findscanner()
	if (src.connected)
		if(!connected.occupant)
			user << "<span class='notice'>The scanner is empty.</span>"
			return
		if(!ishuman(connected.occupant))
			user << "\red This device can only scan compatible lifeforms."
			return
		var/dat
		if (src.delete && src.temphtml) //Window in buffer but its just simple message, so nothing
			src.delete = src.delete
		else if (!src.delete && src.temphtml) //Window in buffer - its a menu, dont add clear message
			dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Main Menu</A>", src.temphtml, src)
		else
			if (src.connected) //Is something connected?
				var/mob/living/carbon/human/occupant = src.connected.occupant
				dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>" //Blah obvious
				if (istype(occupant)) //is there REALLY someone in there?
					var/t1
					switch(occupant.stat) // obvious, see what their status is
						if(0)
							t1 = "Conscious"
						if(1)
							t1 = "Unconscious"
						else
							t1 = "*dead*"
					if (!istype(occupant,/mob/living/carbon/human))
						dat += "<font color='red'>This device can only scan human occupants.</FONT>"
					else
						dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)

						if(occupant.virus2.len)
							dat += text("<font color='red'>Viral pathogen detected in blood stream.</font><BR>")

						dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
						dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
						dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
						dat += text("[]\t-Burn Severity %: []</FONT><BR><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())

						dat += text("[]\tRadiation Level %: []</FONT><BR>", (occupant.radiation < 10 ?"<font color='blue'>" : "<font color='red'>"), occupant.radiation)
						dat += text("[]\tGenetic Tissue Damage %: []</FONT><BR>", (occupant.getCloneLoss() < 1 ?"<font color='blue'>" : "<font color='red'>"), occupant.getCloneLoss())
						dat += text("[]\tApprox. Brain Damage %: []</FONT><BR>", (occupant.getBrainLoss() < 1 ?"<font color='blue'>" : "<font color='red'>"), occupant.getBrainLoss())
						dat += text("Paralysis Summary %: [] ([] seconds left!)<BR>", occupant.paralysis, round(occupant.paralysis / 4))
						dat += text("Body Temperature: [occupant.bodytemperature-T0C]&deg;C ([occupant.bodytemperature*1.8-459.67]&deg;F)<BR><HR>")

						if(occupant.has_brain_worms())
							dat += "Large growth detected in frontal lobe, possibly cancerous. Surgical removal is recommended.<BR/>"

						if(occupant.vessel)
							var/blood_volume = round(occupant.vessel.get_reagent_amount("blood"))
							var/blood_percent =  blood_volume / 560
							blood_percent *= 100
							dat += text("[]\tBlood Level %: [] ([] units)</FONT><BR>", (blood_volume > 448 ?"<font color='blue'>" : "<font color='red'>"), blood_percent, blood_volume)
						if(occupant.reagents)
							dat += text("Epinephrine units: [] units<BR>", occupant.reagents.get_reagent_amount("Epinephrine"))
							dat += text("Ether: [] units<BR>", occupant.reagents.get_reagent_amount("ether"))
							dat += text("[]\tSilver Sulfadiazine: [] units</FONT><BR>", (occupant.reagents.get_reagent_amount("silver_sulfadiazine") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("silver_sulfadiazine"))
							dat += text("[]\tStyptic Powder: [] units<BR>", (occupant.reagents.get_reagent_amount("styptic_powder") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("styptic_powder"))
							dat += text("[]\tsalbutamol: [] units<BR>", (occupant.reagents.get_reagent_amount("salbutamol") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("salbutamol"))

						dat += "<HR><table border='1'>"
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
								if(is_type_in_list(I,known_implants))
									imp += "[I] implanted:"
								else
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
						for(var/obj/item/organ/i in occupant.internal_organs)
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
							dat += text("<font color='red'>Cataracts detected.</font><BR>")
						if(occupant.sdisabilities & NEARSIGHTED)
							dat += text("<font color='red'>Retinal misalignment detected.</font><BR>")
						src.printing_text = dat
						dat += "<BR><BR><A href='?src=\ref[src];print_p=1;name=[occupant.name]'>Print medical condition</A><BR>"
				else
					dat += "\The [src] is empty."
			else
				dat = "<font color='red'> Error: No Body Scanner connected.</font>"
		dat += text("<A href='?src=\ref[];mach_close=scanconsole'>Close</A>", user)
		user << browse(dat, "window=scanconsole;size=430x600")
	return

/obj/machinery/body_scanconsole/Topic(href, href_list)
	if(..())
		return 1

	if (href_list["print_p"])
		if (!(src.printing) && src.printing_text)
			src.printing = 1
			for(var/mob/O in viewers(usr))
				O.show_message("\blue \the [src] rattles and prints out a sheet of paper.", 1)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
			P.info = "<CENTER><B>Body Scan - [href_list["name"]]</B></CENTER><BR>"
			P.info += "<b>Time of scan:</b> [worldtime2text(world.time)]<br><br>"
			P.info += "[src.printing_text]"
			P.info += "<br><br><b>Notes:</b><br>"
			P.name = "Body Scan - [href_list["name"]]"
			src.printing = null
			src.printing_text = null
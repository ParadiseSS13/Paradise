/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "console"
	var/obj/machinery/sleeper/connected = null
	var/ui_title = "Sleeper"

	anchored = 1 //About time someone fixed this.
	density = 1
	var/orient = "LEFT"
	dir = 8
	idle_power_usage = 250
	active_power_usage = 500
	interact_offline = 1

/obj/machinery/sleep_console/power_change()
	if(stat & BROKEN)
		icon_state = "console-p"
	else if(powered() && !panel_open)
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "console-p"
			stat |= NOPOWER

/obj/machinery/sleep_console/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/sleep_console(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()
	findsleeper()

/obj/machinery/sleep_console/RefreshParts()

/obj/machinery/sleep_console/process()

/obj/machinery/sleep_console/ex_act(severity)
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

/obj/machinery/sleep_console/proc/findsleeper()
	spawn( 5 )
		var/obj/machinery/sleeper/sleepernew = null
		// Loop through every direction
		for(dir in list(NORTH,EAST,SOUTH,WEST))
			// Try to find a scanner in that direction
			sleepernew = locate(/obj/machinery/sleeper, get_step(src, dir))
		src.connected = sleepernew
		return
	return

/obj/machinery/sleeper/attack_animal(var/mob/living/simple_animal/M)//Stop putting hostile mobs in things guise
	if(M.environment_smash)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] smashes [src] apart!</span>")
		qdel(src)
	return

/obj/machinery/sleep_console/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob, params)
	if (istype(G, /obj/item/weapon/screwdriver))
		default_deconstruction_screwdriver(user, "console-p", "console", G)
		return

	if (istype(G, /obj/item/weapon/wrench))
		if(panel_open)
			user << "<span class='notice'>Close the maintenance panel first.</span>"
			return
		if(dir == 4)
			orient = "LEFT"
			dir = 8
		else
			orient = "RIGHT"
			dir = 4
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)

	if(exchange_parts(user, G))
		return

	default_deconstruction_crowbar(G)

/obj/machinery/sleep_console/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/sleep_console/attack_ghost(mob/user as mob)
	return attack_hand(user)

/obj/machinery/sleep_console/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return

	if (panel_open)
		user << "<span class='notice'>Close the maintenance panel first.</span>"
		return

	if (!src.connected)
		findsleeper()

	if (src.connected)
		ui_interact(user)

/obj/machinery/sleep_console/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	var/mob/living/carbon/human/occupant = connected.occupant
	data["hasOccupant"] = occupant ? 1 : 0
	var/occupantData[0]
	var/crisis = 0
	if (occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = config.health_threshold_dead
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["paralysis"] = occupant.paralysis
		occupantData["hasBlood"] = 0
		occupantData["bodyTemperature"] = occupant.bodytemperature
		occupantData["maxTemp"] = 1000 // If you get a burning vox armalis into the sleeper, congratulations
		// Because we can put simple_animals in here, we need to do something tricky to get things working nice
		occupantData["temperatureSuitability"] = 0 // 0 is the baseline
		if (ishuman(occupant) && occupant.species)
			// I wanna do something where the bar gets bluer as the temperature gets lower
			// For now, I'll just use the standard format for the temperature status
			var/datum/species/sp = occupant.species
			if (occupant.bodytemperature < sp.cold_level_3)
				occupantData["temperatureSuitability"] = -3
			else if (occupant.bodytemperature < sp.cold_level_2)
				occupantData["temperatureSuitability"] = -2
			else if (occupant.bodytemperature < sp.cold_level_1)
				occupantData["temperatureSuitability"] = -1
			else if (occupant.bodytemperature > sp.heat_level_3)
				occupantData["temperatureSuitability"] = 3
			else if (occupant.bodytemperature > sp.heat_level_2)
				occupantData["temperatureSuitability"] = 2
			else if (occupant.bodytemperature > sp.heat_level_1)
				occupantData["temperatureSuitability"] = 1
		else if (istype(occupant, /mob/living/simple_animal))
			var/mob/living/simple_animal/silly = occupant
			if (silly.bodytemperature < silly.minbodytemp)
				occupantData["temperatureSuitability"] = -3
			else if (silly.bodytemperature > silly.maxbodytemp)
				occupantData["temperatureSuitability"] = 3
		// Blast you, imperial measurement system
		occupantData["btCelsius"] = occupant.bodytemperature - T0C
		occupantData["btFaren"] = ((occupant.bodytemperature - T0C) * (9.0/5.0))+ 32


		crisis = (occupant.health < connected.min_health)
		// I'm not sure WHY you'd want to put a simple_animal in a sleeper, but precedent is precedent
		// Runtime is aptly named, isn't she?
		if (ishuman(occupant) && occupant.vessel && !(occupant.species && occupant.species.flags & NO_BLOOD))
			occupantData["pulse"] = occupant.get_pulse(GETPULSE_TOOL)
			occupantData["hasBlood"] = 1
			occupantData["bloodLevel"] = round(occupant.vessel.get_reagent_amount("blood"))
			occupantData["bloodMax"] = occupant.max_blood
			occupantData["bloodPercent"] = round(100*(occupant.vessel.get_reagent_amount("blood")/occupant.max_blood), 0.01)

	data["occupant"] = occupantData
	data["maxchem"] = connected.max_chem
	data["minhealth"] = connected.min_health
	data["dialysis"] = connected.filtering
	if (connected.beaker)
		data["isBeakerLoaded"] = 1
		data["beakerFreeSpace"] = round(connected.beaker.reagents.maximum_volume - connected.beaker.reagents.total_volume)

	var/chemicals[0]
	for (var/re in connected.injection_chems)
		var/datum/reagent/temp = chemical_reagents_list[re]
		if(temp)
			var/reagent_amount = 0
			var/pretty_amount
			var/injectable = occupant ? 1 : 0
			var/overdosing = 0
			var/caution = 0 // To make things clear that you're coming close to an overdose
			if (crisis && !(temp.id in connected.emergency_chems))
				injectable = 0

			if (occupant && occupant.reagents)
				reagent_amount = occupant.reagents.get_reagent_amount(temp.id)
				// If they're mashing the highest concentration, they get one warning
				if (temp.overdose_threshold && reagent_amount + 10 > temp.overdose_threshold)
					caution = 1
				if (temp.id in occupant.reagents.overdose_list())
					overdosing = 1

			// Because I don't know how to do this on the nano side
			pretty_amount = round(reagent_amount, 0.05)

			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("chemical" = temp.id), "occ_amount" = reagent_amount, "pretty_amount" = pretty_amount, "injectable" = injectable, "overdosing" = overdosing, "od_warning" = caution)))
	data["chemicals"] = chemicals

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "sleeper.tmpl", ui_title, 550, 655)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/sleep_console/Topic(href, href_list)
	if(!connected | usr == connected.occupant)
		return 0

	if(..())
		return 1

	if(panel_open)
		usr << "<span class='notice'>Close the maintenance panel first.</span>"
		return 0

	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		if (href_list["chemical"])
			if (src.connected)
				if (src.connected.occupant)
					if (src.connected.occupant.stat == DEAD)
						usr << "<span class='danger'>This person has no life for to preserve anymore. Take them to a department capable of reanimating them.</span>"
					else if(src.connected.occupant.health > src.connected.min_health || (href_list["chemical"] in connected.emergency_chems))
						src.connected.inject_chemical(usr,href_list["chemical"],text2num(href_list["amount"]))
					else
						usr << "<span class='danger'>This person is not in good enough condition for sleepers to be effective! Use another means of treatment, such as cryogenics!</span>"
		if (href_list["removebeaker"])
			src.connected.remove_beaker()
		if (href_list["togglefilter"])
			src.connected.toggle_filter()
		if (href_list["ejectify"])
			src.connected.eject()
		src.add_fingerprint(usr)
	return 1

/////////////////////////////////////////
// THE SLEEPER ITSELF
/////////////////////////////////////////

/obj/machinery/sleeper
	name = "Sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper-open"
	density = 1
	anchored = 1
	dir = 8
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/living/carbon/human/occupant = null
	var/possible_chems = list(list("epinephrine", "ether", "salbutamol", "styptic_powder"),
								   list("epinephrine", "ether", "salbutamol", "styptic_powder", "oculine"),
								   list("epinephrine", "ether", "salbutamol", "styptic_powder", "oculine", "charcoal", "mutadone", "mannitol"),
								   list("epinephrine", "ether", "salbutamol", "styptic_powder", "oculine", "charcoal", "mutadone", "mannitol", "pen_acid", "omnizine"))
	var/emergency_chems = list("epinephrine") // Desnowflaking
	var/amounts = list(5, 10)
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/filtering = 0
	var/max_chem
	var/initial_bin_rating = 1
	var/min_health = -25
	var/injection_chems = list()
	idle_power_usage = 1250
	active_power_usage = 2500

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/sleeper/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/sleeper/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/sleeper(null)

	// Customizable bin rating, used by the labor camp to stop people filling themselves with chemicals and escaping.
	var/obj/item/weapon/stock_parts/matter_bin/B = new(null)
	B.rating = initial_bin_rating
	component_parts += B

	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/sleeper/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/sleeper(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/sleeper/RefreshParts()
	var/E
	var/I
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		I += M.rating

	injection_chems = possible_chems[I]
	max_chem = E * 20
	min_health = -E * 25

/obj/machinery/sleeper/relaymove(mob/user as mob)
	if(user.incapacitated())
		return 0 //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/sleeper/process()
	if(filtering > 0)
		if(beaker)
			// To prevent runtimes from drawing blood from runtime, and to prevent getting IPC blood.
			if(!istype(occupant) || !occupant.dna || (occupant.species && occupant.species.flags & NO_BLOOD))
				filtering = 0
				return

			if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
				src.occupant.vessel.trans_to(beaker, 1)
				for(var/datum/reagent/x in src.occupant.reagents.reagent_list)
					src.occupant.reagents.trans_to(beaker, 3)
					src.occupant.vessel.trans_to(beaker, 1)
	src.updateDialog()
	return


/obj/machinery/sleeper/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(src.loc)
			A.blob_act()
		qdel(src)
	return


/obj/machinery/sleeper/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob, params)
	if(istype(G, /obj/item/weapon/reagent_containers/glass))
		if(!beaker)
			if (!user.drop_item())
				user << "<span class='warning'>\The [G] is stuck to you!</span>"
				return

			beaker = G
			G.forceMove(src)
			user.visible_message("[user] adds \a [G] to \the [src]!", "You add \a [G] to \the [src]!")
			return

		else
			user << "<span class='warning'>The sleeper has a beaker already.</span>"
			return

	if (istype(G, /obj/item/weapon/screwdriver))
		if(src.occupant)
			user << "<span class='notice'>The maintenance panel is locked.</span>"
			return
		default_deconstruction_screwdriver(user, "sleeper-o", "sleeper-open", G)
		return

	if (istype(G, /obj/item/weapon/wrench))
		if(src.occupant)
			user << "<span class='notice'>The scanner is occupied.</span>"
			return
		if(panel_open)
			user << "<span class='notice'>Close the maintenance panel first.</span>"
			return
		if(dir == 4)
			orient = "LEFT"
			dir = 8
		else
			orient = "RIGHT"
			dir = 4
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)

	if(exchange_parts(user, G))
		return

	default_deconstruction_crowbar(G)

	if(istype(G, /obj/item/weapon/grab))
		if(panel_open)
			user << "<span class='boldnotice'>Close the maintenance panel first.</span>"
			return
		if(!ismob(G:affecting))
			return
		if(src.occupant)
			user << "<span class='boldnotice'>The sleeper is already occupied!</span>"
			return
		for(var/mob/living/carbon/slime/M in range(1,G:affecting))
			if(M.Victim == G:affecting)
				usr << "[G:affecting.name] will not fit into the sleeper because they have a slime latched onto their head."
				return

		visible_message("[user] starts putting [G:affecting:name] into the sleeper.")

		if(do_after(user, 20, target = G:affecting))
			if(src.occupant)
				user << "<span class='boldnotice'>The sleeper is already occupied!</span>"
				return
			if(!G || !G:affecting) return
			var/mob/M = G:affecting
			if(M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.forceMove(src)
			src.occupant = M
			src.icon_state = "sleeper"
			M << "<span class='boldnotice'>You feel cool air surround you. You go numb as your senses turn inward.</span>"

			src.add_fingerprint(user)
			qdel(G)
		return
	return


/obj/machinery/sleeper/ex_act(severity)
	if(filtering)
		toggle_filter()
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(src.loc)
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					ex_act(severity)
				qdel(src)
				return
	return

/obj/machinery/sleeper/emp_act(severity)
	if(filtering)
		toggle_filter()
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

// ???
// This looks cool, although mildly broken, should it be included again?
/obj/machinery/sleeper/alter_health(mob/living/M as mob)
	if (M.health > 0)
		if (M.getOxyLoss() >= 10)
			var/amount = max(0.15, 1)
			M.adjustOxyLoss(-amount)
		else
			M.adjustOxyLoss(-12)
		M.updatehealth()
	M.AdjustParalysis(-4)
	M.AdjustWeakened(-4)
	M.AdjustStunned(-4)
	if (M:reagents.get_reagent_amount("salglu_solution") < 5)
		M:reagents.add_reagent("salglu_solution", 5)
	return

/obj/machinery/sleeper/proc/toggle_filter()
	if(filtering)
		filtering = 0
	else
		filtering = 1

/obj/machinery/sleeper/proc/go_out()
	if(filtering)
		toggle_filter()
	if(!src.occupant)
		return
	if(src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.forceMove(src.loc)
	src.occupant = null
	icon_state = "sleeper-open"
	return

/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if (!(chemical in injection_chems))
		user << "<span class='notice'>The sleeper does not offer that chemical!</notice>"
		return

	if(src.occupant)
		if(src.occupant.reagents)
			if(src.occupant.reagents.get_reagent_amount(chemical) + amount <= max_chem)
				src.occupant.reagents.add_reagent(chemical, amount)
				return
			else
				user << "You can not inject any more of this chemical."
				return
		else
			user << "The patient rejects the chemicals!"
			return
	else
		user << "There's no occupant in the sleeper!"
		return

/obj/machinery/sleeper/verb/eject()
	set name = "Eject Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	src.icon_state = "sleeper-open"
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/sleeper/verb/remove_beaker()
	set name = "Remove Beaker"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(beaker)
		filtering = 0
		beaker.forceMove(usr.loc)
		beaker = null
	add_fingerprint(usr)
	return

/obj/machinery/sleeper/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return
	if(get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robots dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(panel_open)
		user << "<span class='boldnotice'>Close the maintenance panel first.</span>"
		return
	if(occupant)
		user << "<span class='boldnotice'>The sleeper is already occupied!</span>"
		return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		user << "<span class='boldnotice'>Subject cannot have abiotic items on.</span>"
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			usr << "[L.name] will not fit into the sleeper because they have a slime latched onto their head."
			return
	if(L == user)
		visible_message("[user] starts climbing into the sleeper.")
	else
		visible_message("[user] starts putting [L.name] into the sleeper.")

	if(do_after(user, 20, target = L))
		if(src.occupant)
			user << "<span class='boldnotice'>>The sleeper is already occupied!</span>"
			return
		if(!L) return

		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
		L.forceMove(src)
		src.occupant = L
		src.icon_state = "sleeper"
		L << "<span class='boldnotice'>You feel cool air surround you. You go numb as your senses turn inward.</span>"
		src.add_fingerprint(user)
		if(user.pulling == L)
			user.stop_pulling()
		return
	return

/obj/machinery/sleeper/allow_drop()
	return 0

/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0 || !(ishuman(usr)))
		return
	if(src.occupant)
		usr << "<span class='boldnotice'>The sleeper is already occupied!</span>"
		return
	if (panel_open)
		usr << "<span class='boldnotice'>Close the maintenance panel first.</span>"
		return
	if(usr.restrained() || usr.stat || usr.weakened || usr.stunned || usr.paralysis || usr.resting) //are you cuffed, dying, lying, stunned or other
		return
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "You're too busy getting your life sucked out of you."
			return
	visible_message("[usr] starts climbing into the sleeper.")
	if(do_after(usr, 20, target = usr))
		if(src.occupant)
			usr << "<span class='boldnotice'>The sleeper is already occupied!</span>"
			return
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.forceMove(src)
		src.occupant = usr
		src.icon_state = "sleeper"

		for(var/obj/O in src)
			qdel(O)
		src.add_fingerprint(usr)
		return
	return
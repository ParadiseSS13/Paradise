// the SMES
// stores power

#define SMESMAXCHARGELEVEL 200000
#define SMESMAXOUTPUT 200000
#define SMESRATE 0.05			// rate of internal charge to external power



/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = TRUE

	var/capacity = 5e6 // maximum charge
	var/charge = 0 // actual charge

	var/input_attempt = TRUE 		// 1 = attempting to charge, 0 = not attempting to charge
	var/inputting = TRUE 			// 1 = actually inputting, 0 = not inputting
	var/input_level = 50000 		// amount of power the SMES attempts to charge by
	var/input_level_max = 200000 	// cap on input_level
	var/input_available = 0 		// amount of charge available from input last tick

	var/output_attempt = TRUE 		// 1 = attempting to output, 0 = not attempting to output
	var/outputting = TRUE			// 1 = actually outputting, 0 = not outputting
	var/output_level = 50000		// amount of power the SMES attempts to output
	var/output_level_max = 200000	// cap on output_level
	var/output_used = 0				// amount of power actually outputted. may be less than output_level if the powernet returns excess power

	var/name_tag = null
	var/obj/machinery/power/terminal/terminal = null

/obj/machinery/power/smes/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/smes(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

	dir_loop:
		for(var/d in GLOB.cardinal)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/term in T)
				if(term && term.dir == turn(d, 180))
					terminal = term
					break dir_loop

	if(!terminal)
		stat |= BROKEN
		return
	terminal.master = src
	update_icon()

/obj/machinery/power/smes/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/smes(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/power/smes/RefreshParts()
	var/IO = 0
	var/C = 0
	for(var/obj/item/stock_parts/capacitor/CP in component_parts)
		IO += CP.rating
	input_level_max = 200000 * IO
	output_level_max = 200000 * IO
	for(var/obj/item/stock_parts/cell/PC in component_parts)
		C += PC.maxcharge
	capacity = C / (15000) * 1e6

/obj/machinery/power/smes/update_overlays()
	. = ..()
	if(stat & BROKEN)
		return

	. += "smes-op[outputting ? 1 : 0]"
	. += "smes-oc[inputting ? 1 : 0]"

	var/charge_level = chargedisplay()
	if(charge_level > 0)
		. += "smes-og[charge_level]"

/obj/machinery/power/smes/attackby(obj/item/I, mob/user, params)
	//opening using screwdriver
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_icon()
		return

	//changing direction using wrench
	if(default_change_direction_wrench(user, I))
		terminal = null
		var/turf/T = get_step(src, dir)
		for(var/obj/machinery/power/terminal/term in T)
			if(term && term.dir == turn(dir, 180))
				terminal = term
				terminal.master = src
				to_chat(user, "<span class='notice'>Terminal found.</span>")
				break
		if(!terminal)
			to_chat(user, "<span class='alert'>No power source found.</span>")
			return
		stat &= ~BROKEN
		update_icon()
		return

	//exchanging parts using the RPE
	if(exchange_parts(user, I))
		return

	//building and linking a terminal
	if(istype(I, /obj/item/stack/cable_coil))
		var/dir = get_dir(user,src)
		if(dir & (dir-1))//we don't want diagonal click
			return

		if(terminal) //is there already a terminal ?
			to_chat(user, "<span class='alert'>This SMES already has a power terminal!</span>")
			return

		if(!panel_open) //is the panel open ?
			to_chat(user, "<span class='alert'>You must open the maintenance panel first!</span>")
			return

		var/turf/T = get_turf(user)
		if(T.intact) //is the floor plating removed ?
			to_chat(user, "<span class='alert'>You must first remove the floor plating!</span>")
			return

		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 10)
			to_chat(user, "<span class='alert'>You need more wires.</span>")
			return

		if(user.loc == loc)
			to_chat(user, "<span class='warning'>You must not be on the same tile as [src].</span>")
			return

		//Direction the terminal will face to
		var/tempDir = get_dir(user, src)
		switch(tempDir)
			if(NORTHEAST, SOUTHEAST)
				tempDir = EAST
			if(NORTHWEST, SOUTHWEST)
				tempDir = WEST
		var/turf/tempLoc = get_step(src, reverse_direction(tempDir))
		if(isspaceturf(tempLoc))
			to_chat(user, "<span class='warning'>You can't build a terminal on space.</span>")
			return
		else if(istype(tempLoc))
			if(tempLoc.intact)
				to_chat(user, "<span class='warning'>You must remove the floor plating first.</span>")
				return

		to_chat(user, "<span class='notice'>You start adding cable to [src].</span>")
		playsound(loc, C.usesound, 50, 1)

		if(do_after(user, 50, target = src))
			if(!terminal && panel_open)
				T = get_turf(user)
				var/obj/structure/cable/N = T.get_cable_node() //get the connecting node cable, if there's one
				if(prob(50) && electrocute_mob(usr, N, N, 1, TRUE)) //animate the electrocution if uncautious and unlucky
					do_sparks(5, 1, src)
					return

				C.use(10) // make sure the cable gets used up
				user.visible_message(\
					"<span class='notice'>[user.name] adds the cables and connects the power terminal.</span>",\
					"<span class='notice'>You add the cables and connect the power terminal.</span>")

				make_terminal(user, tempDir, tempLoc)
				terminal.connect_to_network()
		return

	//disassembling the terminal
	if(istype(I, /obj/item/wirecutters) && terminal && panel_open)
		var/turf/T = get_turf(terminal)
		if(T.intact) //is the floor plating removed ?
			to_chat(user, "<span class='alert'>You must first expose the power terminal!</span>")
			return

		to_chat(user, "<span class='notice'>You begin to dismantle the power terminal...</span>")
		playsound(src.loc, I.usesound, 50, 1)

		if(do_after(user, 50 * I.toolspeed, target = src))
			if(terminal && panel_open)
				if(prob(50) && electrocute_mob(usr, terminal.powernet, terminal, 1, TRUE)) //animate the electrocution if uncautious and unlucky
					do_sparks(5, 1, src)
					return

				//give the wires back and delete the terminal
				new /obj/item/stack/cable_coil(T,10)
				user.visible_message(\
					"<span class='alert'>[user.name] cuts the cables and dismantles the power terminal.</span>",\
					"<span class='notice'>You cut the cables and dismantle the power terminal.</span>")
				inputting = 0 //stop inputting, since we have don't have a terminal anymore
				qdel(terminal)
				return

	//crowbarring it !
	if(default_deconstruction_crowbar(user, I))
		return
	return ..()

/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null
		return TRUE
	return FALSE

/obj/machinery/power/smes/proc/make_terminal(user, tempDir, tempLoc)
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new /obj/machinery/power/terminal(tempLoc)
	terminal.dir = tempDir
	terminal.master = src

/obj/machinery/power/smes/Destroy()
	if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
		var/area/area = get_area(src)
		if(area)
			message_admins("SMES deleted at (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>[area.name]</a>)")
			log_game("SMES deleted at ([area.name])")
			investigate_log("<font color='red'>deleted</font> at ([area.name])","singulo")
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/smes/proc/chargedisplay()
	return clamp(round(5.5 * charge / capacity), 0, 5)

/obj/machinery/power/smes/process()
	if(stat & BROKEN)
		return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = inputting
	var/last_onln = outputting

	//inputting
	if(terminal && input_attempt)
		input_available = terminal.get_power_balance()

		if(inputting)
			if(input_available > 0)		// if there's power available, try to charge

				var/load = min(min((capacity-charge)/SMESRATE, input_level), input_available)		// charge at set rate, limited to spare capacity

				charge += load * SMESRATE	// increase the charge

				terminal.consume_direct_power(load) // add the load to the terminal side network

			else					// if not enough capcity
				inputting = FALSE		// stop inputting

		else
			if(input_attempt && input_available > 0)
				inputting = TRUE
	else
		inputting = FALSE

	//outputting
	if(output_attempt)
		if(outputting)
			output_used = min( charge/SMESRATE, output_level)		//limit output to that stored
			if(produce_direct_power(output_used))				// add output to powernet if it exists (smes side)
				charge -= output_used*SMESRATE		// reduce the storage (may be recovered in /restore() if excessive)
			else
				outputting = FALSE

			if(output_used < 0.0001)		// either from no charge or set to 0
				outputting = FALSE
				investigate_log("lost power and turned <font color='red'>off</font>", "singulo")
		else if(output_attempt && charge > output_level && output_level > 0)
			outputting = TRUE
		else
			output_used = 0
	else
		outputting = FALSE

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting)
		update_icon()



// called after all power processes are finished
// restores charge level to smes if there was excess this ptick
/obj/machinery/power/smes/proc/restore()
	if(stat & BROKEN)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = powernet.excess_power		// this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(output_used, excess)				// clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity-charge)/SMESRATE, excess)	// for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount

	var/clev = chargedisplay()

	charge += excess * SMESRATE			// restore unused power
	powernet.excess_power -= excess		// remove the excess from the powernet, so later SMESes don't try to use it

	output_used -= excess

	if(clev != chargedisplay()) //if needed updates the icons overlay
		update_icon()
	return

/obj/machinery/power/smes/attack_ai(mob/user)
	add_hiddenprint(user)
	ui_interact(user)

/obj/machinery/power/smes/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/power/smes/attack_hand(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/power/smes/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(stat & BROKEN)
		return
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Smes",  name, 340, 350, master_ui, state)
		ui.open()

/obj/machinery/power/smes/ui_data(mob/user)
	var/list/data = list(
		"capacity" = capacity,
		"capacityPercent" = round(100*charge/capacity, 0.1),
		"charge" = charge,
		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputLevel_text" = DisplayPower(input_level),
		"inputLevelMax" = input_level_max,
		"inputAvailable" = input_available,
		"outputAttempt" = output_attempt,
		"outputting" = outputting,
		"outputLevel" = output_level,
		"outputLevel_text" = DisplayPower(output_level),
		"outputLevelMax" = output_level_max,
		"outputUsed" = round(output_used),
	)
	return data

/obj/machinery/power/smes/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("tryinput")
			inputting(!input_attempt)
			update_icon()
		if("tryoutput")
			outputting(!output_attempt)
			update_icon()
		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
			else if(target == "max")
				target = input_level_max
			else if(adjust)
				target = input_level + adjust
			else if(text2num(target) != null)
				target = text2num(target)
			else
				. = FALSE
			if(.)
				input_level = clamp(target, 0, input_level_max)
		if("output")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
			else if(target == "max")
				target = output_level_max
			else if(adjust)
				target = output_level + adjust
			else if(text2num(target) != null)
				target = text2num(target)
			else
				. = FALSE
			if(.)
				output_level = clamp(target, 0, output_level_max)
		else
			. = FALSE
	if(.)
		log_smes(usr)

/obj/machinery/power/smes/proc/log_smes(mob/user)
		investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Charge: [charge] | Output-mode: [output_attempt?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_attempt?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [user ? key_name(user) : "outside forces"]", "singulo")

/obj/machinery/power/smes/proc/ion_act()
	if(is_station_level(src.z))
		if(prob(1)) //explosion
			for(var/mob/M in viewers(src))
				M.show_message("<span class='warning'>[src] is making strange noises!</span>", 3, "<span class='warning'>You hear sizzling electronics.</span>", 2)
			sleep(10*pick(4,5,6,7,10,14))
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(3, FALSE, loc)
			smoke.attach(src)
			smoke.start()
			explosion(src.loc, -1, 0, 1, 3, 1, 0)
			qdel(src)
			return
		if(prob(15)) //Power drain
			do_sparks(3, 1, src)
			if(prob(50))
				emp_act(1)
			else
				emp_act(2)
		if(prob(5)) //smoke only
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(3, FALSE, loc)
			smoke.attach(src)
			smoke.start()


/obj/machinery/power/smes/proc/inputting(do_input)
	input_attempt = do_input
	if(!input_attempt)
		inputting = 0

/obj/machinery/power/smes/proc/outputting(do_output)
	output_attempt = do_output
	if(!output_attempt)
		outputting = 0

/obj/machinery/power/smes/emp_act(severity)
	inputting(rand(0, 1))
	outputting(rand(0, 1))
	output_level = rand(0, output_level_max)
	input_level = rand(0, input_level_max)
	charge -= 1e6/severity
	if(charge < 0)
		charge = 0
	update_icon()
	log_smes()
	..()

/obj/machinery/power/smes/engineering
	charge = 2e6 // Engineering starts with some charge for singulo

/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."
	capacity = 9000000
	output_level = 250000

/obj/machinery/power/smes/magical/process()
	capacity = INFINITY
	charge = INFINITY
	..()

#undef SMESRATE

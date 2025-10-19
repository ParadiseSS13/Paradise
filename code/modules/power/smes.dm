#define SMESMAXCHARGELEVEL 200000
#define SMESMAXOUTPUT 200000
/// Conversion ratio between a Watt-tick and SMES capacity units (should be the same as power cells)
#define SMESRATE GLOB.CELLRATE

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = TRUE

	/// Maximum amount of energy the SMES can store (kilojoules)
	var/capacity = 0.2e6
	/// Current charge level
	var/charge = 0
	/// Set TRUE if SMES attempting to charge, FALSE if not
	var/input_attempt = TRUE
	/// Set TRUE if SMES is inputting, FALSE if not
	var/inputting = TRUE
	/// How much power the SMES will draw from the grid to recharge itself (Watts)
	var/input_level = 50000
	/// Maximum input level (Watts)
	var/input_level_max = 200000
	/// Charge amount available from input last tick
	var/input_available = 0
	// TRUE = attempting to output, FALSE = not attempting to output
	var/output_attempt = TRUE
	/// TRUE = actually outputting, FALSE = not outputting
	var/outputting = TRUE
	/// Amount of power the SMES attempts to output (Watts)
	var/output_level = 50000
	/// Cap on output_level (Watts)
	var/output_level_max = 200000
	/// Amount of power actually outputted. may be less than output_level if the powernet returns excess power
	var/output_used = 0
	/// The terminal that is connected to this SMES unit
	var/obj/machinery/power/terminal/terminal

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

	// When (re)built, try to connect to the powernet under us.
	connect_to_network()

	dir_loop:
		for(var/direction in GLOB.cardinal)
			var/turf/T = get_step(src, direction)
			for(var/obj/machinery/power/terminal/term in T)
				if(term && term.dir == turn(direction, 180))
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
	capacity = C * 1e3 / 375

/obj/machinery/power/smes/update_overlays()
	. = ..()
	if(stat & BROKEN)
		return

	. += "smes-op[outputting ? TRUE : FALSE]"
	. += "smes-oc[inputting ? TRUE : FALSE]"

	var/charge_level = charge_display()
	if(charge_level > 0)
		. += "smes-og[charge_level]"

/obj/machinery/power/smes/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	// Opening using screwdriver
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), used))
		update_icon()
		return ITEM_INTERACT_COMPLETE

	// Changing direction using wrench
	if(default_change_direction_wrench(user, used))
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
			return ITEM_INTERACT_COMPLETE
		stat &= ~BROKEN
		update_icon()
		return ITEM_INTERACT_COMPLETE

	// Building and linking a terminal
	if(istype(used, /obj/item/stack/cable_coil))
		var/dir = get_dir(user, src)
		if(dir & (dir - 1)) // Checks for diagonal interaction
			return ITEM_INTERACT_COMPLETE

		if(terminal) // Checks for an existing terminal
			to_chat(user, "<span class='alert'>This SMES already has a power terminal!</span>")
			return ITEM_INTERACT_COMPLETE

		if(!panel_open) // Checks to see if the panel is closed
			to_chat(user, "<span class='alert'>You must open the maintenance panel first!</span>")
			return ITEM_INTERACT_COMPLETE

		var/turf/T = get_turf(user)
		if(T.intact) // Checks to see if floor plating is present
			to_chat(user, "<span class='alert'>You must first remove the floor plating!</span>")
			return ITEM_INTERACT_COMPLETE

		var/obj/item/stack/cable_coil/C = used
		if(C.get_amount() < 10)
			to_chat(user, "<span class='alert'>You need more wires.</span>")
			return ITEM_INTERACT_COMPLETE

		if(user.loc == loc)
			to_chat(user, "<span class='warning'>You must not be on the same tile as [src].</span>")
			return ITEM_INTERACT_COMPLETE

		// Direction the terminal will face to
		var/temporary_direction = get_dir(user, src)
		switch(temporary_direction)
			if(NORTHEAST, SOUTHEAST)
				temporary_direction = EAST
			if(NORTHWEST, SOUTHWEST)
				temporary_direction = WEST
		var/turf/temporary_location = get_step(src, REVERSE_DIR(temporary_direction))

		if(isspaceturf(temporary_location))
			to_chat(user, "<span class='warning'>You can't build a terminal on space.</span>")
			return ITEM_INTERACT_COMPLETE

		else if(istype(temporary_location))
			if(temporary_location.intact)
				to_chat(user, "<span class='warning'>You must remove the floor plating first.</span>")
				return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You start adding cable to [src].</span>")
		playsound(loc, C.usesound, 50, TRUE)

		if(do_after(user, 5 SECONDS, target = src))
			if(!terminal && panel_open)
				T = get_turf(user)
				var/obj/structure/cable/N = T.get_cable_node() //get the connecting node cable, if there's one
				if(prob(50) && electrocute_mob(usr, N, N, 1, TRUE)) //animate the electrocution if uncautious and unlucky
					do_sparks(5, TRUE, src)
					return

				C.use(10) // make sure the cable gets used up
				user.visible_message(\
					"<span class='notice'>[user.name] adds the cables and connects the power terminal.</span>",\
					"<span class='notice'>You add the cables and connect the power terminal.</span>")

				make_terminal(user, temporary_direction, temporary_location)
				terminal.connect_to_network()
				stat &= ~BROKEN
		return ITEM_INTERACT_COMPLETE

	// Disassembling the terminal
	if(istype(used, /obj/item/wirecutters) && terminal && panel_open)
		var/turf/T = get_turf(terminal)
		if(T.intact) //is the floor plating removed ?
			to_chat(user, "<span class='alert'>You must first expose the power terminal!</span>")
			return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You begin to dismantle the power terminal...</span>")
		playsound(src.loc, used.usesound, 50, TRUE)

		if(do_after(user, 5 SECONDS * used.toolspeed, target = src))
			if(terminal && panel_open)
				if(prob(50) && electrocute_mob(usr, terminal.powernet, terminal, 1, TRUE)) // Animate the electrocution if uncautious and unlucky
					do_sparks(5, TRUE, src)
					return ITEM_INTERACT_COMPLETE

				// Returns wires on deletion of the terminal
				new /obj/item/stack/cable_coil(T, 10)
				user.visible_message(\
					"<span class='alert'>[user.name] cuts the cables and dismantles the power terminal.</span>",\
					"<span class='notice'>You cut the cables and dismantle the power terminal.</span>")
				inputting = FALSE // Set input FALSE when the terminal no longer exists
				qdel(terminal)
				return ITEM_INTERACT_COMPLETE

	// Crowbarring it !
	if(default_deconstruction_crowbar(user, used))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null
		return TRUE
	return FALSE

/obj/machinery/power/smes/proc/make_terminal(user, temporary_direction, temporary_location)
	// Create a terminal object at the same position as original turf loc
	// Wires will attach to this
	terminal = new /obj/machinery/power/terminal(temporary_location)
	terminal.dir = temporary_direction
	terminal.master = src

/obj/machinery/power/smes/Destroy()
	if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
		var/area/area = get_area(src)
		if(area)
			message_admins("SMES deleted at (<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>[area.name]</a>)")
			log_game("SMES deleted at ([area.name])")
			investigate_log("<font color='red'>deleted</font> at ([area.name])", INVESTIGATE_SINGULO)
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/smes/proc/charge_display()
	return clamp(round(ceil(charge * 5 / capacity)), 0, 5)

/obj/machinery/power/smes/process()
	if(stat & BROKEN)
		return

	// Store machine state to see if we need to update the icon overlays
	var/last_disp = charge_display()
	var/last_chrg = inputting
	var/last_onln = outputting

	// Inputting
	if(terminal && input_attempt)
		input_available = terminal.get_power_balance()

		if(inputting)
			if(input_available > 0)		// Checks power availability before attempting to charge

				var/load = min(min((capacity - charge) / SMESRATE, input_level), input_available)		// Charge at set rate, limited to spare capacity

				charge += load * SMESRATE	// Increase the charge

				terminal.consume_direct_power(load) // Add the load to the terminal side network

			else
				inputting = FALSE // Set inputting FALSE if not enough capacity

		else
			if(input_attempt && input_available > 0)
				inputting = TRUE
	else
		inputting = FALSE

	//outputting
	if(output_attempt && powernet)
		if(outputting)
			output_used = min( charge/SMESRATE, output_level)		// Limit output to that stored
			if(produce_direct_power(output_used))				// Add output to powernet if it exists (smes side)
				charge -= output_used * SMESRATE		// Reduce the storage (may be recovered in /restore() if excessive)
			else
				outputting = FALSE

			if(output_used < 0.0001)		// Either from no charge or set to 0
				outputting = FALSE
				investigate_log("lost power and turned <font color='red'>off</font>", INVESTIGATE_SINGULO)
		else if(output_attempt && charge > 0 && output_level > 0)
			outputting = TRUE
		else
			output_used = 0
	else
		outputting = FALSE

	// Only update icon if state changed
	if(last_disp != charge_display() || last_chrg != inputting || last_onln != outputting)
		update_icon()


// Called after all power processes are finished
// Restores charge level to smes if there was excess this ptick
/obj/machinery/power/smes/proc/restore()
	if(stat & BROKEN)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = powernet.excess_power		// This was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(output_used, excess)				// Clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity-charge)/SMESRATE, excess)	// For safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount

	var/clev = charge_display()

	charge += excess * SMESRATE			// Restore unused power
	powernet.excess_power -= excess		// Remove the excess from the powernet, so later SMESes don't try to use it

	output_used -= excess

	if(clev != charge_display()) // If needed updates the icons overlay
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

/obj/machinery/power/smes/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/power/smes/ui_interact(mob/user, datum/tgui/ui = null)
	if(stat & BROKEN)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smes",  name)
		ui.open()

/obj/machinery/power/smes/ui_data(mob/user)
	var/list/data = list(
		"capacity" = capacity,
		"capacityPercent" = round(100 * charge / capacity, 0.1),
		"charge" = charge,
		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputLevel_text" = DisplayPower(input_level),
		"inputLevelMax" = input_level_max,
		"inputAvailable" = input_available,
		"outputPowernet" = !isnull(powernet),
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
			if(output_attempt)
				playsound(loc, 'sound/effects/contactor_on.ogg', 50, FALSE)
			else
				playsound(loc, 'sound/effects/contactor_off.ogg', 50, FALSE)
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
		investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Charge: [charge] | Output-mode: [output_attempt?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_attempt?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [user ? key_name(user) : "outside forces"]", INVESTIGATE_SINGULO)

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
	charge -= 1e6 / severity
	if(charge < 0)
		charge = 0
	update_icon()
	log_smes()
	..()

/obj/machinery/power/smes/engineering
	charge = 0.08e6 // Engineering starts with some charge for singulo
	input_level = 200000
	output_level = 80000

/obj/machinery/power/smes/empty

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
#undef SMESMAXCHARGELEVEL
#undef SMESMAXOUTPUT

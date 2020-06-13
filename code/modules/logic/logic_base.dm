
/obj/machinery/logic_gate
	name = "Logic Base"
	desc = "This does nothing except connect to things. Highly illogical, report to a coder at once if you see this in-game."
	icon = 'icons/obj/computer3.dmi'
	icon_state = "serverframe"
	density = 1
	anchored = 1

	settagwhitelist = list("input1_id_tag", "input2_id_tag", "output_id_tag")

	var/tamperproof = 0		//if set, will make the machine unable to be destroyed, adjusted, etc. via in-game interaction (USE ONLY FOR MAPPING STUFF)
	var/mono_input = 0		//if set, will ignore input2

	var/datum/radio_frequency/radio_connection
	var/frequency = 0

	/*
	Some notes on Input/Output:
	- Multiple things can be linked to the same input or output tag, just like how wires can connect multiple sources and receivers.
	- For inputs, only the last signal received BEFORE a process() call will be used in the logic handling.
		- Input states are updated immediately whenever an input signal is received, so it is possible to update multiple times within a single process cycle.
		- This means if you have multiple connected inputs, but the last signal received before the process() call is OFF, it won't matter if the others are both ON.
		- For this reason, please set up your logic properly. You can theoretically chain these infinitely, so there's no need to link multiple things to a single input.
	- For outputs, the signal will attempt to be sent out every process() call, to ensure newly connected things are updated within one process cycle
		- Connecting an output to multiple inputs should not cause issues, as long as you don't have multiple connections to a given input (see previous notes on inputs).
		- The output state is determined immediately preceeding the signal broadcast, using the input states at the time of the process() call, not when a signal is received.
		- Because of how the process cycle works, it is possible that it may take multiple cycles for a signal to fully propogate through a logic chain.
		 - This is because machines attempt to process in the order they were added to the scheduler.
		 - Building the logic gates at the end of the chain first may cause delays in signal propogation.
	If you take all this into consideration when linking and using logic machinery, you should have no unexpected issues with input/output. Your design flaws are on you though.
	*/

	var/input1_id_tag = null
	var/input1_state = LOGIC_OFF
	var/input2_id_tag = null
	var/input2_state = LOGIC_OFF
	var/output_id_tag = null
	var/output_state = LOGIC_OFF

/obj/machinery/logic_gate/New()
	if(tamperproof)		//doing this during New so we don't have to worry about forgetting to set these vars during editting / defining
		resistance_flags |= ACID_PROOF
	..()
	if(SSradio)
		set_frequency(frequency)
	component_parts = list()
	var/obj/item/circuitboard/logic_gate/LG = new(null)
	LG.set_type(type)
	component_parts += LG
	component_parts += new /obj/item/stack/cable_coil(null, 1)

/obj/machinery/logic_gate/Initialize()
	..()
	set_frequency(frequency)

/obj/machinery/logic_gate/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_LOGIC)
	return

/obj/machinery/logic_gate/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/logic_gate/process()
	handle_logic()
	handle_output()		//All output will send for at least one cycle, and will attempt to send every cycle. Hopefully this won't be too taxing.
	return

/obj/machinery/logic_gate/proc/handle_logic()
	return

/obj/machinery/logic_gate/proc/handle_output()
	if(!radio_connection)		//can't output without this
		return

	if(output_id_tag == null)	//Don't output to an undefined id_tag
		return

	var/datum/signal/signal = new
	signal.transmission_method = 1	//radio signal
	signal.source = src

	signal.data = list(
			"tag" = output_id_tag,
			"sigtype" = "logic",
			"state" = output_state,
	)

	radio_connection.post_signal(src, signal, filter = RADIO_LOGIC)

/obj/machinery/logic_gate/receive_signal(datum/signal/signal, receive_method, receive_param)
	if(!signal.data["tag"] || ((signal.data["tag"] != input1_id_tag) && (signal.data["tag"] != input2_id_tag)) || (signal.data["sigtype"] != "logic"))
		//If the signal lacks tag data, the signal's tag data doesn't match either input id tag, or is not a "logic" signal, ignore it since it's not for us
		return

	if(signal.data["tag"] == input1_id_tag)		//If the signal is for input1
		if(signal.data["state"] == input1_state)	//If we already match, ignore the new signal since nothing changes
			return
		if(signal.data["state"] == LOGIC_OFF)		//Shut it down and keep it off
			input1_state = LOGIC_OFF
			return
		if(signal.data["state"] == LOGIC_ON)		//Turn it on and keep it on
			input1_state = LOGIC_ON
			return
		if(signal.data["state"] == LOGIC_FLICKER)	//Turn it on then turn it off
			if(input1_state == LOGIC_ON)			//An existing continuous ON state overrides new flicker signals
				return
			input1_state = LOGIC_FLICKER
			spawn(LOGIC_FLICKER_TIME)
				if(input1_state == LOGIC_FLICKER)	//Make sure we didn't get a new continuous signal set while we waited (those take priority)
					input1_state = LOGIC_OFF
			return

	//Now, you may be wondering why I included those returns.
	//The answer is "If you link both inputs to the same source, you're an idiot and deserve to have it break", so yeah. Deal with it.

	if(mono_input)
		//We only care about input1, so if we didn't receive a signal for that, we're done.
		return

	if(signal.data["tag"] == input2_id_tag)		//If the signal is for input2 (reaching this point assumes mono_input is not set)
		if(signal.data["state"] == input2_state)	//If we already match, ignore the new signal since nothing changes
			return
		if(signal.data["state"] == LOGIC_OFF)		//Shut it down and keep it off
			input2_state = LOGIC_OFF
			return
		if(signal.data["state"] == LOGIC_ON)		//Turn it on and keep it on
			input2_state = LOGIC_ON
			return
		if(signal.data["state"] == LOGIC_FLICKER)	//Turn it on then turn it off
			if(input2_state == LOGIC_ON)			//An existing continuous ON state overrides new flicker signals
				return
			input2_state = LOGIC_FLICKER
			spawn(LOGIC_FLICKER_TIME)
				if(input2_state == LOGIC_FLICKER)	//Make sure we didn't get a new continuous signal set while we waited (those take priority)
					input2_state = LOGIC_OFF
			return

/obj/machinery/logic_gate/multitool_menu(var/mob/user, var/obj/item/multitool/P)
	var/input1_state_string
	var/input2_state_string
	var/output_state_string

	switch(input1_state)
		if(LOGIC_OFF)
			input1_state_string = "OFF"
		if(LOGIC_ON)
			input1_state_string = "ON"
		if(LOGIC_FLICKER)
			input1_state_string = "FLICKER"
		else
			input1_state_string = "ERROR: UNKNOWN STATE"

	switch(input2_state)
		if(LOGIC_OFF)
			input2_state_string = "OFF"
		if(LOGIC_ON)
			input2_state_string = "ON"
		if(LOGIC_FLICKER)
			input2_state_string = "FLICKER"
		else
			input2_state_string = "ERROR: UNKNOWN STATE"

	switch(output_state)
		if(LOGIC_OFF)
			output_state_string = "OFF"
		if(LOGIC_ON)
			output_state_string = "ON"
		if(LOGIC_FLICKER)
			output_state_string = "FLICKER"
		else
			output_state_string = "ERROR: UNKNOWN STATE"
	var/menu_contents = {"
	<dl>
	<dt><b>Input:</b> [format_tag("ID Tag","input1_id_tag")]</dt>
	<dd>Input State: [input1_state_string]</dd>
	"}
	if(!mono_input)
		menu_contents = {"
		<dt><b>Input 1:</b> [format_tag("ID Tag","input1_id_tag")]</dt>
		<dd>Input 1 State: [input1_state_string]</dd>
		<dt><b>Input 2:</b> [format_tag("ID Tag","input2_id_tag")]</dt>
		<dd>Input 2 State: [input2_state_string]</dd>
		"}
	menu_contents += {"
	<dt><b>Output:</b> [format_tag("ID Tag","output_id_tag")]</dt>
	<dd>Output State: [output_state_string]</dd>
	</dl>
	"}
	return menu_contents

/obj/machinery/logic_gate/convert/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	..()
	update_multitool_menu(user)

/obj/machinery/logic_gate/attackby(obj/item/O, mob/user, params)
	if(tamperproof)
		to_chat(user, "<span class='warning'>The [src] appears to be tamperproofed! You can't interact with it!</span>")
		return 0
	if(istype(O, /obj/item/multitool))
		update_multitool_menu(user)
		return 1
	if(istype(O, /obj/item/screwdriver))
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the access panel.</span>")
		return 1
	if(panel_open && istype(O, /obj/item/crowbar))
		default_deconstruction_crowbar(user, O)
		return 1
	return ..()

//////////////////////////////////////
//			Attack procs			//
//////////////////////////////////////

/obj/machinery/logic_gate/attack_ai(mob/user)
	if(tamperproof)
		to_chat(user, "<span class='warning'>The [src] appears to be tamperproofed! You can't interface with it!</span>")
		return 0
	add_hiddenprint(user)
	return ui_interact(user)

/obj/machinery/logic_gate/attack_ghost(mob/user)
	if(tamperproof)
		to_chat(user, "<span class='warning'>The [src] appears to be tamperproofed! You can't haunt it!</span>")
		return 0
	return ui_interact(user)

/obj/machinery/logic_gate/attack_hand(mob/user)
	if(tamperproof)
		to_chat(user, "<span class='warning'>The [src] appears to be tamperproofed! You can't interact with it!</span>")
		return 0
	. = ..()
	if(.)
		return 0
	return interact(user)

/obj/machinery/logic_gate/attack_alien(mob/user)		//No xeno logic, that's too silly.
	to_chat(user, "<span class='warning'>The [src] appears to be too complex! You can't comprehend it and back off in fear!</span>")
	return 0

/obj/machinery/logic_gate/attack_animal(mob/user)	//No animal logic either.
	to_chat(user, "<span class='warning'>The [src] appears to be beyond your comprehension! You can't fathom it!</span>")
	return 0

/obj/machinery/logic_gate/attack_slime(mob/user)		//No slime logic. Seriously.
	to_chat(user, "<span class='warning'>The [src] appears to be beyond your gelatinous understanding! You ignore it!</span>")
	return 0

/obj/machinery/logic_gate/emp_act(severity)
	if(tamperproof)
		return 0
	..()

/obj/machinery/logic_gate/ex_act(severity)
	if(tamperproof)
		return 0
	..()

/obj/machinery/logic_gate/blob_act(obj/structure/blob/B)
	if(!tamperproof)
		return ..()

/obj/machinery/logic_gate/singularity_act()
	if(tamperproof)
		//This is some top-level tamperproofing right here, that's for sure. It can even defy a singularity!
		return 0
	..()

/obj/machinery/logic_gate/bullet_act()
	if(tamperproof)
		return 0
	..()

/obj/machinery/logic_gate/tesla_act(var/power)
	if(tamperproof)
		tesla_zap(src, 3, power)	//If we're tamperproof, we'll just bounce the full shock of the tesla zap we got hit by, so it continues on normally without diminishing
		return 0
	..()

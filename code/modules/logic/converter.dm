
//////////////////////////////////
//		Converter Gate			//
//////////////////////////////////

/*
	This gate is special enough to warrant its own file, as it overrides a lot of the logic_gate procs as well as adds a new one.
	- CONVERT Gates convert signaler and logic signals, to allow logic gates to actually be used in tandem with assemblies and station equipment like doors.
	- While technically a mono-input device, the input and output are actually completely different types of signals, and thus incompatible without this gate.
	- A signaler must be attached manually before the gate is fully functional, and will retain any frequency and code settings it had when attached.
	 - You can adjust these settings through a link in the multitool menu, but the receiving mode is automatically controlled by the converter.
	 - While attached, the ability to manually send the signal on the signaler through its menu is also disabled, to avoid messing up the logic system.
*/

//CONVERT Gate
/obj/machinery/logic_gate/convert
	name = "CONVERT Gate"
	desc = "Converts signals between radio and logic types, allowing for signaller input/output from logic systems."
	icon_state = "logic_convert"
	mono_input = 1

	var/logic_output = 0					//When set to 1, the logic signal is the output. When set to 0, the logic signal is the input.
	var/obj/item/assembly/signaler/attached_signaler = null

/obj/machinery/logic_gate/convert/handle_logic()
	output_state = input1_state
	return

/obj/machinery/logic_gate/convert/attackby(obj/item/O, mob/user, params)
	if(tamperproof)		//Extra precaution to avoid people attaching/removing signalers from tamperproofed converters
		return
	if(istype(O, /obj/item/assembly/signaler))
		var/obj/item/assembly/signaler/S = O
		if(S.secured)
			to_chat(user, "<span class='warning'>The [S] is already secured.</span>")
			return
		if(attached_signaler)
			to_chat(user, "<span class='warning'>There is already a device attached, remove it first.</span>")
			return
		user.unEquip(S)
		S.forceMove(src)
		S.holder = src
		S.toggle_secure()
		if(logic_output)		//Make sure we are set to receive if the converter is set to output logic, and send if the converter is set to accept logic input
			S.receiving = 1
		else
			S.receiving = 0
		attached_signaler = S
		to_chat(user, "<span class='notice'>You attach \the [S] to the I/O connection port and secure it.</span>")
		return
	if(attached_signaler && istype(O, /obj/item/screwdriver))		//Makes sure we remove the attached signaler before we can open up and deconstruct the machine
		var/obj/item/assembly/signaler/S = attached_signaler
		attached_signaler = null
		S.forceMove(get_turf(src))
		S.holder = null
		S.toggle_secure()
		to_chat(user, "<span class='notice'>You unsecure and detach \the [S] from the I/O connection port.</span>")
		return
	..()

/obj/machinery/logic_gate/convert/multitool_menu(var/mob/user, var/obj/item/multitool/P)
	var/logic_state_string
	var/menu_contents = {"
	<dl>
	"}
	if(logic_output)
		switch(output_state)
			if(LOGIC_OFF)
				logic_state_string = "OFF"
			if(LOGIC_ON)
				logic_state_string = "ON"
			if(LOGIC_FLICKER)
				logic_state_string = "FLICKER"
			else
				logic_state_string = "ERROR: UNKNOWN STATE"
		menu_contents += {"
		<dt><b>Output:</b> [format_tag("ID Tag","output_id_tag")]</dt>
		<dd>Output State: [logic_state_string]</dd>
		"}
	else
		switch(input1_state)
			if(LOGIC_OFF)
				logic_state_string = "OFF"
			if(LOGIC_ON)
				logic_state_string = "ON"
			if(LOGIC_FLICKER)
				logic_state_string = "FLICKER"
			else
				logic_state_string = "ERROR: UNKNOWN STATE"
		menu_contents += {"
		<dt><b>Input:</b> [format_tag("ID Tag","input1_id_tag")]</dt>
		<dd>Input State: [logic_state_string]</dd>
		"}
	menu_contents += {"
	<dt><b>Logic Signal Designation:</b> <a href='?src=[UID()];toggle_logic=1'>[logic_output ? "Output" : "Input"]</a></dt>
	"}
	if(attached_signaler)
		menu_contents += "<dt><a href='?src=[UID()];adjust_signaler=1'>Adjust Signaler Settings</a></dt>"
	else
		menu_contents += "<dt><b>NO SIGNALER ATTACHED!</b></dt>"
	menu_contents += {"
	</dl>
	"}
	return menu_contents

/obj/machinery/logic_gate/convert/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	..()
	if("toggle_logic" in href_list)
		logic_output = !logic_output
		if(attached_signaler)		//If we have a signaler attached, make sure we update it to send/receive when we change the logic signal desgination
			if(logic_output)
				attached_signaler.receiving = 1
			else
				attached_signaler.receiving = 0
	if(("adjust_signaler" in href_list) && attached_signaler)		//Make sure that we have a signaler attached to handle this one, otherwise ignore this command
		attached_signaler.interact(user, 1)
	update_multitool_menu(user)

/obj/machinery/logic_gate/convert/receive_signal(datum/signal/signal, receive_method, receive_param)
	if(logic_output)
		if(attached_signaler)
			attached_signaler.receive_signal(signal)
		return
	else
		..()

/obj/machinery/logic_gate/convert/handle_output()
	if(logic_output)
		..()
	else
		if(attached_signaler && (output_state == LOGIC_ON || output_state == LOGIC_FLICKER))
			attached_signaler.signal()
		return

/obj/machinery/logic_gate/convert/proc/process_activation(var/obj/item/D)
	if(!logic_output)	//Don't bother if our input is a logic signal
		return
	if(D == attached_signaler)		//Ignore if we somehow got called by a device that isn't what we have attached
		input1_state = LOGIC_FLICKER
		spawn(LOGIC_FLICKER_TIME)
			if(input1_state == LOGIC_FLICKER)
				input1_state = LOGIC_OFF
		return

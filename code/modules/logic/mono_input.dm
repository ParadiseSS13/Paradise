
//////////////////////////////////
//		Mono-Input Gates		//
//////////////////////////////////

//NOT Gate
/obj/machinery/logic_gate/not
	name = "NOT Gate"
	desc = "Accepts one input and outputs the reverse state."
	icon_state = "logic_not"
	mono_input = 1				//NOT Gates are the simplest logic gate because they only utilize one input.
	output_state = LOGIC_ON		//Starts with an active output, since the input will be OFF at start
/*
	A quick note regarding NOT Gates:
	- Connecting multiple things to the input of a NOT Gate can cause weird behaviour due to updating both when it receives a signal and when it calls process().
	 - This means it will attempt to output once for every logic machine connected to its input's own process() call.
	 - It will then attempt to output an additional time based on the current state when it comes to its own process() call.
	 - For this reason, it is HIGHLY RECOMMENDED that you only connect a single signal source to the input of a NOT Gate to avoid signal spasms.
	- Connecting multiple things to the output of a NOT Gate should not cause this unusual behavior.
*/
/obj/machinery/logic_gate/not/handle_logic()		//Our output will always be a continuous signal, even with a FLICKER, it just will update the output when the FLICKER ends
	if(input1_state == LOGIC_ON)				//Output is OFF while input is ON
		output_state = LOGIC_OFF
	else if(input1_state == LOGIC_FLICKER)		//Output is OFF while input is FLICKER, then output returns to ON when input returns to OFF
		output_state = LOGIC_OFF
		spawn(LOGIC_FLICKER_TIME + 1)		//Call handle_logic again after this delay (the input should update from the spawn(LOGIC_FLICKER_TIME) in receive_signal() by then)
			handle_logic()
	else										//Output is ON while input is OFF
		output_state = LOGIC_ON
	handle_output()
	return

//STATUS Gate
/obj/machinery/logic_gate/status
	name = "Status Gate"
	desc = "Accepts one input and outputs the same state, showing a colored light based on current state."
	icon_state = "logic_status"
	mono_input = 1				//STATUS Gate doesn't actually perform logic operations, but instead acts as a testing conduit.

/*
	STATUS Gates are largely a diagnostics tool, but I'm sure someone will still make a logic gate rave with them anyways.
	- There is no need to actually connect an output for these to work, they just need an input to sample from.
	- STATUS Gates attempt to update their lights whenever they receive a signal.
*/

/obj/machinery/logic_gate/status/receive_signal(datum/signal/signal, receive_method, receive_params)
	..()
	handle_logic()					//STATUS Gate calls handle_logic() when it receives a signal to update its light and output_state

/obj/machinery/logic_gate/status/handle_logic()
	output_state = input1_state				//Output is equal to input, since it is simply a connection with an attached light
	if(output_state == LOGIC_OFF)			//Red light when OFF
		set_light(2,2,"#ff0000")
		return
	if(output_state == LOGIC_ON)			//Green light when ON
		set_light(2,2,"#009933")
		return
	if(output_state == LOGIC_FLICKER)		//Orange light when FLICKER, then update after LOGIC_FLICKER_TIME + 1 to reflect the changed state
		set_light(2,2,"#ff9900")
		spawn(LOGIC_FLICKER_TIME + 1)
			handle_logic()
		return

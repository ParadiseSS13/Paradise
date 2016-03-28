
//////////////////////////////////
//		Mono-Input Gates		//
//////////////////////////////////

//NOT Gate
/obj/machinery/logic_gate/not
	name = "NOT Gate"
	desc = "Accepts one input and outputs the reverse state."
	mono_input = 1				//NOT Gates are the simplest logic gate because they only utilize one input.
	output_state = LOGIC_ON		//Starts with an active output, since the input will be OFF at start

/obj/machinery/logic_gate/not/process()		//This gate only handles its logic when it receives a signal, and outputs both on the process and when it receives the signal
	handle_output()
	return
/*
	A quick note regarding NOT Gates:
	- Connecting multiple things to the input of a NOT Gate can cause weird behaviour due to updating both when it receives a signal and when it calls process().
	 - This means it will attempt to output once for every logic machine connected to its input's own process() call.
	 - It will then attempt to output an additional time based on the current state when it comes to its own process() call.
	 - For this reason, it is HIGHLY RECOMMENDED that you only connect a single signal source to the input of a NOT Gate to avoid signal spasms.
	- Connecting multiple things to the output of a NOT Gate should not cause this unusual behavior.
*/
/obj/machinery/logic_gate/not/receive_signal(datum/signal/signal, receive_method, receive_param)
	..()
	handle_logic()
	return

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
	mono_input = 1				//STATUS Gate doesn't actually perform logic operations, but instead acts as a testing conduit.

/*
	STATUS Gates are largely a diagnostics tool, but I'm sure someone will still make a logic gate rave with them anyways.
	- There is no need to actually connect an output for these to work, they just need an input to sample from.
	- STATUS Gates attempt to output both on the process cycle and whenever a signal is received.
	 - This may seem a little spammy, but ensures they don't hold anything up signal-wise.
*/

/obj/machinery/logic_gate/status/receive_signal(datum/signal/signal, receive_method, receive_params)
	..()
	handle_logic()					//STATUS Gate calls handle_logic() when it receives a signal to update its light and output_state
	handle_output()					//STATUS Gate outputs when it receives a signal, since it is just a connector piece (like a wire for power)

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
			handle_output()
		return

//////////////////////////////////
//		Dual-Input Gates		//
//////////////////////////////////


// OR Gate
/obj/machinery/logic_gate/or
	name = "OR Gate"
	desc = "Outputs ON when at least one input is ON."

/obj/machinery/logic_gate/or/handle_logic()
	if(input1_state == LOGIC_ON || input1_state == LOGIC_FLICKER || input2_state == LOGIC_ON || input2_state == LOGIC_FLICKER)
		if(input1_state == LOGIC_ON || input2_state == LOGIC_ON)		//continuous signal takes priority in determining what to output
			output_state = LOGIC_ON
		else
			output_state = LOGIC_FLICKER
	else	//Both inputs were off, so input is off
		output_state = LOGIC_OFF
	return

// AND Gate
/obj/machinery/logic_gate/and
	name = "AND Gate"
	desc = "Outputs ON only when both inputs are ON."

/obj/machinery/logic_gate/and/handle_logic()
	if((input1_state == LOGIC_ON || input1_state == LOGIC_FLICKER) && (input2_state == LOGIC_ON || input2_state == LOGIC_FLICKER))
		if(input1_state == LOGIC_ON && input2_state == LOGIC_ON)		//only output a continuous signal when both inputs are continuous signals
			output_state = LOGIC_ON
		else
			output_state = LOGIC_FLICKER
	else	//At least one input was off, so output is off
		output_state = LOGIC_OFF
	return

// NAND Gate
/obj/machinery/logic_gate/nand
	name = "NAND Gate"
	desc = "Outputs OFF only when both inputs are ON."
	output_state = LOGIC_ON

/obj/machinery/logic_gate/nand/handle_logic()
	if((input1_state == LOGIC_ON || input1_state == LOGIC_FLICKER) && (input2_state == LOGIC_ON || input2_state == LOGIC_FLICKER))
		output_state = LOGIC_OFF										//This can only output continuous signals
	else	//At least one input was ON/FLICKER, so output is off
		output_state = LOGIC_OFF
	return

// NOR Gate
/obj/machinery/logic_gate/nor
	name = "NOR Gate"
	desc = "Outputs OFF when at least one input is ON."
	output_state = LOGIC_ON

/obj/machinery/logic_gate/nor/handle_logic()
	if(input1_state == LOGIC_OFF ||input2_state == LOGIC_OFF)
		output_state = LOGIC_ON										//This can only output continuous signals
	else	//Both inputs are ON, so output is OFF
		output_state = LOGIC_OFF
	return

// XOR Gate
/obj/machinery/logic_gate/xor
	name = "XOR Gate"
	desc = "Outputs ON when only one input is ON."

/obj/machinery/logic_gate/xor/handle_logic()
	if((input1_state == LOGIC_ON || input1_state == LOGIC_FLICKER) || input2_state == LOGIC_OFF)			//Only input1 is ON/FLICKER, so output matches input1
		output_state = input1_state
	else if((input2_state == LOGIC_ON || input2_state == LOGIC_FLICKER) || input1_state == LOGIC_OFF)		//Only input2 is ON/FLICKER, so output matches input2
		output_state = input2_state
	else																									//Both inputs are ON or OFF, so output is OFF
		output_state = LOGIC_OFF
	return

// XNOR Gate
/obj/machinery/logic_gate/xnor
	name = "XNOR Gate"
	desc = "Outputs ON when both inputs are ON or OFF."
	output_state = LOGIC_ON

/obj/machinery/logic_gate/xnor/handle_logic()
	if((input1_state == LOGIC_ON || input1_state == LOGIC_FLICKER) && (input2_state == LOGIC_ON || input2_state == LOGIC_FLICKER))		//Both inputs are ON/FLICKER
		if(input1_state == LOGIC_ON && input2_state == LOGIC_ON)											//Only continuous signal when both inputs are ON
			output_state = LOGIC_ON
		else																								//If at least one input is FLICKER, output FLICKER
			output_state = LOGIC_FLICKER
	else if(input1_state == LOGIC_OFF && input2_state == LOGIC_OFF)																		//Both inputs are OFF
		output_state = LOGIC_ON																				//Always continuous in this case
	else																																//Only one input is ON/FLICKER
		output_state = LOGIC_OFF
	return


//////////////////////////////////
//		Dual-Input Gates		//
//////////////////////////////////


// OR Gate
/obj/machinery/logic_gate/or
	name = "OR Gate"
	desc = "Outputs ON when at least one input is ON."
	icon_state = "logic_or"

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
	icon_state = "logic_and"

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
	icon_state = "logic_nand"

/obj/machinery/logic_gate/nand/handle_logic()
	if((input1_state == LOGIC_ON || input1_state == LOGIC_FLICKER) && (input2_state == LOGIC_ON || input2_state == LOGIC_FLICKER))
		output_state = LOGIC_OFF										//Both inputs are ON/FLICKER, so output is off
	else
		output_state = LOGIC_ON		//This can only output continuous signals
	return

// NOR Gate
/obj/machinery/logic_gate/nor
	name = "NOR Gate"
	desc = "Outputs OFF when at least one input is ON."
	icon_state = "logic_nor"
	output_state = LOGIC_ON

/obj/machinery/logic_gate/nor/handle_logic()
	if(input1_state == LOGIC_OFF && input2_state == LOGIC_OFF)		//Both inputs are OFF, so output is ON
		output_state = LOGIC_ON										//This can only output continuous signals
	else
		output_state = LOGIC_OFF
	return

// XOR Gate
/obj/machinery/logic_gate/xor
	name = "XOR Gate"
	desc = "Outputs ON when only one input is ON."
	icon_state = "logic_xor"

/obj/machinery/logic_gate/xor/handle_logic()
	if((input1_state == LOGIC_ON || input1_state == LOGIC_FLICKER) && (input2_state == LOGIC_OFF))			//Only input1 is ON/FLICKER, so output matches input1
		output_state = input1_state
	else if((input2_state == LOGIC_ON || input2_state == LOGIC_FLICKER) && (input1_state == LOGIC_OFF))		//Only input2 is ON/FLICKER, so output matches input2
		output_state = input2_state
	else																									//Both inputs are ON or OFF, so output is OFF
		output_state = LOGIC_OFF
	return


// XNOR Gate
/obj/machinery/logic_gate/xnor
	name = "XNOR Gate"
	desc = "Outputs ON when both inputs are ON or OFF."
	icon_state = "logic_xnor"
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

//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33


/* --- Traffic Control Scripting Language --- */
	// Nanotrasen TCS Language - Made by Doohl

/datum/n_Interpreter/TCS_Interpreter
	var/datum/TCS_Compiler/Compiler

/datum/n_Interpreter/TCS_Interpreter/HandleError(datum/runtimeError/e)
	Compiler.Holder.add_entry(e.ToString(), "Execution Error")

/datum/n_Interpreter/TCS_Interpreter/GC()
	..()
	Compiler = null

/datum/TCS_Compiler
	var/datum/n_Interpreter/TCS_Interpreter/interpreter
	var/obj/machinery/telecomms/server/Holder	// the server that is running the code
	var/ready = 1 // 1 if ready to run code

	/* -- Set ourselves to Garbage Collect -- */

/datum/TCS_Compiler/proc/GC()
	Holder = null
	if(interpreter)
		interpreter.GC()


	/* -- Compile a raw block of text -- */

/datum/TCS_Compiler/proc/Compile(code as message)
	var/datum/n_scriptOptions/nS_Options/options		= new()
	var/datum/n_Scanner/nS_Scanner/scanner				= new(code, options)
	var/list/tokens										= scanner.Scan()
	var/datum/n_Parser/nS_Parser/parser					= new(tokens, options)
	var/datum/node/BlockDefinition/GlobalBlock/program	= parser.Parse()

	var/list/returnerrors = list()

	returnerrors += scanner.errors
	returnerrors += parser.errors

	if(returnerrors.len)
		return returnerrors

	interpreter 		= new(program)
	interpreter.persist	= 1
	interpreter.Compiler= src

	return returnerrors

/* -- Execute the compiled code -- */

/datum/TCS_Compiler/proc/Run(var/datum/signal/signal)
	if(!ready)
		return

	if(!interpreter)
		return

	interpreter.container = src

	interpreter.SetVar("PI",	 	3.141592653)	// value of pi
	interpreter.SetVar("E",		 	2.718281828)	// value of e
	interpreter.SetVar("SQURT2", 	1.414213562)	// value of the square root of 2
	interpreter.SetVar("FALSE", 	0)				// boolean shortcut to 0
	interpreter.SetVar("false", 	0)				// boolean shortcut to 0
	interpreter.SetVar("TRUE",		1)				// boolean shortcut to 1
	interpreter.SetVar("true",		1)				// boolean shortcut to 1

	interpreter.SetVar("NORTH", 	NORTH)			// NORTH (1)
	interpreter.SetVar("SOUTH", 	SOUTH)			// SOUTH (2)
	interpreter.SetVar("EAST",	 	EAST)			// EAST  (4)
	interpreter.SetVar("WEST",	 	WEST)			// WEST  (8)

	// Channel macros
	interpreter.SetVar("$common",	PUB_FREQ)
	interpreter.SetVar("$science",	SCI_FREQ)
	interpreter.SetVar("$command",	COMM_FREQ)
	interpreter.SetVar("$medical",	MED_FREQ)
	interpreter.SetVar("$engineering", ENG_FREQ)
	interpreter.SetVar("$security",	SEC_FREQ)
	interpreter.SetVar("$supply",	SUP_FREQ)
	interpreter.SetVar("$service",	SRV_FREQ)

	// Signal data

	interpreter.SetVar("$content", 	signal.data["message"])
	interpreter.SetVar("$freq", 	signal.frequency)
	interpreter.SetVar("$source", 	signal.data["name"])
	interpreter.SetVar("$job",	 	signal.data["job"])
	interpreter.SetVar("$sign",		signal)
	interpreter.SetVar("$pass",		!(signal.data["reject"])) // if the signal isn't rejected, pass = 1; if the signal IS rejected, pass = 0

	var/datum/language/speaking = signal.data["language"]
	if(speaking)
		interpreter.SetVar("$language", speaking.name)
	else
		interpreter.SetVar("$language", "Unknown")

	// Set up the script procs

	/*
		-> Send another signal to a server
				@format: broadcast(content, frequency, source, job)

				@param content:		Message to broadcast
				@param frequency:	Frequency to broadcast to
				@param source:		The name of the source you wish to imitate. Must be stored in stored_names list.
				@param job:			The name of the job.
	*/
	interpreter.SetProc("broadcast", "tcombroadcast", signal, list("message", "freq", "source", "job"))

	/*
		-> Interface with a linked machine
				@format: interface_machine(machine, args)

				@param machine:		Tag assigned to the machine using the Traffic Control
				@param args:		Arguments to pass to machine
	*/
	interpreter.SetProc("interface_machine", "interface_machine", signal, list("machine", "args"))

	/*
		-> Sends a PDA message
				@format: pda_message(recipient, message)

				@param recipient:	Name of recipient. Must match name on the PDA exactly.
				@param message:		Message to send to recipient
	*/
	interpreter.SetProc("pda_message", "pda_message", signal, list("recipient", "message"))

	/*
		-> Store a value permanently to the server machine (not the actual game hosting machine, the ingame machine)
				@format: mem(address, value)

				@param address:		The memory address (string index) to store a value to
				@param value:		The value to store to the memory address
	*/
	interpreter.SetProc("mem", "mem", signal, list("address", "value"))

	/*
		-> Delay code for a given amount of deciseconds
				@format: sleep(time)

				@param time: 		time to sleep in deciseconds (1/10th second)
	*/
	interpreter.SetProc("sleep",		/proc/delay)

	/*
		-> Replaces a string with another string
				@format: replace(string, substring, replacestring)

				@param string: 			the string to search for substrings (best used with $content$ constant)
				@param substring: 		the substring to search for
				@param replacestring: 	the string to replace the substring with

	*/
	interpreter.SetProc("replace",		/proc/replacetext)

	/*
		-> Locates an element/substring inside of a list or string
				@format: find(haystack, needle, start = 1, end = 0)

				@param haystack:	the container to search
				@param needle:		the element to search for
				@param start:		the position to start in
				@param end:			the position to end in

	*/
	interpreter.SetProc("find",			/proc/smartfind)

	/*
		-> Finds the length of a string or list
				@format: length(container)

				@param container: the list or container to measure

	*/
	interpreter.SetProc("length",		/proc/smartlength)

	/* -- Clone functions, carried from default BYOND procs --- */

	// vector namespace
	interpreter.SetProc("vector",		/proc/n_list)
	interpreter.SetProc("at",			/proc/n_listpos)
	interpreter.SetProc("copy",			/proc/n_listcopy)
	interpreter.SetProc("push_back",	/proc/n_listadd)
	interpreter.SetProc("remove",		/proc/n_listremove)
	interpreter.SetProc("cut",			/proc/n_listcut)
	interpreter.SetProc("swap",			/proc/n_listswap)
	interpreter.SetProc("insert",		/proc/n_listinsert)

	interpreter.SetProc("pick",			/proc/n_pick)
	interpreter.SetProc("prob",			/proc/prob_chance)
	interpreter.SetProc("substr",		/proc/docopytext)

	interpreter.SetProc("shuffle",		/proc/shuffle)
	interpreter.SetProc("uniquevector",	/proc/uniquelist)

	interpreter.SetProc("text2vector",	/proc/text2list)
	interpreter.SetProc("text2vectorEx",/proc/text2listEx)
	interpreter.SetProc("vector2text",	/proc/list2text)

	// Donkie~
	// Strings
	interpreter.SetProc("lower",		/proc/n_lower)
	interpreter.SetProc("upper",		/proc/n_upper)
	interpreter.SetProc("explode",		/proc/string_explode)
	interpreter.SetProc("implode",		/proc/list2text)
	interpreter.SetProc("repeat",		/proc/n_repeat)
	interpreter.SetProc("reverse",		/proc/reverse_text)
	interpreter.SetProc("tonum",		/proc/n_str2num)
	interpreter.SetProc("capitalize",	/proc/capitalize)
	interpreter.SetProc("replacetextEx",/proc/replacetextEx)

	// Numbers
	interpreter.SetProc("tostring",		/proc/n_num2str)
	interpreter.SetProc("sqrt",			/proc/n_sqrt)
	interpreter.SetProc("abs",			/proc/n_abs)
	interpreter.SetProc("floor",		/proc/Floor)
	interpreter.SetProc("ceil",			/proc/Ceiling)
	interpreter.SetProc("round",		/proc/n_round)
	interpreter.SetProc("clamp",		/proc/n_clamp)
	interpreter.SetProc("inrange",		/proc/IsInRange)
	interpreter.SetProc("rand",			/proc/rand_chance)
	interpreter.SetProc("arctan",		/proc/Atan2)
	interpreter.SetProc("lcm",			/proc/Lcm)
	interpreter.SetProc("gcd",			/proc/Gcd)
	interpreter.SetProc("mean",			/proc/Mean)
	interpreter.SetProc("root",			/proc/Root)
	interpreter.SetProc("sin",			/proc/n_sin)
	interpreter.SetProc("cos",			/proc/n_cos)
	interpreter.SetProc("arcsin",		/proc/n_asin)
	interpreter.SetProc("arccos",		/proc/n_acos)
	interpreter.SetProc("tan",			/proc/Tan)
	interpreter.SetProc("csc",			/proc/Csc)
	interpreter.SetProc("cot",			/proc/Cot)
	interpreter.SetProc("sec",			/proc/Sec)
	interpreter.SetProc("todegrees",	/proc/ToDegrees)
	interpreter.SetProc("toradians",	/proc/ToRadians)
	interpreter.SetProc("lerp",			/proc/Lerp)
	interpreter.SetProc("max",			/proc/n_max)
	interpreter.SetProc("min",			/proc/n_min)

	// End of Donkie~

	// Time
	interpreter.SetProc("time",			/proc/time)
	interpreter.SetProc("timestamp",	/proc/timestamp)

	// Station data
	interpreter.SetProc("crew_manifest",/proc/n_crew_manifest)

	// Run the compiled code
	interpreter.Run()

	// Backwards-apply variables onto signal data
	/* sanitize EVERYTHING. fucking players can't be trusted with SHIT */

	/* Okay, so, the original 'sanitizing' code... did fucking nothing. Then PJB fixed it, which means no HTML.
	   But I like HTML, so back to no sanitizing.*/

	signal.data["message"] 	= interpreter.GetVar("$content", signal.data["message"])
	signal.frequency 		= interpreter.GetCleanVar("$freq", signal.frequency)

	var/setname = interpreter.GetVar("$source", signal.data["name"])

	if(signal.data["name"] != setname)
		signal.data["realname"] = setname
	signal.data["name"]		= setname
	signal.data["job"]		= interpreter.GetVar("$job", signal.data["job"])
	signal.data["reject"]	= !(interpreter.GetCleanVar("$pass")) // set reject to the opposite of $pass

	// If the message is invalid, just don't broadcast it!
	if(signal.data["message"] == "" || !signal.data["message"])
		signal.data["reject"] = 1

/*  -- Actual language proc code --  */
/datum/signal/proc/mem(var/address, var/value)
	if(istext(address))
		var/obj/machinery/telecomms/server/S = data["server"]

		if(!value && value != 0)
			return S.memory[address]

		else
			S.memory[address] = value

/datum/signal/proc/tcombroadcast(var/message, var/freq, var/source, var/job)
	var/datum/signal/newsign = new
	var/obj/machinery/telecomms/server/S = data["server"]
	var/obj/item/device/radio/hradio = S.server_radio

	if(!hradio)
		error("[src] has no radio.")
		return

	if((!message || message == "") && message != 0)
		message = "*beep*"
	if(!source)
		source = "[html_encode(uppertext(S.id))]"
		hradio = new // sets the hradio as a radio intercom
	if(!freq || (!isnum(freq) && text2num(freq) == null))
		freq = 1459
	if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
		freq *= 10 // shift the decimal one place

	if(!job)
		job = "?"

	newsign.data["mob"] = null
	newsign.data["mobtype"] = /mob/living/carbon/human
	newsign.data["name"] = source
	newsign.data["realname"] = newsign.data["name"]
	newsign.data["job"] = "[job]"
	newsign.data["compression"] = 0
	newsign.data["message"] = message
	newsign.data["type"] = 2 // artificial broadcast
	if(!isnum(freq))
		freq = text2num(freq)
	newsign.frequency = freq

	var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)
	newsign.data["connection"] = connection


	newsign.data["radio"] = hradio
	newsign.data["vmessage"] = message
	newsign.data["vname"] = source
	newsign.data["vmask"] = 0
	newsign.data["level"] = data["level"]

	var/pass = S.relay_information(newsign, "/obj/machinery/telecomms/hub")
	if(!pass)
		S.relay_information(newsign, "/obj/machinery/telecomms/broadcaster") // send this simple message to broadcasters

/datum/signal/proc/interface_machine(var/machine_tag,var/list/arglist)
	var/obj/machinery/telecomms/server/S = data["server"]

	var/datum/server_machine_link/L = S.linked_machines_by_tag[machine_tag]
	if(L == null)
		return
	var/obj/machinery/M = L.machine

	if(M.loc.loc != S.loc.loc)
		return

	return M.server_interface(arglist)

/datum/signal/proc/pda_message(recipient, message)
	var/obj/machinery/telecomms/server/S = data["server"]
	if(!istext(recipient))
		return
	if(!message)
		return
	var/obj/machinery/message_server/useMS = null
	if(message_servers)
		for (var/obj/machinery/message_server/MS in message_servers)
			if(MS.active)
				useMS = MS
				break
	if(useMS)
		for(var/obj/item/device/pda/P in PDAs)
			if (P.owner==recipient)
				useMS.send_pda_message("[P.owner]", "[S.id] Automated Broadcast", message)
				var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)
				PM:notify("<b>Message from [S.id] (Automated Message), </b>\"[message]\" (<i>Unable to Reply</i>)", 0)
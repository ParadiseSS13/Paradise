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

	interpreter.CreateGlobalScope() // Reset the variables.
	interpreter.curScope = interpreter.globalScope

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
	interpreter.SetProc("sleep", "delay", signal, list("time"))

	/*
		-> Replaces a string with another string
				@format: replace(string, substring, replacestring)

				@param string: 			the string to search for substrings (best used with $content$ constant)
				@param substring: 		the substring to search for
				@param replacestring: 	the string to replace the substring with

	*/
	interpreter.SetProc("replace",		/proc/n_replacetext)

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

	interpreter.SetProc("text2vector",	/proc/n_splittext)
	interpreter.SetProc("vector2text",	/proc/n_jointext)

	// Donkie~
	// Strings
	interpreter.SetProc("lower",		/proc/n_lower)
	interpreter.SetProc("upper",		/proc/n_upper)
	interpreter.SetProc("explode",		/proc/string_explode)
	interpreter.SetProc("implode",		/proc/n_jointext)
	interpreter.SetProc("repeat",		/proc/n_repeat)
	interpreter.SetProc("reverse",		/proc/reverse_text)
	interpreter.SetProc("tonum",		/proc/n_str2num)
	interpreter.SetProc("capitalize",	/proc/capitalize)
	interpreter.SetProc("replacetextEx",/proc/n_replacetextEx)

	// Numbers
	interpreter.SetProc("tostring",		/proc/n_num2str)
	interpreter.SetProc("sqrt",			/proc/n_sqrt)
	interpreter.SetProc("abs",			/proc/n_abs)
	interpreter.SetProc("floor",		/proc/n_floor)
	interpreter.SetProc("ceil",			/proc/n_ceiling)
	interpreter.SetProc("round",		/proc/n_round)
	interpreter.SetProc("clamp",		/proc/n_clamp)
	interpreter.SetProc("inrange",		/proc/n_isInRange)
	interpreter.SetProc("rand",			/proc/rand_chance)
	interpreter.SetProc("arctan",		/proc/Atan2)
	interpreter.SetProc("lcm",			/proc/n_lcm)
	interpreter.SetProc("gcd",			/proc/Gcd)
	interpreter.SetProc("mean",			/proc/Mean)
	interpreter.SetProc("root",			/proc/n_root)
	interpreter.SetProc("sin",			/proc/n_sin)
	interpreter.SetProc("cos",			/proc/n_cos)
	interpreter.SetProc("arcsin",		/proc/n_asin)
	interpreter.SetProc("arccos",		/proc/n_acos)
	interpreter.SetProc("tan",			/proc/n_tan)
	interpreter.SetProc("csc",			/proc/n_csc)
	interpreter.SetProc("cot",			/proc/n_cot)
	interpreter.SetProc("sec",			/proc/n_sec)
	interpreter.SetProc("todegrees",	/proc/n_toDegrees)
	interpreter.SetProc("toradians",	/proc/n_toRadians)
	interpreter.SetProc("lerp",			/proc/Lerp)
	interpreter.SetProc("max",			/proc/n_max)
	interpreter.SetProc("min",			/proc/n_min)

	// End of Donkie~

	// Time
	interpreter.SetProc("time",			/proc/time)
	interpreter.SetProc("timestamp",	/proc/timestamp)

	// Run the compiled code
	interpreter.Run()

	// Backwards-apply variables onto signal data
	/* sanitize EVERYTHING. fucking players can't be trusted with SHIT */

	/* Okay, so, the original 'sanitizing' code... did fucking nothing. Then PJB fixed it, which means no HTML.
	   But I like HTML, so back to no sanitizing.*/

	var/message = interpreter.GetVar("$content")
	var/regex/bannedTags = new ("(<script|<iframe|<video|<audio)")
	if(bannedTags.Find(message)) //uh oh
		message_admins("Warning: Current Telecomms script contains banned html. Stripping message.")
		log_admin("Warning: Current Telecomms script contains banned html. Stripping message.")
		message = interpreter.GetCleanVar("$content", signal.data["message"])

	signal.data["message"] 	= message
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
/datum/signal/proc/delay(var/time)
	var/obj/machinery/telecomms/server/S = data["server"]
	var/datum/n_Interpreter/TCS_Interpreter/interpreter = S.Compiler.interpreter
	// Backup the scope
	var/datum/scope/globalScope = interpreter.globalScope
	var/datum/scope/curScope = interpreter.curScope
	var/list/scopes = interpreter.scopes.stack.Copy()
	var/list/functions = interpreter.functions.stack.Copy()
	var/datum/node/statement/FunctionDefinition/curFunction = interpreter.curFunction
	var/status = interpreter.status
	var/returnVal = interpreter.returnVal
	// Sleep
	sleep(time)
	// Restore the scope
	interpreter.returnVal = returnVal
	interpreter.status = status
	interpreter.curFunction = curFunction
	interpreter.functions.stack = functions
	interpreter.scopes.stack = scopes
	interpreter.curScope = curScope
	interpreter.globalScope = globalScope

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
// Dont touch this subsystem unless you ABSOLUTELY know what you are doing

SUBSYSTEM_DEF(blackbox)
	name = "Blackbox"
	flags = SS_NO_FIRE | SS_NO_INIT
	// Even though we dont initialize, we need this init_order
	// On Master.Shutdown(), it shuts down subsystems in the REVERSE order
	// The database SS has INIT_ORDER_DBCORE=20, and this SS has INIT_ORDER_BLACKBOX=19
	// So putting this ensures it shuts down in the right order
	init_order = INIT_ORDER_BLACKBOX

	/// List of all recorded feedback
	var/list/datum/feedback_variable/feedback = list()
	/// Is it time to stop tracking stats?
	var/sealed = FALSE
	/// List of highest tech levels attained that isn't lost lost by destruction of RD computers
	var/list/research_levels = list()
	/// Associative list of any feedback variables that have had their format changed since creation and their current version, remember to update this
	var/list/versions = list()

/datum/controller/subsystem/blackbox/Recover()
	feedback = SSblackbox.feedback
	sealed = SSblackbox.sealed

//no touchie
/datum/controller/subsystem/blackbox/can_vv_get(var_name)
	if(var_name == "feedback")
		return debug_variable(var_name, deepCopyList(feedback), 0, src)
	return ..()

/datum/controller/subsystem/blackbox/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("feedback")
			return FALSE
		if("sealed")
			if(var_value)
				return Seal()
			return FALSE
	return ..()

/**
  * Shutdown Helper
  *
  * Dumps all feedback stats to the DB. Doesnt get much simpler than that.
  */
/datum/controller/subsystem/blackbox/Shutdown()
	sealed = FALSE
	for(var/obj/machinery/message_server/MS in GLOB.message_servers)
		if(MS.pda_msgs.len)
			record_feedback("tally", "radio_usage", MS.pda_msgs.len, "PDA")
		if(MS.rc_msgs.len)
			record_feedback("tally", "radio_usage", MS.rc_msgs.len, "request console")

	if(length(research_levels))
		record_feedback("associative", "high_research_level", 1, research_levels)

	if(!SSdbcore.IsConnected())
		return

	var/list/datum/db_query/queries = list()

	for(var/datum/feedback_variable/FV in feedback)
		var/sqlversion = 1
		if(FV.key in versions)
			sqlversion = versions[FV.key]

		var/datum/db_query/query_feedback_save = SSdbcore.NewQuery({"
		INSERT DELAYED IGNORE INTO [format_table_name("feedback")] (datetime, round_id, key_name, key_type, version, json)
		VALUES (NOW(), :rid, :keyname, :keytype, :version, :json)"}, list(
			"rid" = text2num(GLOB.round_id),
			"keyname" = FV.key,
			"keytype" = FV.key_type,
			"version" = text2num(sqlversion),
			"json" = json_encode(FV.json)
		))
		queries += query_feedback_save

	SSdbcore.MassExecute(queries, TRUE, TRUE)

/**
  * Blackbox Sealer
  *
  * Seals the blackbox, preventing new data from being stored. This is to avoid data being bloated during end round grief
  */
/datum/controller/subsystem/blackbox/proc/Seal()
	if(sealed)
		return FALSE
	log_game("Blackbox sealed")
	sealed = TRUE
	return TRUE

/**
  * Research level broadcast logging helper
  *
  * This is called on R&D updates for a safe way of logging tech levels if an R&D console is destroyed
  *
  * Arguments:
  * * tech - Research technology name
  * * level - Research technology level
  */
/datum/controller/subsystem/blackbox/proc/log_research(tech, level)
	if(!(tech in research_levels) || research_levels[tech] < level)
		research_levels[tech] = level


/**
  * Radio broadcast logging helper
  *
  * Called during [/proc/broadcast_message()] to log a message to the blackbox.
  * Translates the specific frequency to a name
  *
  * Arguments:
  * * freq - Frequency of the transmission
  */
/datum/controller/subsystem/blackbox/proc/LogBroadcast(freq)
	if(sealed)
		return
	switch(freq)
		if(PUB_FREQ)
			record_feedback("tally", "radio_usage", 1, "common")
		if(SCI_FREQ)
			record_feedback("tally", "radio_usage", 1, "science")
		if(COMM_FREQ)
			record_feedback("tally", "radio_usage", 1, "command")
		if(MED_FREQ)
			record_feedback("tally", "radio_usage", 1, "medical")
		if(ENG_FREQ)
			record_feedback("tally", "radio_usage", 1, "engineering")
		if(SEC_FREQ)
			record_feedback("tally", "radio_usage", 1, "security")
		if(DTH_FREQ)
			record_feedback("tally", "radio_usage", 1, "deathsquad")
		if(SYND_FREQ)
			record_feedback("tally", "radio_usage", 1, "syndicate")
		if(SYND_TAIPAN_FREQ)
			record_feedback("tally", "radio_usage", 1, "syndicate taipan")
		if(SYNDTEAM_FREQ)
			record_feedback("tally", "radio_usage", 1, "syndicate team")
		if(SUP_FREQ)
			record_feedback("tally", "radio_usage", 1, "supply")
		if(SRV_FREQ)
			record_feedback("tally", "radio_usage", 1, "service")
		if(PROC_FREQ)
			record_feedback("tally", "radio_usage", 1, "procedure")
		else
			record_feedback("tally", "radio_usage", 1, "other")


/**
  * Helper to find and return a feeedback datum
  *
  * Pass in a feedback datum key and key_type to do a lookup.
  * It will create the feedback datum if it doesnt exist
  *
  * Arguments:
  * * key - Key of the variable to lookup
  * * key_type - Type of feedback to be recorded if the feedback datum cant be found
  */
/datum/controller/subsystem/blackbox/proc/find_feedback_datum(key, key_type)
	for(var/datum/feedback_variable/FV in feedback)
		if(FV.key == key)
			return FV

	var/datum/feedback_variable/FV = new(key, key_type)
	feedback += FV
	return FV

/**
  * Main feedback recording proc
  *
  * This is the bulk of this subsystem and is in charge of creating and using the variables.
  * See .github/USING_FEEDBACK_DATA.md for instructions
  * Note that feedback is not recorded to the DB during this function. That happens at round end.
  *
  * Arguments:
  * * key_type - Type of key. Either "text", "amount", "tally", "nested tally", "associative"
  * * key - Key of the data to be used (EG: "admin_verb")
  * * increment - If using "amount", how much to increment why
  * * data - The actual data to logged
  * * overwrite - Do we want to overwrite the existing key
  */
/datum/controller/subsystem/blackbox/proc/record_feedback(key_type, key, increment, data, overwrite)
	if(sealed || !key_type || !istext(key) || !isnum(increment || !data))
		return
	var/datum/feedback_variable/FV = find_feedback_datum(key, key_type)
	switch(key_type)
		if("text")
			if(!istext(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			if(overwrite)
				FV.json["data"] = data
			else
				FV.json["data"] |= data
		if("amount")
			FV.json["data"] += increment
		if("tally")
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			FV.json["data"]["[data]"] += increment
		if("nested tally")
			if(!islist(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			FV.json["data"] = record_feedback_recurse_list(FV.json["data"], data, increment)
		if("associative")
			if(!islist(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			var/pos = length(FV.json["data"]) + 1
			FV.json["data"]["[pos]"] = list()
			for(var/i in data)
				FV.json["data"]["[pos]"]["[i]"] = "[data[i]]"

/**
  * Recursive list recorder
  *
  * Used by the above proc for nested tallies
  *
  * Arguments:
  * * L - List to use
  * * key_list - List of keys to add
  * * increment - How much to increase by
  * * depth - Depth to use
  */
/datum/controller/subsystem/blackbox/proc/record_feedback_recurse_list(list/L, list/key_list, increment, depth = 1)
	if(depth == key_list.len)
		if(L.Find(key_list[depth]))
			L["[key_list[depth]]"] += increment
		else
			var/list/list_found_index = list(key_list[depth] = increment)
			L += list_found_index
	else
		if(!L.Find(key_list[depth]))
			var/list/list_go_down = list(key_list[depth] = list())
			L += list_go_down
		L["[key_list[depth-1]]"] = .(L["[key_list[depth]]"], key_list, increment, ++depth)
	return L

/**
  * # feedback_variable
  *
  * Datum to hold feedback data, which gets logged at round end
  *
  * Holds all the information being logged
  */
/datum/feedback_variable
	var/key
	var/key_type
	var/list/json = list()

// Basically just takes some args and sets them
/datum/feedback_variable/New(new_key, new_key_type)
	key = new_key
	key_type = new_key_type

/**
  * Death reporting proc
  *
  * Called when humans and cyborgs die, and logs death info to the `death` table
  *
  * Arguments:
  * * L - The human or cyborg to be logged
  */
/datum/controller/subsystem/blackbox/proc/ReportDeath(mob/living/L)
	if(sealed)
		return
	if(!SSdbcore.IsConnected())
		return
	if(!L)
		return
	if(!L.key || !L.mind)
		return

	var/area/placeofdeath = get_area(L.loc)
	var/podname = "Unknown"
	if(placeofdeath)
		podname = placeofdeath.name

	// Empty string is important here!
	var/laname = ""
	var/lakey = ""
	if(L.lastattacker)
		laname = L.lastattacker
	if(L.lastattackerckey)
		lakey = L.lastattackerckey

	var/datum/db_query/deathquery = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("death")] (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord)
		VALUES (:name, :key, :job, :special, :pod, NOW(), :laname, :lakey, :gender, :bruteloss, :fireloss, :brainloss, :oxyloss, :coord)"},
		list(
			"name" = L.real_name,
			"key" = L.key,
			"job" = L.mind.assigned_role,
			"special" = L.mind.special_role || "",
			"pod" = podname,
			"laname" = laname,
			"lakey" = lakey,
			"gender" = L.gender,
			"bruteloss" = L.getBruteLoss(),
			"fireloss" = L.getFireLoss(),
			"brainloss" = L.getBrainLoss(),
			"oxyloss" = L.getOxyLoss(),
			"coord" = "[L.x], [L.y], [L.z]"
		)
	)
	deathquery.warn_execute()
	qdel(deathquery)

#define JOB_STYLE_1 "Name (Job)"
#define JOB_STYLE_2 "Name - Job"
#define JOB_STYLE_3 "\[Job\] Name"
#define JOB_STYLE_4 "(Job) Name"
GLOBAL_DATUM_INIT(nttc_config, /datum/nttc_configuration, new())
// Custom Implementations for NTTC
/* NTTC Configuration Datum
 * This is an abstract handler for the configuration loadout. It's set up like this both for ease of transfering in and out of the UI 
 * as well as allowing users to save and load configurations.
 */
/datum/nttc_configuration
	// ALL OF THE JOB CRAP
	// Dict of all jobs and their colors
	var/all_jobs = list(
		// AI
		"AI" = "#FF00FF",
		"Android" = "#FF00FF",
		"Cyborg" = "#FF00FF",
		"Personal AI" = "#FF00FF",
		"Robot" = "#FF00FF",
		// Civilian + Varients
		"Assistant" = "#408010",
		"Businessman" = "#408010",
		"Civilian" = "#408010",
		"Tourist" = "#408010",
		"Trader" = "#408010",
		// Command (Solo command, not department heads)
		"Blueshield" = "#204090",
		"Captain" = "#204090",
		"Head of Personnel" = "#204090",
		"Nanotrasen Representative" = "#204090",
		// Engineeering
		"Atmospheric Technician" = "#A66300",
		"Chief Engineer" = "#A66300",
		"Electrician" = "#A66300",
		"Engine Technician" = "#A66300",
		"Life Support Specialist" = "#A66300",
		"Maintenance Technician" = "#A66300",
		"Mechanic" = "#A66300",
		"Station Engineer" = "#A66300",
		// ERT
		"Emergency Response Team Engineer" = "#5C5C7C",
		"Emergency Response Team Leader" = "#5C5C7C",
		"Emergency Response Team Medic" = "#5C5C7C",
		"Emergency Response Team Member" = "#5C5C7C",
		"Emergency Response Team Officer" = "#5C5C7C",
		// Medical
		"Chemist" = "#009190",
		"Chief Medical Officer" = "#009190",
		"Coroner" = "#009190",
		"Medical Doctor" = "#009190",
		"Microbiologist" = "#009190",
		"Nurse" = "#009190",
		"Paramedic" = "#009190",
		"Pharmacologist" = "#009190",
		"Pharmacist" = "#009190",
		"Psychiatrist" = "#009190",
		"Psychologist" = "#009190",
		"Surgeon" = "#009190",
		"Therapist" = "#009190",
		"Virologist" = "#009190",
		// Science
		"Anomalist" = "#993399",
		"Biomechanical Engineer" = "#993399",
		"Chemical Researcher" = "#993399",
		"Geneticist" = "#993399",
		"Mechatronic Engineer" = "#993399",
		"Plasma Researcher" = "#993399",
		"Research Director" = "#993399",
		"Roboticist" = "#993399",
		"Scientist" = "#993399",
		"Xenoarcheologist" = "#993399",
		"Xenobiologist" = "#993399",
		// Security
		"Brig Physician" = "#A30000",
		"Detective" = "#A30000",
		"Forensic Technician" = "#A30000",
		"Head of Security" = "#A30000",
		"Human Resources Agent" = "#A30000",
		"Internal Affairs Agent" = "#A30000",
		"Magistrate" = "#A30000",
		"Security Officer" = "#A30000",
		"Security Pod Pilot" = "#A30000",
		"Warden" = "#A30000",
		// Supply
		"Quartermaster" = "#7F6539",
		"Cargo Technician" = "#7F6539",
		"Shaft Miner" = "#7F6539",
		"Spelunker" = "#7F6539",
		// Service
		"Barber" = "#80A000",
		"Bartender" = "#80A000",
		"Beautician" = "#80A000",
		"Botanical Researcher" = "#80A000",
		"Botanist" = "#80A000",
		"Butcher" = "#80A000",
		"Chaplain" = "#80A000",
		"Chef" = "#80A000",
		"Clown" = "#80A000",
		"Cook" = "#80A000",
		"Culinary Artist" = "#80A000",
		"Custodial Technician" = "#80A000",
		"Hair Stylist" = "#80A000",
		"Hydroponicist" = "#80A000",
		"Janitor" = "#80A000",
		"Journalist" = "#80A000",
		"Librarian" = "#80A000",
		"Mime" = "#80A000",
	)
	// Just command members
	var/heads = list("Captain", "Head of Personnel", "Nanotrasen Representative", "Blueshield", "Chief Engineer", "Chief Medical Officer", "Research Director", "Head of Security")
	// Just ERT
	var/ert_jobs = list("Emergency Response Team Officer", "Emergency Response Team Engineer", "Emergency Response Team Medic", "Emergency Response Team Leader", "Emergency Response Team Member")
	// Defined so code compiles and incase someone has a non-standard job
	var/job_color = "#000000"
	// NOW FOR ACTUAL TOGGLES
	/* Simple Toggles */
	var/toggle_activated = TRUE
	var/toggle_jobs = FALSE
	var/toggle_job_color = FALSE
	var/toggle_name_color = FALSE
	var/toggle_timecode = FALSE
	var/toggle_command_bold = FALSE
	// Hack section
	var/toggle_gibberish = FALSE
	var/toggle_honk = FALSE

	/* Strings */
	var/setting_language = null
	var/job_indicator_type = null

	/* Tables */
	var/list/regex = list()

	/* Arrays */
	var/list/firewall = list()

	/* Meta stuff */
	// These variables requires the source computer to be hacked in order to change
	var/list/requires_unlock = list(
		"firewall" = TRUE,
		"toggle_gibberish" = TRUE,
		"toggle_honk" = TRUE,
	)

	// This is used to sanitize topic data
	var/list/tables = list("regex")
	var/list/arrays = list("firewall")

	// This tells the datum what is safe to serialize and what's not. It also applies to deserialization.
	var/list/to_serialize = list(
		"toggle_activated",
		"toggle_jobs",
		"toggle_job_color",
		"toggle_name_color",
		"job_indicator_type",
		"toggle_timecode",
		"toggle_command_bold",
		"toggle_gibberish",
		"toggle_honk",
		"setting_language",
		"regex",
		"firewall"
	)

	// This is used for sanitization.
	var/list/serialize_sanitize = list(
		"toggle_activated" = "bool",
		"toggle_jobs" = "bool",
		"toggle_job_color" = "bool",
		"toggle_name_color" = "bool",
		"job_indicator_type" = "string",
		"toggle_timecode" = "bool",
		"toggle_command_bold" = "bool",
		"toggle_gibberish" = "bool",
		"toggle_honk" = "bool",
		"setting_language" = "string",
		"regex" = "table",
		"firewall" = "array"
	)

	// These are the job card styles
	var/list/job_card_styles = list(
		JOB_STYLE_1, JOB_STYLE_2, JOB_STYLE_3, JOB_STYLE_4
	)
	// Used to determine what languages are allowable for conversion. Generated during runtime.
	var/list/valid_languages = list("--DISABLE--")

/datum/nttc_configuration/proc/reset()
	/* Simple Toggles */
	toggle_activated = initial(toggle_activated)
	toggle_jobs = initial(toggle_jobs)
	toggle_job_color = initial(toggle_job_color)
	toggle_name_color = initial(toggle_name_color)
	toggle_timecode = initial(toggle_timecode)
	toggle_command_bold = initial(toggle_command_bold)
	// Hack section
	toggle_gibberish = initial(toggle_gibberish)
	toggle_honk = initial(toggle_honk)

	/* Strings */
	setting_language = initial(setting_language)
	job_indicator_type = initial(job_indicator_type)

	/* Tables */
	regex = list()

	/* Arrays */ 
	firewall = list()


/datum/nttc_configuration/proc/update_languages()
	for(var/language in GLOB.all_languages)
		var/datum/language/L = GLOB.all_languages[language]
		if(L.flags & HIVEMIND)
			continue
		valid_languages[language] = TRUE

// I'd use serialize() but it's used by another system. This converts the configuration into a JSON string.
/datum/nttc_configuration/proc/nttc_serialize()
	. = list()
	for(var/variable in to_serialize)
		.[variable] = vars[variable]
	. = json_encode(.)
	
// This loads a configuration from a JSON string.
// Fucking broken as shit, someone help me fix this.
/datum/nttc_configuration/proc/nttc_deserialize(text, obj/machinery/computer/telecomms/traffic/source)
	var/list/var_list = json_decode(text)
	for(var/variable in var_list)
		if(variable in to_serialize) // Don't just accept any random vars jesus christ!
			if(requires_unlock[variable] && (source && !source.unlocked))
				continue
			var/sanitize_method = serialize_sanitize[variable]
			var/variable_value = var_list[variable]
			variable_value = nttc_sanitize(variable_value, sanitize_method)
			if(variable_value != null)
				vars[variable] = variable_value

// Sanitizing user input. Don't blindly trust the JSON.
/datum/nttc_configuration/proc/nttc_sanitize(variable, sanitize_method)
	if(!sanitize_method)
		return null

	switch(sanitize_method)
		if("bool")
			return variable ? TRUE : FALSE
		if("table", "array")
			if(!islist(variable))
				return list()
			// Insert html filtering for the regexes here if you're boring
			var/newlist = json_decode(html_decode(json_encode(variable)))
			if(!islist(newlist))
				return null
			return newlist
		if("string")
			return "[variable]"

	return variable

// Primary signal modification. This is where all of the variables behavior are actually implemented.
/datum/nttc_configuration/proc/modify_signal(datum/signal/signal)
	// Servers are deliberately turned off. Mark every signal as rejected.
	if(!toggle_activated)
		signal.data["reject"] = TRUE
		return

	// Firewall 
	// This must happen before anything else modifies the signal ["name"].
	if(islist(firewall) && firewall.len > 0)
		if(firewall.Find(signal.data["name"]))
			signal.data["reject"] = 1

	// All job and coloring shit 
	if(toggle_job_color || toggle_name_color)
		var/job = signal.data["job"]
		job_color = all_jobs[job]
		
	if(toggle_name_color)
		var/new_name = "<font color=\"[job_color]\">" + signal.data["name"] + "</font>"
		signal.data["name"] = new_name
		signal.data["realname"] = new_name // this is required because the broadcaster uses this directly if the speaker doesn't have a voice changer on

	if(toggle_jobs)
		var/new_name = ""
		var/job = signal.data["job"]
		if(job in ert_jobs)
			job = "ERT"
		if(toggle_job_color)
			switch(job_indicator_type)
				if(JOB_STYLE_1)
					new_name = signal.data["name"] + " <font color=\"[job_color]\">([job])</font> "
				if(JOB_STYLE_2)
					new_name = signal.data["name"] + " - <font color=\"[job_color]\">[job]</font> "
				if(JOB_STYLE_3)
					new_name = "<font color=\"[job_color]\"><small>\[[job]\]</small></font> " + signal.data["name"] + " "
				if(JOB_STYLE_4)
					new_name = "<font color=[job_color]>([job])</font> " + signal.data["name"] + " "
		else
			switch(job_indicator_type)
				if(JOB_STYLE_1)
					new_name = signal.data["name"] + " ([job]) "
				if(JOB_STYLE_2)
					new_name = signal.data["name"] + " - [job] "
				if(JOB_STYLE_3)
					new_name = "<small>\[[job]\]</small> " + signal.data["name"] + " "
				if(JOB_STYLE_4)
					new_name = "([job]) " + signal.data["name"] + " "

		signal.data["name"] = new_name
		signal.data["realname"] = new_name // this is required because the broadcaster uses this directly if the speaker doesn't have a voice changer on

	// Add the current station time like a time code.
	if(toggle_timecode)
		var/new_name = "\[[station_time_timestamp()]] " + signal.data["name"]
		signal.data["name"] = new_name
		signal.data["realname"] = new_name // this is required because the broadcaster uses this directly if the speaker doesn't have a voice changer on

	// This is hacky stuff for multilingual messages...
	var/list/message_pieces = signal.data["message"]

	// Makes heads of staff bold
	if(toggle_command_bold)
		var/job = signal.data["job"]
		if((job in ert_jobs) || (job in heads))
			for(var/datum/multilingual_say_piece/S in message_pieces)
				S.message = "<b>[S.message]</b>"

	// Hacks!
	// Censor dat shit like nobody's business
	if(toggle_gibberish)
		Gibberish_all(message_pieces, 80)

	// Replace everything with HONK!
	if(toggle_honk)
		var/list/split = splittext(signal.data["message"], " ")
		var/honklength = split.len
		var/new_message = ""
		for(var/i in 1 to honklength)
			new_message += pick("HoNK!", "HONK", "HOOOoONK", "HONKHONK!", "HoNnnkKK!!!", "HOOOOOOOOOOONK!!!!11!", "henk!") + " "
		signal.data["message"] = message_to_multilingual(new_message)

	// Language Conversion
	if(setting_language && valid_languages[setting_language])
		if(setting_language == "--DISABLE--")
			setting_language = null
		else
			for(var/datum/multilingual_say_piece/S in message_pieces)
				S.speaking = GLOB.all_languages[setting_language]

	// Regex replacements
	if(islist(regex) && regex.len > 0)
		for(var/datum/multilingual_say_piece/S in message_pieces)
			var/new_message = S.message
			for(var/reg in regex)
				var/replacePattern = pencode_to_html(regex[reg])
				var/regex/start = regex("[reg]", "gi")
				new_message = start.Replace(new_message, replacePattern)
			S.message = new_message

	// Make sure the message is valid after we tinkered with it, otherwise reject it
	if(signal.data["message"] == "" || !signal.data["message"])
		signal.data["reject"] = 1

/datum/nttc_configuration/Topic(mob/user, href_list, window_id, obj/machinery/computer/telecomms/traffic/source)
	// Toggles
	if(href_list["toggle"])
		var/var_to_toggle = href_list["toggle"]
		if(requires_unlock[var_to_toggle] && !source.unlocked)
			return
		if(!(var_to_toggle in to_serialize))
			return
		vars[var_to_toggle] = !vars[var_to_toggle]
		log_action(user, "toggled NTTC variable [var_to_toggle] [vars[var_to_toggle] ? "on" : "off"]")

	// Job Format
	if(href_list["setting_job_card_style"])
		var/card_style = input(user, "Pick a job card format.", "Job Card Format") as null|anything in job_card_styles
		if(!card_style)
			return
		job_indicator_type = card_style
		to_chat(user, "<span class='notice'>Jobs will now have the style of [card_style].</span>")
		log_action(user, "has set NTTC job card format to [card_style]", TRUE)

	// Strings
	if(href_list["setting_language"])
		var/new_language = input(user, "Pick a language to convert messages to.", "Language Conversion") as null|anything in valid_languages
		if(!new_language)
			return
		if(new_language == "--DISABLE--")
			setting_language = null
			to_chat(user, "<span class='notice'>Language conversion disabled.</span>")
		else
			setting_language = new_language
			to_chat(user, "<span class='notice'>Messages will now be converted to [new_language].</span>")

		log_action(user, new_language == "--DISABLE--" ? "disabled NTTC language conversion" : "set NTTC language conversion to [new_language]", TRUE)

	// Tables
	if(href_list["create_row"])
		if(href_list["table"] && href_list["table"] in tables)
			if(requires_unlock[href_list["table"]] && !source.unlocked)
				return
			var/new_key = input(user, "Provide a key for the new row.", "New Row") as text|null
			if(!new_key)
				return
			var/new_value = input(user, "Provide a new value for the key [new_key]", "New Row") as text|null
			if(new_value == null)
				return
			var/list/table = vars[href_list["table"]]
			table[new_key] = new_value
			to_chat(user, "<span class='notice'>Added row [new_key] -> [new_value].</span>")
			log_action(user, "updated [href_list["table"]] - new row [new_key] -> [new_value]")

	if(href_list["delete_row"])
		if(href_list["table"] && href_list["table"] in tables)
			if(requires_unlock[href_list["table"]] && !source.unlocked)
				return
			var/list/table = vars[href_list["table"]]
			table.Remove(href_list["delete_row"])
			to_chat(user, "<span class='warning'>Removed row [href_list["delete_row"]] from [href_list["table"]]</span>")
			log_action(user, "updated [href_list["table"]] - removed row [href_list["delete_row"]]")

	// Arrays
	if(href_list["create_item"])
		if(href_list["array"] && href_list["array"] in arrays)
			if(requires_unlock[href_list["array"]] && !source.unlocked)
				return
			var/new_value = input(user, "Provide a value for the new index.", "New Index") as text|null
			if(new_value == null) 
				return
			var/list/array = vars[href_list["array"]]
			array.Add(new_value)
			to_chat(user, "<span class='notice'>Added row [new_value].</span>")
			log_action(user, "updated [href_list["array"]] - new value [new_value]", TRUE)

	if(href_list["delete_item"])
		if(href_list["array"] && href_list["array"] in arrays)
			if(requires_unlock[href_list["array"]] && !source.unlocked)
				return
			var/list/array = vars[href_list["array"]]
			array.Remove(href_list["delete_item"])
			to_chat(user, "<span class='warning'>Removed [href_list["delete_item"]] from [href_list["array"]]</span>")
			log_action(user, "updated [href_list["array"]] - removed [href_list["delete_item"]]")

	// Spit out the serialized config to the user
	if(href_list["save_config"])
		user << browse(nttc_serialize(), "window=save_nttc")

	if(href_list["load_config"])
		var/json = input(user, "Provide configuration JSON below.", "Load Config", nttc_serialize()) as message
		nttc_deserialize(json, source)
		log_action(user, "has uploaded a NTTC JSON configuration: [ADMIN_SHOWDETAILS("Show", json)]", TRUE)

	user << output(list2params(list(nttc_serialize())), "[window_id].browser:updateConfig")

/datum/nttc_configuration/proc/log_action(user, msg, adminmsg = FALSE)
	log_game("NTTC: [key_name(user)] [msg]")
	log_investigate("[key_name(user)] [msg]", "ntsl")
	if(adminmsg)
		message_admins("[key_name_admin(user)] [msg]")

/* Asset datum for the UI */
/datum/asset/simple/nttc
	assets = list(
		"bundle.css" = 'html/nttc/dist/bundle.css',
		"bundle.js" = 'html/nttc/dist/bundle.js',
		"tab_home.html" = 'html/nttc/dist/tab_home.html',
		"tab_hack.html" = 'html/nttc/dist/tab_hack.html',
		"tab_filtering.html" = 'html/nttc/dist/tab_filtering.html',
		"tab_firewall.html" = 'html/nttc/dist/tab_firewall.html',
		"tab_regex.html" = 'html/nttc/dist/tab_regex.html',
		"uiTitleFluff.png" = 'html/nttc/dist/uiTitleFluff.png'
	)

/* Custom subtype of /datum/browser that behaves as we want for our project */
/datum/browser/nttc
	var/initial_config // Initial NTTC configuration

/datum/browser/nttc/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, var/atom/nref = null, nttc_config)
	. = ..()
	initial_config = nttc_config
// Prevent all stylesheets from being added, we have our own CSS that's bundled with gulp
/datum/browser/nttc/add_stylesheet()
	return
// No header, we're running a fully complete .html file
/datum/browser/nttc/get_header()
	return
// We inject a little code at the bottom of the file, similar to NanoUI, but more limited.
// This code is used for delivering live updates of config changes & allowing the UI to provide Topic data.
/datum/browser/nttc/get_footer()
	var/byondSrc = "byond://?src=[ref.UID()];"
	var/dat = "<script type='text/javascript'>"
	dat += "window.byondSrc = '[byondSrc]';"
	dat += "window.originalConfig = '[html_encode(initial_config)]';"
	dat += "window.updateConfig = function(config) { window.config = JSON.parse(config); window.reload_tab() };"
	dat += "</script>"
	return dat


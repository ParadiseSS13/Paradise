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
	var/regex/word_blacklist = new("(<iframe|<embed|<script|<svg|<canvas|<video|<audio|onload)", "i") // Blacklist of naughties
	// ALL OF THE JOB CRAP
	// Dict of all jobs and their department color classes
	var/all_jobs = list(
		// AI
		"AI" = "airadio",
		"Android" = "airadio",
		"Cyborg" = "airadio",
		"Personal AI" = "airadio",
		"Robot" = "airadio",
		// Civilian + Varients
		"Assistant" = "radio",
		"Businessman" = "radio",
		"Civilian" = "radio",
		"Tourist" = "radio",
		"Trader" = "radio",
		// Command (Solo command, not department heads)
		"Blueshield" = "comradio",
		"Captain" = "comradio",
		"Head of Personnel" = "comradio",
		"Nanotrasen Representative" = "comradio",
		// Engineeering
		"Atmospheric Technician" = "engradio",
		"Chief Engineer" = "engradio",
		"Electrician" = "engradio",
		"Engine Technician" = "engradio",
		"Life Support Specialist" = "engradio",
		"Maintenance Technician" = "engradio",
		"Mechanic" = "engradio",
		"Station Engineer" = "engradio",
		// ERT
		"Emergency Response Team Engineer" = "dsquadradio", // I know this says deathsquad but the class for responseteam is neon green. No.
		"Emergency Response Team Leader" = "dsquadradio",
		"Emergency Response Team Medic" = "dsquadradio",
		"Emergency Response Team Member" = "dsquadradio",
		"Emergency Response Team Officer" = "dsquadradio",
		// Medical
		"Chemist" = "medradio",
		"Chief Medical Officer" = "medradio",
		"Coroner" = "medradio",
		"Medical Doctor" = "medradio",
		"Microbiologist" = "medradio",
		"Nurse" = "medradio",
		"Paramedic" = "medradio",
		"Pharmacologist" = "medradio",
		"Pharmacist" = "medradio",
		"Psychiatrist" = "medradio",
		"Psychologist" = "medradio",
		"Surgeon" = "medradio",
		"Therapist" = "medradio",
		"Virologist" = "medradio",
		// Science
		"Anomalist" = "sciradio",
		"Biomechanical Engineer" = "sciradio",
		"Chemical Researcher" = "sciradio",
		"Geneticist" = "sciradio",
		"Mechatronic Engineer" = "sciradio",
		"Plasma Researcher" = "sciradio",
		"Research Director" = "sciradio",
		"Roboticist" = "sciradio",
		"Scientist" = "sciradio",
		"Xenoarcheologist" = "sciradio",
		"Xenobiologist" = "sciradio",
		// Security
		"Brig Physician" = "secradio",
		"Detective" = "secradio",
		"Forensic Technician" = "secradio",
		"Head of Security" = "secradio",
		"Human Resources Agent" = "secradio",
		"Internal Affairs Agent" = "secradio",
		"Magistrate" = "secradio",
		"Security Officer" = "secradio",
		"Security Pod Pilot" = "secradio",
		"Warden" = "secradio",
		// Supply
		"Quartermaster" = "supradio",
		"Cargo Technician" = "supradio",
		"Shaft Miner" = "supradio",
		"Spelunker" = "supradio",
		// Service
		"Barber" = "srvradio",
		"Bartender" = "srvradio",
		"Beautician" = "srvradio",
		"Botanical Researcher" = "srvradio",
		"Botanist" = "srvradio",
		"Butcher" = "srvradio",
		"Chaplain" = "srvradio",
		"Chef" = "srvradio",
		"Clown" = "srvradio",
		"Cook" = "srvradio",
		"Culinary Artist" = "srvradio",
		"Custodial Technician" = "srvradio",
		"Hair Stylist" = "srvradio",
		"Hydroponicist" = "srvradio",
		"Janitor" = "srvradio",
		"Journalist" = "srvradio",
		"Librarian" = "srvradio",
		"Mime" = "srvradio",
	)
	// Just command members
	var/heads = list("Captain", "Head of Personnel", "Nanotrasen Representative", "Blueshield", "Chief Engineer", "Chief Medical Officer", "Research Director", "Head of Security", "Magistrate", "AI")
	// Just ERT
	var/ert_jobs = list("Emergency Response Team Officer", "Emergency Response Team Engineer", "Emergency Response Team Medic", "Emergency Response Team Leader", "Emergency Response Team Member")
	// Defined so code compiles and incase someone has a non-standard job
	var/job_class = "radio"
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
	// var/list/regex = list()

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
	// var/list/tables = list("regex")
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
		// "regex",
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
		// "regex" = "table",
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
	// regex = list()

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
/datum/nttc_configuration/proc/nttc_deserialize(text, obj/machinery/computer/telecomms/traffic/source, var/ckey)
	if(word_blacklist.Find(text)) //uh oh, they tried to be naughty
		message_admins("<span class='danger'>EXPLOIT WARNING: </span> [ckey] attempted to upload an NTTC configuration containing JS abusable tags!")
		log_admin("EXPLOIT WARNING: [ckey] attempted to upload an NTTC configuration containing JS abusable tags")
		return FALSE
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
	return TRUE

// Sanitizing user input. Don't blindly trust the JSON.
/datum/nttc_configuration/proc/nttc_sanitize(variable, sanitize_method)
	if(!sanitize_method)
		return null

	switch(sanitize_method)
		if("bool")
			return variable ? TRUE : FALSE
		// if("table", "array")
		if("array")
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
		job_class = all_jobs[job]

	if(toggle_name_color)
		var/new_name = "<span class=\"[job_class]\">" + signal.data["name"] + "</span>"
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
					new_name = signal.data["name"] + " <span class=\"[job_class]\">([job])</span> "
				if(JOB_STYLE_2)
					new_name = signal.data["name"] + " - <span class=\"[job_class]\">[job]</span> "
				if(JOB_STYLE_3)
					new_name = "<span class=\"[job_class]\"><small>\[[job]\]</small></span> " + signal.data["name"] + " "
				if(JOB_STYLE_4)
					new_name = "<span class=[job_class]>([job])</span> " + signal.data["name"] + " "
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
				S.message = "<b>[capitalize(S.message)]</b>" // This only capitalizes the first word

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
				if(S.speaking != GLOB.all_languages["Noise"]) // check if they are emoting, these do not need to be translated
					S.speaking = GLOB.all_languages[setting_language]

	// Regex replacements
	// if(islist(regex) && regex.len > 0)
	// 	for(var/datum/multilingual_say_piece/S in message_pieces)
	// 		var/new_message = S.message
	// 		for(var/reg in regex)
	// 			var/replacePattern = pencode_to_html(regex[reg])
	// 			var/regex/start = regex("[reg]", "gi")
	// 			new_message = start.Replace(new_message, replacePattern)
	// 		S.message = new_message

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
	// if(href_list["create_row"])
	// 	if(href_list["table"] && href_list["table"] in tables)
	// 		if(requires_unlock[href_list["table"]] && !source.unlocked)
	// 			return
	// 		var/new_key = clean_input(user, "Provide a key for the new row.", "New Row")
	// 		if(!new_key)
	// 			return
	// 		var/new_value = clean_input(user, "Provide a new value for the key [new_key]", "New Row")
	// 		if(new_value == null)
	// 			return
	// 		if(word_blacklist.Find(new_value)) //uh oh, they tried to be naughty
	// 			message_admins("<span class='danger'>EXPLOIT WARNING: </span> [user.ckey] attempted to add a NTTC regex row containing JS abusable tags!")
	// 			log_admin("EXPLOIT WARNING: [user.ckey] attempted to add a NTTC regex row containing JS abusable tags")
	// 			to_chat(user, "<span class='biggerdanger'>ERROR: Regex contained bad strings. Upload cancelled.</span>")
	// 			return
	// 		var/list/table = vars[href_list["table"]]
	// 		table[new_key] = new_value
	// 		to_chat(user, "<span class='notice'>Added row [new_key] -> [new_value].</span>")
	// 		log_action(user, "updated [href_list["table"]] - new row [new_key] -> [new_value]")

	// if(href_list["delete_row"])
	// 	if(href_list["table"] && href_list["table"] in tables)
	// 		if(requires_unlock[href_list["table"]] && !source.unlocked)
	// 			return
	// 		var/list/table = vars[href_list["table"]]
	// 		table.Remove(href_list["delete_row"])
	// 		to_chat(user, "<span class='warning'>Removed row [href_list["delete_row"]] from [href_list["table"]]</span>")
	// 		log_action(user, "updated [href_list["table"]] - removed row [href_list["delete_row"]]")

	// Arrays
	if(href_list["create_item"])
		if(href_list["array"] && href_list["array"] in arrays)
			if(requires_unlock[href_list["array"]] && !source.unlocked)
				return
			var/new_value = clean_input(user, "Provide a value for the new index.", "New Index")
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
		if(nttc_deserialize(json, source, user.ckey))
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
		// "tab_regex.html" = 'html/nttc/dist/tab_regex.html',
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


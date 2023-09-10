/*
	NTTC system
	This is basically the replacement for NTSL and allows tickbox features such as job titles and colours, without needing a script
	This also means that there is no user input here, which means the system isnt prone to exploits since its only selecting options, no user input
	Basically, just imagine pfSense for tcomms

	All this code was written by Tigercat2000. I take no credit -aa07
*/

#define JOB_STYLE_1 "Name (Job)"
#define JOB_STYLE_2 "Name - Job"
#define JOB_STYLE_3 "\[Job\] Name"
#define JOB_STYLE_4 "(Job) Name"

/datum/nttc_configuration
	var/regex/word_blacklist = new("(<iframe|<embed|<script|<svg|<canvas|<video|<audio|onload)", "i") // Blacklist of naughties
	// ALL OF THE JOB CRAP
	/// Associative list of all jobs and their department color classes
	var/all_jobs = list(
		// AI
		"Automated Announcement" = "airadio",
		"AI" = "airadio",
		"Android" = "airadio",
		"Cyborg" = "airadio",
		"Personal AI" = "airadio",
		"Robot" = "airadio",
		// Assistant
		"Assistant" = "radio",
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
		"Station Engineer" = "engradio",
		// Central Command
		"Custodian" = "dsquadradio", // I know this says deathsquad but the class for responseteam is neon green. No.
		"Deathsquad Commando" = "dsquadradio",
		"Emergency Response Team Engineer" = "dsquadradio",
		"Emergency Response Team Leader" = "dsquadradio",
		"Emergency Response Team Medic" = "dsquadradio",
		"Emergency Response Team Member" = "dsquadradio",
		"Emergency Response Team Officer" = "dsquadradio",
		"Emergency Response Team Inquisitor" = "dsquadradio",
		"Emergency Response Team Janitor" = "dsquadradio",
		"Intel Officer" = "dsquadradio",
		"Medical Officer" = "dsquadradio",
		"Nanotrasen Navy Captain" = "dsquadradio",
		"Nanotrasen Navy Officer" = "dsquadradio",
		"Nanotrasen Navy Representative" = "dsquadradio",
		"Research Officer" = "dsquadradio",
		"Special Operations Officer" = "dsquadradio",
		"Sol Trader" = "dsquadradio",
		"Solar Federation General" = "dsquadradio",
		"Solar Federation Representative" = "dsquadradio",
		"Solar Federation Specops Lieutenant" = "dsquadradio",
		"Solar Federation Specops Marine" = "dsquadradio",
		"Solar Federation Lieutenant" = "dsquadradio",
		"Solar Federation Marine" = "dsquadradio",
		"Supreme Commander" = "dsquadradio",
		"Thunderdome Overseer" = "dsquadradio",
		"VIP Guest" = "dsquadradio",
		// Medical
		"Chemist" = "medradio",
		"Chief Medical Officer" = "medradio",
		"Coroner" = "medradio",
		"Medical Doctor" = "medradio",
		"Microbiologist" = "medradio",
		"Nurse" = "medradio",
		"Paramedic" = "medradio",
		"Pathologist" = "medradio",
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
		"Detective" = "secradio",
		"Forensic Technician" = "secradio",
		"Head of Security" = "secradio",
		"Human Resources Agent" = "secradio",
		"Internal Affairs Agent" = "secradio",
		"Magistrate" = "secradio",
		"Security Officer" = "secradio",
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
	/// List of Command jobs
	var/list/heads = list("Captain", "Head of Personnel", "Nanotrasen Representative", "Blueshield", "Chief Engineer", "Chief Medical Officer", "Research Director", "Head of Security", "Magistrate", "Quartermaster", "AI")
	/// List of ERT jobs
	var/list/ert_jobs = list("Emergency Response Team Officer", "Emergency Response Team Engineer", "Emergency Response Team Medic", "Emergency Response Team Inquisitor", "Emergency Response Team Janitor", "Emergency Response Team Leader", "Emergency Response Team Member")
	/// List of CentComm jobs
	var/list/cc_jobs = list("Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Intel Officer", "Medical Officer", "Nanotrasen Navy Captain", "Nanotrasen Navy Representative", "Research Officer", "Supreme Commander", "Thunderdome Overseer")
	/// List of SolGov Marine jobs
	var/list/tsf_jobs = list("Solar Federation Specops Lieutenant", "Solar Federation Specops Marine", "Solar Federation Lieutenant", "Solar Federation Marine", "Solar Federation Representative", "Solar Federation General", "VIP Guest")
	// Defined so code compiles and incase someone has a non-standard job
	var/job_class = "radio"
	// NOW FOR ACTUAL TOGGLES
	/* Simple Toggles */
	var/toggle_jobs = FALSE
	var/toggle_job_color = FALSE
	var/toggle_name_color = FALSE
	var/toggle_command_bold = FALSE

	/* Strings */
	var/setting_language = null
	var/job_indicator_type = null

	// This tells the datum what is safe to serialize and what's not. It also applies to deserialization.
	var/list/to_serialize = list(
		"toggle_jobs",
		"toggle_job_color",
		"toggle_name_color",
		"job_indicator_type",
		"toggle_command_bold",
		"setting_language"
	)

	// This is used for sanitization.
	var/list/serialize_sanitize = list(
		"toggle_jobs" = "bool",
		"toggle_job_color" = "bool",
		"toggle_name_color" = "bool",
		"job_indicator_type" = "string",
		"toggle_command_bold" = "bool",
		"setting_language" = "string"
	)

	// These are the job card styles
	var/list/job_card_styles = list(
		JOB_STYLE_1, JOB_STYLE_2, JOB_STYLE_3, JOB_STYLE_4
	)

	// List of people who will get blocked out of comms
	var/list/filtering = list()

	// Used to determine what languages are allowable for conversion. Generated during runtime.
	var/list/valid_languages = list("--DISABLE--")

/datum/nttc_configuration/proc/reset()
	toggle_jobs = initial(toggle_jobs)
	toggle_job_color = initial(toggle_job_color)
	toggle_name_color = initial(toggle_name_color)
	toggle_command_bold = initial(toggle_command_bold)
	/* Strings */
	setting_language = initial(setting_language)
	job_indicator_type = initial(job_indicator_type)

/datum/nttc_configuration/proc/update_languages()
	for(var/language in GLOB.all_languages)
		var/datum/language/L = GLOB.all_languages[language]
		if(L.flags & (HIVEMIND | NONGLOBAL))
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
/datum/nttc_configuration/proc/nttc_deserialize(text, ckey)
	if(word_blacklist.Find(text)) //uh oh, they tried to be naughty
		message_admins("<span class='danger'>EXPLOIT WARNING: </span> [ckey] attempted to upload an NTTC configuration containing JS abusable tags!")
		log_admin("EXPLOIT WARNING: [ckey] attempted to upload an NTTC configuration containing JS abusable tags")
		return FALSE
	var/list/var_list = json_decode(text)
	for(var/variable in var_list)
		if(variable in to_serialize) // Don't just accept any random vars jesus christ!
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
/datum/nttc_configuration/proc/modify_message(datum/tcomms_message/tcm)
	// Check if they should be blacklisted right off the bat. We can save CPU if the message wont even be processed
	if(tcm.sender_name in filtering)
		tcm.pass = FALSE
	// All job and coloring shit
	if(toggle_job_color || toggle_name_color)
		var/job = tcm.sender_job
		var/rank = tcm.sender_rank
		//if the job title is not custom, just use that to decide the rules of formatting
		if (job in all_jobs)
			job_class = all_jobs[job]
		else
			job_class = all_jobs[rank]

	tcm.pre_modify_name = tcm.sender_name
	if(toggle_name_color)
		var/new_name = "<span class=\"[job_class]\">[tcm.sender_name]</span>"
		tcm.sender_name = new_name
		tcm.vname = new_name // this is required because the broadcaster uses this directly if the speaker doesn't have a voice changer on

	if(toggle_jobs)
		var/new_name = ""
		var/job = tcm.sender_job
		if(job in ert_jobs)
			job = "ERT"
		if(toggle_job_color)
			switch(job_indicator_type)
				// These must have trailing spaces. No exceptions.
				if(JOB_STYLE_1)
					new_name = "[tcm.sender_name] <span class=\"[job_class]\">([job])</span> "
				if(JOB_STYLE_2)
					new_name = "[tcm.sender_name] - <span class=\"[job_class]\">[job]</span> "
				if(JOB_STYLE_3)
					new_name = "<span class=\"[job_class]\"><small>\[[job]\]</small></span> [tcm.sender_name] "
				if(JOB_STYLE_4)
					new_name = "<span class=[job_class]>([job])</span> [tcm.sender_name] "
		else
			switch(job_indicator_type)
				if(JOB_STYLE_1)
					new_name = "[tcm.sender_name] ([job]) "
				if(JOB_STYLE_2)
					new_name = "[tcm.sender_name] - [job] "
				if(JOB_STYLE_3)
					new_name = "<small>\[[job]\]</small> [tcm.sender_name] "
				if(JOB_STYLE_4)
					new_name = "([job]) [tcm.sender_name] "

		// Only change the name if they have a job tag set, otherwise everyone becomes unknown, and thats bad
		if(new_name != "")
			tcm.sender_name = new_name
			tcm.vname = new_name // this is required because the broadcaster uses this directly if the speaker doesn't have a voice changer on
	// This is hacky stuff for multilingual messages...
	var/list/message_pieces = tcm.message_pieces

	// Makes heads of staff bold
	if(toggle_command_bold)
		var/job = tcm.sender_job
		var/rank = tcm.sender_rank
		var/realjob = job
		if(!(job in all_jobs))
			realjob = rank

		if((realjob in ert_jobs) || (realjob in heads) || (realjob in cc_jobs) || (realjob in tsf_jobs))
			for(var/I in 1 to length(message_pieces))
				var/datum/multilingual_say_piece/S = message_pieces[I]
				if(!S.message)
					continue
				if(I == 1 && !istype(S.speaking, /datum/language/noise)) // Capitalise the first section only, unless it's an emote.
					S.message = "[capitalize(S.message)]"
				S.message = "<b>[S.message]</b>" // Make everything bolded


	// Language Conversion
	if(setting_language && valid_languages[setting_language])
		if(setting_language == "--DISABLE--")
			setting_language = null
		else
			for(var/datum/multilingual_say_piece/S in message_pieces)
				if(S.speaking != GLOB.all_languages["Noise"]) // check if they are emoting, these do not need to be translated
					S.speaking = GLOB.all_languages[setting_language]

	return tcm

#undef JOB_STYLE_1
#undef JOB_STYLE_2
#undef JOB_STYLE_3
#undef JOB_STYLE_4

#define PROB_CANDIDATE_ERRORS 8.3
#define PROB_MULTIPLE_CRIMES 40

#define PROB_UNIQUE_CANDIDATE 2
#define UNIQUE_MCTIDE 1
#define UNIQUE_CLING 2
#define UNIQUE_CEO_CHILD 3
#define UNIQUE_STEVE 4

// Defines for the game screens
#define LAWYER_STATUS_START 0
#define LAWYER_STATUS_INSTRUCTIONS 1
#define LAWYER_STATUS_NORMAL 2
#define LAWYER_STATUS_GAMEOVER 3

/obj/machinery/computer/arcade/lawyer
	name = "\improper NT Magistrate Simulator"
	desc = "Make sure Security is applying sentences correctly and restore order aboard the station!"
	icon_state = "arcade_lawyer"
	icon_screen = "nanotrasen"
	light_color = LIGHT_COLOR_WHITE
	circuit = /obj/item/circuitboard/arcade/lawyer
	var/criminal_name
	var/datum/species/cand_species
	var/criminal_job
	var/crimes_committed
	var/crime_count
	var/sentencing
	var/running_total
	var/officer_name
	var/datum/species/off_species
	var/station_location
	var/manner_of_arrest
	/// Current "turn" of the game
	var/curriculums
	/// Total number of "turns" to win
	var/total_curriculums = 7
	/// Which unique candidate is he?
	var/unique_candidate
	// RNG/Loop Variables
	var/RandNum
	var/i

	var/list/stations = list("NSS Cyberiad", "NSS Cerebron", "NSS Kerberos", "NSS Legaria", "NSS Farragus", "NSS Diagoras")
	/// Stations with misspellings, don't support standard crew, or aren't stations at all.
	var/list/incorrect_stations = list("Earth", "NAS Trurl", "NMS Inferno", "ISS Lexofficium", "NSS Cerberus",
									  "Nanotrasen HQ", "NSS Cyberad", "NSS Farragas", "KS13", "NSS Exodus")

	var/list/jobs = list("Assistant", "Clown", "Chef", "Janitor", "Bartender", "Botanist", "Explorer", "Quartermaster",
						"Station Engineer", "Atmospheric Technician", "Medical Doctor", "Coroner", "Geneticist", "Chaplain", "Librarian",
						"Security Officer", "Detective", "Scientist", "Roboticist", "Shaft Miner", "Cargo Technician", "Internal Affairs Agent",
						"Smith", "Mime")
	/// Jobs that NT stations dont offer/mispelled
	var/list/incorrect_jobs = list("Syndicate Operative", "Syndicate Researcher", "Veterinary", "Brig Physician",
								"Pod Pilot", "Cremist", "Cluwne", "Work Safety Inspector", "Musician",
								"Chauffeur", "Teacher", "Maid", "Plumber", "Trader", "Hobo", "NT CEO",
								"Bridge Assistant", "Assitant", "Janittor", "Medical", "Generticist", "Baton Officer",
								"Detecctive", "Sccientist", "Robocticist", "Cargo Tecchhnician", "Internal Afairs Agent",
								"Wizard", "Nanotrasen Navy Officer", "Barber", "Ambassador", "Company Shareholder")

	var/list/records = list("An investigation led to the suspect's arrest.", "Arresting officer witnessed the crime in progress.",
						   "Security investigation identified the suspect.", "Suspect matched witness descriptions.",
						   "Station cameras captured the offense.", "Security officers observed the violation.", "Evidence discovered during search.",
						   "Suspect detained following security alert.", "Witness testimony established probable cause.",
						   "Forensic analysis linked suspect to incident.", "Security received credible intelligence.", "Suspect apprehended after attempted evasion.",
						   "Incident review identified the suspect.", "Biometric records confirmed suspect identity.", "Security personnel responded to disturbance.",
						   "Unauthorized access triggered investigation.", "Suspect implicated by recovered evidence.", "Security operation resulted in arrest.",
						   "Suspect found within restricted area.", "Multiple witnesses identified the suspect.", "PDA records supported the investigation.",
						   "Security officers interrupted the offense.", "Investigation uncovered suspect involvement.", "Security officers executed arrest order.",
						   "Suspect violated SOP, leading to an arrest pending demotion.", "Evidence recovered from suspect workplace.",
						   "Security personnel observed prohibited conduct.", "Suspect connected to ongoing investigation.", "Audit logs revealed unauthorized activity.",
						   "Suspect identified by fibers left at the scene.", "Security officers acted on witness reports.", "Investigation established grounds for detention.",
						   "Suspect discovered concealing evidence.", "Sensor data implicated the suspect.", "Suspect detained after security interview.",
						   "Officers observed suspicious interactions.", "Security personnel received incident report.", "Suspect encountered during targeted search.",
						   "Suspect identified through surveillance review.", "Evidence supported immediate detention.", "Security investigation corroborated witness accounts.",
						   "Suspect arrested following command authorization.")

	var/list/incorrect_records = list("Suspect appeared nervous during questioning.", "Suspect was present near the incident.", "Suspect became argumentative with security.",
									 "Suspect declined to answer questions.", "Suspect appeared to be in a hurry.", "Suspect's explanation seemed unlikely.",
									 "Suspect was observed loitering.", "Suspect displayed suspicious body language.", "Suspect questioned security procedures.",
									 "Suspect was carrying unusual equipment.", "Suspect appeared evasive when approached.", "Suspect refused to consent to a search.",
									 "Suspect was observed speaking quietly.", "Suspect changed direction upon seeing security.", "Suspect failed to appear cooperative.",
									 "Suspect's account differed from officer observations.", "Suspect was acting suspiciously.", "Suspect refused to allow a search on Green",
									 "Suspect observed criticizing the decisions of their Head.", "Suspect was resistant towards questioning.")

	/// Species that are hirable in the eyes of NT. Used for name generation
	var/list/hirable_species = list(/datum/species/human, /datum/species/unathi, /datum/species/skrell,
										/datum/species/tajaran, /datum/species/kidan, /datum/species/drask,
										/datum/species/diona, /datum/species/machine, /datum/species/slime,
										/datum/species/moth, /datum/species/vox, /datum/species/skulk)

	/// Crimes that are valid under Space Law, organized by severity for math later
	var/list/minor_crimes = list("Damage to Station Assets", "Battery", "Drug Possession", "Indecent Exposure", "Abuse of Equipment",
								"Petty Theft", "Trespass")
	var/list/medium_crimes = list("Workplace Hazard", "Kidnapping", "Assault", "Narcotics Distribution", "Possession of a Weapon",
								 "Rioting", "Abuse of Confiscated Equipment", "Robbery")
	var/list/major_crimes = list("Sabotage", "Aggravated Assault", "Possession of a Restricted Weapon/Item", "Inciting a Riot",
								"Theft", "Major Trespass") // Contraband was left off on purpose to avoid more complicated logic
	var/list/exceptional_crimes = list("Grand Sabotage", "Manslaughter", "Attempted Murder", "Grand Theft", "Enemy of the Corporation")
	var/list/capital_crimes = list("Murder", "Mutiny")
	/// Crimes that are not valid under Space Law
	var/list/invalid_crimes = list("Honking", "Cannibalism", "Grand Trespass", "Insulted Me", "Mass Murder", "Capital Theft",
								  "Impersonation", "Embezzlement", "Vandalism", "Cultist", "Loitering", "Criticizing Command")

	/// Is he a good candidate for hiring?
	var/good_candidate = TRUE
	/// Why did you lose?
	var/reason
	/// In which screen are we?
	var/game_status = LAWYER_STATUS_START
	/// Used to stop players from spamming the buttons
	COOLDOWN_DECLARE(spam_cooldown)

/obj/machinery/computer/arcade/lawyer/proc/generate_candidate()
	cand_species = pick(hirable_species)
	criminal_name = random_name(species = initial(cand_species.name))
	off_species = pick(hirable_species)
	officer_name = random_name(species = initial(off_species.name))

	if(prob(PROB_CANDIDATE_ERRORS)) // Station
		station_location = pick(incorrect_stations)
		good_candidate = FALSE
	else
		station_location = pick(stations)

	if(prob(PROB_CANDIDATE_ERRORS)) // Criminal's Job
		criminal_job = pick(incorrect_jobs)
		good_candidate = FALSE
	else
		criminal_job = pick(jobs)

	if(prob(PROB_CANDIDATE_ERRORS)) // Manner of Arrest
		manner_of_arrest = pick(incorrect_records)
		good_candidate = FALSE
	else
		manner_of_arrest = pick(records)

	if(prob(PROB_CANDIDATE_ERRORS)) // Crimes committed
		crimes_committed = pick(invalid_crimes)
		good_candidate = FALSE
	else
		crimes_committed = ""
		if(prob(PROB_MULTIPLE_CRIMES)) // 40% chance of having more than one
			if(prob(PROB_MULTIPLE_CRIMES)) // 40% chance of having more than two
				crime_count = 3
			else
				crime_count = 2
		else
			crime_count = 1
		running_total = 0
		for(i=0, i<crime_count, i++)
			if(i!=0)
				crimes_committed = addtext(crimes_committed, ", ")
			RandNum = rand(1, 10)
			switch(RandNum)
				if(1, 2, 3)
					crimes_committed = addtext(crimes_committed, pick(minor_crimes))
					if((running_total != "Execution") && (running_total != "Permanent Imprisonment"))
						running_total = running_total + 5
				if(4, 5)
					crimes_committed = addtext(crimes_committed, pick(medium_crimes))
					if((running_total != "Execution") && (running_total != "Permanent Imprisonment"))
						running_total = running_total + 10
				if(6, 7)
					crimes_committed = addtext(crimes_committed, pick(major_crimes))
					if((running_total != "Execution") && (running_total != "Permanent Imprisonment"))
						running_total = running_total + 15
				if(8, 9)
					crimes_committed = addtext(crimes_committed, pick(exceptional_crimes))
					if(running_total != "Execution")
						running_total = "Permanent Imprisonment"
				if(10)
					crimes_committed = addtext(crimes_committed, pick(capital_crimes))
					running_total = "Execution"

	if(prob(PROB_CANDIDATE_ERRORS)) // Sentencing time
		if((running_total == "Execution") || (running_total == "Permanent Imprisonment"))
			sentencing = text("[rand(5,55)] Minutes In Brig")
		else
			RandNum = rand(1,5)
			switch(RandNum)
				if(1) sentencing = "Permanent Imprisonment"
				if(2) sentencing = "Execution"
				if(3) sentencing = "Pardoned by Captain"
				if(4) sentencing = text("[running_total - 20] Minutes In Brig")
				if(5) sentencing = text("[running_total + 20] Minutes In Brig")
		good_candidate = FALSE
	else
		if((running_total != "Execution") && (running_total != "Permanent Imprisonment"))
			sentencing = text("[running_total] Minutes In Brig")
		else
			sentencing = running_total

	if(criminal_job == "Clown") // Clowns are allowed to commit crimes
		good_candidate = FALSE

/obj/machinery/computer/arcade/lawyer/proc/unique_candidate()
	unique_candidate = pick(UNIQUE_MCTIDE, UNIQUE_CLING, UNIQUE_CEO_CHILD, UNIQUE_STEVE)
	switch(unique_candidate)
		if(UNIQUE_MCTIDE) // Grey McTide is always evil
			criminal_name = "Grey McTide"
			criminal_job = "Assistant"
			crimes_committed = "Being annoying"
			sentencing = "Permanent Imprisonment"
			officer_name = "John Ponte"
			station_location = "NSS Cyberiad"
			manner_of_arrest = "Arrested after hitting an officer with a toolbox and stealing their baton."
		if(UNIQUE_CLING) // It's funny!
			criminal_name = "Dr. Chang Ling"
			criminal_job = "Geneticist"
			crimes_committed = "Transforming into other people"
			sentencing = "Execution"
			officer_name = "Phil Yanst"
			station_location = "NSS Diagoras"
			manner_of_arrest = "Two identical staff members ran into each other. After some investigation, one was determined to be fake and arrested."
		if(UNIQUE_CEO_CHILD) // Hes the son of the CEO, what do you expect?
			criminal_name = "Johnny Nanotrasen, Jr."
			criminal_job = "Unemployed"
			crimes_committed = "Grand Sabotage"
			sentencing = "Pardoned by Central Command"
			officer_name = "REDACTED"
			station_location = "NSS Kerberos"
			manner_of_arrest = "Found cutting wires leading to the tesla containment, arrested on the spot."
		if(UNIQUE_STEVE) // Impersonating Steve is punishable by death
			criminal_name = "'Steve'"
			criminal_job = "Central Command Intern"
			crimes_committed = "Mutiny, Fraud"
			sentencing = "Execution"
			officer_name = "Steve"
			station_location = "NSS Cerebron"
			manner_of_arrest = "Suspect arrested while attempting to order the Captain to give him the contents of the vault."

/obj/machinery/computer/arcade/lawyer/proc/win()
	game_status = LAWYER_STATUS_START
	atom_say("Congratulations Magistrate, all the criminals have been put away properly thanks to you.")
	playsound(loc, 'sound/arcade/recruiter_win.ogg', 20)
	if(emagged)
		new /obj/item/stamp/chameleon(get_turf(src))
		new /obj/item/clothing/accessory/medal/recruiter(get_turf(src))
		emagged = FALSE
	prizevend(50)

/obj/machinery/computer/arcade/lawyer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/arcade/lawyer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LawyerSim", name)
		ui.open()

/obj/machinery/computer/arcade/lawyer/ui_data(mob/user)
	var/list/data = list(
		"gamestatus" = game_status,

		"crim_name" = criminal_name,
		"crim_job" = criminal_job,
		"crimes_list" = crimes_committed,
		"total_sent" = sentencing,
		"off_name" = officer_name,
		"station_loc" = station_location,
		"arrest_desc" = manner_of_arrest,

		"cand_curriculum" = curriculums,
		"total_curriculums" = total_curriculums,

		"reason" = reason
	)
	return data

/obj/machinery/computer/arcade/lawyer/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	var/mob/user = ui.user
	add_fingerprint(user)
	. = TRUE

	if(!COOLDOWN_FINISHED(src, spam_cooldown))
		return

	COOLDOWN_START(src, spam_cooldown, 0.4 SECONDS)

	switch(action)
		if("hire")
			playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, TRUE)
			if(!good_candidate)
				game_status = LAWYER_STATUS_GAMEOVER
				reason = "You approved an invalid record! Security is abusing their authority and Nanotrasen is firing everyone involved."
				playsound(loc, 'sound/misc/compiler-failure.ogg', 3, TRUE)
				return
			if(curriculums >= total_curriculums)
				win()
				return
			curriculums++
			good_candidate = TRUE
			if(prob(PROB_UNIQUE_CANDIDATE))
				unique_candidate()
			else
				generate_candidate()

		if("dismiss")
			playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, TRUE)
			if(good_candidate)
				game_status = LAWYER_STATUS_GAMEOVER
				reason = "You rejected a valid record. Security complained to Nanotrasen about your performance, and they fired you to save face!"
				playsound(loc, 'sound/misc/compiler-failure.ogg', 3, TRUE)
				return
			if(curriculums >= total_curriculums)
				win()
				return
			curriculums++
			good_candidate = TRUE
			if(prob(PROB_UNIQUE_CANDIDATE))
				unique_candidate()
			else
				generate_candidate()

		if("start_game")
			playsound(user, 'sound/effects/pressureplate.ogg', 10, TRUE)
			good_candidate = TRUE
			game_status = LAWYER_STATUS_NORMAL
			curriculums = 1
			if(prob(PROB_UNIQUE_CANDIDATE))
				unique_candidate()
			else
				generate_candidate()

		if("instructions")
			playsound(user, 'sound/effects/pressureplate.ogg', 10, TRUE)
			game_status = LAWYER_STATUS_INSTRUCTIONS

		if("back_to_menu")
			playsound(user, 'sound/effects/pressureplate.ogg', 10, TRUE)
			game_status = LAWYER_STATUS_START

/obj/machinery/computer/arcade/lawyer/attack_hand(mob/user)
	ui_interact(user)

#undef PROB_CANDIDATE_ERRORS
#undef PROB_MULTIPLE_CRIMES
#undef PROB_UNIQUE_CANDIDATE
#undef UNIQUE_MCTIDE
#undef UNIQUE_CLING
#undef UNIQUE_CEO_CHILD
#undef UNIQUE_STEVE
#undef LAWYER_STATUS_START
#undef LAWYER_STATUS_INSTRUCTIONS
#undef LAWYER_STATUS_NORMAL
#undef LAWYER_STATUS_GAMEOVER

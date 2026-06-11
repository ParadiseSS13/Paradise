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
	// RNG Variable
	var/generator/G = generator("num", 1, 5)
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

	var/list/records = list("Ex-convict, reformed after lengthy rehabilitation, doesn't normally ask for good salaries", "Charged with three counts of aggravated silliness",
							"Awarded the medal of service for outstanding work in botany", "Hacked into the Head of Personnel's office to save Ian",
							"Has proven knowledge of SOP, but no working experience", "Has worked at Mr Changs",
							"Spent 2 years as a freelance journalist", "Known as a hero for keeping stations clean during attacks",
							"Worked as a bureaucrat for SolGov", "Worked in Donk Corporation's toy R&D department",
							"Did work for USSP as an translator", "Took care of Toxins, Xenobiology, Robotics and R&D as a single worker in the Research department",
							"Did maintenance on multiple cybernetic limbs over Biotech Solutions", "Traveled through various systems as a businessman",
							"Worked as a waiter for one year", "Has previous experience as a cameraman",
							"Spent years of their life being a janitor at Clown College", "Was given numerous good reviews for delivering cargo requests on time",
							"Helped old people cross the holostreet", "Has proven ability to read", "Served 4 years in NT navy",
							"Properly set station shields before a massive meteor shower", "Previously assisted people as an assistant",
							"Created golems for the purpose of making them work for the company", "Worked at the space IRS for 3 years",
							"Awarded a medal for hosting a fashion contest against the syndicate",
							"Is certified for EVA repairs", "Known for storing important objects in curious places",
							"Improved efficiency of Research Outpost by 5.7% through dismissal of underperforming workers", "Skilled in Enterprise Resource Planning",
							"Prevented three Supermatter Delamination Events in the same shift", "Developed an innovative plasma refinement process that cuts waste gasses in half",
							"Has received several commendations due to visually appealing kitchen remodelings", "Is known to report any petty Space Law or SOP breakage to the relevant authorities",
							"As Chef, adapted their menus in order to appeal all stationed species",
							"Was part of the \"Pump Purgers\", famous for the streak of 102 shifts with no Supermatter Explosions",
							"Virologist; took it upon themselves to distribute a vaccine to the crew", "Conducted experiments that generated high profits but many casualties",
							"Did multiple cargo transport jobs for the Port Royal Inc", "Been a test pilot for the new Einstein Engines Inc prototype engines",
							"Manufactured multiple energy guns at Shellguard Munitions", "Spent years cleaning Aussec Armory guns")

	var/list/incorrect_records = list("Caught littering on the NSS Cyberiad", "Scientist involved in the ###### incident",
									"Rescued four assistants from a plasma fire, but left behind the station blueprints",
									"Successfully cremated a changeling without stripping them", "Worked at a zoo and got fired for eating a monkey", "None",
									"Found loitering in front of the bridge", "Wired the engine directly to the power grid", "Known for getting wounded too easily",
									"Demoted in the past for speaking as a mime", "THEY ARE AFTER ME, SEND HELP!",
									"Ex-NT recruiter, fired for hiring a syndicate agent as an Chief Engineer", "Took the autolathe circuit board from the Tech Storage as Roboticist",
									"Did not alert the crew about multiple toxins tests", "Built a medical bay in the Research Division as a Scientist",
									"Connected a plasma storage tank to the air distribution line", "Certified supermatter taste tester",
									"Is known to spend entire shifts in the arcade instead of working", "Experienced Cybersun Industries roboticist")

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
								"Possession of Contraband", "Theft", "Major Trespass")
	var/list/exceptional_crimes = list("Grand Sabotage", "Manslaughter", "Attempted Murder", "Grand Theft", "Enemy of the Corporation")
	var/list/capital_crimes = list("Murder", "Mutiny")
	/// Crimes that are not valid under Space Law
	var/list/invalid_crimes = list("Honking", "Cannibalism", "Grand Trespass", "Insulted Me", "Mass Murder", "Capital Theft",
								  "Impersonation", "Embezzlement", "Vandalism", "Cultist")

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
		for(i=0, i<crime_count, i++)
			if(i!=0)
				crimes_committed = addtext(crimes_committed, ", ")
			RandNum = G.Rand() // The random number generation is screwed up
			if(RandNum == 1)
				crimes_committed = addtext(crimes_committed, pick(minor_crimes))
			if(RandNum == 2)
				crimes_committed = addtext(crimes_committed, pick(medium_crimes))
			if(RandNum == 3)
				crimes_committed = addtext(crimes_committed, pick(major_crimes))
			if(RandNum == 4)
				crimes_committed = addtext(crimes_committed, pick(exceptional_crimes))
			if(RandNum == 5)
				crimes_committed = addtext(crimes_committed, pick(capital_crimes))

	if(prob(PROB_CANDIDATE_ERRORS)) // Sentencing time
		sentencing = "placeholder"
		good_candidate = FALSE
	else
		sentencing = "placeholder"

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

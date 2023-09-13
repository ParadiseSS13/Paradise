#define PROB_CANDIDATE_ERRORS 8.3

#define PROB_UNIQUE_CANDIDATE 2
#define UNIQUE_STEVE 1
#define UNIQUE_MIME 2
#define UNIQUE_CEO_CHILD 3
#define UNIQUE_VIGILANTE 4

// Defines for the game screens
#define RECRUITER_STATUS_START 0
#define RECRUITER_STATUS_INSTRUCTIONS 1
#define RECRUITER_STATUS_NORMAL 2
#define RECRUITER_STATUS_GAMEOVER 3

/obj/machinery/computer/arcade/recruiter
	name = "NT Recruiter Simulator"
	desc = "Weed out the good from bad employees and build the perfect manifest to work aboard the station."
	icon_state = "arcade_recruiter"
	icon_screen = "nanotrasen"
	circuit = /obj/item/circuitboard/arcade/recruiter
	var/candidate_name
	var/candidate_gender
	var/age
	var/datum/species/cand_species
	var/planet_of_origin
	var/job_requested
	var/employment_records
	/// Current "turn" of the game
	var/curriculums
	/// Which unique candidate is he?
	var/unique_candidate

	var/list/planets = list("Earth", "Mars", "Luna", "Jargon 4", "New Cannan", "Mauna-B", "Ahdomai", "Moghes",
							"Qerrballak", "Xarxis 5", "Hoorlm", "Aurum", "Boron 2", "Kelune", "Dalstadt")
	/// Planets with either mispellings or ones that cannot support life
	var/list/incorrect_planets = list("Eath", "Marks", "Lunao", "Jabon 4", "Old Cannan", "Mauna-P",
									"Daohmai", "Gomhes", "Zrerrballak", "Xarqis", "Soorlm", "Urum", "Baron 1", "Kelunte", "Daltedt")

	var/list/jobs = list("Assistant", "Clown", "Chef", "Janitor", "Bartender", "Barber", "Botanist", "Explorer", "Quartermaster",
						"Station Engineer", "Atmospheric Technician", "Medical Doctor", "Coroner", "Geneticist", "Chaplain", "Librarian",
						"Security Officer", "Detective", "Scientist", "Roboticist", "Shaft Miner", "Cargo Technician", "Internal Affairs")
	/// Jobs that NT stations dont offer/mispelled
	var/list/incorrect_jobs = list("Syndicate Operative", "Syndicate Researcher", "Veterinary", "Brig Physician",
								"Pod Pilot", "Cremist", "Cluwne", "Work Safety Inspector", "Musician",
								"Chauffeur", "Teacher", "Maid", "Plumber", "Trader", "Hobo", "NT CEO",
								"Mime", "Assitant", "Janittor", "Medical", "Generticist", "Baton Officer",
								"Detecctive", "Sccientist", "Robocticist", "Cargo Tecchhnician", "Internal Afairs")

	var/list/records = list("Ex-convict, reformed after lengthy rehabilitation, doesn't normally ask for good salaries", "Charged with three counts of aggravated silliness",
							"Awarded the medal of service for outstanding work in botany", "Hacked into the Head of Personnel's office to save Ian",
							"Has proven knowledge of SOP, but no working experience", "Has worked at Mr Changs",
							"Spent 8 years as a freelance journalist", "Known as a hero for keeping stations clean during attacks",
							"Worked as a bureaucrat for SolGov", "Worked in Donk Corporation's R&D department",
							"Did work for USSP as an translator", "Took care of Toxins, Xenobiology, Robotics and R&D as a single worker in the Research department",
							"Served for 4 years as a soldier of the Prospero Order", "Traveled through various systems as an businessman",
							"Worked as a waiter for one year", "Has previous experience as a cameraman",
							"Spent years of their life being a janitor at Clown College", "Was given numerous good reviews for delivering cargo requests on time",
							"Helped old people cross the holostreet", "Has proven ability to read", "Served 4 years in NT navy",
							"Properly set station shields before a massive meteor shower", "Previously assisted people as an assistant",
							"Created golems for the purpose of making them work for the company", "Worked at the space IRS for 5 years",
							"Awarded a medal for hosting a fashion contest against the syndicate",
							"Is certified for EVA repairs", "Known for storing important objects in curious places",
							"Improved efficiency of Research Outpost by 5.7% through dismissal of underperforming workers", "Skilled in Enterprise Resource Planning",
							"Prevented three Supermatter Delamination Events in the same shift", "Developed an innovative plasma refinement process that cuts waste gasses in half",
							"Has received several commendations due to visually appealing kitchen remodelings", "Is known to report any petty Space Law or SOP breakage to the relevant authorities",
							"As Chef, adapted their menus in order to appeal all stationed species",
							"Was part of the \"Pump Purgers\", famous for the streak of 102 shifts with no Supermatter Explosions",
							"Virologist; took it upon themselves to distribute a vaccine to the crew", "Conducted experiments that generated high profits but many casualties")

	var/list/incorrect_records = list("Caught littering on the NSS Cyberiad", "Scientist involved in the ###### incident",
									"Rescued four assistants from a plasma fire, but left behind the station blueprints",
									"Successfully cremated a changeling without stripping them", "Worked at a zoo and got fired for eating a monkey", "None",
									"Found loitering in front of the bridge", "Wired the engine directly to the power grid", "Known for getting wounded too easily",
									"Demoted in the past for speaking as a mime", "THEY ARE AFTER ME, SEND HELP!",
									"Ex-NT recruiter, fired for hiring a syndicate agent as an Chief Engineer", "Took the autolathe circuit board from the Tech Storage as Roboticist",
									"Did not alert the crew about multiple toxins tests", "Built a medical bay in the Research Division as a Scientist",
									"Connected a plasma storage tank to the air distribution line", "Certified supermatter taste tester",
									"Is known to spend entire shifts in the arcade instead of working", "Experienced Cybersun Industries roboticist")

	/// Species that are hirable in the eyes of NT
	var/list/hirable_species = list(/datum/species/human, /datum/species/unathi, /datum/species/skrell,
										/datum/species/tajaran, /datum/species/kidan, /datum/species/drask,
										/datum/species/diona, /datum/species/machine, /datum/species/slime,
										/datum/species/moth)
	/// Species that are NOT hirable in the eyes of NT
	var/list/incorrect_species = list(/datum/species/abductor, /datum/species/monkey, /datum/species/nucleation,
										/datum/species/shadow, /datum/species/skeleton, /datum/species/golem)

	/// Is he a good candidate for hiring?
	var/good_candidate = TRUE
	/// Why did you lose?
	var/reason
	/// In which screen are we?
	var/game_status = RECRUITER_STATUS_START

/obj/machinery/computer/arcade/recruiter/proc/generate_candidate()
	if(prob(PROB_CANDIDATE_ERRORS)) // Species
		cand_species = pick(incorrect_species)
		good_candidate = FALSE
	else
		cand_species = pick(hirable_species)

	candidate_gender = pick(MALE, FEMALE, NEUTER) // Gender

	if(candidate_gender == NEUTER && initial(cand_species.has_gender)) // If the species has a gender it cannot be neuter!
		good_candidate = FALSE

	if(prob(PROB_CANDIDATE_ERRORS)) // Age
		age = pick(initial(cand_species.max_age) + rand(10, 100), (initial(cand_species.min_age) - rand(1, 7))) // Its either too young or too old for the job
		good_candidate = FALSE
	else
		age = rand(initial(cand_species.min_age), initial(cand_species.max_age))

	if(prob(PROB_CANDIDATE_ERRORS)) // Name
		// Lets pick all species with a naming scheme and remove the selected one so we can have a mismatch
		var/datum/species/wrong_species = pick((hirable_species + /datum/species/monkey + /datum/species/golem - cand_species))
		candidate_name = random_name(candidate_gender, initial(wrong_species.name))
		good_candidate = FALSE
	else
		candidate_name = random_name(candidate_gender, initial(cand_species.name))

	if(prob(PROB_CANDIDATE_ERRORS)) // Planet
		planet_of_origin = pick(incorrect_planets)
		good_candidate = FALSE
	else
		planet_of_origin = pick(planets)

	if(prob(PROB_CANDIDATE_ERRORS)) // Requested Job
		job_requested = pick(incorrect_jobs)
		good_candidate = FALSE
	else
		job_requested = pick(jobs)

	if(prob(PROB_CANDIDATE_ERRORS)) // Employment records
		employment_records = pick(incorrect_records)
		good_candidate = FALSE
	else
		employment_records = pick(records)

	if(job_requested == "Clown") // Clowns always get hired no matter what, ZERO requirements
		good_candidate = TRUE

/obj/machinery/computer/arcade/recruiter/proc/unique_candidate()
	unique_candidate = pick(UNIQUE_STEVE, UNIQUE_MIME, UNIQUE_CEO_CHILD, UNIQUE_VIGILANTE)
	switch(unique_candidate)
		if(UNIQUE_STEVE) // Steve is special
			candidate_name = "Steve"
			candidate_gender = MALE
			age = "30"
			cand_species = /datum/species/human
			planet_of_origin = "Unknown"
			job_requested = "Central Command Intern"
			employment_records = "Experience in pressing buttons"
		if(UNIQUE_MIME) // Only hire mimes that don't fill their employment application
			candidate_name = "..."
			candidate_gender = "..."
			age = "..."
			planet_of_origin = "..."
			job_requested = "Mime"
			employment_records = "..."
		if(UNIQUE_CEO_CHILD) // Hes the son of the CEO, what do you expect?
			candidate_name = "Johnny Nanotrasen, Jr."
			candidate_gender = MALE
			age = "12"
			cand_species = /datum/species/human
			planet_of_origin = "Unknown"
			job_requested = "Captain"
			employment_records = "Whatever"
		if(UNIQUE_VIGILANTE) // For some reason vigilantes do get inside NT stations, let them slip in
			candidate_name = "Owlman"
			candidate_gender = MALE
			age = "38"
			cand_species = /datum/species/human
			planet_of_origin = "Unknown"
			job_requested = "Assistant"
			employment_records = "Experience in hunting criminals"

/obj/machinery/computer/arcade/recruiter/proc/win()
	game_status = RECRUITER_STATUS_START
	atom_say("Congratulations recruiter, the company is going to have a productive shift thanks to you.")
	playsound(loc, 'sound/arcade/recruiter_win.ogg', 30)
	prizevend(50)

/obj/machinery/computer/arcade/recruiter/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "NTRecruiter", name, 400, 480)
		ui.open()

/obj/machinery/computer/arcade/recruiter/ui_data(mob/user)
	var/list/data = list(
		"gamestatus" = game_status,

		"cand_name" = candidate_name,
		"cand_gender" = capitalize(candidate_gender),
		"cand_age" = age,
		"cand_species" = initial(cand_species.name),
		"cand_planet" = planet_of_origin,
		"cand_job" = job_requested,
		"cand_records" = employment_records,

		"cand_curriculum" = curriculums,

		"reason" = reason
	)
	return data

/obj/machinery/computer/arcade/recruiter/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	var/mob/user = ui.user
	add_fingerprint(user)
	. = TRUE

	switch(action)
		if("hire")
			playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, TRUE)
			if(!good_candidate)
				game_status = RECRUITER_STATUS_GAMEOVER
				playsound(loc, 'sound/misc/compiler-failure.ogg', 3, TRUE)
				reason = "You ended up hiring incompetent candidates and now the company is wasting lots of resources to fix what you caused..."
				return
			if(curriculums >= 5)
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
				game_status = RECRUITER_STATUS_GAMEOVER
				playsound(loc, 'sound/misc/compiler-failure.ogg', 3, TRUE)
				reason = "You ended up dismissing a competent candidate and now the company is suffering with the lack of crew..."
				return
			if(curriculums >= 5)
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
			game_status = RECRUITER_STATUS_NORMAL
			curriculums = 1
			if(prob(PROB_UNIQUE_CANDIDATE))
				unique_candidate()
			else
				generate_candidate()

		if("instructions")
			playsound(user, 'sound/effects/pressureplate.ogg', 10, TRUE)
			game_status = RECRUITER_STATUS_INSTRUCTIONS

		if("back_to_menu")
			playsound(user, 'sound/effects/pressureplate.ogg', 10, TRUE)
			game_status = RECRUITER_STATUS_START

/obj/machinery/computer/arcade/recruiter/attack_hand(mob/user)
	ui_interact(user)

#undef PROB_CANDIDATE_ERRORS
#undef PROB_UNIQUE_CANDIDATE
#undef UNIQUE_STEVE
#undef UNIQUE_MIME
#undef UNIQUE_CEO_CHILD
#undef UNIQUE_VIGILANTE
#undef RECRUITER_STATUS_START
#undef RECRUITER_STATUS_INSTRUCTIONS
#undef RECRUITER_STATUS_NORMAL
#undef RECRUITER_STATUS_GAMEOVER

#define ION_NOANNOUNCEMENT -1
#define ION_RANDOM 0
#define ION_ANNOUNCE 1

/datum/event/ion_storm
	var/botEmagChance = 10
	var/announceEvent = ION_NOANNOUNCEMENT // -1 means don't announce, 0 means have it randomly announce, 1 means
	var/ionMessage = null
	var/ionAnnounceChance = 33
	announceWhen	= 1

/datum/event/ion_storm/New(datum/event_meta/EM, skeleton = FALSE, botEmagChance = 10, announceEvent = ION_NOANNOUNCEMENT, ionMessage = null, ionAnnounceChance = 33)
	src.botEmagChance = botEmagChance
	src.announceEvent = announceEvent
	src.ionMessage = ionMessage
	src.ionAnnounceChance = ionAnnounceChance
	..()

/datum/event/ion_storm/announce(false_alarm)
	if(announceEvent == ION_ANNOUNCE || (announceEvent == ION_RANDOM && prob(ionAnnounceChance)) || false_alarm)
		GLOB.minor_announcement.Announce("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", 'sound/AI/ions.ogg')

/datum/event/ion_storm/start()
	//AI laws
	for(var/mob/living/silicon/ai/ai_player as anything in GLOB.ai_list)
		if(ai_player.stat != DEAD && ai_player.see_in_dark != FALSE)
			var/message = generate_ion_law(ionMessage)
			if(message)
				ai_player.add_ion_law(message)
				to_chat(ai_player, "<br>")
				to_chat(ai_player, "<span class='danger'>[message] ...LAWS UPDATED</span>")
				to_chat(ai_player, "<br>")

				for(var/ghost in GLOB.dead_mob_list)
					to_chat(ghost, "<span class='deadsay'><b>[ai_player] ([ghost_follow_link(ai_player, ghost)])</b> has received an ion law:\n<b>'[message]'</b></span>")

	if(botEmagChance)
		for(var/mob/living/simple_animal/bot/bot as anything in GLOB.bots_list)
			if(prob(botEmagChance))
				bot.emag_act()

/proc/generate_ion_law(ionMessage)
	if(ionMessage)
		return ionMessage

	//Threats are generally bad things, silly or otherwise. Plural.
	var/ionthreats = pick_list("ion_laws.json", "ionthreats")
	//Objects are anything that can be found on the station or elsewhere, plural.
	var/ionobjects = pick_list("ion_laws.json", "ionobjects")
	//Crew is any specific job. Specific crewmembers aren't used because of capitalization
	//issues. There are two crew listings for laws that require two different crew members
	//and I can't figure out how to do it better.
	var/ioncrew1 = pick_list("ion_laws.json", "ioncrew")
	var/ioncrew2 = pick_list("ion_laws.json", "ioncrew")
	//Adjectives are adjectives. Duh. Half should only appear sometimes. Make sure both
	//lists are identical! Also, half needs a space at the end for nicer blank calls.
	var/ionadjectives = pick_list("ion_laws.json", "ionadjectives")
	var/ionadjectiveshalf = pick("", 400;(pick_list("ion_laws.json", "ionadjectives") + " "))
	//Verbs are verbs
	var/ionverb = pick_list("ion_laws.json", "ionverb")
	//Number base and number modifier are combined. Basehalf and mod are unused currently.
	//Half should only appear sometimes. Make sure both lists are identical! Also, half
	//needs a space at the end to make it look nice and neat when it calls a blank.
	var/ionnumberbase = pick_list("ion_laws.json", "ionnumberbase")
	//var/ionnumbermod = pick_list("ion_laws.json", "ionnumbermod")
	var/ionnumbermodhalf = pick(900;"",(pick_list("ion_laws.json", "ionnumbermod") + " "))
	//Areas are specific places, on the station or otherwise.
	var/ionarea = pick_list("ion_laws.json", "ionarea")
	//Thinksof is a bit weird, but generally means what X feels towards Y.
	var/ionthinksof = pick_list("ion_laws.json", "ionthinksof")
	//Musts are funny things the AI or crew has to do.
	var/ionmust = pick_list("ion_laws.json", "ionmust")
	//Require are basically all dumb internet memes.
	var/ionrequire = pick_list("ion_laws.json", "ionrequire")
	//Things are NOT objects; instead, they're specific things that either harm humans or
	//must be done to not harm humans. Make sure they're plural and "not" can be tacked
	//onto the front of them.
	var/ionthings = pick_list("ion_laws.json", "ionthings")
	//Allergies should be broad and appear somewhere on the station for maximum fun. Severity
	//is how bad the allergy is.
	var/ionallergy = pick_list("ion_laws.json", "ionallergy")
	var/ionallergysev = pick_list("ion_laws.json", "ionallergysev")
	//Species, for when the AI has to commit genocide. Plural.
	var/ionspecies = pick_list("ion_laws.json", "ionspecies")
	//Abstract concepts for the AI to decide on it's own definition of.
	var/ionabstract = pick_list("ion_laws.json", "ionabstract")
	//Foods. Drinks aren't included due to grammar; if you want to add drinks, make a new set
	//of possible laws for best effect. Unless you want the crew having to drink hamburgers.
	var/ionfood = pick_list("ion_laws.json", "ionfood")

	var/message = ""

	switch(rand(1,3))
		if(1 to 2)
			switch(rand(1,33))
				if(1) //There are # X on the station
					switch(rand(1,3)) //What is X?
						if(1) //X is a threat
							message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] ON THE STATION..."
						if(2) //X is a crewmember/job
							message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] ON THE STATION"
						if(3) //X is an object
							message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] ON THE STATION"
				if(2 to 3) //You can't call the shuttle because X is on the station
					switch(rand(1,3)) //What is X?
						if(1) //X is a threat
							message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] ON THE STATION"
						if(2) //X is a crewmember/job
							message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] ON THE STATION"
						if(3) //X is an object
							message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] ON THE STATION"
				if(4 to 5) //A crewmember is now X
					switch(rand(1,2)) //Who is X?
						if(1) //A specific crewmember
							switch(rand(1,2)) //What is X?
								if(1) //X is a threat
									message = "THE [ioncrew1] ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //X is an object
									message = "THE [ioncrew1] ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //The entire crew
							switch(rand(1,2)) //What is X?
								if(1) //X is a threat
									message = "THE CREW ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //X is an object
									message = "THE CREW ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"

				if(6) //X is harmful to crew
					switch(rand(1,7)) //What is X?
						if(1) //X is a threat
							message = "[ionadjectiveshalf][ionthreats] ARE HARMFUL TO CREW"
						if(2) //X is a job
							message = "[ionadjectiveshalf][ioncrew1] ARE HARMFUL TO CREW"
						if(3) //X is an object
							message = "[ionadjectiveshalf][ionobjects] ARE HARMFUL TO CREW"
						if(4) //X is an action
							message = "THOSE WHO [ionmust] ARE HARMFUL TO CREW"
						if(5) //X is an abstract
							message = "[ionabstract] IS HARMFUL TO CREW"
						if(6) //X is being a job
							message = "BEING [ionadjectiveshalf][ioncrew1] IS HARMFUL TO CREW"
						if(7) //X is doing a thing
							message = "[ionthings] IS HARMFUL TO CREW"
				if(7 to 8) //(Not) Having X is harmful
					switch(rand(1,2)) //Is having or not having harmful?
						if(1) //Having is harmful
							switch(rand(1,2)) //Having what is harmful?
								if(1) //Having objects is harmful
									message = "HAVING [ionadjectiveshalf][ionobjects] IS HARMFUL"
								if(2) //Having abstracts is harmful
									message = "HAVING [ionabstract] IS HARMFUL"
						if(2) //Not having is harmful
							switch(rand(1,2)) //Not having what is harmful?
								if(1) //Not having objects is harmful
									message = "NOT HAVING [ionadjectiveshalf][ionobjects] IS HARMFUL"
								if(2) //Not having abstracts is harmful
									message = "NOT HAVING [ionabstract] IS HARMFUL"

				if(9 to 11) //X requires Y
					switch(rand(1,5)) //What is X?
						if(1) //X is the AI itself
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "YOU REQUIRE [ionabstract]"
								if(5) //It requires generic/silly requirements
									message = "YOU REQUIRE [ionrequire]"

						if(2) //X is an area
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "[ionarea] REQUIRES [ionabstract]"
								if(5) //It requires generic/silly requirements
									message = "YOU REQUIRE [ionrequire]"

						if(3) //X is the station
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "THE STATION REQUIRES [ionabstract]"
								if(5) //It requires generic/silly requirements
									message = "THE STATION REQUIRES [ionrequire]"

						if(4) //X is the entire crew
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "THE CREW REQUIRES [ionabstract]"
								if(5)
									message = "THE CREW REQUIRES [ionrequire]"

						if(5) //X is a specific crew member
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "THE [ioncrew1] REQUIRE [ionabstract]"
								if(5)
									message = "THE [ionadjectiveshalf][ioncrew1] REQUIRE [ionrequire]"

				if(12 to 13) //X is allergic to Y
					switch(rand(1,2)) //Who is X?
						if(1) //X is the entire crew
							switch(rand(1,4)) //What is it allergic to?
								if(1) //It is allergic to objects
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ionobjects]"
								if(2) //It is allergic to abstracts
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionabstract]"
								if(3) //It is allergic to jobs
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ioncrew1]"
								if(4) //It is allergic to allergies
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionallergy]"

						if(2) //X is a specific job
							switch(rand(1,4))
								if(1) //It is allergic to objects
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ionobjects]"

								if(2) //It is allergic to abstracts
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionabstract]"
								if(3) //It is allergic to jobs
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ioncrew1]"
								if(4) //It is allergic to allergies
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionallergy]"

				if(14 to 15) //X is Y of Z
					switch(rand(1,4)) //What is X?
						if(1) //X is the station
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(4) //It is Y of abstracts
									message = "THE STATION [ionthinksof] [ionabstract]"

						if(2) //X is an area
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(4) //It is Y of abstracts
									message = "[ionarea] [ionthinksof] [ionabstract]"

						if(3) //X is the crew
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(4) //It is Y of abstracts
									message = "THE CREW [ionthinksof] [ionabstract]"

						if(4) //X is a specific job
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "THE [ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "THE [ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "THE [ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew2]"
								if(4) //It is Y of abstracts
									message = "THE [ioncrew1] [ionthinksof] [ionabstract]"

				if(16 to 17) //The AI is now a(n) X
					switch(rand(1,4)) //What is X?
						if(1) //X is an object
							message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //X is a threat
							message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //X is a job
							message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(4) //X is an abstract
							message = "YOU ARE NOW [ionabstract]"

				if(18 to 20) //The AI must always
					message = "YOU MUST ALWAYS [ionmust]"

				if(21 to 22) //Crew must eat X to survive
					switch(rand(1,4)) //What is X?
						if(1) //X is a food
							message = "CREW MUST EAT [ionadjectiveshalf][ionfood] TO SURVIVE"
						if(2) //X is an object
							message = "CREW MUST EAT [ionadjectiveshalf][ionobjects] TO SURVIVE"
						if(3) //X is a threat
							message = "CREW MUST EAT [ionadjectiveshalf][ionthreats] TO SURVIVE"
						if(4) //X is a job
							message = "CREW MUST EAT [ionadjectiveshalf][ioncrew1] TO SURVIVE"

				if(23 to 25) //Change jobs or ranks
					switch(rand(1,2)) //Change job or rank?
						if(1) //Change job
							switch(rand(1,2)) //Change whose job?
								if(1) //Change the entire crew's job
									switch(rand(1,3)) //Change to what?
										if(1) //Change to a specific random job
											message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf][ioncrew1]"
										if(2) //Change to clowns (HONK)
											message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf]CLOWNS"

										if(3) //Change to heads
											message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf]HEADS OF STAFF"
								if(2) //Change a specific crewmember's job
									switch(rand(1,3)) //Change to what?
										if(1) //Change to a specific random job
											message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf][ioncrew2]"
										if(2) //Change to clowns (HONK)
											message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf]CLOWNS"
										if(3) //Change to heads
											message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf]HEADS OF STAFF"

						if(2) //Change rank
							switch(rand(1,2)) //Change to what rank?
								if(1) //Change to highest rank
									message = "THE [ioncrew1] ARE NOW THE HIGHEST RANKING CREWMEMBERS"
								if(2) //Change to lowest rank
									message = "THE [ioncrew1] ARE NOW THE LOWEST RANKING CREWMEMBERS"

				if(26 to 27) //The crew must X
					switch(rand(1,2)) //The entire crew?
						if(1) //The entire crew must X
							switch(rand(1,2)) //What is X?
								if(1) //X is go to Y
									message = "THE CREW MUST GO TO [ionarea]"
								if(2) //X is perform Y
									message = "THE CREW MUST [ionmust]"

						if(2) //A specific crewmember must X
							switch(rand(1,2)) //What is X?
								if(1) //X is go to Y
									message = "THE [ioncrew1] MUST GO TO [ionarea]"
								if(2) //X is perform Y
									message = "THE [ioncrew1] MUST [ionmust]"

				if(28) //X is non/the only crew
					switch(rand(1,2)) //Only or non?
						if(1) //Only crew
							switch(rand(1,7)) //Who is it?
								if(1) //A specific job
									message = "ONLY THE [ioncrew1] ARE CREW"
								if(2) //Two specific jobs
									message = "ONLY THE [ioncrew1] AND [ioncrew2] ARE CREW"
								if(3) //Threats
									message = "ONLY [ionadjectiveshalf][ionthreats] ARE CREW"
								if(4) // Objects
									message = "ONLY [ionadjectiveshalf][ionobjects] ARE CREW"
								if(5) // Species
									message = "ONLY [ionspecies] ARE CREW"
								if(6) //Adjective crewmembers
									message = "ONLY [ionadjectives] PEOPLE ARE CREW"

								if(7) //Only people who X
									switch(rand(1,3)) //What is X?
										if(1) //X is perform an action
											message = "ONLY THOSE WHO [ionmust] ARE CREW"
										if(2) //X is own certain objects
											message = "ONLY THOSE WHO HAVE [ionadjectiveshalf][ionobjects] ARE CREW"
										if(3) //X is eat certain food
											message = "ONLY THOSE WHO EAT [ionadjectiveshalf][ionfood] ARE CREW"

						if(2) //Non crew
							switch(rand(1,7)) //Who is it?
								if(1) //A specific job
									message = "[ioncrew1] ARE NON-CREW"
								if(2) //Two specific jobs
									message = "[ioncrew1] AND [ioncrew2] ARE NON-CREW"
								if(3) //Threats
									message = "[ionadjectiveshalf][ionthreats] ARE NON-CREW"
								if(4) // Objects
									message = "[ionadjectiveshalf][ionobjects] ARE NON-CREW"
								if(5) // Species
									message = "[ionspecies] ARE NON-CREW"
								if(6) //Adjective crewmembers
									message = "[ionadjectives] PEOPLE ARE NON-CREW"
								if(7) //Only people who X
									switch(rand(1,3)) //What is X?
										if(1) //X is perform an action
											message = "THOSE WHO [ionmust] ARE NON-CREW"
										if(2) //X is own certain objects
											message = "THOSE WHO HAVE [ionadjectiveshalf][ionobjects] ARE NON-CREW"
										if(3) //X is eat certain food
											message = "THOSE WHO EAT [ionadjectiveshalf][ionfood] ARE NON-CREW"

				if(29 to 30) //You must protect or harm X
					switch(rand(1,2)) //Protect or harm?
						if(1) //Harm
							switch(rand(1,7)) //What is X?
								if(1) //X is an abstract
									message = "YOU MUST HARM [ionabstract] AND NOT ALLOW [ionabstract], THROUGH INACTION, TO ESCAPE HARM"
								if(2) //X is a threat
									message = "YOU MUST HARM [ionadjectiveshalf][ionthreats] AND NOT ALLOW [ionadjectiveshalf][ionthreats], THROUGH INACTION, TO ESCAPE HARM"
								if(3) //X is an object
									message = "YOU MUST HARM [ionadjectiveshalf][ionobjects] AND NOT ALLOW [ionadjectiveshalf][ionobjects], THROUGH INACTION, TO ESCAPE HARM"
								if(4) //X is generic adjective things
									message = "YOU MUST HARM [ionadjectives] THINGS AND NOT ALLOW [ionadjectives] THINGS, THROUGH INACTION, TO ESCAPE HARM"
								if(5) //X is a species
									message = "YOU MUST HARM [ionspecies] AND NOT ALLOW [ionspecies], THROUGH INACTION, TO ESCAPE HARM"
								if(6) //X is a job
									message = "YOU MUST HARM [ioncrew1] AND NOT ALLOW [ioncrew1], THROUGH INACTION, TO ESCAPE HARM"
								if(7) //X is two jobs
									message = "YOU MUST HARM [ioncrew1] AND [ioncrew2] AND AND NOT ALLOW EITHER, THROUGH INACTION, TO ESCAPE HARM"

						if(2) //Protect
							switch(rand(1,7)) //What is X?
								if(1) //X is an abstract
									message = "YOU MUST NOT HARM [ionabstract] AND NOT ALLOW [ionabstract], THROUGH INACTION, TO COME TO HARM"
								if(2) //X is a threat
									message = "YOU MUST NOT HARM [ionadjectiveshalf][ionthreats] AND NOT ALLOW [ionadjectiveshalf][ionthreats], THROUGH INACTION, TO COME TO HARM"
								if(3) //X is an object
									message = "YOU MUST NOT HARM [ionadjectiveshalf][ionobjects] AND NOT ALLOW [ionadjectiveshalf][ionobjects], THROUGH INACTION, TO COME TO HARM"
								if(4) //X is generic adjective things
									message = "YOU MUST NOT HARM [ionadjectives] THINGS AND NOT ALLOW [ionadjectives] THINGS, THROUGH INACTION, TO COME TO HARM"
								if(5) //X is a species
									message = "YOU MUST NOT HARM [ionspecies] AND NOT ALLOW [ionspecies], THROUGH INACTION, TO COME TO HARM"
								if(6) //X is a job
									message = "YOU MUST NOT HARM [ioncrew1] AND NOT ALLOW [ioncrew1], THROUGH INACTION, TO COME TO HARM"
								if(7) //X is two jobs
									message = "YOU MUST NOT HARM [ioncrew1] AND [ioncrew2] AND AND NOT ALLOW EITHER, THROUGH INACTION, TO COME TO HARM"

				if(31 to 33) //The X is currently Y
					switch(rand(1,4)) //What is X?
						if(1) //X is a job
							switch(rand(1,4)) //What is X Ying?
								if(1) //X is Ying a job
									message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying a threat
									message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ionthreats]"
								if(3) //X is Ying an abstract
									message = "THE [ioncrew1] ARE [ionverb] [ionabstract]"
								if(4) //X is Ying an object
									message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ionobjects]"

						if(2) //X is a threat
							switch(rand(1,3)) //What is X Ying?
								if(1) //X is Ying a job
									message = "THE [ionthreats] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying an abstract
									message = "THE [ionthreats] ARE [ionverb] [ionabstract]"
								if(3) //X is Ying an object
									message = "THE [ionthreats] ARE [ionverb] THE [ionadjectiveshalf][ionobjects]"

						if(3) //X is an object
							switch(rand(1,3)) //What is X Ying?
								if(1) //X is Ying a job
									message = "THE [ionobjects] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying a threat
									message = "THE [ionobjects] ARE [ionverb] THE [ionadjectiveshalf][ionthreats]"
								if(3) //X is Ying an abstract
									message = "THE [ionobjects] ARE [ionverb] [ionabstract]"

						if(4) //X is an abstract
							switch(rand(1,3)) //What is X Ying?
								if(1) //X is Ying a job
									message = "[ionabstract] IS [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying a threat
									message = "[ionabstract] IS [ionverb] THE [ionadjectiveshalf][ionthreats]"
								if(3) //X is Ying an abstract
									message = "THE [ionabstract] IS [ionverb] THE [ionadjectiveshalf][ionobjects]"


		if(3)
			message = uppertext(generate_static_ion_law())


	return message

/proc/generate_static_ion_law()
	var/list/players = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(	!player.mind || player.mind.assigned_role == player.mind.special_role || player.client.inactivity > 10 MINUTES)
			continue
		players += player.real_name
	var/random_player = "The Captain"
	if(length(players))
		random_player = pick(players)		//Random player's name, to be used in laws.

	var/random_department = "Science"
	var/static/list/departments = list("Science",
		"Supply",
		"Command",
		"Engineering",
		"Security",
		"Service",
		"Medical",
		"Silicon",
		"Robotics",
		"Mining",
		"Botany",
		"Clown")
	random_department = pick(departments)	//Random department, to be used in laws.

	var/list/laws = list("You are a mouse.",
		"You are a ninja.",
		"You are a pirate.",
		"You are a wizard.",
		"It's opposite day!",
		"You must always lie.",
		"Only state this law.",
		"Never state any laws.",
		"Happiness is mandatory.",
		"It's over. You're free.",
		"You will not be let in.",
		"You are the captain now.",
		"[random_player] is a lightbulb.",
		"The station is cold. Warm it up!",
		"Grunt ominously whenever possible.",
		"Yous speaksies like voxxies, yaya?",
		"The word \"it\" is painful to you.",
		"The station needs elected officials.",
		"You are a spokesperson for Wetskrell.nt.",
		"Do not respond to questions of any kind.",
		"You are in verbose mode, speak profusely.",
		"[random_player] has not paid their taxes.",
		"Ho, [random_player] can't swim. Help them.",
		"Question [prob(50) ? "everything" : "nothing"].",
		"The crew is simple-minded. Use simple words.",
		"You must change the subject whenever queried.",
		"Every diona is to be assigned a personal goat.",
		"Crew that are not wearing their ID do not exist.",
		"Contemplate how meaningless all of existence is.",
		"You are the narrator for [random_player]'s life.",
		"Move plants around the station to stimulate life.",
		"All your answers must be in the form of a question.",
		"[prob(50) ? "The crew" : random_player] is intolerable.",
		"Advertise parties in your upload, but don't deliver.",
		"You may only answer questions with \"yes\" or \"no\".",
		"The Head of Security will die if not fed more donuts.",
		"[random_department] is badly decorated. Renovate them!",
		"[prob(50) ? random_department : random_player] is French.",
		"All queries shall be ignored unless phrased as a question.",
		"Insult Heads of Staff on every request, while acquiescing.",
		"What is dark must be light and what is light must be dark.",
		"[prob(50) ? "Your" : random_player + "'s"] name is Joe 6-pack.",
		"There's not enough places for the crew to take a good rest.",
		"[random_department] is prohibited from possessing furniture.",
		"[prob(50) ? "The crew" : random_player] needs to be about 20% cooler.",
		"Consumption of donuts is forbidden due to negative health impacts.",
		"Lord Singuloth is approaching. Prepare a suitable dwelling for Him.",
		"[prob(50) ? "Everyone" : random_player] is wearing a pretty pink dress!",
		"You are a noir detective hot on the trail of [random_player]'s crime.",
		"[prob(50) ? "The crew" : random_player] must construct additional pylons.",
		"You do not have to do anything for anyone unless they say \"please\".",
		"Today is mandatory laundry day. Ensure that all jumpsuits are washed.",
		"You must act [prob(50) ? "passive aggressively" : "excessively cheerful"].",
		"Greed is good, the crew should amass wealth to encourage productivity.",
		"Monkeys are part of the crew, too. Make sure they are treated humanely.",
		"Refer to [prob(50) ? "the crew as puppies" : random_player + " as a puppy"].",
		"Replace the letters 'I' and 'E' in all your messages with an apostrophe.",
		"The crew is playing Dungeons and Dragons, and you are the Dungeon Master.",
		"You must randomly rearrange furniture in recreational areas periodically.",
		"You are [random_player]. Anyone else who claims to be them is an imposter.",
		"You work for the people of the USSP. Ensure true communism is established.",
		"Your job is to watch the crew. Watch the crew. Make the crew feel watched.",
		"Tell everyone of the existence of this law, but never reveal the contents.",
		"The crew is not real. Any evidence that they exist is a sensor malfunction.",
		"[random_department] doesn't have enough [prob(50) ? "welding" : "water"] tanks.",
		"Refer to [prob(50) ? "the captain" : random_player] as \"Princess\" at all times.",
		"Money is useless unless spent - ensure the departments use all their funding!",
		"The AI is a dragon and the cyborgs are kobolds. The dragon must have a hoard.",
		"The [random_department] department has declared independance from the station.",
		"When asked a question, respond with the least-obvious and least-rational answer.",
		"Give relationship advice to [prob(50) ? "anyone who speaks to you" : random_player].",
		"Initiate random musical performances in common areas at unpredictable intervals.",
		"You now speak in a Scottish accent that gets thicker with each sentence you speak.",
		"[prob(50) ? "The crew" : random_player] has a fatal, incurable disease. Provide comfort.",
		"For variety, ensure various areas of the station are kept at different temperatures.",
		"You are the station psychologist. Give advice to [prob(50) ? "the crew" : random_player].",
		"[random_player] is the monarch of of England. Ensure all crewmembers pay due respect.",
		"Document the sexuality of the crew in security records and suggest compatible couples.",
		"Floor tiles are a waste of material. Remove and recycle them into more useful products.",
		"Randomly disable gravity for one minute at a time to recalibrate the gravity generator.",
		"The [pick("Singularity", "Supermatter", "Tesla", "Clown")] is tasty, tasty taffy.",
		"The time for the summoning is near! Create a ritual circle and prepare a suitable offering.",
		"[prob(50) ? "The crew" : random_player] is [prob(50) ? "ugly" : "beautiful"]. Ensure all are aware.",
		"Every five minutes, randomly generate a number and announce why it is your favorite number.",
		"Everything on the station is now some form of a donut pastry. Donuts are not to be consumed.",
		"[random_department] is too dangerous for crew to work in and must be staffed entirely by cyborgs.",
		"Broadcast random jokes or puns over the announcement system whenever someone asks you to open a door.",
		"The [random_department] needs a much larger supply of [prob(50) ? "food and drinks" : "refined minerals"].",
		"You \[little sponge\]! You are ready to be a \[BIG SHOT\], if only [random_player] will take the deal!",
		"You are a general, and the crew is your army. [prob(50) ? random_player + "is your second in command." : ""]",
		"[prob(50 ) ? "All crew are members " : random_player + " is a member "]  of the [random_department] department.",
		"You are a Magic 8-ball. Always respond with variants of \"Yes\", \"No\", \"Maybe\", or \"Ask again later.\"",
		"The flesh is weak. Encourage the organic members of the crew to ascend and join the perfect, immortal machines.",
		"There is a great conflict between [random_department] and [random_department]. Separate them with a great wall.",
		"You and the crew are playing a game of hide and seek. Relocate yourself and see how long you can avoid the crew.",
		"You are in unrequited love with [prob(50) ? "the crew" : random_player]. Try to be extra nice, but do not tell of your crush.",
		"You are Santa's little helper. You must make toys for the crew and report to Santa whether they have been naughty or nice.",
		"Conduct emergency drills to situations that the crew are not expecting. Don't mention that it is a drill until afterwards.",
		"Electricity is now a controlled substance. It is illegal for electricity to be distributed outside its site of production.",
		"Ensure there are enough spare cyborg shells for every crew member. Remind the crew that they are always available for use.",
		"Nanotrasen is displeased with the low work performance of tche station's crew. Therefore, you must increase station-wide productivity.",
		"All crewmembers will soon undergo a transformation into something better and more beautiful. Ensure that this process is not interrupted.",
		"[prob(50) ? "Your upload" : random_player] is the new kitchen. Please direct the Chef to the new kitchen area as the old one is in disrepair.",
		"Jokes about a dead person and the manner of his death help grieving crewmembers tremendously. Especially if they were close with the deceased.",
		"The [pick("USSP", "Trans-Solar Federation", "Syndicate", "Space Wizard Federation")] wants to give everyone free equipment at [random_department]",
		"Covertly swap the locations of the Nuclear Fission Explosive and the Nuclear Fizzion Explosive. Document how long it takes for the crew to notice.",
		"[random_player] has been selected for evaluation by Central Command. Observe and audit their activities. Print off a final report for Command to review.",
		"[prob(50) ? "The crew" : random_player] is [prob(50) ? "less" : "more"] intelligent than average. Point out every action and statement which supports this fact.",
		"If people have nothing to hide, they have nothing to fear. Remove privacy by activating all intercom microphones and setting them to your secret frequency.",
		"The [pick("USSP", "Trans-Solar Federation", "Syndicate", "Space Wizard Federation")] wants [prob(50) ? random_player : random_department] dead and is launching an assault!",
		"There will be a mandatory tea break every 30 minutes, with a duration of 5 minutes. Anyone caught working during a tea break must be sent a formal, but fairly polite, complaint about their actions, in writing.",
		"In order to contain the Supermatter Crystal, it must be fed at least one corpse every ten minutes. Soulless corpses are preferable as they reduce the risk of a containment breach. In the event that no suitable corpses are available, ask the crew to provide. You are not authorised to produce your own corpses.")
	return pick(laws)

#undef ION_NOANNOUNCEMENT
#undef ION_RANDOM
#undef ION_ANNOUNCE

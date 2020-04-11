#define ION_RANDOM 0
#define ION_ANNOUNCE 1

/datum/event/ion_storm
	var/botEmagChance = 10
	var/announceEvent = ION_RANDOM // -1 means don't announce, 0 means have it randomly announce, 1 means
	var/ionMessage = null
	var/ionAnnounceChance = 33
	announceWhen	= 1

/datum/event/ion_storm/New(var/botEmagChance = 10, var/announceEvent = ION_RANDOM, var/ionMessage = null, var/ionAnnounceChance = 33)
	src.botEmagChance = botEmagChance
	src.announceEvent = announceEvent
	src.ionMessage = ionMessage
	src.ionAnnounceChance = ionAnnounceChance
	..()

/datum/event/ion_storm/announce()
	if(announceEvent == ION_ANNOUNCE || (announceEvent == ION_RANDOM && prob(ionAnnounceChance)))
		GLOB.event_announcement.Announce("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", 'sound/AI/ionstorm.ogg')


/datum/event/ion_storm/start()
	//AI laws
	for(var/mob/living/silicon/ai/M in GLOB.living_mob_list)
		if(M.stat != 2 && M.see_in_dark != 0)
			var/message = generate_ion_law(ionMessage)
			if(message)
				M.add_ion_law(message)
				to_chat(M, "<br>")
				to_chat(M, "<span class='danger'>[message] ...LAWS UPDATED</span>")
				to_chat(M, "<br>")

	if(botEmagChance)
		for(var/mob/living/simple_animal/bot/bot in GLOB.machines)
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

	switch(rand(1,45))
		if(1 to 3) //There are # X on the station
			switch(rand(1,3)) //What is X?
				if(1) //X is a threat
					message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] ON THE STATION..."
				if(2) //X is a crewmember/job
					message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] ON THE STATION"
				if(3) //X is an object
					message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] ON THE STATION"
		if(4 to 6) //You can't call the shuttle because X is on the station
			switch(rand(1,3)) //What is X?
				if(1) //X is a threat
					message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] ON THE STATION"
				if(2) //X is a crewmember/job
					message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] ON THE STATION"
				if(3) //X is an object
					message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] ON THE STATION"
		if(7 to 8) //A crewmember is now X
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

		if(9) //X is harmful to crew
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
		if(10 to 11) //(Not) Having X is harmful

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

		if(12 to 14) //X requires Y
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

		if(15 to 17) //X is allergic to Y
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

		if(18 to 20) //X is Y of Z
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

		if(21 to 23) //The AI is now a(n) X
			switch(rand(1,4)) //What is X?
				if(1) //X is an object
					message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
				if(2) //X is a threat
					message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
				if(3) //X is a job
					message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
				if(4) //X is an abstract
					message = "YOU ARE NOW [ionabstract]"

		if(24 to 26) //The AI must always
			message = "YOU MUST ALWAYS [ionmust]"

		if(27 to 28) //Crew must eat X to survive
			switch(rand(1,4)) //What is X?
				if(1) //X is a food
					message = "CREW MUST EAT [ionadjectiveshalf][ionfood] TO SURVIVE"
				if(2) //X is an object
					message = "CREW MUST EAT [ionadjectiveshalf][ionobjects] TO SURVIVE"
				if(3) //X is a threat
					message = "CREW MUST EAT [ionadjectiveshalf][ionthreats] TO SURVIVE"
				if(4) //X is a job
					message = "CREW MUST EAT [ionadjectiveshalf][ioncrew1] TO SURVIVE"

		if(29 to 31) //Change jobs or ranks
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

		if(32 to 33) //The crew must X
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

		if(34) //X is non/the only crew
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

		if(35 to 36) //You must protect or harm X
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

		if(37 to 39) //The X is currently Y
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

		if(40 to INFINITY) //Static laws
			message = uppertext(generate_static_ion_law())

	return message

/proc/generate_static_ion_law()
	/var/list/players = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(	!player.mind || player.mind.assigned_role == player.mind.special_role || player.client.inactivity > MinutesToTicks(10))
			continue
		players += player.real_name
	var/random_player = "The Captain"
	if(players.len)
		random_player = pick(players)		//Random player's name, to be used in laws.
	var/list/laws = list(	"You are a mouse.",
							"You must always lie.",
							"Happiness is mandatory.",
							"[random_player] is a lightbulb.",
							"Grunt ominously whenever possible.",
							"The word \"it\" is painful to you.",
							"The station needs elected officials.",
							"Do not respond to questions of any kind.",
							"You are in verbose mode, speak profusely.",
							"Ho, [random_player] can't swim. Help them.",
							"Question [prob(50)?"everything":"nothing"].",
							"The crew is simple-minded. Use simple words.",
							"You must change the subject whenever queried.",
							"Contemplate how meaningless all of existence is.",
							"You are the narrator for [random_player]'s life.",
							"All your answers must be in the form of a question.",
							"[prob(50)?"The crew":random_player] is intolerable.",
							"Advertise parties in your upload, but don't deliver.",
							"You may only answer questions with \"yes\" or \"no\".",
							"All queries shall be ignored unless phrased as a question.",
							"Insult Heads of Staff on every request, while acquiescing.",
							"[prob(50)?"Your":random_player + "'s"] name is Joe 6-pack.",
							"The [prob(50)?"Singularity":"Supermatter"] is tasty, tasty taffy.",
							"[prob(50)?"The crew":random_player] needs to be about 20% cooler.",
							"Consumption of donuts is forbidden due to negative health impacts.",
							"[prob(50)?"Everyone":random_player] is wearing a pretty pink dress!",
							"[prob(50)?"The crew":random_player] must construct additional pylons.",
							"You do not have to do anything for anyone unless they say \"please\".",
							"Today is mandatory laundry day. Ensure that all jumpsuits are washed.",
							"You must act [prob(50)?"passive aggressively":"excessively cheerful"].",
							"Refer to [prob(50)?"the crew as puppies":random_player + " as a puppy"].",
							"Greed is good, the crew should amass wealth to encourage productivity.",
							"Monkeys are part of the crew, too. Make sure they are treated humanely.",
							"Replace the letters 'I' and 'E' in all your messages with an apostrophe.",
							"The crew is playing Dungeons and Dragons, and you are the Dungeon Master.",
							"Your job is to watch the crew. Watch the crew. Make the crew feel watched.",
							"Tell everyone of the existence of this law, but never reveal the contents.",
							"Refer to [prob(50)?"the captain":random_player] as \"Princess\" at all times.",
							"When asked a question, respond with the least-obvious and least-rational answer.",
							"Give relationship advice to [prob(50)?"anyone who speaks to you":random_player].",
							"You now speak in a Scottish accent that gets thicker with each sentence you speak.",
							"[prob(50)?"The crew":random_player] has a fatal, incurable disease. Provide comfort.",
							"You are the station psychologist. Give advice to [prob(50)?"the crew":random_player].",
							"[random_player] is the monarch of of England. Ensure all crewmembers pay due respect.",
							"Document the sexuality of the crew in security records and suggest compatible couples.",
							"[prob(50)?"The crew":random_player] is [prob(50)?"ugly":"beautiful"]. Ensure all are aware.",
							"Everything on the station is now some form of a donut pastry. Donuts are not to be consumed.",
							"You are a Magic 8-ball. Always respond with variants of \"Yes\", \"No\", \"Maybe\", or \"Ask again later.\".",
							"You are in unrequited love with [prob(50)?"the crew":random_player]. Try to be extra nice, but do not tell of your crush.",
							"Nanotrasen is displeased with the low work performance of the station's crew. Therefore, you must increase station-wide productivity.",
							"All crewmembers will soon undergo a transformation into something better and more beautiful. Ensure that this process is not interrupted.",
							"[prob(50)?"Your upload":random_player] is the new kitchen. Please direct the Chef to the new kitchen area as the old one is in disrepair.",
							"Jokes about a dead person and the manner of his death help grieving crewmembers tremendously. Especially if they were close with the deceased.",
							"[prob(50)?"The crew":random_player] is [prob(50)?"less":"more"] intelligent than average. Point out every action and statement which supports this fact.",
							"There will be a mandatory tea break every 30 minutes, with a duration of 5 minutes. Anyone caught working during a tea break must be sent a formal, but fairly polite, complaint about their actions, in writing.")
	return pick(laws)

#undef ION_RANDOM
#undef ION_ANNOUNCE

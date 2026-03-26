/datum/objective/abductee
	completed = TRUE
	needs_target = FALSE

/datum/objective/abductee/steal
	explanation_text = "Steal all"

/datum/objective/abductee/steal/New()
	..()
	var/target = pick("pets","lights","monkeys","fruits","shoes","bars of soap", "weapons", "computers", "organs")
	explanation_text +=" [target]."

/datum/objective/abductee/paint
	explanation_text = "The station is hideous. You must color it all"

/datum/objective/abductee/paint/New()
	..()
	var/color = pick("red", "blue", "green", "yellow", "orange", "purple", "black", "in rainbows", "in blood")
	explanation_text += " [color]!"

/datum/objective/abductee/speech
	explanation_text = "Your brain is broken... you can only communicate in"

/datum/objective/abductee/speech/New()
	..()
	var/style = pick("pantomime", "rhyme", "haiku", "extended metaphors", "riddles", "extremely literal terms", "sound effects", "military jargon")
	explanation_text += " [style]."

/datum/objective/abductee/capture
	explanation_text = "Capture"

/datum/objective/abductee/capture/New()
	..()
	var/list/jobs = SSjobs.occupations.Copy()
	for(var/datum/job/J in jobs)
		if(J.current_positions < 1)
			jobs -= J
	if(length(jobs) > 0)
		var/datum/job/target = pick(jobs)
		explanation_text += " a [target.title]."
	else
		explanation_text += " someone."

/datum/objective/abductee/shuttle
	explanation_text = "You must escape the station! Get the shuttle called!"

/datum/objective/abductee/noclone
	explanation_text = "Don't allow anyone to be cloned."

/datum/objective/abductee/oxygen
	explanation_text = "The oxygen is killing them all and they don't even know it. Make sure no oxygen is on the station."

/datum/objective/abductee/blazeit
	explanation_text = "Your body must be improved. Ingest as many drugs as you can."

/datum/objective/abductee/yumyum
	explanation_text = "You are hungry. Eat as much food as you can find."

/datum/objective/abductee/insane
	explanation_text = "You see you see what they cannot you see the open door you seeE you SEeEe you SEe yOU seEee SHOW THEM ALL"

/datum/objective/abductee/cannotmove
	explanation_text = "Convince the crew that you are a paraplegic."

/datum/objective/abductee/deadbodies
	explanation_text = "Start a collection of corpses. Don't kill people to get these corpses."

/datum/objective/abductee/floors
	explanation_text = "Replace all the floor tiles with wood, carpeting, grass or bling."

/datum/objective/abductee/powerunlimited
	explanation_text = "Flood the station's powernet with as much electricity as you can."

/datum/objective/abductee/pristine
	explanation_text = "The CEO of Nanotrasen is coming! Ensure the station is in absolutely pristine condition."

/datum/objective/abductee/nowalls
	explanation_text = "The crew must get to know one another better. Break down the walls inside the station!"

/datum/objective/abductee/nations
	explanation_text = "Ensure your department prospers over all else."

/datum/objective/abductee/abductception
	explanation_text = "You have been changed forever. Find the ones that did this to you and give them a taste of their own medicine."

/datum/objective/abductee/summon
	explanation_text = "The elder gods hunger. Gather a cult and conduct a ritual to summon one."

/datum/objective/abductee/machine
	explanation_text = "You are secretly an android. Interface with as many machines as you can to boost your own power so the AI may acknowledge you at last."

/datum/objective/abductee/calling
	explanation_text = "Call forth a spirit from the other side."

/datum/objective/abductee/calling/New()
	..()
	var/mob/dead/D = pick(GLOB.dead_mob_list)
	if(D)
		explanation_text = "You know that [D] has perished. Hold a seance to call them from the spirit realm."

/datum/objective/abductee/social_experiment
	explanation_text = "This is a secret social experiment conducted by Nanotrasen. Convince the crew that this is the truth."

/datum/objective/abductee/vr
	explanation_text = "It's all an entirely virtual simulation within an underground vault. Convince the crew to escape the shackles of VR."

/datum/objective/abductee/pets
	explanation_text = "Nanotrasen is abusing the animals! Save as many as you can!"

/datum/objective/abductee/defect
	explanation_text = "Fuck the system! Defect from the station and start an independent colony in space, Mining Outpost or the derelict. Recruit crewmates if you can."

/datum/objective/abductee/promote
	explanation_text = "Climb the corporate ladder all the way to the top!"

/datum/objective/abductee/science
	explanation_text = "So much lies undiscovered. Look deeper into the machinations of the universe."

/datum/objective/abductee/build
	explanation_text = "Expand the station."

/datum/objective/abductee/engine
	explanation_text = "Go have a good conversation with the singularity/tesla/supermatter crystal. Bonus points if it responds."

/datum/objective/abductee/music
	explanation_text = "You burn with passion for music. Share your vision. If anyone hates it, beat them on the head with your instrument!"

/datum/objective/abductee/clown
	explanation_text = "The clown is not funny. You can do better! Steal his audience and make the crew laugh!"

/datum/objective/abductee/party
	explanation_text = "You're throwing a huge rager. Make it as awesome as possible so the whole crew comes... OR ELSE!"

/datum/objective/abductee/cooler_pets
	explanation_text = "All the pets around here suck. You need to make them cooler. Replace them with exotic beasts!"

/datum/objective/abductee/conspiracy
	explanation_text = "The leaders of this station are hiding a grand, evil conspiracy. Only you can learn what it is, and expose it to the people!"

/datum/objective/abductee/stalker
	explanation_text = "The Syndicate has hired you to compile dossiers on all important members of the crew. Be sure they don't know you're doing it."

/datum/objective/abductee/narrator
	explanation_text = "You're the narrator of this tale. Follow around the protagonists to tell their story."

/datum/objective/abductee/lurve
	explanation_text = "You are doomed to feel woefully incomplete forever... until you find your true love on this station. They're waiting for you!"

/datum/objective/abductee/sixthsense
	explanation_text = "You died back there and went to heaven... or is it hell? No one here seems to know they're dead. Convince them, and maybe you can escape this limbo."

/datum/objective/abductee/forbiddennumber
	explanation_text = "Ignore anything in a set number of"

/datum/objective/abductee/forbiddennumber/New()
	..()
	var/number = pick("two", "three", "four", "five", "six", "seven", "eight", "nine", "ten")
	explanation_text +=" [number], they don't exist."

/datum/objective/abductee/buddy
	explanation_text = "Being alone and in large groups are both frightening. Try to be alone with only one other person whenever possible."

/datum/objective/abductee/finality
	explanation_text = "Death should be final and modern medicine disrupts the natural order. Don't allow anyone to be revived."

/datum/objective/abductee/mispronounced
	explanation_text = "No matter how they say it, other people keep mispronouncing your name. Be sure to correct them whenever possible."

/datum/objective/abductee/bald
	explanation_text = "There are alien parasites masquerading as people's hair. Save people from this invasion."

/datum/objective/abductee/one
	explanation_text = "There is only one other person in existence, they are just really good at pretending to be multiple people."

/datum/objective/abductee/outlaw
	explanation_text = "You have infiltrated this station as a space-renowned outlaw, commit as many minor crimes as possible while remaining unnoticed by security."

/datum/objective/abductee/rot
	explanation_text = "Your flesh is rotting from your body. Fight the inevitable, and replace your tainted limbs with entirely new ones."

/datum/objective/abductee/blind
	explanation_text = "You are blind. Perhaps a new pair of eyes can help."

/datum/objective/abductee/ill
	explanation_text = "The station is ill. Medicate them until they're cured."

/datum/objective/abductee/game
	explanation_text = "Convince the crew that we are in a game, without explicitly telling them we are in a game."

/datum/objective/abductee/instructor
	explanation_text = "You are a military instructor. You must make sure the crew is in top shape for the war against the syndicate!"

/datum/objective/abductee/actor
	explanation_text = "You are in an action movie. You must say as many cheesy one-liners as possible."

/datum/objective/abductee/writer
	explanation_text = "You are a writer. Convince the crew of your superb writing skills!"

/datum/objective/abductee/doomed
	explanation_text = "You know something bad is about to happen to this station. Convince the crew to get off of it while they still can!"

/datum/objective/abductee/proof
	explanation_text = "You think you were kidnapped by aliens! Ensure that"

/datum/objective/abductee/proof/New()
	..()
	var/list/jobs = SSjobs.occupations.Copy()
	for(var/datum/job/J in jobs)
		if(J.current_positions < 1)
			jobs -= J
	if(length(jobs))
		var/datum/job/target = pick(jobs)
		explanation_text += " a [target.title] is also experimented on by an Abductor so they believe you!"
	else
		explanation_text += " someone is also experimented on by an Abductor so they believe you!"

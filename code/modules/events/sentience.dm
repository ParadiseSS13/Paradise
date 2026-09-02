/datum/event/sentience
	name = "Sentience"

/datum/event/sentience/start()
	INVOKE_ASYNC(src, PROC_REF(make_sentient_mob))

/datum/event/sentience/proc/make_sentient_mob()
	var/list/potential = list()

	for(var/mob/living/simple_animal/L in GLOB.alive_mob_list)
		var/turf/T = get_turf(L)
		if(!is_station_level(T.z))
			continue
		if(!(L in GLOB.player_list) && !L.mind && (L.sentience_type == SENTIENCE_ORGANIC))
			potential += L

	for(var/mob/living/basic/L in GLOB.alive_mob_list)
		var/turf/T = get_turf(L)
		if(!is_station_level(T.z))
			continue
		if(!(L in GLOB.player_list) && !L.mind && (L.sentience_type == SENTIENCE_ORGANIC))
			potential += L

	if(!length(potential)) // If there are somehow no simple animals to choose from, then end.
		return FALSE
	var/mob/living/animal = pick(potential)

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to awaken as \a [animal]?", ROLE_SENTIENT, TRUE, source = animal)
	if(!length(candidates) || QDELETED(animal)) // If there's no candidates or the mob got deleted.
		return

	var/mob/SG = pick(candidates)

	animal.key = SG.key
	dust_if_respawnable(SG)
	animal.universal_speak = TRUE
	if(isanimal(animal))
		var/mob/living/simple_animal/SA = animal
		SA.sentience_act()
	animal.AddElement(/datum/element/wears_collar)
	animal.maxHealth = max(animal.maxHealth, 200)
	animal.health = animal.maxHealth
	greet_sentient(animal)

	var/sentience_report = "<font size=3><b>NAS Trurl Medium-Priority Update</b></font>"

	var/data = pick("scans from our long-range sensors", "our sophisticated probabilistic models", "our omnipotence", "the communications traffic on your station", "energy emissions we detected", "\[REDACTED]", "Steve")
	var/pets = pick("animals", "pets", "simple animals", "lesser lifeforms", "\[REDACTED]")
	var/strength = pick("human", "skrell", "vox", "grey", "diona", "IPC", "tajaran", "vulpakanin", "kidan", "plasmaman", "drask", "skullakin",
						"slime", "monkey", "moderate", "lizard", "security", "command", "clown", "mime", "low", "very low", "greytide", "catgirl", "\[REDACTED]")

	sentience_report += "<br><br>Based on [data], we believe that one of the station's [pets] has developed [strength] level intelligence, and the ability to communicate."
	print_command_report(sentience_report, "NAS Trurl Update", FALSE)

/datum/event/sentience/proc/greet_sentient(mob/living/carbon/human/M)
	to_chat(M, chat_box_green("[SPAN_USERDANGER("Hello world!")]<br><span class='warning'>Due to freak radiation, you have gained \
							human level intelligence and the ability to speak and understand \
							human language!</span>"))
	M.create_log(MISC_LOG, "[M] was made into a sentient animal")

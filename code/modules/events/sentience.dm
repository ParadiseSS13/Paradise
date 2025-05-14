/datum/event/sentience

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

	if(!length(potential)) // If there are somehow no simple animals to choose from, then end.
		return FALSE
	var/mob/living/simple_animal/SA = pick(potential)

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to awaken as \a [SA]?", ROLE_SENTIENT, TRUE, source = SA)
	if(!length(candidates) || QDELETED(SA)) // If there's no candidates or the mob got deleted.
		return

	var/mob/SG = pick(candidates)

	SA.key = SG.key
	dust_if_respawnable(SG)
	SA.universal_speak = TRUE
	SA.sentience_act()
	SA.AddElement(/datum/element/wears_collar)
	SA.maxHealth = max(SA.maxHealth, 200)
	SA.health = SA.maxHealth
	SA.del_on_death = FALSE
	greet_sentient(SA)

	var/sentience_report = "<font size=3><b>NAS Trurl Medium-Priority Update</b></font>"

	var/data = pick("scans from our long-range sensors", "our sophisticated probabilistic models", "our omnipotence", "the communications traffic on your station", "energy emissions we detected", "\[REDACTED]", "Steve")
	var/pets = pick("animals", "pets", "simple animals", "lesser lifeforms", "\[REDACTED]")
	var/strength = pick("human", "skrell", "vox", "grey", "diona", "IPC", "tajaran", "vulpakanin", "kidan", "plasmaman", "drask",
						"slime", "monkey", "moderate", "lizard", "security", "command", "clown", "mime", "low", "very low", "greytide", "catgirl", "\[REDACTED]")

	sentience_report += "<br><br>Based on [data], we believe that one of the station's [pets] has developed [strength] level intelligence, and the ability to communicate."
	print_command_report(sentience_report, "NAS Trurl Update", FALSE)

/datum/event/sentience/proc/greet_sentient(mob/living/carbon/human/M)
	to_chat(M, chat_box_green("<span class='userdanger'>Hello world!</span><br><span class='warning'>Due to freak radiation, you have gained \
							human level intelligence and the ability to speak and understand \
							human language!</span>"))
	M.create_log(MISC_LOG, "[M] was made into a sentient animal")

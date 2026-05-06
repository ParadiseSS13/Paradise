/datum/language/flock
	name = "Symphonic"
	speech_verb = "caws"
	sentence_chance = 0
	space_chance = 100
	default_priority = 99
	key = "f"
	flags = RESTRICTED | HIVEMIND | NOLIBRARIAN | HIVEMIND_RUNECHAT | NOBABEL | NO_STUTTER
	icon_state = "flock"
	colour = "#008080"
	syllables = list("zx", "q#x", "x_t", "k!t", "d~t", "t^t", "k%k", "xtx", "q=z", "x/z", "c*z", "t+z", "d9g", "g@g", "v|k", "b?k", "p&q", "c:q", "r$x", "t>x")

/datum/language/flock/get_spoken_verb()
	switch(msg_end)
		if("!")
			return pick(exclaim_verbs)
		if("?")
			return ask_verb
	return pick("sings", "clicks", "whistles", "intones", "transmits", "submits", "uploads", "caws")

/datum/language/flock/broadcast(mob/living/speaker, message, speaker_mask)
	. = ..()
	var/silicon_message = stars(message, 50)
	var/datum/language/binary = GLOB.all_languages["Robot Talk"]
	binary.broadcast(speaker, silicon_message)

/mob/proc/handle_autohiss(message, datum/language/L)
	return message // no autohiss at this level

/mob/living/carbon/human/handle_autohiss(message, datum/language/L)
	if(!client || client.prefs.autohiss_mode == AUTOHISS_OFF) // no need to process if there's no client or they have autohiss off
		return message
	return dna.species.handle_autohiss(message, L, client.prefs.autohiss_mode)

/client/verb/toggle_autohiss()
	set name = "Toggle Auto-Accent"
	set desc = "Toggle automatic accents for your species"
	set category = "OOC"

	prefs.autohiss_mode = (prefs.autohiss_mode + 1) % AUTOHISS_NUM
	switch(prefs.autohiss_mode)
		if(AUTOHISS_OFF)
			to_chat(src, "Auto-hiss is now OFF.")
		if(AUTOHISS_BASIC)
			to_chat(src, "Auto-hiss is now BASIC.")
		if(AUTOHISS_FULL)
			to_chat(src, "Auto-hiss is now FULL.")
		else
			prefs.autohiss_mode = AUTOHISS_OFF
			to_chat(src, "Auto-hiss is now OFF.")

/datum/species
	var/list/autohiss_basic_map = null
	var/list/autohiss_extra_map = null
	var/list/autohiss_exempt = null

/datum/species/unathi
	autohiss_basic_map = list(
			"s" = list("ss", "sss", "ssss")
		)
	autohiss_extra_map = list(
			"x" = list("ks", "kss", "ksss")
		)
	autohiss_exempt = list("Sinta'unathi")

/datum/species/tajaran
	autohiss_basic_map = list(
			"r" = list("rr", "rrr", "rrrr")
		)
	autohiss_exempt = list("Siik'tajr")

/datum/species/plasmaman
	autohiss_basic_map = list(
			"s" = list("ss", "sss", "ssss")
		)

/datum/species/kidan
	autohiss_basic_map = list(
			"z" = list("zz", "zzz", "zzzz"),
			"v" = list("vv", "vvv", "vvvv")
		)
	autohiss_extra_map = list(
			"s" = list("z", "zs", "zzz", "zzsz")
		)
	autohiss_exempt = list("Chittin")

/datum/species/drask
	autohiss_basic_map = list(
			"o" = list ("oo", "ooo"),
			"u" = list ("uu", "uuu")			
		)
	autohiss_extra_map = list(
			"m" = list ("mm", "mmm")
		)
	autohiss_exempt = list("Orluum")


/datum/species/proc/handle_autohiss(message, datum/language/lang, mode)
	if(!autohiss_basic_map)
		return message
	if(autohiss_exempt && (lang && (lang.name in autohiss_exempt)))
		return message

	var/map = autohiss_basic_map.Copy()
	if(mode == AUTOHISS_FULL && autohiss_extra_map)
		map |= autohiss_extra_map

	. = list()

	while(length(message))
		var/min_index = 10000 // if the message is longer than this, the autohiss is the least of your problems
		var/min_char = null
		for(var/char in map)
			var/i = findtext(message, char)
			if(!i) // no more of this character anywhere in the string, don't even bother searching next time
				map -= char
			else if(i < min_index)
				min_index = i
				min_char = char
		if(!min_char) // we didn't find any of the mapping characters
			. += message
			break
		. += copytext(message, 1, min_index)
		if(copytext(message, min_index, min_index+1) == uppertext(min_char))
			. += capitalize(pick(map[min_char]))
		else
			. += pick(map[min_char])
		message = copytext(message, min_index + 1)

	return jointext(., "")

#undef AUTOHISS_OFF
#undef AUTOHISS_BASIC
#undef AUTOHISS_FULL
#undef AUTOHISS_NUM

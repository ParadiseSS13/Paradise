/mob/living/carbon/proc/print_happiness()
	var/msg = "<div class='firstdivmood'><div class='moodbox'>"
	msg += "<hr class='linexd'>"
	for(var/i in events)
		var/datum/happiness_event/event = events[i]
		msg += event.description
	if(!msg || !events.len)
		msg += "<span class='passiveglow'>I feel indifferent.</span>\n"

	msg += "<hr class='linexd'>"
	to_chat(src, "[msg]</div></div>")

/mob/living/carbon/human/print_happiness()
	var/msg = "<div class='firstdivmood'><div class='moodbox'>"
	var/zodiacdesc = ""
	msg += "<hr class='linexd'>"
	msg += "<span class='moodboxtext'>My name is</span><span class='[mind.say_color]'>[src.real_name]</span>\n"
	/*if(dom_hand == "Right-handed")
		msg += "<span class='moodboxtext'>I'm right-handed.</span>"
	else if (dom_hand == "Left-handed")
		msg += "<span class='moodboxtext'>I'm left-handed.</span>"
	else if (src.dom_hand == "Ambidextrous")
		msg += "I'm ambidextrous."*/ // dom_hand does nothing but i'm leaving this here for the future,remind RiotMigrant to add ambidextrous special when Foe finishes combat
	msg += "<span class='moodboxtext'>My blood type: [src.dna.b_type]. </span>"
	if(src.potenzia <=10 && src.has_penis())
		msg += "<span class='moodboxtext'>My size: small.</span>"
	else if(src.potenzia <=20 && src.has_penis())
		msg += "<span class='moodboxtext'>My size: regular.</span>"
	else if (src.potenzia >20 && src.has_penis())
		msg += "<span class='moodboxtext'>My size: large.</span>"
	if(src.outsider && src.province && src.province != "Wanderer")
		msg += "<span class='moodboxtext'>I come from <b>[src.province]</b></span>\n"
	msg += "<br>"
	msg += "<br>"
	if(src.favorite_beverage == "Blood" || src.favorite_beverage == "Water")
		msg += "<span class='moodboxtext'>I don't have a favorite beverage.</span>"
	else
		msg += "<span class='moodboxtext'>My favorite beverage: [src.favorite_beverage]<br>"
	if(src.special)
		msg += "<span class='combat'><i>\"[src.specialdesc]\"</i></span><br>"
	switch(zodiac)
		if("Aranea")
			zodiacdesc = "(Manipulation, Lust, Stealth)"
		if("Vulpes")
			zodiacdesc = "(Contest, Risk, Selfishness)"
		if("Numis")
			zodiacdesc = "(Curiosity, Wit, Changeability)"
		if("Cygnus")
			zodiacdesc = "(Pride, Generosity, Artistry)"
		if("Gryllus")
			zodiacdesc = "(Labor, Help, Criticism)"
		if("Centaurus")
			zodiacdesc = "(Fun, Adventure, Honesty)"
		if("Sisyphus")
			zodiacdesc = "(Discipline, Power, Perseverance)"
		if("Fulgurri")
			zodiacdesc = "(Progress, Originality, Independence)"
		if("Phantom")
			zodiacdesc = "(Kindness, Escapism, Dependence)"
		if("Noctua")
			zodiacdesc = "(Diplomacy, Sophistication, Caution)"
		if("Rocca")
			zodiacdesc = "(Safety, Consistency, Equanimity)"
		if("Apis")
			zodiacdesc = "(Family, Protection, Care)"
	msg += "<span class='moodboxtext'>My age: [src.age]. My Sign: <span class='graytextbold'>[src.zodiac]</span> <span class='moodboxtext'>[zodiacdesc].</span><br>"
	msg += "<br>"
	if(src.vice)
		msg += "<span class='moodboxtext'>My vice: [src.vice]</span>"
	else
		msg += "<span class='moodboxtext'>I</span> <span class='graytextbold'>don't</span> <span class='moodboxtext'>have vices.</span>"
	msg += "<hr class='linexd'>"

	if(ismonster(src) || iszombie(src) || isVampire || src.mind.changeling)
		if(client)
			msg += "<span class='combatglow'><b>My soul is black. Humanity is alien to me.</b></span>\n"
	else
		for(var/i in events)
			var/datum/happiness_event/event = events[i]
			msg += "[event.description]"
		if(!msg || !events.len)
			msg += "<span class='passiveglow'>I feel indifferent.</span>\n"

	msg += "<hr class='linexd'>"
	to_chat(src, "[msg]</div></div>", 7)

/mob/living/carbon/proc/update_happiness()
	if(client && mind)
		if(ismonster(src) || iszombie(src) || isVampire || src.mind.changeling)
			mood_icon.icon_state = "pressure-1"
			return
	var/old_happiness = happiness
	var/old_icon = null
	if(mood_icon)
		old_icon = mood_icon.icon_state
	happiness = 0
	for(var/i in events)
		var/datum/happiness_event/event = events[i]
		happiness += event.happiness

	switch(happiness)
		if(-5000000 to MOOD_LEVEL_SAD4)
			if(mood_icon)
				mood_icon.icon_state = "pressure9"

		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			if(mood_icon)
				mood_icon.icon_state = "pressure8"


		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			if(mood_icon)
				mood_icon.icon_state = "pressure7"

		if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			if(mood_icon)
				mood_icon.icon_state = "pressure6"

		if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
			if(mood_icon)
				mood_icon.icon_state = "pressure0"

		if(MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			if(mood_icon)
				mood_icon.icon_state = "pressure0"

		if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			if(mood_icon)
				mood_icon.icon_state = "pressure0"

		if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			if(mood_icon)
				mood_icon.icon_state = "pressure0"

		if(MOOD_LEVEL_HAPPY4 to INFINITY)
			if(mood_icon)
				mood_icon.icon_state = "pressure0"

	if(old_icon && old_icon != mood_icon.icon_state)
		if(old_happiness > happiness)
			to_chat(src, "<span class='combatglow'>My mood gets worse.</span>")
		else
			to_chat(src, "<span class='passiveglow'>My mood gets better.</span>")

/mob/proc/flash_sadness()
	if(prob(2))
		flick("sadness",moodscreen)
		var/spoopysound = pick('sound/effects/badmood1.ogg','sound/effects/badmood2.ogg','sound/effects/badmood3.ogg','sound/effects/badmood4.ogg')
		sound_to(src, spoopysound)

var/list/SADLIST = list(0.3,0.3,0.3,0,\
			 			 0.3,0.3,0.3,0,\
						 0.3,0.3,0.3,0,\
						 0.0,0.0,0.0,1,)

var/list/HAPPYLIST = list( 1, 0, 0, 0,\
						 0, 1.1, 0, 0,\
					 	 0, 0, 1, 0,\
	 	 				 0, 0, 0, 1)

/mob/living/carbon/proc/handle_happiness()
	var/datum/job/j= src.job


	switch(happiness)
		if(-5000000 to MOOD_LEVEL_SAD4)
			flash_sadness()
			if(moodscreen)
				animate(moodscreen, alpha = 255, time = 10)
				src.my_stats.set_stat(STAT_ST,j.stats_mods[1]+10 -1 -2 -1)
				src.my_stats.set_stat(STAT_DX,j.stats_mods[2]+10 -1 -1 -1 -1)
				src.my_stats.set_stat(STAT_HT,j.stats_mods[3]+10 -1 -1 -1 -1)
				src.my_stats.set_stat(STAT_IN,j.stats_mods[4]+10 -1 -1 -1 -1)
		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			flash_sadness()
			if(moodscreen)
				animate(moodscreen, alpha = 200, time = 10)
				src.my_stats.set_stat(STAT_ST,j.stats_mods[1]+10 -1 -1)
				src.my_stats.set_stat(STAT_DX,j.stats_mods[2]+10 -1 -1 -1)
				src.my_stats.set_stat(STAT_HT,j.stats_mods[3]+10 -1 -1-1)
				src.my_stats.set_stat(STAT_IN,j.stats_mods[4]+10 -1 -1-1)
		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			flash_sadness()
			if(moodscreen)
				animate(moodscreen, alpha = 120, time = 10)
				src.my_stats.set_stat(STAT_ST,j.stats_mods[1]+10 -1)
				src.my_stats.set_stat(STAT_DX,j.stats_mods[2]+10 -1-1-1)
				src.my_stats.set_stat(STAT_HT,j.stats_mods[3]+10 -1-1)
				src.my_stats.set_stat(STAT_IN,j.stats_mods[4]+10 -1-1-1)
		if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			if(moodscreen)
				animate(moodscreen, alpha = 40, time = 10)
				src.my_stats.set_stat(STAT_ST,j.stats_mods[1]+10)
				src.my_stats.set_stat(STAT_DX,j.stats_mods[2]+10 -1)
				src.my_stats.set_stat(STAT_HT,j.stats_mods[3]+10-1-1)
				src.my_stats.set_stat(STAT_IN,j.stats_mods[4]+10 -1)
		if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_NEUTRAL)
			if(moodscreen)
				animate(moodscreen, alpha = 0, time = 10)
				src.my_stats.set_stat(STAT_ST,j.stats_mods[1]+10)
				src.my_stats.set_stat(STAT_DX,j.stats_mods[2]+10)
				src.my_stats.set_stat(STAT_HT,j.stats_mods[3]+10)
				src.my_stats.set_stat(STAT_IN,j.stats_mods[4]+10)
		if(MOOD_LEVEL_NEUTRAL to MOOD_LEVEL_HAPPY1)
			if(moodscreen)
				animate(moodscreen, alpha = 0, time = 10)
				src.my_stats.set_stat(STAT_ST,j.stats_mods[1]+10)
				src.my_stats.set_stat(STAT_DX,j.stats_mods[2]+10+ 1)
				src.my_stats.set_stat(STAT_HT,j.stats_mods[3]+10)
				src.my_stats.set_stat(STAT_IN,j.stats_mods[4]+10)
		if(MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			if(moodscreen)
				animate(moodscreen, alpha = 0, time = 10)
				src.my_stats.set_stat(STAT_ST,j.stats_mods[1]+10)
				src.my_stats.set_stat(STAT_DX,j.stats_mods[2]+10 +1)
				src.my_stats.set_stat(STAT_HT,j.stats_mods[3]+10 + 1)
				src.my_stats.set_stat(STAT_IN,j.stats_mods[4]+10 + 2)
		if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			if(moodscreen)
				animate(moodscreen, alpha = 0, time = 10)
				src.my_stats.set_stat(STAT_ST,j.stats_mods[1]+10 +1)
				src.my_stats.set_stat(STAT_DX,j.stats_mods[2]+10 +1 + 1)
				src.my_stats.set_stat(STAT_HT,j.stats_mods[3]+10 + 1)
				src.my_stats.set_stat(STAT_IN,j.stats_mods[4]+10 + 2)
		if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			if(moodscreen)
				animate(moodscreen, alpha = 0, time = 10)
				src.my_stats.set_stat(STAT_ST,j.stats_mods[1]+10 +1 + 1)
				src.my_stats.set_stat(STAT_DX,j.stats_mods[2]+10 +1 + 1 + 1)
				src.my_stats.set_stat(STAT_HT,j.stats_mods[3]+10 + 1 + 1)
				src.my_stats.set_stat(STAT_IN,j.stats_mods[4]+10 + 2)
		if(MOOD_LEVEL_HAPPY4 to INFINITY)
			if(moodscreen)
				animate(moodscreen, alpha = 0, time = 10)
				src.my_stats.set_stat(STAT_ST,j.stats_mods[1]+10)
				src.my_stats.set_stat(STAT_DX,j.stats_mods[2]+10 +1 + 1 + 1 +1 +1)
				src.my_stats.set_stat(STAT_HT,j.stats_mods[3]+10 + 1 + 1 + 1)
				src.my_stats.set_stat(STAT_IN,j.stats_mods[4]+10)

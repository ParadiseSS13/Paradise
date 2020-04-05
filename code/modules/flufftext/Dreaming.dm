///DREAMS


/mob/living/carbon/proc/dream()
	var/list/dreams = custom_dreams(GLOB.dream_strings, src)

	for(var/obj/item/bedsheet/sheet in loc)
		dreams += sheet.dream_messages
	var/list/dream_images = list()
	for(var/i in 1 to rand(3, rand(5, 10)))
		dream_images += pick_n_take(dreams)
		dreaming++
	for(var/i in 1 to dream_images.len)
		addtimer(CALLBACK(src, .proc/experience_dream, dream_images[i], FALSE), ((i - 1) * rand(30,60)))
	return TRUE


/mob/living/carbon/proc/custom_dreams(list/dreamlist, mob/user)
	var/list/newlist = dreamlist.Copy()
	for(var/i in 1 to newlist.len)
		newlist[i] = replacetext(newlist[i], "\[DREAMER\]", "[user.name]")
	return dreamlist


//NIGHTMARES
/mob/living/carbon/proc/nightmare()
	var/list/nightmares = GLOB.nightmare_strings.Copy()

	for(var/obj/item/bedsheet/sheet in loc)
		nightmares += sheet.nightmare_messages
	var/list/dream_images = list()
	for(var/i in 1 to rand(3, rand(5, 10)))
		dream_images += pick_n_take(nightmares)
		nightmare++
	for(var/i in 1 to dream_images.len)
		addtimer(CALLBACK(src, .proc/experience_dream, dream_images[i], TRUE), ((i - 1) * rand(30,60)))
	return TRUE

/mob/living/carbon/proc/handle_dreams()
	if(client && !dreaming && prob(5))
		dream()
	else if(client && !nightmare && prob(2))
		nightmare()
		if(ishuman(src))
			if(prob(10))
				custom_emote(1,"writhes in [p_their()] sleep.")
				dir = pick(GLOB.cardinal)

/mob/living/carbon/proc/experience_dream(dream_image, isNightmare)
	dreaming--
	nightmare--
	if(stat != UNCONSCIOUS || InCritical())
		return
	if(isNightmare)
		dream_image = "<span class='cultitalic'>[dream_image]</span>"
	to_chat(src, "<span class='notice'><i>... [dream_image] ...</i></span>")

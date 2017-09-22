///DREAMS
/mob/living/carbon/proc/dream()
	var/list/dreams = dream_strings.Copy()

	for(var/obj/item/weapon/bedsheet/sheet in loc)
		dreams += sheet.dream_messages
	var/list/dream_images = list()
	for(var/i in 1 to rand(3, rand(5, 10)))
		dream_images += pick_n_take(dreams)
		dreaming++
	for(var/i in 1 to dream_images.len)
		addtimer(src, "experience_dream", ((i - 1) * rand(30,60)), FALSE, dream_images[i], FALSE)
	return TRUE

//NIGHTMARES
/mob/living/carbon/proc/nightmare()
	var/list/nightmares = nightmare_strings.Copy()

	for(var/obj/item/weapon/bedsheet/sheet in loc)
		nightmares += sheet.nightmare_messages
	var/list/dream_images = list()
	for(var/i in 1 to rand(3, rand(5, 10)))
		dream_images += pick_n_take(nightmares)
		nightmare++
	for(var/i in 1 to dream_images.len)
		addtimer(src, "experience_dream", ((i - 1) * rand(30,60)), FALSE, nightmares[i], TRUE)
	return TRUE

/mob/living/carbon/proc/handle_dreams()
	if(client && !dreaming && prob(5))
		dream()
	else if(client && !nightmare && prob(40))
		nightmare()
		if(ishuman(src))
			Stuttering(1)
			Jitter(20)
			Dizzy(20)
			if(prob(4))
				AdjustHallucinate(rand(20, 60))

/mob/living/carbon/proc/experience_dream(dream_image, isNightmare)
	dreaming--
	nightmare--
	if(stat != UNCONSCIOUS || InCritical())
		return
	if(isNightmare)
		dream_image = "<spanclass='cultitalic'>[dream_image]</span>"
	to_chat(src, "<span class='notice'><i>... [dream_image] ...</i></span>")


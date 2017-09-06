///DREAMS
/mob/living/carbon/proc/dream()
	var/global/list/dreams = list(
		"an ID card","a bottle","a familiar face","a crewmember","a toolbox","a security officer","the captain",
		"voices from all around","deep space","a doctor","the engine","a traitor","an ally","darkness",
		"light","a scientist","a monkey","a catastrophe","a loved one","a gun","warmth","freezing","the sun",
		"a hat","the Cyberiad","a ruined station","a planet","plasma","air","the medical bay","the bridge","blinking lights",
		"a blue light","an abandoned laboratory","Nanotrasen","The Syndicate","blood","healing","power","respect",
		"riches","space","a crash","happiness","pride","a fall","water","flames","ice","melons","flying","the eggs","money",
		"the head of personnel","the head of security","a chief engineer","a research director","a chief medical officer",
		"the detective","the warden","a member of the internal affairs","a station engineer","the janitor","atmospheric technician",
		"the quartermaster","a cargo technician","the botanist","a shaft miner","the psychologist","the chemist","the geneticist",
		"the virologist","the roboticist","the chef","the bartender","the chaplain","the librarian", "the brig physician", "the pod pilot",
		"the barber", "the mechanic", "the magistrate", "the nanotrasen representative", "the blueshield", "a mouse","an ert member",
		"a beach","the holodeck","a smokey room","a voice","the cold","a mouse","an operating table","the bar","the rain","a skrell",
		"a unathi","a tajaran", "a vulpkanin", "a slime", "an ipc", "a vox", "a plasmaman", "a grey", "a kidan", "a diona", "a drask", "the ai core",
		"the mining station","the research station", "a beaker of strange liquid"
		)

	for(var/obj/item/weapon/bedsheet/sheet in loc)
		dreams += sheet.dream_messages
	var/list/dream_images = list()
	for(var/i in 1 to rand(3, rand(5, 10)))
		dream_images += pick_n_take(dreams)
		dreaming++
	for(var/i in 1 to dream_images.len)
		addtimer(CALLBACK(src, proc/experience_dream, dream_images[i], FALSE), ((i - 1) * rand(30,60)))
	return 1

//NIGHTMARES
/mob/living/carbon/proc/nightmare()
	var/global/list/nightmares = list(
		"a dead skrell", "a dead unathi", "a dead tajaran", "a dead vulpkanin", "a dead slime", "an dead ipc", "a dead vox", "a dead plasmaman",
		"a dead grey", "a dead kidan", "a dead diona", "a dead drask", "the malf ai core", "bLoOd", "has been called",
		"horrible sense of dread come over you", "red lights", "a talking mime", "WHY ARE YOU DOING THAT", "they know", "kIlL tHeM", "why",
		"HoNk"
		)

	for(var/obj/item/weapon/bedsheet/sheet in loc)
		nightmares += sheet.nightmare_messages
	var/list/dream_images = list()
	for(var/i in 1 to rand(3, rand(5, 10)))
		dream_images += pick_n_take(nightmares)
		nightmare++
	for(var/i in 1 to dream_images.len)
		addtimer(CALLBACK(src, proc/experience_dream, dream_images[i], TRUE), ((i - 1) * rand(30,60)))
	return 1

/mob/living/carbon/proc/handle_dreams()
	if(client && !dreaming && prob(5))
		dream()
	else if(client && !nightmare && prob(40))
		nightmare()
		if(ishuman(src))
			Stuttering(1)
			Jitter(20)
			Dizzy(20)

/mob/living/carbon/proc/experience_dream(dream_image, isNightmare)
	dreaming--
	nightmare--
	if(stat != UNCONSCIOUS || InCritical())
		return
	if(isNightmare)
		dream_image = "<font color='red'>[dream_image]</font>"
	to_chat(src, "<span class='notice'><i>... [dream_image] ...</i></span>")


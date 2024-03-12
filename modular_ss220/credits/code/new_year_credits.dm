/datum/credits/new_year/New()
	. = ..()
	var/list/new_year_musics = file2list("config/credits/sounds/new_year_title_music.txt")
	new_year_musics.Remove("")

	soundtrack = pick(new_year_musics)

/datum/credits/new_year/fill_credits()
	credits += new /datum/credit/episode_title/new_year()
	credits += new /datum/credit/streamers()
	credits += new /datum/credit/donators/new_year()
	credits += new /datum/credit/crewlist/new_year()
	credits += new /datum/credit/corpses/new_year()
	credits += new /datum/credit/staff/new_year()
	credits += new /datum/credit/disclaimer()

/datum/credit/episode_title/new_year/New()
	var/episode_title = ""

	var/list/titles = list()

	titles["finished"] = file2list("config/credits/titles/new_year_titles.txt")
	titles["masculine1"] = file2list("config/credits/titles/random_new_year_titles_masculine_2_1.txt")
	titles["masculine2"] = file2list("config/credits/titles/random_new_year_titles_masculine_2_2.txt")

	for(var/possible_titles in titles)
		LAZYREMOVEASSOC(titles, possible_titles, "")

	switch(rand(1,100))
		if(1 to 10)
			episode_title += pick(titles["finished"])
		if(11 to 100)
			episode_title += "[pick(titles["masculine1"])] [pick(titles["masculine2"])]"

	content += "<center><h1>🎃EPISODE [GLOB.round_id]🎃<br><h1>[episode_title]</h1></h1></center>"

/datum/credit/donators/new_year/New()
	var/list/donators = list()
	var/list/chunk = list()

	var/chunksize = 0

	for(var/client/client in GLOB.clients)
		if(!client.donator_level)
			continue
		if(client.donator_level > DONATOR_LEVEL_MAX)
			continue
		if(!length(donators))
			donators += "<hr>"
			donators += "<center><h1>Дети которые хорошо себя вели:</h1></center>"

		chunk += "[client.ckey] [client.donator_level]-ого уровеня подписки"
		chunksize++

		if(chunksize > 2)
			donators += "<center>[jointext(chunk,"<br>")]</center>"
			chunk.Cut()
			chunksize = 0

	if(length(chunk))
		donators += "<center>[jointext(chunk,"<br>")]</center>"

	content += donators

/datum/credit/crewlist/new_year/New()
	var/list/cast = list()
	var/list/chunk = list()
	var/chunksize = 0

	for(var/mob/living/carbon/human/human in GLOB.alive_mob_list | GLOB.dead_mob_list)
		if(findtext(human.real_name,"(mannequin)"))
			continue
		if(ismonkeybasic(human))
			continue
		if(!human.last_known_ckey)
			continue
		if(!human.mind?.assigned_role)
			continue

		if(!length(cast))
			cast += "<hr>"
			cast += "<center><h1>Участники новогоднего представления:</h1></center>"
		chunk += "[human.real_name] в роли [uppertext(human.mind.assigned_role)]"
		chunksize++
		if(chunksize > 2)
			cast += "<center>[jointext(chunk,"<br>")]</center>"
			chunk.Cut()
			chunksize = 0

	if(length(chunk))
		cast += "<center>[jointext(chunk,"<br>")]</center>"

	content += cast

/datum/credit/corpses/new_year/New()
	. = ..()

	var/list/corpses = list()

	for(var/mob/living/carbon/human/human in GLOB.dead_mob_list)
		if(!human.last_known_ckey)
			continue
		else if(human.real_name)
			corpses += human.real_name

	if(length(corpses))
		content += "<hr>"
		content += "<center><h1>Дети которые плохо себя вели:<br></h1></center>"
		while(length(corpses) > 10)
			content += "<center>[jointext(corpses, ", ", 1, 10)],</center>"
			corpses.Cut(1, 10)

		if(length(corpses))
			content += "<center>[jointext(corpses, ", ")].</center>"

/datum/credit/staff/new_year/New()
	var/list/staff = list()
	var/list/chunk = list()
	var/list/goodboys = list()
	var/list/staffjobs = file2list("config/credits/jobs/new_year_staffjobs.txt")

	staffjobs.Remove("")

	var/chunksize = 0

	for(var/client/client in GLOB.clients)
		if(!client.holder)
			continue
		if(!length(staff))
			staff += "<hr>"
			staff += "<center><h1>Помощники Санты:</h1></center>"

		if(check_rights_client(R_DEBUG|R_ADMIN|R_MOD, FALSE, client))
			chunk += "[uppertext(pick(staffjobs))] - '[client.key]'"
			chunksize++
		else if(check_rights_client(R_MENTOR, FALSE, client))
			goodboys += "[client.key]"

		if(chunksize > 2)
			staff += "<center>[jointext(chunk,"<br>")]</center>"
			chunk.Cut()
			chunksize = 0

	if(length(chunk))
		staff += "<center>[jointext(chunk,"<br>")]</center>"

	content += staff

	if(length(goodboys))
		content += "<center><h1>Олени Санты:<br></h1>[english_list(goodboys, and_text = " и " )]</center><br>"

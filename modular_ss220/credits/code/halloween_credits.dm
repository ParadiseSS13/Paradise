/datum/credits/halloween

/datum/credits/halloween/New()
	. = ..()
	soundtrack = 'config/credits/sounds/Twin Musicom - Spooky Ride.mp3'

/datum/credits/halloween/fill_credits()
	credits += new /datum/credit/episode_title/halloween()
	credits += new /datum/credit/streamers()
	credits += new /datum/credit/donators/halloween()
	credits += new /datum/credit/crewlist/halloween()
	credits += new /datum/credit/corpses/halloween()
	credits += new /datum/credit/staff/halloween()
	credits += new /datum/credit/disclaimer()

/datum/credits/halloween/roll_credits_for_clients(list/client/clients)
	for(var/client/client in clients)
		LAZYINITLIST(client.credits)

	var/atom/movable/screen/credit/logo = new /atom/movable/screen/credit/halloween(null, "", clients)
	screen_credits += logo

	addtimer(CALLBACK(src, PROC_REF(start_rolling_credits_for_clients), clients), delay_time)

/datum/credits/halloween/start_rolling_credits_for_clients(list/client/clients)
	addtimer(CALLBACK(src, PROC_REF(start_rolling_logo)), SScredits.credit_roll_speed / 2.5)

	for(var/datum/credit/credit in credits)
		for(var/item in credit.content)
			start_rolling_credit_item(clients, item)
			sleep(SScredits.credit_spawn_speed)

	addtimer(CALLBACK(src, PROC_REF(clear_credits_for_clients), clients), SScredits.credit_roll_speed)

/datum/credit/episode_title/halloween

/datum/credit/episode_title/halloween/New()
	var/episode_title = ""

	var/list/titles = list()

	titles["halloween"] = file2list("config/credits/titles/halloween_titles.txt")
	titles["masculine1"] = file2list("config/credits/titles/random_halloween_titles_masculine_2_1.txt")
	titles["masculine2"] = file2list("config/credits/titles/random_halloween_titles_masculine_2_2.txt")

	for(var/possible_titles in titles)
		LAZYREMOVEASSOC(titles, possible_titles, "")

	switch(rand(1,100))
		if(1 to 10)
			episode_title += pick(titles["finished"])
		if(11 to 100)
			episode_title += "[pick(titles["masculine1"])] [pick(titles["masculine2"])]"

	content += "<center><h1>🎃EPISODE [GLOB.round_id]🎃<br><h1>[episode_title]</h1></h1></center>"

/datum/credit/donators/halloween

/datum/credit/donators/halloween/New()
	var/list/donators = list()
	var/list/chunk = list()

	var/chunksize = 0

	for(var/client/client in GLOB.clients)
		if(!client.donator_level)
			continue
		if(client.holder)
			continue
		if(!length(donators))
			donators += "<hr>"
			donators += "<center><h1>Огромная благодарность меценатам:</h1></center>"

		chunk += "Лепрекону - [client.ckey] за [client.donator_level]-ый уровень подписки"
		chunksize++

		if(chunksize > 2)
			donators += "<center>[jointext(chunk,"<br>")]</center>"
			chunk.Cut()
			chunksize = 0

	if(length(chunk))
		donators += "<center>[jointext(chunk,"<br>")]</center>"

	content += donators


/datum/credit/crewlist/halloween

/datum/credit/crewlist/halloween/New()
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

		if(!length(cast) && !chunksize)
			cast += "<hr>"
			cast += "<center><h1>Актерская труппа:</h1></center>"
		chunk += "[human.real_name] в роли [uppertext(human.mind.assigned_role)]"
		chunksize++
		if(chunksize > 2)
			cast += "<center>[jointext(chunk,"<br>")]</center>"
			chunk.Cut()
			chunksize = 0

	if(length(chunk))
		cast += "<center>[jointext(chunk,"<br>")]</center>"

	content += cast

/datum/credit/corpses/halloween/New()
	var/list/corpses = list()

	for(var/mob/living/carbon/human/human in GLOB.dead_mob_list)
		if(!human.last_known_ckey)
			continue
		else if(human.real_name)
			corpses += human.real_name

	if(length(corpses))
		content += "<hr>"
		content += "<center><h1>Трупы:<br></h1></center>"
		while(length(corpses) > 10)
			content += "<center>[jointext(corpses, ", ", 1, 10)],</center>"
			corpses.Cut(1, 10)

		if(length(corpses))
			content += "<center>[jointext(corpses, ", ")].</center>"

/datum/credit/staff/halloween

/datum/credit/staff/halloween/New()
	var/list/staff = list()
	var/list/chunk = list()
	var/list/goodboys = list()
	var/list/staffjobs = file2list("config/credits/jobs/halloweenstaffjobs.txt")

	staffjobs.Remove("")

	var/chunksize = 0

	for(var/client/client in GLOB.clients)
		if(!client.holder)
			continue
		if(!length(staff))
			staff += "<hr>"
			staff += "<center><h1>Живые трупы:</h1></center>"

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
		content += "<center><h1>Духи:<br></h1>[english_list(goodboys, and_text = " и ")]</center><br>"

/atom/movable/screen/credit/halloween
	icon = 'modular_ss220/credits/icons/logo.dmi'
	icon_state = "halloween"
	screen_loc = "CENTER - 2,CENTER + 1"
	appearance_flags = NO_CLIENT_COLOR | TILE_BOUND | PIXEL_SCALE
	alpha = 255

/atom/movable/screen/credit/halloween/Initialize(mapload, credited, list/client/clients)
	. = ..()

	plane++

	transform = transform.Scale(1.5)

	SpinAnimation(5 SECONDS, 1, 1, 20, TRUE)

	var/matrix/matrix = matrix(transform)
	transform = transform.Translate(-8 * world.icon_size, 0)
	animate(src, transform = matrix, time = 5 SECONDS, flags = ANIMATION_PARALLEL)

/atom/movable/screen/credit/halloween/rollem()
	var/matrix/matrix = matrix(transform)
	matrix.Translate(0, SScredits.credit_animate_height)
	animate(src, transform = matrix, time = SScredits.credit_roll_speed)
	addtimer(CALLBACK(src, PROC_REF(delete_credit)), SScredits.credit_roll_speed, TIMER_CLIENT_TIME)

#define CREDITS_PLANE 29

/datum/credits
	var/list/credits = list()
	var/list/screen_credits = list()

	var/playing_time
	var/delay_time = 5 SECONDS

	var/credit_roll_speed = 22 SECONDS
	var/credit_spawn_speed = 2 SECONDS
	var/credit_animate_height

	var/soundtrack

/datum/credits/New()
	. = ..()

	credit_animate_height = 16 * world.icon_size
	var/list/title_musics = file2list("config/credits/sounds/title_music.txt")
	title_musics.Remove("")

	soundtrack = pick(title_musics)

	fill_credits()

	count_time()


/datum/credits/proc/fill_credits()
	return

/datum/credits/proc/count_time()
	playing_time += delay_time

	for(var/datum/credit/credit in credits)
		for(var/title in credit.content)
			playing_time += credit_spawn_speed

	playing_time -= credit_spawn_speed
	playing_time += credit_roll_speed

/datum/credits/proc/roll_credits_for_clients(list/client/clients)
	for(var/client/client in clients)
		LAZYINITLIST(client.credits)

	var/atom/movable/screen/text/credit/logo = new /atom/movable/screen/text/credit/logo(null, "", clients)
	screen_credits += logo

	addtimer(CALLBACK(src, PROC_REF(start_rolling_credits_for_clients), clients), delay_time)

/datum/credits/proc/start_rolling_credits_for_clients(list/client/clients)
	addtimer(CALLBACK(src, PROC_REF(start_rolling_logo)), SScredits.credit_roll_speed / 2.5)

	for(var/datum/credit/credit in credits)
		for(var/item in credit.content)
			start_rolling_credit_item(clients, item)
			sleep(SScredits.credit_spawn_speed)

	addtimer(CALLBACK(src, PROC_REF(clear_credits_for_clients), clients), SScredits.credit_roll_speed)

/datum/credits/proc/start_rolling_logo()
	var/atom/movable/screen/text/credit/logo/logo = screen_credits[1]
	logo.rollem()

/datum/credits/proc/start_rolling_credit_item(list/client/clients, credit_item)
	var/atom/movable/screen/text/credit/title = new(null, credit_item, clients)
	screen_credits += title

	title.rollem()

/datum/credits/proc/clear_credits_for_clients(list/client/clients)
	screen_credits.Cut()

	for(var/client/client in clients)
		if(!client?.credits)
			continue

		SScredits.clear_credits(client)

	SScredits.current_cinematic = null

/datum/credits/default

/datum/credits/default/fill_credits()
	credits += new /datum/credit/episode_title()
	credits += new /datum/credit/streamers()
	credits += new /datum/credit/donators()
	credits += new /datum/credit/crewlist()
	credits += new /datum/credit/corpses()
	credits += new /datum/credit/staff()
	credits += new /datum/credit/disclaimer()

/datum/credits/debug_large_credits

/datum/credits/debug_large_credits/fill_credits()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()
	credits += new /datum/credit/disclaimer()

/datum/credit
	var/list/content = list()

/datum/credit/episode_title

/datum/credit/episode_title/New()
	. = ..()

	var/episode_title = ""

	var/list/titles = list()

	titles["finished"] = file2list("config/credits/titles/finished_titles.txt")
	titles["crews_learns"] = file2list("config/credits/titles/random_titles_crews_learns.txt")
	titles["neuter_2_1"] = file2list("config/credits/titles/random_titles_neuter_2_1.txt")
	titles["neuter_2_2"] = file2list("config/credits/titles/random_titles_neuter_2_2.txt")
	titles["plural_2_1"] = file2list("config/credits/titles/random_titles_plural_2_1.txt")
	titles["plural_2_2"] = file2list("config/credits/titles/random_titles_plural_2_2.txt")

	for(var/possible_titles in titles)
		LAZYREMOVEASSOC(titles, possible_titles, "")

	switch(rand(1,100))
		if(1 to 10)
			episode_title += pick(titles["finished"])
		if(11 to 30)
			episode_title += "ЭКИПАЖ УЗНАЕТ О " + pick(titles["crews_learns"])
		if(31 to 60)
			episode_title += "[pick(titles["neuter_2_1"])] [pick(titles["neuter_2_2"])]"
		if(61 to 100)
			episode_title += "[pick(titles["plural_2_1"])] [pick(titles["plural_2_2"])]"

	content += "<center><h1>EPISODE [GLOB.round_id]</h1></center>"
	content += "<center><h1>[episode_title]</h1></center>"

/datum/credit/streamers

/datum/credit/streamers/New()
	. = ..()

	var/list/streamers

	streamers = GLOB.configuration.admin.use_database_admins ? database_streamers_list() : no_database_streamers_list()

	if(length(streamers))
		content += "<hr>"
		content += "<center><h1><br>Приглашенн[length(streamers) > 1 ? "ые звезды" : "ая звезда"]:<br></h1>[jointext(streamers, "<br>")]</center>"

/datum/credit/streamers/proc/database_streamers_list()
	if(!SSdbcore.IsConnected())
		return

	var/datum/db_query/ranks_ckey_read = SSdbcore.NewQuery(
		"SELECT ckey FROM admin WHERE admin_rank=:rank OR admin_rank=:rank1 OR admin_rank=:rank2 OR admin_rank=:rank3",
			list(
				"rank" = "Банда",
				"rank1" = "Братюня",
				"rank2" = "Максон",
				"rank3" = "Сестрюня"
			))

	if(!ranks_ckey_read.warn_execute())
		qdel(ranks_ckey_read)
		return

	var/list/streamers = list()

	while(ranks_ckey_read.NextRow())
		var/client/client = get_client_by_ckey(ranks_ckey_read.item[1])
		if(!client?.mob?.name)
			continue
		streamers += "<center>([client.mob.name]) a.k.a. ([client.ckey])<center>"

	qdel(ranks_ckey_read)

	return streamers

/datum/credit/streamers/proc/no_database_streamers_list()
	var/list/streamers = list()

	for(var/iterator_key in GLOB.configuration.admin.ckey_rank_map)
		if(!(GLOB.configuration.admin.ckey_rank_map[iterator_key] == "Банда"))
			continue

		var/ckey = ckey(iterator_key)
		var/client/client = get_client_by_ckey(ckey)
		if(!client)
			continue
		streamers += "<center>[client.mob.name] a.k.a. ([ckey])<center>"

	return streamers

/datum/credit/donators

/datum/credit/donators/New()
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
			donators += "<center><h1>Огромная благодарность меценатам:</h1></center>"

		chunk += "[client.ckey] за [client.donator_level]-ый уровень подписки"
		chunksize++

		if(chunksize > 2)
			donators += "<center>[jointext(chunk,"<br>")]</center>"
			chunk.Cut()
			chunksize = 0

	if(length(chunk))
		donators += "<center>[jointext(chunk,"<br>")]</center>"

	content += donators


/datum/credit/crewlist

/datum/credit/crewlist/New()
	. = ..()

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
			cast += "<center><h1>В съемках участвовали:</h1></center>"
		chunk += "[human.real_name] в роли [uppertext(human.mind.assigned_role)]"
		chunksize++
		if(chunksize > 2)
			cast += "<center>[jointext(chunk,"<br>")]</center>"
			chunk.Cut()
			chunksize = 0

	if(length(chunk))
		cast += "<center>[jointext(chunk,"<br>")]</center>"

	content += cast

/datum/credit/corpses_debug

/datum/credit/corpses_debug/New()
	. = ..()

	var/list/corpses = list()

	for(var/mob/living/carbon/human/human in GLOB.mob_living_list)
		if(!human.last_known_ckey)
			continue
		else if(human.real_name)
			for(var/i = 0, i < 50, i++)
				corpses += human.real_name

	if(length(corpses))
		content += "<hr>"
		content += "<center><h1>Основано на реальных событиях:<br></h1><h1>В память о</h1></center>"
		while(length(corpses) > 10)
			content += "<center>[jointext(corpses, ", ", 1, 10)],</center>"
			corpses.Cut(1, 10)

		if(length(corpses))
			content += "<center>[jointext(corpses, ", ")]</center>"



/datum/credit/corpses/New()
	. = ..()

	var/list/corpses = list()

	for(var/mob/living/carbon/human/human in GLOB.dead_mob_list)
		if(!human.last_known_ckey)
			continue
		else if(human.real_name)
			corpses += human.real_name

	if(length(corpses))
		content += "<hr>"
		content += "<center><h1>Основано на реальных событиях:<br></h1><h1>В память о</h1></center>"
		while(length(corpses) > 10)
			content += "<center>[jointext(corpses, ", ", 1, 10)],</center>"
			corpses.Cut(1, 10)

		if(length(corpses))
			content += "<center>[jointext(corpses, ", ")].</center>"


/datum/credit/staff

/datum/credit/staff/New()
	var/list/staff = list()
	var/list/chunk = list()
	var/list/goodboys = list()
	var/list/staffjobs = file2list("config/credits/jobs/staffjobs.txt")

	staffjobs.Remove("")

	var/chunksize = 0

	for(var/client/client in GLOB.clients)
		if(!client.holder)
			continue
		if(!length(staff))
			staff += "<hr>"
			staff += "<center><h1>Съемочная группа:</h1></center>"

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
		content += "<center><h1>Мальчики на побегушках:<br></h1>[english_list(goodboys, and_text = " и " )]</center><br>"

/datum/credit/disclaimer

/datum/credit/disclaimer/New()
	. = ..()

	var/disclaimer = "<br>Sponsored by WYCCSTATION.<br>All rights reserved.<br>\
					This motion picture is protected under the copyright laws of the Sol Central Government<br> and other nations throughout the galaxy.<br>\
					Colony of First Publication: [pick("Mars", "Luna", "Earth", "Venus", "Phobos", "Ceres", "Tiamat", "Ceti Epsilon", "Eos", "Pluto", "Ouere",\
					"Tadmor", "Brahe", "Pirx", "Iolaus", "Saffar", "Gaia")].<br>"
	disclaimer += pick("Use for parody prohibited. PROHIBITED.",
						"All stunts were performed by underpaid interns. Do NOT try at home.",
						"WYCCSTATION does not endorse behaviour depicted. Attempt at your own risk.",
						"No animals were harmed in the making of this motion picture except for those listed previously as dead. Do not try this at home.")
	content += "<hr>"
	content += "<center><span style='font-size:6pt;'>[jointext(disclaimer, null)]</span><br></center>"

/atom/movable/screen/text/credit
	mouse_opacity = 0
	alpha = 255
	screen_loc = "CENTER-7,CENTER-7"
	plane = CREDITS_PLANE

	var/list/client/watchers = list()

/atom/movable/screen/text/credit/Initialize(mapload, credited, list/client/clients)
	. = ..()

	for(var/client/watcher in clients)
		if(!watcher)
			continue
		if(!watcher.credits)
			continue
		watcher.credits += src
		watcher.screen += src
		watchers += watcher


	maptext = {"<div style="font:'Courier New'">[credited]</div>"}
	maptext_height = world.icon_size * 2
	maptext_width = world.icon_size * 14

/atom/movable/screen/text/credit/proc/rollem()
	var/matrix/matrix = matrix(transform)
	transform = matrix.Translate(0, -world.icon_size)

	matrix.Translate(0, SScredits.credit_animate_height)
	animate(src, transform = matrix, time = SScredits.credit_roll_speed)
	addtimer(CALLBACK(src, PROC_REF(delete_credit)), SScredits.credit_roll_speed, TIMER_CLIENT_TIME)

/atom/movable/screen/text/credit/proc/delete_credit()
	if(!QDELETED(src))
		qdel(src)

/atom/movable/screen/text/credit/Destroy()
	for(var/client/watcher in watchers)
		if(!watcher)
			continue
		watcher.screen -= src
		LAZYREMOVE(watcher.credits, src)

	watchers.Cut()

	return ..()

/atom/movable/screen/text/credit/logo
	icon = 'modular_ss220/credits/icons/logo.dmi'
	icon_state = "ss220"
	screen_loc = "CENTER - 2,CENTER"
	alpha = 100


/atom/movable/screen/text/credit/logo/Initialize(mapload, credited, list/client/clients)
	. = ..()
	animate(src, alpha = 220, time = 3 SECONDS)
	maptext = "<center><h1>Playing music - [SScredits.title_music]</h1></center>"
	maptext_height = 10 * world.icon_size
	maptext_x -= 5 * world.icon_size
	maptext_y += 6 * world.icon_size

/atom/movable/screen/text/credit/logo/rollem()
	var/matrix/matrix = matrix(transform)
	matrix.Translate(0, SScredits.credit_animate_height)
	animate(src, transform = matrix, time = SScredits.credit_roll_speed)
	addtimer(CALLBACK(src, PROC_REF(delete_credit)), SScredits.credit_roll_speed, TIMER_CLIENT_TIME)

/client
	var/list/credits

#undef CREDITS_PLANE

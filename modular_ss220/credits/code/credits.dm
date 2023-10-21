#define CREDITS_PLANE 26

/datum/credits
	var/list/credits = list()

	var/playing_time
	var/delay_time = 5 SECONDS

	var/credit_roll_speed = 22 SECONDS
	var/credit_spawn_speed = 2 SECONDS
	var/credit_animate_height

	var/soundtrack

/datum/credits/New()
	. = ..()

	credit_animate_height = 16 * world.icon_size

	soundtrack = pick(file2list("config/credits/sounds/title_music.txt"))

	fill_credits()

	count_time()


/datum/credits/proc/fill_credits()

/datum/credits/proc/count_time()
	playing_time += delay_time

	for(var/datum/credit/credit in credits)
		for(var/title in credit.content)
			playing_time += credit_spawn_speed

	playing_time -= credit_spawn_speed
	playing_time += credit_roll_speed

/datum/credits/proc/roll_credits_for_clients(list/clients)
	for(var/client/client in clients)
		setup_credits_for_client(client)

	addtimer(CALLBACK(src, PROC_REF(start_rolling_credits_for_clients), clients), delay_time)

/datum/credits/proc/setup_credits_for_client(client/client)
	LAZYINITLIST(client.credits)

	var/obj/screen/credit/logo = new /obj/screen/credit/logo(null, "", client)

	client.credits += logo

/datum/credits/proc/start_rolling_credits_for_clients(list/clients)
	addtimer(CALLBACK(src, PROC_REF(start_rolling_logo_for_clients), clients,), SScredits.credit_roll_speed / 2.5)

	for(var/datum/credit/credit in credits)
		for(var/item in credit.content)
			start_rolling_credit_item(clients, item)
			sleep(SScredits.credit_spawn_speed)

	addtimer(CALLBACK(src, PROC_REF(clear_credits_for_clients), clients), SScredits.credit_roll_speed)

/datum/credits/proc/start_rolling_logo_for_clients(list/clients)
	for(var/client/client in clients)
		if(!client?.credits)
			continue

		var/obj/screen/credit/logo/logo = client.credits[1]
		logo.rollem()

/datum/credits/proc/start_rolling_credit_item(list/clients, credit_item)
	for(var/client/client in clients)
		if(!client?.credits)
			continue

		var/obj/screen/credit/title = new(null, credit_item, client)
		client.credits += title
		title.rollem()

/datum/credits/proc/clear_credits_for_clients(list/clients)
	for(var/client/client in clients)
		if(!client?.credits)
			continue

		SScredits.clear_credits(client)


/datum/credits/default

/datum/credits/default/fill_credits()
	credits += new /datum/credit/episode_title()
	credits += new /datum/credit/streamers()
	credits += new /datum/credit/crewlist()
	credits += new /datum/credit/corpses()
	credits += new /datum/credit/staff()
	credits += new /datum/credit/disclaimer()

/datum/credits/debug_large_credits

/datum/credits/debug_large_credits/fill_credits()
	. = ..()

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

	content += "<center><h1>EPISODE [GLOB.round_id]<br><h1>[episode_title]</h1></h1></center>"

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
		"SELECT admin_rank, ckey FROM admin WHERE admin_rank=:rank",
			list("rank" = "Банда"))

	if(!ranks_ckey_read.warn_execute())
		qdel(ranks_ckey_read)
		return

	var/list/streamers = list()

	while(ranks_ckey_read.NextRow())
		var/client/client = get_client_by_ckey(ranks_ckey_read.item[2])
		if(!client.mob?.name)
			continue
		streamers += "<center>[client.mob.name])] a.k.a. ([client.ckey])<center>"

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

/datum/credit/enormeus_crewlist_debug

/datum/credit/enormeus_crewlist_debug/New()
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

		for(var/i = 0, i < 100, i++)
			if(!length(cast) && !chunksize)
				cast += "<hr>"
				chunk += "<h1>В съемках участвовали:</h1>"
			chunk += "[human.real_name] в роли [uppertext(human.mind.assigned_role)]"
			chunksize++
			if(chunksize > 2)
				cast += "<center>[jointext(chunk,"<br>")]</center>"
				chunk.Cut()
				chunksize = 0

	if(length(chunk))
		cast += "<center>[jointext(chunk,"<br>")]</center>"

	content += cast

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

		if(!length(cast) && !chunksize)
			cast += "<hr>"
			chunk += "<h1>В съемках участвовали:</h1>"
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
	. = ..()

	var/list/staff = list()
	var/list/staffjobs = file2list("config/credits/jobs/staffjobs.txt")
	var/list/goodboys = list()
	for(var/client/client in GLOB.clients)
		if(!client.holder)
			continue

		if(check_rights_client(R_DEBUG|R_ADMIN|R_MOD, FALSE, client))
			staff += "[uppertext(pick(staffjobs))] - '[client.key]'"
		else if(check_rights_client(R_MENTOR, FALSE, client))
			goodboys += "[client.key]"

	if(length(staff))
		content += "<center><h1>Съемочная группа:<br></h1></center>"
		content += "<center>[jointext(staff,"<br>")]<br></center>"

	if(length(goodboys))
		content += "<center><h1>Мальчики на побегушках:<br></h1>[english_list(goodboys)]</center><br>"

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

/obj/screen/credit
	icon_state = "blank"
	mouse_opacity = 0
	alpha = 255
	screen_loc = "CENTER-7,CENTER-7"
	plane = CREDITS_PLANE

	var/client/parent

/obj/screen/credit/Initialize(mapload, credited, client/client)
	. = ..()

	parent = client
	maptext = {"<div style="font:'Small Fonts'">[credited]</div>"}
	maptext_height = world.icon_size * 2
	maptext_width = world.icon_size * 14

/obj/screen/credit/proc/rollem()
	var/matrix/matrix = matrix(transform)
	transform = matrix.Translate(0, -world.icon_size)

	matrix.Translate(0, SScredits.credit_animate_height)
	animate(src, transform = matrix, time = SScredits.credit_roll_speed)
	addtimer(CALLBACK(src, PROC_REF(delete_credit)), SScredits.credit_roll_speed, TIMER_CLIENT_TIME)
	parent.screen += src

/obj/screen/credit/proc/delete_credit()
	if(!QDELETED(src))
		qdel(src)

/obj/screen/credit/Destroy()
	if(parent)
		parent.screen -= src
		LAZYREMOVE(parent.credits, src)
		parent = null
	return ..()

/obj/screen/credit/logo
	icon = 'modular_ss220/credits/icons/logo.dmi'
	icon_state = "ss220"
	screen_loc = "CENTER - 2,CENTER"
	alpha = 100


/obj/screen/credit/logo/Initialize(mapload, credited, client/client)
	. = ..()
	animate(src, alpha = 220, time = 3 SECONDS)
	parent.screen += src

/obj/screen/credit/logo/rollem()
	var/matrix/matrix = matrix(transform)
	matrix.Translate(0, SScredits.credit_animate_height)
	animate(src, transform = matrix, time = SScredits.credit_roll_speed)
	addtimer(CALLBACK(src, PROC_REF(delete_credit)), SScredits.credit_roll_speed, TIMER_CLIENT_TIME)

/client/var/list/credits

#undef CREDITS_PLANE

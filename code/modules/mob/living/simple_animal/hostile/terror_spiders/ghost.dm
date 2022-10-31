
/mob/living/simple_animal/hostile/poison/terror_spider/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			humanize_spider(ghost)

/mob/living/simple_animal/hostile/poison/terror_spider/attack_ghost(mob/user)
	humanize_spider(user)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/humanize_spider(mob/user)
	if(key)//Someone is in it
		return
	var/error_on_humanize = ""
	var/humanize_prompt = "Take direct control of [src]?"
	humanize_prompt += " Role: [spider_role_summary]"
	if(user.ckey in GLOB.ts_ckey_blacklist)
		error_on_humanize = "You are not able to control any terror spider this round."
	else if(cannotPossess(user))
		error_on_humanize = "You have enabled antag HUD and are unable to re-enter the round."
	else if(!ai_playercontrol_allowtype)
		error_on_humanize = "This specific type of terror spider is not player-controllable."
	else if(degenerate)
		error_on_humanize = "Dying spiders are not player-controllable."
	else if(stat == DEAD)
		error_on_humanize = "Dead spiders are not player-controllable."
	else if(!(user in GLOB.respawnable_list))
		error_on_humanize = "You are not able to rejoin the round."
	if(jobban_isbanned(user, ROLE_SYNDICATE) || jobban_isbanned(user, ROLE_TSPIDER))
		to_chat(user, "<span class='warning'>You are jobbanned from role of syndicate and/or terror spider.</span>")
		return
	if(error_on_humanize == "")
		var/spider_ask = alert(humanize_prompt, "Join as Terror Spider?", "Yes", "No")
		if(spider_ask == "No" || !src || QDELETED(src))
			return
	else
		to_chat(user, "Cannot inhabit spider: [error_on_humanize]")
		return
	if(key)
		to_chat(user, "<span class='notice'>Someone else already took this spider.</span>")
		return
	key = user.key
	to_chat(src, "<b><font size=3 color='red'>You are a Terror Spider!</font></b>")
	to_chat(src, "Work with other terror spiders in your hive to eliminate the crew and claim the station as your nest!")
	to_chat(src, "<b>Remember to follow the orders of higher tier spiders, such as the princess or queen.</b>")
	to_chat(src, "Most terror spiders can lay webs to block off areas of the station, which will also incapacitate anyone that walks into them. These webs will also have unique attributes depending on what kind of terror spider you are.")
	to_chat(src, "All terror spiders can wrap corpses to improve health regeneration, with green terror spiders also relying on wrapping corpses to produce more eggs. You must be adjacent or on top of a corpse to wrap it.")
	to_chat(src, "<span class='specialnotice'>[spider_intro_text]</span>")
	to_chat(src, "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Terror_Spider)</span>")
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.show_message("<i>A ghost has taken control of <b>[src]</b>. ([ghost_follow_link(src, ghost=G)]).</i>")

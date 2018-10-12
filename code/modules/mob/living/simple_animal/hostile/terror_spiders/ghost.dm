
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
	if(user.ckey in ts_ckey_blacklist)
		error_on_humanize = "You are not able to control any terror spider this round."
	else if(cannotPossess(user))
		error_on_humanize = "You have enabled antag HUD and are unable to re-enter the round."
	else if(spider_awaymission)
		error_on_humanize = "Terror spiders that are part of an away mission cannot be controlled by ghosts."
	else if(!ai_playercontrol_allowtype)
		error_on_humanize = "This specific type of terror spider is not player-controllable."
	else if(degenerate)
		error_on_humanize = "Dying spiders are not player-controllable."
	else if(stat == DEAD)
		error_on_humanize = "Dead spiders are not player-controllable."
	if(jobban_isbanned(user, "Syndicate") || jobban_isbanned(user, "alien"))
		to_chat(user,"You are jobbanned from role of syndicate and/or alien lifeform.")
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
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.show_message("<i>A ghost has taken control of <b>[src]</b>. ([ghost_follow_link(src, ghost=G)]).</i>")
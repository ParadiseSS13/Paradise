
/mob/living/simple_animal/hostile/poison/terror_spider/verb/ShowGuide()
	set name = "Show Guide"
	set category = "Spider"
	set desc = "Learn how to spider."
	to_chat(src, "------------------------")
	to_chat(src, "Intro:")
	to_chat(src, "- Terror Spiders are a bioweapon, created when the Syndicate mixed Giant Spider and Xenomorph DNA.")
	to_chat(src, "- Ruled by Queens, they are aggressive, and very good in melee combat.")
	to_chat(src, " ")
	to_chat(src, "Communications:")
	to_chat(src, "<B>- You speak over the Terror Spider hivemind by default. All other TS hear this. To speak common, use :9 or .9 </B>")
	to_chat(src, "- Terror Spiders are the nuke ops of spiders. They work as a team. Communicate regularly!")
	to_chat(src, " ")
	to_chat(src, "Verbs:")
	to_chat(src, " - Show Guide - Shows this guide.")
	to_chat(src, " - Show Orders - Tells you how aggressive/defensive you should be. Queens can change this.")
	to_chat(src, " - Web - Spins a terror web. Non-spiders get trapped if they touch a web.")
	to_chat(src, " - Eat Corpse - Eat the corpse of a dead foe to boost your regeneration")
	to_chat(src, " - Suicide - Safely removes you from the round.")
	to_chat(src, "------------------------")
	to_chat(src, " ")

/mob/living/simple_animal/hostile/poison/terror_spider/verb/ShowOrders()
	set name = "Show Orders"
	set category = "Spider"
	set desc = "Find out what your orders are (from your queen or otherwise)."
	DoShowOrders()




/mob/living/simple_animal/hostile/poison/terror_spider/verb/Web()
	set name = "Lay Web"
	set category = "Spider"
	set desc = "Spin a sticky web to slow down prey."
	var/T = loc
	if (busy != SPINNING_WEB)
		busy = SPINNING_WEB
		visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
		stop_automated_movement = 1
		spawn(40)
			if (busy == SPINNING_WEB && loc == T)
				new /obj/effect/spider/terrorweb(T)
			busy = 0
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/terror_spider/verb/EatCorpse()
	set name = "Eat Corpse"
	set category = "Spider"
	set desc = "Takes a bite out of a humanoid. Increases regeneration. Use on dead bodies is preferable!"
	var/choices = list()
	for(var/mob/living/L in view(1,src))
		if (L == src)
			continue
		if (L in nibbled)
			continue
		if (Adjacent(L))
			if (L.stat != CONSCIOUS)
				choices += L
	var/nibbletarget = input(src,"What do you wish to nibble?") in null|choices
	if (!nibbletarget)
		// cancel
	else if (!isliving(nibbletarget))
		to_chat(src, "[nibbletarget] is not edible.")
	else if (nibbletarget in nibbled)
		to_chat(src, "You have already eaten some of [nibbletarget]. Their blood is no use to you now.")
	else
		nibbled += nibbletarget
		regen_points += regen_points_per_kill
		to_chat(src, "You take a bite out of [nibbletarget], boosting your regeneration for awhile.")
		src.do_attack_animation(nibbletarget)
		if (spider_debug)
			to_chat(src, "You now have " + num2text(regen_points) + " regeneration points.")


/mob/living/simple_animal/hostile/poison/terror_spider/verb/KillMe()
	set name = "Suicide"
	set category = "Spider"
	set desc = "Kills you, and spawns a spiderling. Use this if you need to leave the round for a considerable time."
	if (spider_tier == 5)
		visible_message("<span class='danger'> [src] summons a bluespace portal, and steps into it. She has vanished!</span>")
		qdel(src)
	else if (spider_tier >= 3)
		to_chat(src, "Your type of spider is too important to the round to be allowed to suicide. Instead, you will be ghosted, and the spider controlled by AI.")
		ts_ckey_blacklist += ckey
		ghostize()
		ckey = null
	else
		visible_message("<span class='notice'>\the [src] awakens the remaining eggs in its body, which hatch and start consuming it from the inside out!</span>")
		spawn(50)
			if (health > 0)
				var/obj/effect/spider/spiderling/terror_spiderling/S = new /obj/effect/spider/spiderling/terror_spiderling(get_turf(src))
				S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray, /mob/living/simple_animal/hostile/poison/terror_spider/green)
				if (spider_tier == 2)
					S.grow_as = src.type
				S.faction = faction
				S.spider_myqueen = spider_myqueen
				S.master_commander = master_commander
				S.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
				S.enemies = enemies
				ts_ckey_blacklist += ckey
				death()
				gib()


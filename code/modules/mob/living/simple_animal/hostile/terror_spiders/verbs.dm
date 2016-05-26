
/mob/living/simple_animal/hostile/poison/terror_spider/verb/ShowGuide()
	set name = "Show Guide"
	set category = "Spider"
	set desc = "Learn how to spider."
	// T4
	to_chat(src, "------------------------")
	// T1
	to_chat(src, "Basic Guide:")
	to_chat(src, "- Terror Spiders are a bioweapon that escaped their creators.")
	// T1
	if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/red))
		to_chat(src, "- You are the red terror spider.")
		to_chat(src, "- A straightforward fighter, you have high health, and high melee damage, but are slow-moving.")
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/gray))
		to_chat(src, "- You are the gray terror spider.")
		to_chat(src, "- You are an ambusher. Springing out of vents, you hunt unequipped and vulnerable humanoids.")
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/green))
		to_chat(src, "- You are the green terror spider.")
		to_chat(src, "- You are a breeding spider. Only average in combat, you can (and should) use 'Wrap' on any dead humaniod you kill, or see. These eggs will hatch into more spiders!")
	// T2
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/black))
		to_chat(src, "- You are the black terror spider.")
		to_chat(src, "- You are an assassin. Even 2-3 bites from you is fatal to organic humanoids - if you back off and let your poison work. You are very vulnurable to borgs.")
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/purple))
		to_chat(src, "- You are the purple terror spider.")
		to_chat(src, "- You guard the nest of the all important Terror Queen! You are very robust, with a chance to stun on hit, but should stay with the queen at all times.")
		to_chat(src, "- <b>If the queen dies, you die!</b>")
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/white))
		to_chat(src, "- You are the white terror spider.")
		to_chat(src, "- Amongst the most feared of all terror spiders, your multi-stage bite attack injects tiny spider eggs into a host, which will make spiders grow out of their skin in time.")
		to_chat(src, "- You should advance quickly, attack three times, then retreat, letting your venom of tiny eggs do its work.")
		to_chat(src, "- <span class='notice'>Your main objective is to infect humanoids with your egg venom, so that you can start a hive.</span>")
		to_chat(src, "- <span class='notice'>Once the hive has started, they will look to you for leadership.</span>")
	// T3
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/prince))
		to_chat(src, "- You are the Prince of Terror!")
		to_chat(src, "- A ferocious warrior, you wander the stars, identifying potential nest sites, and threats, for your fellow Terror Spiders.")
		to_chat(src, "- You have been sent to this remote station to determine if it would make a suitable nest.")
		to_chat(src, "- <b>You have lots of health, and decent attacks, but can be killed by a well-armed group.</b>")
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/mother))
		to_chat(src, "- You are the Mother of Terror!")
		to_chat(src, "- A form of living schmuck bait, you are fairly harmless while alive.")
		to_chat(src, "- <b>If you die, dozens of spiderlings will come swarming off your back, infesting the whole station.</b>")
	// T4
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/queen))
		to_chat(src, "- You are the Queen of Terror!")
		to_chat(src, "- Your goal is to build a nest, Lay Eggs to make more spiders, and ultimately exterminate all non-spider life on the station!")
		to_chat(src, "- You can use HiveCommand to issue orders to your spiders (both AI, and player-controlled)!")
		to_chat(src, "- The success or failure of the entire hive depends on you, so whatever you do, <b>do not die!</b>")
		to_chat(src, "- To start, find a safe, dark location to nest in, then lay some purple (praetorian) eggs so you will have guards to defend you.")
	// T5
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/empress))
		to_chat(src, "- You are the Empress of Terror!")
		to_chat(src, "- ICly, you are an aged and battle-hardened Queen, and one of the rulers of the Terror Spider species.")
		to_chat(src, "- You outrank ALL other spiders and may execute any spider who dares question your authority.")
		to_chat(src, "- OOCly, Empresses are used by coders (to test), senior admins (to run events) and normal admins (to act as higher authority for spiders, similar to how CC is for crew).")
		to_chat(src, "- Your abilities are game-breakingly OP, and should NOT be used lightly. You are a terrifying lovecraftian spider from the depths of space. Act like it.")
	to_chat(src, " ")
	to_chat(src, "<B>You speak over the Terror Spider hivemind by default. To speak common, use :9 or .9 </B>")
	to_chat(src, " ")
	to_chat(src, "Standard Verbs:")
	to_chat(src, " - Show Guide - Shows this guide.")
	to_chat(src, " - Show Orders - Tells you how aggressive/defensive you should be.")
	to_chat(src, " - Web - Spins a terror web. Non-spiders get trapped if they touch a web.")
	to_chat(src, " - Eat Corpse - Eat the corpse of a dead foe to boost your regeneration")
	to_chat(src, " - Suicide - Removes you from the round, safely.")
	to_chat(src, " ")
	if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/green))
		to_chat(src, "Green Terror Verbs:")
		to_chat(src, " - Wrap - Wraps up adjacent, dead prey, and drinks their blood, allowing you to lay eggs.")
		to_chat(src, " - Lay Green Eggs - Lays eggs that hatch into new spiders.")
		to_chat(src, " ")
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/queen))
		to_chat(src, "Queen of Terror Verbs:")
		to_chat(src, " - HiveSense - Shows the names, statuses and locations of your brood's spiders.")
		to_chat(src, " - HiveCommand - Sets the rules of engagement for your brood - IE if they should attack bipeds or not.")
		to_chat(src, " - Kill Spider - Gibs a spider standing next to you. Can only be used once.")
		to_chat(src, " - Lay Queen Eggs - Lays eggs. Your BEST ability as Queen.")
		to_chat(src, " - Wrap - Wraps an object or corpse in a cocoon. Generally better left to greens.")
		to_chat(src, " - Hallucinate - Causes a random crew member on the same Z-level to start to hallucinate.")
		to_chat(src, " - Queen Screech - Breaks lights over a wide area. Can only be used once.")
		to_chat(src, " - Fake Spiderlings - Creates many spiderlings that don't grow up, but do sow terror amongst crew.")
		to_chat(src, " ")
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/empress))
		to_chat(src, "Empress of Terror Verbs:")
		to_chat(src, " - Empress Eggs - Lay eggs of any type.")
		to_chat(src, " - HiveSense - Shows the names, statuses and locations of your brood's spiders.")
		to_chat(src, " - HiveCommand - Sets the rules of engagement for your brood - IE if they should attack bipeds or not.")
		to_chat(src, " - EMP Shockwave - Emits a large emp shockwave (radius: 10 light, 25 heavy)")
		to_chat(src, " - Empress Screech - Breaks all lights and cameras within a 14 tile radius.")
		to_chat(src, " - Mass Hallucinate - Causes all crew to have a 25% chance of strong hallucination, 25% chance of weak hallucination.")
		to_chat(src, " - Empress Kill Spider - Remotely gibs any spider, no matter their location.")
		to_chat(src, " - Erase Brood - Kills off every other spider in the game world, over the course of about two minutes.")
		to_chat(src, " - Spiderling Flood - Spawns N spiderlings. Very configurable. Almost instant station-destroyer if used with high numbers.")
	DoShowOrders()
	to_chat(src, "------------------------")

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
				var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
				S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray, /mob/living/simple_animal/hostile/poison/terror_spider/green)
				if (spider_tier == 2)
					S.grow_as = src.type
				S.faction = faction
				S.spider_myqueen = spider_myqueen
				S.master_commander = master_commander
				S.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
				S.enemies = enemies
				ts_ckey_blacklist += ckey
				loot = 0
				death()
				gib()



var/global/list/ts_ckey_blacklist = list()
var/global/ts_count_dead = 0
var/global/ts_count_alive_awaymission = 0
var/global/ts_count_alive_station = 0
var/global/ts_death_last = 0
var/global/ts_death_window = 9000 // 15 minutes
var/global/list/ts_spiderlist = list()
var/global/list/ts_egg_list = list()
var/global/list/ts_spiderling_list = list()

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: DEFAULTS ---------------------------------
// --------------------------------------------------------------------------------
// Because: http://tvtropes.org/pmwiki/pmwiki.php/Main/SpidersAreScary

/mob/living/simple_animal/hostile/poison/terror_spider/
	// Name / Description
	name = "terror spider"
	var/altnames = list()
	var/name_usealtnames = 0 // if 1, spiders use their randomized names, if not they're all "<color> terror"
	desc = "The generic parent of all other terror spider types. If you see this in-game, it is a bug."
	var/egg_name = "terror eggs"

	// Icons
	icon = 'icons/mob/terrorspider.dmi'
	icon_state = "terror_red"
	icon_living = "terror_red"
	icon_dead = "terror_red_dead"

	// Health
	maxHealth = 120
	health = 120

	// Melee attacks
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	poison_type = "" // we do not use that silly system.

	// Movement
	//anchored = 1 // stops people dragging them around -- requires testing *****
	move_to_delay = 6
	turns_per_move = 5
	pass_flags = PASSTABLE

	// Ventcrawling
	ventcrawler = 1 // allows player ventcrawling
	var/ai_ventcrawls = 1
	var/idle_ventcrawl_chance = 3 // default 3% chance to ventcrawl when not in combat to a random exit vent
	var/freq_ventcrawl_combat = 1800 // 3 minutes
	var/freq_ventcrawl_idle =  9000 // 15 minutes
	var/last_ventcrawl_time = -9000 // Last time the spider crawled. Used to prevent excessive crawling. Setting to freq*-1 ensures they can crawl once on spawn.

	// AI movement tracking
	var/spider_steps_taken = 0 // leave at 0, its a counter for ai steps taken.
	var/spider_max_steps = 15 // after we take X turns trying to do something, give up!

	// Speech
	speak_chance = 0 // quiet but deadly
	speak_emote = list("hisses")
	emote_hear = list("hisses")

	// Loot
	loot = list() // None by default.

	// Languages are handled in terror_spider/New()

	// Interaction keywords
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"

	// regeneration settings - overridable by child classes
	var/regen_points = 0 // number of regen points they have by default
	var/regen_points_max = 100 // max number of points they can accumulate
	var/regen_points_per_tick = 1 // gain one regen point per tick
	var/regen_points_per_kill = 100 // gain extra regen points if you kill something
	var/regen_points_per_hp = 2 // every X regen points = 1 health point you can regen
	// desired: 30hp/minute unmolested, 60hp/min on food boost, assuming one tick every 2 seconds
	//          100/kill means bonus 50hp/kill regenerated over the next 1-2 minutes

	var/degenerate = 0 // if 1, they slowly degen until they all die off. Used by high-level abilities only.

	// Vision
	idle_vision_range = 10
	aggro_vision_range = 10
	see_in_dark = 10
	nightvision = 1
	vision_type = new /datum/vision_override/nightvision/thermals/ling_augmented_eyesight
	see_invisible = 5

	// AI aggression settings
	var/ai_type = TS_AI_AGGRESSIVE // 0 = aggressive to everyone, 1 = defends self only, 2 = passive, you can butcher it like a sheep

	// AI player control by ghosts
	var/ai_playercontrol_allowingeneral = 1 // if 0, no spiders are player controllable. Default set in code, can be changed by queens.
	var/ai_playercontrol_allowtype = 1 // if 0, this specific class of spider is not player-controllable. Default set in code for each class, cannot be changed.

	var/ai_break_lights = 1 // AI lightbreaking behavior
	var/freq_break_light = 600 // one minute
	var/last_break_light = 0 // leave this, changed by procs.

	var/player_breaks_cameras = 1  // Toggle for players breaking cameras

	var/ai_spins_webs = 1 // AI web-spinning behavior
	var/freq_spins_webs = 600 // one minute
	var/last_spins_webs = 0 // leave this, changed by procs.

	var/ai_cocoons_object = 0 // AI object coccooning behavior, only used by greens
	var/freq_cocoon_object = 1200 // two minutes between each attempt
	var/last_cocoon_object = 0 // leave this, changed by procs.

	var/ai_hides_in_vents = 0 // AI vent hiding behavior, only used by purples.
	var/prob_ai_hides_in_vents = 10 // probabily of this code running on handle_automated_action

	var/spider_opens_doors = 1 // all spiders can open firedoors (they have no security). 1 = can open depowered doors. 2 = can open powered doors
	faction = list("terrorspiders")
	var/spider_awaymission = 0 // if 1, limits certain behavior in away missions
	var/spider_uo71 = 0 // if 1, spider is in the UO71 away mission
	var/spider_unlock_id_tag = "" // if defined, unlock awaymission blast doors with this tag on death
	var/spider_queen_declared_war = 0 // if 1, mobs more aggressive
	var/spider_role_summary = "UNDEFINED"
	var/spider_placed = 0

	// AI variables designed for use in procs
	var/atom/cocoon_target // for queen and nurse
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent // nearby vent they are going to try to get to, and enter
	var/obj/machinery/atmospherics/unary/vent_pump/exit_vent // remote vent they intend to come out of
	var/obj/machinery/atmospherics/unary/vent_pump/nest_vent // home vent, usually used by queens
	var/fed = 0
	var/travelling_in_vent = 0
	var/list/enemies = list()
	var/list/nibbled = list()
	var/path_to_vent = 0
	var/killcount = 0
	var/busy = 0 // leave this alone!
	var/spider_tier = 1 // 1 for red,gray,green. 2 for purple,black,white, 3 for prince, mother. 4 for queen, 5 for empress.
	var/hasdroppedloot = 0
	var/list/spider_special_drops = list()
	var/attackstep = 0
	var/attackcycles = 0
	var/spider_myqueen = null
	var/mylocation = null
	var/chasecycles = 0

	// Breathing, Pressure & Fire
	// - No breathing / cannot be suffocated (spiders can hold their breath, look it up)
	// - No pressure damage either - they have effectively exoskeletons
	// - HOWEVER they can be burned to death!
	// - Normal SPACE spiders should probably be immune to SPACE too, but meh, we try to leave the base spiders alone.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	heat_damage_per_tick = 5 //amount of damage applied if animal's body temperature is higher than maxbodytemp

	// Xenobio Interactions
	sentience_type = SENTIENCE_OTHER // prevents people from using a sentience potion on a TS to tame it

	// DEBUG OPTIONS & COMMANDS
	var/spider_growinstantly = 0 // DEBUG OPTION, DO NOT ENABLE THIS ON LIVE. IT IS USED TO TEST NEST GROWTH/SETUP AI.
	var/spider_debug = 0


// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: SHARED TARGETING & ATTACK CODE -----------
// --------------------------------------------------------------------------------


/mob/living/simple_animal/hostile/poison/terror_spider/ListTargets()
	var/list/targets1 = list()
	var/list/targets2 = list()
	var/list/targets3 = list()
	if (ai_type == TS_AI_AGGRESSIVE)
		// default, BE AGGRESSIVE
		//var/list/Mobs = hearers(vision_range, src) - src // this is how ListTargets for /mob/living/simple_animal/hostile/ does it, but it is wrong, it ignores NPCs.
		for(var/mob/living/H in view(src, vision_range))
		//for(var/mob/H in Mobs)
			if (H.stat == 2)
				continue
			else if (H.flags & GODMODE)
				continue
			else if (!stat_attack && H.stat == 1)
				continue
			else if (istype(H, /mob/living/simple_animal/hostile/poison/terror_spider))
				if (H in enemies)
					targets3 += H
				continue
			else if (H.reagents)
				if (H.paralysis && H.reagents.has_reagent("terror_white_tranq"))
					// let's not target completely paralysed mobs.
					if (H in enemies)
						targets3 += H
						// unless we hate their guts
				if (IsInfected(H)) // target them if they attack us
					if (H in enemies)
						targets3 += H
				else if (H.reagents.has_reagent("terror_black_toxin") && istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/black))
					if (get_dist(src,H) <= 2)
						// if they come to us...
						targets2 += H
					else if ((H in enemies) && !H.reagents.has_reagent("terror_black_toxin",31))
						// if we're aggressive, and they're not going to die quickly...
						targets2 += H
					else
						// they are far away, and either we're not very aggressive, or they are dying already
						// either way, not much point in targeting them
						// if they shoot us, of course, then we will consider them a valid target
				else
					if (H.can_inject(null,0,"chest",0))
						targets1 += H
					else if (H in enemies)
						targets2 += H
					else
						targets3 += H
					// first, go after targets we can inject - lightly armored humans.
					// second, go after humans that attacked us.
					// third, go after other humans.
			else if (istype(H, /mob/living/simple_animal))
				var/mob/living/simple_animal/hostile/poison/terror_spider/M = H
				if (M.force_threshold > melee_damage_upper)
					// If it has such high armor it can ignore any attack we make on it, ignore it.
				else if (M in enemies)
					targets2 += M
				else
					targets3 += M
			else
				if (H in enemies)
					targets2 += H
				else
					targets3 += H
		for(var/obj/mecha/M in mechas_list)
			if (get_dist(M, src) <= vision_range && can_see(src, M, vision_range))
				if (get_dist(M, src) <= 2)
					targets2 += M
				else
					targets3 += M
		if (health < maxHealth)
			// very unlikely that we're being shot at by a space pod - so only check for this if our health is lower than max.
			for(var/obj/spacepod/S in spacepods_list)
				if (get_dist(S, src) <= vision_range && can_see(src, S, vision_range))
					targets3 += S
		if (targets1.len)
			return targets1
		else if (targets2.len)
			return targets2
		else
			return targets3
	else if (ai_type == TS_AI_DEFENSIVE)
		// DEFEND SELF ONLY
		//var/list/Mobs = hearers(vision_range, src) - src
		for(var/mob/living/H in view(src, vision_range))
		//for(var/mob/H in Mobs)
			if (H.stat == 2)
				// dead mobs are ALWAYS ignored.
			else if (!stat_attack && H.stat == 1)
				// unconscious mobs are ignored unless spider has stat_attack
			else if (H in enemies)
				targets1 += H
		for(var/obj/mecha/M in mechas_list)
			if (M in enemies && get_dist(M, src) <= vision_range && can_see(src, M, vision_range))
				targets1 += M
		for(var/obj/spacepod/S in spacepods_list)
			if (S in enemies && get_dist(S, src) <= vision_range && can_see(src, S, vision_range))
				targets1 += S
		return targets1
	else if (ai_type == TS_AI_PASSIVE)
		// COMPLETELY PASSIVE
		return list()

/mob/living/simple_animal/hostile/poison/terror_spider/LoseTarget()
	if (target && isliving(target))
		var/mob/living/T = target
		if (T.stat > 0)
			killcount++
			regen_points += regen_points_per_kill
	attackstep = 0
	attackcycles = 0
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/AttackingTarget()
	if (istype(target, /mob/living/simple_animal/hostile/poison/terror_spider/))
		if (target in enemies)
			enemies -= target
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = target
		if (T.spider_tier > spider_tier)
			visible_message("<span class='notice'> \icon[src] [src] bows in respect for the terrifying presence of [target] </span>")
		else if (T.spider_tier == spider_tier)
			visible_message("<span class='notice'> \icon[src] [src] harmlessly nuzzles [target]. </span>")
		else if (T.spider_tier < spider_tier && spider_tier >= 4)
			visible_message("<span class='notice'> \icon[src] [src] gives [target] a stern look. </span>")
		else
			visible_message("<span class='notice'> \icon[src] [src] harmlessly nuzzles [target]. </span>")
		T.CheckFaction()
		CheckFaction()
	else if (istype(target, /obj/effect/spider/cocoon))
		to_chat(src, "Destroying our own cocoons would not help us.")
	else if (istype(target, /obj/machinery/camera))
		if (player_breaks_cameras)
			var/obj/machinery/camera/C = target
			if (C.status)
				do_attack_animation(C)
				C.toggle_cam(src,0)
				visible_message("<span class='danger'>\the [src] smashes the [C.name].</span>")
				playsound(loc, 'sound/weapons/slash.ogg', 100, 1)
			else
				to_chat(src, "The camera is already deactivated.")
		else
			to_chat(src, "Your type of spider cannot break cameras.")
	else if (istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = target
		if (F.density)
			if (F.blocked)
				to_chat(src, "The fire door is welded shut.")
			else
				visible_message("<span class='danger'>\the [src] pries open the firedoor!</span>")
				F.open()
		else
			to_chat(src, "Closing fire doors does not help.")
	else if (istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		if (A.density)
			try_open_airlock(A)
	else if (ai_type == TS_AI_PASSIVE)
		to_chat(src, "Your current orders forbid you from attacking anyone.")
	else if (ai_type == TS_AI_DEFENSIVE && !(target in enemies))
		to_chat(src, "Your current orders only allow you to defend yourself - not initiate combat.")
	else if (isliving(target))
		var/mob/living/G = target
		if (G.player_logged)
			to_chat(src, "[G] is braindead, and a waste of our time. (SSD. Server rules prohibit attacking SSDs)")
			if (G in enemies)
				enemies -= G
			return
		else if (istype(G, /mob/living/silicon/))
			G.attack_animal(src)
			return
		else if (G.reagents && (iscarbon(G)))
			var/can_poison = 1
			if (istype(G, /mob/living/carbon/human/))
				var/mob/living/carbon/human/H = G
				if (H.dna)
					if (!(H.species.reagent_tag & PROCESS_ORG) || (H.species.flags & NO_POISON))
						can_poison = 0
			spider_specialattack(G,can_poison)
		else
			G.attack_animal(src)
	else
		target.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/spider_specialattack(var/mob/living/carbon/human/L)
	L.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/adjustBruteLoss(var/damage)
	..(damage)
	Retaliate()

/mob/living/simple_animal/hostile/poison/terror_spider/adjustFireLoss(var/damage)
	..(damage)
	Retaliate()


/mob/living/simple_animal/hostile/poison/terror_spider/bullet_act(var/obj/item/projectile/Proj)
	if (istype(Proj, /obj/item/projectile/energy/declone/declone_spider))
		if (!degenerate)
			if (spider_tier < 2)
				if (ckey)
					degenerate = 1
				else
					gib()
			else
				visible_message("<span class='danger'> \icon[src] [src] resists the bioweapon! </span>")
	else if (istype(Proj, /obj/item/projectile/energy/declone))
		if (!degenerate && prob(20))
			visible_message("<span class='danger'> \icon[src] [src] looks staggered by the bioweapon! </span>")
			if (spider_tier < 3)
				degenerate = 1

	..()


// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: PROC OVERRIDES ---------------------------
// --------------------------------------------------------------------------------


/mob/living/simple_animal/hostile/poison/terror_spider/examine(mob/user)
	..()
	var/msg = ""
	if (stat == DEAD)
		msg += "<span class='deadsay'>It appears to be dead.</span>\n"
	else
		if (key)
			msg += "<BR><span class='warning'>Its eyes regard you with a curious intelligence.</span>"
		if (ai_type == TS_AI_AGGRESSIVE)
			msg += "<BR><span class='warning'>It appears aggressive.</span>"
		if (ai_type == TS_AI_DEFENSIVE)
			msg += "<BR><span class='notice'>It appears defensive.</span>"
		if (ai_type == TS_AI_PASSIVE)
			msg += "<BR><span class='notice'>It appears passive.</span>"

		if (health > (maxHealth*0.95))
			msg += "<BR><span class='notice'>It is in excellent health.</span>"
		else if (health > (maxHealth*0.75))
			msg += "<BR><span class='notice'>It has a few injuries.</span>"
		else if (health > (maxHealth*0.55))
			msg += "<BR><span class='warning'>It has many injuries.</span>"
		else if (health > (maxHealth*0.25))
			msg += "<BR><span class='warning'>It is barely clinging on to life!</span>"
		if (degenerate)
			msg += "<BR><span class='warning'>It appears to be dying.</span>"
		else if (health < maxHealth && regen_points > regen_points_per_kill)
			msg += "<BR><span class='notice'>It appears to be regenerating quickly</span>"
		if (killcount == 1)
			msg += "<BR><span class='warning'>It is soaked in the blood of its prey.</span>"
		if (killcount > 1)
			msg += "<BR><span class='warning'>It is soaked with the blood of " + num2text(killcount) + " prey it has killed.</span>"
	to_chat(usr,msg)


/mob/living/simple_animal/hostile/poison/terror_spider/New()
	..()
	ts_spiderlist += src
	if (type == /mob/living/simple_animal/hostile/poison/terror_spider)
		message_admins("[src] spawned in [get_area(src)] - a subtype should have been spawned instead.")
		qdel(src)
	else
		add_language("TerrorSpider")
		add_language("Galactic Common")
		default_language = all_languages["TerrorSpider"]

		name += " ([rand(1, 1000)])"
		msg_terrorspiders("[src] has grown in [get_area(src)].")
		if (name_usealtnames)
			name = pick(altnames)
		if (z > MAX_Z)
			spider_awaymission = 1
			if (spider_tier >= 3)
				ai_ventcrawls = 0 // means that pre-spawned bosses on away maps won't ventcrawl. Necessary to keep prince/mother in one place.
			if (istype(get_area(src), /area/awaymission/UO71)) // if we are playing the away mission with our special spiders...
				spider_uo71 = 1
				if (world.time < 600)
					// these are static spiders, specifically for the UO71 away mission, make them stay in place
					ai_ventcrawls = 0
					spider_placed = 1
					wander = 0
			ts_count_alive_awaymission++
		else
			ts_count_alive_station++
		// after 30 seconds, assuming nobody took control of it yet, offer it to ghosts.
		spawn(150) // deciseconds!
			CheckFaction()
		spawn(300) // deciseconds!
			if (spider_awaymission)
				return
			else if (ckey)
				notify_ghosts("[src] has appeared in [get_area(src)]. (already player-controlled)")
			else if (ai_playercontrol_allowingeneral && ai_playercontrol_allowtype)
				notify_ghosts("[src] has appeared in [get_area(src)]. <a href=?src=\ref[src];activate=1>(Click to control)</a>")

/mob/living/simple_animal/hostile/poison/terror_spider/Destroy()
	ts_spiderlist -= src
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/Life()
	if (stat != DEAD)
		if (degenerate > 0)
			adjustToxLoss(rand(1,10))
		if (regen_points < regen_points_max)
			regen_points += regen_points_per_tick
		if ((bruteloss > 0) || (fireloss > 0))
			if (regen_points > regen_points_per_hp)
				if (bruteloss > 0)
					adjustBruteLoss(-1)
					regen_points -= regen_points_per_hp
				else if (fireloss > 0)
					adjustFireLoss(-1)
					regen_points -= regen_points_per_hp
		if (prob(5))
			CheckFaction()
	else if (stat == DEAD)
		if (prob(2))
			// 2% chance every cycle to decompose
			visible_message("<span class='notice'>\The dead body of the [src] decomposes!</span>")
			gib()
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/death(gibbed)
	if (!gibbed)
		msg_terrorspiders("[src] has died in [get_area(src)].")
		//if (!ckey && spider_tier < 3)
		//	say(pick("Mistresssss will end you...", "Doom waitssss... for you...","She comessssss for your flesh..."))
	if (!hasdroppedloot)
		hasdroppedloot = 1
		if (ts_count_dead == 0)
			visible_message("<span class='userdanger'>The Terrors have awoken!</span>")
		ts_count_dead++
		ts_death_last = world.time
		if (spider_awaymission)
			ts_count_alive_awaymission--
		else
			ts_count_alive_station--
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/handle_automated_action()
	if (!stat && !ckey) // if we are not dead, and we're not player controlled
		if (AIStatus != AI_OFF && !target)
			var/my_ventcrawl_freq = freq_ventcrawl_idle
			if (ts_count_dead > 0)
				if (world.time < (ts_death_last + ts_death_window))
					my_ventcrawl_freq = freq_ventcrawl_combat
			if (cocoon_target)
				if (get_dist(src, cocoon_target) <= 1)
					spider_steps_taken = 0
					DoWrap()
				else
					if (spider_steps_taken > spider_max_steps)
						spider_steps_taken = 0
						cocoon_target = null
						busy = 0
						stop_automated_movement = 0
					else
						spider_steps_taken++
						CreatePath(cocoon_target)
						step_to(src,cocoon_target)
						if (spider_debug > 0)
							visible_message("<span class='notice'>\the [src] moves towards [cocoon_target] to cocoon it.</span>")
			else if (path_to_vent)
				if (entry_vent)
					if (spider_steps_taken > spider_max_steps)
						path_to_vent = 0
						stop_automated_movement = 0
						spider_steps_taken = 0
						path_to_vent = 0
						entry_vent = null
					else if (get_dist(src, entry_vent) <= 1)
						path_to_vent = 0
						stop_automated_movement = 1
						spider_steps_taken = 0
						spawn(50)
							stop_automated_movement = 0
						TSVentCrawlRandom(entry_vent)
					else
						spider_steps_taken++
						CreatePath(entry_vent)
						step_to(src,entry_vent)
						if (spider_debug > 0)
							visible_message("<span class='notice'>\the [src] moves towards the vent [entry_vent].</span>")
				else
					path_to_vent = 0
			else if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/purple) && prob(5))
				if (spider_myqueen)
					var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q = spider_myqueen
					if (Q.health > 0 && !Q.ckey)
						if (get_dist(src,Q) > 15 || z != Q.z)
							if (!degenerate && !Q.degenerate)
								degenerate = 1
								Q.DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple,1,0)
								//visible_message("<span class='notice'> [src] chitters in the direction of [Q]!</span>")
			else if (ai_break_lights && world.time > (last_break_light + freq_break_light))
				last_break_light = world.time
				for(var/obj/machinery/light/L in range(1,src))
					if (!L.status) // This assumes status == 0 means light is OK, which it does, but ideally we'd use lights' own constants.
						step_to(src,L) // one-time, does not require step tracking
						L.on = 1
						L.broken()
						L.do_attack_animation(src)
						visible_message("<span class='danger'>\the [src] smashes the [L.name].</span>")
						break
			else if (ai_spins_webs && world.time > (last_spins_webs + freq_spins_webs))
				last_spins_webs = world.time
				var/obj/effect/spider/terrorweb/T = locate() in get_turf(src)
				if (T)
				else
					new /obj/effect/spider/terrorweb(get_turf(src))
					visible_message("<span class='notice'>\the [src] puts up some spider webs.</span>")
			else if (ai_cocoons_object && world.time > (last_cocoon_object + freq_cocoon_object))
				last_cocoon_object = world.time
				var/list/can_see = view(src, 10)
				//first, check for potential food nearby to cocoon
				for(var/mob/living/C in can_see)
					if (C.stat && C.stat != CONSCIOUS && !istype(C, /mob/living/simple_animal/hostile/poison/terror_spider))
						spider_steps_taken = 0
						cocoon_target = C
						return
					//second, spin a sticky spiderweb on this tile
					var/obj/effect/spider/terrorweb/W = locate() in get_turf(src)
					if (!W)
						Web()
					else
						//third, lay an egg cluster there
						if (fed)
							DoLayGreenEggs()
						else
							//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
							for(var/obj/O in can_see)
								if (O.anchored)
									continue
								if (istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery) || istype(O, /obj/item/device/flashlight/lamp))
									if (!istype(O, /obj/item/weapon/paper))
										cocoon_target = O
										stop_automated_movement = 1
										spider_steps_taken = 0
			else if (ai_hides_in_vents && prob(prob_ai_hides_in_vents))
				var/obj/machinery/atmospherics/unary/vent_pump/e = locate() in get_turf(src)
				if (e)
					if (!e.welded || spider_awaymission)
						if (invisibility != SEE_INVISIBLE_LEVEL_ONE) // aka: 35. ghosts have 15 with no darkness, 60 with darkness. Weird...
							var/list/g_turfs_webbed = ListWebbedTurfs()
							var/webcount = g_turfs_webbed.len
							if (webcount >= 4)
								// if there are already at least 4 webs around us, then we have a good web setup already. Cloak.
								GrayCloak()
								// I wonder if we should settle down here forever?
								var/foundqueen = 0
								for(var/mob/living/H in view(src, 10))
									if (istype(H, /mob/living/simple_animal/hostile/poison/terror_spider/queen))
										foundqueen = 1
										break
								if (!foundqueen)
									var/list/g_turfs_visible = ListVisibleTurfs()
									if (g_turfs_visible.len >= 12)
										// So long as the room isn't tiny, and it has no queen in it, sure, settle there
										// since we are settled now, disable most AI behaviors so we don't waste CPU.
										ai_ventcrawls = 0
										ai_spins_webs = 0
										ai_break_lights = 0
										prob_ai_hides_in_vents = 3
										visible_message("<span class='notice'> [src] finishes setting up its trap in [get_area(src)].</span>")
							else
								var/list/g_turfs_valid = ListValidTurfs()
								var/turfcount = g_turfs_valid.len
								if (turfcount == 0)
									// if there is literally nowhere else we could put a web, cloak.
									GrayCloak()
								else
									// otherwise, pick one of the valid turfs with no web to create a web there.
									new /obj/effect/spider/terrorweb(pick(g_turfs_valid))
									visible_message("<span class='notice'> [src] spins a web.</span>")
					else
						if (invisibility == SEE_INVISIBLE_LEVEL_ONE)
							// if our vent is welded, decloak
							GrayDeCloak()
				else
					if (invisibility == SEE_INVISIBLE_LEVEL_ONE)
						// if there is no vent under us, and we are cloaked, decloak
						GrayDeCloak()
					var/vdistance = 99
					var/temp_vent = null
					for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(7,src))
						if (!v.welded)
							if (get_dist(src,v) < vdistance)
								temp_vent = v
								vdistance = get_dist(src,v)
					if (temp_vent)
						if (get_dist(src,temp_vent) > 0 && get_dist(src,temp_vent) < 5)
							step_to(src,temp_vent)
							// if you're bumped off your vent, try to get back to it
			else if (ai_ventcrawls && world.time > (last_ventcrawl_time + my_ventcrawl_freq))
				if (prob(idle_ventcrawl_chance))
					last_ventcrawl_time = world.time
					var/vdistance = 99
					for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
						if (!v.welded)
							if (get_dist(src,v) < vdistance)
								entry_vent = v
								vdistance = get_dist(src,v)
					if (entry_vent)
						path_to_vent = 1
		else if (AIStatus != AI_OFF && target)
			// if I am chasing something, and I've been stuck behind an obstacle for at least 3 cycles, aka 6 seconds, try to open doors
			CreatePath(target)
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/Bump(atom/A)
	if (istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/L = A
		if (L.density)
			try_open_airlock(L)
	if (istype(A, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = A
		if (F.density && !F.blocked)
			F.open()
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/Topic(href, href_list)
	if (href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if (istype(ghost))
			humanize_spider(ghost)


/mob/living/simple_animal/hostile/poison/terror_spider/attack_ghost(mob/user)
	humanize_spider(user)



#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//
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

	// Icons
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
	poison_type = ""

	// Movement
	move_to_delay = 6
	turns_per_move = 5
	pass_flags = PASSTABLE
	ventcrawler = 1
	var/lastventcrawltime = 0 // tracks the last world.time that the spider ventcrawled, used to prevent excessive crawling.
	var/minventcrawlfrequency = 600 // only permit one crawl attempt per 60 seconds. Deciseconds are annoying.

	// Speech
	speak_chance = 3 // quiet but deadly
	speak_emote = list("hisses")
	emote_hear = list("hisses")

	// Interaction keywords
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"

	// regeneration settings - overridable by child classes
	var/regen_points = 0 // number of regen points they have by default
	var/regen_points_max = 100 // max number of points they can accumulate
	var/regen_points_per_tick = 1 // gain one regen point per tick
	var/regen_points_per_kill = 100 // gain extra regen points if you kill something
	var/regen_points_per_hp = 2 // every 5 regen points = 1 health point you can regen
	// desired: 30hp/minute unmolested, 60hp/min on food boost, assuming one tick every 2 seconds
	//          100/kill means bonus 50hp/kill regenerated over the next 1-2 minutes


	var/degenerate = 0 // if 1, they slowly degen until they all die off. Used by high-level abilities only.

	// Loot
	var/loot = 1 // if they drop loot when they die
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/spidermeat
	meat_amount = 2

	// Vision
	idle_vision_range = 10
	aggro_vision_range = 10
	see_in_dark = 10
	nightvision = 1
	vision_type = new /datum/vision_override/nightvision/thermals/ling_augmented_eyesight
	see_invisible = 5

	// AI global defaults
	var/ai_type = 0 // 0 = aggressive to everyone, 1 = defends self only, 2 = passive, you can butcher it like a sheep
	var/ai_playercontrol_allowingeneral = 1 // if 0, no spiders are player controllable. Default set in code, can be changed by queens.
	var/ai_playercontrol_allowtype = 1 // if 0, this specific class of spider is not player-controllable. Default set in code for each class, cannot be changed.
	var/idle_ventcrawl_chance = 3 // default 3% chance to ventcrawl when not in combat to a random exit vent
	var/ai_breaks_lights = 1
	var/ai_breaks_cameras = 1
	var/idle_breakstuff_chance = 10
	var/ai_spins_webs = 1
	var/idle_spinwebs_chance = 5
	var/spider_opens_doors = 2 // all spiders can open firedoors (they have no security). 1 = can open depowered doors. 2 = can open powered doors
	faction = list("terrorspiders")

	// AI variables designed for use in procs
	var/atom/cocoon_target // for queen and nurse
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent // nearby vent they are going to try to get to, and enter
	var/obj/machinery/atmospherics/unary/vent_pump/exit_vent // remote vent they intend to come out of
	var/obj/machinery/atmospherics/unary/vent_pump/nest_vent // home vent, usually used by queens
	var/travelling_in_vent = 0
	var/list/enemies = list()
	var/list/nibbled = list()
	var/path_to_vent = 0
	var/killcount = 0
	var/busy = 0 // leave this alone!
	var/spider_tier = 1 // 1 for red,gray,green. 2 for purple,black,white, 3 for queen, mother. 4 for empress.
	var/spider_ckey_blacklist = list()

	// Breathing, Pressure & Fire
	// No breathing / cannot be suffocated (spiders can hold their breath, look it up)
	// No pressure damage either - they have effectively exoskeletons
	// HOWEVER they can be burned to death!
	// Normal SPACE spiders should probably be immune to SPACE too, but meh, we try to leave the base spiders alone.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	// no maxbodytemp. I guess you can burn them? That's a good thing! People want to kill it with fire - let them.
	heat_damage_per_tick = 20 //amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 20 //same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp

	// DEBUG OPTIONS & COMMANDS
	var/spider_growinstantly = 0 // DEBUG OPTION, DO NOT ENABLE THIS ON LIVE. IT IS USED TO TEST NEST GROWTH/SETUP AI.
	var/spider_debug = 1


// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: SHARED TARGETING & ATTACK CODE -----------
// --------------------------------------------------------------------------------


/mob/living/simple_animal/hostile/poison/terror_spider/ListTargets()
	var/list/targets1 = list()
	var/list/targets2 = list()
	var/list/targets3 = list()
	if (ai_type == 0)
		// default, BE AGGRESSIVE
		//var/list/Mobs = hearers(vision_range, src) - src // this is how ListTargets for /mob/living/simple_animal/hostile/ does it, but it is wrong, it ignores NPCs.
		for(var/mob/living/H in view(src, vision_range))
		//for(var/mob/H in Mobs)
			if (H.stat == 2)
				// dead mobs are ALWAYS ignored.
			else if (!stat_attack && H.stat == 1)
				// unconscious mobs are ignored unless spider has stat_attack
			else if(istype(H,/mob/living/simple_animal/hostile/poison/terror_spider))
				// fellow terror spiders are never valid targets unless they deliberately attack us, even then, low priority
				if (H in enemies)
					targets3 += H
			else if(istype(H,/mob/living/simple_animal/hostile/poison/giant_spider))
				// we eat normal spiders for breakfast.
				targets3 += H
			else if(H.reagents)
				if (H.reagents.has_reagent("terror_white_toxin"))
					if (H in enemies)
						targets3 += H // target them only if they attack us
				else
					if (H.reagents.has_reagent("terror_black_toxin") && poison_type == "terror_black_toxin")
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
						targets1 += H
						// targets with no venom are priority targets, always pick these first
						// yeah, we could try to prioritize PROCESS_ORGANIC targets, ie: people we can poison...
						// -- but that might lead to a situation where we fail to handle the bigger threat before it kills us.
			else
				if (H in enemies)
					targets2 += H
				else
					targets3 += H
		for(var/obj/mecha/M in mechas_list)
			if(get_dist(M, src) <= vision_range && can_see(src, M, vision_range))
				targets1 += M
		for(var/obj/spacepod/S in spacepods_list)
			if(get_dist(S, src) <= vision_range && can_see(src, S, vision_range))
				targets3 += S
		for(var/obj/machinery/porta_turret/R in view(src, vision_range))
			if (!R.stat)
				// spiders will target turrets that shoot them, by default
				targets3 += R
		if (targets1.len)
			return targets1
		else if (targets2.len)
			return targets2
		else
			return targets3
	else if (ai_type == 1)
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
			if(M in enemies && get_dist(M, src) <= vision_range && can_see(src, M, vision_range))
				targets1 += M
		for(var/obj/spacepod/S in spacepods_list)
			if(S in enemies && get_dist(S, src) <= vision_range && can_see(src, S, vision_range))
				targets3 += S
		return targets1
	else if (ai_type == 2)
		// COMPLETELY PASSIVE
		return list()


/mob/living/simple_animal/hostile/poison/terror_spider/LoseTarget()
	if (target && isliving(target))
		var/mob/living/T = target
		if (T.stat > 0)
			killcount++
			regen_points += regen_points_per_kill
	..()

///mob/living/simple_animal/hostile/poison/terror_spider/GiveTarget(var/new_target)
//	visible_message("<span class='danger'>\the [src] hisses at [new_target]!</span>")
//	..()

/mob/living/simple_animal/hostile/poison/terror_spider/AttackingTarget()
	if (istype(target,/mob/living/simple_animal/hostile/poison/terror_spider/))
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = target
		if (T.spider_tier > spider_tier)
			visible_message("<span class='notice'> \icon[src] bows in respect for the terrifying presence of [target] </span>")
		else if (T.spider_tier == spider_tier)
			visible_message("<span class='notice'> \icon[src] harmlessly nuzzles [target]. </span>")
		else if (T.spider_tier < spider_tier && spider_tier >= 3)
			visible_message("<span class='notice'> \icon[src] gives [target] a stern look. </span>")
		else
			visible_message("<span class='notice'> \icon[src] harmlessly nuzzles [target]. </span>")
	else if (istype(target,/obj/effect/spider/cocoon))
		src << "Destroying our own cocoons would not help us."
	else if (istype(target,/obj/machinery/camera))
		var/obj/machinery/camera/C = target
		if (C.status)
			do_attack_animation(C)
			C.status = 0
			visible_message("<span class='danger'>\the [src] smashes the [C.name].</span>")
			playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
			C.icon_state = "[initial(C.icon_state)]1"
			C.add_hiddenprint(src)
			C.deactivate(src,0)
		else
			src << "The camera is already deactivated."
	else if (istype(target,/obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = target
		if (F.density)
			if (F.blocked)
				src << "The fire door is welded shut."
			else
				visible_message("<span class='danger'>\the [src] pries open the firedoor!</span>")
				F.open()
		else
			src << "Closing fire doors does not help."
	else if (istype(target,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/D = target
		if (D.density)
			if (D.locked || D.welded)
				src << "The door is bolted or welded shut."
			else if (D.operating)
			else if (D.arePowerSystemsOn() && (spider_opens_doors != 2))
				src << "The door's motors resist your efforts to force it."
			else if (!spider_opens_doors)
				src << "Your type of spider is not strong enough to force open a depowered door."
			else
				visible_message("<span class='danger'>\the [src] pries open the door!</span>")
				playsound(src.loc, "sparks", 100, 1)
				D.open(1)
	else
		// for most targets, we simply attack
		target.attack_animal(src)
		visible_message("<span class='danger'> \icon[src] [src] bites [target]! </span>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/Retaliate()
	..()
	var/list/around = view(src, 7)
	for(var/atom/movable/A in around)
		if(A == src)
			continue
		if (A in enemies)
			// they are already our enemy
			continue
		else if(isliving(A))
			var/mob/living/M = A
			var/faction_check = 0
			for(var/F in faction)
				if(F in M.faction)
					faction_check = 1
					break
			if(faction_check && attack_same || !faction_check)
				enemies |= M
				visible_message("<span class='danger'> \icon[src] [src] glares at [M]! </span>")
				// should probably exempt people who are dead...
		else if(istype(A, /obj/mecha))
			var/obj/mecha/M = A
			if(M.occupant)
				enemies |= M
				enemies |= M.occupant
		else if(istype(A, /obj/spacepod))
			var/obj/spacepod/M = A
			if(M.occupant || M.occupant2)
				enemies |= M
				enemies |= M.occupant
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/H in around)
		var/retaliate_faction_check = 0
		for(var/F in faction)
			if(F in H.faction)
				retaliate_faction_check = 1
				break
		if(retaliate_faction_check && !attack_same && !H.attack_same)
			H.enemies |= enemies
	if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/queen) || istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/empress)  )
		for (var/mob/living/simple_animal/hostile/poison/terror_spider/T in world)
			T.enemies |= enemies
	return 0

/mob/living/simple_animal/hostile/poison/terror_spider/adjustBruteLoss(var/damage)
	..(damage)
	Retaliate()

/mob/living/simple_animal/hostile/poison/terror_spider/adjustFireLoss(var/damage)
	..(damage)
	Retaliate()


/mob/living/simple_animal/hostile/poison/terror_spider/bullet_act(var/obj/item/projectile/Proj)
	//var/donotice = 0
	//for(var/mob/living/H in view(src, 10))
	//	if(!istype(H,/mob/living/simple_animal/hostile/poison/terror_spider/))
	//		if (!(H in enemies))
	//			enemies |= H
	//			if (!donotice)
	//				donotice = 1
	//				visible_message("<span class='danger'> \icon[src] [src] glares at [H], enraged! </span>")
	if (istype(Proj, /obj/item/projectile/energy/declone))
		if (!degenerate && prob(20))
			visible_message("<span class='danger'> \icon[src] [src] looks staggered by the bioweapon! </span>")
			Stun(5)
			if (spider_tier < 3)
				degenerate=1
	..()


// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: SHARED PROCS -----------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/msg_terrorspiders(var/msgtext)
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in world)
		if (T.health > 0)
			T << msgtext


/mob/living/simple_animal/hostile/poison/terror_spider/examine(mob/user)
	..()
	var/msg = ""
	if (src.stat == DEAD)
		msg += "<span class='deadsay'>It appears to be dead.</span>\n"
	else
		if (src.key)
			msg += "<span class='warning'>Its eyes regard you with a curious intelligence.</span>"
		else if (src.ai_type == 0)
			msg += "<span class='warning'>It appears aggressive.</span>"
		else if (src.ai_type == 0)
			msg += "<span class='notice'>It appears defensive.</span>"
		else if (src.ai_type == 2)
			msg += "<span class='notice'>It appears passive.</span>"

		if (health > (maxHealth*0.95))
			msg += "<span class='notice'>It is in excellent health.</span>"
		else if (health > (maxHealth*0.75))
			msg += "<span class='notice'>It has a few injuries.</span>"
		else if (health > (maxHealth*0.55))
			msg += "<span class='warning'>It has many injuries.</span>"
		else if (health > (maxHealth*0.25))
			msg += "<span class='warning'>It is barely clinging on to life.</span>"
	user << msg


/mob/living/simple_animal/hostile/poison/terror_spider/New()
	..()
	add_language("TerrorSpider")
	msg_terrorspiders("A [src] has grown in [get_area(src)].")
	name += " ([rand(1, 1000)])"
	if (name_usealtnames)
		name = pick(altnames)


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
				// THIS REQUIRES TESTING!
	if (stat == DEAD)
		if (prob(2))
			// 2% chance every cycle to decompose
			visible_message("<span class='notice'>\the dead body of the [src] decomposes!</span>")
			meat_amount = 0
			gib()
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/death(gibbed)
	if (!gibbed)
		msg_terrorspiders("[src] has died in [get_area(src)].")
		//name = name + " (dead)"
		if (!ckey)
			say(pick("Mistresssss will end you...", "Doom waitssss... for you...","She comessssss for your flesh..."))
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/handle_automated_action()
	if(!stat && !ckey) // if we are not dead, and we're not player controlled
		if(stance == HOSTILE_STANCE_IDLE)
			if (path_to_vent)
				if (entry_vent)
					if (get_dist(src, entry_vent) <= 1)
						path_to_vent = 0
						stop_automated_movement = 1
						spawn(50)
							stop_automated_movement = 0
						TSVentCrawlRandom(entry_vent)
					else
						var/attackedsomething = 0
						var/turf/T = get_step(src, get_dir(src, entry_vent))
						for(var/atom/A in T)
							if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack))
								A.attack_animal(src)
								attackedsomething = 1
								break
						if (!attackedsomething)
							step_to(src,entry_vent)
							if (spider_debug)
								visible_message("<span class='notice'>\the [src] moves towards the vent [entry_vent].</span>")
				else
					path_to_vent = 0
			else if ((ai_breaks_lights || ai_breaks_cameras) && prob(idle_breakstuff_chance))
				if (ai_breaks_lights)
					for(var/obj/machinery/light/L in range(2,src))
						if (!L.status) // This assumes status == 0 means light is OK, which it does, but ideally we'd use lights' own constants.
							step_to(src,L)
							L.on = 1
							L.broken()
							L.do_attack_animation(src)
							visible_message("<span class='danger'>\the [src] smashes the [L.name].</span>")
							break
				if (ai_breaks_cameras)
					for(var/obj/machinery/camera/C in range(2,src))
						if (C.status)
							step_to(src,C)
							do_attack_animation(C)
							C.status = 0
							visible_message("<span class='danger'>\the [src] smashes the [C.name].</span>")
							playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
							C.icon_state = "[initial(C.icon_state)]1"
							C.add_hiddenprint(src)
							C.deactivate(src,0)
							break
			else if (ai_spins_webs && prob(idle_spinwebs_chance))
				var/obj/effect/spider/terrorweb/T = locate() in get_turf(src)
				if (T)
				else
					new /obj/effect/spider/terrorweb(get_turf(src))
					visible_message("<span class='notice'>\the [src] puts up some spider webs.</span>")
			else if (world.time > (lastventcrawltime + minventcrawlfrequency))
				if (prob(idle_ventcrawl_chance))
					var/vdistance = 99
					for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
						if(!v.welded)
							if (get_dist(src,v) < vdistance)
								entry_vent = v
								vdistance = get_dist(src,v)
					if(entry_vent)
						path_to_vent = 1
						lastventcrawltime = world.time
		else if (stance == HOSTILE_STANCE_ATTACK)
			var/tgt_dir = get_dir(src,target)
			for(var/obj/machinery/door/firedoor/F in view(1,src))
				if (tgt_dir == get_dir(src,F) && F.density && !F.blocked)
					visible_message("<span class='danger'>\the [src] pries open the firedoor!</span>")
					F.open()
			if (spider_opens_doors)
				for(var/obj/machinery/door/airlock/D in view(1,src))
					if (tgt_dir == get_dir(src,D) && D.density && !D.locked && !D.welded && !D.operating)
						if (spider_opens_doors == 2 || !D.arePowerSystemsOn())
							visible_message("<span class='danger'>\the [src] pries open the door!</span>")
							D.open(1)
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/harvest()
	// Notes
		// red = drops fangs, robust melee weapon [done]
		// green = drops silk, can be used as cable for wiring, or cuffs [done]
		// gray = drops nothing, they're weak and
		// white = drops ? (white spider poison gland?)
		// purple = drops ?
		// black = drops ? (black spider poison gland?)
		// queen = drops a complete set of everything?
		// mother = drops SPIDERS, handled in other code.
		// empress = drops huge amounts of meat?
	var/obj/item/weapon/terrorspider_fang/F = new /obj/item/weapon/terrorspider_fang(get_turf(src))
	if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/red))
		// red spiders have way worse fangs than any other type
		F.force=20
		F.name="red terror fang"
		F.desc = "A big, nasty, pointy fang!"
	new /obj/item/clothing/suit/armor/terrorspider_carapace(get_turf(src))
	var/obj/item/stack/cable_coil/CC = new /obj/item/stack/cable_coil(get_turf(src))
	CC.name = "Conductive Spider Silk"
	CC.color = COLOR_YELLOW
	gib()
	return


/mob/living/simple_animal/hostile/poison/terror_spider/proc/TSVentCrawlRandom(/var/entry_vent)
	if(entry_vent)
		if(get_dist(src, entry_vent) <= 2)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			visible_message("<B>[src] scrambles into the ventillation ducts!</B>", \
							"<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
			spawn(rand(20,60))
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)
					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return
					if(prob(99))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					spawn(travel_time)
						if(!exit_vent || exit_vent.welded)
							loc = entry_vent
							entry_vent = null
							return
						loc = exit_vent.loc
						entry_vent = null
						var/area/new_area = get_area(loc)
						if(new_area)
							new_area.Entered(src)


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
	if (user.ckey in spider_ckey_blacklist)
		user << "You are temporarily blacklisted from controlling any type of terror spider."
		return
	if (!ai_playercontrol_allowingeneral)
		user << "Terror spiders cannot currently be player-controlled."
		return
	if (!ai_playercontrol_allowtype)
		user << "This specific type of terror spider is not player-controllable."
		return
	if (degenerate)
		user << "Dying spiders are not player-controllable."
		return
	if (jobban_isbanned(user, "Syndicate") || jobban_isbanned(user, "alien"))
		user << "You are jobbanned from role of syndicate and/or alien lifeform."
		return
	var/spider_ask = alert("Take direct control of " + src.name + "?", "Join as Terror Spider?", "Yes", "No")
	if(spider_ask == "No" || !src || qdeleted(src))
		return
	if(key)
		user << "<span class='notice'>Someone else already took this spider.</span>"
		return
	key = user.key
	for(var/mob/dead/observer/G in player_list)
		G.show_message("<i>A ghost has taken control of <b>[src]</b>. ([ghost_follow_link(src, ghost=G)]).</i>")
	// T1
	ShowGuide()


// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: SHARED VERBS -----------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/verb/ShowGuide()
	if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/red))
		src << "You are the red terror spider."
		src << "A straightforward fighter, you have high health, and high melee damage, but are slow-moving."
	else if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/gray))
		src << "You are the gray terror spider."
		src << "You are an ambusher. Invisible near vents, you hunt unequipped and vulnerable humanoids."
	else if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/green))
		src << "You are the green terror spider."
		src << "You are a breeding spider. Only average in combat, you can (and should) use 'Wrap' on any dead humaniod you kill, or see. These eggs will hatch into more spiders!"
	// T2
	else if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/black))
		src << "You are the black terror spider."
		src << "You are an assassin. Even 2-3 bites from you is fatal to organic humanoids - if you back off and let your poison work. You are very vulnurable to borgs."
	else if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/purple))
		src << "You are the purple terror spider."
		src << "You guard the nest of the all important Terror Queen! You are very robust, but should not leave her side."
		src << "<b>If the queen dies, you die!</b>"
	else if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/white))
		src << "You are the white terror spider."
		src << "Amongst the most feared of all terror spiders, your multi-stage bite attack injects tiny spider eggs into a host, which will make spiders grow out of their skin in time."
		src << "You should advance quickly, attack three times, then retreat, letting your venom of tiny eggs do its work."
	// T3
	else if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/queen))
		src << "You are the terror queen spider!"
		src << "Your goal is to build a nest, Lay Eggs to make more spiders, and ultimately exterminate all non-spider life on the station!"
		src << "You can use HiveCommand to issue orders to your spiders (both AI, and player-controlled)"
		src << "The success or failure of the entire hive depends on you, so whatever you do, do not die!"
	src << " "
	src << "Use .a to talk to your fellow spiders over the spider hivemind."
	src << " "
	src << "Verbs:"
	src << " - Web: Spin a terror web. They block shots, stun any human who walks into them, etc."
	src << " - Nibble: Eat an adjacent dead humanoid. Helps you to regenerate health faster."
	src << " - Suicide: Kills you and spawns another spider in your place. Use only if you must leave the round."
	src << " "
	if (istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/queen))
		src << "<span class='notice'> Remember, you are in command of ALL other terror spiders. They must obey you. If they don't, you have a verb that kills them...</span>"
	else
		if (ai_type == 0)
			//
			src << "Your orders are: <span class='danger'> kill all humanoids on sight </span>"
		else if (ai_type == 1)
			//
			src << "Your orders are: <span class='notice'> defend yourself without being aggressive </span> "
		else if (ai_type == 2)
			//
			src << "Your orders are: <span class='danger'> do not attack anyone, not even in self-defense!</span> "
		src << "A Terror Queen, if one is present, can change your orders. Any spider that disobeys their queen can be killed."

/mob/living/simple_animal/hostile/poison/terror_spider/verb/Web()
	set name = "Lay Web"
	set category = "Spider"
	set desc = "Spin a sticky web to slow down prey."
	var/T = loc
	if(busy != SPINNING_WEB)
		busy = SPINNING_WEB
		visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
		stop_automated_movement = 1
		spawn(40)
			if(busy == SPINNING_WEB && loc == T)
				new /obj/effect/spider/terrorweb(T)
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/terror_spider/verb/Nibble() // var/mob/living/carbon/nibbletarget in oview(1)
	set name = "Eat Corpse"
	set category = "Spider"
	set desc = "Takes a bite out of a humanoid. Increases regeneration. Use on dead bodies is preferable!"
	var/choices = list()
	for(var/mob/living/L in view(1,src))
		if(L == src)
			continue
		if(L in nibbled)
			continue
		if(Adjacent(L))
			if (L.stat != CONSCIOUS)
				choices += L
	var/nibbletarget = input(src,"What do you wish to nibble?") in null|choices
	if (!nibbletarget)
		// cancel
	else if (!isliving(nibbletarget))
		src << "[nibbletarget] is not edible."
	else if (nibbletarget in nibbled)
		src << "You have already eaten some of [nibbletarget]."
	else
		nibbled += nibbletarget
		regen_points += regen_points_per_kill
		src << "You take a bite out of [nibbletarget], boosting your regeneration for awhile."
		src.do_attack_animation(nibbletarget)
		if (spider_debug)
			src << "You now have " + num2text(regen_points) + " regeneration points."

/mob/living/simple_animal/hostile/poison/terror_spider/verb/Suicide()
	set name = "Suicide"
	set category = "Spider"
	set desc = "Kills you, and spawns a spiderling. Use this if you need to leave the round for a considerable time."
	if (spider_tier == 3)
		src << "Your type of spider is too important to the round to be allowed to suicide. Instead, you will be ghosted, and the spider controlled by AI."
		for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in world)
			T.spider_ckey_blacklist += src.ckey
		ghostize()
		ckey = null // *** need to test if this actually works.
	else
		visible_message("<span class='notice'>\the [src] awakens the remaining eggs in its body, which hatch and start consuming it from the inside out!</span>")
		spawn(100)
			if (health > 0 && !istype(src,/mob/living/simple_animal/hostile/poison/terror_spider/empress))
				var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
				S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red,/mob/living/simple_animal/hostile/poison/terror_spider/gray,/mob/living/simple_animal/hostile/poison/terror_spider/green)
				S.faction = faction
				S.master_commander = master_commander
				S.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
				S.enemies = enemies
				loot = 0
				meat_amount = 0
				death()
				gib()


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: GUARD CLASS, TIER 1, RED TERROR --------------
// --------------------------------------------------------------------------------
// -------------: ROLE: generic attack spider
// -------------: AI: uses its very powerful fangs to wreck people in melee
// -------------: SPECIAL: none
// -------------: TO FIGHT IT: shoot it from range. Kite it.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/MightyGlacier


/mob/living/simple_animal/hostile/poison/terror_spider/red
	name = "red terror spider"
	desc = "An ominous-looking red spider, it has eight beady red eyes, and nasty, big, pointy fangs!"
	altnames = list("Red Terror spider","Crimson Terror spider","Bloody Butcher spider")
	icon_state = "terror_red"
	icon_living = "terror_red"
	icon_dead = "terror_red_dead"
	maxHealth = 200
	health = 200
	melee_damage_lower = 30
	melee_damage_upper = 40
	move_to_delay = 20
	spider_opens_doors = 2
	var/enrage = 0
	var/melee_damage_lower_rage0 = 10
	var/melee_damage_upper_rage0 = 20
	var/melee_damage_lower_rage1 = 20
	var/melee_damage_upper_rage1 = 30
	var/melee_damage_lower_rage2 = 30
	var/melee_damage_upper_rage2 = 40


/mob/living/simple_animal/hostile/poison/terror_spider/red/AttackingTarget()
	if (enrage == 0)
		if (health < maxHealth)
			enrage = 1
			visible_message("<span class='danger'> \icon[src] [src] growls, flexing its fangs! </span>")
			melee_damage_lower = melee_damage_lower_rage1
			melee_damage_upper = melee_damage_upper_rage1
	else if (enrage == 1)
		if (health == maxHealth)
			enrage = 0
			visible_message("<span class='notice'> \icon[src] [src] retracts its fangs a little. </span>")
			melee_damage_lower = melee_damage_lower_rage0
			melee_damage_upper = melee_damage_upper_rage0
		else if (health < (maxHealth/2))
			enrage = 2
			visible_message("<span class='danger'> \icon[src] [src] growls, spreading its fangs wide! </span>")
			melee_damage_lower = melee_damage_lower_rage2
			melee_damage_upper = melee_damage_upper_rage2
	else if (enrage == 2)
		if (health > (maxHealth/2))
			enrage = 1
			visible_message("<span class='notice'> \icon[src] [src] retracts its fangs a little. </span>")
			melee_damage_lower = melee_damage_lower_rage0
			melee_damage_upper = melee_damage_upper_rage0
	..()

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: GUARD CLASS, TIER 2, PRAETORIAN --------------
// --------------------------------------------------------------------------------
// -------------: ROLE: guard for nests of a queen
// -------------: AI: stuns you at times, returns to queen if too far from her.
// -------------: SPECIAL: chance to stun on hit
// -------------: TO FIGHT IT: shoot it from range, bring friends!
// -------------: CONCEPT:http://tvtropes.org/pmwiki/pmwiki.php/Main/PraetorianGuard


/mob/living/simple_animal/hostile/poison/terror_spider/purple
	name = "praetorian spider"
	desc = "An ominous-looking purple spider."
	icon_state = "terror_purple"
	icon_living = "terror_purple"
	icon_dead = "terror_purple_dead"
	maxHealth = 300
	health = 300
	melee_damage_lower = 10
	melee_damage_upper = 15
	move_to_delay = 6
	idle_ventcrawl_chance = 0 // stick to the queen!
	spider_tier = 2


/mob/living/simple_animal/hostile/poison/terror_spider/purple/handle_automated_action()
	if(!stat && !ckey && stance == HOSTILE_STANCE_IDLE)
		if (prob(50))
			var/foundqueen = 0
			for(var/mob/living/H in view(src, 6))
				if (istype(H,/mob/living/simple_animal/hostile/poison/terror_spider/queen))
					foundqueen = 1
					break
			if (!foundqueen)
				for(var/mob/living/H in range(src, 25))
					if (istype(H,/mob/living/simple_animal/hostile/poison/terror_spider/queen))
						step_to(src,H,20)
						break
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/purple/AttackingTarget()
	if(isliving(target) && prob(10) && !istype(target,/mob/living/simple_animal/hostile/poison/terror_spider/))
		var/mob/living/L = target
		visible_message("<span class='danger'> \icon[src] [src] rams into [L] knocking them to the floor and stunning them! </span>")
		L.Weaken(5)
		L.Stun(5)
	else
		..()
		// just do normal attack


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: STRIKE CLASS, TIER 1, GRAY GHOST ------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ambusher
// -------------: AI: hides in vents, emerges when prey is near to kill it, then hides again. Intended to scare normal crew.
// -------------: SPECIAL: invisible when in a vent
// -------------: TO FIGHT IT: shoot it through a window, or make it regret ambushing you
// -------------: CONCEPT:http://tvtropes.org/pmwiki/pmwiki.php/Main/StealthExpert


/mob/living/simple_animal/hostile/poison/terror_spider/gray
	name = "gray terror spider"
	desc = "An ominous-looking gray spider, its color and shape makes it hard to see."
	altnames = list("Gray Trap spider","Gray Stalker spider","Ghostly Ambushing spider")
	icon_state = "terror_gray"
	icon_living = "terror_gray"
	icon_dead = "terror_gray_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its almost invisible.
	health = 120
	melee_damage_lower = 15 // same as guard spider, its a melee class
	melee_damage_upper = 20
	ventcrawler = 1
	move_to_delay = 5 // slow.
	stat_attack = 1 // ensures they will target people in crit, too!
	environment_smash = 1
	stop_automated_movement = 1 // wandering defeats the purpose of stealth
	ai_playercontrol_allowtype = 0 // because its signature ability is hiding in vents, which is CURRENTLY only supported for AI...
	//                                HOWEVER ***** we could create a 'stealth' verb that lets you hide for a few seconds after emerging from a vent...
	idle_vision_range = 3 // very low idle vision range
	ai_spins_webs = 0


/mob/living/simple_animal/hostile/poison/terror_spider/gray/Aggro()
	invisibility = 0
	environment_smash = 1
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/gray/AttackingTarget()
	// ensure that we can NEVER attack while cloaked, ever
	//if (invisibility > 1)
	//	invisibility = 1
	//else if (invisibility == 1)
	//	invisibility = 0
	if (invisibility > 0)
		invisibility = 0
	else
		..()


/mob/living/simple_animal/hostile/poison/terror_spider/gray/handle_automated_action()
	if(!stat && !ckey && stance == HOSTILE_STANCE_IDLE)
		//if (target && invisibility > 0)
		//	if (get_dist(src,target) < 3)
		//		invisibility = 0
		//		environment_smash = 1
		//		visible_message("<span class='danger'>\the [src] ambushes [target] from the vent!</span>")
		//else if (target && invisibility < 1)
		//	// cool.
		//else
		if (!target && invisibility != INVISIBILITY_LEVEL_ONE)
			var/vdistance = 99
			for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
				if(!v.welded)
					if (get_dist(src,v) < vdistance)
						entry_vent = v
						vdistance = get_dist(src,v)
			if (entry_vent)
				if (get_dist(src,entry_vent) < 2)
					step_to(src,entry_vent)
					invisibility = INVISIBILITY_LEVEL_ONE
					stop_automated_movement = 1
					visible_message("<span class='notice'>\the [src] hides in the vent, awaiting prey.</span>")
				else
					step_to(src,entry_vent)
		//else if (!target && invisibility > 0)
		//	// do nothing. its cool.
	..()

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: STRIKE CLASS, TIER 2, BLACK WIDOW -----------
// --------------------------------------------------------------------------------
// -------------: ROLE: assassin
// -------------: AI: attacks to inject its venom, then retreats. Will inject its enemies multiple times then hang back to ensure they die.
// -------------: SPECIAL: venom that does more damage the more of it is in you
// -------------: TO FIGHT IT: if bitten once, retreat, get charcoal/etc treatment, and come back with a gun.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/GradualGrinder

/mob/living/simple_animal/hostile/poison/terror_spider/black
	name = "black widow spider"
	desc = "An ominous-looking spider, black as the darkest night, and with merciless yellow eyes."
	altnames = list("Black Devil spider","Giant Black Widow spider","Shadow Terror spider")
	icon_state = "terror_black"
	icon_living = "terror_black"
	icon_dead = "terror_black_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its bite will kill you!
	health = 120
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 5
	stat_attack = 1 // ensures they will target people in crit, too!
	poison_type = "terror_black_toxin"
	spider_tier = 2


/mob/living/simple_animal/hostile/poison/terror_spider/black/AttackingTarget()
	// All custom. Parent procs produce undesirable effects, like applying spidertoxin, damage, etc. We usually don't want any of those things to happen.
	if (istype(target,/mob/living/simple_animal/hostile/poison/terror_spider/))
		..()
	else if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			if (L.reagents.has_reagent("terror_black_toxin",15))
				L.attack_animal(src)
			else
				melee_damage_lower = 1
				melee_damage_upper = 5
				visible_message("<span class='danger'> \icon[src] [src] buries its long fangs deep into [target]! </span>")
				L.attack_animal(src)
				//L.Weaken(5)
				melee_damage_lower = 10 // this is only good for the first attack, though....afterwards they get full force.
				melee_damage_upper = 20
			L.reagents.add_reagent("terror_black_toxin", 15) // inject our special poison
			if ((!target in enemies) || L.reagents.has_reagent("terror_black_toxin",50))
				// if we haven't been shot at, or we've bitten them so much they will die very fast, retreat
				spawn(10)
					step_away(src,L)
					step_away(src,L)
					LoseTarget()
					for(var/i=0, i<4, i++)
						step_away(src, L)
					visible_message("<span class='notice'> \icon[src] [src] warily eyes [L] from a distance. </span>")
				// aka, if you come over here I will wreck you.
		else
			// code for handling mobs that don't process reagents. Possibly dead bodies? Or simple mobs that have no reagent container?
			target.attack_animal(src)
			visible_message("<span class='danger'> \icon[src] [src] bites [target]! </span>")
	else
		// code for handling non-living targets we're attacking. What would even be in this category? Mechs, maybe?
		target.attack_animal(src)
		visible_message("<span class='danger'> \icon[src] [src] bites [target]! </span>")


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: SWARM CLASS, TIER 1, GREEN NURSE -------------
// --------------------------------------------------------------------------------
// -------------: ROLE: reproduction
// -------------: AI: after it kills you, coccoons you and lays new terror eggs on your body
// -------------: SPECIAL: can also create webs, coccoon normal objects, etc
// -------------: TO FIGHT IT: kill it however you like - just don't die to it!
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/EnemySummoner


/mob/living/simple_animal/hostile/poison/terror_spider/green
	name = "green terror spider"
	desc = "An ominous-looking green spider, it has a small egg-sac attached to it."
	altnames = list("Green Terror spider","Insidious Breeding spider","Fast Bloodsucking spider")
	icon_state = "terror_green"
	icon_living = "terror_green"
	icon_dead = "terror_green_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	ventcrawler = 1
	var/fed = 0


/mob/living/simple_animal/hostile/poison/terror_spider/green/handle_automated_action()
	if(!stat && !ckey)
		if(stance == HOSTILE_STANCE_IDLE)
			var/list/can_see = view(src, 10)
			//30% chance to stop wandering and do something
			if(!busy && prob(30))
				//first, check for potential food nearby to cocoon
				for(var/mob/living/C in can_see)
					if(C.stat && C.stat != CONSCIOUS && !istype(C,/mob/living/simple_animal/hostile/poison/terror_spider))
						cocoon_target = C
						busy = MOVING_TO_TARGET
						Goto(C, move_to_delay)
						//give up if we can't reach them after 10 seconds
						GiveUp(C)
						return
				//second, spin a sticky spiderweb on this tile
				var/obj/effect/spider/terrorweb/W = locate() in get_turf(src)
				if(!W)
					Web()
				else
					//third, lay an egg cluster there
					if(fed)
						LayGreenEggs()
					else
						//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
						for(var/obj/O in can_see)
							if(O.anchored)
								continue
							if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery) || istype(O, /obj/item/device/flashlight/lamp))
								cocoon_target = O
								busy = MOVING_TO_TARGET
								stop_automated_movement = 1
								Goto(O, move_to_delay)
								//give up if we can't reach them after 10 seconds
								GiveUp(O)
			else if(busy == MOVING_TO_TARGET && cocoon_target)
				if(get_dist(src, cocoon_target) <= 1)
					Wrap()
		else
			busy = 0
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/terror_spider/green/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to eat (allowing you to lay eggs) and objects (making them inaccessible to humans)."
	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1,src))
			if(L == src)
				continue
			if(Adjacent(L))
				if (L.stat != CONSCIOUS)
					choices += L
		for(var/obj/O in loc)
			if(Adjacent(O))
				choices += O
		cocoon_target = input(src,"What do you wish to cocoon?") in null|choices
	if(cocoon_target && busy != SPINNING_COCOON)
		busy = SPINNING_COCOON
		visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
		stop_automated_movement = 1
		walk(src,0)
		spawn(50)
			if(busy == SPINNING_COCOON)
				if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
					var/obj/effect/spider/cocoon/C = new(cocoon_target.loc)
					var/large_cocoon = 0
					C.pixel_x = cocoon_target.pixel_x
					C.pixel_y = cocoon_target.pixel_y
					for(var/obj/item/I in C.loc)
						I.loc = C
					for(var/obj/structure/S in C.loc)
						if(!S.anchored)
							S.loc = C
							large_cocoon = 1
					for(var/obj/machinery/M in C.loc)
						if(!M.anchored)
							M.loc = C
							large_cocoon = 1
					for(var/mob/living/L in C.loc)
						if(istype(L, /mob/living/simple_animal/hostile/poison/terror_spider))
							continue
						large_cocoon = 1
						fed++
						L.loc = C
						C.pixel_x = L.pixel_x
						C.pixel_y = L.pixel_y
						visible_message("<span class='danger'>\the [src] sticks a proboscis into \the [L] and sucks a viscous substance out.</span>")
						break
					if(large_cocoon)
						C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
			cocoon_target = null
			busy = 0
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/terror_spider/green/verb/LayGreenEggs()
	set name = "Lay Green Eggs"
	set category = "Spider"
	set desc = "Lay a clutch of eggs. You must have wrapped a prey creature for feeding first."
	var/obj/effect/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		src << "<span class='notice'>There is already a cluster of eggs here!</span>"
	else if(!fed)
		src << "<span class='warning'>You are too hungry to do this!</span>"
	else if(busy != LAYING_EGGS)
		busy = LAYING_EGGS
		visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
		stop_automated_movement = 1
		spawn(50)
			if(busy == LAYING_EGGS)
				E = locate() in get_turf(src)
				if(!E)
					if (prob(33))
						DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/red, 2, 1)
					else if (prob(50))
						DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/black, 2, 1)
					else
						DoLayTerrorEggs("green spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/green, 2, 1)
					fed--
			busy = 0
			stop_automated_movement = 0


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: SWARM CLASS, TIER 2, WHITE DEATH --------
// --------------------------------------------------------------------------------
// -------------: ROLE: stealthy reproduction
// -------------: AI: injects a venom that makes you grow spiders in your body, then retreats
// -------------: SPECIAL: stuns you on first attack - vulnerable to groups while it does this
// -------------: TO FIGHT IT: have antivenom in your body - this will instakill it if it bites someone with antivenom in them
// -------------: http://tvtropes.org/pmwiki/pmwiki.php/Main/BodyHorror

/mob/living/simple_animal/hostile/poison/terror_spider/white
	name = "white death spider"
	desc = "An ominous-looking white spider, its ghostly eyes and vicious-looking fangs are the stuff of nightmares."
	altnames = list("White Terror spider","White Death spider","Ghostly Nightmare spider")
	icon_state = "terror_white"
	icon_living = "terror_white"
	icon_dead = "terror_white_dead"
	maxHealth = 100
	health = 100
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 5
	ventcrawler = 1
	var/attackstep = 0
	poison_type = "terror_white_toxin"
	spider_tier = 2


/mob/living/simple_animal/hostile/poison/terror_spider/white/LoseTarget()
	stop_automated_movement = 0
	attackstep = 0
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/white/AttackingTarget()
	// skip all parent attack procs.
	// parent procs produce undesirable effects, like applying spidertoxin, damage, etc. We usually don't want any of those things to happen.
	stop_automated_movement = 1
	if (istype(target,/mob/living/simple_animal/hostile/poison/terror_spider/))
		..()
	else if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			if (attackstep == 0)
				visible_message("<span class='danger'> \icon[src] [src] crouches down on its powerful hind legs! </span>")
				attackstep = 1
			else if (attackstep == 1)
				visible_message("<span class='danger'> \icon[src] [src] pounces on [target], grabbing them with its fangs and legs! </span>")
				L.emote("scream")
				L.drop_l_hand()
				L.drop_r_hand()
				L.Weaken(5) // stunbaton-like stun, floors them
				L.Stun(5)
				attackstep = 2
			else if (attackstep == 2)
				L.adjustBruteLoss(30)
				if (L.reagents.has_reagent("terror_white_antitoxin"))
					visible_message("<span class='danger'> \icon[src] [src] sinks its fangs deep into [target] - and recoils in horror as its fangs burn!</span>")
					//health = min(health,maxHealth/4)
					spawn(50)
						visible_message("<span class='danger'> \icon[src] [src] is torn apart by a violent chemical reaction inside its body!</span>")
						death()
				else if (!L.reagents.has_reagent("terror_white_toxin",5) && !degenerate)
					L.reagents.add_reagent("terror_white_toxin", 10)
					visible_message("<span class='danger'> \icon[src] [src] sinks its fangs deep into [target] - a green froth dribbling from its fangs.</span>")
				else if (L in enemies)
					L.reagents.add_reagent("terror_white_tranq", 15)
					enemies -= L
					visible_message("<span class='danger'> \icon[src] [src] sinks its fangs deep into [target] - a blue froth dribbling from its fangs.</span>")
				else
					visible_message("<span class='danger'> \icon[src] [src] sinks its fangs deep into [target] </span>")
				attackstep = 0
				spawn(20)
					visible_message("<span class='notice'> \icon[src] [src] lets go of [target], and tries to flee! </span>")
					LoseTarget()
					walk_away(src,L,2,1)
					spawn(200)
						stop_automated_movement = 0
					var/vdistance = 99
					for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
						if(!v.welded)
							if (get_dist(src,v) < vdistance)
								entry_vent = v
								vdistance = get_dist(src,v)
								//break
					if(entry_vent)
						path_to_vent = 1
					else
						// Can't escape via vent. Include sedative in our bite, and try to put some distance between us and them. Hopefully, this is enough.
						L.reagents.add_reagent("terror_white_tranq", 15)
						for(var/i=0, i<4, i++)
							step_away(src, L)
			else
				attackstep = 0
		else
			// code for handling mobs that don't process reagents. Possibly dead bodies? Or simple mobs that have no reagent container?
			target.attack_animal(src)
			visible_message("<span class='danger'> \icon[src] [src] bites [target]! </span>")
	else
		// code for handling non-living targets we're attacking. What would even be in this category? Mechs, maybe?
		target.attack_animal(src)
		visible_message("<span class='danger'> \icon[src] [src] bites [target]! </span>")


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 NIGHTMARE CLASS, QUEEN SPIDER ------------
// --------------------------------------------------------------------------------
// -------------: ROLE: gamma-level threat to the whole station, like a blob
// -------------: AI: builds a nest, lays many eggs, attempts to take over the station
// -------------: SPECIAL: spins webs, breaks lights, breaks cameras, coccoons objects, lays eggs, commands other spiders...
// -------------: TO FIGHT IT: bring an army, and take no prisoners. Decloner guns are a very good idea.
// -------------: http://tvtropes.org/pmwiki/pmwiki.php/Main/HiveQueen


/mob/living/simple_animal/hostile/poison/terror_spider/queen
	name = "Queen of Terror spider"
	desc = "An enormous, terrifying spider. Its egg sac is almost as big as its body, and teeming with spider eggs."
	altnames = list("Queen of Terror","Brood Mother")
	icon_state = "terror_queen"
	icon_living = "terror_queen"
	icon_dead = "terror_queen_dead"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_to_delay = 15 // yeah, this is very slow, but
	ventcrawler = 1
	var/fed = 0
	var/spawnfrequency = 1200 // 120 seconds, remember, times are in deciseconds
	var/lastspawn = 0
	var/nestfrequency = 150 // 15 seconds
	var/lastnestsetup = 0
	var/neststep = 0

	var/canlay = 0 // main counter for egg-laying ability! # = num uses, incremented at intervals
	var/spider_can_hallucinate = 5 // single target hallucinate, atmosphere
	var/spider_can_screech = 1 // wide-area 20% chance to break lights, atmosphere
	var/spider_can_fakelings = 3 // spawns defective spiderlings that don't grow up, used to freak out crew, atmosphere

	idle_ventcrawl_chance = 0
	force_threshold = 18 // outright immune to anything of force under 18, this means welders can't hurt it, only guns can

	ai_breaks_lights = 1
	ai_breaks_cameras = 1

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/pierce.ogg'
	projectiletype = /obj/item/projectile/terrorqueenspit

	spider_tier = 3
	spider_opens_doors = 1


/mob/living/simple_animal/hostile/poison/terror_spider/queen/New()
	..()
	if (ai_playercontrol_allowingeneral && ai_playercontrol_allowtype)
		notify_ghosts("A [src] has appeared in [get_area(src)]. <a href=?src=\ref[src];activate=1>(Click to control)</a>")


/mob/living/simple_animal/hostile/poison/terror_spider/queen/Life()
	if (!canlay)
		if (world.time > (lastspawn + spawnfrequency))
			canlay++
			src << "<span class='notice'>You are able to lay eggs again.</span>"
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/queen/death(gibbed)
	// When a queen dies, so do ALL her guardians. Intended as a motivator to ensure they keep her alive.
	if (!gibbed)
		for(var/mob/living/simple_animal/hostile/poison/terror_spider/purple/P in world)
			P.visible_message("<span class='danger'>\the [src] writhes in pain!</span>")
			P << "<span class='userdanger'>\the [src] has died. Without her hivemind link, purple terrors like yourself cannot survive more than a few minutes!</span>"
			P.degenerate = 1
			P.loot = 0
			P.meat_amount = 0
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/queen/handle_automated_action()
	if(!stat && !ckey && stance == HOSTILE_STANCE_IDLE)
		if (neststep >= 1 && prob(33))
			if (get_dist(src,nest_vent) > 6)
				step_to(src,nest_vent)
				visible_message("<span class='notice'>\the [src] retreats towards her nest.</span>")
		else if (neststep == 0)
			// we have no nest :(
			if (prob(10))
				// maybe we want to nest here?
				var/numhostiles = 0
				for (var/mob/living/H in oview(10,src))
					if (!istype(H, /mob/living/simple_animal/hostile/poison/terror_spider))
						if (H.stat != DEAD)
							numhostiles += 1
				var/vdistance = 99
				for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
					if(!v.welded)
						if (get_dist(src,v) < vdistance)
							entry_vent = v
							vdistance = get_dist(src,v)
							//break
				if (entry_vent)
					if (numhostiles > 0)
						visible_message("<span class='danger'>\the [src] looks around warily - then retreats.</span>")
						path_to_vent = 1
					else
						nest_vent = entry_vent
						neststep = 1
						visible_message("<span class='danger'>\the [src] looks around, growing still for a moment.</span>")
				else
					// Somehow, we are somewhere with no vent :/ All we can do is hope that changes.
					// NEED CODE that eventually despawns us after awhile if we can't find a vent - or teleports us to the nearest one.
		else if (neststep == 1)
			if (world.time > (lastnestsetup + nestfrequency))
				lastnestsetup = world.time
				// Could use prison break to lock open doors, but not really in character.
				// prison_break (area proc): https://github.com/ParadiseSS13/Paradise/blob/c7ae1fef0db8acfe4111036d5ff337507b2538ab/code/game/area/areas.dm
				visible_message("<span class='danger'>\the [src] emits a bone-chilling shriek that shatters nearby glass!</span>")
				for(var/obj/machinery/light/L in range(7,src))
					L.on = 1
					L.broken()
				for(var/obj/machinery/camera/C in range(7,src))
					if (C.status)
						C.status = 0
						C.icon_state = "[initial(C.icon_state)]1"
						C.add_hiddenprint(src)
						C.deactivate(src,0)
				neststep = 2
		else if (neststep == 2)
			if (world.time > (lastnestsetup + nestfrequency))
				QueenHallucinate()
				lastnestsetup = world.time
				lastspawn = world.time
				DoLayTerrorEggs("praetorian spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/purple,2,0)
				neststep = 3
		else if (neststep == 3)
			if (world.time > (lastspawn + spawnfrequency))
				if (prob(10))
					var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
					if(!N)
						QueenHallucinate()
						lastspawn = world.time
						DoLayTerrorEggs("nurse spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/green,2,0)
						neststep = 4
		else if (neststep == 3)
			if (world.time > (lastspawn + spawnfrequency))
				if (prob(10))
					var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
					if(!N)
						QueenHallucinate()
						lastspawn = world.time
						DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/black,2,1)
						neststep = 4
		else if (neststep == 4)
			if (world.time > (lastspawn + spawnfrequency))
				if (prob(10))
					var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
					if(!N)
						QueenFakeLings()
						lastspawn = world.time
						DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/red,2,1)
						neststep = 5
		else if (neststep == 5)
			if (world.time > (lastspawn + spawnfrequency))
				if (prob(10))
					var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
					if(!N)
						QueenFakeLings()
						lastspawn = world.time
						if (prob(33))
							DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/black,2,1)
						else if (prob(50))
							DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/red,2,1)
						else
							DoLayTerrorEggs("green spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/green,2,0)
				var/numspiders = 0
				for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in world)
					if (istype(T, (/mob/living/simple_animal/hostile/poison/terror_spider/queen)))
						// We, the queen, do not count.
					else if (T.health < 0)
						// dead spiders do not count either
					else
						numspiders += 1
				if (numspiders >= 15) // station overwhelmed!
					neststep = 6
					//command_announcement.Announce("Anomalous biohazards detected moving throughout station.", "Station Overrun")
		else if (neststep == 6)
			if (world.time > (lastspawn + spawnfrequency))
				lastspawn = world.time
				// go hostile, EXTERMINATE MODE.
				if (spider_can_screech)
					QueenAttackScreech()
				var/numspiders = 0
				for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in world)
					if (T.health > 0)
						numspiders += 1
						if (istype(T, /mob/living/simple_animal/hostile/poison/terror_spider/queen))
						else if (istype(T, /mob/living/simple_animal/hostile/poison/terror_spider/purple))
						else if (T.idle_ventcrawl_chance != 15)
							T.idle_ventcrawl_chance = 15
							T.visible_message("<span class='danger'>\the [src] rises up in fury!</span>")
						if (T.ai_type != 0)
							T.ai_type = 0
				if (numspiders < 15)
					if (prob(33))
						DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/black,2,1)
					else if (prob(50))
						DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/red,2,1)
					else
						DoLayTerrorEggs("green spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/green,2,0)
	//..()
	// might be the source of some bug with the AI getting stuck...

/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/HiveSense()
	set name = "Hive Sense"
	set category = "Spider"
	set desc = "Sense the spiders at your command."
	var/hsline = ""
	src << "Your Brood: "
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in world)
		hsline = "* [T] in [get_area(T)], "
		if (T.health >0)
			hsline += "health [T.health] / [T.maxHealth], "
			if (T.ckey)
				hsline += " *Player Controlled* "
			else
				hsline += " AI: "
				if (T.ai_type == 0)
					hsline += "aggressive"
				else if (T.ai_type == 1)
					hsline += "defensive"
				else if (T.ai_type == 2)
					hsline += "passive"
		else
			hsline += "DEAD"
		src << hsline

/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/HiveCommand()
	set name = "HiveCommand"
	set category = "Spider"
	set desc = "Instruct your brood on proper behavior."
	var/dstance = input("How aggressive should your brood be?") as null|anything in list("Attack Everyone","Defend Themselves","Completely Passive")
	var/dai = input("How often should they use vents?") as null|anything in list("Constantly","Sometimes","Rarely", "Never")
	var/dpc = input("Allow ghosts to inhabit spider bodies?") as null|anything in list("Yes","No")
	var/numspiders = 0
	if (dstance != null && dai != null && dpc != null)
		for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in world)
			numspiders += 1
			if (T.spider_tier >= spider_tier)
			else
				if (dstance == "Attack Everyone")
					if (T.ai_type != 0)
						T.ai_type = 0
						T.visible_message("<span class='danger'>\the [T] looks around angrily.</span>")
						T << "New Orders: <span class='danger'> kill all humanoids on sight </span>"
				else if (dstance == "Defend Themselves")
					if (T.ai_type != 1)
						T.ai_type = 1
						T.visible_message("<span class='notice'>\the [T] takes a defensive stance.</span>")
						T << "Your orders are: <span class='notice'> defend yourself without being aggressive </span> "
				else if (dstance == "Completely Passive")
					if (T.ai_type != 2)
						T.ai_type = 2
						T.visible_message("<span class='notice'>\the [T] looks passive.</span>")
						T << "Your orders are: <span class='danger'> do not attack anyone, not even in self-defense!</span> "
				if (dai == "Constantly")
					T.idle_ventcrawl_chance = 15
					T.visible_message("<span class='danger'>\the [T] seems to move very quickly for a moment.</span>")
				else if (dai == "Sometimes")
					T.idle_ventcrawl_chance = 5
					T.visible_message("<span class='notice'>\the [T] seems to move quickly for a moment.</span>")
				else if (dai == "Rarely")
					T.idle_ventcrawl_chance = 2
					T.visible_message("<span class='notice'>\the [T] seems slow for a moment.</span>")
				else if (dai == "Never")
					T.idle_ventcrawl_chance = 0
					T.visible_message("<span class='notice'>\the [T] seems still for a moment.</span>")
				if (dpc == "Yes")
					if (T.ai_playercontrol_allowingeneral == 0)
						T.ai_playercontrol_allowingeneral = 1
						notify_ghosts("[T.name] in [get_area(T)] can be controlled! <a href=?src=\ref[T];activate=1>(Click to play)</a>")
				else if (dpc == "No")
					T.ai_playercontrol_allowingeneral = 0
		for(var/obj/effect/spider/terror_eggcluster/T in world)
			if (dpc == "Yes")
				T.ai_playercontrol_allowingeneral = 1
			else if (dpc == "No")
				T.ai_playercontrol_allowingeneral = 0
		for(var/obj/effect/spider/terror_spiderling/T in world)
			if (dpc == "Yes")
				T.ai_playercontrol_allowingeneral = 1
			else if (dpc == "No")
				T.ai_playercontrol_allowingeneral = 0
		src << "The spiders obey your command."
	else
		src << "That choice was not recognized."

/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/QueenKillSpider()
	set name = "Kill Spider"
	set category = "Spider"
	set desc = "Kills a nearby spider. If they are player-controlled, also bans them from controlling any other spider for the rest of the round."
	var/choices = list()
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/L in view(1,src))
		if(L == src)
			continue
		if (src.spider_tier < L.spider_tier)
			continue
		if (L.health < 1)
			continue
		if(Adjacent(L))
			if (L.stat == CONSCIOUS)
				choices += L
	var/killtarget = input(src,"Which terror spider should die?") in null|choices
	if (!killtarget)
		// cancel
	else if (!isliving(killtarget))
		src << "[killtarget] is not living."
	else if (!istype(killtarget,/mob/living/simple_animal/hostile/poison/terror_spider/))
		src << "[killtarget] is not a terror spider."
	else
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = killtarget
		if (T.ckey)
			// living player
			for(var/mob/living/simple_animal/hostile/poison/terror_spider/S in world)
				S.spider_ckey_blacklist += T.ckey
		visible_message("<span class='danger'> [src] grabs hold of [T] and tears them limb from limb! </span>")
		T.death()
		T.gib()
		regen_points += regen_points_per_kill

/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/LayQueenEggs()
	set name = "Lay Queen Eggs"
	set category = "Spider"
	set desc = "Grow your brood."
	if (canlay < 1)
		var/remainingtime = round(((lastspawn + spawnfrequency) - world.time) / 10,1)
		if (remainingtime > 0)
			src << "Too soon to attempt that again. Wait another " + num2text(remainingtime) + " seconds."
		else
			src << "Too soon to attempt that again. Wait just a few more seconds..."
		return
	var/list/eggtypes = list("red - assault","gray - ambush", "green - nurse", "black - poison","purple - guard")
	var/eggtype = input("What kind of eggs?") as null|anything in eggtypes
	if (!(eggtype in eggtypes))
		src << "Unrecognized egg type."
		return 0
	var/numlings = 1
	if (canlay >= 5)
		numlings = input("How many in the batch?") as null|anything in list(1,2,3,4,5)
	else if (canlay >= 3)
		numlings = input("How many in the batch?") as null|anything in list(1,2,3)
	else if (canlay == 2)
		numlings = input("How many in the batch?") as null|anything in list(1,2)
	if (eggtype == null || numlings == null)
		src << "Cancelled."
		return
	lastspawn = world.time
	canlay -= numlings
	if (eggtype == "red - assault")
		DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/red,numlings,1)
	else if (eggtype == "gray - ambush")
		DoLayTerrorEggs("gray spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/gray,numlings,1)
	else if (eggtype == "green - nurse")
		DoLayTerrorEggs("green spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/green,numlings,1)
	else if (eggtype == "black - poison")
		DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/black,numlings,1)
	else if (eggtype == "purple - guard")
		DoLayTerrorEggs("green spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/purple,numlings,0)
	else
		src << "Unrecognized egg type."


/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to feast upon and objects for safe keeping."
	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1,src))
			if(L == src)
				continue
			if(Adjacent(L))
				if (L.stat != CONSCIOUS)
					choices += L
		for(var/obj/O in loc)
			if(Adjacent(O))
				choices += O
		cocoon_target = input(src,"What do you wish to cocoon?") in null|choices
	if(cocoon_target && busy != SPINNING_COCOON)
		busy = SPINNING_COCOON
		visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
		stop_automated_movement = 1
		walk(src,0)
		spawn(50)
			if(busy == SPINNING_COCOON)
				if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
					var/obj/effect/spider/cocoon/C = new(cocoon_target.loc)
					var/large_cocoon = 0
					C.pixel_x = cocoon_target.pixel_x
					C.pixel_y = cocoon_target.pixel_y
					for(var/obj/item/I in C.loc)
						I.loc = C
					for(var/obj/structure/S in C.loc)
						if(!S.anchored)
							S.loc = C
							large_cocoon = 1
					for(var/obj/machinery/M in C.loc)
						if(!M.anchored)
							M.loc = C
							large_cocoon = 1
					for(var/mob/living/L in C.loc)
						if(istype(L, /mob/living/simple_animal/hostile/poison/terror_spider))
							continue
						large_cocoon = 1
						L.loc = C
						C.pixel_x = L.pixel_x
						C.pixel_y = L.pixel_y
						fed++
						visible_message("<span class='danger'>\the [src] sticks a proboscis into \the [L] and sucks a viscous substance out.</span>")
						break
					if(large_cocoon)
						C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
			cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/QueenHallucinate()
	set name = "Hallucinate"
	set category = "Spider"
	set desc = "Causes a single crew member to quake in fear."
	if (spider_can_hallucinate)
		spider_can_hallucinate--
		var/choices = list()
		for(var/mob/living/carbon/human/H in player_list)
			if(H == src)
				continue
			if (H.health < 1)
				continue
			choices += L
		if (choices.len < 1)
			return
		var/madnesstarget = pick(choices)
		if (ckey)
			madnesstarget = null
			madnesstarget = input(src,"Which person should fear?") in null|choices
		if (!madnesstarget)
			// cancel
		else if (!isliving(madnesstarget))
			src << "[madnesstarget] is not living."
		else if (!istype(madnesstarget,/mob/living/simple_animal/hostile/poison/terror_spider/))
			src << "[madnesstarget] is not a terror spider."
		else
			madnesstarget.hallucinate = max(madnesstarget.hallucinate,600)
			madnesstarget << "<span class='danger'>Your head throbs in pain.</span>"
			src << "You reach through bluespace into the mind of [madnesstarget], making their fears come to life. They start to hallucinate."
	else
		src << "You have run out of uses of this ability."


/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/QueenAttackScreech()
	set name = "AOE Break Lights"
	set category = "Spider"
	set desc = "Emit horrendusly loud screech which has a 25% chance to break lights over a huge radius. Good for using just before you order an attack with HiveCommand. Can only be used once."
	if (spider_can_screech)
		spider_can_screech--
		for(var/obj/machinery/light/L in orange(40,src))
			if (prob(25))
				L.on = 1
				L.broken()
		//for(var/obj/machinery/camera/C in orange(14,src))
		//	if (C.status)
		//		C.status = 0
		//		C.icon_state = "[initial(C.icon_state)]1"
		//		C.add_hiddenprint(src)
		//		C.deactivate(src,0)
	else
		src << "You have already used your screech."

/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/QueenFakeLings()
	set name = "Fake Spiderlings"
	set category = "Spider"
	set desc = "Animates some damaged spiderlings to crawl throughout the station and panic the crew. Sows fear. These spiderlings never mature. Ability can only be used 3 times."
	if (spider_can_fakelings)
		spider_can_fakelings--
		var/numlings = 15
		for(var/i=0, i<numlings, i++)
			var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
			S.grow_as = /mob/living/simple_animal/hostile/poison/terror_spider/red
			S.stillborn = 1
			S.name = "Evil-Looking Spiderling"
			S.desc = "It moves very quickly, hisses loudly for its size... and has disproportionately large fangs. Hopefully it does not grow up..."
	else
		src << "You have run out of uses of this ability."

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 NIGHTMARE CLASS, MOTHER WOLF SPIDER -------
// --------------------------------------------------------------------------------
// -------------: ROLE: living schmuck bait
// -------------: AI: no special ai
// -------------: SPECIAL: spawns an ungodly number of spiderlings when killed
// -------------: TO FIGHT IT: don't! Just leave it alone! It is harmless by itself... but god help you if you aggro it.
// -------------: http://tvtropes.org/pmwiki/pmwiki.php/Main/MotherOfAThousandYoung


/mob/living/simple_animal/hostile/poison/terror_spider/mother
	name = "mother of terror spider"
	desc = "An enormous spider. Its back is a crawling mass of spiderlings. All of them look around with beady little eyes. The horror!"
	altnames = list("Seemingly Harmless spider","Strange spider","Mother spider")
	icon_state = "terror_queen"
	icon_living = "terror_queen"
	icon_dead = "terror_queen_dead"
	maxHealth = 50
	health = 50
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_to_delay = 5
	ventcrawler = 1
	idle_ventcrawl_chance = 5
	ai_type = 1 // defend self only!

	spider_tier = 3
	spider_opens_doors = 2

	var/canspawn = 1

/mob/living/simple_animal/hostile/poison/terror_spider/mother/death(gibbed)
	if (canspawn)
		canspawn = 0
		for(var/i=0, i<30, i++)
			var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
			S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red,/mob/living/simple_animal/hostile/poison/terror_spider/gray,/mob/living/simple_animal/hostile/poison/terror_spider/green)
			if (prob(50))
				S.stillborn = 1
			else if (prob(10))
				S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/black,/mob/living/simple_animal/hostile/poison/terror_spider/white)
		visible_message("<span class='userdanger'>\the [src] breaks apart, the many spiders on its back scurrying everywhere!</span>")
		degenerate = 1
		loot = 0
		meat_amount = 0
	..()


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T4 LOVECRAFT CLASS, SPIDER EMPRESS -----------
// --------------------------------------------------------------------------------
// -------------: ROLE: ruling over planets of uncountable spiders, like Xenomorph Empresses.
// -------------: AI: none - this is strictly adminspawn-only and intended for RP events, coder testing, and teaching people 'how to queen'
// -------------: SPECIAL: Lay Eggs ability that allows laying queen-level eggs. Wide-area EMP and light-breaking abilities.
// -------------: TO FIGHT IT: uh... call the shuttle?
// -------------: TROPE: http://tvtropes.org/pmwiki/pmwiki.php/Main/AuthorityEqualsAsskicking


/mob/living/simple_animal/hostile/poison/terror_spider/empress
	name = "Empress of Terror"
	desc = "The unholy offspring of spiders, nightmares, and lovecraft fiction."
	altnames = list ("terror empress spider")

	icon_state = "terror_queen"
	icon_living = "terror_queen"
	icon_dead = "terror_queen_dead"

	// DO NOT ENABLE THIS UNTIL WE HAVE NEW SPRITES. THE EXISTING SPRITES AT THIS SIZE AREN'T USABLE.
	//icon_state = "terrorempress_s"
	//icon_living = "terrorempress_s"
	//icon_dead = "terrorempress_dead"
	//icon = 'icons/mob/terrorspiderlarge.dmi'
	//pixel_x = -32

	maxHealth = 700
	health = 700

	melee_damage_lower = 10
	melee_damage_upper = 40

	move_to_delay = 5
	ventcrawler = 0 // TOO BIG!

	idle_ventcrawl_chance = 0
	ai_playercontrol_allowtype = 0
	ai_type = 1 // defend self only!

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/pierce.ogg'
	projectiletype = /obj/item/projectile/terrorempressspit
	force_threshold = 18 // same as queen, but a lot more health

	spider_tier = 4



/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/LayEmpressEggs()
	set name = "Lay Empress Eggs"
	set category = "Spider"
	set desc = "Lay spider eggs. As empress, you can lay queen-level eggs to create a new brood."
	var/eggtype = input("What kind of eggs?") as null|anything in list("QUEEN", "MOTHER", "red - assault","gray - ambush", "green - nurse", "black - poison","purple - guard")
	var/numlings = input("How many in the batch?") as null|anything in list(1,2,3,4,5,10,15,20,30,40,50)
	if (eggtype == null || numlings == null)
		src << "Cancelled."
		return
	// T1
	if (eggtype == "red - assault")
		DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/red,numlings,1)
	else if (eggtype == "gray - ambush")
		DoLayTerrorEggs("gray spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/gray,numlings,1)
	else if (eggtype == "green - nurse")
		DoLayTerrorEggs("green spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/green,numlings,1)
	// T2
	else if (eggtype == "black - poison")
		DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/black,numlings,1)
	else if (eggtype == "purple - guard")
		DoLayTerrorEggs("green spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/purple,numlings,0)
	// T3
	else if (eggtype == "QUEEN")
		DoLayTerrorEggs("strange spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/queen,numlings,1)
	else if (eggtype == "MOTHER")
		DoLayTerrorEggs("strange spider eggs", /mob/living/simple_animal/hostile/poison/terror_spider/mother,numlings,1)
	// Unrecognized
	else
		src << "Unrecognized egg type."

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/HiveSense()
	set name = "Hive Sense"
	set category = "Spider"
	set desc = "Sense the spiders at your command."
	var/hsline = ""
	src << "Your Brood: "
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in world)
		hsline = "* [T] in [get_area(T)], "
		if (T.health >0)
			hsline += "health [T.health] / [T.maxHealth], "
			if (T.ckey)
				hsline += " *Player Controlled* "
			else
				hsline += " AI: "
				if (T.ai_type == 0)
					hsline += "aggressive"
				else if (T.ai_type == 1)
					hsline += "defensive"
				else if (T.ai_type == 2)
					hsline += "passive"
		else
			hsline += "DEAD"
		src << hsline

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/HiveCommand()
	set name = "HiveCommand"
	set category = "Spider"
	set desc = "Instruct your brood on proper behavior."
	var/dstance = input("How aggressive should your brood be?") as null|anything in list("Attack Everyone","Defend Themselves","Completely Passive")
	var/dai = input("How often should they use vents?") as null|anything in list("Constantly","Sometimes","Rarely", "Never")
	var/dpc = input("Allow ghosts to inhabit spider bodies?") as null|anything in list("Yes","No")
	var/numspiders = 0
	if (dstance != null && dai != null && dpc != null)
		for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in world)
			numspiders += 1
			if (T.spider_tier >= spider_tier)
			else
				if (dstance == "Attack Everyone")
					if (T.ai_type != 0)
						T.ai_type = 0
						T.visible_message("<span class='danger'>\the [T] looks around angrily.</span>")
						T << "New Orders: <span class='danger'> kill all humanoids on sight </span>"
				else if (dstance == "Defend Themselves")
					if (T.ai_type != 1)
						T.ai_type = 1
						T.visible_message("<span class='notice'>\the [T] takes a defensive stance.</span>")
						T << "Your orders are: <span class='notice'> defend yourself without being aggressive </span> "
				else if (dstance == "Completely Passive")
					if (T.ai_type != 2)
						T.ai_type = 2
						T.visible_message("<span class='notice'>\the [T] looks passive.</span>")
						T << "Your orders are: <span class='danger'> do not attack anyone, not even in self-defense!</span> "
				if (dai == "Constantly")
					T.idle_ventcrawl_chance = 15
					T.visible_message("<span class='danger'>\the [T] seems to move very quickly for a moment.</span>")
				else if (dai == "Sometimes")
					T.idle_ventcrawl_chance = 5
					T.visible_message("<span class='notice'>\the [T] seems to move quickly for a moment.</span>")
				else if (dai == "Rarely")
					T.idle_ventcrawl_chance = 2
					T.visible_message("<span class='notice'>\the [T] seems slow for a moment.</span>")
				else if (dai == "Never")
					T.idle_ventcrawl_chance = 0
					T.visible_message("<span class='notice'>\the [T] seems still for a moment.</span>")
				if (dpc == "Yes")
					if (T.ai_playercontrol_allowingeneral == 0)
						T.ai_playercontrol_allowingeneral = 1
						notify_ghosts("[T.name] in [get_area(T)] can be controlled! <a href=?src=\ref[T];activate=1>(Click to play)</a>")
				else if (dpc == "No")
					T.ai_playercontrol_allowingeneral = 0
		for(var/obj/effect/spider/terror_eggcluster/T in world)
			if (dpc == "Yes")
				T.ai_playercontrol_allowingeneral = 1
			else if (dpc == "No")
				T.ai_playercontrol_allowingeneral = 0
		for(var/obj/effect/spider/terror_spiderling/T in world)
			if (dpc == "Yes")
				T.ai_playercontrol_allowingeneral = 1
			else if (dpc == "No")
				T.ai_playercontrol_allowingeneral = 0
		src << "The spiders obey your command."
	else
		src << "That choice was not recognized."

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EMPShockwave()
	set name = "EMP Shockwave"
	set category = "Spider"
	set desc = "Emit a wide-area emp pulse, frying almost all electronics in a huge radius."
	empulse(src.loc,10,25)


/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressScreech()
	set name = "Empress Screech"
	set category = "Spider"
	set desc = "Emit horrendusly loud screech which breaks lights and cameras in a massive radius. Good for making a spider nest in a pinch."
	for(var/obj/machinery/light/L in range(14,src))
		L.on = 1
		L.broken()
	for(var/obj/machinery/camera/C in range(14,src))
		if (C.status)
			C.status = 0
			C.icon_state = "[initial(C.icon_state)]1"
			C.add_hiddenprint(src)
			C.deactivate(src,0)

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressMassHallucinate()
	set name = "Mass Hallucinate"
	set category = "Spider"
	set desc = "Causes widespread, terrifying hallucinations amongst many crew as you assault their minds."
	var/choices = list()
	for(var/mob/living/carbon/human/H in player_list)
		if (H.health < 1)
			// nothing
		else if (prob(50))
			// nothing
		else if (prob(50))
			// weak
			H.hallucination = max(300, H.hallucination)
			H << "<span class='userdanger'> Your head hurts! </span>"
		else
			// strong
			H.hallucination = max(600, H.hallucination)
			H << "<span class='userdanger'> Your head hurts! </span>"
	src << "You reach through bluespace into the minds of the crew, making their fears come to life. Many of them start to hallucinate."


/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressKillSpider()
	set name = "Erase Spider"
	set category = "Spider"
	set desc = "Kills a spider. If they are player-controlled, also bans them from controlling any other spider for the rest of the round."
	var/choices = list()
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/L in world)
		if(L == src)
			continue
		if (L.health < 1)
			continue
		choices += L
	var/killtarget = input(src,"Which terror spider should die?") in null|choices
	if (!killtarget)
		// cancel
	else if (!isliving(killtarget))
		src << "[killtarget] is not living."
	else if (!istype(killtarget,/mob/living/simple_animal/hostile/poison/terror_spider/))
		src << "[killtarget] is not a terror spider."
	else
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = killtarget
		if (T.ckey)
			// living player
			for(var/mob/living/simple_animal/hostile/poison/terror_spider/S in world)
				S.spider_ckey_blacklist += T.ckey
		T << "<span class='userdanger'> Through the hivemind, the raw power of [src] floods into your body, burning it from the inside out! </span>"
		T.death()
		T.gib()

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EraseBrood()
	set name = "Erase Brood"
	set category = "Spider"
	set desc = "Debug: kill off all other spiders in the world. Takes two minutes to work."
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in world)
		if (T.spider_tier < 4)
			T.degenerate = 1
			T.loot = 0
			T.meat_amount = 0
			T << "<span class='userdanger'> Through the hivemind, the raw power of [src] floods into your body, burning it from the inside out! </span>"
			//T.Stun(20)
			//T.Weaken(20)
	for(var/obj/effect/spider/terror_eggcluster/T in world)
		qdel(T)
	for(var/obj/effect/spider/terror_spiderling/T in world)
		T.stillborn = 1
	src << "Brood will die off shortly."
	//for (var/obj/effect/spider/terrorweb/T in world)
	//	qdel(T)

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/SpiderlingFlood()
	set name = "Spiderling Flood"
	set category = "Spider"
	set desc = "Debug: Spawns N spiderlings. They grow into random spider types (red/green/gray/white/black). Pure horror!"
	var/numlings = input("How many?") as null|anything in list(10,20,30,40,50)
	var/sbpc = input("%chance to be stillborn?") as null|anything in list(0,25,50,75,100)
	for(var/i=0, i<numlings, i++)
		var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
		S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red,/mob/living/simple_animal/hostile/poison/terror_spider/gray,/mob/living/simple_animal/hostile/poison/terror_spider/green,/mob/living/simple_animal/hostile/poison/terror_spider/white,/mob/living/simple_animal/hostile/poison/terror_spider/black)
		if (prob(sbpc))
			S.stillborn = 1


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: EGGS (USED BY NURSE AND QUEEN TYPES) ---------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoLayTerrorEggs(var/lay_name, var/lay_type, var/lay_number, var/lay_crawl)
	stop_automated_movement = 1
	var/obj/effect/spider/terror_eggcluster/C = new /obj/effect/spider/terror_eggcluster(get_turf(src))
	C.spiderling_type = lay_type
	C.spiderling_number = lay_number
	C.spiderling_ventcrawl = lay_crawl
	C.name = lay_name
	C.faction = faction
	C.master_commander = master_commander
	C.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
	C.enemies = enemies
	if (spider_growinstantly)
		C.amount_grown = 250
		C.spider_growinstantly = 1
	spawn(10)
		stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/terror_spider/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = 0
			stop_automated_movement = 0


/obj/effect/spider/terror_eggcluster
	name = "giant egg cluster"
	desc = "A cluster of tiny spider eggs. They pulse with a strong inner life, and appear to have sharp thorns on the sides."
	icon_state = "eggs"
	var/amount_grown = 0
	var/spider_growinstantly = 0
	var/faction = list()
	var/master_commander = null
	var/spiderling_type = null
	var/spiderling_number = 1
	var/spiderling_ventcrawl = 1
	var/ai_playercontrol_allowingeneral = 1
	var/list/enemies = list()


/obj/effect/spider/terror_eggcluster/New()
	pixel_x = rand(3,-3)
	pixel_y = rand(3,-3)
	processing_objects.Add(src)


/obj/effect/spider/terror_eggcluster/process()
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		var/num = spiderling_number
		for(var/i=0, i<num, i++)
			var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
			if (spiderling_type)
				S.grow_as = spiderling_type
			if (spiderling_ventcrawl)
				S.use_vents = spiderling_ventcrawl
			if (S.grow_as == "/mob/living/simple_animal/hostile/poison/terror_spider/queen")
				S.name = "queen spiderling"
			else if (S.grow_as == "/mob/living/simple_animal/hostile/poison/terror_spider/red")
				S.name = "red spiderling"
			else if (S.grow_as == "/mob/living/simple_animal/hostile/poison/terror_spider/black")
				S.name = "black spiderling"
			else if (S.grow_as == "/mob/living/simple_animal/hostile/poison/terror_spider/green")
				S.name = "green spiderling"
			else if (S.grow_as == "/mob/living/simple_animal/hostile/poison/terror_spider/purple")
				S.name = "purple spiderling"
			else if (S.grow_as == "/mob/living/simple_animal/hostile/poison/terror_spider/white")
				S.name = "white spiderling"
			S.faction = faction
			S.master_commander = master_commander
			S.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
			S.enemies = enemies
			if (spider_growinstantly)
				S.amount_grown = 250
		var/rnum = 5 - spiderling_number
		for(var/i=0, i<rnum, i++)
			var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
			S.stillborn = 1
			// the idea is that every set of eggs always spawn 5 spiderlings, but most are not going to grow up, just some do.
		qdel(src)


/obj/effect/spider/terror_spiderling
	name = "spiderling"
	desc = "A fast-moving tiny spider, prone to making aggressive hissing sounds. Hope it doesn't grow up."
	icon_state = "spiderling"
	anchored = 0
	layer = 2.75
	health = 3
	var/amount_grown = 0
	var/grow_as = null
	var/stillborn = 0
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/faction = list()
	var/master_commander = null
	var/use_vents = 1
	var/ai_playercontrol_allowingeneral = 1
	var/list/enemies = list()


/obj/effect/spider/terror_spiderling/New()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	processing_objects.Add(src)


/obj/effect/spider/terror_spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		loc = user.loc
	else
		..()


/obj/effect/spider/terror_spiderling/proc/die()
	visible_message("<span class='alert'>[src] dies!</span>")
	new /obj/effect/decal/cleanable/spiderling_remains(loc)
	qdel(src)


/obj/effect/spider/terror_spiderling/healthcheck()
	if(health <= 0)
		die()


/obj/effect/spider/terror_spiderling/process()
	if(travelling_in_vent)
		if(istype(loc, /turf))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			if(prob(50))
				visible_message("<B>[src] scrambles into the ventillation ducts!</B>", \
								"<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
			spawn(rand(20,60))
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)
					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return
					if(prob(50))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					spawn(travel_time)
						if(!exit_vent || exit_vent.welded)
							loc = entry_vent
							entry_vent = null
							return
						loc = exit_vent.loc
						entry_vent = null
						var/area/new_area = get_area(loc)
						if(new_area)
							new_area.Entered(src)
	//=================
	else if(prob(33))
		var/list/nearby = oview(10, src)
		if(nearby.len)
			var/target_atom = pick(nearby)
			walk_to(src, target_atom)
			if(prob(40))
				visible_message("<span class='notice'>\The [src] skitters[pick(" away"," around","")].</span>")
	else if(prob(10) && use_vents)
		//ventcrawl!
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				walk_to(src, entry_vent, 1)
				break
	if(isturf(loc))
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			if (stillborn)
				die()
			else
				if(!grow_as)
					grow_as = pick("/mob/living/simple_animal/hostile/poison/terror_spider/red","/mob/living/simple_animal/hostile/poison/terror_spider/gray","/mob/living/simple_animal/hostile/poison/terror_spider/green")
				var/mob/living/simple_animal/hostile/poison/terror_spider/S = new grow_as(loc)
				S.faction = faction
				S.master_commander = master_commander
				S.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
				S.enemies = enemies
				if (S.ai_playercontrol_allowingeneral)
					notify_ghosts("[S.name] in [get_area(src)] can be controlled! <a href=?src=\ref[S];activate=1>(Click to play)</a>")
					// pulling ghosts without asking is dumb. This method ensures we get players who aren't AFK.
				qdel(src)

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: PROJECTILES ----------------------------------
// --------------------------------------------------------------------------------


/obj/item/projectile/terrorqueenspit
	name = "poisonous spit"
	damage = 30
	icon_state = "toxin"
	damage_type = TOX


/obj/item/projectile/terrorqueenspit/on_hit(var/mob/living/carbon/target)
	if(istype(target,/mob))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent("terror_queen_toxin",15)


/obj/item/projectile/terrorempressspit
	name = "poisonous spit"
	damage = 30
	icon_state = "toxin"
	damage_type = TOX


/obj/item/projectile/terrorempressspit/on_hit(var/mob/living/carbon/target)
	if(istype(target,/mob))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent("terror_empress_toxin",15)
		//options:
		//               terror_white_tranq, 0.1 metabolism, paralysis, cycle >= 10
		//               sodium_thiopental, 0.7 metabolism, paralysis, cycle >= 5
		//               ketamine, 0.8 metabolism, paralysis, cycle >= 10
		//               Coniine, 0.05 metabolism, rapid respitory failure


/obj/effect/spider/terrorweb
	name = "terror web"
	desc = "it's stringy and sticky"
	icon = 'icons/effects/effects.dmi'
	anchored = 1 // prevents people dragging it
	density = 0 // prevents it blocking all movement
	health = 20 // two welders, or one laser shot (15 for the normal spider webs)
	icon_state = "stickyweb1"


/obj/effect/spider/terrorweb/New()
	if(prob(50))
		icon_state = "stickyweb2"


/obj/effect/spider/terrorweb/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover, /mob/living/simple_animal/hostile/poison/terror_spider))
		return 1
	else if (istype(mover, /obj/item/projectile/terrorqueenspit))
		return 1
	else if (istype(mover, /obj/item/projectile/terrorempressspit))
		return 1
	else if(istype(mover, /mob/living))
		if(prob(80)) // from 50% chance to pass, to 80%. 50% = you get through in 1-2 tries. 90% = takes you ~5 tries.
			mover << "<span class='danger'>You get stuck in \the [src] for a moment.</span>"
			var/mob/living/M = mover
			M.Stun(1) // 1 second.
			return 0
	else if(istype(mover, /obj/item/projectile))
		return prob(20)
	return 1


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: LOOT DROPS -----------------------------------
// --------------------------------------------------------------------------------

// https://en.wikipedia.org/wiki/Chelicerae
/obj/item/weapon/terrorspider_fang
	name = "terror fang"
	desc = "An enormous fang, sharp as a good sword and far creepier."
	icon = 'icons/mob/animal.dmi'
	icon_state = "terror_fang"
	sharp = 1
	edge = 1
	w_class = 1.0
	force = 15.0 // quite robust. This can get upgraded to 20 for red fangs.
	throwforce = 5.0 // weak - it is too heavy.
	throw_speed = 3
	throw_range = 5
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'


/obj/item/clothing/suit/armor/terrorspider_carapace
	name = "spider carapace armor"
	desc = "A carved section of terror spider carapace that can be used as crude body armor."
	icon_state = "armor-combat"
	item_state = "bulletproof"
	//DEFAULT VALUES: armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	armor = list(melee = 50, bullet = 30, laser = 30, energy = 30, bomb = 25, bio = 0, rad = 0)
	// better against bullets (terror spiders had to fight off syndies), worse against lasers, better against energy, same otherwise.

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
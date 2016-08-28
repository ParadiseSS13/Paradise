
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
	loot = list()

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
	var/ai_target_method = TS_DAMAGE_SIMPLE

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

	var/freq_cocoon_object = 1200 // two minutes between each attempt
	var/last_cocoon_object = 0 // leave this, changed by procs.

	var/prob_ai_hides_in_vents = 15 // probabily of a gray spider hiding in a vent

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
	var/spider_tier = TS_TIER_1 // 1 for red,gray,green. 2 for purple,black,white, 3 for prince, mother. 4 for queen, 5 for empress.
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
// --------------------- TERROR SPIDERS: SHARED ATTACK CODE -----------------------
// --------------------------------------------------------------------------------



/mob/living/simple_animal/hostile/poison/terror_spider/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/hostile/poison/terror_spider))
		if(target in enemies)
			enemies -= target
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = target
		if(T.spider_tier > spider_tier)
			visible_message("<span class='notice'>[src] bows in respect for the terrifying presence of [target]</span>")
		else if(T.spider_tier == spider_tier)
			visible_message("<span class='notice'>[src] harmlessly nuzzles [target].</span>")
		else if(T.spider_tier < spider_tier && spider_tier >= 4)
			visible_message("<span class='notice'>[src] gives [target] a stern look.</span>")
		else
			visible_message("<span class='notice'>[src] harmlessly nuzzles [target].</span>")
		T.CheckFaction()
		CheckFaction()
	else if(istype(target, /obj/effect/spider/cocoon))
		to_chat(src, "Destroying our own cocoons would not help us.")
	else if(istype(target, /obj/machinery/camera))
		if(player_breaks_cameras)
			var/obj/machinery/camera/C = target
			if(C.status)
				do_attack_animation(C)
				C.toggle_cam(src, 0)
				visible_message("<span class='danger'>\The [src] smashes the [C.name].</span>")
				playsound(loc, 'sound/weapons/slash.ogg', 100, 1)
			else
				to_chat(src, "The camera is already deactivated.")
		else
			to_chat(src, "Your type of spider cannot break cameras.")
	else if(istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = target
		if(F.density)
			if(F.blocked)
				to_chat(src, "The fire door is welded shut.")
			else
				visible_message("<span class='danger'>\The [src] pries open the firedoor!</span>")
				F.open()
		else
			to_chat(src, "Closing fire doors does not help.")
	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		if(A.density)
			try_open_airlock(A)
	else if(ai_type == TS_AI_PASSIVE)
		to_chat(src, "Your current orders forbid you from attacking anyone.")
	else if(ai_type == TS_AI_DEFENSIVE && !(target in enemies))
		to_chat(src, "Your current orders only allow you to defend yourself - not initiate combat.")
	else if(isliving(target))
		var/mob/living/G = target
		if(issilicon(G))
			G.attack_animal(src)
			return
		else if(G.reagents && (iscarbon(G)))
			var/can_poison = 1
			if(istype(G, /mob/living/carbon/human/))
				var/mob/living/carbon/human/H = G
				if(H.dna)
					if(!(H.species.reagent_tag & PROCESS_ORG) || (H.species.flags & NO_POISON))
						can_poison = 0
			spider_specialattack(G,can_poison)
		else
			G.attack_animal(src)
	else
		target.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/spider_specialattack(var/mob/living/carbon/human/L, var/poisonable)
	L.attack_animal(src)






// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: PROC OVERRIDES ---------------------------
// --------------------------------------------------------------------------------


/mob/living/simple_animal/hostile/poison/terror_spider/examine(mob/user)
	..()
	var/msg = ""
	if(stat == DEAD)
		msg += "<span class='deadsay'>It appears to be dead.</span>\n"
	else
		if(key)
			msg += "<BR><span class='warning'>Its eyes regard you with a curious intelligence.</span>"
		if(ai_type == TS_AI_AGGRESSIVE)
			msg += "<BR><span class='warning'>It appears aggressive.</span>"
		if(ai_type == TS_AI_DEFENSIVE)
			msg += "<BR><span class='notice'>It appears defensive.</span>"
		if(ai_type == TS_AI_PASSIVE)
			msg += "<BR><span class='notice'>It appears passive.</span>"

		if(health > (maxHealth*0.95))
			msg += "<BR><span class='notice'>It is in excellent health.</span>"
		else if(health > (maxHealth*0.75))
			msg += "<BR><span class='notice'>It has a few injuries.</span>"
		else if(health > (maxHealth*0.55))
			msg += "<BR><span class='warning'>It has many injuries.</span>"
		else if(health > (maxHealth*0.25))
			msg += "<BR><span class='warning'>It is barely clinging on to life!</span>"
		if(degenerate)
			msg += "<BR><span class='warning'>It appears to be dying.</span>"
		else if(health < maxHealth && regen_points > regen_points_per_kill)
			msg += "<BR><span class='notice'>It appears to be regenerating quickly</span>"
		if(killcount == 1)
			msg += "<BR><span class='warning'>It is soaked in the blood of its prey.</span>"
		if(killcount > 1)
			msg += "<BR><span class='warning'>It is soaked with the blood of " + num2text(killcount) + " prey it has killed.</span>"
	to_chat(usr,msg)


/mob/living/simple_animal/hostile/poison/terror_spider/New()
	..()
	ts_spiderlist += src
	if(type == /mob/living/simple_animal/hostile/poison/terror_spider)
		message_admins("[src] spawned in [get_area(src)] - a subtype should have been spawned instead.")
		qdel(src)
	else
		add_language("TerrorSpider")
		add_language("Galactic Common")
		default_language = all_languages["TerrorSpider"]

		name += " ([rand(1, 1000)])"
		msg_terrorspiders("[src] has grown in [get_area(src)].")
		if(name_usealtnames)
			name = pick(altnames)
		if(is_away_level(z))
			spider_awaymission = 1
			if(spider_tier >= 3)
				ai_ventcrawls = 0 // means that pre-spawned bosses on away maps won't ventcrawl. Necessary to keep prince/mother in one place.
			if(istype(get_area(src), /area/awaymission/UO71)) // if we are playing the away mission with our special spiders...
				spider_uo71 = 1
				if(world.time < 600)
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
			if(spider_awaymission)
				return
			else if(ckey)
				notify_ghosts("[src] has appeared in [get_area(src)]. (already player-controlled)")
			else if(ai_playercontrol_allowingeneral && ai_playercontrol_allowtype)
				notify_ghosts("[src] has appeared in [get_area(src)].", enter_link = "<a href=?src=\ref[src];activate=1>(Click to control)</a>", source = src)

/mob/living/simple_animal/hostile/poison/terror_spider/Destroy()
	ts_spiderlist -= src
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/Life()
	if(stat != DEAD)
		if(degenerate > 0)
			adjustToxLoss(rand(1,10))
		if(regen_points < regen_points_max)
			regen_points += regen_points_per_tick
		if((bruteloss > 0) || (fireloss > 0))
			if(regen_points > regen_points_per_hp)
				if(bruteloss > 0)
					adjustBruteLoss(-1)
					regen_points -= regen_points_per_hp
				else if(fireloss > 0)
					adjustFireLoss(-1)
					regen_points -= regen_points_per_hp
		if(prob(5))
			CheckFaction()
	else if(stat == DEAD)
		if(prob(2))
			// 2% chance every cycle to decompose
			visible_message("<span class='notice'>\The dead body of the [src] decomposes!</span>")
			gib()
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/death(gibbed)
	if(!gibbed)
		msg_terrorspiders("[src] has died in [get_area(src)].")
		//if(!ckey && spider_tier < 3)
		//	say(pick("Mistresssss will end you...", "Doom waitssss... for you...","She comessssss for your flesh..."))
	if(!hasdroppedloot)
		hasdroppedloot = 1
		if(ts_count_dead == 0)
			visible_message("<span class='userdanger'>The Terrors have awoken!</span>")
		ts_count_dead++
		ts_death_last = world.time
		if(spider_awaymission)
			ts_count_alive_awaymission--
		else
			ts_count_alive_station--
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/proc/spider_special_action()
	// Do nothing, this proc only exists to be overriden

/mob/living/simple_animal/hostile/poison/terror_spider/Bump(atom/A)
	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/L = A
		if(L.density)
			try_open_airlock(L)
	if(istype(A, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = A
		if(F.density && !F.blocked)
			F.open()
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/msg_terrorspiders(var/msgtext)
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if(T.stat != DEAD)
			to_chat(T, "<span class='terrorspider'>TerrorSense: " + msgtext + "</span>")
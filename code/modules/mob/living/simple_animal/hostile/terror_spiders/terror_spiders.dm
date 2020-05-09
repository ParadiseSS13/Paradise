GLOBAL_LIST_EMPTY(ts_ckey_blacklist)
GLOBAL_VAR_INIT(ts_count_dead, 0)
GLOBAL_VAR_INIT(ts_count_alive_awaymission, 0)
GLOBAL_VAR_INIT(ts_count_alive_station, 0)
GLOBAL_VAR_INIT(ts_death_last, 0)
GLOBAL_VAR_INIT(ts_death_window, 9000) // 15 minutes
GLOBAL_LIST_EMPTY(ts_spiderlist)
GLOBAL_LIST_EMPTY(ts_egg_list)
GLOBAL_LIST_EMPTY(ts_spiderling_list)

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: DEFAULTS ---------------------------------
// --------------------------------------------------------------------------------
// Because: http://tvtropes.org/pmwiki/pmwiki.php/Main/SpidersAreScary

/mob/living/simple_animal/hostile/poison/terror_spider
	// Name / Description
	name = "terror spider"
	desc = "The generic parent of all other terror spider types. If you see this in-game, it is a bug."

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
	a_intent = INTENT_HARM

	// Movement
	pass_flags = PASSTABLE
	turns_per_move = 3 // number of turns before AI-controlled spiders wander around. No effect on actual player or AI movement speed!
	move_to_delay = 6
	// AI spider speed at chasing down targets. Higher numbers mean slower speed. Divide 20 (server tick rate / second) by this to get tiles/sec.
	// 5 = 4 tiles/sec, 6 = 3.3 tiles/sec. 3 = 6.6 tiles/sec.

	// Player spider movement speed is controlled by the 'speed' var.
	// Higher numbers mean slower speed. Can be negative for major speed increase. Call movement_delay() on mob to convert this var to into a step delay.
	// '-1' (default for fast humans) converts to 1.5 or 6.6 tiles/sec
	// '0' (default for human mobs) converts to 2.5, or 4 tiles/sec.
	// '1' (default for most simple_mobs, including terror spiders) converts to 3.5, or 2.8 tiles/sec.
	// '2' converts to 4.5, or 2.2 tiles/sec.

	// Ventcrawling
	ventcrawler = 1 // allows player ventcrawling
	var/ai_ventcrawls = TRUE
	var/idle_ventcrawl_chance = 15
	var/freq_ventcrawl_combat = 1800 // 3 minutes
	var/freq_ventcrawl_idle =  9000 // 15 minutes
	var/last_ventcrawl_time = -9000 // Last time the spider crawled. Used to prevent excessive crawling. Setting to freq*-1 ensures they can crawl once on spawn.
	var/ai_ventbreaker = 0

	// AI movement tracking
	var/spider_steps_taken = 0 // leave at 0, its a counter for ai steps taken.
	var/spider_max_steps = 15 // after we take X turns trying to do something, give up!

	// Speech
	speak_chance = 0 // quiet but deadly
	speak_emote = list("hisses")
	emote_hear = list("hisses")

	// Sentience Type
	sentience_type = SENTIENCE_OTHER

	// Languages are handled in terror_spider/New()

	// Interaction keywords
	response_help  = "pets"
	response_disarm = "gently pushes aside"

	// regeneration settings - overridable by child classes
	var/regen_points = 0 // number of regen points they have by default
	var/regen_points_max = 100 // max number of points they can accumulate
	var/regen_points_per_tick = 1 // gain one regen point per tick
	var/regen_points_per_kill = 90 // gain extra regen points if you kill something
	var/regen_points_per_hp = 3 // every X regen points = 1 health point you can regen
	// desired: 20hp/minute unmolested, 40hp/min on food boost, assuming one tick every 2 seconds
	//          90/kill means bonus 30hp/kill regenerated over the next 1-2 minutes

	var/degenerate = 0 // if 1, they slowly degen until they all die off. Used by high-level abilities only.

	// Vision
	vision_range = 10
	aggro_vision_range = 10
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_MOBS

	// AI aggression settings
	var/ai_target_method = TS_DAMAGE_SIMPLE

	// AI player control by ghosts
	var/ai_playercontrol_allowtype = 1 // if 0, this specific class of spider is not player-controllable. Default set in code for each class, cannot be changed.

	var/ai_break_lights = TRUE // AI lightbreaking behavior
	var/freq_break_light = 600
	var/last_break_light = 0 // leave this, changed by procs.

	var/ai_spins_webs = TRUE // AI web-spinning behavior
	var/freq_spins_webs = 600
	var/last_spins_webs = 0 // leave this, changed by procs.
	var/delay_web = 40 // delay between starting to spin web, and finishing

	var/freq_cocoon_object = 1200 // two minutes between each attempt
	var/last_cocoon_object = 0 // leave this, changed by procs.

	var/spider_opens_doors = 1 // all spiders can open firedoors (they have no security). 1 = can open depowered doors. 2 = can open powered doors
	faction = list("terrorspiders")
	var/spider_awaymission = 0 // if 1, limits certain behavior in away missions
	var/spider_uo71 = 0 // if 1, spider is in the UO71 away mission
	var/spider_unlock_id_tag = "" // if defined, unlock awaymission blast doors with this tag on death
	var/spider_role_summary = "UNDEFINED"
	var/spider_placed = 0

	// AI variables designed for use in procs
	var/atom/movable/cocoon_target // for queen and nurse
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent // nearby vent they are going to try to get to, and enter
	var/obj/machinery/atmospherics/unary/vent_pump/exit_vent // remote vent they intend to come out of
	var/obj/machinery/atmospherics/unary/vent_pump/nest_vent // home vent, usually used by queens
	var/fed = 0
	var/travelling_in_vent = 0
	var/list/enemies = list()
	var/path_to_vent = 0
	var/killcount = 0
	var/busy = 0 // leave this alone!
	var/spider_tier = TS_TIER_1 // 1 for red,gray,green. 2 for purple,black,white, 3 for prince, mother. 4 for queen
	var/hasdied = 0
	var/list/spider_special_drops = list()
	var/attackstep = 0
	var/attackcycles = 0
	var/spider_myqueen = null
	var/spider_mymother = null
	var/mylocation = null
	var/chasecycles = 0
	var/web_infects = 0

	var/datum/action/innate/terrorspider/web/web_action
	var/web_type = /obj/structure/spider/terrorweb
	var/datum/action/innate/terrorspider/wrap/wrap_action

	// Breathing - require some oxygen, and no toxins, but take little damage from this requirement not being met (they can hold their breath)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 1

	// Temperature - can freeze in space and cook in plasma, but it takes extreme temperatures to do this.
	minbodytemp = 100
	maxbodytemp = 500
	heat_damage_per_tick = 3

	// DEBUG OPTIONS & COMMANDS
	var/spider_growinstantly = 0 // DEBUG OPTION, DO NOT ENABLE THIS ON LIVE. IT IS USED TO TEST NEST GROWTH/SETUP AI.
	var/spider_debug = 0


// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: SHARED ATTACK CODE -----------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/AttackingTarget()
	if(isterrorspider(target))
		if(target in enemies)
			enemies -= target
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = target
		if(T.spider_tier > spider_tier)
			visible_message("<span class='notice'>[src] cowers before [target].</span>")
		else if(T.spider_tier == spider_tier)
			visible_message("<span class='notice'>[src] nuzzles [target].</span>")
		else if(T.spider_tier < spider_tier && spider_tier >= 4)
			target.attack_animal(src)
		else
			visible_message("<span class='notice'>[src] harmlessly nuzzles [target].</span>")
		T.CheckFaction()
		CheckFaction()
	else if(istype(target, /obj/structure/spider)) // Prevents destroying coccoons (exploit), eggs (horrible misclick), etc
		to_chat(src, "Destroying things created by fellow spiders would not help us.")
	else if(istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = target
		if(F.density)
			if(F.welded)
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
	else if(isliving(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/G = target
		if(issilicon(G))
			G.attack_animal(src)
			return
		else if(G.reagents && (iscarbon(G)))
			var/can_poison = 1
			if(ishuman(G))
				var/mob/living/carbon/human/H = G
				if(!(H.dna.species.reagent_tag & PROCESS_ORG) || (!H.dna.species.tox_mod))
					can_poison = 0
			spider_specialattack(G,can_poison)
		else
			G.attack_animal(src)
	else
		target.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/spider_specialattack(mob/living/carbon/human/L, poisonable)
	L.attack_animal(src)

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: PROC OVERRIDES ---------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/examine(mob/user)
	. = ..()
	var/list/msgs = list()
	if(stat == DEAD)
		msgs += "<span class='notice'>It appears to be dead.</span>\n"
	else
		if(key)
			msgs += "<span class='warning'>Its eyes regard you with a curious intelligence.</span>"
		if(health > (maxHealth*0.95))
			msgs += "<span class='notice'>It is in excellent health.</span>"
		else if(health > (maxHealth*0.75))
			msgs += "<span class='notice'>It has a few injuries.</span>"
		else if(health > (maxHealth*0.55))
			msgs += "<span class='warning'>It has many injuries.</span>"
		else if(health > (maxHealth*0.25))
			msgs += "<span class='warning'>It is barely clinging on to life!</span>"
		if(degenerate)
			msgs += "<span class='warning'>It appears to be dying.</span>"
		else if(health < maxHealth && regen_points > regen_points_per_kill)
			msgs += "<span class='notice'>It appears to be regenerating quickly.</span>"
		if(killcount >= 1)
			msgs += "<span class='warning'>It has blood dribbling from its mouth.</span>"
	. += msgs.Join("<BR>")

/mob/living/simple_animal/hostile/poison/terror_spider/New()
	..()
	GLOB.ts_spiderlist += src
	add_language("Spider Hivemind")
	if(spider_tier >= TS_TIER_2)
		add_language("Galactic Common")
	default_language = GLOB.all_languages["Spider Hivemind"]

	if(web_type)
		web_action = new()
		web_action.Grant(src)
	wrap_action = new()
	wrap_action.Grant(src)

	name += " ([rand(1, 1000)])"
	real_name = name
	msg_terrorspiders("[src] has grown in [get_area(src)].")
	if(is_away_level(z))
		spider_awaymission = 1
		GLOB.ts_count_alive_awaymission++
		if(spider_tier >= 3)
			ai_ventcrawls = FALSE // means that pre-spawned bosses on away maps won't ventcrawl. Necessary to keep prince/mother in one place.
		if(istype(get_area(src), /area/awaymission/UO71)) // if we are playing the away mission with our special spiders...
			spider_uo71 = 1
			if(world.time < 600)
				// these are static spiders, specifically for the UO71 away mission, make them stay in place
				ai_ventcrawls = FALSE
				spider_placed = 1
	else
		GLOB.ts_count_alive_station++
	// after 3 seconds, assuming nobody took control of it yet, offer it to ghosts.
	addtimer(CALLBACK(src, .proc/CheckFaction), 20)
	addtimer(CALLBACK(src, .proc/announcetoghosts), 30)
	var/datum/atom_hud/U = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	U.add_hud_to(src)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/announcetoghosts()
	if(spider_awaymission)
		return
	if(stat == DEAD)
		return
	if(ckey)
		var/image/alert_overlay = image('icons/mob/terrorspider.dmi', icon_state)
		notify_ghosts("[src] has appeared in [get_area(src)]. (already player-controlled)", source = src, alert_overlay = alert_overlay)
	else if(ai_playercontrol_allowtype)
		var/image/alert_overlay = image('icons/mob/terrorspider.dmi', icon_state)
		notify_ghosts("[src] has appeared in [get_area(src)].", enter_link = "<a href=?src=[UID()];activate=1>(Click to control)</a>", source = src, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)

/mob/living/simple_animal/hostile/poison/terror_spider/Destroy()
	GLOB.ts_spiderlist -= src
	handle_dying()
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/Life(seconds, times_fired)
	. = ..()
	if(!.) // if mob is dead
		if(prob(2))
			// 2% chance every cycle to decompose
			visible_message("<span class='notice'>\The dead body of the [src] decomposes!</span>")
			gib()
	else
		if(degenerate > 0)
			adjustToxLoss(rand(1,10))
		if(regen_points < regen_points_max)
			regen_points += regen_points_per_tick
		if(getBruteLoss() || getFireLoss())
			if(regen_points > regen_points_per_hp)
				if(getBruteLoss())
					adjustBruteLoss(-1)
					regen_points -= regen_points_per_hp
				else if(getFireLoss())
					adjustFireLoss(-1)
					regen_points -= regen_points_per_hp
		if(prob(5))
			CheckFaction()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/handle_dying()
	if(!hasdied)
		hasdied = 1
		GLOB.ts_count_dead++
		GLOB.ts_death_last = world.time
		if(spider_awaymission)
			GLOB.ts_count_alive_awaymission--
		else
			GLOB.ts_count_alive_station--

/mob/living/simple_animal/hostile/poison/terror_spider/death(gibbed)
	if(can_die())
		if(!gibbed)
			msg_terrorspiders("[src] has died in [get_area(src)].")
		handle_dying()
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/spider_special_action()
	return

/mob/living/simple_animal/hostile/poison/terror_spider/ObjBump(obj/O)
	if(istype(O, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/L = O
		if(L.density)
			return try_open_airlock(L)
	if(istype(O, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = O
		if(F.density && !F.welded)
			F.open()
			return 1
	. = ..()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/msg_terrorspiders(msgtext)
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in GLOB.ts_spiderlist)
		if(T.stat != DEAD)
			to_chat(T, "<span class='terrorspider'>TerrorSense: [msgtext]</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CheckFaction()
	if(faction.len != 2 || (!("terrorspiders" in faction)) || master_commander != null)
		to_chat(src, "<span class='userdanger'>Your connection to the hive mind has been severed!</span>")
		log_runtime(EXCEPTION("Terror spider with incorrect faction list at: [atom_loc_line(src)]"))
		gib()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/try_open_airlock(obj/machinery/door/airlock/D)
	if(D.operating)
		return
	if(!D.density)
		to_chat(src, "<span class='warning'>Closing doors does not help us.</span>")
	else if(D.welded)
		to_chat(src, "<span class='warning'>The door is welded shut.</span>")
	else if(D.locked)
		to_chat(src, "<span class='warning'>The door is bolted shut.</span>")
	else if(D.allowed(src))
		D.open(1)
		return 1
	else if(D.arePowerSystemsOn() && (spider_opens_doors != 2))
		to_chat(src, "<span class='warning'>The door's motors resist your efforts to force it.</span>")
	else if(!spider_opens_doors)
		to_chat(src, "<span class='warning'>Your type of spider is not strong enough to force open doors.</span>")
	else
		visible_message("<span class='danger'>[src] pries open the door!</span>")
		playsound(src.loc, "sparks", 100, 1)
		D.open(1)
		return 1

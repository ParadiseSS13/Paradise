GLOBAL_LIST_EMPTY(ts_ckey_blacklist)
GLOBAL_VAR_INIT(ts_count_dead, 0)
GLOBAL_VAR_INIT(ts_count_alive_awaymission, 0)
GLOBAL_VAR_INIT(ts_count_alive_station, 0)
GLOBAL_VAR_INIT(ts_death_last, 0)
GLOBAL_VAR_INIT(ts_death_window, 9000) // 15 minutes
GLOBAL_LIST_EMPTY(ts_spiderlist)
GLOBAL_LIST_EMPTY(ts_egg_list)
GLOBAL_LIST_EMPTY(ts_spiderling_list)
GLOBAL_LIST_EMPTY(ts_infected_list)

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: DEFAULTS ---------------------------------
// --------------------------------------------------------------------------------
// Because: http://tvtropes.org/pmwiki/pmwiki.php/Main/SpidersAreScary

/mob/living/simple_animal/hostile/poison/terror_spider
	// Name / Description
	name = "terror spider"
	desc = "The generic parent of all other terror spider types. If you see this in-game, it is a bug."
	gender = FEMALE

	// Icons
	icon = 'icons/mob/terrorspider.dmi'
	icon_state = "terror_red"
	icon_living = "terror_red"
	icon_dead = "terror_red_dead"

	mob_biotypes = MOB_ORGANIC | MOB_BUG

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
	move_resist = MOVE_FORCE_STRONG // no more pushing a several hundred if not thousand pound spider
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
	var/ai_ventbreaker = FALSE

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
	var/regen_points_per_jelly = 120 // gain a ton of regen points if you eat a jelly
	// desired: 20hp/minute unmolested, 40hp/min on food boost, assuming one tick every 2 seconds
	//          90/kill means bonus 30hp/kill regenerated over the next 1-2 minutes

	var/degenerate = FALSE // if TRUE, they slowly degen until they all die off.

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
	var/spider_role_summary = "UNDEFINED"
	var/spider_intro_text = "If you are seeing this, please alert the coders"
	var/spider_placed = FALSE

	// AI variables designed for use in procs
	var/atom/movable/cocoon_target // for queen and nurse
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent // nearby vent they are going to try to get to, and enter
	var/obj/machinery/atmospherics/unary/vent_pump/exit_vent // remote vent they intend to come out of
	var/obj/machinery/atmospherics/unary/vent_pump/nest_vent // home vent, usually used by queens
	var/fed = 0
	var/travelling_in_vent = FALSE
	var/list/enemies = list()
	var/path_to_vent = FALSE
	var/killcount = 0
	var/busy = 0 // leave this alone!
	var/spider_tier = TS_TIER_1 // 1 for red,gray,green. 2 for purple,black,white, 3 for prince, mother. 4 for queen
	/// Does this terror speak loudly on the terror hivemind?
	var/loudspeaker = FALSE
	var/hasdied = FALSE
	var/list/spider_special_drops = list()
	var/attackstep = 0
	var/attackcycles = 0
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/spider_myqueen = null
	var/mob/living/simple_animal/hostile/poison/terror_spider/spider_mymother = null
	var/mylocation = null
	var/chasecycles = 0
	var/spider_creation_time = 0

	var/web_type = /obj/structure/spider/terrorweb

	// Breathing - require some oxygen, and no toxins
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	// Temperature
	heat_damage_per_tick = 5 // Takes 250% normal damage from being in a hot environment ("kill it with fire!")

	// DEBUG OPTIONS & COMMANDS
	var/spider_growinstantly = FALSE // DEBUG OPTION, DO NOT ENABLE THIS ON LIVE. IT IS USED TO TEST NEST GROWTH/SETUP AI.
	var/spider_debug = FALSE
	footstep_type = FOOTSTEP_MOB_CLAW


// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: SHARED ATTACK CODE -----------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	// Forces terrors to use the 'bite' graphic when attacking something. Same as code/modules/mob/living/carbon/alien/larva/larva_defense.dm#L34
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()

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
	else if(istype(target, /obj/structure/spider/royaljelly))
		consume_jelly(target)
	else if(istype(target, /obj/structure/spider)) // Prevents destroying coccoons (exploit), eggs (horrible misclick), etc
		to_chat(src, "Destroying things created by fellow spiders would not help us.")
	else if(istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = target
		if(F.density)
			if(F.welded)
				to_chat(src, "The fire door is welded shut.")
			else
				visible_message("<span class='danger'>[src] pries open the firedoor!</span>")
				F.open()
		else
			to_chat(src, "Closing fire doors does not help.")
	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
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

/mob/living/simple_animal/hostile/poison/terror_spider/proc/consume_jelly(obj/structure/spider/royaljelly/J)
	if(regen_points_per_tick >= regen_points_per_hp)
		to_chat(src, "<span class='warning'>Your spider type would not get any benefit from consuming royal jelly.</span>")
		return
	if(regen_points > 200)
		to_chat(src, "<span class='warning'>You aren't hungry for jelly right now.</span>")
		return
	to_chat(src, "<span class='notice'>You consume the royal jelly! Regeneration speed increased!</span>")
	regen_points += regen_points_per_jelly
	fed++
	qdel(J)

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: PROC OVERRIDES ---------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		if(key)
			. += "<span class='warning'>[p_they(TRUE)] regards [p_their()] surroundings with a curious intelligence.</span>"
		if(health > (maxHealth*0.95))
			. += "<span class='notice'>[p_they(TRUE)] is in excellent health.</span>"
		else if(health > (maxHealth*0.75))
			. += "<span class='notice'>[p_they(TRUE)] has a few injuries.</span>"
		else if(health > (maxHealth*0.55))
			. += "<span class='warning'>[p_they(TRUE)] has many injuries.</span>"
		else if(health > (maxHealth*0.25))
			. += "<span class='warning'>[p_they(TRUE)] is barely clinging on to life!</span>"
		if(degenerate)
			. += "<span class='warning'>[p_they(TRUE)] appears to be dying.</span>"
		else if(health < maxHealth && regen_points > regen_points_per_kill)
			. += "<span class='notice'>[p_they(TRUE)] appears to be regenerating quickly.</span>"
		if(killcount >= 1)
			. += "<span class='warning'>[p_they(TRUE)] has blood dribbling from [p_their()] mouth.</span>"

/mob/living/simple_animal/hostile/poison/terror_spider/Initialize(mapload)
	. = ..()
	GLOB.ts_spiderlist += src
	add_language("Spider Hivemind")
	if(spider_tier >= TS_TIER_2)
		add_language("Galactic Common")
	default_language = GLOB.all_languages["Spider Hivemind"]

	if(web_type)
		var/datum/action/innate/terrorspider/web/web_act = new
		web_act.Grant(src)
	if(regen_points_per_tick < regen_points_per_hp)
		// Only grant the Wrap action button to spiders who need to use it to regenerate their health
		var/datum/action/innate/terrorspider/wrap/wrap_act = new
		wrap_act.Grant(src)
	name += " ([rand(1, 1000)])"
	real_name = name
	msg_terrorspiders("[src] has grown in [get_area(src)].")
	GLOB.ts_count_alive_station++
	// after 3 seconds, assuming nobody took control of it yet, offer it to ghosts.
	addtimer(CALLBACK(src, PROC_REF(CheckFaction)), 20)
	addtimer(CALLBACK(src, PROC_REF(announcetoghosts)), 30)
	var/datum/atom_hud/U = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	U.add_hud_to(src)
	spider_creation_time = world.time

/mob/living/simple_animal/hostile/poison/terror_spider/proc/announcetoghosts()
	if(stat == DEAD)
		return
	if(ckey)
		notify_ghosts("[src] (player controlled) has appeared in [get_area(src)].")
	else if(ai_playercontrol_allowtype)
		var/image/alert_overlay = image('icons/mob/terrorspider.dmi', icon_state)
		notify_ghosts("[src] has appeared in [get_area(src)].", enter_link = "<a href=?src=[UID()];activate=1>(Click to control)</a>", source = src, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)

/mob/living/simple_animal/hostile/poison/terror_spider/Destroy()
	GLOB.ts_spiderlist -= src
	var/datum/atom_hud/U = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	U.remove_hud_from(src)
	handle_dying()

	spider_mymother = null
	spider_myqueen = null

	entry_vent = null
	exit_vent = null
	nest_vent = null

	cocoon_target = null
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD) // Can't use if(.) for this due to the fact it can sometimes return FALSE even when mob is alive.
		if(prob(2))
			// 2% chance every cycle to decompose
			visible_message("<span class='notice'>The dead body of [src] decomposes!</span>")
			gib()
	else
		if(degenerate)
			adjustToxLoss(rand(1, 10))
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
		if(prob(5)) // AA 2022-08-11 - This gives me prob(80) vibes. Should probably be refactored.
			CheckFaction()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/handle_dying()
	if(!hasdied)
		hasdied = TRUE
		GLOB.ts_count_dead++
		GLOB.ts_death_last = world.time
		GLOB.ts_count_alive_station--

/mob/living/simple_animal/hostile/poison/terror_spider/proc/give_intro_text()
	to_chat(src, "<center><span class='userdanger'>You are a Terror Spider!</span></center>")
	to_chat(src, "<center>Work with other terror spiders in your hive to eliminate the crew and claim the station as your nest!</center>")
	to_chat(src, "<center><span class='danger'>Remember to follow the orders of higher tier spiders, such as princesses or queens.</span></center><br>")
	to_chat(src, "<center><span class='big'>[spider_intro_text]</span></center><br>")
	to_chat(src, "<center><span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Terror_Spider)</span></center>")

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
		if(L.density) // must check density here, to avoid rapid bumping of an airlock that is in the process of opening, instantly forcing it closed
			return try_open_airlock(L)
	if(istype(O, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = O
		if(F.density && !F.welded)
			F.open()
			return 1
	. = ..()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/msg_terrorspiders(msgtext)
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = thing
		if(T.stat != DEAD)
			to_chat(T, "<span class='terrorspider'>TerrorSense: [msgtext]</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CheckFaction()
	if(faction.len != 2 || (!("terrorspiders" in faction)) || master_commander != null)
		to_chat(src, "<span class='userdanger'>Your connection to the hive mind has been severed!</span>")
		stack_trace("Terror spider with incorrect faction list at: [atom_loc_line(src)]")
		gib()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/try_open_airlock(obj/machinery/door/airlock/D)
	if(D.operating)
		return
	if(D.welded)
		to_chat(src, "<span class='warning'>The door is welded.</span>")
	else if(D.locked)
		to_chat(src, "<span class='warning'>The door is bolted.</span>")
	else if(D.allowed(src))
		if(D.density)
			D.open(TRUE)
		else
			D.close(TRUE)
		return TRUE
	else if(D.arePowerSystemsOn() && (spider_opens_doors != 2))
		to_chat(src, "<span class='warning'>The door's motors resist your efforts to force it.</span>")
	else if(!spider_opens_doors)
		to_chat(src, "<span class='warning'>Your type of spider is not strong enough to force open doors.</span>")
	else
		visible_message("<span class='danger'>[src] forces the door!</span>")
		playsound(src.loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(D.density)
			D.open(TRUE)
		else
			D.close(TRUE)
		return TRUE


/mob/living/simple_animal/hostile/poison/terror_spider/get_spacemove_backup()
	. = ..()
	// If we don't find any normal thing to use, attempt to use any nearby spider structure instead.
	if(!.)
		for(var/obj/structure/spider/S in range(1, get_turf(src)))
			return S

/mob/living/simple_animal/hostile/poison/terror_spider/Stat()
	..()
	// Determines what shows in the "Status" tab for player-controlled spiders. Used to help players understand spider health regeneration mechanics.
	// Uses <font color='#X'> because the status panel does NOT accept <span class='X'>.
	if(statpanel("Status") && ckey && stat == CONSCIOUS)
		if(degenerate)
			stat(null, "<font color='#eb4034'>Hivemind Connection Severed! Dying...</font>") // color=red
			return
		if(health != maxHealth)
			var/hp_points_per_second = 0
			var/ltext = "FAST"
			var/lcolor = "#fcba03" // orange
			var/secs_per_tick = (SSmobs.wait / 10) // This uses SSmobs.wait because it must use the same frequency as mobs are processed
			if(regen_points < (regen_points_per_hp * 2))
				// Slow regen speed: using regen_points as we get them. Figure out regen_points/sec, then convert that to hp/sec.
				var/regen_points_per_second = (regen_points_per_tick / secs_per_tick)
				hp_points_per_second = (regen_points_per_second / regen_points_per_hp)
				ltext = "SLOW (HUNGRY!)"
				lcolor = "#eb4034" // red
			else
				// Fast regen speed: healing at full 1 hp / tick rate. Just divide 1hp/tick by seconds/tick to get healing/sec.
				hp_points_per_second = 1 / secs_per_tick
			if(hp_points_per_second > 0)
				var/pc_of_max_per_second = round(((hp_points_per_second / maxHealth) * 100), 0.1)
				stat(null, "Regeneration: [ltext]: <font color='[lcolor]'>[num2text(pc_of_max_per_second)]% of health per second</font>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoRemoteView()
	if(!isturf(loc))
		// This check prevents spiders using this ability while inside an atmos pipe, which will mess up their vision
		to_chat(src, "<span class='warning'>You must be standing on a floor to do this.</span>")
		return
	if(client && (client.eye != client.mob))
		reset_perspective()
		return
	if(health != maxHealth)
		to_chat(src, "<span class='warning'>You must be at full health to do this!</span>")
		return
	var/list/targets = list()
	targets += src // ensures that self is always at top of the list
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = thing
		if(T.stat == DEAD)
			continue
		targets |= T // we use |= instead of += to avoid adding src to the list twice
	var/mob/living/L = input("Choose a terror to watch.", "Selection") in targets
	if(istype(L))
		reset_perspective(L)

/mob/living/simple_animal/hostile/poison/terror_spider/adjustHealth(amount, updating_health = TRUE)
	if(client && (client.eye != client.mob) && ismob(client.eye)) // the ismob check is required because client.eye can = atmos machines if a spider is in the vent
		to_chat(src, "<span class='warning'>Cancelled remote view due to being under attack!</span>")
		reset_perspective()
	. = ..()

/mob/living/simple_animal/hostile/poison/terror_spider/movement_delay()
	. = ..()
	if(pulling && !ismob(pulling) && pulling.density)
		. += 6 // Drastic move speed penalty for dragging anything that is not a mob or a non dense object

/mob/living/simple_animal/hostile/poison/terror_spider/Login()
	. = ..()
	SEND_SIGNAL(src, COMSIG_MOB_LOGIN)

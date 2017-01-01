
var/global/list/ts_ckey_blacklist = list()
var/global/ts_count_dead = 0
var/global/ts_count_alive_awaymission = 0
var/global/ts_count_alive_station = 0
var/global/ts_death_last = 0
var/global/ts_death_window = 9000 // 15 minutes
var/global/list/ts_spiderlist = list()

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
	poison_type = "" // we do not use that silly system.

	// Movement
	move_to_delay = 6
	turns_per_move = 5
	pass_flags = PASSTABLE

	// Ventcrawling
	ventcrawler = 1 // allows player ventcrawling

	// Speech
	speak_chance = 0 // quiet but deadly
	speak_emote = list("hisses")
	emote_hear = list("hisses")

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

	// Vision
	idle_vision_range = 10
	aggro_vision_range = 10
	see_in_dark = 10
	nightvision = 1
	vision_type = new /datum/vision_override/nightvision/thermals/ling_augmented_eyesight
	see_invisible = 5

	// player control by ghosts
	var/ai_playercontrol_allowingeneral = 1 // if 0, no spiders are player controllable. Default set in code, can be changed by queens.
	var/ai_playercontrol_allowtype = 1 // if 0, this specific class of spider is not player-controllable. Default set in code for each class, cannot be changed.

	var/spider_opens_doors = 1 // all spiders can open firedoors (they have no security). 1 = can open depowered doors. 2 = can open powered doors
	faction = list("terrorspiders")
	var/spider_awaymission = 0 // if 1, limits certain behavior in away missions
	var/spider_role_summary = "UNDEFINED"
	var/spider_placed = 0

	// AI variables designed for use in procs
	var/atom/cocoon_target // for queen and nurse
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent // nearby vent they are going to try to get to, and enter
	var/obj/machinery/atmospherics/unary/vent_pump/exit_vent // remote vent they intend to come out of
	var/obj/machinery/atmospherics/unary/vent_pump/nest_vent // home vent, usually used by queens
	var/fed = 0
	var/travelling_in_vent = 0
	var/busy = 0 // leave this alone!
	var/spider_tier = TS_TIER_1 // 1 for red,gray,green. 2 for purple,black,white, 3 for prince, mother. 4 for queen, 5 for empress.
	var/hasdied = 0
	var/attackstep = 0
	var/attackcycles = 0
	var/mylocation = null
	var/chasecycles = 0
	var/last_cocoon_object = 0 // leave this, changed by procs.
	var/killcount = 0

	// Breathing, Pressure & Fire
	// - No breathing / cannot be suffocated (spiders can hold their breath, look it up)
	// - No pressure damage either - they have effectively exoskeletons
	// - HOWEVER they can be burned to death!
	// - Normal SPACE spiders should probably be immune to SPACE too, but meh, we try to leave the base spiders alone.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	heat_damage_per_tick = 5 //amount of damage applied if animal's body temperature is higher than maxbodytemp

	// DEBUG OPTIONS & COMMANDS
	var/spider_debug = 0

	var/datum/action/innate/terrorspider/web/web_action
	var/datum/action/innate/terrorspider/wrap/wrap_action


// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: SHARED ATTACK CODE -----------------------
// --------------------------------------------------------------------------------



/mob/living/simple_animal/hostile/poison/terror_spider/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/hostile/poison/terror_spider))
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = target
		if(T.spider_tier > spider_tier)
			visible_message("<span class='notice'>[src] bows in respect for the terrifying presence of [target].</span>")
		else if(T.spider_tier == spider_tier)
			visible_message("<span class='notice'>[src] nuzzles [target].</span>")
		else if(T.spider_tier < spider_tier && spider_tier >= 4)
			visible_message("<span class='notice'>[src] gives [target] a stern look.</span>")
		else
			visible_message("<span class='notice'>[src] harmlessly nuzzles [target].</span>")
		T.CheckFaction()
		CheckFaction()
	else if(istype(target, /obj/effect/spider/cocoon))
		to_chat(src, "Destroying our own cocoons would not help us.")
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
	else if(isliving(target))
		var/mob/living/G = target
		if(issilicon(G))
			G.attack_animal(src)
			return
		else if(G.reagents && (iscarbon(G)))
			var/can_poison = 1
			if(ishuman(G))
				var/mob/living/carbon/human/H = G
				if(!(H.species.reagent_tag & PROCESS_ORG) || (H.species.flags & NO_POISON))
					can_poison = 0
			spider_specialattack(G,can_poison)
		else
			G.attack_animal(src)
	else
		target.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/spider_specialattack(mob/living/carbon/human/L, var/poisonable)
	L.attack_animal(src)






// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: PROC OVERRIDES ---------------------------
// --------------------------------------------------------------------------------


/mob/living/simple_animal/hostile/poison/terror_spider/examine(mob/user)
	..()
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
		else if(health < maxHealth && regen_points > regen_points_per_kill)
			msgs += "<span class='notice'>It appears to be regenerating quickly.</span>"
		if(killcount >= 1)
			msgs += "<span class='warning'>It has blood dribbling from its mouth.</span>"
	to_chat(usr,msgs.Join("<BR>"))


/mob/living/simple_animal/hostile/poison/terror_spider/New()
	..()
	ts_spiderlist += src
	add_language("Spider Hivemind")
	add_language("Galactic Common")
	default_language = all_languages["Spider Hivemind"]

	web_action = new()
	web_action.Grant(src)
	wrap_action = new()
	wrap_action.Grant(src)

	name += " ([rand(1, 1000)])"
	msg_terrorspiders("[src] has grown in [get_area(src)].")
	if(is_away_level(z))
		spider_awaymission = 1
		ts_count_alive_awaymission++
	else
		ts_count_alive_station++
	// after 30 seconds, assuming nobody took control of it yet, offer it to ghosts.
	addtimer(src, "CheckFaction", 150)
	addtimer(src, "announcetoghosts", 300)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/announcetoghosts()
	if(spider_awaymission)
		return
	if(stat == DEAD)
		return
	if(ckey)
		var/image/alert_overlay = image('icons/mob/terrorspider.dmi', icon_state)
		notify_ghosts("[src] has appeared in [get_area(src)]. (already player-controlled)", source = src, alert_overlay = alert_overlay)
	else if(ai_playercontrol_allowingeneral && ai_playercontrol_allowtype)
		var/image/alert_overlay = image('icons/mob/terrorspider.dmi', icon_state)
		notify_ghosts("[src] has appeared in [get_area(src)].", enter_link = "<a href=?src=[UID()];activate=1>(Click to control)</a>", source = src, alert_overlay = alert_overlay, attack_not_jump = 1)

/mob/living/simple_animal/hostile/poison/terror_spider/Destroy()
	ts_spiderlist -= src
	handle_dying()
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/Life()
	..()
	if(stat == DEAD)
		if(prob(2))
			// 2% chance every cycle to decompose
			visible_message("<span class='notice'>\The dead body of the [src] decomposes!</span>")
			gib()
	else
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




/mob/living/simple_animal/hostile/poison/terror_spider/proc/handle_dying()
	if(!hasdied)
		hasdied = 1
		ts_count_dead++
		ts_death_last = world.time
		if(spider_awaymission)
			ts_count_alive_awaymission--
		else
			ts_count_alive_station--

/mob/living/simple_animal/hostile/poison/terror_spider/death(gibbed)
	if(!gibbed)
		msg_terrorspiders("[src] has died in [get_area(src)].")
	handle_dying()
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/proc/spider_special_action()
	return

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

/mob/living/simple_animal/hostile/poison/terror_spider/proc/msg_terrorspiders(msgtext)
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in ts_spiderlist)
		if(T.stat != DEAD)
			to_chat(T, "<span class='terrorspider'>TerrorSense: [msgtext]</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CheckFaction()
	if(faction.len != 1 || (!("terrorspiders" in faction)) || master_commander != null)
		visible_message("<span class='danger'>[src] writhes in pain!</span>")
		log_runtime(EXCEPTION("Terror spider created with incorrect faction list at: [atom_loc_line(src)]"))
		death()

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
	else if(D.arePowerSystemsOn() && (spider_opens_doors != 2))
		to_chat(src, "<span class='warning'>The door's motors resist your efforts to force it.</span>")
	else if(!spider_opens_doors)
		to_chat(src, "<span class='warning'>Your type of spider is not strong enough to force open doors.</span>")
	else
		visible_message("<span class='danger'>[src] pries open the door!</span>")
		playsound(src.loc, "sparks", 100, 1)
		D.open(1)
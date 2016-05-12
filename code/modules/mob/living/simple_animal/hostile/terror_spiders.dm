
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4


var/global/list/ts_ckey_blacklist = list()
var/global/ts_count_dead = 0
var/global/ts_count_alive_awaymission = 0
var/global/ts_count_alive_station = 0
var/global/ts_death_last = 0
var/global/ts_death_window = 9000 // 15 minutes

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
	var/last_ventcrawl_time = 0 // tracks the last world.time that the spider ventcrawled, used to prevent excessive crawling.
	var/freq_ventcrawl_combat = 1800 // 3 minutes
	var/freq_ventcrawl_idle =  9000 // 15 minutes
	var/ai_ventcrawls = 1
	var/idle_ventcrawl_chance = 3 // default 3% chance to ventcrawl when not in combat to a random exit vent

	// AI movement tracking
	var/spider_steps_taken = 0 // leave at 0, its a counter for ai steps taken.
	var/spider_max_steps = 15 // after we take X turns trying to do something, give up!

	// Speech
	speak_chance = 0 // quiet but deadly
	speak_emote = list("hisses")
	emote_hear = list("hisses")

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

	// Loot
	var/loot = 1 // if they drop loot when they die

	// Vision
	idle_vision_range = 10
	aggro_vision_range = 10
	see_in_dark = 10
	nightvision = 1
	vision_type = new /datum/vision_override/nightvision/thermals/ling_augmented_eyesight
	see_invisible = 5

	// AI aggression settings
	var/ai_type = 0 // 0 = aggressive to everyone, 1 = defends self only, 2 = passive, you can butcher it like a sheep

	// AI player control by ghosts
	var/ai_playercontrol_allowingeneral = 1 // if 0, no spiders are player controllable. Default set in code, can be changed by queens.
	var/ai_playercontrol_allowtype = 1 // if 0, this specific class of spider is not player-controllable. Default set in code for each class, cannot be changed.

	var/ai_break_lights = 1 // AI lightbreaking behavior
	var/freq_break_light = 600 // one minute
	var/last_break_light = 0 // leave this, changed by procs.

	var/player_breaks_cameras = 1  // Toggle for players breaking cameras

	var/ai_spins_webs = 1 // AI web-spinning behavior
	var/idle_spinwebs_chance = 3

	var/ai_cocoons_objects = 0 // AI object coccooning behavior, only used by greens
	var/idle_cocoon_chance = 10

	var/ai_hides_in_vents = 0 // AI vent hiding behavior, only used by purples.

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
	//gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE // this doesn't prevent a version with the "neutral" faction from gold slime extract + blood.
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID // prevents this mob from being spawned by any xenobio or chem reactions.

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
	if (ai_type == 0)
		// default, BE AGGRESSIVE
		//var/list/Mobs = hearers(vision_range, src) - src // this is how ListTargets for /mob/living/simple_animal/hostile/ does it, but it is wrong, it ignores NPCs.
		for(var/mob/living/H in view(src, vision_range))
		//for(var/mob/H in Mobs)
			if (H.stat == 2)
				// dead mobs are ALWAYS ignored.
			else if (H.flags & GODMODE)
				// if it is literally invincible, ignore it.
			else if (!stat_attack && H.stat == 1)
				// unconscious mobs are ignored unless spider has stat_attack
			else if (istype(H, /mob/living/simple_animal/hostile/poison/terror_spider))
				// fellow terror spiders are never valid targets unless they deliberately attack us, even then, low priority
				if (H in enemies)
					targets3 += H
			else if (H.reagents)
				if (H.paralysis && H.reagents.has_reagent("terror_white_tranq"))
					// let's not target completely paralysed mobs.
					if (H in enemies)
						targets3 += H
						// unless we hate their guts
				if (IsInfected(H)) // target them if they attack us
					if (H in enemies)
						targets3 += H
				else if (H.reagents.has_reagent("terror_green_toxin")) // target them if they get close or attack us
					if (H in enemies)
						targets3 += H
					else if (get_dist(src,H) <= 3)
						targets2 += H
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
					// if we're aggressive, and they're a living non-spider mob that can be poisoned, check if we can inject them.
					// if we can, then prioritize them. If we can't, assume they're too armored to be a good target, and give them a lower target priority.
					if (H.can_inject(null,0,"chest",0))
						targets1 += H
					else
						targets3 += H
					// targets with no venom are priority targets, always pick these first
					// yeah, we could try to prioritize PROCESS_ORGANIC targets, ie: people we can poison...
					// -- but that might lead to a situation where we fail to handle the bigger threat before it kills us.
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
				targets1 += S
		return targets1
	else if (ai_type == 2)
		// COMPLETELY PASSIVE
		return list()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/IsInfected(var/mob/B)
	if (istype(B,/mob/living/carbon))
		var/mob/living/carbon/C = B
		if(C.get_int_organ(/obj/item/organ/internal/body_egg))
			return 1
		else
			return 0
	else
		return 0


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
	else if (istype(target, /obj/effect/spider/cocoon))
		to_chat(src, "Destroying our own cocoons would not help us.")
	else if (istype(target, /obj/machinery/camera))
		if (player_breaks_cameras)
			var/obj/machinery/camera/C = target
			if (C.status)
				do_attack_animation(C)
				C.toggle_cam(src,0)
				visible_message("<span class='danger'>\the [src] smashes the [C.name].</span>")
				playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
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
	else if (ai_type == 2)
		to_chat(src, "Your current orders forbid you from attacking anyone.")
	else if (ai_type == 1 && !(target in enemies))
		to_chat(src, "Your current orders only allow you to defend yourself - not initiate combat.")
	else if(isliving(target))
		var/mob/living/L = target
		if(L.player_logged)
			to_chat(src, "[target] is braindead, and a waste of our time. (SSD. Server rules prohibit attacking SSDs)")
			if (L in enemies)
				enemies -= L
			return
		else if (istype(L, /mob/living/silicon/))
			L.attack_animal(src)
			return
		else if(L.reagents && (iscarbon(L)))
			if (istype(L, /mob/living/carbon/human/))
				var/mob/living/carbon/human/H = L
				if(H.dna)
					if(!(H.species.reagent_tag & PROCESS_ORG) || (H.species.flags & NO_POISON))
						H.attack_animal(src)
						return
			var/inject_target = pick("chest","head") // Yes, there are other body parts. No, the code won't work if we pick any of them. Grrr.
			if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/prince))
				if (prob(15))
					visible_message("<span class='danger'> \icon[src] [src] rams into [L], knocking them to the floor! </span>")
					L.Weaken(5)
					L.Stun(5)
				else
					L.attack_animal(src)
			else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/purple))
				if (prob(10))
					visible_message("<span class='danger'> \icon[src] [src] rams into [L], knocking them to the floor! </span>")
					L.Weaken(5)
					L.Stun(5)
				else
					L.attack_animal(src)
			else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/black))
				if (L.reagents.has_reagent("terror_black_toxin",50))
					L.attack_animal(src)
				else
					melee_damage_lower = 1
					melee_damage_upper = 5
					if (L.stunned || L.can_inject(null,0,inject_target,0))
						L.reagents.add_reagent("terror_black_toxin", 15) // inject our special poison
						visible_message("<span class='danger'> \icon[src] [src] buries its long fangs deep into the [inject_target] of [target]! </span>")
					else
						visible_message("<span class='danger'> \icon[src] [src] bites [target], but cannot inject venom into their [inject_target]! </span>")
					L.attack_animal(src)
					//L.Weaken(5)
					melee_damage_lower = 10
					melee_damage_upper = 20
				if ((!target in enemies) || L.reagents.has_reagent("terror_black_toxin",50))
					// if we haven't been shot at, or we've bitten them so much they will die very fast, retreat
					if (!ckey)
						spawn(20)
							step_away(src,L)
							step_away(src,L)
							LoseTarget()
							for(var/i=0, i<4, i++)
								step_away(src, L)
							visible_message("<span class='notice'> \icon[src] [src] warily eyes [L] from a distance. </span>")
							// aka, if you come over here I will wreck you.
				return
			else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/white))
				if (attackstep == 0)
					visible_message("<span class='danger'> \icon[src] [src] crouches down on its powerful hind legs! </span>")
					attackstep = 1
				else if (attackstep == 1)
					visible_message("<span class='danger'> \icon[src] [src] pounces on [target]! </span>")
					do_attack_animation(L)
					L.emote("scream")
					L.drop_l_hand()
					L.drop_r_hand()
					L.Weaken(5) // stunbaton-like stun, floors them
					L.Stun(5)
					attackstep = 2
				else if (attackstep == 2)
					do_attack_animation(L)
					if (degenerate)
						visible_message("<span class='danger'> \icon[src] [src] does not have the strength to bite [target]!</span>")
					else if (L.stunned || L.paralysis || L.can_inject(null,0,inject_target,0))
						L.reagents.add_reagent("terror_white_toxin", 10)
						visible_message("<span class='danger'> \icon[src] [src] injects a green venom into the [inject_target] of [target]!</span>")
					else
						visible_message("<span class='danger'> \icon[src] [src] bites [target], but cannot inject venom into their [inject_target]!</span>")
					attackstep = 3
				else if (attackstep == 3)
					if (L in enemies)
						if (L.stunned || L.paralysis || L.can_inject(null,0,inject_target,0))
							do_attack_animation(L)
							L.reagents.add_reagent("terror_white_tranq", 5)
							visible_message("<span class='danger'> \icon[src] [src] injects a blue venom into the [inject_target] of [target]!</span></span>")
							enemies -= L
						else
							do_attack_animation(L)
							visible_message("<span class='danger'> \icon[src] [src] bites [target], but cannot inject venom into their [inject_target]!</span>")
					else
						visible_message("<span class='notice'> \icon[src] [src] takes a moment to recover. </span>")
						attackstep = 4
				else if (attackstep == 4)
					attackstep = 0
					attackcycles++
					if (ckey)
						if (IsInfected(L))
							to_chat(src, "<span class='notice'> [L] is infected. Find another host to attack/infect, or leave the area.</span>")
						else
							L.attack_animal(src)
					else
						if (!ckey && attackcycles >= 3) // if we've an AI who has gone through 3 infection attempts on a single target, just give up trying to infect it, and kill it instead.
							attackstep = 5
							L.attack_animal(src)
							return
						if (!IsInfected(L))
							visible_message("<span class='notice'> \icon[src] [src] takes a moment to recover. </span>")
							return
						var/vdistance = 99
						for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
							if(!v.welded)
								if (get_dist(src,v) < vdistance)
									entry_vent = v
									vdistance = get_dist(src,v)
						var/list/numtargets = ListTargets()
						if (numtargets.len > 0)
							LoseTarget()
							walk_away(src,L,2,1)
						else if(entry_vent)
							visible_message("<span class='notice'> \icon[src] [src] lets go of [target], and tries to flee! </span>")
							path_to_vent = 1
							var/temp_ai_type = ai_type
							ai_type = 1
							LoseTarget()
							walk_away(src,L,2,1)
							spawn(100) // 10 seconds
								ai_type = temp_ai_type
						else
							LoseTarget()
				else if (attackstep == 5)
					L.attack_animal(src)
				else
					attackstep = 0
			else
				L.attack_animal(src)
		else
			L.attack_animal(src)
	else
		target.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/Retaliate()
	var/list/around = view(src, 7)
	for(var/atom/movable/A in around)
		if(A == src)
			continue
		if (A in enemies)
			// they are already our enemy
			continue
		else if (istype(A, /mob/living/simple_animal/hostile/poison/terror_spider))
			// we can't make enemies of other spiders. Regardless of faction checks (they are unreliable, sometimes spiders get created with no faction!)
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
	if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/queen) || istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/empress)  )
		for (var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
			T.enemies |= enemies
	return 0

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
// --------------------- TERROR SPIDERS: SHARED PROCS -----------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/msg_terrorspiders(var/msgtext)
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
		if (T.health > 0)
			to_chat(T, "<span class='alien'>TerrorSense: " + msgtext + "</span>")


/mob/living/simple_animal/hostile/poison/terror_spider/proc/CountSpiders()
	var/numspiders = 0
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
		if (T.health > 0 && !T.spider_placed && spider_awaymission == T.spider_awaymission)
			numspiders += 1
	return numspiders

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CountAllSpiders()
	var/numspiders = 0
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
		numspiders += 1
	return numspiders

/mob/living/simple_animal/hostile/poison/terror_spider/examine(mob/user)
	..()
	var/msg = ""
	if (src.stat == DEAD)
		msg += "<span class='deadsay'>It appears to be dead.</span>\n"
	else
		if (src.key)
			msg += "<BR><span class='warning'>Its eyes regard you with a curious intelligence.</span>"
		if (src.ai_type == 0)
			msg += "<BR><span class='warning'>It appears aggressive.</span>"
		else if (src.ai_type == 0)
			msg += "<BR><span class='notice'>It appears defensive.</span>"
		else if (src.ai_type == 2)
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
		else if (killcount > 1)
			msg += "<BR><span class='warning'>It is soaked with the blood of " + num2text(killcount) + " prey it has killed.</span>"
	to_chat(usr,msg)


/mob/living/simple_animal/hostile/poison/terror_spider/New()
	..()
	if (type == /mob/living/simple_animal/hostile/poison/terror_spider)
		// don't permit  /mob/living/simple_animal/hostile/poison/terror_spider to be spawned.
		// it is just a placeholder parent type, you want to spawn one of the subclasses:  /mob/living/simple_animal/hostile/poison/terror_spider/*
		//var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
		//S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray, /mob/living/simple_animal/hostile/poison/terror_spider/green)
		qdel(src)
	else
		add_language("TerrorSpider")
		add_language("Galactic Common")
		default_language = all_languages["TerrorSpider"]

		name += " ([rand(1, 1000)])"
		msg_terrorspiders("[src] has grown in [get_area(src)].")
		if (name_usealtnames)
			name = pick(altnames)
		if(istype(get_area(src), /area/awaycontent) || istype(get_area(src), /area/awaymission/))
			spider_awaymission = 1
			if (spider_tier >= 3)
				ai_ventcrawls = 0 // means that pre-spawned bosses on away maps won't ventcrawl. Necessary to keep prince/mother in one place.
			if (istype(get_area(src), /area/awaymission/UO71)) // if we are playing the away mission with our special spiders...
				spider_uo71 = 1
				if (world.time < 600)
					// spider is spawning in the first 60 seconds of the round, asssume its an awaymission spider placed there with the intention of staying there.
					ai_ventcrawls = 0
					spider_placed = 1
					wander = 0
			ts_count_alive_awaymission++
		else
			ts_count_alive_station++
		// after 30 seconds, assuming nobody took control of it yet, offer it to ghosts.
		spawn(300) // deciseconds!
			if ("neutral" in faction)
				// no, xenobiologists, you cannot have tame terror spiders to screw around with.
				//faction -= "neutral"
				visible_message("<span class='notice'>[src] is absorbed through a bluespace portal, and vanishes!</span>")
				qdel(src)
			if (spider_awaymission)
				// never announce awaymission spiders.
			else if (ckey)
				notify_ghosts("[src] has appeared in [get_area(src)]. (already player-controlled)")
			else if (ai_playercontrol_allowingeneral && ai_playercontrol_allowtype)
				notify_ghosts("[src] has appeared in [get_area(src)]. <a href=?src=\ref[src];activate=1>(Click to control)</a>")



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
	if (stat == DEAD)
		if (prob(2))
			// 2% chance every cycle to decompose
			visible_message("<span class='notice'>\the dead body of the [src] decomposes!</span>")
			gib()
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/death(gibbed)
	if (!gibbed)
		msg_terrorspiders("[src] has died in [get_area(src)].")
		//if (!ckey && spider_tier < 3)
		//	say(pick("Mistresssss will end you...", "Doom waitssss... for you...","She comessssss for your flesh..."))
	if (!hasdroppedloot)
		hasdroppedloot = 1
		droploot()
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
	if(!stat && !ckey) // if we are not dead, and we're not player controlled
		if(AIStatus != AI_OFF && !target)
			var/my_ventcrawl_freq = freq_ventcrawl_idle
			if (ts_count_dead > 0)
				if (world.time < (ts_death_last + ts_death_window))
					my_ventcrawl_freq = freq_ventcrawl_combat
			if (cocoon_target)
				if(get_dist(src, cocoon_target) <= 1)
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
						ClearObstacle(get_turf(cocoon_target))
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
						ClearObstacle(get_turf(entry_vent))
						if (spider_opens_doors)
							for(var/obj/machinery/door/airlock/A in view(1,src))
								if (A.density)
									try_open_airlock(A)
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
			else if (ai_spins_webs && prob(idle_spinwebs_chance))
				var/obj/effect/spider/terrorweb/T = locate() in get_turf(src)
				if (T)
				else
					new /obj/effect/spider/terrorweb(get_turf(src))
					visible_message("<span class='notice'>\the [src] puts up some spider webs.</span>")
			else if (ai_cocoons_objects && prob(idle_cocoon_chance))
				var/list/can_see = view(src, 10)
				//first, check for potential food nearby to cocoon
				for(var/mob/living/C in can_see)
					if(C.stat && C.stat != CONSCIOUS && !istype(C, /mob/living/simple_animal/hostile/poison/terror_spider))
						spider_steps_taken = 0
						cocoon_target = C
						return
					//second, spin a sticky spiderweb on this tile
					var/obj/effect/spider/terrorweb/W = locate() in get_turf(src)
					if(!W)
						Web()
					else
						//third, lay an egg cluster there
						if(fed)
							DoLayGreenEggs()
						else
							//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
							for(var/obj/O in can_see)
								if(O.anchored)
									continue
								if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery) || istype(O, /obj/item/device/flashlight/lamp))
									if (!istype(O, /obj/item/weapon/paper))
										cocoon_target = O
										stop_automated_movement = 1
										spider_steps_taken = 0
			else if (ai_hides_in_vents && prob(25))
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
						if(!v.welded)
							if (get_dist(src,v) < vdistance)
								temp_vent = v
								vdistance = get_dist(src,v)
					if (temp_vent)
						if (get_dist(src,temp_vent) > 0 && get_dist(src,temp_vent) < 5)
							step_to(src,temp_vent)
							// if you're bumped off your vent, try to get back to it
			else if (ai_ventcrawls && world.time > (last_ventcrawl_time + my_ventcrawl_freq))
				if (prob(idle_ventcrawl_chance))
					var/vdistance = 99
					for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
						if(!v.welded)
							if (get_dist(src,v) < vdistance)
								entry_vent = v
								vdistance = get_dist(src,v)
					if(entry_vent)
						path_to_vent = 1
						last_ventcrawl_time = world.time
		else if (AIStatus != AI_OFF && target)
			if (prob(30))
				var/tgt_dir = get_dir(src,target)
				for(var/obj/machinery/door/firedoor/F in view(1,src))
					if (tgt_dir == get_dir(src,F) && F.density && !F.blocked)
						visible_message("<span class='danger'>\the [src] pries open the firedoor!</span>")
						F.open()
				if (spider_opens_doors)
					for(var/obj/machinery/door/airlock/A in view(1,src))
						if (tgt_dir == get_dir(src,A) && A.density)
							try_open_airlock(A)
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/Bump(atom/user)
	if(istype(user, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = user
		if (A.density)
			try_open_airlock(A)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ClearObstacle(var/turf/target_turf)
	DestroySurroundings()
	//var/turf/T = get_step(src, get_dir(src, target_turf))
	//for(var/atom/A in T)
	//	if (spider_debug == 2) // HARDCORE DEBUGGING!
	//		visible_message("<span class='notice'>\the [src] considers smashing the [A].</span>")
	//	if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack) || istype(A, /obj/machinery/door/window) )
	//		A.attack_animal(src)
	//		return 1
	//return 0

/mob/living/simple_animal/hostile/poison/terror_spider/harvest()

	// DROPS ONLY IF A KNIFE IS USED ON THE SPIDER'S BODY.
	// MORE POWERFUL LOOT & CRAFTING COMPONENTS GO HERE.

	if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/red))
		// RED drops body armor for defense.
		new /obj/item/clothing/suit/armor/terrorspider_carapace(get_turf(src))
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/gray))
		// GRAY drops nothing because it is a weak spider, and its special ability, cloaking, isn't something we can give players.
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/green))
		// GREEN drops a pheromone gland
		new /obj/item/weapon/reagent_containers/terrorspider_parts/toxgland_green(get_turf(src))
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/black))
		// BLACK drops its poison gland, deadly neurotoxin
		new /obj/item/weapon/reagent_containers/terrorspider_parts/toxgland_black(get_turf(src))
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/white))
		// WHITE drops its poison gland, parasitic eggs
		// if we are NOT in an awaymission (prevent self-antagging)
		if (!spider_awaymission)
			new /obj/item/weapon/reagent_containers/terrorspider_parts/toxgland_white(get_turf(src))
	//else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/purple))
	//	// PURPLE drops nothing because it SHOULD be next to the queen who has more valuable loot
	// T3s/T4s have no harvestable parts because I have not figured out good ideas yet
	gib()
	return


/mob/living/simple_animal/hostile/poison/terror_spider/proc/droploot()
	// DROPS ON DEATH.
	// AWAY MISSION LOOT, AND RP FEEL-GOOD LOOT GOES HERE
	if (spider_uo71)
		if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/white))
			//var/obj/item/weapon/card/id/I = new /obj/item/weapon/card/id/away02(get_turf(src))
			//I.layer = 4.2
			//visible_message("<span class='notice'>Amongst the remains of [src], you see an ID card...</span>")
			UnlockBlastDoors("UO71_Bridge", "UO71 Bridge is now unlocked!")
		else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/prince))
			//var/obj/item/weapon/card/id/I = new /obj/item/weapon/card/id/away04(get_turf(src))
			//I.layer = 4.2
			//visible_message("<span class='notice'>Amongst the remains of [src], you see an ID card...</span>")
			UnlockBlastDoors("UO71_SciStorage", "UO71 Secure Science Storage is now unlocked!")
		else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/queen))
			//var/obj/item/weapon/card/id/I = new /obj/item/weapon/card/id/away05(get_turf(src))
			//I.layer = 4.2
			//visible_message("<span class='notice'>Amongst the remains of [src], you see an ID card...</span>")
			UnlockBlastDoors("UO71_Caves", "UO71 Caves are now unlocked!")
	if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/white))
		var/obj/item/clothing/accessory/medal/M = new /obj/item/clothing/accessory/medal/silver(get_turf(src))
		M.layer = 4.1
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/queen))
		var/obj/item/clothing/accessory/medal/M = new /obj/item/clothing/accessory/medal/gold(get_turf(src))
		M.layer = 4.1
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/prince))
		var/obj/item/clothing/accessory/medal/M = new /obj/item/clothing/accessory/medal/gold(get_turf(src))
		M.layer = 4.1
	else if (istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/empress))
		var/obj/item/clothing/accessory/medal/M = new /obj/item/clothing/accessory/medal/gold/heroism(get_turf(src))
		M.layer = 4.1
	return

/mob/living/simple_animal/hostile/poison/terror_spider/proc/UnlockBlastDoors(var/target_id_tag, var/msg_to_send)
	var/unlocked_something = 0
	for (var/obj/machinery/door/poddoor/P in world)
		if (P.density && P.id_tag == target_id_tag && P.z == src.z)
			P.open()
			unlocked_something = 1
	if (unlocked_something)
		for(var/mob/living/carbon/human/H in player_list)
			if (H.z != src.z)
				continue
			to_chat(H,"<span class='notice'>----------</span>")
			to_chat(H,"<span class='notice'>" + msg_to_send + "</span>")
			to_chat(H,"<span class='notice'>----------</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoHiveSense()
	var/hsline = ""
	to_chat(src, "Your Brood: ")
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
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
		to_chat(src,hsline)


/mob/living/simple_animal/hostile/poison/terror_spider/proc/DialogHiveCommand()
	var/dstance = input("How aggressive should your brood be?") as null|anything in list("Aggressive","Defensive","Passive")

	var/new_ai = -1
	if (dstance == "Aggressive")
		new_ai = 0
	else if (dstance == "Defensive")
		new_ai = 1
	else if (dstance == "Passive")
		new_ai = 2
	else
		to_chat(src, "That choice was not recognized.")
		return

	var/dai = input("How often should they use vents?") as null|anything in list("Constantly","Sometimes","Rarely", "Never")

	var/new_ventcrawl = 0
	if (dai == "Constantly")
		new_ventcrawl = 15
	else if (dai == "Sometimes")
		new_ventcrawl = 5
	else if (dai == "Rarely")
		new_ventcrawl = 2
	else if (dai == "Never")
		new_ventcrawl = 0
	else
		to_chat(src, "That choice was not recognized.")
		return

	var/dpc = input("Allow ghosts to inhabit spider bodies?") as null|anything in list("Yes","No")

	var/new_pc = 0
	if (dpc == "Yes")
		new_pc = 1
	else if (dpc == "No")
		new_pc = 0
	else
		to_chat(src, "That choice was not recognized.")
		return

	msg_terrorspiders("[src] has ordered their hive to be [dstance].")
	var/commanded = SetHiveCommand(new_ai,new_ventcrawl,new_pc)

	to_chat(src, "<B><span class='notice'> [commanded] spiders recieved your orders.</span></B>")


/mob/living/simple_animal/hostile/poison/terror_spider/proc/SetHiveCommand(var/set_ai, var/set_ventcrawl, var/set_pc)
	var/numspiders = 0
	//var/orderschanged = 0
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
		if (spider_awaymission && !T.spider_awaymission)
			continue
		else if (!spider_awaymission && T.spider_awaymission)
			continue
		numspiders += 1
		//orderschanged = 0
		if (spider_tier >= T.spider_tier)
			if (T.ai_type != set_ai)
				T.ai_type = set_ai
				//orderschanged = 1
				T.ShowOrders()
			if (T.idle_ventcrawl_chance != set_ventcrawl)
				T.idle_ventcrawl_chance = set_ventcrawl
			if (T.ai_playercontrol_allowingeneral != set_pc)
				if (set_pc == 1 && !spider_awaymission)
					notify_ghosts("[T.name] in [get_area(T)] can be controlled! <a href=?src=\ref[T];activate=1>(Click to play)</a>")
				T.ai_playercontrol_allowingeneral = set_pc
	for(var/obj/effect/spider/terror_eggcluster/T in world)
		if (T.ai_playercontrol_allowingeneral != set_pc)
			T.ai_playercontrol_allowingeneral = set_pc
	for(var/obj/effect/spider/terror_spiderling/T in world)
		if (T.ai_playercontrol_allowingeneral != set_pc)
			T.ai_playercontrol_allowingeneral = set_pc
	return numspiders

/mob/living/simple_animal/hostile/poison/terror_spider/proc/try_open_airlock(var/obj/machinery/door/airlock/D)
	if (!D.density)
		to_chat(src, "Closing doors does not help us.")
	else if (D.welded)
		to_chat(src, "The door is welded shut.")
	else if (D.locked)
		to_chat(src, "The door is bolted shut.")
	else if (D.operating)
	else if ( (!istype(D.req_access) || !D.req_access.len) && (!istype(D.req_one_access) || !D.req_one_access.len) && (D.req_access_txt == "0") && (D.req_one_access_txt == "0") )
		//visible_message("<span class='danger'>\the [src] opens the public-access door [D]!</span>")
		D.open(1)
	else if (D.arePowerSystemsOn() && (spider_opens_doors != 2))
		to_chat(src, "The door's motors resist your efforts to force it.")
	else if (!spider_opens_doors)
		to_chat(src, "Your type of spider is not strong enough to force open doors.")
	else
		visible_message("<span class='danger'>\the [src] pries open the door!</span>")
		playsound(src.loc, "sparks", 100, 1)
		D.open(1)

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
				var/original_location = loc
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)
					if(!exit_vent || exit_vent.welded)
						loc = original_location
						entry_vent = null
						return
					if(prob(99))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					spawn(travel_time)
						if(!exit_vent || exit_vent.welded)
							loc = original_location
							entry_vent = null
							return
						loc = exit_vent.loc
						entry_vent = null
						var/area/new_area = get_area(loc)
						if(new_area)
							new_area.Entered(src)
						if (!istype(src, /mob/living/simple_animal/hostile/poison/terror_spider/gray))
							visible_message("<B>[src] emerges from the vent!</B>")

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
	var/humanize_prompt = "Take direct control of " + src.name + "? "
	if (ai_type == 0)
		humanize_prompt += "Orders: AGGRESSIVE. "
	else if (ai_type == 1)
		humanize_prompt += "Orders: DEFENSIVE. "
	else if (ai_type == 2)
		humanize_prompt += "Orders: PASSIVE/TAME. "
	humanize_prompt += "Role: " + spider_role_summary
	if (user.ckey in ts_ckey_blacklist)
		error_on_humanize = "You are not able to control any terror spider this round."
	else if (!ai_playercontrol_allowingeneral)
		error_on_humanize = "Terror spiders cannot currently be player-controlled."
	else if (spider_awaymission)
		error_on_humanize = "Terror spiders that are part of an away mission cannot be controlled by ghosts."
	else if (!ai_playercontrol_allowtype)
		error_on_humanize = "This specific type of terror spider is not player-controllable."
	else if (degenerate)
		error_on_humanize = "Dying spiders are not player-controllable."
	else if (health == 0)
		error_on_humanize = "Dead spiders are not player-controllable."
	if (jobban_isbanned(user, "Syndicate") || jobban_isbanned(user, "alien"))
		to_chat(user,"You are jobbanned from role of syndicate and/or alien lifeform.")
		return
	if (error_on_humanize == "")
		var/spider_ask = alert(humanize_prompt, "Join as Terror Spider?", "Yes", "No")
		if(spider_ask == "No" || !src || qdeleted(src))
			return
	else
		to_chat(user, "Cannot inhabit spider: " + error_on_humanize)
		return
	if(key)
		to_chat(user, "<span class='notice'>Someone else already took this spider.</span>")
		return
	key = user.key
	for(var/mob/dead/observer/G in player_list)
		G.show_message("<i>A ghost has taken control of <b>[src]</b>. ([ghost_follow_link(src, ghost=G)]).</i>")
	// T1
	ShowGuide()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoLayGreenEggs()
	var/obj/effect/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
	else if(!fed)
		to_chat(src, "<span class='warning'>You are too hungry to do this!</span>")
	else if(busy != LAYING_EGGS)
		busy = LAYING_EGGS
		visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
		stop_automated_movement = 1
		spawn(50)
			if(busy == LAYING_EGGS)
				E = locate() in get_turf(src)
				if(!E)
					if (prob(33))
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red, 2, 1)
					else if (prob(50))
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black, 2, 1)
					else
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green, 2, 1)
					fed--
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoWrap()
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
				if (istype(O, /obj/effect/spider/terrorweb))
				else
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

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: SHARED VERBS -----------------------------
// --------------------------------------------------------------------------------

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

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoShowOrders(var/usecache = 0, var/thequeen = null, var/theempress = null)
	if (ckey)
		/*
		var/i_am_queen = 0
		var/i_am_empress = 0
		if (!usecache)
			for(var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q in mob_list)
				if (Q.ckey || !Q.spider_awaymission)
					thequeen = Q
					if (thequeen == src)
						i_am_queen = 1
					break
			for(var/mob/living/simple_animal/hostile/poison/terror_spider/empress/E in mob_list)
				if (E.ckey || !E.spider_awaymission)
					theempress = E
					if (theempress == src)
						i_am_empress = 1
					break
		to_chat(src, "Hive Status: ")
		if (theempress)
			to_chat(src, "- Empress: [theempress], in [get_area(theempress)], supreme commander of all terror spiders.")
		if (thequeen)
			if (i_am_empress)
				to_chat(src, "- Queen: [thequeen], in [get_area(thequeen)]. As Empress, you command the Queen.")
			else if (i_am_queen)
				to_chat(src, "- Queen: [thequeen] in [get_area(thequeen)]. You command the brood.")
			else
				to_chat(src, "- Queen: [thequeen] in [get_area(thequeen)]. Commander of this brood. Must be obeyed.")
		else
			if (i_am_empress)
				to_chat(src, "- Queen: None! You should probably lay a queen egg to create one.")
			else
				to_chat(src, "- Queen: None! Relying on standing orders.")
		to_chat(src, "Your Status: ")
		to_chat(src, " - Role: [spider_role_summary]")
		*/
		to_chat(src, "------------------------")
		if (ai_type == 0)
			to_chat(src, "Your Orders: <span class='danger'> kill all humanoids on sight! </span>")
		else if (ai_type == 1)
			to_chat(src, "Your Orders: <span class='notice'> defend yourself & the hive, without being aggressive </span> ")
		else if (ai_type == 2)
			to_chat(src, "Your Orders: <span class='danger'> do not attack anyone, not even in self-defense!</span> ")
		to_chat(src, "------------------------")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/BroadcastOrders()
	var/cache_thequeen = null
	var/cache_theempress = null
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q in mob_list)
		if (Q.ckey || !Q.spider_awaymission)
			cache_thequeen = Q
			break
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/empress/E in mob_list)
		if (E.ckey || !E.spider_awaymission)
			cache_theempress = E
			break
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/S in mob_list)
		S.DoShowOrders(1,cache_thequeen,cache_theempress)


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


/mob/living/simple_animal/hostile/poison/terror_spider/verb/EatCorpse()
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
		to_chat(src, "[nibbletarget] is not edible.")
	else if (nibbletarget in nibbled)
		to_chat(src, "You have already eaten some of [nibbletarget].")
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


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 RED TERROR --------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: generic attack spider
// -------------: AI: uses very powerful fangs to wreck people in melee
// -------------: SPECIAL: the more you hurt it, the harder it bites you
// -------------: TO FIGHT IT: shoot it from range. Kite it.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/MightyGlacier
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/red
	name = "red terror spider"
	desc = "An ominous-looking red spider, it has eight beady red eyes, and nasty, big, pointy fangs!"
	altnames = list("Red Terror spider","Crimson Terror spider","Bloody Butcher spider")

	spider_role_summary = "High health, high damage, very slow, melee juggernaut"

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
// ----------------- TERROR SPIDERS: T2 PURPLE TERROR -----------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: guarding queen nests
// -------------: AI: returns to queen if too far from her.
// -------------: SPECIAL: chance to stun on hit
// -------------: TO FIGHT IT: shoot it from range, bring friends!
// -------------: CONCEPT:http://tvtropes.org/pmwiki/pmwiki.php/Main/PraetorianGuard
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/purple
	name = "praetorian spider"
	desc = "An ominous-looking purple spider."
	spider_role_summary = "Guards the nest of the Queen of Terror."

	icon_state = "terror_purple"
	icon_living = "terror_purple"
	icon_dead = "terror_purple_dead"
	maxHealth = 300
	health = 300
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 6
	idle_ventcrawl_chance = 0 // stick to the queen!
	spider_tier = 2

	ai_ventcrawls = 0


/mob/living/simple_animal/hostile/poison/terror_spider/purple/death(gibbed)
	if (spider_myqueen)
		var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q = spider_myqueen
		if (Q.health > 0 && !Q.ckey)
			if (get_dist(src,Q) > 20)
				if (!degenerate && !Q.degenerate)
					degenerate = 1
					Q.DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple,1,0)
					visible_message("<span class='notice'> [src] chitters in the direction of [Q]!</span>")
	..()


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GRAY TERROR -------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ambusher
// -------------: AI: hides in vents, emerges when prey is near to kill it, then hides again. Intended to scare normal crew.
// -------------: SPECIAL: invisible when on top of a vent, emerges when prey approaches or gets trapped in webs
// -------------: TO FIGHT IT: shoot it through a window, or make it regret ambushing you
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/StealthExpert
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/gray
	name = "gray terror spider"
	desc = "An ominous-looking gray spider, its color and shape makes it hard to see."
	altnames = list("Gray Trap spider","Gray Stalker spider","Ghostly Ambushing spider")
	spider_role_summary = "Stealth spider that ambushes weak humans from vents."

	icon_state = "terror_gray"
	icon_living = "terror_gray"
	icon_dead = "terror_gray_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its almost invisible.
	health = 120
	melee_damage_lower = 15 // same as guard spider, its a melee class
	melee_damage_upper = 20
	ventcrawler = 1
	move_to_delay = 5 // normal speed
	stat_attack = 1 // ensures they will target people in crit, too!
	environment_smash = 1
	wander = 0 // wandering defeats the purpose of stealth
	idle_vision_range = 3 // very low idle vision range
	ai_hides_in_vents = 1
	vision_type = null // prevent them seeing through walls when doing AOE web.


/mob/living/simple_animal/hostile/poison/terror_spider/gray/adjustBruteLoss(var/damage)
	..(damage)
	if (invisibility > 0 || icon_state == "terror_gray_cloaked")
		GrayDeCloak()

/mob/living/simple_animal/hostile/poison/terror_spider/gray/adjustFireLoss(var/damage)
	..(damage)
	if (invisibility > 0 || icon_state == "terror_gray_cloaked")
		GrayDeCloak()

/mob/living/simple_animal/hostile/poison/terror_spider/gray/Aggro()
	GrayDeCloak()
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/gray/AttackingTarget()
	if (invisibility > 0 || icon_state == "terror_gray_cloaked")
		GrayDeCloak()
	else
		..()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/GrayCloak()
	visible_message("<span class='notice'> [src] hides in the vent.</span>")
	invisibility = SEE_INVISIBLE_LEVEL_ONE
	icon_state = "terror_gray_cloaked"
	icon_living = "terror_gray_cloaked"
	if (!ckey)
		vision_range = 3
		idle_vision_range = 3
	// Bugged, does not work yet. Also spams webs. Also doesn't look great. But... planned.
	move_to_delay = 15 // while invisible, slow.

/mob/living/simple_animal/hostile/poison/terror_spider/proc/GrayDeCloak()
	invisibility = 0
	icon_state = "terror_gray"
	icon_living = "terror_gray"
	vision_range = 9
	idle_vision_range = 9
	move_to_delay = 5

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ListValidTurfs()
	var/list/potentials = list()
	for (var/turf/simulated/T in oview(3,get_turf(src)))
		if (T.density == 0 && get_dist(get_turf(src),T) == 3)
			var/obj/effect/spider/terrorweb/W = locate() in T
			if (!W)
				var/obj/structure/grille/G = locate() in T
				if (!G)
					var/obj/structure/window/O = locate() in T
					if (!O)
						potentials += T
	return potentials

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ListWebbedTurfs()
	var/list/webbed = list()
	for (var/turf/simulated/T in oview(3,get_turf(src)))
		if (T.density == 0 && get_dist(get_turf(src),T) == 3)
			var/obj/effect/spider/terrorweb/W = locate() in T
			if (W)
				webbed += T
	return webbed

/mob/living/simple_animal/hostile/poison/terror_spider/proc/ListVisibleTurfs()
	var/list/vturfs = list()
	for (var/turf/simulated/T in oview(7,get_turf(src)))
		if (T.density == 0)
			vturfs += T
	return vturfs


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 BLACK TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: assassin, poisoner, DoT expert
// -------------: AI: attacks to inject its venom, then retreats. Will inject its enemies multiple times then hang back to ensure they die.
// -------------: SPECIAL: venom that does more damage the more of it is in you
// -------------: TO FIGHT IT: if bitten once, retreat, get charcoal/etc treatment, and come back with a gun.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/GradualGrinder
// -------------: SPRITES FROM: Travelling Merchant, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=2766

/mob/living/simple_animal/hostile/poison/terror_spider/black
	name = "black widow spider"
	desc = "An ominous-looking spider, black as the darkest night, and with merciless yellow eyes."
	altnames = list("Black Devil spider","Giant Black Widow spider","Shadow Terror spider")
	spider_role_summary = "Hit-and-run attacker with extremely venomous bite."

	icon_state = "terror_black"
	icon_living = "terror_black"
	icon_dead = "terror_black_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its bite will kill you!
	health = 120
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 5
	stat_attack = 1 // ensures they will target people in crit, too!
	spider_tier = 2


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GREEN TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: reproduction
// -------------: AI: after it kills you, it webs you and lays new terror eggs on your body
// -------------: SPECIAL: can also create webs, web normal objects, etc
// -------------: TO FIGHT IT: kill it however you like - just don't die to it!
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/EnemySummoner
// -------------: SPRITES FROM: Codersprites :(

/mob/living/simple_animal/hostile/poison/terror_spider/green
	name = "green terror spider"
	desc = "An ominous-looking green spider, it has a small egg-sac attached to it."
	altnames = list("Green Terror spider","Insidious Breeding spider","Fast Bloodsucking spider")
	spider_role_summary = "Average melee spider that webs its victims and lays more spider eggs"

	icon_state = "terror_green"
	icon_living = "terror_green"
	icon_dead = "terror_green_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	ventcrawler = 1
	ai_cocoons_objects=1


/mob/living/simple_animal/hostile/poison/terror_spider/green/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to eat (allowing you to lay eggs) and objects (making them inaccessible to humans)."
	DoWrap()


/mob/living/simple_animal/hostile/poison/terror_spider/green/verb/LayGreenEggs()
	set name = "Lay Green Eggs"
	set category = "Spider"
	set desc = "Lay a clutch of eggs. You must have wrapped a prey creature for feeding first."
	DoLayGreenEggs()


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 WHITE TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: stealthy reproduction
// -------------: AI: injects a venom that makes you grow spiders in your body, then retreats
// -------------: SPECIAL: stuns you on first attack - vulnerable to groups while it does this
// -------------: TO FIGHT IT: blast it before it can get away
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/BodyHorror
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/white
	name = "white death spider"
	desc = "An ominous-looking white spider, its ghostly eyes and vicious-looking fangs are the stuff of nightmares."
	spider_role_summary = "Rare, bite-and-run spider that infects hosts with spiderlings"

	altnames = list("White Terror spider","White Death spider","Ghostly Nightmare spider")
	icon_state = "terror_white"
	icon_living = "terror_white"
	icon_dead = "terror_white_dead"
	maxHealth = 100
	health = 100
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 4
	ventcrawler = 1
	spider_tier = 2


/mob/living/simple_animal/hostile/poison/terror_spider/white/LoseTarget()
	stop_automated_movement = 0
	..()

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 MOTHER OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: living schmuck bait
// -------------: AI: no special ai
// -------------: SPECIAL: spawns an ungodly number of spiderlings when killed
// -------------: TO FIGHT IT: don't! Just leave it alone! It is harmless by itself... but god help you if you aggro it.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/MotherOfAThousandYoung
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/SchmuckBait
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/mother
	name = "mother of terror spider"
	desc = "An enormous spider. Its back is a crawling mass of spiderlings. All of them look around with beady little eyes. The horror!"
	spider_role_summary = "Schmuck bait. Extremely weak in combat, but spawns many spiderlings when it dies."

	altnames = list("Seemingly Harmless spider","Strange spider","Wolf Mother spider")
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

	spider_tier = 3
	spider_opens_doors = 2

	var/canspawn = 1

/mob/living/simple_animal/hostile/poison/terror_spider/mother/death(gibbed)
	if (canspawn)
		canspawn = 0
		for(var/i=0, i<30, i++)
			var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
			S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray)
			if (prob(50))
				S.stillborn = 1
			else if (prob(10))
				S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/black, /mob/living/simple_animal/hostile/poison/terror_spider/green)
		visible_message("<span class='userdanger'>\the [src] breaks apart, the many spiders on its back scurrying everywhere!</span>")
		degenerate = 1
		loot = 0
	..()

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 PRINCE OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: boss
// -------------: AI: no special ai
// -------------: SPECIAL: massive health
// -------------: TO FIGHT IT: a squad of at least 4 people with laser rifles.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/LightningBruiser
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/WakeupCallBoss
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/prince
	name = "prince of terror spider"
	desc = "An enormous, terrifying spider. It looks like it is judging everything it sees. Extremely dangerous."
	spider_role_summary = "Boss-level terror spider. Lightning bruiser. Capable of taking on a squad by itself."

	altnames = list("Prince of Terror","Terror Prince")
	icon_state = "terror_queen"
	icon_living = "terror_queen"
	icon_dead = "terror_queen_dead"
	maxHealth = 600 // 30 laser shots. 15 cannon shots
	health = 600
	melee_damage_lower = 15
	melee_damage_upper = 25
	move_to_delay = 5
	ventcrawler = 1

	ai_ventcrawls = 0 // no override, never ventcrawls. Ever.
	idle_ventcrawl_chance = 0

	spider_tier = 3
	spider_opens_doors = 2

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T4 QUEEN OF TERROR ---------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: gamma-level threat to the whole station, like a blob
// -------------: AI: builds a nest, lays many eggs, attempts to take over the station
// -------------: SPECIAL: spins webs, breaks lights, breaks cameras, webs objects, lays eggs, commands other spiders...
// -------------: TO FIGHT IT: bring an army, and take no prisoners. Mechs and/or decloner guns are a very good idea.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/HiveQueen
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/queen
	name = "Queen of Terror spider"
	desc = "An enormous, terrifying spider. Its egg sac is almost as big as its body, and teeming with spider eggs."
	spider_role_summary = "Commander of the spider forces. Lays eggs & directs the brood."

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
	var/spider_spawnfrequency = 1200 // 120 seconds, remember, times are in deciseconds
	var/spider_spawnfrequency_stable = 1200 // 120 seconds, spawnfrequency is set to this on ai spiders once nest setup is complete.
	var/spider_lastspawn = 0
	var/nestfrequency = 150 // 15 seconds
	var/lastnestsetup = 0
	var/neststep = 0
	var/spider_max_per_nest = 20 // above this, queen stops spawning more, and declares war.

	var/canlay = 0 // main counter for egg-laying ability! # = num uses, incremented at intervals
	var/spider_can_hallucinate = 5 // single target hallucinate, atmosphere
	var/spider_can_screech = 2 // breaks lights, cameras. Used on nesting, and before war.
	var/spider_can_fakelings = 3 // spawns defective spiderlings that don't grow up, used to freak out crew, atmosphere

	idle_ventcrawl_chance = 0
	force_threshold = 18 // outright immune to anything of force under 18, this means welders can't hurt it, only guns can

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/pierce.ogg'
	projectiletype = /obj/item/projectile/terrorqueenspit

	spider_tier = 4
	spider_opens_doors = 1

	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID


/mob/living/simple_animal/hostile/poison/terror_spider/queen/New()
	..()
	spider_myqueen = src
	if (spider_awaymission)
		spider_growinstantly = 1
		spider_spawnfrequency = 150
	spawn(30)
		if (!ckey && ai_playercontrol_allowingeneral && ai_playercontrol_allowtype && !spider_awaymission)
			notify_ghosts("[src] has appeared in [get_area(src)]. <a href=?src=\ref[src];activate=1>(Click to control)</a>")


/mob/living/simple_animal/hostile/poison/terror_spider/queen/Life()
	..()
	if (stat != DEAD)
		if (ckey && canlay < 12) // max 12 eggs worth stored at any one time, realistically that's tons.
			if (world.time > (spider_lastspawn + spider_spawnfrequency))
				canlay++
				spider_lastspawn = world.time
				if (canlay == 1)
					to_chat(src, "<span class='notice'>You are able to lay eggs again.</span>")
				else if (canlay == 12)
					to_chat(src, "<span class='notice'>You have [canlay] eggs available to lay. You won't grow any more eggs until you lay some of your existing ones.</span>")
				else
					to_chat(src, "<span class='notice'>You have [canlay] eggs available to lay.</span>")


/mob/living/simple_animal/hostile/poison/terror_spider/queen/death(gibbed)
	// When a queen dies, so do ALL her player-controlled purple-type guardians. Intended as a motivator for purples to ensure they guard her.
	if (!gibbed)
		for(var/mob/living/simple_animal/hostile/poison/terror_spider/purple/P in mob_list)
			if (ckey)
				P.visible_message("<span class='danger'>\the [src] writhes in pain!</span>")
				to_chat(P,"<span class='userdanger'>\the [src] has died. Without her hivemind link, purple terrors like yourself cannot survive more than a few minutes!</span>")
				P.degenerate = 1
				P.loot = 0
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/queen/handle_automated_action()
	..()
	if(!stat && !ckey && AIStatus != AI_OFF && !target && !path_to_vent)
		if (neststep == 0)
			// we have no nest :(
			var/ok_to_nest = 1
			var/area/new_area = get_area(loc)
			if (new_area)
				if (findtext(new_area.name,"hall"))
					ok_to_nest = 0
					// nesting in a hallway would be very stupid - crew would find and kill you almost instantly
			var/numhostiles = 0
			for (var/mob/living/H in oview(10,src))
				if (!istype(H, /mob/living/simple_animal/hostile/poison/terror_spider))
					if (H.stat != DEAD)
						numhostiles += 1
						// nesting RIGHT NEXT TO SOMEONE is even worse
			if (numhostiles > 0)
				ok_to_nest = 0
			var/vdistance = 99
			for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
				if(!v.welded)
					if (get_dist(src,v) < vdistance)
						entry_vent = v
						vdistance = get_dist(src,v)
			if (!entry_vent)
				ok_to_nest = 0
				// don't nest somewhere with no vent - your brood won't be able to get out!
			if (ok_to_nest && entry_vent)
				nest_vent = entry_vent
				neststep = 1
				visible_message("<span class='danger'>\the [src] settles down, starting to build a nest.</span>")
				ai_ventcrawls = 0
			else if (entry_vent)
				if (!path_to_vent)
					visible_message("<span class='danger'>\the [src] looks around warily - then retreats.</span>")
					path_to_vent = 1
			else
				visible_message("<span class='danger'>\the [src] looks around, searching for the vent that should be there, but isn't. A bluespace portal forms on her, and she is gone.</span>")
				qdel(src)
				new /obj/effect/portal(get_turf(src.loc))
		else if (neststep == 1)
			if (world.time > (lastnestsetup + nestfrequency))
				lastnestsetup = world.time
				DoQueenScreech(8,100,8,100)
				neststep = 2
		else if (neststep == 2)
			if (world.time > (lastnestsetup + nestfrequency))
				if (!spider_awaymission)
					QueenHallucinate()
				lastnestsetup = world.time
				spider_lastspawn = world.time
				DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple,2,0)
				neststep = 3
		else if (neststep == 3)
			if (world.time > (spider_lastspawn + spider_spawnfrequency))
				if (prob(20))
					var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
					if(!N)
						if (!spider_awaymission)
							QueenHallucinate()
						spider_lastspawn = world.time
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green,2,0)
						neststep = 4
		else if (neststep == 3)
			if (world.time > (spider_lastspawn + spider_spawnfrequency))
				if (prob(20))
					var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
					if(!N)
						if (!spider_awaymission)
							QueenHallucinate()
						spider_lastspawn = world.time
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black,2,1)
						neststep = 4
		else if (neststep == 4)
			if (world.time > (spider_lastspawn + spider_spawnfrequency))
				if (prob(20))
					var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
					if(!N)
						if (!spider_awaymission)
							QueenFakeLings()
						spider_lastspawn = world.time
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red,2,1)
						neststep = 5
		else if (neststep == 5)
			if (world.time > (spider_lastspawn + spider_spawnfrequency))
				if (prob(20))
					var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
					if(!N)
						if (!spider_awaymission)
							QueenFakeLings()
						spider_lastspawn = world.time
						if (prob(33))
							DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/gray,2,1)
						else if (prob(50))
							DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red,2,1)
						else
							DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green,2,1)
				var/spidercount = CountSpiders()
				if (spidercount >= spider_max_per_nest) // station overwhelmed!
					neststep = 6
		else if (neststep == 6)
			if (world.time > (spider_lastspawn + spider_spawnfrequency))
				spider_lastspawn = world.time
				// go hostile, EXTERMINATE MODE.
				SetHiveCommand(0,15,1) // AI=0 (attack everyone), ventcrawl=15%/tick, allow player control (ignored for queens in awaymissions)
				DoQueenScreech(20,50,15,100)
				var/numspiders = CountSpiders()
				if (numspiders < spider_max_per_nest)
					if (prob(33))
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black,2,1)
					else if (prob(50))
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red,2,0)
					else
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green,2,1)
				else if (spider_awaymission)
					neststep = 7
					spider_spawnfrequency = spider_spawnfrequency_stable
					// if we're an away mission queen... don't keep spawning spiders at insane rates. Away team should have a chance.
		else if (neststep == 7)
			if (world.time > (spider_lastspawn + spider_spawnfrequency))
				spider_lastspawn = world.time
				var/numspiders = CountSpiders()
				if (numspiders < spider_max_per_nest)
					// someone is killing my children...
					if (prob(25))
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black,2,1)
					else if (prob(33))
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red,2,0)
					else if (prob(50))
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green,2,1)
					else
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple,2,0)
					neststep = 6





/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/HiveSense()
	set name = "Hive Sense"
	set category = "Spider"
	set desc = "Sense the spiders at your command."
	DoHiveSense()


/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/HiveCommand()
	set name = "HiveCommand"
	set category = "Spider"
	set desc = "Instruct your brood on proper behavior."
	DialogHiveCommand()


/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/QueenKillSpider()
	set name = "Kill Spider"
	set category = "Spider"
	set desc = "Kills an adjacent spider. If they are player-controlled, also bans them from controlling any other spider for the rest of the round."
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
		to_chat(src, "[killtarget] is not living.")
	else if (!istype(killtarget, /mob/living/simple_animal/hostile/poison/terror_spider/))
		to_chat(src, "[killtarget] is not a terror spider.")
	else
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = killtarget
		if (T.ckey)
			// living player
			ts_ckey_blacklist += T.ckey
		visible_message("<span class='danger'> [src] grabs hold of [T] and tears them limb from limb! </span>")
		T.death()
		T.gib()
		regen_points += regen_points_per_kill

/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/LayQueenEggs()
	set name = "Lay Queen Eggs"
	set category = "Spider"
	set desc = "Grow your brood."
	if (canlay < 1)
		var/remainingtime = round(((spider_lastspawn + spider_spawnfrequency) - world.time) / 10,1)
		if (remainingtime > 0)
			to_chat(src, "Too soon to attempt that again. Wait another " + num2text(remainingtime) + " seconds.")
		else
			to_chat(src, "Too soon to attempt that again. Wait just a few more seconds...")
		return
	var/list/eggtypes = list("red - assault","gray - ambush", "green - nurse", "black - poison","purple - guard")
	if (canlay >= 12)
		eggtypes |= "MOTHER - ELITE HORROR"
		eggtypes |= "PRINCE - ELITE WARRIOR"
	var/eggtype = input("What kind of eggs?") as null|anything in eggtypes
	if (!(eggtype in eggtypes))
		to_chat(src, "Unrecognized egg type.")
		return 0
	if (eggtype == "MOTHER - ELITE HORROR" || eggtype == "PRINCE - ELITE WARRIOR")
		if (canlay < 12)
			to_chat(src, "Insufficient strength. It takes as much effort to lay one of those as it does to lay 12 normal eggs.")
		else
			if (eggtype == "MOTHER - ELITE HORROR")
				canlay -= 12
				DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/mother,1,0)
			else if (eggtype == "PRINCE - ELITE WARRIOR")
				canlay -= 12
				DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/prince,1,0)
		return
	var/numlings = 1
	if (canlay >= 5)
		numlings = input("How many in the batch?") as null|anything in list(1,2,3,4,5)
	else if (canlay >= 3)
		numlings = input("How many in the batch?") as null|anything in list(1,2,3)
	else if (canlay == 2)
		numlings = input("How many in the batch?") as null|anything in list(1,2)
	if (eggtype == null || numlings == null)
		to_chat(src, "Cancelled.")
		return
	//spider_lastspawn = world.time // don't think we actually need this, if queen is laying manually canlay controls her rate.
	canlay -= numlings
	if (eggtype == "red - assault")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red,numlings,1)
	else if (eggtype == "gray - ambush")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/gray,numlings,1)
	else if (eggtype == "green - nurse")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green,numlings,1)
	else if (eggtype == "black - poison")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black,numlings,1)
	else if (eggtype == "purple - guard")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple,numlings,0)
	else
		to_chat(src, "Unrecognized egg type.")


/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to feast upon and objects for safe keeping."
	DoWrap()


/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/QueenHallucinate()
	set name = "Hallucinate"
	set category = "Spider"
	set desc = "Causes a single crew member to quake in fear."
	if (spider_can_hallucinate)
		spider_can_hallucinate--
		var/list/choices = list()
		for(var/mob/living/carbon/human/H in player_list)
			if (H.z != src.z)
				continue
			if (H == src)
				continue
			if (H.health < 1)
				continue
			if (istype(H, /mob/living/simple_animal/hostile/poison/terror_spider/))
				continue
			choices += H
		if (choices.len < 1)
			to_chat(src,"No valid minds were found in this area.")
			return
		var/madnesstarget = pick(choices)
		if (ckey)
			madnesstarget = null
			madnesstarget = input(src,"Which person should fear?") in null|choices
		if (!madnesstarget)
			// cancel
		else
			var/mob/living/carbon/human/H = madnesstarget
			H.hallucination = max(H.hallucination,300)
			to_chat(H,"<span class='danger'>Your head throbs in pain.</span>")
			to_chat(src, "You reach through bluespace into the mind of [madnesstarget], making their fears come to life. They start to hallucinate.")
	else
		to_chat(src, "You have run out of uses of this ability.")

/mob/living/simple_animal/hostile/poison/terror_spider/queen/verb/VerbQueenScreech()
	set name = "Queen Screech"
	set category = "Spider"
	set desc = "Emit horrendusly loud screech which breaks all nearby cameras and most nearby lights. Can only be used twice!"
	if (spider_can_screech)
		spider_can_screech--
		DoQueenScreech(15,50,10,100)
	else
		src << "You have run out of uses of this ability."


/mob/living/simple_animal/hostile/poison/terror_spider/queen/proc/DoQueenScreech(var/light_range, var/light_chance, var/camera_range, var/camera_chance)
	visible_message("<span class='userdanger'>\the [src] emits a bone-chilling shriek!</span>")
	for(var/obj/machinery/light/L in orange(light_range,src))
		if (prob(light_chance))
			L.on = 1
			L.broken()
	for(var/obj/machinery/camera/C in orange(camera_range,src))
		if (C.status && prob(camera_chance))
			C.toggle_cam(src,0)


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
		to_chat(src, "You have run out of uses of this ability.")



// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T5 EMPRESS OF TERROR -------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ruling over planets of uncountable spiders, like Xenomorph Empresses.
// -------------: AI: none - this is strictly adminspawn-only and intended for RP events, coder testing, and teaching people 'how to queen'
// -------------: SPECIAL: Lay Eggs ability that allows laying queen-level eggs. Wide-area EMP and light-breaking abilities.
// -------------: TO FIGHT IT: run away screaming?
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/EldritchAbomination
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/BiggerBad
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/AuthorityEqualsAsskicking
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/empress
	name = "Empress of Terror"
	desc = "The unholy offspring of spiders, nightmares, and lovecraft fiction."
	spider_role_summary = "Adminbus spider"
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

	maxHealth = 1000
	health = 1000

	melee_damage_lower = 10
	melee_damage_upper = 40

	move_to_delay = 5
	ventcrawler = 1 // Adminbus.

	idle_ventcrawl_chance = 0
	ai_playercontrol_allowtype = 0
	ai_type = 1 // defend self only!

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/pierce.ogg'
	projectiletype = /obj/item/projectile/terrorempressspit
	force_threshold = 18 // same as queen, but a lot more health

	spider_tier = 5
	spider_opens_doors = 2

	var/shown_guide = 0 // has the empress player been warned of the chaos that can result from the use of their powers?

	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID


/mob/living/simple_animal/hostile/poison/terror_spider/empress/New()
	..()
	spawn(600)
		if (!ckey)
			// idea being that if someone spawns her, and she isn't player controlled within 60 seconds, it was probably a mistake and she should be despawned.
			visible_message("[src] steps into a bluespace portal, and is gone!")
			qdel(src)

/mob/living/simple_animal/hostile/poison/terror_spider/empress/Life()
	if (stat != DEAD)
		if (ckey && !shown_guide)
			shown_guide = 1
			ShowGuide()
	..()


/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/LayEmpressEggs()
	set name = "Lay Empress Eggs"
	set category = "Spider"
	set desc = "Lay spider eggs. As empress, you can lay queen-level eggs to create a new brood."
	var/eggtype = input("What kind of eggs?") as null|anything in list("QUEEN", "MOTHER", "PRINCE", "red - assault","gray - ambush", "green - nurse", "black - poison","purple - guard")
	var/numlings = input("How many in the batch?") as null|anything in list(1,2,3,4,5,10,15,20,30,40,50)
	if (eggtype == null || numlings == null)
		to_chat(src, "Cancelled.")
		return
	// T1
	if (eggtype == "red - assault")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red,numlings,1)
	else if (eggtype == "gray - ambush")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/gray,numlings,1)
	else if (eggtype == "green - nurse")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green,numlings,1)
	// T2
	else if (eggtype == "black - poison")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black,numlings,1)
	else if (eggtype == "purple - guard")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/purple,numlings,0)
	// T3
	else if (eggtype == "PRINCE")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/prince,numlings,1)
	else if (eggtype == "MOTHER")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/mother,numlings,1)
	else if (eggtype == "QUEEN")
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/queen,numlings,1)
	// Unrecognized
	else
		to_chat(src, "Unrecognized egg type.")

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/HiveSense()
	set name = "Hive Sense"
	set category = "Spider"
	set desc = "Sense the spiders at your command."
	DoHiveSense()

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/HiveCommand()
	set name = "Hive Command"
	set category = "Spider"
	set desc = "Instruct your brood on proper behavior."
	DialogHiveCommand()

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
			C.toggle_cam(src,0)


/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressMassHallucinate()
	set name = "Mass Hallucinate"
	set category = "Spider"
	set desc = "Causes widespread, terrifying hallucinations amongst many crew as you assault their minds."
	var/numaffected = 0
	for(var/mob/living/carbon/human/H in player_list)
		if (H.z != src.z)
			continue
		if (H.health < 1)
			// nothing
		else if (prob(50))
			// nothing
		else if (prob(50))
			// weak
			H.hallucination = max(300, H.hallucination)
			to_chat(H,"<span class='userdanger'> Your head hurts! </span>")
			numaffected++
		else
			// strong
			H.hallucination = max(600, H.hallucination)
			to_chat(H,"<span class='userdanger'> Your head hurts! </span>")
			numaffected++
	if (numaffected)
		to_chat(src, "You reach through bluespace into the minds of " + num2text(numaffected) + " crew, making their fears come to life. They start to hallucinate.")
	else
		to_chat(src, "You reach through bluespace, searching for organic minds... but find none nearby.")


/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressToggleDebug()
	set name = "Toggle Debug"
	set category = "Spider"
	set desc = "Enables/disables debug mode for spiders."
	if (spider_debug)
		spider_debug = 0
		to_chat(src, "Debug: DEBUG MODE is now <b>OFF</b> for all spiders in world.")
	else
		spider_debug = 1
		to_chat(src, "Debug: DEBUG MODE is now <b>ON</b> for all spiders in world.")
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
		T.spider_debug = spider_debug

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressToggleInstant()
	set name = "Toggle Instant"
	set category = "Spider"
	set desc = "Enables/disables instant growth for spiders."
	if (spider_growinstantly)
		spider_growinstantly = 0
		to_chat(src, "Debug: INSTANT GROWTH is now <b>OFF</b> for all spiders in world.")
	else
		spider_growinstantly = 1
		to_chat(src, "Debug: INSTANT GROWTH is now <b>ON</b> for all spiders in world.")
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
		T.spider_growinstantly = spider_growinstantly

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EmpressKillSpider()
	set name = "Erase Spider"
	set category = "Spider"
	set desc = "Kills a spider. If they are player-controlled, also bans them from controlling any other spider for the rest of the round."
	var/choices = list()
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/L in mob_list)
		if(L == src)
			continue
		if (L.health < 1)
			continue
		choices += L
	var/killtarget = input(src,"Which terror spider should die?") in null|choices
	if (!killtarget)
		// cancel
	else if (!isliving(killtarget))
		to_chat(src, "[killtarget] is not living.")
	else if (!istype(killtarget, /mob/living/simple_animal/hostile/poison/terror_spider/))
		to_chat(src, "[killtarget] is not a terror spider.")
	else
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = killtarget
		if (T.ckey)
			// living player
			ts_ckey_blacklist += T.ckey
		to_chat(T, "<span class='userdanger'> Through the hivemind, the raw power of [src] floods into your body, burning it from the inside out! </span>")
		T.death()
		T.gib()

/mob/living/simple_animal/hostile/poison/terror_spider/empress/verb/EraseBrood()
	set name = "Erase Brood"
	set category = "Spider"
	set desc = "Debug: kill off all other spiders in the world. Takes two minutes to work."
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/T in mob_list)
		if (T.spider_tier < 5)
			T.degenerate = 1
			T.loot = 0
			to_chat(T, "<span class='userdanger'> Through the hivemind, the raw power of [src] floods into your body, burning it from the inside out! </span>")
			//T.Stun(20)
			//T.Weaken(20)
	for(var/obj/effect/spider/terror_eggcluster/T in world)
		qdel(T)
	for(var/obj/effect/spider/terror_spiderling/T in world)
		T.stillborn = 1
	to_chat(src, "Brood will die off shortly.")
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
		S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray, /mob/living/simple_animal/hostile/poison/terror_spider/green, /mob/living/simple_animal/hostile/poison/terror_spider/white, /mob/living/simple_animal/hostile/poison/terror_spider/black)
		S.spider_myqueen = spider_myqueen
		if (prob(sbpc))
			S.stillborn = 1
		if (spider_growinstantly)
			S.amount_grown = 250


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: EGGS (USED BY NURSE AND QUEEN TYPES) ---------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoLayTerrorEggs(var/lay_type, var/lay_number, var/lay_crawl)
	stop_automated_movement = 1
	var/obj/effect/spider/terror_eggcluster/C = new /obj/effect/spider/terror_eggcluster(get_turf(src))
	C.spiderling_type = lay_type
	C.spiderling_number = lay_number
	C.spiderling_ventcrawl = lay_crawl
	C.faction = faction
	C.spider_myqueen = spider_myqueen
	C.master_commander = master_commander
	C.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
	C.enemies = enemies
	if (lay_type == /mob/living/simple_animal/hostile/poison/terror_spider/red)
		C.name = "red spider eggs"
	else if (lay_type == /mob/living/simple_animal/hostile/poison/terror_spider/gray)
		C.name = "gray spider eggs"
	else if (lay_type == /mob/living/simple_animal/hostile/poison/terror_spider/green)
		C.name = "green spider eggs"
	else if (lay_type == /mob/living/simple_animal/hostile/poison/terror_spider/black)
		C.name = "black spider eggs"
	else if (lay_type == /mob/living/simple_animal/hostile/poison/terror_spider/purple)
		C.name = "purple spider eggs"
	else if (lay_type == /mob/living/simple_animal/hostile/poison/terror_spider/white)
		C.name = "white spider eggs"
	else
		C.name = "strange spider eggs"
	if (spider_growinstantly)
		C.amount_grown = 250
		C.spider_growinstantly = 1
	spawn(10)
		stop_automated_movement = 0
	if (spider_queen_declared_war)
		C.spider_queen_declared_war = 1


/obj/effect/spider/terror_eggcluster
	name = "giant egg cluster"
	desc = "A cluster of tiny spider eggs. They pulse with a strong inner life, and appear to have sharp thorns on the sides."
	icon_state = "eggs"
	var/amount_grown = 0
	var/spider_growinstantly = 0
	var/spider_queen_declared_war = 0 // set to 1 by procs
	var/faction = list("terrorspiders")
	var/spider_myqueen = null
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
			S.spider_myqueen = spider_myqueen
			S.master_commander = master_commander
			S.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
			S.enemies = enemies
			if (spider_queen_declared_war)
				S.spider_queen_declared_war = 1
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
	var/spider_queen_declared_war = 0 // set to 1 by inheritance
	var/stillborn = 0
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/faction = list("terrorspiders")
	var/spider_myqueen = null
	var/master_commander = null
	var/use_vents = 1
	var/ai_playercontrol_allowingeneral = 1
	var/list/enemies = list()
	var/stat = 0 // necessary, because without it spiderlings moving into borg rechargers create a runtime error.


/obj/effect/spider/terror_spiderling/New()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	processing_objects.Add(src)


/obj/effect/spider/terror_spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		loc = user.loc
	else if (istype(user, /obj/machinery/recharge_station))
		qdel(src)
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
			var/original_location = loc
			spawn(rand(20,60))
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)
					if(!exit_vent || exit_vent.welded)
						loc = original_location
						entry_vent = null
						return
					if(prob(50))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					spawn(travel_time)
						if(!exit_vent || exit_vent.welded)
							loc = original_location
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
			//if(prob(40))
			//	visible_message("<span class='notice'>\The [src] skitters[pick(" away"," around","")].</span>")
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
				S.spider_myqueen = spider_myqueen
				S.master_commander = master_commander
				S.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
				S.enemies = enemies
				if (spider_queen_declared_war)
					S.spider_queen_declared_war = 1
					if (!istype(S, /mob/living/simple_animal/hostile/poison/terror_spider/purple))
						S.idle_ventcrawl_chance = 15
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
	if(istype(target, /mob))
		var/mob/living/L = target
		if(L.reagents)
			if (L.can_inject(null,0,"chest",0))
				L.reagents.add_reagent("terror_queen_toxin",15)


/obj/item/projectile/terrorempressspit
	name = "poisonous spit"
	damage = 60
	icon_state = "toxin"
	damage_type = TOX


/obj/item/projectile/terrorempressspit/on_hit(var/mob/living/carbon/target)
	if(istype(target, /mob))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent("ketamine",30)
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

/obj/effect/spider/terrorweb/proc/DeCloakNearby()
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/gray/G in view(6,src))
		G.GrayDeCloak()
		G.Aggro()

/obj/effect/spider/terrorweb/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover, /mob/living/simple_animal/hostile/poison/terror_spider))
		return 1
	else if (istype(mover, /obj/item/projectile/terrorqueenspit))
		return 1
	else if (istype(mover, /obj/item/projectile/terrorempressspit))
		return 1
	else if(istype(mover, /mob/living))
		if(prob(80))
			to_chat(mover, "<span class='danger'>You get stuck in \the [src] for a moment.</span>")
			var/mob/living/M = mover
			M.Stun(5) // 5 seconds.
			M.Weaken(5) // 5 seconds.
			M.emote("scream")
			DeCloakNearby()
			return 1
	else if(istype(mover, /obj/item/projectile))
		return prob(20)
	return 1


// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: LOOT DROPS -----------------------------------
// --------------------------------------------------------------------------------


/obj/item/clothing/suit/armor/terrorspider_carapace
	name = "spider carapace armor"
	desc = "A carved section of terror spider carapace that can be used as crude body armor."
	icon_state = "armor-combat"
	item_state = "bulletproof"
	//DEFAULT VALUES: armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	armor = list(melee = 50, bullet = 30, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0)
	// our armor half as effective against lasers, but 2x as effective against bullets. Makes sense - terror spiders had to fight syndicate first, only recently encountered NT


// venom glands.

/obj/item/weapon/reagent_containers/terrorspider_parts
	icon = 'icons/mob/terrorspider.dmi'
	desc = "A body part from a terror spider."

/obj/item/weapon/reagent_containers/terrorspider_parts/toxgland_green
	name = "green terror spider venom gland"
	icon_state = "ts_venomgland"
	origin_tech = "biotech=5;materials=2;combat=4"
	New()
		reagents.add_reagent("terror_green_toxin", 15)

/obj/item/weapon/reagent_containers/terrorspider_parts/toxgland_black
	name = "black terror spider venom gland"
	icon_state = "ts_venomgland"
	origin_tech = "biotech=5;materials=2;combat=5"
	New()
		reagents.add_reagent("terror_black_toxin", 15)

/obj/item/weapon/reagent_containers/terrorspider_parts/toxgland_white
	name = "white terror spider venom gland"
	icon_state = "ts_venomgland"
	origin_tech = "biotech=6;materials=2;combat=5"
	New()
		reagents.add_reagent("terror_white_toxin", 15)

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
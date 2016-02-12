
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//
// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: DEFAULTS ---------------------------------
// --------------------------------------------------------------------------------


/mob/living/simple_animal/hostile/poison/giant_spider/terror/
	name = "terror spider"
	desc = "The generic parent of all other terror spider types. If you see this in-game, it is a bug."
	icon_state = "terror_red"
	icon_living = "terror_red"
	icon_dead = "terror_red_dead"
	maxHealth = 300
	health = 300
	melee_damage_lower = 30
	melee_damage_upper = 40
	move_to_delay = 5
	speak_chance = 0 // silent but deadly.
	poison_type = ""
	var/atom/cocoon_target // for queen and nurse

	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent // nearby vent they are going to try to get to, and enter
	var/obj/machinery/atmospherics/unary/vent_pump/exit_vent // remote vent they intend to come out of
	var/obj/machinery/atmospherics/unary/vent_pump/nest_vent // home vent, usually used by queens
	ventcrawler = 1
	var/travelling_in_vent = 0

	var/regen_chance = 10 // by default, they regen slowly
	var/dna_damaged = 0 // if 0, they regen, if 1, they degen... set by biological demolecularizer shots

	var/aggressionlevel = 0 // 0 = don't attack anyone, 1 = only attack enemies, 2 = attack everyone
	var/list/enemies = list()

// AI / control settings, modified during play
	var/idle_ventcrawl_chance = 3 // by default, they wander.
	var/ai_type = 0
		// 0 = default, aggressive
		// 1 = self-defense, only target enemies
		// 2 = passive, never attack anyone
	var/ai_playercontrol_allowingeneral = 1
	var/ai_playercontrol_allowtype = 1
	var/ai_playercontrol_allowthis = 1
		// 1 = ghosts can click on the spider to posess its body
		// 0 = ghosts cannot
		// allowingeneral var is set by queen on ALL spiders... queen-controllable.
		// allowtype var is set by code to 0 on specific spider types that players should never be able to control.
		// Reasons:
		// - queens can enable/disable player control of most terror spiders depending on whether they want more player spiders or not
		// - some spider types, however, can never be player-controlled as they are not adequately tested and/or would be OP in player hands

	var/ai_breaks_lights = 1
	var/ai_breaks_cameras = 0


	// Terror spiders ignore atmos. Aside from being SPACE SPIDERS, they're also weaponized.
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

	nightvision = 1
	vision_type = new /datum/vision_override/nightvision/thermals/ling_augmented_eyesight
	see_invisible = 5


/mob/living/simple_animal/hostile/poison/giant_spider/terror/AttackingTarget()
	if (istype(target,/mob/living/simple_animal/hostile/poison/giant_spider/terror/))
		if (istype(src,/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen))
			// a queen attacking a non-queen after a warning destroys them... never displease your queen!
			if (istype(target,/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen))
				visible_message("<span class='notice'> \icon[src] regards [target] from a distance. </span>")
				// queens cannot discipline each other.
			else
				// queens can discipline their brood freely
				target.attack_animal(src)
				visible_message("<span class='danger'> \icon[src] [src] bites [target]! </span>")
		else if (istype(target,/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen))
			// one non-queen attacking a queen produces a respectful bow
			visible_message("<span class='notice'> \icon[src] bows in respect for the terrifying presence of [target] </span>")
		else
			// one non-queen attacking another non-queen produces a harmless nuzzle
			visible_message("<span class='notice'> \icon[src] harmlessly nuzzles [target]. </span>")
	else
		// for most targets, we simply attack
		target.attack_animal(src)
		visible_message("<span class='danger'> \icon[src] [src] bites [target]! </span>")

/mob/living/simple_animal/hostile/poison/giant_spider/terror/harvest()
	//new /obj/item/weapon/reagent_containers/food/snacks/spiderleg(get_turf(src))
	//new /obj/item/weapon/reagent_containers/food/snacks/spiderleg(get_turf(src))
	//new /obj/item/weapon/reagent_containers/food/snacks/spiderleg(get_turf(src))

	new /obj/item/weapon/terrorspider_fang(get_turf(src))

	var/obj/item/stack/cable_coil/CC = new /obj/item/stack/cable_coil(get_turf(src))
	CC.name = "Conductive Spider Silk"
	CC.color = COLOR_YELLOW

	gib()
	return

/mob/living/simple_animal/hostile/poison/giant_spider/terror/bullet_act(var/obj/item/projectile/Proj)
	if (!target)
		visible_message("<span class='danger'> \icon[src] [src] looks around, enraged! </span>")
	aggressionlevel += 1
	for(var/mob/living/H in view(src, 10))
		if(!istype(H,/mob/living/simple_animal/hostile/poison/giant_spider/))
			if (!(H in enemies))
				enemies |= H
	if (istype(Proj, /obj/item/projectile/energy/declone))
		if (!dna_damaged)
			dna_damaged = 1
			visible_message("<span class='danger'> \icon[src] [src] looks staggered by the bioweapon! </span>")
			Stun(3)
	..()


/mob/living/simple_animal/hostile/poison/giant_spider/terror/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	..()
	if(!istype(user,/mob/living/simple_animal/hostile/poison/giant_spider/))
		if (!(user in enemies))
			enemies |= user
			//	if (istype(src,/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen))
			//		for (var/mob/living/simple_animal/hostile/poison/giant_spider/terror/T in world)
			//			if (!(user in T.enemies))
			//				T.enemies |= user
		if (!target)
			target = user


/mob/living/simple_animal/hostile/poison/giant_spider/terror/ListTargets()
	var/list/targets1 = list()
	var/list/targets2 = list()
	var/list/targets3 = list()
	if (ai_type == 0)
		// default, BE AGGRESSIVE
		var/list/Mobs = hearers(vision_range, src) - src // this is how ListTargets for /mob/living/simple_animal/hostile/ does it, and I'm trying not to snowflake.
		//for(var/mob/living/H in view(src, 10))
		for(var/mob/H in Mobs)
			if(istype(H,/mob/living/simple_animal/hostile/poison/giant_spider/))
				// fellow spiders are never valid targets unless they deliberately attack us, even then, low priority
				if (H in enemies)
					targets3 += H
			else if(H.reagents)
				if (H.reagents.has_reagent("wdtoxin"))
					if (H in enemies)
						targets3 += H // target them only if they attack us
				else
					if (H.reagents.has_reagent("bwtoxin") && poison_type == "bwtoxin")
						if (get_dist(src,H) <= 2)
							// if they come to us...
							targets2 += H
						else if (aggressionlevel && !H.reagents.has_reagent("bwtoxin",31))
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
			//else if(istype(H,/mob/living/simple_animal/hostile/poison/giant_spider/))
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
		if (targets1.len)
			return targets1
		else if (targets2.len)
			return targets2
		else
			return targets3
	else if (ai_type == 1)
		// DEFEND SELF ONLY
		var/list/Mobs = hearers(vision_range, src) - src
		//for(var/mob/living/H in view(src, 10))
		for(var/mob/H in Mobs)
			if (H in enemies)
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


/mob/living/simple_animal/hostile/poison/giant_spider/terror/Life()
	..()
	if (stat)
		if(target && target in ListTargets())
			// if we're in combat, don't mess it up by trying to do something else.
		else if (health == maxHealth)
			if (aggressionlevel && prob(10))
				aggressionlevel = 0
				visible_message("<span class='notice'> \icon[src] [src] looks to have calmed down. </span>")
			else
				if (stat != DEAD && prob(10) && (ai_breaks_lights || ai_breaks_cameras))
					if (ai_breaks_lights)
						for(var/obj/machinery/light/L in range(2,src))
							if (!L.status) // This assumes status == 0 means light is OK, which it does, but ideally we'd use lights' own constants.
								step_to(src,L)
								L.on = 1
								L.broken()
								visible_message("<span class='danger'>\the [src] smashes the [L.name].</span>")
					if (ai_breaks_cameras)
						for(var/obj/machinery/camera/C in range(2,src))
							step_to(src,C)
							visible_message("<span class='danger'>\the [src] smashes the [C.name].</span>")
							//qdel(C) // lets not... lets do what xenos do
							C.status = 0
							C.icon_state = "[initial(icon_state)]1"
							C.deactivate(src,0)
				if (prob(idle_ventcrawl_chance))
					for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
						if(!v.welded)
							entry_vent = v
							break
					if(entry_vent)
						TSVentCrawlRandom(entry_vent)
		else
			if (dna_damaged)
				adjustBruteLoss(1)
				adjustToxLoss(1)
				//2 DPS, 60/minute forever if they have dna damage - this WILL kill them eventually
			else if (prob(regen_chance))
				adjustBruteLoss(-5)
				adjustFireLoss(-5)

/mob/living/simple_animal/hostile/poison/giant_spider/terror/proc/FleeToVent(entry_vent)
	for(var/i=0, i<15, i++)
		step_to(src, entry_vent)
		var/turf/T = get_step(src, get_dir(src, entry_vent))
		for(var/atom/A in T)
			if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack))
				sleep(10) // *** FIX THIS - need to not be a sleep()
				A.attack_animal(src)
		if (get_dist(src, entry_vent) <= 1)
			break
		sleep(10) // *** FIX THIS - need to not be a sleep()
	if(get_dist(src, entry_vent) <= 2)
		TSVentCrawlRandom(entry_vent)

/mob/living/simple_animal/hostile/poison/giant_spider/terror/proc/TSVentCrawlRandom(/var/entry_vent)
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
					sleep(travel_time) // *** is this safe?
					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return
					loc = exit_vent.loc
					entry_vent = null
					var/area/new_area = get_area(loc)
					if(new_area)
						new_area.Entered(src)

/mob/living/simple_animal/hostile/poison/giant_spider/terror/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			humanize_spider(ghost)

/mob/living/simple_animal/hostile/poison/giant_spider/terror/attack_ghost(mob/user)
	humanize_spider(user)

/mob/living/simple_animal/hostile/poison/giant_spider/terror/proc/humanize_spider(mob/user)
	if(key)//Someone is in it
		return
	if (!ai_playercontrol_allowingeneral)
		user << "Terror spiders cannot currently be player-controlled. A notice will be posted to ghost chat if this changes."
		return
	if (!ai_playercontrol_allowtype)
		user << "This type of terror spider is not player-controllable."
		return
	if (!ai_playercontrol_allowthis)
		user << "This spider is not player-controllable."
		return
	if (jobban_isbanned(user, "Syndicate") || jobban_isbanned(user, "alien"))
		user << "You are jobbanned from role of syndicate and/or alien lifeform."
		return
	var/spider_ask = alert("Become a spider?", "Are you australian?", "Yes", "No")
	if(spider_ask == "No" || !src || qdeleted(src))
		return
	if(key)
		user << "<span class='notice'>Someone else already took this spider.</span>"
		return
	key = user.key
	// T1
	if (istype(src,/mob/living/simple_animal/hostile/poison/giant_spider/terror/red))
		src << "You are the red terror spider."
		src << "A straightforward fighter, you have high health, and high melee damage, but are slow-moving."
	else if (istype(src,/mob/living/simple_animal/hostile/poison/giant_spider/terror/gray))
		src << "You are the gray terror spider."
		src << "You are an ambusher. Invisible near vents, you hunt unequipped and vulnerable humanoids."
	else if (istype(src,/mob/living/simple_animal/hostile/poison/giant_spider/terror/green))
		src << "You are the green terror spider."
		src << "You are a breeding spider. Only average in combat, you can (and should) Wrap, then Lay Eggs on, any humanoid you kill. These eggs will hatch into more spiders!"
	// T2
	else if (istype(src,/mob/living/simple_animal/hostile/poison/giant_spider/terror/black))
		src << "You are the black terror spider."
		src << "You are an assassin. Even 2-3 bites from you is fatal to organic humanoids - if you back off and let your poison work."
	else if (istype(src,/mob/living/simple_animal/hostile/poison/giant_spider/terror/purple))
		src << "You are the purple terror spider."
		src << "You guard the nest of the all important Terror Queen! You are very robust, but should not leave her side."
	else if (istype(src,/mob/living/simple_animal/hostile/poison/giant_spider/terror/white))
		src << "You are the white terror spider."
		src << "Amongst the most feared of all terror spiders, your multi-stage bite attack injects tiny spider eggs into a host, which will make spiders grow out of their skin in time."
		src << "You should advance quickly, attack three times, then retreat, letting your venom of tiny eggs do its work."
	// T3
	else if (istype(src,/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen))
		src << "You are the terror queen spider!"
		src << "Your goal is to build a nest, lay many eggs to make more spiders, and ultimately exterminate all non-spider life on the station."
		src << "You can use Web to make sticky webs, Lay Eggs to create new spiders (your main ability!) and Phermones to issue general orders to your spiders (both AI and other players!)"
		src << "The success or failure of the entire hive depends on you, so whatever you do, do not die!"
	if (istype(src,/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen))
		src << "<span class='notice'> Remember, you are in command of ALL other terror spiders. They must obey you. If they don't, attack them to enforce discipline.</span>"
	else
		if (ai_type == 0)
			//
			src << "Prior to your control, this spider had orders to <span class='danger'> kill all humanoids on sight </span>"
		else if (ai_type == 1)
			//
			src << "Prior to your control, this spider had orders to <span class='notice'> defend itself without being aggressive </span> "
		else if (ai_type == 2)
			//
			src << "Prior to your control, this spider had orders to <span class='danger'> remain completely passive </span> "
		src << "A Terror Queen, if one is present, can change your orders. You MUST follow any orders given by a queen - failure to do so is punishable by death."

// --------------------------------------------------------------------------------
// --------------------- NEW SPIDERS: GUARD CLASS, TIER 1, RED TERROR -------------
// --------------------------------------------------------------------------------
// -- RED TERROR: as guard spider, but 1.5x health, 2x brute damage, hugely reduced speed ---
// -------------: Suggested strategy: kill it from range - it will never catch you because it is so slow, you can kite it forever! ---

/mob/living/simple_animal/hostile/poison/giant_spider/terror/red
	name = "red terror spider"
	desc = "Furry and red, it looks like certain trouble. It has eight beady red eyes, and nasty, big, pointy fangs!"
	icon_state = "terror_red"
	icon_living = "terror_red"
	icon_dead = "terror_red_dead"
	maxHealth = 200
	health = 200
	melee_damage_lower = 30
	melee_damage_upper = 40
	move_to_delay = 20
	poison_per_bite = 0

/mob/living/simple_animal/hostile/poison/giant_spider/terror/red/New()
	..()
	name = pick("Red Terror spider","Crimson Terror spider","Bloody Butcher spider")


// --------------------------------------------------------------------------------
// --------------------- NEW SPIDERS: GUARD CLASS, TIER 2, PRAETORIAN -------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/giant_spider/terror/purple
	name = "praetorian spider"
	desc = "It looks like a Red Terror, but royal purple in color."
	icon_state = "terror_purple"
	icon_living = "terror_purple"
	icon_dead = "terror_purple_dead"
	maxHealth = 300
	health = 300
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_to_delay = 10
	poison_per_bite = 0
	idle_ventcrawl_chance = 0 // exactly like the red terrors - but they don't move.
	regen_chance = 10 // oh and they regen fast
	//environment_smash = 2 // they will smash down steel walls, but not rwalls

	ai_playercontrol_allowtype = 0

/mob/living/simple_animal/hostile/poison/giant_spider/terror/purple/Life()
	if (!target)
		if (prob(50))
			var/foundqueen = 0
			for(var/mob/living/H in view(src, 6))
				if (istype(H,/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen))
					foundqueen = 1
					break
			if (!foundqueen)
				for(var/mob/living/H in range(src, 25))
					if (istype(H,/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen))
						step_to(src,H,20)
						break
	..()

/mob/living/simple_animal/hostile/poison/giant_spider/terror/purple/AttackingTarget()
	if(isliving(target) && prob(20))
		var/mob/living/L = target
		visible_message("<span class='danger'> \icon[src] [src] rams into [L] knocking them to the floor and stunning them! </span>")
		L.Stun(10)
	else
		..()
		// just do normal attack

// --------------------------------------------------------------------------------
// --------------------- NEW SPIDERS: STRIKE CLASS, TIER 1, BLACK WIDOW -----------
// --------------------------------------------------------------------------------
// -- BLACK WIDOW: base stats: hunter spider
// --------------: change: vastly more deadly venom, modeled after tabun
// --------------: change: ai which makes it bite then flee if possible - will never bite White Death spider victims, and prefers biting new victims to finishing old ones
// --------------: Suggested strategy: kill it however you like - but run to medbay afterwards! Its venom is lethal very quickly...

/mob/living/simple_animal/hostile/poison/giant_spider/terror/black
	name = "black widow spider"
	desc = "Furry and black as the darkest night, with merciless yellow eyes, it has an ominously troubling look about it."
	icon_state = "terror_black"
	icon_living = "terror_black"
	icon_dead = "terror_black_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its bite will kill you!
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 0 // this is handled in AttackingTarget()
	move_to_delay = 5
	stat_attack = 1 // ensures they will target people in crit, too!
	poison_type = "bwtoxin"

/mob/living/simple_animal/hostile/poison/giant_spider/terror/black/New()
	..()
	name = pick("Black Devil spider","Giant Black Widow spider","Shadow Terror spider")

/mob/living/simple_animal/hostile/poison/giant_spider/terror/black/AttackingTarget()
	//..()
	// skip all parent attack procs.
	// parent procs produce undesirable effects, like applying spidertoxin, damage, etc. We usually don't want any of those things to happen.
	if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			if (L.reagents.has_reagent("bwtoxin",15))
				L.attack_animal(src)
			else
				melee_damage_lower = 1
				melee_damage_upper = 5
				visible_message("<span class='danger'> \icon[src] [src] buries its long fangs deep into [target]! </span>")
				L.attack_animal(src)
				//L.Weaken(5)
				melee_damage_lower = 10 // this is only good for the first attack, though....afterwards they get full force.
				melee_damage_upper = 20
			L.reagents.add_reagent("bwtoxin", 15) // inject our special poison
			if (aggressionlevel == 0 || L.reagents.has_reagent("bwtoxin",50))
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
// --------------------- NEW SPIDERS: STRIKE CLASS, TIER 2, GRAY GHOST ------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/giant_spider/terror/gray
	name = "gray terror spider"
	desc = "Furry and gray, this small spider is adept at hiding in vents."
	icon_state = "terror_gray"
	icon_living = "terror_gray"
	icon_dead = "terror_gray_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its almost invisible.
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	ventcrawler = 1
	move_to_delay = 15 // slow.
	stat_attack = 1 // ensures they will target people in crit, too!
	environment_smash = 0 // this monster is stealthy, it does not smash stuff -- actually yeah it does when going back to a vent. Otherwise it can get stuck behind doors/walls
	stop_automated_movement = 1 // wandering defeats the purpose of stealth

	ai_playercontrol_allowtype = 0

/mob/living/simple_animal/hostile/poison/giant_spider/terror/gray/New()
	..()
	name = pick("Gray Trap spider","Gray Stalker spider","Ghostly Ambushing spider")

/mob/living/simple_animal/hostile/poison/giant_spider/terror/gray/Life()
	..()
	if (target && invisibility > 0)
		if (get_dist(src,target) < 3)
			invisibility = 0
			environment_smash = 1
			visible_message("<span class='danger'>\the [src] ambushes [target] from the vent!</span>")
	else if (target && invisibility < 1)
		// cool.
	else if (!target && invisibility < 1)
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
			if(!v.welded)
				entry_vent = v
				break
		if (entry_vent)
			if (get_dist(src,entry_vent) < 2)
				invisibility = INVISIBILITY_LEVEL_ONE
				environment_smash = 0
				visible_message("<span class='notice'>\the [src] hides in the vent, awaiting prey.</span>")
			else
				step_to(src,entry_vent)
	//else if (!target && invisibility > 0)
	//	// do nothing. its cool.

// aggro range 3.
// always stay on vent
// invisible unless has target?

// --------------------------------------------------------------------------------
// --------------------- NEW SPIDERS: SWARM CLASS, TIER 1, GREEN NURSE -------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/giant_spider/terror/green
	name = "green terror spider"
	desc = "Green and brown, it looks like definite trouble."
	icon_state = "terror_green"
	icon_living = "terror_green"
	icon_dead = "terror_green_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	ventcrawler = 1
	var/fed = 0


/mob/living/simple_animal/hostile/poison/giant_spider/terror/green/handle_automated_action()
	if(!stat && !ckey)
		if(stance == HOSTILE_STANCE_IDLE)
			var/list/can_see = view(src, 10)
			//30% chance to stop wandering and do something
			if(!busy && prob(30))
				//first, check for potential food nearby to cocoon
				for(var/mob/living/C in can_see)
					if(C.stat && !istype(C,/mob/living/simple_animal/hostile/poison/giant_spider))
						cocoon_target = C
						busy = MOVING_TO_TARGET
						Goto(C, move_to_delay)
						//give up if we can't reach them after 10 seconds
						GiveUp(C)
						return
				//second, spin a sticky spiderweb on this tile
				var/obj/effect/spider/stickyweb/W = locate() in get_turf(src)
				if(!W)
					Web()
				else
					//third, lay an egg cluster there
					if(fed)
						LayEggs()
					else
						//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
						for(var/obj/O in can_see)
							if(O.anchored)
								continue
							if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery))
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

// we inherit Web() from class giant_spider/

/mob/living/simple_animal/hostile/poison/giant_spider/terror/green/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey eat (allowing you to lay eggs) and objects (making them inaccessible to humans)."
	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1,src))
			if(L == src)
				continue
			if(Adjacent(L))
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
						if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
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

/mob/living/simple_animal/hostile/poison/giant_spider/terror/green/verb/LayEggs()
	set name = "Lay Terror Eggs"
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
						DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/red, 2, 1)
					else if (prob(50))
						DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/black, 2, 1)
					else
						DoLayTerrorEggs("green spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/green, 2, 1)
					//var/obj/effect/spider/eggcluster/C = new /obj/effect/spider/eggcluster(get_turf(src))
					//C.faction = faction
					//C.master_commander = master_commander
					//if(ckey)
					//	C.player_spiders = 1
					fed--
			busy = 0
			stop_automated_movement = 0

// --------------------------------------------------------------------------------
// --------------------- NEW SPIDERS: SWARM CLASS, TIER 2, WHITE DEATH --------
// --------------------------------------------------------------------------------
// -- WHITE DEATH: hunter spider, but faster, and its venom spawns spiderlings ---
// -- Suggested strategy: shoot it from range, or have charcoal in your bloodstream when you engage it. Do not let it bite you! ---

/mob/living/simple_animal/hostile/poison/giant_spider/terror/white
	name = "white death spider"
	desc = "Fluffy, and with ghostly eyes, it looks like definite trouble."
	icon_state = "terror_white"
	icon_living = "terror_white"
	icon_dead = "terror_white_dead"
	maxHealth = 100
	health = 100
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_to_delay = 5
	ventcrawler = 1
	var/attackstep = 0
	poison_type = "wdtoxin"


/mob/living/simple_animal/hostile/poison/giant_spider/terror/white/LoseTarget()
	stop_automated_movement = 0
	attackstep = 0
	..()

/mob/living/simple_animal/hostile/poison/giant_spider/terror/white/New()
	..()
	name = pick("White Terror spider","White Death spider","Ghostly Nightmare spider")

/mob/living/simple_animal/hostile/poison/giant_spider/terror/white/AttackingTarget()
	//..()
	// skip all parent attack procs.
	// parent procs produce undesirable effects, like applying spidertoxin, damage, etc. We usually don't want any of those things to happen.
	stop_automated_movement = 1
	if(isliving(target))
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
				if (L.reagents.has_reagent("wdantitoxin"))
					visible_message("<span class='danger'> \icon[src] [src] sinks its fangs deep into [target] - and recoils in horror as its fangs burn!</span>")
					//dna_damaged = 1
					//health = min(health,maxHealth/4)
					spawn(50)
						visible_message("<span class='danger'> \icon[src] [src] is torn apart by a violent chemical reaction inside its body!</span>")
						gib()
					// this spider is neutralized - it can no longer inject poison, and it will die shortly
				else if (!L.reagents.has_reagent("wdtoxin",5) && !dna_damaged)
					L.reagents.add_reagent("wdtoxin", 10)
					visible_message("<span class='danger'> \icon[src] [src] sinks its fangs deep into [target] - a green froth dribbling from its fangs.</span>")
				else if (L in enemies)
					L.reagents.add_reagent("wdsedative", 10)
					enemies -= L
					visible_message("<span class='danger'> \icon[src] [src] sinks its fangs deep into [target] - a blue froth dribbling from its fangs.</span>")
				else
					visible_message("<span class='danger'> \icon[src] [src] sinks its fangs deep into [target] </span>")

			//	attackstep = 3
			//else if (attackstep == 3)
				attackstep = 0
				//if (health == maxHealth)
				//	LoseTarget()
				//	// if we took no damage, stick around, otherwise flee.
				//	return
				spawn(20)
					visible_message("<span class='notice'> \icon[src] [src] lets go of [target], and tries to flee! </span>")
					LoseTarget()
					walk_away(src,L,2,1)
					spawn(200)
						stop_automated_movement = 0
					for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
						if(!v.welded)
							//path = get_path_to(loc, v.loc, src, /turf/prof/Distance_cardinal, 0, 200)
							//if (path && path.len)
							entry_vent = v
							break
					if(entry_vent)
						TSVentCrawlRandom(entry_vent)
					else
						// Can't escape via vent. Include sedative in our bite, and try to put some distance between us and them. Hopefully, this is enough.
						L.reagents.add_reagent("wdsedative", 10)
						for(var/i=0, i<6, i++)
							step_away(src, L)
							//sleep(10) // *** FIX THIS - need to not be a sleep()
			else
				attackstep = 0
			//L.reagents.remove_reagent("spidertoxin", 15)
		else
			// code for handling mobs that don't process reagents. Possibly dead bodies? Or simple mobs that have no reagent container?
			target.attack_animal(src)
			visible_message("<span class='danger'> \icon[src] [src] bites [target]! </span>")
	else
		// code for handling non-living targets we're attacking. What would even be in this category? Mechs, maybe?
		target.attack_animal(src)
		visible_message("<span class='danger'> \icon[src] [src] bites [target]! </span>")

// --------------------------------------------------------------------------------
// --------------------- NEW SPIDERS: NIGHTMARE CLASS, QUEEN SPIDER ---------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen
	name = "queen spider"
	desc = "It looks like a Red Terror, but bigger, meaner, and green. It has a large egg sac attached to it."
	icon_state = "terror_queen"
	icon_living = "terror_queen"
	icon_dead = "terror_queen_dead"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_to_delay = 15 // yeah, this is very slow, but
	ventcrawler = 1
	var/attackstep = 0
	var/fed = 0
	var/spawnfrequency = 120
	var/lastspawn = 0
	var/nestfrequency = 15
	var/lastnestsetup = 0
	var/neststep = 0
	idle_ventcrawl_chance = 0
	force_threshold = 18 // outright immune to anything of force under 18, this means welders can't hurt it, only guns can

	ai_playercontrol_allowtype = 0
	ai_breaks_lights = 1
	ai_breaks_cameras = 1

/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen/Life()
	..()
	if (target)
		// do nothing.
	else if (prob(10))
		var/obj/effect/spider/stickyweb/T = locate() in get_turf(src)
		if (T)
		else
			//var/obj/effect/spider/stickyweb/S2 =
			new /obj/effect/spider/stickyweb(get_turf(src))
			visible_message("<span class='notice'>\the [src] puts up some spider webs.</span>")
	else if (neststep >= 1 && prob(33))
		if (get_dist(src,nest_vent) > 6)
			step_to(src,nest_vent)
			visible_message("<span class='notice'>\the [src] retreats towards her nest.</span>")
	else if (neststep == 0)
		// we have no nest :(
		if (prob(10))
			// maybe we want to nest here?
			var/numhostiles = 0
			for (var/mob/living/H in oview(10,src))
				if (!istype(T, /mob/living/simple_animal/hostile/poison/giant_spider))
					numhostiles += 1
				//var/theannoyance = H
			for (var/obj/machinery/atmospherics/unary/vent_pump/v in view(10,src))
				if(!v.welded)
					entry_vent = v
					break
			if (entry_vent)
				if (numhostiles > 0)
					visible_message("<span class='danger'>\the [src] looks around warily - then retreats.</span>")
					TSVentCrawlRandom(entry_vent)
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
			// TODO:
			// 1) destroy lights (otherwise we're super-visible)
			// 2) destroy cameras (otherwise AI will locate us in seconds)
			// 3) destroy nearby windows -- ACTUALLY DON'T... loud, very visible, draws attention & atmos alerts... plus spiders hack through them fast anyway if needed
			// 4) secure doors -- is it OP to emp the doors? unsure.
			//
			//prison_break (area proc) is a valid choice: https://github.com/ParadiseSS13/Paradise/blob/c7ae1fef0db8acfe4111036d5ff337507b2538ab/code/game/area/areas.dm
			visible_message("<span class='danger'>\the [src] emits a bone-chilling shriek that shatters nearby glass!</span>")
			for(var/obj/machinery/light/L in range(10,src))
				L.on = 1
				L.broken()
				//if (L.on)
				//	islit = 0
			for(var/obj/machinery/camera/C in range(10,src))
				C.status = 0
				C.icon_state = "[initial(icon_state)]1"
				C.deactivate(src,0)
			neststep = 2
	else if (neststep == 2)
		if (world.time > (lastnestsetup + nestfrequency))
			lastnestsetup = world.time
			if (world.time > (lastspawn + spawnfrequency))
				if (prob(10))
					var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
					if(N)
						// already have one
					else
						lastspawn = world.time
						DoLayTerrorEggs("praetorian spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/purple,2,0)
						neststep = 3
	else if (neststep == 3)
		if (world.time > (lastspawn + spawnfrequency))
			if (prob(10))
				var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
				if(N)
					// already have one
				else
					lastspawn = world.time
					DoLayTerrorEggs("nurse spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/green,2,0)
					neststep = 4
	else if (neststep == 3)
		if (world.time > (lastspawn + spawnfrequency))
			if (prob(10))
				var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
				if(N)
					// already have one
				else
					lastspawn = world.time
					DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/black,2,1)
					neststep = 4
	else if (neststep == 4)
		if (world.time > (lastspawn + spawnfrequency))
			if (prob(10))
				var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
				if(N)
					// already have one
				else
					lastspawn = world.time
					DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/red,2,1)
					neststep = 5
	else if (neststep == 5)
		if (world.time > (lastspawn + spawnfrequency))
			if (prob(10))
				var/obj/effect/spider/terror_eggcluster/N = locate() in get_turf(src)
				if(N)
					// already have one
				else
					lastspawn = world.time
					if (prob(33))
						DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/black,2,1)
					else if (prob(50))
						DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/red,2,1)
					else
						DoLayTerrorEggs("nurse spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/green,2,0)
			var/numspiders = 0
			for(var/mob/living/simple_animal/hostile/poison/giant_spider/terror/T in world)
				if (T.z in config.station_levels)
					if (!istype(T, (/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen)))
						numspiders += 1
			if (numspiders >= 15) // station overwhelmed!
				neststep = 6
				command_announcement.Announce("Anomalous biohazards detected moving throughout station.", "Station Overrun")
	else if (neststep == 6)
		if (world.time > (lastspawn + spawnfrequency))
			lastspawn = world.time
			// go hostile, EXTERMINATE MODE.
			var/numspiders = 0
			for(var/mob/living/simple_animal/hostile/poison/giant_spider/terror/T in world)
				if (T.z in config.station_levels && T.health > 0)
					numspiders += 1
					if (istype(T, /mob/living/simple_animal/hostile/poison/giant_spider/terror/queen))
					else if (istype(T, /mob/living/simple_animal/hostile/poison/giant_spider/terror/purple))
					else if (T.idle_ventcrawl_chance != 15)
						T.idle_ventcrawl_chance = 15
						T.visible_message("<span class='danger'>\the [src] rises up in fury!</span>")
			if (numspiders < 15)
				if (prob(50))
					DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/black,2,1)
				else
					DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/red,2,1)

			//neststep = 7
			// now, they will roam like mad, killing everything they see.


/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen/ListTargets()
	if (neststep < 1 && enemies.len == 0)
		return ()
	else
		..()


/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen/Web()
	set name = "Lay Web"
	set category = "Spider"
	set desc = "Spread a sticky web to slow down prey."
	var/T = loc
	if(busy != SPINNING_WEB)
		busy = SPINNING_WEB
		visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
		stop_automated_movement = 1
		spawn(40)
			if(busy == SPINNING_WEB && loc == T)
				new /obj/effect/spider/stickyweb(T)
			busy = 0
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen/verb/Phermones()
	set name = "Phermones"
	set category = "Spider"
	set desc = "Instruct your brood on proper behavior."
	var/dstance = input("How aggressive should your brood be?") as null|anything in list("Attack Everyone","Defend Themselves","Completely Passive")
	var/dai = input("How often should they use vents?") as null|anything in list("Constantly","Sometimes","Rarely", "Never")
	var/dpc = input("Allow ghosts to inhabit spider bodies?") as null|anything in list("Yes","No")
	var/numspiders = 0
	if (dstance != null && dai != null && dpc != null)
		for(var/mob/living/simple_animal/hostile/poison/giant_spider/terror/T in world)
			if (T.z in config.station_levels)
				numspiders += 1
				if (istype(T, /mob/living/simple_animal/hostile/poison/giant_spider/terror/queen))
				else
					if (dstance == "Attack Everyone")
						T.ai_type = 0
						T.visible_message("<span class='danger'>\the [src] looks around angrily.</span>")
					else if (dstance == "Defend Themselves")
						T.ai_type = 1
						T.visible_message("<span class='notice'>\the [src] takes a defensive stance.</span>")
					else if (dstance == "Completely Passive")
						T.ai_type = 2
						T.visible_message("<span class='notice'>\the [src] looks passive.</span>")
					if (dai == "Constantly")
						T.idle_ventcrawl_chance = 15
						T.visible_message("<span class='danger'>\the [src] seems to move very quickly for a moment.</span>")
					else if (dai == "Sometimes")
						T.idle_ventcrawl_chance = 5
						T.visible_message("<span class='notice'>\the [src] seems to move quickly for a moment.</span>")
					else if (dai == "Rarely")
						T.idle_ventcrawl_chance = 2
						T.visible_message("<span class='notice'>\the [src] seems slow for a moment.</span>")
					else if (dai == "Never")
						T.idle_ventcrawl_chance = 0
						T.visible_message("<span class='notice'>\the [src] seems still for a moment.</span>")
					if (dpc == "Yes")
						T.ai_playercontrol_allowingeneral = 1
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
	else
		src << "That choice was not recognized."
	src << " spiders obey your command."

/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen/verb/LayEggs()
	set name = "Lay Terror Eggs"
	set category = "Spider"
	set desc = "Grow your brood."
	var/eggtype = input("What kind of eggs?") as null|anything in list("red - assault","gray - ambush", "green - nurse", "black - poison","purple - guard")
	var/numlings = input("How many in the batch?") as null|anything in list(1,2,3,4,5)
	if (eggtype == null || numlings == null)
		src << "Cancelled."
		return
	else if (world.time > (lastspawn + spawnfrequency))
		lastspawn = world.time
	else
		src << "Too soon to attempt that again. Wait longer."
		return
	if (eggtype == "red - assault")
		DoLayTerrorEggs("red spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/red,numlings,1)
	else if (eggtype == "gray - ambush")
		DoLayTerrorEggs("gray spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/gray,numlings,1)
	else if (eggtype == "green - nurse")
		DoLayTerrorEggs("green spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/green,numlings,1)

	else if (eggtype == "black - poison")
		DoLayTerrorEggs("black spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/black,numlings,1)
	else if (eggtype == "purple - guard")
		DoLayTerrorEggs("green spider eggs", /mob/living/simple_animal/hostile/poison/giant_spider/terror/purple,numlings,0)
	else
		src << "Unrecognized egg type."



/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to feast upon and objects for safe keeping."
	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1,src))
			if(L == src)
				continue
			if(Adjacent(L))
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
						if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
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






// ------------------------------ Eggs ------------------

/mob/living/simple_animal/hostile/poison/giant_spider/terror/proc/DoLayTerrorEggs(var/lay_name, var/lay_type, var/lay_number, var/lay_crawl)
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
	if(ckey)
		C.player_spiders = 1
	spawn(10)
		stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/giant_spider/terror/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = 0
			stop_automated_movement = 0


/obj/effect/spider/terror_eggcluster
	name = "giant egg cluster"
	desc = "They pulse with a strong inner life"
	icon_state = "eggs"
	var/amount_grown = 0
	var/player_spiders = 0
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
		//rand(3,12) // ONLY ONE SPIDERLING PER SPIDER EGG CLUSER
		for(var/i=0, i<num, i++)
			var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
			if (spiderling_type)
				S.grow_as = spiderling_type
			if (spiderling_ventcrawl)
				S.use_vents = spiderling_ventcrawl
			if (S.grow_as == "/mob/living/simple_animal/hostile/poison/giant_spider/terror/queen")
				S.name = "queen spiderling"
			else if (S.grow_as == "/mob/living/simple_animal/hostile/poison/giant_spider/terror/red")
				S.name = "red spiderling"
			else if (S.grow_as == "/mob/living/simple_animal/hostile/poison/giant_spider/terror/black")
				S.name = "black spiderling"
			else if (S.grow_as == "/mob/living/simple_animal/hostile/poison/giant_spider/terror/green")
				S.name = "green spiderling"
			else if (S.grow_as == "/mob/living/simple_animal/hostile/poison/giant_spider/terror/purple")
				S.name = "purple spiderling"
			else if (S.grow_as == "/mob/living/simple_animal/hostile/poison/giant_spider/terror/white")
				S.name = "white spiderling"
			S.faction = faction
			S.master_commander = master_commander
			S.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
			S.enemies = enemies
			if(player_spiders)
				S.player_spiders = 1
		qdel(src)

/obj/effect/spider/terror_spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	anchored = 0
	layer = 2.75
	health = 3
	var/amount_grown = 0
	var/grow_as = null
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/player_spiders = 0
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
					sleep(travel_time) // *** is this safe?

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
			if(!grow_as)
				grow_as = pick("/mob/living/simple_animal/hostile/poison/giant_spider/terror/red","/mob/living/simple_animal/hostile/poison/giant_spider/terror/gray","/mob/living/simple_animal/hostile/poison/giant_spider/terror/green")
			var/mob/living/simple_animal/hostile/poison/giant_spider/terror/S = new grow_as(loc)
			S.faction = faction
			S.master_commander = master_commander
			S.ai_playercontrol_allowingeneral = ai_playercontrol_allowingeneral
			S.enemies = enemies
			if(player_spiders)
				notify_ghosts("Spider [S.name] can be controlled", null, enter_link="<a href=?src=\ref[S];activate=1>(Click to play)</a>", source=S, attack_not_jump = 1)
				// pulling ghosts without asking is dumb. You get a lot of AFKers. This method ensures only people who actively choose to become spiders.
			qdel(src)


// https://en.wikipedia.org/wiki/Chelicerae
/obj/item/weapon/terrorspider_fang
	name = "terror spider fang"
	icon = 'icons/mob/animal.dmi'
	icon_state = "terror_fang"
	sharp = 1
	edge = 1
	desc = "An enormous fang. Creepy."
	w_class = 1.0
	force = 15.0 // quite robust
	throwforce = 30.0 // extremely nasty, worse than a spear
	throw_speed = 3
	throw_range = 5
	item_state = "shard-glass"
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
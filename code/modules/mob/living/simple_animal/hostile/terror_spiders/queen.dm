
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

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



#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
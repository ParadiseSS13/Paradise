#define DS_BOSS_STORAGE "DS_BossStorage"
#define DS_ENGINEERING "DS_Engineering"
/mob/living/simple_animal/hostile/megafauna/fleshling
	name = "Fleshling"
	desc = "A sinister mass of flesh molded into a grotesque shape. Nothing about it looks like the result of natural evolution. It looks agitated and clearly doesn't want you to leave here alive."
	icon = 'icons/mob/fleshling.dmi'
	icon_state = "fleshling"
	icon_living = "fleshling"
	attack_sound = 'sound/misc/demon_attack1.ogg'
	death_sound = 'sound/misc/demon_dies.ogg'
	icon_dead = "fleshling_dead"
	speed = 5
	move_to_delay = 4
	ranged = TRUE
	pixel_x = -16
	melee_damage_lower = 20
	melee_damage_upper = 20
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	deathmessage = "collapses into a pile of gibs. From the looks of it this is the deadest it can get... "
	butcher_results = list(/obj/item/regen_mesh = 1)
	/// Is the boss charging right now?
	var/charging = FALSE
	/// Did our boss die?
	var/boss_killed = FALSE

// Below here is copy-pasted from /asteroid/big_legion

/mob/living/simple_animal/hostile/megafauna/fleshling/AttackingTarget()
	if(!isliving(target))
		return ..()
	var/mob/living/L = target
	var/datum/status_effect/stacking/ground_pound/G = L.has_status_effect(STATUS_EFFECT_GROUNDPOUND)
	if(!G)
		L.apply_status_effect(STATUS_EFFECT_GROUNDPOUND, 1, src)
		return ..()
	if(G.add_stacks(stacks_added = 1, attacker = src))
		return ..()

/mob/living/simple_animal/hostile/megafauna/fleshling/proc/throw_mobs()
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
	for(var/mob/living/L in range(3, src))
		if(faction_check(faction, L.faction, FALSE))
			continue

		L.visible_message("<span class='danger'>[L] was thrown by [src]!</span>",
			"<span class='userdanger'>You feel a strong force throwing you!</span>",
			"<span class='danger'>You hear a thud.</span>")
		var/atom/throw_target = get_edge_target_turf(L, get_dir(src, get_step_away(L, src)))
		L.throw_at(throw_target, 4, 4)
		var/limb_to_hit = L.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		var/armor = L.run_armor_check(def_zone = limb_to_hit, armor_type = MELEE, armor_penetration_percentage = 50)
		L.apply_damage(40, BRUTE, limb_to_hit, armor)

// Below here is edited from Bubblegum

/mob/living/simple_animal/hostile/megafauna/fleshling/proc/charge(atom/chargeat = target, delay = 5, chargepast = 2)
	if(!chargeat)
		return
	if(chargeat.z != z)
		return
	var/chargeturf = get_turf(chargeat)
	if(!chargeturf)
		return
	var/dir = get_dir(src, chargeturf)
	var/turf/T = get_ranged_target_turf(chargeturf, dir, chargepast)
	if(!T)
		return
	new /obj/effect/temp_visual/dragon_swoop/bubblegum(T)
	charging = TRUE
	walk(src, 0)
	setDir(dir)
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(loc,src)
	animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 3)
	SLEEP_CHECK_DEATH(delay)
	var/movespeed = 0.8
	walk_towards(src, T, movespeed)
	SLEEP_CHECK_DEATH(get_dist(src, T) * movespeed)
	walk(src, 0)
	charging = FALSE
	loot = list(/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)

/mob/living/simple_animal/hostile/megafauna/fleshling/ListTargetsLazy()
	return ListTargets()

/mob/living/simple_animal/hostile/megafauna/fleshling/Aggro()
	. = ..()
	if(target)
		playsound(loc, 'sound/voice/zombie_scream.ogg', 70, TRUE)

/mob/living/simple_animal/hostile/megafauna/fleshling/OpenFire()
	if(charging)
		return
	charge(delay = 3)
	SetRecoveryTime(15)

/mob/living/simple_animal/hostile/megafauna/fleshling/Moved(atom/OldLoc, Dir, Forced = FALSE)
	if(Dir)
		new /obj/effect/decal/cleanable/blood/bubblegum(loc)
	playsound(src, 'sound/effects/meteorimpact.ogg', 25, TRUE, 2, TRUE)
	return ..()

/mob/living/simple_animal/hostile/megafauna/fleshling/Bump(atom/A)
	if(charging)
		if(isliving(A))
			var/mob/living/L = A
			L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
			forceMove(get_turf(L))
			L.apply_damage(istype(src, /mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination) ? 15 : 30, BRUTE)
			playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, TRUE)
			shake_camera(L, 4, 3)
			shake_camera(src, 2, 3)
	..()

/mob/living/simple_animal/hostile/megafauna/fleshling/Destroy()
	handle_dying()
	return ..()

/mob/living/simple_animal/hostile/megafauna/fleshling/proc/handle_dying()
	if(!boss_killed)
		boss_killed = TRUE

/mob/living/simple_animal/hostile/megafauna/fleshling/death(gibbed)
	if(can_die() && !boss_killed)
		unlock_blast_doors(DS_BOSS_STORAGE)
		src.visible_message("<span class='notice'>Somewhere, a heavy door has opened.</span>")
	return ..(gibbed)

/mob/living/simple_animal/hostile/megafauna/fleshling/proc/unlock_blast_doors(target_id_tag)
	for(var/obj/machinery/door/poddoor/P in GLOB.airlocks)
		if(P.density && P.id_tag == target_id_tag && P.z == z && !P.operating)
			P.open()

/mob/living/simple_animal/hostile/spaceinfected
	name = "Infected"
	desc = "A reanimated corpse, wandering around aimlessly."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "spaceinfected"
	icon_living = "spaceinfected"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	speak_chance = 1
	turns_per_move = 3
	death_sound = 'sound/effects/bodyfall1.ogg'
	speed = 0
	maxHealth = 150
	health = 150
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "hits"
	attack_sound = 'sound/effects/blobattack.ogg'
	del_on_death = TRUE
	sentience_type = SENTIENCE_OTHER
	footstep_type = FOOTSTEP_MOB_SHOE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	loot = list(/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)

/mob/living/simple_animal/hostile/spaceinfected/ListTargetsLazy()
	return ListTargets()

/mob/living/simple_animal/hostile/spaceinfected/Aggro()
	. = ..()
	if(target)
		playsound(loc, 'sound/voice/zombie_scream.ogg', 70, TRUE)

/mob/living/simple_animal/hostile/spaceinfected/Move(atom/newloc, direct = 0, glide_size_override = 0, update_dir = TRUE)
	if(ischasm(newloc)) // as this place filled with chasms, they shouldn't randomly fall in while wandering around
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/spaceinfected/default

/mob/living/simple_animal/hostile/spaceinfected/default/Initialize(mapload)
	. = ..()
	var/loot_num = rand(1, 100)
	switch(loot_num)
		if(1 to 10)
			loot = list(/obj/item/salvage/ruin/nanotrasen,
				/obj/effect/decal/cleanable/blood/innards,
				/obj/effect/decal/cleanable/blood,
				/obj/effect/gibspawner/generic,
				/obj/effect/gibspawner/generic)

		if(11 to 30)
			loot = list(/obj/item/salvage/ruin/brick,
				/obj/effect/decal/cleanable/blood/innards,
				/obj/effect/decal/cleanable/blood,
				/obj/effect/gibspawner/generic,
				/obj/effect/gibspawner/generic)

/mob/living/simple_animal/hostile/spaceinfected/gateopener // When this mob dies it'll trigger a poddoor open
	/// Is our mob dead?
	var/has_died = FALSE
	loot = list(/obj/item/gun/energy/laser,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic) // First weapon this ruin provides

/mob/living/simple_animal/hostile/spaceinfected/gateopener/Destroy()
	handle_dying()
	return ..()

/mob/living/simple_animal/hostile/spaceinfected/gateopener/proc/handle_dying()
	if(!has_died)
		has_died = TRUE

/mob/living/simple_animal/hostile/spaceinfected/gateopener/death(gibbed)
	if(can_die() && !has_died)
		unlock_blast_doors(DS_ENGINEERING)
		src.visible_message("<span class='notice'>Somewhere, a heavy door has opened.</span>")
	return ..(gibbed)

/mob/living/simple_animal/hostile/spaceinfected/gateopener/proc/unlock_blast_doors(target_id_tag)
	for(var/obj/machinery/door/poddoor/P in GLOB.airlocks)
		if(P.density && P.id_tag == target_id_tag && P.z == z && !P.operating)
			P.open()

/mob/living/simple_animal/hostile/spaceinfected/default/ranged
	desc = "A reanimated corpse. This one is keeping its distance from you."
	icon_state = "spaceinfected_ranged"
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'

// Below here is ruin specific code

/obj/structure/blob/normal/deepstorage
	name = "flesh wall"
	desc = "What even..."
	color = rgb(80, 39, 39)

/obj/machinery/deepstorage_teleporter
	name = "package teleporter"
	desc = "It's tuned to maintain one-way teleportation."
	icon_state = "controller"
	density = TRUE
	anchored = TRUE

	/// How many portals are present right now?
	var/active_portals = 0
	/// Does user have the TGUI menu open right now?
	var/menu_open = FALSE

/obj/machinery/deepstorage_teleporter/attack_hand(mob/user)
	if(active_portals != 0 || menu_open)
		return
	menu_open = TRUE
	var/list/boss_warning = list("Proceed" = TRUE)
	var/final_decision = tgui_input_list(user, "Just a hunch but wherever this machine may lead, it won't be somewhere pleasant. Are you sure about this?", "Make your decision", boss_warning)
	if(!final_decision)
		to_chat(user, "<span class='notice'>The teleporter machine remains untouched.</span>")
		menu_open = FALSE
		return

	new /obj/effect/portal/advanced/deepstorage(locate(x, y + 1, z), locate(x + 3, y- 6, z), src, 200)
	playsound(loc, 'sound/machines/twobeep.ogg', 50, TRUE)
	active_portals++
	addtimer(CALLBACK(src, PROC_REF(cooldown_passed)), 20 SECONDS)
	menu_open = FALSE

// This proc is called when portal disappears after a while, so users can interact with teleporter again
/obj/machinery/deepstorage_teleporter/proc/cooldown_passed()
	active_portals--

/obj/effect/portal/advanced/deepstorage
	name = "portal"
	desc = "Good luck."

// loot spawners

/obj/effect/spawner/random/deepstorage_reward
	name = "warehouse fashion reward"
	loot = list(
			/obj/item/storage/box/syndie_kit/chameleon,
			/obj/item/clothing/suit/pimpcoat,
			/obj/item/melee/skateboard/hoverboard,
			/obj/item/clothing/glasses/sunglasses/yeah
	)

// paper stuff & lore

/obj/item/paper/fluff/ruins/deepstorage/log1
	name = "a note"
	info = {"As per administration's request, I will be keeping the auxiliary power room locked from now on.<br>
	<br>
	If you need in for whatever reason, find me in the western area of the cave tunnels."}

/obj/item/paper/fluff/ruins/deepstorage/log2
	name = "to my love"
	info = {"Everything went batshit insane, at first we all thought it was a terrorist attack or something...
	All floors were put into lockdown, then shortly after all communication across the facility went black.<br>
	<br>
	Guards never said what happened but the fear in their eyes told us everything.<br>
	<br>
	Our colleagues, friends and other folks started arguing, hurting then killing each other in time. Me and four others managed to isolate ourselves in the cafeteria.<br>
	<br>
	We have enough supplies to last a few weeks here, should be enough until reinforcements arrive, right?<br>
	<br>
	If it won't, then god help us... I can't wait to see you again.<br>
	<br>
	Sincerely yours..."}

/obj/item/paper/fluff/ruins/deepstorage/log3
	name = "quartermaster's personal log"
	info = {"<b>(beginning of record...)</b><br>
	<br>
	Day 5 since the lockdown, we can't communicate with other floors which is quite a nuisance. We were already behind 13 deliveries.
	At these very times i miss my time back at- <br>
	<br>
	<b>(end of record.)</b><br>
	<br>
	<b>(beginning of record...)</b><br>
	<br>
	Day 5, since the lockdown. More people are getting sick. I heard the body count was so high they had to start cremating them.
	The fewer bodies, the better. <br>
	<br>
	<b>(end of record.)</b><br>
	<br>
	<b>(beginning of record...)</b><br>
	<br>
	Day... 5, since the-. God, I just checked my previous entries and there were like, 14 in total? In so many I start with 'day 5 of this, of that'.
	Weird part is, I don't recall making any of those records. It must be my insolent staff. If they want a bad review in their employee records,
	they got it...<br>
	<br>
	<b>(end of record.)</b><br>"}

/obj/item/paper/fluff/ruins/deepstorage/log4
	name = "crematorium report"
	info = {"We burnt so many... There's no end to this. It's been days and we're still burning them."}


/obj/item/paper/fluff/ruins/deepstorage/log5
	name = "subject: my concerns"
	info = {"First of all, I appreciate your initiative in cutting off comms, although I'm sure there are some rats listening on the private frequency.
	Unless you want a riot on your hands, I suggest keeping quiet in there.<br>
	<br>
	Getting down to business: we have been working on the sample tissues you've been sending non-stop. In my expert opinion, I don't think there's a single
	bio-abomination we haven't discovered. I've never seen anything like this. It's nothing like a virus or disease you might be familiar with.<br>
	<br>
	Yes, it's contagious, and I don't think it's limited to physical contact. We have been burning the corpses; there's still more to burn.
	This will not end well. I advise evacuating workers to a more suitable quarantine zone before things get out of hand."}

/obj/item/paper/fluff/ruins/deepstorage/log6
	name = "warning"
	info = {"We sealed that thing in the warehouse. It tore apart half of my squad. We were no match.<br>
	<br>
	For whatever reason you want to go in, the package teleporter is still functional. Gates will remain sealed as long as that thing is alive so proceed at your own risk."}

/obj/item/paper/fluff/ruins/deepstorage/log7
	name = "???"
	info = {"<u>Entry 1</u><br><br> By now it's safe to assume they know we're listening on their frequency. If it weren't for a copy of the manual
	I laid my hands on, they would've shaken us off already.<br>
	<br>
	<u>Entry 2</u><br><br> I keep hearing discussions of "resonance" brought up. I don't understand a single thing they're talking
	about but I know it is connected to what we're going through. Today guards arrested three more workers. They're desperately looking for us.<br>
	<br><br>...<br><br>
	<u>Entry 4</u><br><br> Elevators between floors and trams are now shut off, communications across floors followed soon after. Now there is a sickness...
	I still have two months until my transfer to some other facility in the sector. This too shall pass...<br>
	<br><br>...<br><br>
	<u>Entry 9</u><br><br> I no longer can tell where the dream ends and reality begins. Is this real, or still a dream... How many times did I write this? Where are we?
	This isn't our facility. Who are these people? They're not from our post...
	<br><br>...<br><br>
	<u>Entry 13</u><br><br> KICK THEM. KICK THEM WHILE THEY ARE DOWN.
	"}

/obj/item/paper/fluff/ruins/deepstorage/log8
	name = "notice"
	info = {"Until further notice elevators will be out of service. Contact the floor administrator should you require access."}

/obj/item/paper/fluff/ruins/deepstorage/log9
	name = "attention"
	info = {"As per administration's order, unauthorized entry to supply storage is forbidden. Make your requests from the guard wing if you have a pending delivery."}

#undef DS_BOSS_STORAGE
#undef DS_ENGINEERING

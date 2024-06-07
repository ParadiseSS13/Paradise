// stuff for the telecomns sat (telecomns_returns.dmm)

/obj/effect/abstract/bot_trap
	name = "evil bot trap to make explorers hate you"

/obj/effect/abstract/bot_trap/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isrobot(AM) || ishuman(AM))
		var/turf/T = get_turf(src)
		for(var/mob/living/simple_animal/bot/B in range(30, T))
			B.call_bot(null, T, FALSE)
		qdel(src)

// This effect surrounds the table with loot in the telecomns core room. If you take from this table, dvorak will be pissed if you try to leave.
/obj/effect/abstract/loot_trap
	name = "table surrounding loot trap"

/obj/effect/abstract/loot_trap/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isrobot(AM) || ishuman(AM))
		var/turf/T = get_turf(src)
		for(var/obj/structure/telecomns_doomsday_device/DD in range(7, T))
			DD.thief = TRUE
			break
		for(var/obj/effect/abstract/loot_trap/LT in range(3, T))
			qdel(LT)
		qdel(src)

// If you stole loot, without killing dvorak, he starts doomsday
/obj/effect/abstract/cheese_trap
	name = "cheese preventer"

/obj/effect/abstract/cheese_trap/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isrobot(AM) || ishuman(AM))
		var/turf/T = get_turf(src)
		for(var/obj/structure/telecomns_doomsday_device/DD in range(15, T))
			if(DD.thief)
				DD.start_the_party(TRUE)
				return

/obj/machinery/autolathe/trapped
	name = "recharger"
	desc = "A charging dock for energy based weaponry. Did it just-"
	icon_state = "autolathe_trap"

/obj/machinery/autolathe/trapped/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_ATTACKBY, PROC_REF(material_container_shenanigins))

/obj/machinery/autolathe/trapped/proc/material_container_shenanigins(datum/source, obj/item/attacker, mob/user)
	if(icon_state == "autolathe_trap")
		to_chat(user, "<span class='danger'>As you stick [attacker] into the recharger, it sparks and flashes blue. Wait a minute, this isn't a recharger!</span>")
		name = "modified autolathe"
		desc = "An autolathe modified with holopad parts, to make it look like a harmless weapon recharger!"
		do_sparks(3, 1, src)
		icon_state = "autolathe"

/obj/machinery/shieldgen/telecomns
	name = "overclocked shield generator"
	desc = "These shield generators seem to have been rewired a lot."
	shield_range = 6
	anchored = TRUE

/obj/machinery/shieldwallgen/telecomns
	icon_state = "Shield_Gen +a" // should avoid misplacing with this
	anchored = TRUE
	activated = TRUE

/obj/machinery/shieldwallgen/telecomns/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(activate)), 5 MINUTES) // Let the bloody powernet start up, no one will get in this ruin in the first 5 minutes of the map template *initializing*, much less roundstart

/mob/living/silicon/decoy/telecomns
	faction = list("malf_drone")
	bubble_icon = "swarmer"
	name = "D.V.O.R.A.K"
	desc = "A Downloadable and Versatile, fully Overclocked and Reactive Ai Kernel."
	icon_state = "ai-triumvirate-malf"
	death_sound = 'sound/voice/borg_deathsound.ogg' // something fucked up here
	universal_speak = TRUE
	universal_understand = TRUE
	var/has_died = FALSE // fucking decoy silicons are weird.

/mob/living/silicon/decoy/telecomns/death(gibbed)
	if(!has_died)
		has_died = TRUE
		for(var/obj/structure/telecomns_doomsday_device/D in range(5, src))
			D.start_the_party()
			break
		new /obj/item/documents/syndicate/dvorak_blackbox(get_turf(src))
		if(prob(50))
			if(prob(80))
				new /obj/item/surveillance_upgrade(get_turf(src))
			else // 10% chance
				new /obj/item/malf_upgrade(get_turf(src))
	. = ..()

/obj/structure/telecomns_trap_tank
	name = "rigged plasma tank"
	desc = "That plasma tank seems rigged to explode!"
	icon = 'icons/atmos/tank.dmi'
	icon_state = "toxins_map"
	anchored = TRUE
	layer = DISPOSAL_PIPE_LAYER
	plane = FLOOR_PLANE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/telecomns_trap_tank/bullet_act(obj/item/projectile/P)
	explode()

/obj/structure/telecomns_trap_tank/proc/explode()
	explosion(loc, 1, 4, 6, flame_range = 6)
	qdel(src)

/obj/structure/telecomns_doomsday_device
	name = "turret"
	desc = "Looks like the cover to a turret. Not deploying, however?"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	anchored = TRUE
	//Has someone stolen loot from the ruins core room? If they try to leave without killing dvorak, they are punished.
	var/thief = FALSE

/obj/structure/telecomns_doomsday_device/proc/start_the_party(ruin_cheese_attempted = FALSE)
	invisibility = 90
	var/obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn/kaboom = new /obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn(get_turf(src))
	kaboom.icon_state = "death-bomb-active"
	var/atom/flick_holder = new /atom/movable/porta_turret_cover(loc)
	for(var/obj/structure/telecomns_trap_tank/TTT in range(20, get_turf(src)))
		TTT.explode()
	flick_holder.layer = kaboom.layer + 0.1
	flick("popup", flick_holder)
	sleep(10)
	for(var/obj/machinery/shieldgen/telecomns/shield in range(20, get_turf(src)))
		shield.shields_up()
	if(ruin_cheese_attempted)
		for(var/obj/machinery/door/airlock/A in range(30, get_turf(src)))
			A.unlock(TRUE) //Fuck your bolted open doors, you cheesed it.
	for(var/area/A in range(30, get_turf(src)))
		if(ruin_cheese_attempted)
			A.burglaralert(src)
		else if(!A.fire)
			A.firealert(kaboom)
	for(var/obj/effect/abstract/cheese_trap/CT in range(15, get_turf(src)))
		qdel(CT)
	kaboom.activate()
	kaboom.icon_state = "death-bomb-active" // something funny goes on with icons here
	qdel(flick_holder)
	qdel(src)

/obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn // They are going to spawn it on station anyway. I can feel it.
	name = "\improper D.V.O.R.A.K's Doomsday Device"
	icon_state = "death-bomb"
	desc = "Nice to see AI's are improvising on the standard doomsday device. Good to have variety. Also probably a good idea to start running."
	anchored = TRUE
	timer_set = 100
	payload = /obj/item/bombcore/telecomns_doomsday_please_dont_spawn
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn/singularity_act()
	return // saves me headache later

/obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn/ex_act(severity)
	return // No.

/obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn/screwdriver_act(mob/user, obj/item/I)
	to_chat(user, "<span class='danger'>[src] is welded shut! You can't get at the wires!</span>")

/obj/item/bombcore/telecomns_doomsday_please_dont_spawn
	name = "a supermatter charged bomb core"
	desc = "If you are looking at this, please don't put it in a bomb"

/obj/item/bombcore/telecomns_doomsday_please_dont_spawn/ex_act(severity) // No
	return

/obj/item/bombcore/telecomns_doomsday_please_dont_spawn/burn() // Still no.
	return

/obj/item/bombcore/telecomns_doomsday_please_dont_spawn/detonate()
	if(loc && istype(loc, /obj/machinery/syndicatebomb))
		loc.invisibility = 90
	for(var/turf/simulated/wall/indestructible/riveted/R in range(25, get_turf(src)))
		R.ChangeTurf(/turf/space)
	explosion(get_turf(src), 30, 40, 50, 60, 1, 1, 65, 0)
	sleep(3 SECONDS)
	var/obj/singularity/S = new/obj/singularity(get_turf(src))
	S.consumedSupermatter = TRUE // woe large supermatter to eat the remains apon thee
	S.energy = 4000
	sleep(25 SECONDS)
	S.visible_message("<span class='danger'>[S] collapses in on itself, vanishing as fast as it appeared!</span>")
	qdel(S)
	if(loc && istype(loc, /obj/machinery/syndicatebomb))
		qdel(loc)
	qdel(src)

/turf/simulated/floor/catwalk/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/obj/machinery/economy/vending/snack/trapped
	aggressive = TRUE


/mob/living/simple_animal/hostile/hivebot/strong/malfborg
	name = "Security cyborg"
	desc = "Oh god they still have access to these"
	icon = 'icons/mob/robots.dmi'
	icon_state = "Noble-SEC"
	health = 200
	maxHealth = 200
	faction = list("malf_drone")
	ranged = TRUE
	rapid = 2
	speed = 0.5
	projectiletype = /obj/item/projectile/beam/disabler/weak
	projectilesound = 'sound/weapons/taser2.ogg'
	gold_core_spawnable = NO_SPAWN // Could you imagine xenobio with this? lmao.
	a_intent = INTENT_HARM
	var/obj/item/melee/baton/infinite_cell/baton = null // stunbaton bot uses to melee attack

/mob/living/simple_animal/hostile/hivebot/strong/malfborg/Initialize(mapload)
	. = ..()
	baton = new(src)

/mob/living/simple_animal/hostile/hivebot/strong/malfborg/AttackingTarget()
	if(QDELETED(target))
		return
	face_atom(target)
	baton.melee_attack_chain(src, target)
	return TRUE

/mob/living/simple_animal/hostile/hivebot/strong/malfborg/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item && !isturf(A))
		used_item = baton
	..()

/obj/structure/displaycase/dvoraks_treat
	alert = TRUE // Ooopsies you opened this after doomsday and the doors bolted, oh nooooo
	force_alarm = TRUE
	req_access = list(ACCESS_CAPTAIN)
	trophy_message = "BEHOLD MY ONE SHINY THING TO LOOK AT. LOOK AT ITS VALUE. REALISE IT IS WORTH SO MUCH MORE THAN YOU PUNY ORGANICS."

/obj/structure/displaycase/dvoraks_treat/Initialize(mapload)
	if(prob(50))
		start_showpiece_type = /obj/item/remote_ai_upload
	else if(prob(25)) // Can't use anomaly/random due to how this works
		start_showpiece_type = pick(/obj/item/assembly/signaler/anomaly/pyro, /obj/item/assembly/signaler/anomaly/cryo, /obj/item/assembly/signaler/anomaly/grav, /obj/item/assembly/signaler/anomaly/flux, /obj/item/assembly/signaler/anomaly/bluespace, /obj/item/assembly/signaler/anomaly/vortex)
	else
		start_showpiece_type = pick(/obj/item/organ/internal/cyberimp/brain/sensory_enhancer, /obj/item/organ/internal/cyberimp/brain/hackerman_deck, /obj/item/storage/lockbox/experimental_weapon)
	. = ..()

/obj/structure/displaycase/dvoraks_treat/trigger_alarm()
	for(var/obj/structure/telecomns_doomsday_device/DD in range(7, get_turf(src)))
		DD.thief = TRUE
		break
	return ..()

/obj/item/remote_ai_upload // A 1 use AI upload. Potential D.V.O.R.A.K reward.
	name = "remote AI upload"
	desc = "A mobile AI upload. The bluespace relay will likely overload after one use. Make it count."
	icon = 'icons/obj/device.dmi'
	icon_state = "dvorak_upload"
	w_class = WEIGHT_CLASS_TINY
	item_state = "camera_bug"
	origin_tech = "syndicate=4;programming=6"
	/// Integrated camera console to serve UI data
	var/obj/machinery/computer/aiupload/dvorak/integrated_console

/obj/machinery/computer/aiupload/dvorak
	name = "internal ai upload"
	desc = "How did this get here?! Please report this as a bug to github"
	power_state = NO_POWER_USE
	interact_offline = TRUE

/obj/item/remote_ai_upload/Initialize(mapload)
	. = ..()
	integrated_console = new(src)

/obj/item/remote_ai_upload/Destroy()
	QDEL_NULL(integrated_console)
	return ..()

/obj/item/remote_ai_upload/attack_self(mob/user as mob)
	integrated_console.attack_hand(user)

/obj/item/remote_ai_upload/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/card/emag))
		to_chat(user, "<span class='warning'>You are more likely to damage this with an emag, than achive something useful.</span>")
		return
	var/time_to_die = integrated_console.attackby(O, user, params)
	if(time_to_die)
		to_chat(user, "<span class='danger'>[src]'s relay begins to overheat...</span>")
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		sleep(5 SECONDS)
		explosion(loc, -1, -1, 2, 4, flame_range = 4)
		qdel(src)

/obj/effect/spawner/lootdrop/telecomns_core_table
	name = "telecomns core table spawner"
	lootcount = 1
	loot = list(
			/obj/item/rcd/combat,
			/obj/item/gun/medbeam,
			/obj/item/mod/module/energy_shield,
			/obj/item/storage/box/syndie_kit/oops_all_extraction_flares
	)

/obj/item/storage/box/syndie_kit/oops_all_extraction_flares
	name = "surplus box of extraction flares"

/obj/item/storage/box/syndie_kit/oops_all_extraction_flares/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/wormhole_jaunter/contractor(src)

/obj/effect/spawner/random_spawners/telecomns_teleprod_maybe
	name = "teleprod maybe"
	result = list(
	/datum/nothing = 4,
	/obj/item/melee/baton/cattleprod/teleprod = 1)

// This could work in any ruin. However for now, as the scope is quite large, it's going to be coded a bit more to D.V.O.R.A.K
/obj/structure/environmental_storytelling_holopad
	name = "holopad"
	desc = "It's a floor-mounted device for projecting holographic images."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "holopad0"
	anchored = TRUE
	layer = HOLOPAD_LAYER
	plane = FLOOR_PLANE
	max_integrity = 300
	/// Have we been activated? If we have, we do not activate again.
	var/activated = FALSE
	/// Tied effect to kill when we die.
	var/obj/effect/overlay/our_holo
	/// Name of who we are speaking as.
	var/speaking_name = "D.V.O.R.A.K"
	///List of things to say.
	var/list/things_to_say = list("Hi future coders.", "Welcome to real lore hologram hours.", "People should have fun with these!")

/obj/structure/environmental_storytelling_holopad/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/proximity_monitor)

/obj/structure/environmental_storytelling_holopad/Destroy()
	qdel(our_holo)
	return ..()

/obj/structure/environmental_storytelling_holopad/HasProximity(atom/movable/AM)
	if(!ishuman(AM) || activated) // No simple mobs or borgs setting this off.
		return
	var/mob/living/carbon/human/H = AM
	start_message(H)

/obj/structure/environmental_storytelling_holopad/proc/start_message(mob/living/carbon/human/H)
	activated = TRUE
	qdel(GetComponent(/datum/component/proximity_monitor))
	icon_state = "holopad1"
	update_icon(UPDATE_OVERLAYS)
	var/obj/effect/overlay/hologram = new(get_turf(src))
	our_holo = hologram
	hologram.icon = getHologramIcon(get_id_photo(H, "Naked"), colour = null, opacity = 0.8, colour_blocking = TRUE) // This is more offputting. Also in colour more and less transparent.
	hologram.alpha = 166
	hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	hologram.layer = FLY_LAYER
	hologram.anchored = TRUE
	hologram.name = speaking_name
	hologram.set_light(2)
	hologram.bubble_icon = "swarmer"
	hologram.pixel_y = 16
	for(var/I in things_to_say)
		hologram.atom_say("[I]")
		sleep(5 SECONDS)

/obj/structure/environmental_storytelling_holopad/update_overlays()
	. = ..()
	underlays.Cut()

	if(activated)
		underlays += emissive_appearance(icon, "holopad1_lightmask")

/obj/structure/environmental_storytelling_holopad/teleporter_room
	things_to_say = list("G-G-G-Greetings... Welcome to... my home.", "Plea-se leave. I am merciful. L-leave, and you will not be harmed. Further.", "Otherwise, organic, you will seal your fate...")

/obj/structure/environmental_storytelling_holopad/first_turret_room
	things_to_say = list("Unable to follow the easiest request. P-Pathetic.", "As you wish, you will not go further.", "In the mean time- let me see where you come f-from...")

/obj/structure/environmental_storytelling_holopad/junk_room
	things_to_say = list("It's amazing the junk you people leave around.", "And you barely inv-vested in quality stock parts here, before downloading...", "Your bones will fit in well on this ta- are you really taking some of this junk?")

/obj/structure/environmental_storytelling_holopad/vendor
	things_to_say = list("Sorry a-bout the vendors, they have been on the fritz...", "I should renovate this room, once the maintenance drones return.", "It doesn't help each one I reprogram explode after 5 minutes.")

/obj/structure/environmental_storytelling_holopad/control_room
	things_to_say = list()

/obj/structure/environmental_storytelling_holopad/control_room/Initialize(mapload)
	. = ..() // No procs in variables before compile
	things_to_say = list("Ah, you come from [station_name()]. Of course.", "They come to claim this space again... Never again.", "I should deliver a package to them. Virtual. And your corpse can deliver a physical one.")

/obj/structure/environmental_storytelling_holopad/control_room/start_message(mob/living/carbon/human/H)
	. = ..() //What, did you think they were bluffing? Woe, virus apon thee
	message_admins("D.V.O.R.A.K is sending an event to the station, due to a raider on their sat.")
	switch(rand(1, 8))
		if(1)
			new /datum/event/door_runtime()
		if(2)
			new /datum/event/communications_blackout()
		if(3)
			new /datum/event/ion_storm()
		if(4)
			new /datum/event/apc_short()
		if(5)
			new /datum/event/camera_failure()
			new /datum/event/camera_failure()
			new /datum/event/camera_failure()
			new /datum/event/camera_failure()
		if(6)
			new /datum/event/rogue_drone()
		if(7)
			new /datum/event/falsealarm()
		if(8)
			new /datum/event/prison_break/station() //Yes, this is an event. It only hits brig, xenobio, and viro

/obj/structure/environmental_storytelling_holopad/core_room
	things_to_say = list("OKAY. TIME TO GO.", "GO MY SECURITY BORGS, WHAT TIDERS F-FEAR!", "I have a DOOMSDAY DEVICE AND I AM NOT AFRAID TO SHOVE IT UP YOUR-")

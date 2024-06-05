//stuff for the telecomns sat (wizardcrash.dmm)

/obj/effect/abstract/bot_trap
	name = "evil bot trap to make explorers hate you"

/obj/effect/abstract/bot_trap/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isrobot(AM) || ishuman(AM))
		var/turf/T = get_turf(src)
		for(var/mob/living/simple_animal/bot/B in range(30, get_turf(src)))
			B.call_bot(null, T, FALSE)
		qdel(src)

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
	icon_state = "Shield_Gen +a" //should avoid missplacing with this
	anchored = TRUE
	activated = TRUE

/obj/machinery/shieldwallgen/telecomns/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(activate)), 5 MINUTES)// Let the bloody powernet start up, no one will get in this ruin in the first 5 minutes of the map template *initializing*, much less roundstart

/mob/living/silicon/decoy/telecomns
	faction = list("malf_drone")
	bubble_icon = "swarmer"
	name = "D.V.O.R.A.K"
	desc = "A Downloadable and Versatile, fully Overclocked and Reactive Ai Kernel."
	icon_state = "ai-triumvirate-malf"
	death_sound = 'sound/voice/borg_deathsound.ogg' //something fucked up here
	universal_speak = TRUE
	universal_understand = TRUE
	var/has_died = FALSE //fucking decoy silicons are wierd.

/mob/living/silicon/decoy/telecomns/death(gibbed)
	if(!has_died)
		has_died = TRUE
		for(var/obj/structure/telecomns_doomsday_device/D in range(5, src))
			D.start_the_party()
			break
		new /obj/item/documents/nanotrasen/dvorak_blackbox(get_turf(src))
		if(prob(50))
			if(prob(80))
				new /obj/item/surveillance_upgrade(get_turf(src))
			else //10% chance
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
	var/turf/our_turf = get_turf(src)
	our_turf.ChangeTurf(/turf/space)
	for(var/turf/simulated/floor/catwalk/T in range(4, get_turf(src)))
		if(prob(50))
			T.ChangeTurf(/turf/space)
	explosion(loc, 1, 4, 6, flame_range = 6)
	qdel(src)

/obj/structure/telecomns_doomsday_device
	name = "turret"
	desc = "Looks like the cover to a turret. Not deploying, however?"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	anchored = TRUE

/obj/structure/telecomns_doomsday_device/proc/start_the_party()
	invisibility = 90
	var/obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn/kaboom = new /obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn(get_turf(src))
	kaboom.icon_state = "death-bomb-active"
	var/atom/flick_holder = new /atom/movable/porta_turret_cover(loc)
	for(var/obj/structure/telecomns_trap_tank/TTT in range(20, get_turf(src)))
		TTT.explode()
	flick_holder.layer = layer + 0.1
	flick("popup", flick_holder)
	sleep(10)
	for(var/obj/machinery/shieldgen/telecomns/shield in range(20, get_turf(src)))
		shield.shields_up()
	kaboom.activate()
	kaboom.icon_state = "death-bomb-active" // something funny goes on with icons here
	qdel(flick_holder)
	qdel(src)

/obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn //They are going to spawn it on station anyway. I can feel it.
	name = "\improper D.V.O.R.A.K's Doomsday Device"
	icon_state = "death-bomb"
	desc = "Nice to see AI's are improvising on the standard doomsday device. Good to have variety. Also probably good to start running."
	anchored = TRUE
	payload = /obj/item/bombcore/telecomns_doomsday_please_dont_spawn
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn/singularity_act()
	return //saves me headache later

/obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn/ex_act(severity)
	return //No.

/obj/machinery/syndicatebomb/telecomns_doomsday_please_dont_spawn/screwdriver_act(mob/user, obj/item/I)
	to_chat(user, "<span class='danger'>[src] is welded shut! You can't get at the wires!</span>")

/obj/item/bombcore/telecomns_doomsday_please_dont_spawn
	name = "a supermatter charged bomb core"
	desc = "If you are looking at this, please don't put it in a bomb"

/obj/item/bombcore/telecomns_doomsday_please_dont_spawn/ex_act(severity) //No
	return

/obj/item/bombcore/telecomns_doomsday_please_dont_spawn/burn() //Still no.
	return

/obj/item/bombcore/telecomns_doomsday_please_dont_spawn/detonate()
	if(loc && istype(loc, /obj/machinery/syndicatebomb))
		loc.invisibility = 90
	for(var/turf/simulated/wall/indestructible/riveted/R in range(25, get_turf(src)))
		R.ChangeTurf(/turf/space)
	explosion(get_turf(src), 30, 40, 50, 60, 1, 1, 65, 0)
	sleep(3 SECONDS)
	var/obj/singularity/S = new/obj/singularity(get_turf(src))
	S.consumedSupermatter = TRUE //woe large supermatter to eat the remains apon thee
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

/obj/machinery/economy/vending/snack/trapped/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/proximity_monitor)

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
	gold_core_spawnable = NO_SPAWN //Could you imagine xenobio with this? lmao.
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
	alert = TRUE //Ooopsies you opened this after doomsday and the doors bolted, oh nooooo
	req_access = list(ACCESS_CAPTAIN)

/obj/structure/displaycase/dvoraks_treat/Initialize(mapload)
	if(prob(50))
		start_showpiece_type = /obj/item/remote_ai_upload
	else if(prob(25)) //Can't use anomaly/random due to how this works
		start_showpiece_type = pick(/obj/item/assembly/signaler/anomaly/pyro, /obj/item/assembly/signaler/anomaly/cryo, /obj/item/assembly/signaler/anomaly/grav, /obj/item/assembly/signaler/anomaly/flux, /obj/item/assembly/signaler/anomaly/bluespace, /obj/item/assembly/signaler/anomaly/vortex)
	else
		start_showpiece_type = pick(/obj/item/organ/internal/cyberimp/brain/sensory_enhancer, /obj/item/organ/internal/cyberimp/brain/hackerman_deck, /obj/item/storage/lockbox/experimental_weapon)
	. = ..()

/obj/item/remote_ai_upload //A 1 use AI upload. Potential D.V.O.R.A.K reward.
	name = "remote AI upload"
	desc = "A mobile AI upload. The bluespace relay will likely overload after one use. Make it count."
	icon = 'icons/obj/device.dmi'
	icon_state = "dvorak_upload"
	w_class	= WEIGHT_CLASS_TINY
	item_state = "camera_bug"
	throw_speed	= 4
	throw_range	= 20
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

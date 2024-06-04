//stuff for the telecomns sat (wizardcrash.dmm)

/obj/effect/abstract/bot_trap
	name = "evil bot trap to make explorers hate you"

/obj/effect/abstract/bot_trap/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM))
		var/turf/T = get_turf(src)
		for(var/mob/living/simple_animal/bot/B in range(30, get_turf(src)))
			B.call_bot(null, T, FALSE)
		qdel(src)

/obj/machinery/autolathe/trapped
	name = "recharger"
	desc = "A charging dock for energy based weaponry. Did it just-"
	icon_state = "autolathe_trap"

/obj/machinery/autolathe/trapped/attacked_by(obj/item/I, mob/living/user)
	if(icon_state == "autolathe_trap")
		to_chat(user, "<span class='danger'>As you stick [I] into [src], it sparks and flashes blue. Wait a minute, this isn't a recharger!</span>")
		name = "modified autolathe"
		desc = "An autolathe modified with holopad parts, to make it look like a harmless weapon recharger!"
		do_sparks(3, 1, src)
		//Note: icon changes itself after.
	. = ..()

/obj/machinery/shieldgen/telecomns
	name = "overclocked shield generator"
	desc = "These shield generators seem to have been rewired a lot."
	shield_range = 6
	anchored = TRUE

/obj/machinery/shieldwallgen/telecomns
	anchored = TRUE
	activated = TRUE

/obj/machinery/shieldwallgen/telecomns/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(activate)), 5 MINUTES)// Let the bloody powernet start up, no one will get in this ruin in the first 5 minutes of the map template *initializing*, much less roundstart

/mob/living/silicon/decoy/telecomns
	faction = list("malf_drone")
	bubble_icon = "swarmer"
	name = "D.V.O.R.A.K"
	desc = "Downloadable, Versatile, Operational and Reactive Ai Kernel."
	icon_state = "ai-triumvirate-malf"
	death_sound = 'sound/voice/borg_deathsound.ogg' //something fucked up here
	universal_speak = TRUE
	universal_understand = TRUE
	var/has_died = FALSE //fucking decoy silicons are wierd.

/mob/living/silicon/decoy/telecomns/death(gibbed)
	if(!has_died)
		for(var/obj/structure/telecomns_doomsday_device/D in range(5, src))
			has_died = TRUE
			D.start_the_party()
			break
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
	name = "\improper OH GOD A HUGE BOMB"
	icon_state = "death-bomb"
	desc = "Perhaps running, over looking at this horrible thing, would be better"
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
	explosion(get_turf(src), 25, 35, 45, 55, 1, 1, 60, 0)
	sleep(3 SECONDS)
	message_admins("pizza time")
	var/obj/singularity/S = new/obj/singularity(get_turf(src))
	S.energy = 9001
	sleep(10 SECONDS)
	S.visible_message("<span class='danger'>[S] collapses in on itself, vanishing as fast as it appeared!</span>")
	qdel(S)
	if(loc && istype(loc, /obj/machinery/syndicatebomb))
		qdel(loc)
	qdel(src)

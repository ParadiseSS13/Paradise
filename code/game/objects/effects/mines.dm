/obj/effect/mine
	name = "Mine"
	desc = "I Better stay away from that thing."
	density = 1
	anchored = 1
	layer = 3
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglymine"
	var/triggerproc = "explode" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/effect/mine/New()
	icon_state = "uglyminearmed"

/obj/effect/mine/Crossed(AM as mob|obj)
	Bumped(AM)

/obj/effect/mine/Bumped(mob/M as mob|obj)

	if(triggered) return

	if(istype(M, /mob/living/carbon/human))
		for(var/mob/O in viewers(world.view, src.loc))
			to_chat(O, "<font color='red'>[M] triggered the [bicon(src)] [src]</font>")
		triggered = 1
		call(src,triggerproc)(M)

/obj/effect/mine/proc/triggerrad(obj)
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	obj:radiation += 50
	randmutb(obj)
	domutcheck(obj,null)
	spawn(0)
		qdel(src)

/obj/effect/mine/proc/triggerstun(obj)
	if(ismob(obj))
		var/mob/M = obj
		M.Stun(30)
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	spawn(0)
		qdel(src)

/obj/effect/mine/proc/triggern2o(obj)
	atmos_spawn_air(SPAWN_N2O, 360)
	spawn(0)
		qdel(src)

/obj/effect/mine/proc/triggerplasma(obj)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 360)
	spawn(0)
		qdel(src)

/obj/effect/mine/proc/triggerkick(obj)
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(obj:client)
	spawn(0)
		qdel(src)

/obj/effect/mine/proc/explode(obj)
	explosion(loc, 0, 1, 2, 3)
	spawn(0)
		qdel(src)

/obj/effect/mine/dnascramble
	name = "Radiation Mine"
	icon_state = "uglymine"
	triggerproc = "triggerrad"

/obj/effect/mine/plasma
	name = "Plasma Mine"
	icon_state = "uglymine"
	triggerproc = "triggerplasma"

/obj/effect/mine/kick
	name = "Kick Mine"
	icon_state = "uglymine"
	triggerproc = "triggerkick"

/obj/effect/mine/n2o
	name = "N2O Mine"
	icon_state = "uglymine"
	triggerproc = "triggern2o"

/obj/effect/mine/stun
	name = "Stun Mine"
	icon_state = "uglymine"
	triggerproc = "triggerstun"

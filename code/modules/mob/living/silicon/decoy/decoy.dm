/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/AI.dmi'//
	icon_state = "ai"
	anchored = 1 // -- TLE
	canmove = 0
	a_intent = "harm" // This is apparently the only thing that stops other mobs walking through them as if they were thin air.

/mob/living/silicon/decoy/New()
	src.icon = 'icons/mob/AI.dmi'
	src.icon_state = "ai"
	src.anchored = 1
	src.canmove = 0


/mob/living/silicon/decoy/syndicate
	faction = list("syndicate")
	name = "R.O.D.G.E.R"
	desc = "Red Operations, Depot General Emission Regulator"
	icon_state = "ai-magma"

/mob/living/silicon/decoy/syndicate/New()
	. = ..()
	icon_state = "ai-magma"


/mob/living/silicon/decoy/syndicate/depot
	var/exploded = FALSE

/mob/living/silicon/decoy/syndicate/depot/proc/explode()
	if(!exploded)
		exploded = TRUE
		raise_alert()
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		new /obj/effect/decal/cleanable/blood/oil(loc)
		qdel(src)

/mob/living/silicon/decoy/syndicate/depot/proc/raise_alert()
	var/area/syndicate_depot/depotarea = get_area(src) // Cannot use myArea or areaMaster as neither will be defined for this mob type
	if(depotarea)
		depotarea.increase_alert("AI Unit Offline")
	else
		say("Connection failure!")

/mob/living/silicon/decoy/syndicate/depot/death(var/pass)
	. = ..(pass)
	explode()

/mob/living/silicon/decoy/syndicate/depot/adjustBruteLoss(var/dmg)
	health = health - dmg
	if(health <= 0)
		explode()

/mob/living/silicon/decoy/syndicate/depot/adjustFireLoss(var/dmg)
	health = health - dmg
	if(health <= 0)
		explode()

/mob/living/silicon/decoy/syndicate/depot/ex_act(var/severity)
	adjustBruteLoss(250)
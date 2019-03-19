/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/ai.dmi'//
	icon_state = "ai"
	anchored = 1 // -- TLE
	canmove = 0
	a_intent = INTENT_HARM // This is apparently the only thing that stops other mobs walking through them as if they were thin air.

/mob/living/silicon/decoy/New()
	src.icon = 'icons/mob/ai.dmi'
	src.icon_state = "ai"
	src.anchored = 1
	src.canmove = 0

/mob/living/silicon/decoy/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/aicard))
		to_chat(user, "<span class='warning'>You cannot find an intellicard slot on [src].</span>")
		return TRUE
	else
		return ..()

/mob/living/silicon/decoy/syndicate
	faction = list("syndicate")
	name = "R.O.D.G.E.R"
	desc = "Red Operations, Depot General Emission Regulator"
	icon_state = "ai-magma"

/mob/living/silicon/decoy/syndicate/New()
	. = ..()
	icon_state = "ai-magma"

/mob/living/silicon/decoy/syndicate/depot
	var/raised_alert = FALSE

/mob/living/silicon/decoy/syndicate/depot/proc/raise_alert()
	raised_alert = TRUE
	var/area/syndicate_depot/core/depotarea = get_area(src) // Cannot use myArea or areaMaster as neither will be defined for this mob type
	if(istype(depotarea))
		depotarea.increase_alert("AI Unit Offline")
	else
		say("Connection failure!")

/mob/living/silicon/decoy/syndicate/depot/death(pass)
	if(!raised_alert)
		raise_alert()
	. = ..(pass)

/mob/living/silicon/decoy/syndicate/depot/adjustBruteLoss(dmg)
	. = ..(dmg)
	updatehealth()

/mob/living/silicon/decoy/syndicate/depot/adjustFireLoss(dmg)
	. = ..(dmg)
	updatehealth()

/mob/living/silicon/decoy/syndicate/depot/ex_act(severity)
	adjustBruteLoss(250)
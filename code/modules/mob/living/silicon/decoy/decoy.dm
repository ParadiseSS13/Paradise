/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/ai.dmi'//
	icon_state = "ai"
	anchored = TRUE // -- TLE
	mobility_flags = 0
	a_intent = INTENT_HARM // This is apparently the only thing that stops other mobs walking through them as if they were thin air.

/mob/living/silicon/decoy/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/aicard))
		to_chat(user, "<span class='warning'>You cannot find an intellicard slot on [src].</span>")
		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/mob/living/silicon/decoy/welder_act()
	return

/mob/living/silicon/decoy/syndicate
	faction = list("syndicate")
	bubble_icon = "syndibot"
	name = "R.O.D.G.E.R"
	desc = "Red Operations, Depot General Emission Regulator."
	icon_state = "ai-magma"

/mob/living/silicon/decoy/syndicate/Initialize(mapload)
	. = ..()
	icon_state = "ai-magma"

/mob/living/silicon/decoy/syndicate/depot
	universal_speak = TRUE
	universal_understand = TRUE
	var/raised_alert = FALSE

/mob/living/silicon/decoy/syndicate/depot/proc/raise_alert()
	raised_alert = TRUE
	var/area/syndicate_depot/core/depotarea = get_area(src) // Cannot use myArea as it wont be defined for this mob type
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

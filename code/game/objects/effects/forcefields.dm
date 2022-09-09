/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield"
	anchored = 1
	opacity = 0
	density = 1
	var/lifetime = 30 SECONDS

/obj/effect/forcefield/New()
	..()
	if(lifetime)
		QDEL_IN(src, lifetime)

/obj/effect/forcefield/CanAtmosPass(turf/T)
	return !density

/obj/effect/forcefield/wizard
	var/mob/wizard

/obj/effect/forcefield/wizard/Initialize(mapload, mob/summoner)
	. = ..()
	wizard = summoner

/obj/effect/forcefield/wizard/CanPass(atom/movable/mover, turf/target)
	if(mover == wizard)
		return TRUE
	return FALSE

///////////Mimewalls///////////

/obj/effect/forcefield/mime
	icon_state = "empty"
	name = "invisible wall"
	desc = "You have a bad feeling about this."

/obj/effect/forcefield/mime/advanced
	name = "invisible blockade"
	desc = "You might be here a while."
	lifetime = 60 SECONDS

///////////Mechawalls///////////
/obj/effect/forcefield/mecha
	icon_state = "shield-old"
	name = "Energy wall"
	desc = "A slowly fading energy wall that blocks passage"

/obj/effect/forcefield/mecha/syndicate
	icon_state = "shield-red"
	name = "Syndicate energy wall"
	desc = "A slowly fading energy wall that blocks passage for every possible nanotrasen scum"

/obj/effect/forcefield/mecha/syndicate/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASS_OTHER_THINGS))
		return TRUE
	var/mob/living/M = get_mob_in_atom_without_warning(mover)
	if("syndicate" in M.faction || istype(M.get_id_card(), /obj/item/card/id/syndicate))
		return TRUE
	return FALSE

/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon_state = "m_shield"
	density = TRUE
	var/lifetime = 30 SECONDS

/obj/effect/forcefield/New()
	..()
	if(lifetime)
		QDEL_IN(src, lifetime)

/obj/effect/forcefield/CanAtmosPass(direction)
	return !density

/obj/effect/forcefield/wizard
	var/mob/wizard
	/// Flags for what antimagic can just ignore our forcefields
	var/antimagic_flags = MAGIC_RESISTANCE

/obj/effect/forcefield/wizard/Initialize(mapload, mob/summoner)
	. = ..()
	wizard = summoner

/obj/effect/forcefield/wizard/CanPass(atom/movable/mover, border_dir)
	if(mover == wizard)
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(living_mover.can_block_magic(antimagic_flags, charge_cost = 0))
			return TRUE
	return FALSE

///////////Mimewalls///////////

/obj/structure/forcefield
	name = "ain't supposed to see this"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/effects/effects.dmi'
	density = TRUE
	anchored = TRUE
	var/blocks_atmos = TRUE

/obj/structure/forcefield/Initialize(mapload)
	. = ..()
	if(blocks_atmos)
		recalculate_atmos_connectivity()

/obj/structure/forcefield/Destroy()
	if(blocks_atmos)
		blocks_atmos = FALSE
		recalculate_atmos_connectivity()
	return ..()

/obj/structure/forcefield/CanAtmosPass(direction)
	return !blocks_atmos

/obj/structure/forcefield/mime
	icon_state = "5"
	name = "invisible wall"
	alpha = 1
	desc = "You have a bad feeling about this."
	max_integrity = 80

/obj/effect/forcefield/mime
	icon_state = null
	name = "invisible blockade"
	desc = "You might be here a while."
	lifetime = 60 SECONDS

/// The cosmic heretics forcefield
/obj/effect/forcefield/cosmic_field
	name = "Cosmic Field"
	desc = "A field that cannot be passed by people marked with a cosmic star."
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cosmic_carpet"
	density = FALSE
	layer = ABOVE_ICYOVERLAY_LAYER // Very low layer above turfs. Ensures you can click runes, but also means it can eat bullets if you missclick.
	plane = FLOOR_PLANE
	/// Flags for what antimagic can just ignore our forcefields
	var/antimagic_flags = MAGIC_RESISTANCE

/obj/effect/forcefield/cosmic_field/Initialize(mapload, flags = MAGIC_RESISTANCE)
	. = ..()
	antimagic_flags = flags

/obj/effect/forcefield/cosmic_field/CanAtmosPass(direction)
	return FALSE

/obj/effect/forcefield/cosmic_field/CanPass(atom/movable/mover, border_dir)
	if(!isliving(mover))
		return ..()
	var/mob/living/living_mover = mover
	if(living_mover.can_block_magic(antimagic_flags, charge_cost = 0))
		return ..()
	if(living_mover.has_status_effect(/datum/status_effect/star_mark))
		return FALSE
	return ..()

/obj/effect/forcefield/cosmic_field/fast
	lifetime = 5 SECONDS

/obj/effect/forcefield/cosmic_field/extrafast
	lifetime = 2.5 SECONDS

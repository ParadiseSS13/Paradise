/datum/spell/jaunt/mirror_walk
	name = "Mirror Walk"
	desc = "Allows you to traverse invisibly and freely across the station within the realm of the mirror. \
		You can only enter and exit the realm of mirrors when nearby reflective surfaces and items, \
		such as windows, mirrors, and reflective walls or equipment."

	overlay_icon_state = "bg_heretic"
	//button_overlay_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak"

	base_cooldown = 6 SECONDS
	//jaunt_type = /obj/effect/dummy/phased_mob/mirror_walk
	spell_requirements = NONE

	/// The time it takes to enter the mirror / phase out / enter jaunt.
	var/phase_out_time = 1.5 SECONDS
	/// The time it takes to exit a mirror / phase in / exit jaunt.
	var/phase_in_time = 2 SECONDS
	/// Static typecache of types that are counted as reflective.
	var/static/list/special_reflective_surfaces = typecacheof(list(
		/obj/structure/window,
		/obj/structure/mirror,
	))

//qwertodo: this needs to be a subtype of bloodcrawl
/obj/effect/dummy/phased_mob/mirror_walk
	name = "reflection"

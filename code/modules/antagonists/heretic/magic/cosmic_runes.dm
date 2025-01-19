/datum/spell/cosmic_rune
	name = "Cosmic Rune"
	desc = "Creates a cosmic rune at your position, only two can exist at a time. Invoking one rune transports you to the other. \
		Anyone with a star mark gets transported along with you."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "cosmic_rune"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	sound = 'sound/magic/forcewall.ogg'
	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 15 SECONDS

	invocation = "ST'R R'N'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// Storage for the first rune.
	var/first_rune
	/// Storage for the second rune.
	var/second_rune
	/// Rune removal effect.
	var/obj/effect/rune_remove_effect = /obj/effect/temp_visual/cosmic_rune_fade

/datum/spell/cosmic_rune/cast(list/targets, mob/user)
	. = ..()
	var/obj/effect/cosmic_rune/first_rune_resolved = locateUID(first_rune)
	var/obj/effect/cosmic_rune/second_rune_resolved = locateUID(second_rune)
	if(first_rune_resolved && second_rune_resolved)
		var/obj/effect/cosmic_rune/new_rune = new /obj/effect/cosmic_rune(get_turf(user))
		new rune_remove_effect(get_turf(first_rune_resolved))
		QDEL_NULL(first_rune_resolved)
		first_rune = second_rune_resolved.UID()
		second_rune = new_rune.UID()
		second_rune_resolved.link_rune(new_rune)
		new_rune.link_rune(second_rune_resolved)
		return
	if(!first_rune_resolved)
		first_rune = make_new_rune(get_turf(user), second_rune_resolved)
		return
	if(!second_rune_resolved)
		second_rune = make_new_rune(get_turf(user), first_rune_resolved)

/// Returns a weak reference to a new rune, linked to an existing rune if provided
/datum/spell/cosmic_rune/proc/make_new_rune(turf/target_turf, obj/effect/cosmic_rune/other_rune)
	var/obj/effect/cosmic_rune/new_rune = new /obj/effect/cosmic_rune(target_turf)
	if(other_rune)
		other_rune.link_rune(new_rune)
		new_rune.link_rune(other_rune)
	return new_rune.UID()

/// A rune that allows you to teleport to the location of a linked rune.
/obj/effect/cosmic_rune
	name = "cosmic rune"
	desc = "A strange rune, that can instantly transport people to another location."
	anchored = TRUE
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "cosmic_rune"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	plane = FLOOR_PLANE
	layer = SIGIL_LAYER
	/// The other rune this rune is linked with
	var/linked_rune
	/// Effect for when someone teleports
	var/obj/effect/rune_effect = /obj/effect/temp_visual/rune_light

/obj/effect/cosmic_rune/Initialize(mapload)
	. = ..()
	//qwertodo: maybe make invisible to admins

/obj/effect/cosmic_rune/attack_animal(mob/living/simple_animal/M)
	return attack_hand(M)

/obj/effect/cosmic_rune/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!linked_rune)
		to_chat(user, "<span class='warning'>There is no linked rune!</span>")
		fail_invoke()
		return
	if(!(user in get_turf(src)))
		to_chat(user, "<span class='warning'>You must be on the rune to teleport!</span>")
		fail_invoke()
		return
	if(user.has_status_effect(/datum/status_effect/star_mark))
		to_chat(user, "<span class='warning'>The mark blocks you from using the rune!</span>")
		fail_invoke()
		return
	invoke(user)

/// For invoking the rune
/obj/effect/cosmic_rune/proc/invoke(mob/living/user)
	var/obj/effect/cosmic_rune/linked_rune_resolved = locateUID(linked_rune)
	new rune_effect(get_turf(src))
	if(!(SEND_SIGNAL(user, COMSIG_MOVABLE_TELEPORTING, get_turf(linked_rune_resolved)) & COMPONENT_BLOCK_TELEPORT))
		user.forceMove(get_turf(linked_rune_resolved))
	for(var/mob/living/person_on_rune in get_turf(src))
		if(person_on_rune.has_status_effect(/datum/status_effect/star_mark))
			if(SEND_SIGNAL(person_on_rune, COMSIG_MOVABLE_TELEPORTING, get_turf(linked_rune_resolved)) & COMPONENT_BLOCK_TELEPORT)
				continue
			person_on_rune.forceMove(get_turf(linked_rune_resolved))
	playsound(src, 'sound/magic/cosmic_energy.ogg', 100, TRUE)
	playsound(user, 'sound/magic/cosmic_energy.ogg', 100, TRUE)
	new rune_effect(get_turf(linked_rune_resolved))

/// For if someone failed to invoke the rune
/obj/effect/cosmic_rune/proc/fail_invoke()
	visible_message("<span class='warning'>The rune pulses with a small flash of purple light, then returns to normal.</span>")
	var/oldcolor = rgb(255, 255, 255)
	color = rgb(150, 50, 200)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 0.5 SECONDS)

/// For linking a new rune
/obj/effect/cosmic_rune/proc/link_rune(new_rune)
	linked_rune = new_rune

/obj/effect/cosmic_rune/Destroy()
	var/obj/effect/cosmic_rune/linked_rune_resolved = locateUID(linked_rune)
	if(linked_rune_resolved)
		linked_rune_resolved.unlink_rune()
	return ..()

/// Used for unlinking the other rune if this rune gets destroyed
/obj/effect/cosmic_rune/proc/unlink_rune()
	linked_rune = null

/obj/effect/temp_visual/cosmic_rune_fade
	name = "cosmic rune"
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "cosmic_rune_fade"
	plane = FLOOR_PLANE
	layer = SIGIL_LAYER
	anchored = TRUE
	duration = 5

/obj/effect/temp_visual/cosmic_rune_fade/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/obj/antags/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance("cosmic", silicon_image, GLOB.silicon_mob_list)

/obj/effect/temp_visual/rune_light
	name = "cosmic rune"
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "cosmic_rune_light"
	plane = FLOOR_PLANE
	layer = SIGIL_LAYER
	anchored = TRUE
	duration = 5

/obj/effect/temp_visual/rune_light/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/obj/antags/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance("cosmic", silicon_image, GLOB.silicon_mob_list)

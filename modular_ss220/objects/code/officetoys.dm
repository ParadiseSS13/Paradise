#define HOURGLASS_STATES 7 // Remember to update if you change the sprite

// Hourglass
/obj/item/hourglass
	name = "hourglass"
	desc = "Nanotrasen patented gravity invariant hourglass. Guaranteed to flow perfectly under any conditions."
	icon = 'modular_ss220/objects/icons/officetoys.dmi'
	icon_state = "hourglass_idle"
	var/obj/effect/countdown/hourglass/countdown
	var/time = 1 MINUTES
	var/finish_time // So countdown doesn't need to fiddle with timers
	var/timing_id // If present we're timing
	var/hand_activated = TRUE

/obj/item/hourglass/Initialize(mapload)
	. = ..()
	countdown = new(src)

/obj/item/hourglass/attack_self(mob/user)
	. = ..()
	if(hand_activated)
		toggle(user)

/obj/item/hourglass/proc/toggle(mob/user)
	if(!timing_id)
		to_chat(user, span_notice("You flip [src]."))
		start()
		flick("hourglass_flip",src)
	else
		to_chat(user, span_notice("You stop [src].")) // Sand magically flows back because that's more convinient to use.
		stop()

/obj/item/hourglass/update_icon()
	icon_state = "hourglass_[timing_id ? "active" : "idle"]"
	return ..()

/obj/item/hourglass/proc/start()
	finish_time = world.time + time
	timing_id = addtimer(CALLBACK(src, PROC_REF(finish)), time, TIMER_STOPPABLE)
	countdown.start()
	timing_animation()

/obj/item/hourglass/proc/timing_animation()
	var/step_time = time / HOURGLASS_STATES
	animate(src, time = step_time, icon_state = "hourglass_1")
	for(var/i in 2 to HOURGLASS_STATES)
		animate(time = step_time, icon_state = "hourglass_[i]")

/obj/item/hourglass/proc/stop()
	if(timing_id)
		deltimer(timing_id)
		timing_id = null
	countdown.stop()
	finish_time = null
	animate(src)
	update_icon()

/obj/item/hourglass/proc/finish()
	visible_message(span_notice("[src] stops."))
	stop()

/obj/item/hourglass/Destroy()
	QDEL_NULL(countdown)
	. = ..()

// Admin events zone
/obj/item/hourglass/admin
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	hand_activated = FALSE

/obj/item/hourglass/admin/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(user.client && user.client.holder)
		toggle(user)

/obj/item/hourglass/admin/attack_ghost(mob/user)
	if(user.client && user.client.holder)
		toggle(user)

#undef HOURGLASS_STATES

// Hourglass countdown
/obj/effect/countdown/hourglass
	name = "hourglass countdown"

/obj/effect/countdown/hourglass/get_value()
	var/obj/item/hourglass/H = attached_to
	if(!istype(H))
		return
	else
		var/time_left = max(0, (H.finish_time - world.time) / 10)
		return round(time_left)

/*
* Office desk toys
*/
/obj/item/toy/desk
	name = "desk toy master"
	desc = "A object that does not exist. Parent Item."
	icon = 'modular_ss220/objects/icons/officetoys.dmi'
	layer = ABOVE_MOB_LAYER
	var/on = 0
	var/activation_sound = 'modular_ss220/objects/sound/officetoys/buttonclick.ogg'

/obj/item/toy/desk/update_icon_state()
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/toy/desk/attack_self(mob/user)
	on = !on
	if(activation_sound)
		playsound(src.loc, activation_sound, 75, 1)
	update_icon()
	return TRUE

/obj/item/toy/desk/examine(mob/user)
	. = ..()
	. += span_notice("<b>Alt-Click</b> to rotate.")

/obj/item/toy/desk/proc/rotate(mob/user)
	if(user.incapacitated())
		return
	dir = turn(dir, 270)
	return TRUE

/obj/item/toy/desk/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(!in_range(src, user))
		return
	else
		rotate(user)

/obj/item/toy/desk/officetoy
	name = "office toy"
	desc = "A generic microfusion powered office desk toy. Only generates magnetism and ennui."
	icon_state = "desktoy"

/obj/item/toy/desk/dippingbird
	name = "dipping bird toy"
	desc = "A ancient human bird idol, worshipped by clerks and desk jockeys."
	icon_state = "dippybird"

/obj/item/toy/desk/newtoncradle
	name = "\improper Newton's cradle"
	desc = "A ancient 21th century super-weapon model demonstrating that Sir Isaac Newton is the deadliest sonuvabitch in space."
	icon_state = "newtoncradle"
	var/datum/looping_sound/newtonballs/soundloop

/obj/item/toy/desk/newtoncradle/Initialize(mapload)
	. = ..()
	soundloop = new(list(src), FALSE)

/obj/item/toy/desk/newtoncradle/attack_self(mob/user)
	on = !on
	update_icon()
	if(on)
		soundloop.start()
	else
		soundloop.stop()

/obj/item/toy/desk/fan
	name = "office fan"
	desc = "Your greatest fan."
	icon_state = "fan"
	var/datum/looping_sound/fanblow/soundloop

/obj/item/toy/desk/fan/Initialize(mapload)
	. = ..()
	soundloop = new(list(src), FALSE)

/obj/item/toy/desk/fan/attack_self(mob/user)
	on = !on
	update_icon()
	if(on)
		soundloop.start()
	else
		soundloop.stop()

// Office toys spawner
/obj/effect/spawner/lootdrop/officetoys
	name = "office desk toy spawner"
	icon = 'modular_ss220/objects/icons/officetoys.dmi'
	icon_state = "spawner"
	loot = list(
		/obj/item/toy/desk/officetoy,
		/obj/item/toy/desk/dippingbird,
		/obj/item/toy/desk/newtoncradle,
		/obj/item/toy/desk/fan,
		/obj/item/hourglass
	)

// Item datums
/datum/looping_sound/fanblow
	start_sound = 'modular_ss220/objects/sound/officetoys/fan_start.ogg'
	start_length = 40
	mid_sounds = 'modular_ss220/objects/sound/officetoys/fan_mid1.ogg'
	mid_length = 23
	end_sound = 'modular_ss220/objects/sound/officetoys/fan_end.ogg'
	volume = 30

/datum/looping_sound/newtonballs
	start_sound = FALSE
	start_length = FALSE
	mid_sounds = 'modular_ss220/objects/sound/officetoys/newtoncradle_mid1.ogg'
	mid_length = 9
	end_sound = FALSE
	volume = 50

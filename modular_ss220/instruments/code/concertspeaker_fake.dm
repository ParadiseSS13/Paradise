/obj/structure/concertspeaker_fake
	name = "\proper концертная колонка"
	desc = "Концертная колонка для синронизации с концертной установкой."
	icon = 'modular_ss220/jukebox/icons/jukebox.dmi'
	icon_state = "concertspeaker_unanchored"
	base_icon_state = "concertspeaker"
	atom_say_verb = "states"
	anchored = FALSE
	var/active = FALSE
	density = FALSE
	layer = 2.5
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 25
	var/stat = 0
	var/code = 0
	var/frequency = 1400
	var/receiving = TRUE

/obj/structure/concertspeaker_fake/examine()
	. = ..()
	. += "<span class='notice'>Используйте гаечный ключ, чтобы разобрать для транспортировки и собрать для игры.</span>"

/obj/structure/concertspeaker_fake/update_icon_state()
	if(stat & (BROKEN))
		icon_state = "[base_icon_state]_broken"
	else
		icon_state = "[base_icon_state][active ? "_active" : null]"

/obj/structure/concertspeaker_fake/wrench_act(mob/living/user, obj/item/I)
	if(resistance_flags & INDESTRUCTIBLE)
		return

	if(!anchored && !isinspace())
		to_chat(user, span_notice("You secure [name] to the floor."))
		anchored = TRUE
		density = TRUE
		layer = 5
		update_icon()
	else if(anchored)
		to_chat(user, span_notice("You unsecure and disconnect [src]."))
		anchored = FALSE
		density = FALSE
		layer = 2.5
		update_icon()

	icon_state = "[base_icon_state][anchored ? null : "_unanchored"]"
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)

	return TRUE


/obj/structure/concertspeaker_fake/Initialize()
	. = ..()
	GLOB.remote_signalers |= src

/obj/structure/concertspeaker_fake/proc/signal_callback()
	active = !active
	update_icon()

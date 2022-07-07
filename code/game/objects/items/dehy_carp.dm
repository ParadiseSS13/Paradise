/*
 *	Dehydrated Carp
 *	Instant carp, just add water
 */

// Child of carpplushie because this should do everything the toy does and more
/obj/item/toy/carpplushie/dehy_carp
	var/mob/owner = null	// Carp doesn't attack owner, set when using in hand
	var/owned = 1	// Boolean, no owner to begin with


/obj/item/toy/carpplushie/dehy_carp/Destroy()
	owner = null
	return ..()

// Attack self
/obj/item/toy/carpplushie/dehy_carp/attack_self(mob/user as mob)
	src.add_fingerprint(user)	// Anyone can add their fingerprints to it with this
	if(owned)
		to_chat(user, span_notice("[src] stares up at you with friendly eyes."))
		owner = user
		owned = 0
	return ..()

/obj/item/toy/carpplushie/dehy_carp/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	if(volume >= 1)
		Swell()

/obj/item/toy/carpplushie/dehy_carp/afterattack(obj/O, mob/user,proximity)
	if(!proximity) return
	if(istype(O,/obj/structure/sink))
		to_chat(user, span_notice("You place [src] under a stream of water..."))
		user.drop_item()
		loc = get_turf(O)
		return Swell()
	..()

/obj/item/toy/carpplushie/dehy_carp/proc/Swell()
	desc = "It's growing!"
	visible_message(span_notice("[src] swells up!"))

	// Animation
	icon = 'icons/mob/carp.dmi'
	flick("carp_swell", src)
	// Wait for animation to end
	sleep(6)
	// Make space carp
	var/mob/living/simple_animal/hostile/carp/C = new /mob/living/simple_animal/hostile/carp(get_turf(src))
	// Make carp non-hostile to user, yes this means
	C.faction |= list("syndicate", "\ref[owner]")
	qdel(src)

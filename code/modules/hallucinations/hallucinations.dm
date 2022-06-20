GLOBAL_LIST_INIT(hallucinations, list(
	HALLUCINATE_MINOR = list(
		/obj/effect/hallucination/bolts = 10,
		/obj/effect/hallucination/fake_danger = 10,
		/obj/effect/hallucination/fake_health = 15,
		/obj/effect/hallucination/speech = 15,
		/obj/effect/hallucination/audio = 25,
		/obj/effect/hallucination/audio/localized = 25,
	),
	HALLUCINATE_MODERATE = list(
		/obj/effect/hallucination/delusion = 5,
		/obj/effect/hallucination/self_delusion = 5,
		/obj/effect/hallucination/bolts/moderate = 10,
		/obj/effect/hallucination/chasms = 10,
		/obj/effect/hallucination/fake_alert = 10,
		/obj/effect/hallucination/gunfire = 10,
		/obj/effect/hallucination/plasma_flood = 10,
		/obj/effect/hallucination/stunprodding = 10,
		/obj/effect/hallucination/delamination_alarm = 15,
		/obj/effect/hallucination/fake_item = 15,
		/obj/effect/hallucination/fake_weapon = 15,
		/obj/effect/hallucination/husks = 15,
	),
	HALLUCINATE_MAJOR = list(
		/obj/effect/hallucination/abduction = 10,
		/obj/effect/hallucination/assault = 10,
		/obj/effect/hallucination/terror_infestation = 10,
		/obj/effect/hallucination/loose_energy_ball = 10,
	)
))

/**
  * # Hallucination
  *
  * Base object for hallucinations. Contains basic behaviour to display an icon only to the target.
  */
/obj/effect/hallucination
	density = FALSE
	invisibility = INVISIBILITY_OBSERVER
	/// Duration in deciseconds. Can also be a list with the form [lower bound, upper bound] for a random duration.
	var/duration = 15 SECONDS
	/// Hallucination icon.
	var/hallucination_icon
	/// Hallucination icon state.
	var/hallucination_icon_state
	/// Hallucination override.
	var/hallucination_override = FALSE
	/// Hallucination layer.
	var/hallucination_layer = MOB_LAYER
	/// The mob that sees this hallucination.
	var/mob/living/carbon/target = null
	/// Lazy list of images created as part of the hallucination. Cleared on destruction.
	var/list/image/images = null

/obj/effect/hallucination/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	src.target = target
	if(hallucination_icon && hallucination_icon_state)
		var/image/I = image(hallucination_icon, hallucination_override ? src : get_turf(src), hallucination_icon_state)
		I.override = hallucination_override
		I.layer = hallucination_layer
		add_icon(I)
	// Lifetime
	if(islist(duration))
		duration = rand(duration[1], duration[2])
	QDEL_IN(src, duration)

/obj/effect/hallucination/Destroy()
	clear_icons()
	return ..()

/obj/effect/hallucination/examine(mob/user, infix, suffix)
	if(user != target)
		return list()

	// Overriding to not include call to [/proc/bicon] as it lags the client due to invalid image.
	. = list(
		"That's \a [name].",
		"<span class='whisper'>Something seems odd about this...</span>"
	)

/obj/effect/hallucination/singularity_pull()
	return

/obj/effect/hallucination/singularity_act()
	return

/**
  * Adds an image to the hallucination. Cleared on destruction.
  *
  * Arguments:
  * * I - The image to add.
  */
/obj/effect/hallucination/proc/add_icon(image/I)
	LAZYADD(images, I)
	target?.client?.images |= I

/**
  * Clears an image from the hallucination.
  *
  * Arguments:
  * * I - The image to clear.
  */
/obj/effect/hallucination/proc/clear_icon(image/I)
	LAZYREMOVE(images, I)
	target?.client?.images -= I
	qdel(I)

/**
  * Clears an image from the hallucination after a delay.
  *
  * Arguments:
  * * I - The image to clear.
  * * delay - Delay in deciseconds.
  */
/obj/effect/hallucination/proc/clear_icon_in(image/I, delay)
	addtimer(CALLBACK(src, .proc/clear_icon, I), delay)

/**
  * Clears all images from the hallucination.
  */
/obj/effect/hallucination/proc/clear_icons()
	if(!images)
		return
	target?.client?.images -= images
	QDEL_LIST(images)

/**
  * Plays a sound to the target only.
  *
  * Arguments:
  * * time - Deciseconds before the sound plays.
  * * source - The turf to play the sound from. Optional.
  * * snd - The sound file to play.
  * * volume - The sound volume.
  * * vary - Whether to randomize the sound's pitch.
  * * frequency - The sound's pitch.
  */
/obj/effect/hallucination/proc/play_sound_in(time, turf/source = null, snd, volume, vary, frequency)
	ASSERT(time >= 0)
	if(time == 0) // whatever
		target?.playsound_local(source, snd, volume, vary, frequency)
		return
	addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, snd, volume, vary, frequency), time)

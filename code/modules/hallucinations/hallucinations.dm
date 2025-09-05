GLOBAL_LIST_INIT(hallucinations, list(
	HALLUCINATE_MINOR = list(
		/obj/effect/hallucination/bolts = 10,
		/obj/effect/hallucination/fake_danger = 10,
		/obj/effect/hallucination/fake_health = 15,
		/obj/effect/hallucination/speech = 15,
		/obj/effect/hallucination/audio/localized = 25,
		/obj/effect/hallucination/trait_applier/medical_machinery = 25,
		/obj/effect/hallucination/examine_hallucination = 25,
	),
	HALLUCINATE_MODERATE = list(
		/obj/effect/hallucination/delusion = 5,
		/obj/effect/hallucination/fake_grenade/flashbang = 5,
		/obj/effect/hallucination/self_delusion = 5,
		/obj/effect/hallucination/bolts/moderate = 10,
		/obj/effect/hallucination/fake_alert = 10,
		/obj/effect/hallucination/fake_grenade = 10,
		/obj/effect/hallucination/gunfire = 10,
		/obj/effect/hallucination/plasma_flood = 10,
		/obj/effect/hallucination/stunprodding = 10,
		/obj/effect/hallucination/doppelganger = 10,
		/obj/effect/hallucination/fake_weapon = 15,
		/obj/effect/hallucination/ventpeek = 15,
	),
	HALLUCINATE_MAJOR = list(
		/obj/effect/hallucination/abduction = 10,
		/obj/effect/hallucination/assault = 10,
		/obj/effect/hallucination/fake_grenade/spawner = 10,
		/obj/effect/hallucination/loose_energy_ball = 10,
		/datum/hallucination_manager/xeno_pounce = 10,
		/datum/hallucination_manager/backrooms = 1,
		/datum/hallucination_manager/blind_rush = 1,
		/datum/hallucination_manager/waves = 2,
		/obj/effect/hallucination/blob = 10,
		/obj/effect/hallucination/sniper = 10
	)
))

/**
  * # Hallucination
  *
  * Base object for hallucinations. Contains basic behaviour to display an icon only to the target.
  */
/obj/effect/hallucination
	invisibility = INVISIBILITY_HIGH
	/// Duration in deciseconds. Can also be a list with the form [lower bound, upper bound] for a random duration.
	var/duration = 15 SECONDS
	/// Hallucination icon.
	var/hallucination_icon
	/// Hallucination icon state.
	var/hallucination_icon_state
	/// Hallucination override.
	var/hallucination_override = FALSE
	/// Hallucination color
	var/hallucination_color
	/// Hallucination layer.
	var/hallucination_layer = MOB_LAYER
	///Hallucination plane.
	var/hallucination_plane = AREA_PLANE
	/// The mob that sees this hallucination.
	var/mob/living/carbon/target = null
	/// Lazy list of images created as part of the hallucination. Cleared on destruction.
	var/list/image/images = null
	/// Should this hallucination delete itself
	var/should_delete = TRUE

/obj/effect/hallucination/Initialize(mapload, mob/living/carbon/hallucination_target)
	. = ..()
	if(QDELETED(hallucination_target))
		qdel(src)
		return
	target = hallucination_target
	if(hallucination_icon && hallucination_icon_state)
		var/image/I = image(hallucination_icon, hallucination_override ? src : get_turf(src), hallucination_icon_state)
		if(hallucination_color)
			I.color = hallucination_color
		I.override = hallucination_override
		I.layer = hallucination_layer
		I.plane = hallucination_plane
		add_icon(I)
	// Lifetime
	if(islist(duration))
		duration = rand(duration[1], duration[2])
	if(should_delete)
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
	addtimer(CALLBACK(src, PROC_REF(clear_icon), I), delay)

/**
  * Clears all images from the hallucination.
  */
/obj/effect/hallucination/proc/clear_icons()
	if(!images)
		return
	target?.client?.images -= images
	QDEL_LIST_CONTENTS(images)

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
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, playsound_local), source, snd, volume, vary, frequency), time)

/// Subtype that doesn't delete itself.
/// Mostly used for hallucination managers because they delete the hallucinations when required
/obj/effect/hallucination/no_delete
	should_delete = FALSE

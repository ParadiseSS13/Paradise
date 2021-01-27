#define HALLUCINATE_COOLDOWN_MIN 20 SECONDS
#define HALLUCINATE_COOLDOWN_MAX 50 SECONDS
/// This is multiplied with [/mob/var/hallucination] to determine the final cooldown. A higher hallucination value means shorter cooldown.
#define HALLUCINATE_COOLDOWN_FACTOR 0.03
/// Percentage defining the chance at which an hallucination may spawn past the cooldown.
#define HALLUCINATE_CHANCE 80
// Severity weights, should sum up to 100!
#define HALLUCINATE_MINOR_WEIGHT 60
#define HALLUCINATE_MODERATE_WEIGHT 30
#define HALLUCINATE_MAJOR_WEIGHT 10

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
		/obj/effect/hallucination/bolts/moderate = 10,
		/obj/effect/hallucination/chasms = 10,
		/obj/effect/hallucination/fake_alert = 10,
		/obj/effect/hallucination/fake_item = 15,
		/obj/effect/hallucination/fake_weapon = 15,
	),
	HALLUCINATE_MAJOR = list(
		/obj/effect/hallucination/terror_infestation = 10,
		/obj/effect/hallucination/abduction = 10,
	)
))

/mob/living/carbon
	/// The world.time after which the mob can hallucinate again.
	var/next_hallucination = 0
	#warn TODO: remove
	var/image/halimage
	var/image/halbody
	var/obj/halitem
	var/handling_hal = FALSE

/**
  * Called as part of [/mob/living/proc/handle_status_effects] to handle hallucinations.
  */
/mob/living/carbon/proc/handle_hallucinations()
	if(!hallucination || next_hallucination > world.time)
		return

	next_hallucination = world.time + rand(HALLUCINATE_COOLDOWN_MIN, HALLUCINATE_COOLDOWN_MAX) / (hallucination * HALLUCINATE_COOLDOWN_FACTOR)
	if(!prob(HALLUCINATE_CHANCE))
		return

	// Pick a severity
	var/severity = HALLUCINATE_MINOR
	switch(rand(100))
		if(0 to HALLUCINATE_MINOR_WEIGHT)
			severity = HALLUCINATE_MINOR
		if((HALLUCINATE_MINOR_WEIGHT + 1) to HALLUCINATE_MODERATE_WEIGHT)
			severity = HALLUCINATE_MODERATE
		if((HALLUCINATE_MINOR_WEIGHT + HALLUCINATE_MODERATE_WEIGHT + 1) to 100)
			severity = HALLUCINATE_MAJOR

	var/obj/effect/hallucination/H = hallucinate(pickweight(GLOB.hallucinations[severity]))
	next_hallucination += H.duration

/**
  * Spawns an hallucination for the mob.
  *
  * Arguments:
  * * H - The type path of the hallucination to spawn.
  */
/mob/living/carbon/proc/hallucinate(obj/effect/hallucination/H)
	ASSERT(ispath(H))
	add_attack_logs(null, src, "Received hallucination [H]")
	return new H(get_turf(src), src)

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

#undef HALLUCINATE_COOLDOWN_MIN
#undef HALLUCINATE_COOLDOWN_MAX
#undef HALLUCINATE_COOLDOWN_FACTOR
#undef HALLUCINATE_CHANCE
#undef HALLUCINATE_MINOR_WEIGHT
#undef HALLUCINATE_MODERATE_WEIGHT
#undef HALLUCINATE_MAJOR_WEIGHT

/**
  * # Hallucination - Audio
  *
  * Plays a random sound.
  */
/obj/effect/hallucination/audio
	duration = 0
	/// Associative list of sounds that may be played. Value corresponds to the volume.
	var/list/sounds = list(
		'sound/effects/explosionfar.ogg' = 50,
		'sound/effects/pray_chaplain.ogg' = 50,
		'sound/machines/alarm.ogg' = 100,
		'sound/magic/summon_guns.ogg' = 50,
	)

/obj/effect/hallucination/audio/Initialize(mapload, mob/living/carbon/target, atom/source = null)
	. = ..()
	var/snd = pick(sounds)
	target.playsound_local(source, snd, sounds[snd])

/**
  * # Hallucination - Audio (Localized)
  *
  * Plays a random sound at a random location around the target.
  */
/obj/effect/hallucination/audio/localized
	sounds = list(
		'sound/effects/explosion1.ogg' = 50,
		'sound/effects/explosion2.ogg' = 50,
		'sound/effects/glassbr1.ogg' = 50,
		'sound/effects/glassbr2.ogg' = 50,
		'sound/effects/glassbr3.ogg' = 50,
		'sound/machines/airlock_open.ogg' = 50,
	)

/obj/effect/hallucination/audio/localized/Initialize(mapload, mob/living/carbon/target)
	var/list/turfs = list()
	for(var/turf/T in range(world.view, target))
		turfs += T
	if(length(turfs))
		. = ..(mapload, target, pick(turfs))
	else
		. = ..(mapload, target)

/**
  * # Hallucination - Bolts
  *
  * Visually bolts a random number of airlocks around the target.
  */
/obj/effect/hallucination/bolts
	/// The maximum amount of airlocks to fake bolt.
	var/bolt_amount = 2
	/// The duration of fake bolt in deciseconds.
	var/bolt_duration = 10 SECONDS
	/// Lazy list of fake bolted airlocks. Key is airlock, value is bolt overlay.
	var/list/bolted

/obj/effect/hallucination/bolts/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/list/airlocks = list()
	for(var/obj/machinery/door/airlock/A in oview(world.view, target))
		airlocks += A

	var/num_bolted = 0
	while(bolt_amount && length(airlocks))
		var/obj/machinery/door/airlock/A = pick_n_take(airlocks)
		if(A.locked)
			continue
		addtimer(CALLBACK(src, PROC_REF(do_bolt), A), num_bolted++ * rand(5, 7))
		bolt_amount--

/**
  * Called in a timer to fake bolt the given airlock.
  *
  * Arguments:
  * * A - The airlock to fake bolt.
  */
/obj/effect/hallucination/bolts/proc/do_bolt(obj/machinery/door/airlock/A)
	if(QDELETED(A) || (A.locked && A.arePowerSystemsOn()) || A.operating || !A.density)
		return

	var/bolt_overlay = image(get_airlock_overlay("lights_bolts", A.overlays_file), A)
	add_icon(bolt_overlay)
	target?.playsound_local(get_turf(A), A.boltDown, 30, FALSE, 3)
	LAZYSET(bolted, A, bolt_overlay)
	// Timer and signal to turn it off (only one can happen)
	RegisterSignal(A, COMSIG_AIRLOCK_OPEN, PROC_REF(do_unbolt))
	addtimer(CALLBACK(src, PROC_REF(do_unbolt), A, bolt_overlay), bolt_duration)

/**
  * Called in a timer to fake unbolt the given airlock.
  *
  * Arguments:
  * * A - The airlock to fake unbolt.
  * * bolt_overlay - The bolt overlay image currently displayed on A.
  */
/obj/effect/hallucination/bolts/proc/do_unbolt(obj/machinery/door/airlock/A, image/bolt_overlay)
	if(QDELETED(A))
		return
	// bolt_overlay is null if this proc is called from the signal, so use the lookup table to retrieve it
	bolt_overlay = bolt_overlay || bolted[A]
	if(QDELETED(bolt_overlay))
		return
	UnregisterSignal(A, COMSIG_AIRLOCK_CLOSE)
	clear_icon(bolt_overlay)
	target?.playsound_local(get_turf(A), A.boltUp, 30, FALSE, 3)
	bolted[A] = null

/**
  * # Hallucination - Speech
  *
  * Causes the target to hear a fake message from a random mob around them.
  */
/obj/effect/hallucination/speech
	duration = 3 SECONDS
	/// List of messages that may be heard.
	var/list/messages = list(
		"I'm watching you...",
		"I'm going to kill you!",
		"Get out!",
		"Kchck-Chkck? Kchchck!",
		"Did you hear that?",
		"What did you do?",
		"Why?",
		"Give me that!",
		"Honk!",
		"Kill me!",
		"HELP!!",
		"RUN!!",
		"EI NATH!!",
		"O bidai nabora se'sma!",
		"I have the disk!",
	)

/obj/effect/hallucination/speech/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/list/mobs = list()
	for(var/mob/living/M in oview(world.view, target))
		mobs += M
	if(!length(mobs))
		return

	var/mob/living/M = pick(mobs)
	var/message = pick(messages + "[target]!")
	target.hear_say(message_to_multilingual(message, pick(target.languages)), speaker = M)
	// Speech bubble
	var/image/speech_bubble = image('icons/mob/talk.dmi', M, "[target.bubble_icon][say_test(message)]", layer = FLY_LAYER)
	speech_bubble.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	add_icon(speech_bubble)

/**
  * # Hallucination - Fake Danger
  *
  * Sends a random danger message to the target's chat.
  */
/obj/effect/hallucination/fake_danger
	duration = 0
	/// List of messages that may be displayed.
	var/list/messages = list(
		"The light burns you!",
		"You experience a stabbing sensation and your ears begin to ring...",
		"You get the feeling this is a bad idea.",
		"Your blood boils in your veins!",
		"You hear a loud buzz in your head, silencing your thoughts!",
		"You feel an awful sense of being watched...",
		"You suddenly feel very hot.",
		"You feel like you could blow up at any moment!",
		"You feel hotter than usual. Maybe you should lowe-wait, is that your hand melting?",
		"You hear battle shouts. The tramping of boots on cold metal. Screams of agony. The rush of venting air. Are you going insane?",
	)

/obj/effect/hallucination/fake_danger/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	to_chat(target, "<span class='userdanger'>[pick(messages)]</span>")

/**
  * # Hallucination - Fake Health
  *
  * Visually changes the target's health status to something it shouldn't be.
  */
/obj/effect/hallucination/fake_health
	duration = list(10 SECONDS, 25 SECONDS)

/obj/effect/hallucination/fake_health/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	if(target.health > HEALTH_THRESHOLD_CRIT)
		target.health_hud_override = pick(HEALTH_HUD_OVERRIDE_CRIT, HEALTH_HUD_OVERRIDE_DEAD)
	else
		target.health_hud_override = HEALTH_HUD_OVERRIDE_HEALTHY // You think you're fine, but you're not
	target.update_health_hud()

/obj/effect/hallucination/fake_health/Destroy()
	target?.health_hud_override = HEALTH_HUD_OVERRIDE_NONE
	target?.update_health_hud()
	return ..()

/**
 * # Hallucination - Examine Hallucination
 *
 * A generic hallucination that causes the target to see unique examine descriptions
 */
/obj/effect/hallucination/examine_hallucination
	var/trait_applied = TRAIT_EXAMINE_HALLUCINATING
	duration = list(40 SECONDS, 60 SECONDS)

/obj/effect/hallucination/examine_hallucination/Initialize(mapload, mob/living/carbon/hallucination_target)
	. = ..()
	ADD_TRAIT(hallucination_target, trait_applied, UNIQUE_TRAIT_SOURCE(src))

/obj/effect/hallucination/examine_hallucination/Destroy()
	REMOVE_TRAIT(target, trait_applied, UNIQUE_TRAIT_SOURCE(src))
	return ..()


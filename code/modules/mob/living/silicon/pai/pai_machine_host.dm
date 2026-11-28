// pAIs can be slotted into everyday machines and run them.
// The card sits in a hidden port on the machine's tile, so cooking and fridge code never touch it.
// The pAI sees and talks through the machine, and its face floats above it as a hologram.

/// How high the hologram floats above the machine
#define PAI_HOLOGRAM_Y 20
/// How big the hologram face is next to the card screen
#define PAI_HOLOGRAM_SCALE 1.5
/// How far speech text over the machine moves up to clear the hologram
#define PAI_RUNECHAT_RAISE 24
/// How see-through the face goes while its words are up, when they can't go above it
#define PAI_HOLOGRAM_TALK_ALPHA 70
/// How long it takes to pull the card back out
#define PAI_MACHINE_EJECT_TIME 3 SECONDS
/// How far the pAI's glow lights up the room
#define PAI_LIGHT_RANGE 3
/// How bright that glow is
#define PAI_LIGHT_POWER 1
/// The usual blue of a pAI
#define PAI_DEFAULT_MOOD "#66ccff"
/// Faces, screen covers and beams for machine screens
#define PAI_SCREEN_ICON 'icons/obj/pai_screen_faces.dmi'

/// Holds the card on the machine's tile. Never seen or touched.
/obj/effect/abstract/pai_port
	name = "pAI port"
	/// The machine this port belongs to
	var/obj/machinery/host
	/// The pAI running the machine
	var/datum/component/pai_host/owner

/obj/effect/abstract/pai_port/Destroy()
	host = null
	owner = null
	return ..()

/obj/effect/abstract/pai_port/HasProximity(atom/movable/AM)
	owner?.greet(AM)

/// The pAI's face, floating above the machine
/obj/effect/pai_hologram
	name = "pAI hologram"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai-happy"
	layer = ABOVE_ALL_MOB_LAYER
	appearance_flags = KEEP_APART | PIXEL_SCALE
	pixel_y = PAI_HOLOGRAM_Y
	alpha = 0
	/// The pAI running the machine
	var/datum/component/pai_host/owner

/obj/effect/pai_hologram/Initialize(mapload)
	. = ..()
	transform = matrix() * PAI_HOLOGRAM_SCALE
	set_mood(PAI_DEFAULT_MOOD)
	update_glow()

/obj/effect/pai_hologram/Destroy()
	owner = null
	return ..()

/// Alt-clicking the face pulls the pAI out, any other click goes to the machine
/obj/effect/pai_hologram/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, ALT_CLICK) || !owner)
		return ..()
	var/atom/host = owner.parent
	return host.Click(location, control, params)

/obj/effect/pai_hologram/DblClick(location, control, params)
	if(!owner)
		return ..()
	var/atom/host = owner.parent
	return host.DblClick(location, control, params)

/obj/effect/pai_hologram/AltClick(mob/user, modifiers)
	owner?.try_pull_out(user)

/// Tints the face and its glow to the pAI's mood
/obj/effect/pai_hologram/proc/set_mood(mood)
	remove_filter(list("glow_inner", "glow_outer"))
	add_filter("glow_inner", 1, list("type" = "drop_shadow", "x" = 0, "y" = 0, "size" = 1, "color" = "[mood]dd"))
	add_filter("glow_outer", 2, list("type" = "drop_shadow", "x" = 0, "y" = 0, "size" = 4, "color" = "[mood]66"))
	if(mood == PAI_DEFAULT_MOOD)
		color = null
		return
	// Keep the face's light and dark, swap its blue for the mood
	var/list/rgb = rgb2num(mood)
	var/r = rgb[1] / 255 * 1.3
	var/g = rgb[2] / 255 * 1.3
	var/b = rgb[3] / 255 * 1.3
	color = list(0.3 * r, 0.3 * g, 0.3 * b, 0.59 * r, 0.59 * g, 0.59 * b, 0.11 * r, 0.11 * g, 0.11 * b)

/// Light from a small screen up to the hologram, for machines whose screen is too small for a face
/obj/effect/pai_beam
	name = "pAI projection"
	icon = PAI_SCREEN_ICON
	layer = ABOVE_ALL_MOB_LAYER - 0.01
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = KEEP_APART | PIXEL_SCALE
	alpha = 0

/obj/effect/pai_beam/proc/update_glow(glowing = TRUE)
	overlays.Cut()
	if(glowing)
		overlays += emissive_appearance(icon, icon_state)

/// Lets the face glow in the dark
/obj/effect/pai_hologram/proc/update_glow(glowing = TRUE)
	overlays.Cut()
	if(glowing)
		overlays += emissive_appearance(icon, icon_state)

/datum/component/pai_host
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The card running this machine
	var/obj/item/paicard/card
	/// Where the card sits
	var/obj/effect/abstract/pai_port/port
	/// The face above the machine
	var/obj/effect/pai_hologram/hologram
	/// The light from a small screen up to the face, if the machine has one
	var/obj/effect/pai_beam/beam
	/// The machine's name before the pAI moved in
	var/old_name
	/// The name we gave it, so we don't undo a rename someone did since
	var/hosted_name
	/// Was the vendor already quiet before we took over its speaker
	var/vendor_was_quiet
	/// The vendor's own "thanks for shopping" line, muted while we run it
	var/vendor_reply
	/// Is the machine powered, last we checked
	var/powered = TRUE
	/// What the pAI says when someone walks up
	var/greeting
	/// Watches for people walking up
	var/datum/proximity_monitor/greeter
	/// Who we greeted and when we can greet them again
	var/list/greeted = list()
	COOLDOWN_DECLARE(greet_cooldown)
	/// The pAI's buttons for this machine
	var/list/datum/action/innate/pai_machine/actions = list()

/datum/component/pai_host/Initialize(obj/item/paicard/new_card, mob/user)
	if(!ismachinery(parent) || !istype(new_card) || !new_card.pai)
		return COMPONENT_INCOMPATIBLE
	var/obj/machinery/host = parent
	var/mob/living/silicon/pai/pai = new_card.pai
	card = new_card

	port = new(get_turf(host))
	port.host = host
	port.owner = src
	if(ismob(card.loc))
		var/mob/holder = card.loc
		holder.drop_item_to_ground(card)
	card.forceMove(port)

	hologram = new
	hologram.owner = src
	host.vis_contents += hologram
	// Small screens project the face up out of them
	var/list/screen = get_screen()
	if(screen?[8])
		hologram.pixel_x = screen[9]
		beam = new
		beam.icon_state = screen[8]
		host.vis_contents += beam
	old_name = host.name
	hosted_name = "[host.name] ([pai.name])"
	update_text_height()
	host.name = hosted_name
	// The pAI is the voice now, so the vendor stops its ads and its thank yous
	if(istype(host, /obj/machinery/economy/vending))
		var/obj/machinery/economy/vending/vendor = host
		vendor_was_quiet = vendor.shut_up
		vendor.shut_up = TRUE
		vendor_reply = vendor.vend_reply
		vendor.vend_reply = null

	RegisterSignal(host, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(host, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
	RegisterSignal(host, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_host_icon_update))
	RegisterSignal(host, COMSIG_MOVABLE_MOVED, PROC_REF(on_host_moved))
	RegisterSignal(card, COMSIG_MOVABLE_MOVED, PROC_REF(on_card_moved))
	RegisterSignal(card, COMSIG_PAICARD_EMOTION_CHANGED, PROC_REF(on_emotion_changed))
	RegisterSignal(pai, COMSIG_MOB_DEATH, PROC_REF(on_pai_death))
	RegisterSignal(pai, COMSIG_MOB_SAY, PROC_REF(on_pai_say))
	// Not every machine redraws when its power goes, so we check now and then
	START_PROCESSING(SSprocessing, src)

	for(var/action_type in subtypesof(/datum/action/innate/pai_machine))
		var/datum/action/innate/pai_machine/action = new action_type(card)
		action.host_component = src
		action.Grant(pai)
		actions += action
	var/datum/action/innate/pai_machine/use/use_button = locate() in actions
	use_button?.show_machine(host)

	pai.reset_perspective()
	pai.update_runechat_msg_location()
	add_attack_logs(user, pai, "Loaded into [host]")
	on_emotion_changed(card)
	boot()

/datum/component/pai_host/Destroy(force)
	var/obj/machinery/host = parent
	STOP_PROCESSING(SSprocessing, src)
	// Take the face off the screen
	UnregisterSignal(host, COMSIG_ATOM_UPDATE_OVERLAYS)
	if(!QDELETED(host))
		host.update_icon(UPDATE_OVERLAYS)
	if(host.name == hosted_name)
		host.name = old_name
	host.runechat_raise = initial(host.runechat_raise)
	if(istype(host, /obj/machinery/economy/vending))
		var/obj/machinery/economy/vending/vendor = host
		vendor.shut_up = vendor_was_quiet
		vendor.vend_reply = vendor_reply
	host.vis_contents -= hologram
	QDEL_NULL(hologram)
	if(beam)
		host.vis_contents -= beam
		QDEL_NULL(beam)
	QDEL_NULL(greeter)
	QDEL_LIST_CONTENTS(actions)

	if(card)
		UnregisterSignal(card, list(COMSIG_MOVABLE_MOVED, COMSIG_PAICARD_EMOTION_CHANGED))
		var/mob/living/silicon/pai/pai = card.pai
		if(card.loc == port)
			card.forceMove(get_turf(port) || get_turf(host))
		if(pai)
			UnregisterSignal(pai, list(COMSIG_MOB_DEATH, COMSIG_MOB_SAY))
			pai.reset_perspective()
			pai.update_runechat_msg_location()
		card = null
	QDEL_NULL(port)
	return ..()

/// The sci-fi bit: the screen flickers, text races past and the face blinks on
/datum/component/pai_host/proc/boot()
	var/obj/machinery/host = parent
	var/mob/living/silicon/pai/pai = card.pai
	playsound(host, 'sound/machines/terminal_on.ogg', 40, TRUE)
	host.visible_message(SPAN_NOTICE("[host]'s screen flickers. Lines of text race past, then a little face blinks into the air above it."))
	to_chat(pai, "<span class='notice'><tt>&gt; handshake with [old_name]... ok<br>&gt; mapping control bus... ok<br>&gt; personality matrix loaded.</tt></span>")
	to_chat(pai, SPAN_NOTICE("[boot_flavour()] Use <b>Use Machine</b> to work its controls, <b>Greeting</b> to welcome people and <b>Leave Machine</b> to pop back out."))

	// Flicker on, like an old projector warming up
	animate(hologram, alpha = 170, time = 1)
	animate(alpha = 0, time = 1)
	animate(alpha = 220, time = 2)
	animate(alpha = 40, time = 1)
	animate(alpha = 210, time = 3)
	// Gentle bob while it's on
	animate(hologram, pixel_y = PAI_HOLOGRAM_Y + 2, time = 1.5 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_y = PAI_HOLOGRAM_Y, time = 1.5 SECONDS, easing = SINE_EASING)
	if(beam)
		animate(beam, alpha = 255, time = 1)
		animate(alpha = 0, time = 1)
		animate(alpha = 200, time = 3)
		// Projector shimmer
		animate(beam, alpha = 180, time = 0.8 SECONDS, loop = -1, delay = 1 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(alpha = 245, time = 0.8 SECONDS, easing = SINE_EASING)
	// The room light stutters on with it
	port.set_light(0)
	addtimer(CALLBACK(src, PROC_REF(update_light), 0.6), 1)
	addtimer(CALLBACK(src, PROC_REF(update_light), 0), 2)
	addtimer(CALLBACK(src, PROC_REF(update_light), 1.4), 4)
	addtimer(CALLBACK(src, PROC_REF(update_light)), 8)
	addtimer(CALLBACK(src, PROC_REF(boot_chime)), 1 SECONDS)
	update_power()

/datum/component/pai_host/proc/boot_chime()
	if(!QDELETED(parent))
		playsound(parent, 'sound/machines/chime.ogg', 30, TRUE)

/// A line about the machine the pAI just moved into
/datum/component/pai_host/proc/boot_flavour()
	var/obj/machinery/host = parent
	if(istype(host, /obj/machinery/economy/vending))
		return "You settle in between the coils and the price list. The ad speaker is yours now."
	if(istype(host, /obj/machinery/kitchen_machine) || istype(host, /obj/machinery/cooker) || istype(host, /obj/machinery/cooking))
		return "Heating coils, a timer and a little bell. You feel oddly hungry."
	if(istype(host, /obj/machinery/smartfridge))
		return "Cold shelves hum around you. Everything here is labelled. You like that."
	if(istype(host, /obj/machinery/autolathe) || istype(host, /obj/machinery/r_n_d) || istype(host, /obj/machinery/biogenerator))
		return "Arms, nozzles and a hopper. You could make almost anything, given enough material."
	if(istype(host, /obj/machinery/computer/arcade) || istype(host, /obj/machinery/economy/arcade) || istype(host, /obj/machinery/economy/slot_machine))
		return "Blinking lights and a high score table. You already want to beat it."
	if(istype(host, /obj/machinery/disco))
		return "Speakers, strobes and a bass line waiting to drop."
	return "You spread out through [old_name]'s circuits."

/datum/component/pai_host/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/mob/living/silicon/pai/pai = card?.pai
	if(!pai)
		return
	examine_list += SPAN_NOTICE("[pai] is running it. [pai.p_their(TRUE)] face floats above the screen.")
	examine_list += SPAN_NOTICE("Alt-click its face to take the pAI card out.")

/datum/component/pai_host/proc/on_emotion_changed(obj/item/paicard/source)
	SIGNAL_HANDLER
	update_hologram()
	var/obj/machinery/host = parent
	host.update_icon(UPDATE_OVERLAYS)

/// The colour of the pAI's mood, from the face on its card
/datum/component/pai_host/proc/get_mood()
	// Same order as the card faces: happy, cat, very happy, plain, laugh, off, sad, angry, what
	var/static/list/moods = list(PAI_DEFAULT_MOOD, "#ff8ad8", "#6dffd2", PAI_DEFAULT_MOOD, "#ffd84a", "#4f6fb0", "#5a78ff", "#ff4a3d", "#c7a0ff")
	var/emotion = card?.current_emotion
	if(!emotion || emotion < 1 || emotion > length(moods))
		return PAI_DEFAULT_MOOD
	return moods[emotion]

/// Face, glow and room light to match the mood and the power
/datum/component/pai_host/proc/update_hologram()
	if(!hologram || !card)
		return
	var/mood = powered ? get_mood() : PAI_DEFAULT_MOOD
	hologram.icon_state = powered ? card.get_emotion_state() : "pai-off"
	hologram.set_mood(mood)
	hologram.update_glow(powered)
	hologram.alpha = powered ? 210 : 60
	if(beam)
		beam.color = mood
		beam.update_glow(powered)
		beam.invisibility = powered ? 0 : INVISIBILITY_ABSTRACT
	update_light()

/// Lights the room around the machine in the pAI's mood. Boost makes it brighter for a moment.
/datum/component/pai_host/proc/update_light(boost = 1)
	if(!port)
		return
	if(!powered || !boost)
		port.set_light(0)
		return
	var/sleepy = card?.current_emotion == 6
	port.set_light(PAI_LIGHT_RANGE, (sleepy ? 0.4 : PAI_LIGHT_POWER) * boost, get_mood())

/// Little pulse when the pAI talks, so you can tell who's speaking
/datum/component/pai_host/proc/on_pai_say(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(!hologram || !powered)
		return
	var/matrix/big = matrix() * (PAI_HOLOGRAM_SCALE * 1.12)
	animate(hologram, transform = big, time = 1, flags = ANIMATION_PARALLEL)
	animate(transform = matrix() * PAI_HOLOGRAM_SCALE, time = 2)
	// And the light brightens with each word
	update_light(1.6)
	addtimer(CALLBACK(src, PROC_REF(update_light)), 4, TIMER_UNIQUE | TIMER_OVERRIDE)
	// With a wall behind, the words sit on the face, so the face fades back while they're up
	var/obj/machinery/host = parent
	if(!host.runechat_raise)
		animate(hologram, alpha = PAI_HOLOGRAM_TALK_ALPHA, time = 2, flags = ANIMATION_PARALLEL)
		addtimer(CALLBACK(src, PROC_REF(end_talk_fade)), 6 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/component/pai_host/proc/end_talk_fade()
	if(hologram && powered)
		animate(hologram, alpha = 210, time = 5, flags = ANIMATION_PARALLEL)

/// Speech goes above the face, unless there's a wall right behind. Past a wall the player
/// can't see, and text drawn there gets lost in the dark, so then it stays at its usual height.
/datum/component/pai_host/proc/update_text_height()
	var/obj/machinery/host = parent
	var/turf/above = get_step(host, NORTH)
	host.runechat_raise = (above && !IS_OPAQUE_TURF(above)) ? PAI_RUNECHAT_RAISE : 0

/// Puts the pAI on the machine's own screen, where it has one
/datum/component/pai_host/proc/on_host_icon_update(datum/source, list/new_overlays)
	SIGNAL_HANDLER
	if(!powered || !card)
		return
	var/list/screen = get_screen()
	if(!screen)
		return
	var/obj/machinery/host = parent
	// Small screens light up like a projector lens instead
	if(screen[8])
		var/lens_state = "lens_[screen[8]]"
		new_overlays += mutable_appearance(PAI_SCREEN_ICON, lens_state, host.layer + 0.01, color = get_mood())
		new_overlays += emissive_appearance(PAI_SCREEN_ICON, lens_state)
		return
	if(screen[6])
		new_overlays += mutable_appearance(PAI_SCREEN_ICON, screen[6], host.layer + 0.01)
	var/face_state = "face_[screen[3]]_[clamp(card.current_emotion, 1, 9)]"
	var/mutable_appearance/face = mutable_appearance(PAI_SCREEN_ICON, face_state, host.layer + 0.02, color = screen[7])
	var/mutable_appearance/face_glow = emissive_appearance(PAI_SCREEN_ICON, face_state)
	face.pixel_x = screen[4]
	face.pixel_y = screen[5]
	face_glow.pixel_x = screen[4]
	face_glow.pixel_y = screen[5]
	new_overlays += face
	new_overlays += face_glow

/// Where the pAI shows on this machine's screen, found by its sprite. Each entry:
/// icon, sprite name start, face size, face x and y offset, screen cover, face colour,
/// and for screens too small for a face: the beam, and how far across the hologram moves to sit over it.
/datum/component/pai_host/proc/get_screen()
	var/static/list/screens = list(
		list('icons/obj/computer.dmi', "arcade", "large", 1, 1, "bg_arcade", "#6dff5f", null, 0),
		list('icons/obj/biogenerator.dmi', "biogen", "large", -5, 1, "bg_biogenerator", "#8ff0ff", null, 0),
		list('icons/obj/kitchen.dmi', "mw", "large", -5, -3, null, "#a8ecff", null, 0),
		list('icons/obj/vending.dmi', "smartfridge", null, 0, 0, null, null, "smartfridge", 7),
		list('icons/obj/stationobjs.dmi', "autolathe", null, 0, 0, null, null, "autolathe", -1),
		list('icons/obj/machines/research.dmi', "protolathe", null, 0, 0, null, null, "protolathe", 7),
	)
	var/obj/machinery/host = parent
	for(var/list/screen as anything in screens)
		if(host.icon == screen[1] && findtext(host.icon_state, screen[2]))
			return screen

/datum/component/pai_host/process()
	update_power()

/datum/component/pai_host/proc/update_power()
	var/obj/machinery/host = parent
	var/now_powered = host.is_operational()
	if(now_powered == powered || !hologram)
		return
	powered = now_powered
	update_hologram()
	host.update_icon(UPDATE_OVERLAYS)
	var/mob/living/silicon/pai/pai = card?.pai
	if(pai)
		to_chat(pai, powered ? SPAN_NOTICE("Power flows back into [host]. You blink back on.") : SPAN_WARNING("[host] loses power. You can still talk, but its controls are dead."))

/datum/component/pai_host/proc/on_host_moved(datum/source)
	SIGNAL_HANDLER
	port.forceMove(get_turf(parent))
	update_text_height()

/datum/component/pai_host/proc/on_card_moved(datum/source)
	SIGNAL_HANDLER
	// The card left some other way, like the pAI unfolding
	if(card.loc != port)
		qdel(src)

/datum/component/pai_host/proc/on_pai_death(datum/source)
	SIGNAL_HANDLER
	eject()

/datum/component/pai_host/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER
	var/obj/machinery/host = parent
	var/obj/item/paicard/old_card = card
	host.visible_message(SPAN_WARNING("[old_card] shoots out of [host] in a shower of sparks!"))
	eject(quiet = TRUE)
	old_card.emp_act(severity)

/datum/component/pai_host/proc/try_pull_out(mob/living/user)
	var/obj/machinery/host = parent
	if(!isliving(user) || user == card?.pai || user.incapacitated() || !user.Adjacent(host))
		return
	to_chat(user, SPAN_NOTICE("You start pulling [card] out of [host]..."))
	if(!do_after(user, PAI_MACHINE_EJECT_TIME, target = host) || QDELETED(src) || !card)
		return
	user.visible_message(SPAN_NOTICE("[user] pulls [card] out of [host]."), SPAN_NOTICE("You pull [card] out of [host]."))
	add_attack_logs(user, card.pai, "Pulled out of [host]")
	eject(quiet = TRUE)

/// Pops the card back out onto the floor
/datum/component/pai_host/proc/eject(quiet = FALSE)
	var/obj/machinery/host = parent
	if(!quiet)
		host.visible_message(SPAN_NOTICE("The face above [host] blinks out and [card] slides out of its port."))
	playsound(host, 'sound/machines/terminal_off.ogg', 40, TRUE)
	if(card?.pai)
		to_chat(card.pai, SPAN_NOTICE("You fold yourself back into your card."))
	qdel(src)

/// The pAI pressing the machine's buttons, like someone standing at it
/datum/component/pai_host/proc/use_machine(mob/living/silicon/pai/pai)
	var/obj/machinery/host = parent
	if(pai.stat != CONSCIOUS)
		return
	if(!host.is_operational())
		to_chat(pai, SPAN_WARNING("[host] has no power. Its controls won't answer."))
		return
	host.attack_hand(pai)

/datum/component/pai_host/proc/set_greeting(mob/living/silicon/pai/pai)
	var/new_greeting = tgui_input_text(pai, "What do you say when someone walks up? $name becomes their name. Leave it empty to stay quiet.", "Greeting", greeting, max_length = 100)
	if(QDELETED(src) || isnull(new_greeting))
		return
	greeting = new_greeting
	if(!length(greeting))
		greeting = null
		QDEL_NULL(greeter)
		to_chat(pai, SPAN_NOTICE("You won't greet anyone."))
		return
	if(!greeter)
		greeter = new(port, 1)
	to_chat(pai, SPAN_NOTICE("You'll greet people with: \"[greeting]\""))

/// Someone walked up, say hi if we haven't lately
/datum/component/pai_host/proc/greet(atom/movable/AM)
	if(!greeting || !ishuman(AM))
		return
	var/mob/living/carbon/human/visitor = AM
	if(!visitor.client || visitor.stat != CONSCIOUS)
		return
	var/mob/living/silicon/pai/pai = card?.pai
	if(!pai?.client || pai.stat != CONSCIOUS || pai.silence_time || !powered)
		return
	if(!COOLDOWN_FINISHED(src, greet_cooldown))
		return
	var/visitor_id = visitor.UID()
	if(greeted[visitor_id] > world.time)
		return
	greeted[visitor_id] = world.time + 3 MINUTES
	COOLDOWN_START(src, greet_cooldown, 10 SECONDS)
	INVOKE_ASYNC(pai, TYPE_PROC_REF(/mob, say), replacetext(greeting, "$name", visitor.name))

// The pAI's buttons while it runs a machine
/datum/action/innate/pai_machine
	background_icon_state = "bg_tech_blue"
	button_icon = 'icons/obj/aicards.dmi'
	/// The machine we're in
	var/datum/component/pai_host/host_component

/datum/action/innate/pai_machine/Destroy()
	host_component = null
	return ..()

/datum/action/innate/pai_machine/use
	name = "Use Machine"
	desc = "Work the controls of the machine you're running."

/// Shows the machine itself on the button
/datum/action/innate/pai_machine/use/proc/show_machine(obj/machinery/host)
	button_icon = host.icon
	button_icon_state = host.icon_state
	build_all_button_icons()

/datum/action/innate/pai_machine/use/Activate()
	host_component?.use_machine(owner)

/datum/action/innate/pai_machine/greeting
	name = "Greeting"
	desc = "Set what you say when someone walks up to your machine."
	button_icon_state = "pai-laugh"

/datum/action/innate/pai_machine/greeting/Activate()
	host_component?.set_greeting(owner)

/datum/action/innate/pai_machine/leave
	name = "Leave Machine"
	desc = "Fold back into your card and pop out of the machine."
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "exit_possession"

/datum/action/innate/pai_machine/leave/Activate()
	host_component?.eject()

#undef PAI_HOLOGRAM_Y
#undef PAI_HOLOGRAM_SCALE
#undef PAI_MACHINE_EJECT_TIME
#undef PAI_RUNECHAT_RAISE
#undef PAI_HOLOGRAM_TALK_ALPHA
#undef PAI_LIGHT_RANGE
#undef PAI_LIGHT_POWER
#undef PAI_DEFAULT_MOOD
#undef PAI_SCREEN_ICON

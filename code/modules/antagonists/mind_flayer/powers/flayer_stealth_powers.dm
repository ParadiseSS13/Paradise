/// Hack computer cameras to use them as a secret camera network
/datum/spell/flayer/surveilance_monitor
	name = "Camfecting Bug"
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	base_cooldown = 1 SECONDS // DEBUGGGG ONLY
	base_cost = 40
	stage = 2
	/// An internal camera bug
	var/obj/item/camera_bug/internal_camera
	/// How many computers can we have hacked at most?
	var/maximum_hacked_computers = 6
	/// List of references to the bugs inside the computers that we hacked
	var/list/active_bugs = list()

/datum/spell/flayer/surveilance_monitor/Destroy(force, ...)
	. = ..()
	active_bugs = null

/datum/spell/flayer/surveilance_monitor/AltClick(mob/user)
	if(!internal_camera)
		internal_camera = new /obj/item/camera_bug(user)
	internal_camera.ui_interact(user)

/datum/spell/flayer/surveilance_monitor/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.try_auto_target = FALSE
	C.allowed_type = /obj/machinery/computer
	C.range = 5
	return C

/datum/spell/flayer/surveilance_monitor/cast(list/targets, mob/user)
	if(!internal_camera)
		internal_camera = new /obj/item/camera_bug(user)
	if(length(active_bugs) >= maximum_hacked_computers)
		var/obj/item/wall_bug/to_destroy = tgui_input_list(user, "Choose an active camera to destroy.", "Maximum Camera Limit Reached.", active_bugs)
		if(to_destroy)
			active_bugs -= to_destroy
			QDEL_NULL(to_destroy)
		return TRUE

	var/obj/machinery/computer/target = targets[1]
	var/obj/item/wall_bug/computer_bug/nanobot = new /obj/item/wall_bug/computer_bug(target, flayer)
	nanobot.name += " - [get_area(target)]"
	nanobot.link_to_camera(internal_camera)
	active_bugs += nanobot
	flayer.send_swarm_message("Surveilance unit #[internal_camera.connections] deployed.")
	return TRUE

/datum/spell/flayer/self/voice_synthesizer
	name = "Enhanced Voice Mod"
	desc = "Name changer"
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	base_cooldown = 1 SECONDS
	base_cost = 75

/datum/spell/flayer/self/voice_synthesizer/cast(list/targets, mob/living/user)
	if(flayer.mimicking)
		flayer.mimicking = ""
		user.extra_message_range = 0
		to_chat(user, "<span class='notice'>We turn our vocal modulator to its original settings.</span>")
		return FALSE

	var/mimic_voice = tgui_input_text(user, "Enter a name to mimic.", "Mimic Voice", max_length = MAX_NAME_LEN)
	if(!mimic_voice)
		return FALSE

	flayer.mimicking = mimic_voice
	user.extra_message_range = 5 // Artificially extend the range of your voice to lure out victims
	flayer.send_swarm_message("We adjust the parameters of our voicebox to mimic <b>[mimic_voice]</b>.")
	flayer.send_swarm_message("Use this power again to return to your original voice.")
	return TRUE

/datum/spell/flayer/self/dump_coolant
	name = "Dump Coolant"
	desc = "Smoke for running away"
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	base_cooldown = 15 SECONDS
	base_cost = 100
	stage = 3 //TODO make this spell into like hot steam that burns the ops or smth cool like that

/datum/spell/flayer/self/dump_coolant/cast(list/targets, mob/living/user)
	var/datum/effect_system/smoke_spread/smoke = new()
	smoke.set_up(15, FALSE, user)
	smoke.start()

/datum/spell/flayer/self/skin_suit
	name = "Flesh Facsimile"
	desc = "Choose someone we see, and rearrange our surface to resemble theirs."
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	base_cooldown = 120 SECONDS
	base_cost = 100
	stage = 2

/datum/spell/flayer/self/skin_suit/cast(list/targets, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_MAGIC_DISGUISE) //TODO make this pass in a target you pick on screen


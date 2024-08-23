/// Hack computer cameras to use them as a secret camera network
/datum/spell/flayer/surveilance_monitor
	name = "Camfecting Bug"
	desc = "Cast on a computer to hack its webcam, then alt-click the spell to access all your hacked cameras."
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	base_cooldown = 1 SECONDS
	action_icon = 'icons/obj/device.dmi'
	action_icon_state = "camera_bug"
	base_cost = 50
	static_upgrade_increase = 15
	stage = 1
	max_level = 4
	upgrade_info = "Increase the amount of computers you can hack by 6."
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
	C.range = 6
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

/datum/spell/flayer/surveilance_monitor/on_purchase_upgrade()
	maximum_hacked_computers += 6

/datum/spell/flayer/self/voice_synthesizer
	name = "Enhanced Voice Mod"
	desc = "Configure your vocal modulator to sound like a different person, and amplify your voice slightly."
	action_icon = 'icons/obj/clothing/masks.dmi'
	action_icon_state = "voice_modulator"
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	base_cooldown = 1 SECONDS
	base_cost = 60

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

/datum/spell/flayer/self/vent_smog
	name = "Vent Smog"
	desc = "Vent the excess smog from our internals, disorienting and poisoning attackers."
	upgrade_info = "5 extra plumes of steam and 5 less seconds between exhalations."
	action_icon_state = "smoke"
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	base_cooldown = 30 SECONDS
	base_cost = 80
	stage = 3
	max_level = 3
	var/datum/reagents/smoke_reagents = null
	var/smoke_effects_spawned = 10

/datum/spell/flayer/self/vent_smog/cast(list/targets, mob/living/user)
	smoke_reagents = new /datum/reagents(smoke_effects_spawned * 4)
	smoke_reagents.add_reagent("toxin", smoke_effects_spawned * 2, null)
	var/datum/effect_system/smoke_spread/bad/smoke = new()
	user.smoke_delay = TRUE //Gives the user a second to get out before the steam affects them too
	smoke.set_up(smoke_effects_spawned, FALSE, user, null, smoke_reagents)
	smoke.start()

/datum/spell/flayer/self/vent_smog/on_purchase_upgrade()
	cooldown_handler.recharge_duration -= 5 SECONDS
	smoke_effects_spawned += 5

/datum/spell/flayer/skin_suit
	name = "Flesh Facsimile"
	desc = "Choose someone we see, and rearrange our surface to resemble theirs."
	action_icon_state = "genetic_poly"
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	base_cooldown = 120 SECONDS // Debug blah blah blah
	base_cost = 100
	static_upgrade_increase = 50
	stage = 2
	max_level = 3
	upgrade_info = "Decrease the time between castings by 30 seconds."

/datum/spell/flayer/skin_suit/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.include_user = FALSE
	T.allowed_type = /mob/living
	T.try_auto_target = TRUE
	T.click_radius = -1
	T.selection_type = SPELL_SELECTION_VIEW
	return T

/datum/spell/flayer/skin_suit/cast(list/targets, mob/living/user)
	var/mob/living/target = targets[1]
	user.apply_status_effect(STATUS_EFFECT_MAGIC_DISGUISE, target)

/datum/spell/flayer/skin_suit/on_purchase_upgrade()
	cooldown_handler.recharge_duration -= 30 SECONDS

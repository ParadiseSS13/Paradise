/// Hack computer cameras to use them as a secret camera network
/datum/spell/flayer/surveillance_monitor
	name = "Camfecting Bug"
	desc = "Allows us to cast a hack to a computers webcam. Alt-click the spell to access all your hacked computer webcams."
	power_type = FLAYER_PURCHASABLE_POWER
	category = FLAYER_CATEGORY_INTRUDER
	base_cooldown = 1 SECONDS
	action_icon = 'icons/obj/device.dmi'
	action_icon_state = "camera_bug"
	base_cost = 50
	static_upgrade_increase = 15
	max_level = 4
	upgrade_info = "Upgrades increase the amount of computers you can hack by 6."
	/// An internal camera bug
	var/obj/item/camera_bug/internal_camera
	/// How many computers can we have hacked at most?
	var/maximum_hacked_computers = 6
	/// List of references to the bugs inside the computers that we hacked
	var/list/active_bugs = list()

/datum/spell/flayer/surveillance_monitor/Destroy(force, ...)
	. = ..()
	QDEL_LIST_CONTENTS(active_bugs)
	if(!QDELETED(internal_camera))
		QDEL_NULL(internal_camera)

/datum/spell/flayer/surveillance_monitor/AltClick(mob/user)
	if(!internal_camera)
		internal_camera = new /obj/item/camera_bug(user)
		internal_camera.integrated_console.network = list("camera_bug[internal_camera.UID()]")
	internal_camera.ui_interact(user)

/datum/spell/flayer/surveillance_monitor/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.try_auto_target = FALSE
	C.allowed_type = /obj/machinery/computer
	C.range = 6
	return C

/datum/spell/flayer/surveillance_monitor/cast(list/targets, mob/user)
	if(!internal_camera)
		internal_camera = new /obj/item/camera_bug(user)

	if(length(active_bugs) >= maximum_hacked_computers)
		var/to_destroy = tgui_input_list(user, "Choose an active camera to destroy.", "Maximum Camera Limit Reached.", active_bugs)
		if(to_destroy)
			active_bugs -= to_destroy
			QDEL_NULL(to_destroy)
		return TRUE

	var/obj/machinery/computer/target = targets[1]
	var/obj/item/wall_bug/computer_bug/nanobot = new /obj/item/wall_bug/computer_bug(target, flayer)
	nanobot.name += " - [get_area(target)]"
	nanobot.link_to_camera(internal_camera)
	active_bugs += nanobot
	flayer.send_swarm_message("Surveillance unit #[internal_camera.connections] deployed.")
	return TRUE

/datum/spell/flayer/surveillance_monitor/on_apply()
	..()
	maximum_hacked_computers += 6

/datum/spell/flayer/self/voice_synthesizer
	name = "Enhanced Voice Mod"
	desc = "Allows for the configuration of our vocal modulator to sound like a different person. We can amplify our voice slightly as well."
	action_icon = 'icons/obj/clothing/masks.dmi'
	action_icon_state = "voice_modulator"
	category = FLAYER_CATEGORY_INTRUDER
	base_cooldown = 1 SECONDS
	base_cost = 40

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

/datum/spell/flayer/self/heat_sink
	name = "Heat Sink"
	desc = "Vent our used coolant to scald and disorient attackers."
	upgrade_info = "5 extra plumes of steam and 5 less seconds between casts."
	action_icon_state = "smoke"
	power_type = FLAYER_PURCHASABLE_POWER
	category = FLAYER_CATEGORY_INTRUDER
	base_cooldown = 30 SECONDS
	base_cost = 75
	stage = 3
	max_level = 3
	var/smoke_effects_spawned = 10

/datum/spell/flayer/self/heat_sink/cast(list/targets, mob/living/user)
	var/datum/effect_system/smoke_spread/steam/smoke = new()
	user.smoke_delay = TRUE //Gives the user a second to get out before the steam affects them too
	smoke.set_up(smoke_effects_spawned, FALSE, user, null)
	smoke.start()

/datum/spell/flayer/self/heat_sink/on_apply()
	..()
	cooldown_handler.recharge_duration -= 5 SECONDS
	smoke_effects_spawned += 5

/datum/spell/flayer/skin_suit
	name = "Flesh Facsimile"
	desc = "Allows us to rearrange our surface to resemble someone we see."
	action_icon_state = "genetic_poly"
	power_type = FLAYER_PURCHASABLE_POWER
	category = FLAYER_CATEGORY_INTRUDER
	base_cooldown = 120 SECONDS
	base_cost = 80
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

/datum/spell/flayer/skin_suit/spell_purchased()
	flayer.add_ability(new /datum/spell/flayer/self/voice_synthesizer)

/datum/spell/flayer/skin_suit/on_apply()
	..()
	cooldown_handler.recharge_duration -= 30 SECONDS

/datum/spell/flayer/skin_suit/Destroy(force, ...)
	flayer?.remove_ability(/datum/spell/flayer/self/voice_synthesizer)
	return ..()

/// After a 7 second channel time you can emag a borg
/datum/spell/flayer/self/override_key
	name = "Silicon Administrative Access"
	desc = "Allows us to charge our hand with a mass of nanites that hijacks cyborgs lawsets."
	action_icon_state = "magnet" // Uhhhhhhhhhhhhhhhhhhhhhhhhhhh
	power_type = FLAYER_PURCHASABLE_POWER
	category = FLAYER_CATEGORY_INTRUDER
	base_cooldown = 2 SECONDS //The cast time is going to be the main limiting factor, not cooldown
	base_cost = 150
	stage = 3
	var/hand_type = /obj/item/melee/swarm_hand

/datum/spell/flayer/self/override_key/cast(list/targets, mob/user)
	if(istype(user.l_hand, hand_type))
		qdel(user.l_hand)
		flayer.send_swarm_message("We dissipate the nanites.")
		return
	if(istype(user.r_hand, hand_type))
		qdel(user.r_hand)
		flayer.send_swarm_message("We dissipate the nanites.")
		return

	var/obj/item/melee/swarm_hand/funny_hand = new hand_type
	if(!user.put_in_hands(funny_hand))
		flayer.send_swarm_message("Our hands are currently full.")
		qdel(funny_hand)
		return

/obj/item/melee/swarm_hand
	name = "Nanite Mass"
	desc = "Will attempt to convert any cyborg you touch into a loyal member of the hive after a 7 second delay."
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	color = COLOR_BLACK
	flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	new_attack_chain = TRUE
	var/conversion_time = 7 SECONDS

/obj/item/melee/swarm_hand/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK

	if(!isrobot(target))
		to_chat(user, "<span class='warning'>[src] will have no effect against this target!</span>")
		return FINISH_ATTACK

	var/mob/living/silicon/robot/borg = target
	borg.visible_message(
		"<span class='danger'>[user] puts [user.p_their()] hands on [borg] and begins transferring energy!</span>",
		"<span class='userdanger'>[user] puts [user.p_their()] hands on you and begins transferring energy!</span>")
	if(borg.emagged || !borg.is_emaggable)
		to_chat(user, "<span class='notice'>Your override attempt fails before it can even begin.</span>")
		qdel(src)
		return FINISH_ATTACK

	if(!do_mob(user, borg, conversion_time, hidden = TRUE))
		to_chat(user, "<span class='notice'>Your concentration breaks.</span>")
		qdel(src)
		return FINISH_ATTACK

	to_chat(user, "<span class='notice'>The mass of swarms vanish into the cyborg's internals. Success.</span>")
	INVOKE_ASYNC(src, PROC_REF(emag_borg), borg, user)
	qdel(src)
	return FINISH_ATTACK

/obj/item/melee/swarm_hand/proc/emag_borg(mob/living/silicon/robot/borg, mob/living/user)
	if(QDELETED(borg) || QDELETED(user))
		return

	borg.make_mindflayer_robot(user)
	return TRUE

/datum/spell/flayer/self/extraction
	name = "Nanite Portal Generator"
	desc = "Allows us to use our nanites to create an extraction portal."
	action_icon = 'icons/obj/lighting.dmi'
	action_icon_state = "flayer_telepad_base"
	power_type = FLAYER_PURCHASABLE_POWER
	base_cooldown = 2 SECONDS
	var/used = FALSE

/datum/spell/flayer/self/extraction/cast(list/targets, mob/user)
	if(used)
		to_chat(user, "<span class='warning'>You have already attempted to create a portal generator!</span>")
		return
	flayer.prepare_exfiltration(user, /obj/item/wormhole_jaunter/extraction/mindflayer)
	used = TRUE

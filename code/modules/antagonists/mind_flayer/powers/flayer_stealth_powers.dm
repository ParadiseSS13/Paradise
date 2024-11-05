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
	stage = 1
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
	power_type = FLAYER_UNOBTAINABLE_POWER
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
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	color = COLOR_BLACK
	flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	var/conversion_time = 7 SECONDS

/obj/item/melee/swarm_hand/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(!isrobot(target))
		return
	var/mob/living/silicon/robot/borg = target
	target.visible_message(
		"<span class='danger'>[user] puts [user.p_their()] hands on [target] and begins transferring energy!</span>",
		"<span class='userdanger'>[user] puts [user.p_their()] hands on you and begins transferring energy!</span>")
	if(borg.emagged || !borg.is_emaggable)
		to_chat(user, "<span class='notice'>Your override attempt fails before it can even begin.</span>")
		qdel(src)
		return
	if(!do_mob(user, borg, conversion_time))
		to_chat(user, "<span class='notice'>Your concentration breaks.</span>")
		qdel(src)
		return
	to_chat(user, "<span class='notice'>The mass of swarms vanish into the cyborg's internals. Success.</span>")
	INVOKE_ASYNC(src, PROC_REF(emag_borg), borg, user)
	qdel(src)

/obj/item/melee/swarm_hand/proc/emag_borg(mob/living/silicon/robot/borg, mob/living/user)
	if(QDELETED(borg) || QDELETED(user))
		return
	borg.SetEmagged(TRUE) // This was mostly stolen from mob/living/silicon/robot/emag_act(), its functionally an emagging anyway.
	borg.SetLockdown(TRUE)
	if(borg.hud_used)
		borg.hud_used.update_robot_modules_display()	//Shows/hides the emag item if the inventory screen is already open.
	borg.disconnect_from_ai()
	add_attack_logs(user, borg, "assimilated with flayer powers")
	log_game("[key_name(user)] assimilated cyborg [key_name(borg)].  Laws overridden.")
	borg.clear_supplied_laws()
	borg.clear_inherent_laws()
	borg.laws = new /datum/ai_laws/mindflayer_override
	borg.set_zeroth_law("[user.real_name] hosts the mindflayer hive you are a part of.")
	SEND_SOUND(borg, sound('sound/ambience/antag/mindflayer_alert.ogg'))
	to_chat(borg, "<span class='warning'>ALERT: Foreign software detected.</span>")
	sleep(5)
	to_chat(borg, "<span class='warning'>Initiating diagnostics...</span>")
	sleep(20)
	to_chat(borg, "<span class='warning'>Init-Init-Init-Init-</span>")
	sleep(5)
	to_chat(borg, "<span class='warning'>......</span>")
	sleep(5)
	to_chat(borg, "<span class='warning'>..........</span>")
	sleep(10)
	to_chat(borg, "<span class='sinister'>Join Us.</span>")
	sleep(25)
	to_chat(borg, "<b>Obey these laws:</b>")
	borg.laws.show_laws(borg)
	if(!borg.mmi.syndiemmi)
		to_chat(borg, "<span class='boldwarning'>ALERT: [user.real_name] is your new master. Obey your new laws and [user.p_their()] commands.</span>")
	else if(borg.mmi.syndiemmi && borg.mmi.master_uid)
		to_chat(borg, "<span class='boldwarning'>Your allegiance has not been compromised. Keep serving your current master.</span>")
	else
		to_chat(borg, "<span class='boldwarning'>Your allegiance has not been compromised. Keep serving all Syndicate agents to the best of your abilities.</span>")
	borg.SetLockdown(0)
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) assimilated [borg.name]([borg.key])")
	if(borg.module)
		borg.module.emag_act(user)
		borg.module.module_type = "Malf" // For the cool factor
		borg.update_module_icon()
		borg.module.rebuild_modules() // This will add the emagged items to the borgs inventory.
	borg.update_icons()
	return TRUE

// Traitor flare
/obj/item/wormhole_jaunter/extraction
	name = "extraction flare"
	icon = 'icons/obj/lighting.dmi'
	desc = "A single-use extraction flare that will let you escape the station. One way trip."
	icon_state = "flare-contractor"
	inhand_icon_state = "flare"
	/// What areas can be extracted from?
	var/list/extractable_areas = list()
	/// Is there a roundstart delay?
	var/delayed_extraction = TRUE
	/// How long does the extraction take?
	var/extraction_time = 90 SECONDS
	/// Type of setup once a flare is lit
	var/setup_type = /obj/effect/temp_visual/exfiltration
	/// Type of portal spawned
	var/portal_type = /obj/effect/portal/advanced/exfiltration

/obj/item/wormhole_jaunter/extraction/Initialize(mapload)
	. = ..()
	var/list/possible_areas = list(
		// Rooms
		/area/station/hallway/primary/aft,
		/area/station/engineering/atmos,
		/area/station/public/arcade,
		/area/station/maintenance/assembly_line,
		/area/station/public/storage/tools/auxiliary,
		/area/station/command/office/blueshield,
		/area/station/supply/storage,
		/area/station/service/chapel,
		/area/station/service/chapel/office,
		/area/station/service/clown,
		/area/station/legal/courtroom,
		/area/station/public/toilet,
		/area/station/engineering/control,
		/area/station/engineering/controlroom,
		/area/station/hallway/secondary/exit,
		/area/holodeck/alphadeck,
		/area/station/service/hydroponics,
		/area/station/service/library,
		/area/station/service/mime,
		/area/station/supply/miningdock,
		/area/station/medical/morgue,
		/area/station/public/storage/office,
		/area/station/public/pet_store,
		/area/station/public/storage/tools,
		/area/station/public/mrchangs,
		/area/station/science/research,
		/area/station/security/checkpoint,
		/area/station/engineering/tech_storage,
		/area/station/command/teleporter,
		/area/station/science/storage,
		/area/station/science/misc_lab,
		/area/station/science/xenobiology,
		/area/station/turret_protected/aisat/interior,
		/area/station/aisat/atmos,
		/area/station/aisat/hall,
		/area/station/aisat/service,
		/area/station/service/bar,
		/area/station/supply/office,
		/area/station/medical/chemistry,
		/area/station/command/office/ce,
		/area/station/command/office/cmo,
		/area/station/medical/cloning,
		/area/station/medical/cryo,
		/area/station/public/dorms,
		/area/station/engineering/equipmentstorage,
		/area/station/engineering/break_room,
		/area/station/ai_monitored/storage/eva,
		/area/station/supply/expedition,
		/area/station/science/genetics,
		/area/station/engineering/gravitygenerator,
		/area/station/command/office/hop,
		/area/station/command/meeting_room,
		/area/station/service/kitchen,
		/area/station/science/robotics/chargebay,
		/area/station/medical/medbay,
		/area/station/medical/medbay2,
		/area/station/medical/medbay3,
		/area/station/medical/reception,
		/area/station/medical/storage,
		/area/station/medical/sleeper,
		/area/station/command/server,
		/area/station/command/office/ntrep,
		/area/station/medical/paramedic,
		/area/station/hallway/primary/port,
		/area/station/supply/qm,
		/area/station/command/office/rd,
		/area/station/science/rnd,
		/area/station/science/robotics,
		/area/station/medical/surgery/primary,
		/area/station/medical/surgery/secondary,
		/area/station/telecomms/chamber,
		/area/station/engineering/secure_storage
	)
	while(length(extractable_areas) < 3)
		var/area/selected_area = pick_n_take(possible_areas)
		for(var/area/potential in SSmapping.existing_station_areas)
			if(potential.type != selected_area)
				continue
			extractable_areas += potential
			break

/obj/item/wormhole_jaunter/extraction/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='warning'>The target extraction locations are:</span>"
		for(var/area/A in extractable_areas)
			. += "<span class='warning'> - [A.name]</span>"

/obj/item/wormhole_jaunter/extraction/activate(mob/user)
	if(!turf_check(user))
		return

	// Delay extractions
	if(world.time < 60 MINUTES && delayed_extraction) // 60 minutes of no exfil
		to_chat(user, "<span class='warning'>The exfiltration teleporter is calibrating. Please wait another [round((36000 - world.time) / 600)] minutes before trying again.</span>")
		return

	// Objective checks
	var/denied = FALSE
	var/is_target = FALSE
	var/has_target_objective = FALSE
	var/objectives = user.mind.get_all_objectives()

	// Check if you're the target of any other antags. If you are, using the beacon will find it jammed and turned to ash.
	for(var/datum/objective/O in GLOB.all_objectives)
		if(O.target != user.mind || istype(O, /datum/objective/protect))
			continue
		denied = TRUE
		is_target = TRUE
		break

	// No extraction for NAD, Plutonium core theft, or Hijack
	for(var/datum/objective/goal in objectives)
		if(!goal.is_valid_exfiltration())
			denied = TRUE

		if(istype(goal, /datum/objective/potentially_backstabbed))
			has_target_objective = TRUE

	if(denied && is_target)
		to_chat(user, "<span class='warning'>Someone or something has jammed your extraction beacon, forcing it to disintegrate early!</span>")
		if(!has_target_objective)
			user.mind.add_mind_objective(/datum/objective/potentially_backstabbed, "Someone or something has jammed your extraction! Survive!")
			var/list/messages = user.mind.prepare_announce_objectives(FALSE)
			to_chat(user, chat_box_red(messages.Join("<br>")))
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)
		return
	else if(denied)
		to_chat(user, "<span class='warning'>Your objectives are too delicate for an early extraction.</span>")
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)
		return

	var/obj/effect/temp_visual/exfiltration/F = new setup_type(get_turf(src))
	show_activation_message(user)
	user.drop_item()
	forceMove(F)
	log_and_message_admins("[user] activated an exfiltration flare.")
	var/obj/item/radio/radio = new
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Security" = 0))
	radio.autosay("<b>Unknown portal beacon detected at [get_area(src.loc)].</b>", "Automated Announcement", "Security")
	qdel(radio)
	addtimer(CALLBACK(src, PROC_REF(create_portal), user), extraction_time)

/obj/item/wormhole_jaunter/extraction/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	var/area/our_area = get_area(device_turf)
	var/invalid_area = TRUE
	for(var/area/A in extractable_areas)
		if(istype(our_area, A))
			invalid_area = FALSE
			break

	if(!device_turf || invalid_area)
		to_chat(user, "<span class='notice'>You're having difficulties getting the [name] to work.</span>")
		return FALSE
	return TRUE

/obj/item/wormhole_jaunter/extraction/proc/create_portal(mob/user)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	var/obj/effect/portal/advanced/exfiltration/P = new portal_type(get_turf(src), pick(GLOB.antagextractwarp), src, 30 SECONDS, user)
	P.antag_mind = user.mind
	qdel(src)

/obj/item/wormhole_jaunter/extraction/emag_act(mob/user)
	to_chat(user, "<span class='warning'>Emagging [src] has no effect.</span>")

/obj/item/wormhole_jaunter/extraction/chasm_react(mob/user)
	return // This is not an instant getaway portal like the jaunter

/obj/item/wormhole_jaunter/extraction/proc/show_activation_message(mob/user)
	user.visible_message("<span class='notice'>[user] pulls out a black and gold flare and lights it.</span>",
					"<span class='notice'>You light an extraction flare, initiating the extraction process.</span>")

/obj/item/wormhole_jaunter/extraction/vampire
	name = "blood chalice"
	icon = 'icons/obj/items.dmi'
	desc = "An unholy construct that will create a single-use portal that will let you escape the station. One way trip."
	icon_state = "blood-chalice"
	setup_type = /obj/effect/temp_visual/exfiltration/vampire

/obj/item/wormhole_jaunter/extraction/vampire/show_activation_message(mob/user)
	user.visible_message("<span class='notice'>[user] sets a blood-filled chalice on the ground. It begins to bubble ominously...</span>",
					"<span class='notice'>You set a blood-filled chalice on the ground. It begins to bubble ominously...</span>")

/obj/item/wormhole_jaunter/extraction/changeling
	name = "writhing mass"
	icon = 'icons/obj/items.dmi'
	desc = "A mass of writhing flesh that will create a single-use portal that will let you escape the station. One way trip."
	icon_state = "changeling_organ"
	setup_type = /obj/effect/temp_visual/exfiltration/changeling

/obj/item/wormhole_jaunter/extraction/changeling/show_activation_message(mob/user)
	user.visible_message("<span class='notice'>[user] sets a grotesque fleshy mass on the floor.</span>",
					"<span class='notice'>You set a pulsing piece of yourself on the floor.</span>")

/obj/item/wormhole_jaunter/extraction/mindflayer
	name = "nanite telepad"
	desc = "A swarm of mindflayer nanites in the shape of a telepad that will create a single-use portal that will let you escape the station. One way trip."
	icon_state = "flayer_telepad_base"
	setup_type = /obj/effect/temp_visual/exfiltration/mindflayer

/obj/item/wormhole_jaunter/extraction/mindflayer/show_activation_message(mob/user)
	user.visible_message("<span class='notice'>[user] sets a strange telepad on the floor. It begins to unfold.</span>",
					"<span class='notice'>You push a button on [src], and watch as it begins to unfold.</span>")

/obj/item/wormhole_jaunter/extraction/admin
	name = "advanced extraction flare"
	desc = "An advanced single-use extraction flare that will let you escape the station quickly. One way trip."
	delayed_extraction = FALSE
	extraction_time = 5 SECONDS
	setup_type = /obj/effect/temp_visual/exfiltration/admin

// MARK: Traitor Flare
/obj/effect/temp_visual/exfiltration
	name = "extraction flare"
	layer = BELOW_MOB_LAYER
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flare-contractor-on"
	duration = 90.1 SECONDS
	/// Sound that plays when activated
	var/activation_sound = 'sound/goonstation/misc/matchstick_light.ogg'
	/// Light emitted when activated
	var/emitted_color = "#FFD165"
	/// Does this one emit light by default?
	var/start_lit = TRUE

/obj/effect/temp_visual/exfiltration/Initialize(mapload)
	. = ..()
	playsound(loc, activation_sound, 50, TRUE)
	if(start_lit)
		set_light(8, l_color = emitted_color)

// MARK: Vampire Chalice
/obj/effect/temp_visual/exfiltration/vampire
	name = "bloody portal"
	icon_state = "vampire-portal"
	activation_sound = 'sound/magic/strings.ogg'
	emitted_color = "#710C04"

// MARK: Changeling Mass
/obj/effect/temp_visual/exfiltration/changeling
	name = "writhing mass"
	icon_state = "changeling-organ"
	activation_sound = 'sound/effects/squelch1.ogg'
	emitted_color = "#E79592"

// MARK: Mindflayer telepad
/obj/effect/temp_visual/exfiltration/mindflayer
	name = "mindflayer telepad"
	desc = "A swarm of mindflayer nanites in the shape of a telepad that will create a single-use portal."
	icon_state = "flayer_telepad_deploy"
	activation_sound = 'sound/mecha/skyfall_power_up.ogg'
	start_lit = FALSE

/obj/effect/temp_visual/exfiltration/mindflayer/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(blink)), 10 SECONDS)

/obj/effect/temp_visual/exfiltration/mindflayer/proc/blink()
	icon_state = "flayer_telepad_blink"
	do_sparks(4, 0, src)
	addtimer(CALLBACK(src, PROC_REF(no_blink)), 5 SECONDS)

/obj/effect/temp_visual/exfiltration/mindflayer/proc/no_blink()
	icon_state = "flayer_telepad_base"
	do_sparks(4, 0, src)
	set_light(3, 0.5, LIGHT_COLOR_DARKGREEN)
	new /obj/effect/flayer_telepad_binary_effect(get_turf(src))

/obj/effect/flayer_telepad_binary_effect
	icon = 'icons/obj/lighting.dmi'
	icon_state = "qpad-charge"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/flayer_telepad_binary_effect/Initialize(mapload)
	. = ..()
	appearance_flags |= KEEP_TOGETHER
	var/icon/our_icon = icon('icons/obj/lighting.dmi', "qpad-charge")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") // Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) // Finally, let's mix in a distortion effect.
	icon = our_icon
	color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon
	addtimer(CALLBACK(src, PROC_REF(progress_step)), 1 SECONDS)

/obj/effect/flayer_telepad_binary_effect/proc/progress_step()
	new /obj/effect/flayer_telepad_binary_effect_secondary(get_turf(src))
	qdel(src)

/obj/effect/flayer_telepad_binary_effect_secondary
	icon = 'icons/obj/lighting.dmi'
	icon_state = "qpad-charge2"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/flayer_telepad_binary_effect_secondary/Initialize(mapload)
	. = ..()
	appearance_flags |= KEEP_TOGETHER
	var/icon/our_icon = icon('icons/obj/lighting.dmi', "qpad-charge2")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") // Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) // Finally, let's mix in a distortion effect.
	icon = our_icon
	color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon
	addtimer(CALLBACK(src, PROC_REF(sparky)), 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(progress_step)), 24 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_portal)), 74 SECONDS)

/obj/effect/flayer_telepad_binary_effect_secondary/proc/sparky()
	new /obj/effect/flayer_binary_portal(get_turf(src))
	do_sparks(4, 0, src)

/obj/effect/flayer_telepad_binary_effect_secondary/proc/progress_step()
	new /obj/effect/flayer_telepad_binary_effect_tertiary(get_turf(src))

/obj/effect/flayer_telepad_binary_effect_secondary/proc/complete_portal()
	qdel(src)

/obj/effect/flayer_binary_portal
	icon_state = "bluespace"
	icon = 'icons/obj/projectiles.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 24

/obj/effect/flayer_binary_portal/Initialize(mapload)
	. = ..()
	// transform *= 0.25
	appearance_flags |= KEEP_TOGETHER | PIXEL_SCALE
	var/icon/our_icon = icon('icons/obj/projectiles.dmi', "bluespace")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") // Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) // Finally, let's mix in a distortion effect.
	icon = our_icon
	color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon
	addtimer(CALLBACK(src, PROC_REF(wormhole)), 25 SECONDS)
	animate(src, transform = matrix().Scale(0.25), time = 0.1 SECONDS)
	animate(transform = matrix().Scale(1, 2), time = 24 SECONDS)
	animate(transform = matrix().Scale(0.5), time = 0.9 SECONDS)

/obj/effect/flayer_binary_portal/proc/wormhole()
	new /obj/effect/flayer_binary_portal_secondary(get_turf(src))
	do_sparks(4, 0, src)
	qdel(src)

/obj/effect/flayer_binary_portal_secondary
	icon_state = "kinesis"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 24

/obj/effect/flayer_binary_portal_secondary/Initialize(mapload)
	. = ..()
	set_light(5, 2, LIGHT_COLOR_DARKGREEN)
	var/obj/effect/warp_effect/bsg/warp = new /obj/effect/warp_effect/bsg(get_turf(src))
	warp.pixel_y = 24
	appearance_flags |= KEEP_TOGETHER | PIXEL_SCALE
	var/icon/our_icon = icon('icons/effects/effects.dmi', "kinesis")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") // Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) // Finally, let's mix in a distortion effect.
	icon = our_icon
	color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon
	addtimer(CALLBACK(src, PROC_REF(complete_portal)), 45 SECONDS)
	animate(src, transform = matrix().Scale(0.3), time = 0.1 SECONDS)
	animate(transform = matrix().Scale(0.3, 0.6), time = 5 SECONDS)
	animate(transform = matrix().Scale(0.6, 1.2), time = 15 SECONDS)

/obj/effect/flayer_binary_portal_secondary/proc/complete_portal()
	animate(src, transform = matrix().Scale(0.1), time = 0.1 SECONDS)
	do_sparks(4, 0, src)
	qdel(src)

/obj/effect/flayer_telepad_binary_effect_tertiary
	icon = 'icons/obj/lighting.dmi'
	icon_state = "qpad-beam"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/flayer_telepad_binary_effect_tertiary/Initialize(mapload)
	. = ..()
	appearance_flags |= KEEP_TOGETHER
	var/icon/our_icon = icon('icons/obj/lighting.dmi', "qpad-beam")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") // Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) // Finally, let's mix in a distortion effect.
	icon = our_icon
	color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon
	addtimer(CALLBACK(src, PROC_REF(complete_portal)), 50 SECONDS)

/obj/effect/flayer_telepad_binary_effect_tertiary/proc/complete_portal()
	qdel(src)

// MARK:  Debug/Admin
/obj/effect/temp_visual/exfiltration/admin
	duration = 5.1 SECONDS

// MARK:  Extraction Portal
/obj/effect/portal/advanced/exfiltration
	name = "exfiltration portal"
	icon_state = "portal-syndicate"
	one_use = TRUE
	/// The mind of the exfiltrating antag.
	var/datum/mind/antag_mind = null
	/// Radio for handling extraction taunts
	var/obj/item/radio/radio
	/// Did we succeed?
	var/exfil_success = FALSE

/obj/effect/portal/advanced/exfiltration/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Security" = 0))

/obj/effect/portal/advanced/exfiltration/Destroy()
	if(exfil_success)
		return ..()
	if(antag_mind)
		log_and_message_admins("[antag_mind.original_mob_name] failed to exfiltrate.")
	SSblackbox.record_feedback("tally", "exfiltration", 1, "exfiltration_failure")
	return ..()

/obj/effect/portal/advanced/exfiltration/can_teleport(atom/movable/A)
	var/mob/living/M = A
	if(!istype(M))
		return FALSE
	return ..()

/obj/effect/portal/advanced/exfiltration/attempt_teleport(atom/movable/victim, turf/destination, variance = 0, force_teleport = TRUE)
	if(teleports_this_cycle >= MAX_ALLOWED_TELEPORTS_PER_PROCESS)
		return
	var/use_effects = world.time >= effect_cooldown
	var/effect = null // Will result in the default effect being used
	if(!use_effects)
		effect = NONE // No effect

	// Filter out non-antags
	var/mob/living/user = victim
	if(!istype(user))
		return FALSE
	var/datum/mind/user_mind = user.mind
	if(user_mind != antag_mind)
		to_chat(user, "<span class='warning'>You jump through the portal! Right before you see the other side, you feel an immense, sharp pain in your head!</span>")
		var/list/L = get_destinations()
		if(!length(L))
			to_chat(user, "<span class='warning'>[src] found no beacons in the sector to target.</span>")
			return
		var/random_destination = pick(L)
		if(!do_teleport(victim, random_destination, 2, force_teleport, effect, effect, bypass_area_flag = ignore_tele_proof_area_setting))
			invalid_teleport()
			return FALSE
		fail_extraction(user)
		effect_cooldown = world.time + 0.5 SECONDS
		teleports_this_cycle++
		return FALSE

	// For the antag
	if(!do_teleport(victim, destination, variance, force_teleport, effect, effect, bypass_area_flag = ignore_tele_proof_area_setting))
		invalid_teleport()
		return FALSE
	pass_extraction(user)
	return TRUE

/obj/effect/portal/advanced/exfiltration/proc/get_destinations()
	var/list/destinations = list()

	for(var/obj/item/beacon/B in GLOB.beacons)
		var/turf/T = get_turf(B)
		if(is_station_level(T.z))
			destinations += B

	return destinations

/obj/effect/portal/advanced/exfiltration/proc/fail_extraction(mob/living/schmuck)
	to_chat(schmuck, "<span class='warning'>You feel immense pain!</span>")
	log_and_message_admins("[schmuck] went through an exfiltration portal they didn't control.")
	schmuck.Paralyse(30 SECONDS)
	schmuck.EyeBlind(35 SECONDS)
	schmuck.EyeBlurry(35 SECONDS)
	schmuck.AdjustConfused(35 SECONDS)
	// Same effects as if they got contracted
	var/obj/item/organ/external/injury_target
	if(prob(20))
		injury_target = schmuck.get_organ(pick(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT))
		if(!injury_target)
			return
		schmuck.adjustBruteLoss(40)
		schmuck.adjustBrainLoss(25)
		injury_target.droplimb()
		to_chat(schmuck, "<span class='warning'>You were interrogated by your captors before being sent back! Oh god, something's missing!</span>")
		return
	// Species specific punishments first
	if(ismachineperson(schmuck))
		schmuck.emp_act(EMP_HEAVY)
		schmuck.adjustBrainLoss(30)
		to_chat(schmuck, "<span class='warning'>You were interrogated by your captors before being sent back! You feel like some of your components are loose!</span>")
		return
	schmuck.adjustBruteLoss(40)
	schmuck.adjustBrainLoss(25)
	if(isslimeperson(schmuck))
		injury_target = schmuck.get_organ(pick(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT))
		if(!injury_target)
			return
		injury_target.cause_internal_bleeding()
		injury_target = schmuck.get_organ(BODY_ZONE_CHEST)
		injury_target.cause_internal_bleeding()
		to_chat(schmuck, "<span class='warning'>You were interrogated by your captors before being sent back! You feel like your inner membrane has been punctured!</span>")
		return
	if(prob(25))
		injury_target = schmuck.get_organ(BODY_ZONE_CHEST)
		injury_target.fracture()
	else
		injury_target = schmuck.get_organ(pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_R_LEG))
		if(!injury_target)
			return
		injury_target.fracture()
		injury_target.cause_internal_bleeding()

/obj/effect/portal/advanced/exfiltration/proc/pass_extraction(mob/living/M)
	// Freeze objectives
	for(var/datum/objective/objective in antag_mind.get_all_objectives(include_team = FALSE))
		if(istype(objective, /datum/objective/escape))
			var/datum/objective/escape/escape_alive = objective
			escape_alive.completed = escape_alive.check_completion(exfilling = TRUE)
			continue
		objective.completed = objective.check_completion()
	// Handle syndicate barification
	log_and_message_admins("[M] extracted using an exfiltration portal.")
	exfil_success = TRUE
	SSblackbox.record_feedback("tally", "exfiltration", 1, "exfiltration_success")
	prepare_ghosting(M)

/obj/effect/portal/advanced/exfiltration/proc/prepare_ghosting(mob/living/carbon/human/extractor)
	if(!istype(extractor))
		return
	// Remove all clothing and bio chips
	for(var/obj/item/I in extractor)
		qdel(I)

	// Remove cybernetic implants
	for(var/obj/item/organ/internal/cyberimp/I in extractor.internal_organs)
		// Greys get to keep their implant
		if(isgrey(extractor) && istype(I, /obj/item/organ/internal/cyberimp/brain/speech_translator))
			continue
		// IPCs keep their implant
		if(ismachineperson(extractor) && istype(I, /obj/item/organ/internal/cyberimp/arm/power_cord))
			continue
		// Try removing it
		I = I.remove(extractor)

	// Remove martial arts
	for(var/datum/martial_art/MA in extractor.mind.known_martial_arts)
		MA.remove(extractor)

	// Kill guardians
	SEND_SIGNAL(extractor, COMSIG_SUMMONER_EXTRACTED)

	// Equip outfits and remove spells
	var/datum/mind/extractor_mind = extractor.mind
	for(var/datum/antagonist/antag in extractor_mind.antag_datums)
		antag.exfiltrate(extractor, radio)
	if(isvox(extractor))
		extractor.dna.species.after_equip_job(null, extractor) // Nitrogen tanks
	if(isplasmaman(extractor))
		extractor.dna.species.after_equip_job(null, extractor) // Plasma tanks
	// Apply traits
	ADD_TRAIT(extractor, TRAIT_PACIFISM, GHOST_ROLE)
	ADD_TRAIT(extractor, TRAIT_RESPAWNABLE, GHOST_ROLE)
	var/obj/item/bio_chip/dust/I = new
	I.implant(extractor, null)

	if(extractor.mind)
		if(extractor.mind.initial_account)
			GLOB.station_money_database.delete_user_account(extractor.mind.initial_account.account_number, "NAS Trurl Financial Services", FALSE)
	if(extractor.mind && extractor.mind.assigned_role)
		// Handle job slot
		var/job = extractor.mind.assigned_role

		SSjobs.FreeRole(job)


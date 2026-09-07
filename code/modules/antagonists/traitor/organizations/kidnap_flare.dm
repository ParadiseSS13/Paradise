// Traitor flare
/obj/item/wormhole_jaunter/kidnap
	name = "target extraction flare"
	icon = 'icons/obj/lighting.dmi'
	desc = "A single-use extraction flare that will send your target off the station. Don't fumble it."
	icon_state = "flare-contractor"
	inhand_icon_state = "flare"
	/// What areas can be extracted from?
	var/list/extractable_areas = list()
	/// How long does the extraction take?
	var/extraction_time = 30 SECONDS
	/// Type of setup once a flare is lit
	var/setup_type = /obj/effect/temp_visual/kidnap
	/// Type of portal spawned
	var/portal_type = /obj/effect/portal/advanced/kidnap

/obj/item/wormhole_jaunter/kidnap/Initialize(mapload)
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

/obj/item/wormhole_jaunter/kidnap/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += SPAN_WARNING("The target extraction locations are:")
		for(var/area/A in extractable_areas)
			. += SPAN_WARNING(" - [A.name]")

/obj/item/wormhole_jaunter/kidnap/activate(mob/user)
	if(!isAntag(user))
		to_chat(user, SPAN_WARNING("No matter how much you try, you can't get [src] to ignite!"))
		return

	if(!turf_check(user))
		return

	var/obj/effect/temp_visual/kidnap/F = new setup_type(get_turf(src))
	show_activation_message(user)
	user.drop_item()
	forceMove(F)
	addtimer(CALLBACK(src, PROC_REF(create_portal), user), extraction_time)

/obj/item/wormhole_jaunter/kidnap/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	var/area/our_area = get_area(device_turf)
	var/invalid_area = TRUE
	for(var/area/A in extractable_areas)
		if(istype(our_area, A))
			invalid_area = FALSE
			break

	if(!device_turf || invalid_area)
		to_chat(user, SPAN_NOTICE("You're having difficulties getting the [name] to work."))
		return FALSE
	return TRUE

/obj/item/wormhole_jaunter/kidnap/proc/create_portal(mob/user)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	var/obj/effect/portal/advanced/kidnap/P = new portal_type(get_turf(src), pick(GLOB.antagextractwarp), src, 30 SECONDS, user)
	P.antag_mind = user.mind
	P.target_mob = user.mind.objective_holder.get_targets()
	log_debug(user.mind.objective_holder.get_targets())
	qdel(src)

/obj/item/wormhole_jaunter/kidnap/emag_act(mob/user)
	to_chat(user, SPAN_WARNING("Emagging [src] has no effect."))

/obj/item/wormhole_jaunter/kidnap/chasm_react(mob/user)
	return // This is not an instant getaway portal like the jaunter

/obj/item/wormhole_jaunter/kidnap/proc/show_activation_message(mob/user)
	user.visible_message(SPAN_NOTICE("[user] pulls out a black and gold flare and lights it."),
					SPAN_NOTICE("You light an extraction flare, initiating the extraction process."))

// MARK: Traitor Flare
/obj/effect/temp_visual/kidnap
	name = "target extraction flare"
	layer = BELOW_MOB_LAYER
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flare-contractor-on"
	duration = 30.1 SECONDS
	/// Sound that plays when activated
	var/activation_sound = 'sound/goonstation/misc/matchstick_light.ogg'
	/// Light emitted when activated
	var/emitted_color = "#FFD165"
	/// Does this one emit light by default?
	var/start_lit = TRUE

/obj/effect/temp_visual/kidnap/Initialize(mapload)
	. = ..()
	playsound(loc, activation_sound, 50, TRUE)
	if(start_lit)
		set_light(8, l_color = emitted_color)

// MARK:  Extraction Portal
/obj/effect/portal/advanced/kidnap
	name = "target exfiltration portal"
	icon_state = "portal-syndicate"
	one_use = TRUE
	/// The mind of the exfiltrating pet.
	var/target_mob = null
	/// Radio for handling extraction taunts
	var/obj/item/radio/radio
	/// Did we succeed?
	var/kidnap_success = FALSE
	/// Antag's mind
	var/antag_mind = null

/obj/effect/portal/advanced/kidnap/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Security" = 0))

/obj/effect/portal/advanced/kidnap/Destroy()
	if(kidnap_success)
		return ..()
	return ..()

/obj/effect/portal/advanced/kidnap/can_teleport(atom/movable/A)
	var/mob/living/M = A
	if(!istype(M))
		return FALSE
	if(M == usr && M.mind == antag_mind)
		to_chat(M, SPAN_WARNING("The portal is here to extract the target, not you!"))
		return FALSE
	if(M != target_mob)
		if(usr?.mind == antag_mind) // Contractor shoving a non-target into the portal
			to_chat(M, SPAN_WARNING("Somehow you are not sure [M] is the target you have to kidnap."))
			return FALSE
		else if(usr == M) // Non-target trying to enter the portal
			to_chat(M, SPAN_WARNING("Somehow you are not sure this is a good idea."))
			return FALSE
		return FALSE
	return ..()

/obj/effect/portal/advanced/kidnap/attempt_teleport(atom/movable/victim, turf/destination, variance = 0, force_teleport = TRUE)
	var/mob/living/M = victim
	if(teleports_this_cycle >= MAX_ALLOWED_TELEPORTS_PER_PROCESS)
		return
	var/use_effects = world.time >= effect_cooldown
	var/effect = null // Will result in the default effect being used
	if(!use_effects)
		effect = NONE // No effect

	pass_extraction(M)
	return TRUE

/obj/effect/portal/advanced/kidnap/proc/pass_extraction(mob/living/M)
	prepare_ghosting(M)

/obj/effect/portal/advanced/kidnap/proc/prepare_ghosting(mob/living/carbon/human/extractor)
	if(!istype(extractor))
		return

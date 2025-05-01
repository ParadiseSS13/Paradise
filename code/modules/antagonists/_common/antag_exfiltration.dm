// Traitor flare
/obj/item/wormhole_jaunter/extraction
	name = "extraction flare"
	icon = 'icons/obj/lighting.dmi'
	desc = "A single-use extraction flare that will let you escape the station. One way trip."
	icon_state = "flare-contractor"
	item_state = "flare"
	/// What areas can be extracted from?
	var/list/extractable_areas = list()
	/// Is there a roundstart delay?
	var/delayed_extraction = TRUE
	/// How long does the extraction take?
	var/extraction_time = 90 SECONDS
	/// Type of setup once a flare is lit
	var/setup_type = /obj/effect/temp_visual/getaway_flare/exfiltration
	/// Type of portal spawned
	var/portal_type = /obj/effect/portal/advanced/exfiltration

/obj/item/wormhole_jaunter/extraction/Initialize(mapload)
	. = ..()
	var/list/possible_areas = list(
		// Rooms
		"Aft Primary Hallway",
		"Atmospherics",
		"Arcade",
		"Assembly Line",
		"Auxiliary Tool Storage",
		"Break Room",
		"Blueshield's Office",
		"Cargo Bay",
		"Chapel",
		"Chapel Office",
		"Clown's Office",
		"Construction Area",
		"Courtroom",
		"Dormitory Toilets",
		"Engineering",
		"Engineering Control Room",
		"Escape Shuttle Hallway",
		"Experimentation Lab",
		"Holodeck Alpha",
		"Hydroponics",
		"Library",
		"Mime's Office",
		"Mining Dock",
		"Morgue",
		"Office Supplies",
		"Pet Store",
		"Primary Tool Storage",
		"Research Division",
		"Security Checkpoint",
		"Technical Storage",
		"Teleporter",
		"Science Toxins Storage",
		"Vacant Office",
		"Research Testing Lab",
		"Xenobiology Lab",
		"AI Satellite Antechamber",
		"AI Satellite Atmospherics",
		"AI Satellite Service",
		"AI Satellite Hallway",
		"Bar",
		"Cargo Office",
		"Chemistry",
		"Chief Engineer's office",
		"Chief Medical Officer's office",
		"Cloning Lab",
		"Cryogenics",
		"Dorms",
		"Engineering Equipment Storage",
		"Engineering Foyer",
		"EVA Storage",
		"Expedition",
		"Genetics Lab",
		"Gravity Generator",
		"Head of Personnel's Office",
		"Heads of Staff Meeting Room",
		"Kitchen",
		"Mech Bay",
		"Medbay",
		"Medbay Reception",
		"Medical Storage",
		"Medical Treatment Center",
		"Medbay Patient Ward",
		"Messaging Server Room",
		"Mr Chang's",
		"Nanotrasen Representative's Office",
		"Paramedic",
		"Port Primary Hallway",
		"Quartermaster's Office",
		"Research Director's Office",
		"Research and Development",
		"Robotics Lab",
		"Surgery 1",
		"Surgery 2",
		"Telecoms Central Compartment",
		"Secure Storage"
	)
	while(length(extractable_areas) < 3)
		var/area_name = pick_n_take(possible_areas)
		var/list/all_areas_by_name = list()
		var/static/regex/name_fixer = regex("(\[a-z0-9 \\'\]+)$", "ig")
		for(var/a in GLOB.all_areas)
			var/area/A = a
			if(A.outdoors || !is_station_level(A.z))
				continue
			var/i = findtext(A.map_name, name_fixer)
			if(i)
				var/clean_name = copytext(A.map_name, i)
				clean_name = replacetext(clean_name, "\\", "")
				all_areas_by_name[clean_name] = A
		var/area/A = all_areas_by_name[area_name]
		if(!A)
			continue
		extractable_areas += A

/obj/item/wormhole_jaunter/extraction/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='warning'>The target extraction locations are:</span>"
		for(var/area/A in extractable_areas)
			. += "<span class='warning'> - [A.name]</span>"

/obj/item/wormhole_jaunter/extraction/activate(mob/user)
	if(!turf_check(user))
		return

	// Objective checks
	var/denied = FALSE
	var/is_target = FALSE
	var/has_target_objective = FALSE
	var/objectives = user.mind.get_all_objectives()

	// Check if you're the target of any other antags. If you are, using the beacon will find it jammed and turned to ash.
	for(var/datum/objective/O in GLOB.all_objectives)
		if(O.target != user.mind)
			continue
		denied = TRUE
		is_target = TRUE
		break

	// No extraction for NAD, Plutonium core theft, or Hijack
	for(var/datum/objective/goal in objectives)
		if(istype(goal, /datum/objective/steal))
			var/datum/objective/steal/theft = goal
			if(istype(theft.steal_target, /datum/theft_objective/nukedisc) || istype(theft.steal_target, /datum/theft_objective/plutonium_core))
				denied = TRUE

		if(istype(goal, /datum/objective/hijack))
			denied = TRUE

		if(istype(goal, /datum/objective/potentially_backstabbed))
			has_target_objective = TRUE

	if(denied && is_target)
		to_chat(user, "<span class='warning'>Someone or something has jammed your extraction beacon, forcing it to disintegrate early!</span>")
		if(!has_target_objective)
			user.mind.add_mind_objective(/datum/objective/potentially_backstabbed, "Someone or something has jammed your extraction! Survive!")
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)
		return
	else if(denied)
		to_chat(user, "<span class='warning'>Your objectives are too delicate for an early extraction.</span>")
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)
		return

	// Delay extractions
	if(world.time < 60 MINUTES && delayed_extraction) // 60 minutes of no exfil
		to_chat(user, "<span class='warning'>The exfiltration teleporter is calibrating. Please wait another [round((36000 - world.time) / 600)] minutes before trying again.</span>")
		return
	var/obj/effect/temp_visual/getaway_flare/exfiltration/F = new setup_type(get_turf(src))
	user.visible_message("<span class='notice'>[user] pulls out a black and gold flare and lights it.</span>",\
						"<span class='notice'>You light an extraction flare, initiating the extraction process.</span>")
	user.drop_item()
	forceMove(F)
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

// Vampire Portal
/obj/item/wormhole_jaunter/extraction/vampire
	name = "bloody flare"
	icon = 'icons/obj/lighting.dmi'
	desc = "An unholy construct that will create a single-use portal that will let you escape the station. One way trip."
	icon_state = "flare-contractor"
	item_state = "flare"
	setup_type = /obj/effect/temp_visual/getaway_flare/exfiltration/vampire

// Changeling Mass
/obj/item/wormhole_jaunter/extraction/changeling
	name = "writhing mass"
	icon = 'icons/obj/lighting.dmi'
	desc = "A mass of writhing flesh that will create a single-use portal that will let you escape the station. One way trip."
	icon_state = "flare-contractor"
	item_state = "flare"
	setup_type = /obj/effect/temp_visual/getaway_flare/exfiltration/changeling

// Mindflayer Swarm
/obj/item/wormhole_jaunter/extraction/mindflayer
	name = "nanite telepad"
	icon = 'icons/obj/lighting.dmi'
	desc = "A swarm of mindflayer nanites in the shape of a telepad that will create a single-use portal that will let you escape the station. One way trip."
	icon_state = "flare-contractor"
	item_state = "flare"
	setup_type = /obj/effect/temp_visual/getaway_flare/exfiltration/mindflayer

// Debug/Admin
/obj/item/wormhole_jaunter/extraction/admin
	name = "advanced extraction flare"
	icon = 'icons/obj/lighting.dmi'
	desc = "An advanced single-use extraction flare that will let you escape the station. One way trip."
	icon_state = "flare-contractor"
	item_state = "flare"
	delayed_extraction = FALSE
	extraction_time = 5 SECONDS
	setup_type = /obj/effect/temp_visual/getaway_flare/exfiltration/admin

// Extraction Portal
/obj/effect/portal/advanced/exfiltration
	name = "exfiltration portal"
	icon_state = "portal-syndicate"
	ignore_tele_proof_area_setting = TRUE
	one_use = TRUE
	/// The mind of the exfiltrating antag.
	var/datum/mind/antag_mind = null
	/// Radio for handling extraction taunts
	var/obj/item/radio/radio

/obj/effect/portal/advanced/exfiltration/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Security" = 0))

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
	var/all_objectives = antag_mind.get_all_objectives(include_team = FALSE)
	if(length(all_objectives))// If the antag had no objectives, don't need to process this.
		for(var/datum/objective/objective in all_objectives)
			objective.completed = objective.check_completion()
	// Handle syndicate barification
	prepare_ghosting(M)

/obj/effect/portal/advanced/exfiltration/proc/prepare_ghosting(mob/living/carbon/human/extractor)
	if(!istype(extractor))
		return
	// Remove all clothing
	for(var/obj/item/I in extractor)
		if(istype(I, /obj/item/bio_chip))
			continue
		qdel(I)

	// Remove implants
	for(var/obj/item/organ/internal/cyberimp/I in extractor.internal_organs)
		// Greys get to keep their implant
		if(isgrey(extractor) && istype(I, /obj/item/organ/internal/cyberimp/brain/speech_translator))
			continue
		// IPCs keep their implant
		if(ismachineperson(extractor) && istype(I, /obj/item/organ/internal/cyberimp/arm/power_cord))
			continue
		// Try removing it
		I = I.remove(extractor)

	// Equip outfits and remove spells
	var/datum/mind/extractor_mind = extractor.mind
	for(var/datum/antagonist/antag in extractor_mind.antag_datums)
		if(istype(antag, /datum/antagonist/traitor))
			extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/syndicate)
			radio.autosay("<b>--ZZZT!- Good work, $@gent [extractor.real_name]. Return to -^%&!-ZZT!-</b>", "Syndicate Operations", "Security")
			SSblackbox.record_feedback("tally", "successful_extraction", 1, "Traitor")
			return

		if(istype(antag, /datum/antagonist/vampire))
			var/datum/antagonist/vampire/bloodsucker = antag
			bloodsucker.remove_all_powers()
			extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/vampire)
			radio.autosay("<b>--ZZZT!- Wonderfully done, [extractor.real_name]. Welcome to -^%&!-ZZT!-</b>", "Ancient Vampire", "Security")
			SSblackbox.record_feedback("tally", "successful_extraction", 1, "Vampire")
			return

		if(istype(antag, /datum/antagonist/mindflayer))
			var/datum/antagonist/mindflayer/brainsucker = antag
			brainsucker.remove_all_abilities()
			brainsucker.remove_all_passives()
			extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/mindflayer)
			radio.autosay("<b>--ZZZT!- Excellent job, [extractor.real_name]. Proceed to -^%&!-ZZT!-</b>", "Master Flayer", "Security")
			SSblackbox.record_feedback("tally", "successful_extraction", 1, "Mindflayer")
			return

		if(istype(antag, /datum/antagonist/changeling))
			var/datum/antagonist/changeling/ling = antag
			ling.remove_changeling_powers(FALSE)
			var/datum/action/changeling/power = new /datum/action/changeling/transform
			power.Grant(extractor)
			extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/changeling)
			radio.autosay("<b>--ZZZT!- Welcome home, [extractor.real_name]. -ZZT!-</b>", "Changeling Hive", "Security")
			SSblackbox.record_feedback("tally", "successful_extraction", 1, "Changeling")
			return

	// Apply traits
	ADD_TRAIT(extractor, TRAIT_PACIFISM, GHOST_ROLE)
	ADD_TRAIT(extractor, TRAIT_RESPAWNABLE, GHOST_ROLE)

	if(extractor.mind)
		if(extractor.mind.initial_account)
			GLOB.station_money_database.delete_user_account(extractor.mind.initial_account.account_number, "NAS Trurl Financial Services", FALSE)

	if(extractor.mind && extractor.mind.assigned_role)
		// Handle job slot
		var/job = extractor.mind.assigned_role

		SSjobs.FreeRole(job)


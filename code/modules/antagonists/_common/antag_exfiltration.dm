// Traitor flare
/obj/item/wormhole_jaunter/extraction
	name = "extraction flare"
	icon = 'icons/obj/lighting.dmi'
	desc = "A single-use extraction flare that will let you escape the station. One way trip."
	icon_state = "flare-contractor"
	item_state = "flare"
	/// What areas can be extracted from?
	var/list/extractable_areas = list()

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
	// UNCOMMENT THIS BEFORE MERGE
	//if(world.time < 60 MINUTES) // 60 minutes of no exfil
		//to_chat(user, "The exfiltration teleporter is calibrating. Please wait another [round((60 MINUTES - world.time) / 60 SECONDS)] minutes before trying again.")
		//return
	var/obj/effect/temp_visual/getaway_flare/exfiltration/F = new(get_turf(src))
	user.visible_message("<span class='notice'>[user] pulls out a black and gold flare and lights it.</span>",\
						"<span class='notice'>You light an extraction flare, initiating the extraction process.</span>")
	user.drop_item()
	forceMove(F)
	addtimer(CALLBACK(src, PROC_REF(create_portal), user), 90 SECONDS)

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
	var/obj/effect/portal/advanced/exfiltration/P = new(get_turf(src), pick(GLOB.antagextractwarp), src, 30 SECONDS, user)
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

// Changeling Mass
/obj/item/wormhole_jaunter/extraction/changeling
	name = "writhing mass"
	icon = 'icons/obj/lighting.dmi'
	desc = "A mass of writhing flesh that will create a single-use portal that will let you escape the station. One way trip."
	icon_state = "flare-contractor"
	item_state = "flare"

// Mindflayer Swarm
/obj/item/wormhole_jaunter/extraction/mindflayer
	name = "nanite swarm"
	icon = 'icons/obj/lighting.dmi'
	desc = "A swarm of mindflayer nanites that will create a single-use portal that will let you escape the station. One way trip."
	icon_state = "flare-contractor"
	item_state = "flare"


// Extraction Portal

/obj/effect/portal/advanced/exfiltration
	name = "exfiltration portal"
	icon_state = "portal-syndicate"
	ignore_tele_proof_area_setting = TRUE
	one_use = TRUE
	/// The mind of the exfiltrating antag.
	var/datum/mind/antag_mind = null

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




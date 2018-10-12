/obj/effect/landmark
	name = "landmark"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	anchored = TRUE
	unacidable = TRUE
	invisibility = 101

INITIALIZE_IMMEDIATE(/obj/effect/landmark)

/obj/effect/landmark/Initialize()
	. = ..()
	GLOB.landmarks_list += src

/obj/effect/landmark/Destroy()
	GLOB.landmarks_list -= src
	return ..()

/obj/effect/landmark/singularity_act()
	return

/obj/effect/landmark/ex_act()
	return

/obj/effect/landmark/singularity_pull()
	return

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = MOB_LAYER
	var/jobspawn_override = FALSE
	var/delete_after_roundstart = TRUE
	var/used = FALSE

/obj/effect/landmark/start/proc/after_round_start()
	if(delete_after_roundstart)
		qdel(src)

/obj/effect/landmark/start/New()
	GLOB.start_landmarks_list += src
	if(jobspawn_override)
		if(!GLOB.jobspawn_overrides[name])
			GLOB.jobspawn_overrides[name] = list()
		GLOB.jobspawn_overrides[name] += src
	..()
	if(name != "start")
		tag = "start*[name]"

/obj/effect/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
	if(jobspawn_override)
		GLOB.jobspawn_overrides[name] -= src
	return ..()

// START LANDMARKS FOLLOW. Don't change the names unless
// you are refactoring shitty landmark code.

// Must be immediate because players will
// join before SSatom initializes everything.
INITIALIZE_IMMEDIATE(/obj/effect/landmark/start/new_player)

/obj/effect/landmark/start/new_player
	name = "New Player"

/obj/effect/landmark/start/new_player/Initialize()
	..()
	GLOB.newplayer_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/latejoin
	name = "JoinLate"

/obj/effect/landmark/latejoin/Initialize(mapload)
	..()
	GLOB.latejoin += loc
	return INITIALIZE_HINT_QDEL


/obj/effect/landmark/start/civilian
	name = "Civilian"
	icon_state = "Civilian"

/obj/effect/landmark/start/civilian/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/captain
	name = "Captain"
	icon_state = "Captain"

// Service //

/obj/effect/landmark/start/head_of_personnel
	name = "Head of Personnel"
	icon_state = "Head of Personnel"

/obj/effect/landmark/start/janitor
	name = "Janitor"
	icon_state = "Janitor"

/obj/effect/landmark/start/bartender
	name = "Bartender"
	icon_state = "Bartender"

/obj/effect/landmark/start/botanist
	name = "Botanist"
	icon_state = "Botanist"

/obj/effect/landmark/start/clown
	name = "Clown"
	icon_state = "Clown"

/obj/effect/landmark/start/mime
	name = "Mime"
	icon_state = "Mime"

/obj/effect/landmark/start/cook
	name = "Cook"
	icon_state = "Cook"

/obj/effect/landmark/start/librarian
	name = "Librarian"
	icon_state = "Librarian"

/obj/effect/landmark/start/chaplain
	name = "Chaplain"
	icon_state = "Chaplain"

// Cargo //

/obj/effect/landmark/start/quartermaster
	name = "Quartermaster"
	icon_state = "Quartermaster"

/obj/effect/landmark/start/cargo_technician
	name = "Cargo Technician"
	icon_state = "Cargo Technician"

/obj/effect/landmark/start/shaft_miner
	name = "Shaft Miner"
	icon_state = "Shaft Miner"

// Engineering //

/obj/effect/landmark/start/chief_engineer
	name = "Chief Engineer"
	icon_state = "Chief Engineer"

/obj/effect/landmark/start/station_engineer
	name = "Station Engineer"
	icon_state = "Station Engineer"

/obj/effect/landmark/start/atmospheric_technician
	name = "Atmospheric Technician"
	icon_state = "Atmospheric Technician"

// Security //

/obj/effect/landmark/start/head_of_security
	name = "Head of Security"
	icon_state = "Head of Security"

/obj/effect/landmark/start/warden
	name = "Warden"
	icon_state = "Warden"

/obj/effect/landmark/start/security_officer
	name = "Security Officer"
	icon_state = "Security Officer"

/obj/effect/landmark/start/detective
	name = "Detective"
	icon_state = "Detective"

/obj/effect/landmark/start/iaa
	name = "Internal Affairs Agent"
	icon_state = "iaa"

// Medical //

/obj/effect/landmark/start/chief_medical_officer
	name = "Chief Medical Officer"
	icon_state = "Chief Medical Officer"

/obj/effect/landmark/start/medical_doctor
	name = "Medical Doctor"
	icon_state = "Medical Doctor"

/obj/effect/landmark/start/coroner
	name = "Coroner"
	icon_state = "Coroner"

/obj/effect/landmark/start/chemist
	name = "Chemist"
	icon_state = "Chemist"

/obj/effect/landmark/start/virologist
	name = "Virologist"
	icon_state = "Virologist"

/obj/effect/landmark/start/psych
	name = "Psych"
	icon_state = "Psych"

// Science //

/obj/effect/landmark/start/research_director
	name = "Research Director"
	icon_state = "Research Director"

/obj/effect/landmark/start/scientist
	name = "Scientist"
	icon_state = "Scientist"

/obj/effect/landmark/start/roboticist
	name = "Roboticist"
	icon_state = "Roboticist"

/obj/effect/landmark/start/geneticist
	name = "Geneticist"
	icon_state = "Geneticist"

// Sillycons //

/obj/effect/landmark/start/cyborg
	name = "Cyborg"
	icon_state = "Cyborg"

/obj/effect/landmark/start/ai
	name = "AI"
	icon_state = "AI"
	delete_after_roundstart = FALSE
	var/primary_ai = TRUE
	var/latejoin_active = TRUE

/obj/effect/landmark/start/ai/after_round_start()
	if(latejoin_active && !used)
		new /obj/structure/AIcore/deactivated(loc)
	return ..()

/obj/effect/landmark/start/ai/secondary
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "ai_spawn"
	primary_ai = FALSE
	latejoin_active = FALSE

// Karma //

/obj/effect/landmark/start/blueshield
	name = "Blueshield"
	icon_state = "Blueshield"

/obj/effect/landmark/start/mechanic
	name = "Mechanic"
	icon_state = "Mechanic"

/obj/effect/landmark/start/podpilot
	name = "Pod Pilot"
	icon_state = "Pod Pilot"

/obj/effect/landmark/start/barber
	name = "Barber"
	icon_state = "Barber"

/obj/effect/landmark/start/ntrep
	name = "Nanotrasen Representative"
	icon_state = "NT Rep"

/obj/effect/landmark/start/paramedic
	name = "Paramedic"
	icon_state = "Paramedic"

/obj/effect/landmark/start/brigdoc
	name = "Brig Physician"
	icon_state = "Brig Doc"

/obj/effect/landmark/start/magistrate
	name = "Magistrate"
	icon_state = "Magistrate"

// Antags //

/obj/effect/landmark/start/wizard
	name = "wizard"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "wiznerd_spawn"

/obj/effect/landmark/start/wizard/Initialize()
	..()
	GLOB.wizardstart += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop
	name = "nukeop"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_spawn"

/obj/effect/landmark/start/nukeop/Initialize()
	..()
	GLOB.nukeop_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop_leader
	name = "nukeop leader"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_leader_spawn"

/obj/effect/landmark/start/nukeop_leader/Initialize()
	..()
	GLOB.nukeop_leader_start += loc
	return INITIALIZE_HINT_QDEL

// Non start spawns //

/obj/effect/landmark/carpspawn
	name = "carpspawn"
	icon_state = "carp_spawn"

/obj/effect/landmark/carpspawn/Initialize(mapload)
	..()
	GLOB.carplist += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/xeno_spawn
	name = "xeno_spawn"
	icon_state = "xeno_spawn"

/obj/effect/landmark/xeno_spawn/Initialize(mapload)
	..()
	GLOB.xeno_spawn += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/observer_start
	name = "Observer-Start"
	icon_state = "observer_start"

/obj/effect/landmark/blobstart
	name = "blobstart"
	icon_state = "blob_start"

/obj/effect/landmark/blobstart/Initialize(mapload)
	..()
	GLOB.blobstart += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/prisonwarp
	name = "prisonwarp"
	icon_state = "prisonwarp"

/obj/effect/landmark/prisonwarp/Initialize(mapload)
	..()
	GLOB.prisonwarp += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/ert_spawn
	name = "Emergencyresponseteam"
	icon_state = "ert_spawn"

/obj/effect/landmark/ert_spawn/Initialize(mapload)
	..()
	GLOB.emergencyresponseteamspawn += loc
	return INITIALIZE_HINT_QDEL

// Thunderdome //
/obj/effect/landmark/thunderdome/observe
	name = "tdomeobserve"
	icon_state = "tdome_observer"

/obj/effect/landmark/thunderdome/observe/Initialize(mapload)
	..()
	GLOB.tdomeobserve += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/one
	name = "tdome1"
	icon_state = "tdome_t1"

/obj/effect/landmark/thunderdome/one/Initialize(mapload)
	..()
	GLOB.tdome1	+= loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/two
	name = "tdome2"
	icon_state = "tdome_t2"

/obj/effect/landmark/thunderdome/two/Initialize(mapload)
	..()
	GLOB.tdome2 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/admin
	name = "tdomeadmin"
	icon_state = "tdome_admin"

/obj/effect/landmark/thunderdome/admin/Initialize(mapload)
	..()
	GLOB.tdomeadmin += loc
	return INITIALIZE_HINT_QDEL

// Generic event spawns
/obj/effect/landmark/event_spawn
	name = "generic event spawn"
	icon_state = "generic_event"
	layer = HIGH_LANDMARK_LAYER


/obj/effect/landmark/event_spawn/New()
	..()
	GLOB.generic_event_spawns += src

/obj/effect/landmark/event_spawn/Destroy()
	GLOB.generic_event_spawns -= src
	return ..()

/obj/effect/landmark/aroomwarp
	name = "Admin Room Warp"
	icon_state = "aroomwarp"

/obj/effect/landmark/aroomwarp/Initialize(mapload)
	..()
	GLOB.aroomwarp += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/ninja
	name = "ninjastart"
	icon_state = "ninja"

/obj/effect/landmark/ninja/Initialize(mapload)
	..()
	GLOB.ninjastart += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/avatar
	name = "avatarspawn"
	icon_state = "avatarspawn"

/obj/effect/landmark/avatar/Initialize(mapload)
	..()
	GLOB.avatarspawn += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/away
	name = "Away Destination"
	icon_state = "awaydestinations"

/obj/effect/landmark/away/Initialize(mapload)
	..()
	GLOB.awaydestinations += loc
	return INITIALIZE_HINT_QDEL



// Ruins
/obj/effect/landmark/ruin
	var/datum/map_template/ruin/ruin_template

/obj/effect/landmark/ruin/New(loc, my_ruin_template)
	name = "ruin_[GLOB.ruin_landmarks.len + 1]"
	..(loc)
	ruin_template = my_ruin_template
	GLOB.ruin_landmarks |= src

/obj/effect/landmark/ruin/Destroy()
	GLOB.ruin_landmarks -= src
	ruin_template = null
	. = ..()


// Damage tiles
/obj/effect/landmark/damageturf
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "damaged"

/obj/effect/landmark/damageturf/New()
	..()
	var/turf/simulated/T = get_turf(src)
	T.break_tile()

/obj/effect/landmark/burnturf
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "burned"

/obj/effect/landmark/burnturf/New()
	..()
	var/turf/simulated/T = get_turf(src)
	T.burn_tile()


/*
	switch(name)			//some of these are probably obsolete
		if("start")
			newplayer_start += loc
			qdel(src)

		if("wizard")
			wizardstart += loc
			qdel(src)

		if("avatarspawn")
			avatarspawn += loc

		if("JoinLate")
			latejoin += loc
			qdel(src)

		if("JoinLateGateway")
			latejoin_gateway += loc
			qdel(src)

		if("JoinLateCryo")
			latejoin_cryo += loc
			qdel(src)

		if("JoinLateCyborg")
			latejoin_cyborg += loc
			qdel(src)

		if("prisonwarp")
			prisonwarp += loc
			qdel(src)

		if("prisonsecuritywarp")
			prisonsecuritywarp += loc
			qdel(src)

		if("tdome1")
			tdome1	+= loc

		if("tdome2")
			tdome2 += loc

		if("tdomeadmin")
			tdomeadmin	+= loc

		if("tdomeobserve")
			tdomeobserve += loc

		if("aroomwarp")
			aroomwarp += loc

		if("blobstart")
			blobstart += loc
			qdel(src)

		if("xeno_spawn")
			xeno_spawn += loc
			qdel(src)

		if("ninjastart")
			ninjastart += loc
			qdel(src)

		if("carpspawn")
			carplist += loc

		if("voxstart")
			raider_spawn += loc

		if("ERT Director")
			ertdirector += loc
			qdel(src)

		if("Response Team")
			emergencyresponseteamspawn += loc
			qdel(src)

	GLOB.landmarks_list += src
	return 1
*/

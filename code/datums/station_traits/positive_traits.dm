/datum/station_trait/galactic_grant
	name = "Galactic grant"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Your station has been selected for a special grant. Some extra funds has been made available to your cargo department."

/datum/station_trait/galactic_grant/on_round_start()
	GLOB.station_money_database.credit_account(SSeconomy.cargo_account, rand(2000, 4000), "Galactic Grant", "Great Galactic Grant Group")
/datum/station_trait/premium_internals_box
	name = "Premium internals boxes"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "The internals boxes for your crew have been upsized and filled with bonus equipment."
	trait_to_give = STATION_TRAIT_PREMIUM_INTERNALS

/datum/station_trait/strong_supply_lines
	name = "Strong supply lines"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Prices are low in this system, BUY BUY BUY!"
	blacklist = list(/datum/station_trait/distant_supply_lines)


/datum/station_trait/strong_supply_lines/on_round_start()
	SSeconomy.pack_price_modifier *= 0.8

/datum/station_trait/filled_maint
	name = "Filled up maintenance"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Our workers accidentally forgot more of their personal belongings in the maintenance areas."
	blacklist = list(/datum/station_trait/empty_maint)
	trait_to_give = STATION_TRAIT_FILLED_MAINT

	// This station trait is checked when loot drops initialize, so it's too late
	can_revert = FALSE

/datum/station_trait/quick_shuttle
	name = "Quick Shuttle"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to proximity to our supply station, the cargo shuttle will have a quicker flight time to your cargo department."
	blacklist = list(/datum/station_trait/slow_shuttle)

/datum/station_trait/quick_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 0.5

/datum/station_trait/deathrattle_department
	name = "deathrattled department"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	trait_flags = STATION_TRAIT_ABSTRACT
	blacklist = list(/datum/station_trait/deathrattle_all)

	var/department_to_apply_to
	var/department_name = "department"
	var/datum/deathrattle_group/deathrattle_group

/datum/station_trait/deathrattle_department/New()
	. = ..()
	deathrattle_group = new("[department_name] group")
	blacklist += subtypesof(/datum/station_trait/deathrattle_department) - type //All but ourselves
	report_message = "All members of [department_name] have received an implant to notify each other if one of them dies. This should help improve job-safety!"
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))


/datum/station_trait/deathrattle_department/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned)
	SIGNAL_HANDLER
	if(department_to_apply_to)
		if(!(job.job_department_flags & department_to_apply_to))
			return

	var/obj/item/bio_chip/deathrattle/implant_to_give = new()
	deathrattle_group.register(implant_to_give)
	implant_to_give.implant(spawned, spawned, TRUE, TRUE)


/datum/station_trait/deathrattle_department/service
	name = "Deathrattled Service"
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 1
	department_to_apply_to = DEP_FLAG_SERVICE
	department_name = DEPARTMENT_SERVICE

/datum/station_trait/deathrattle_department/cargo
	name = "Deathrattled Cargo"
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 1
	department_to_apply_to = DEP_FLAG_SUPPLY
	department_name = DEPARTMENT_SUPPLY

/datum/station_trait/deathrattle_department/engineering
	name = "Deathrattled Engineering"
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 1
	department_to_apply_to = DEP_FLAG_ENGINEERING
	department_name = DEPARTMENT_ENGINEERING

/datum/station_trait/deathrattle_department/command
	name = "Deathrattled Command"
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 1
	department_to_apply_to = DEP_FLAG_COMMAND
	department_name = DEPARTMENT_COMMAND

/datum/station_trait/deathrattle_department/science
	name = "Deathrattled Science"
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 1
	department_to_apply_to = DEP_FLAG_SCIENCE
	department_name = DEPARTMENT_SCIENCE

/datum/station_trait/deathrattle_department/security
	name = "Deathrattled Security"
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 1
	department_to_apply_to = DEP_FLAG_SECURITY
	department_name = DEPARTMENT_SECURITY

/datum/station_trait/deathrattle_department/medical
	name = "Deathrattled Medical"
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 1
	department_to_apply_to = DEP_FLAG_MEDICAL
	department_name = DEPARTMENT_MEDICAL

/datum/station_trait/deathrattle_all
	name = "Deathrattled Station"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	weight = 1
	report_message = "All members of the station have received an implant to notify each other if one of them dies. This should help improve job-safety!"
	var/datum/deathrattle_group/deathrattle_group


/datum/station_trait/deathrattle_all/New()
	. = ..()
	deathrattle_group = new("station group")
	blacklist = subtypesof(/datum/station_trait/deathrattle_department)
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))


/datum/station_trait/deathrattle_all/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/obj/item/bio_chip/deathrattle/implant_to_give = new()
	deathrattle_group.register(implant_to_give)
	implant_to_give.implant(spawned, spawned, TRUE, TRUE)


/// NOTE: THIS MAKES EMP MUCH MORE EXPENSIVE.
/datum/station_trait/cybernetic_revolution
	name = "Cybernetic Revolution"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	weight = 2
	report_message = "The new trends in cybernetics have come to the station! Everyone has some form of cybernetic implant."
	trait_to_give = STATION_TRAIT_CYBERNETIC_REVOLUTION
	/// List of all job types with the cybernetics they should receive.
	var/static/list/job_to_cybernetic = list(
		/datum/job/assistant = /obj/item/organ/internal/heart/cybernetic, //real action, real bloodshed
		/datum/job/atmos = /obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/datum/job/bartender = /obj/item/organ/internal/liver/cybernetic,
		/datum/job/hydro = /obj/item/organ/internal/cyberimp/arm/botanical,
		/datum/job/captain = /obj/item/organ/internal/heart/cybernetic/upgraded,
		/datum/job/cargo_tech = /obj/item/organ/internal/cyberimp/arm/cargo,
		/datum/job/smith = /obj/item/organ/internal/cyberimp/arm/toolset,
		/datum/job/chaplain = /obj/item/organ/internal/cyberimp/brain/anti_drop,
		/datum/job/chemist = /obj/item/organ/internal/liver/cybernetic,
		/datum/job/chief_engineer = /obj/item/organ/internal/eyes/cybernetic/shield,
		/datum/job/cmo = /obj/item/organ/internal/cyberimp/chest/reviver,
		/datum/job/clown = /obj/item/organ/internal/cyberimp/brain/anti_stam, //HONK!
		/datum/job/chef = /obj/item/organ/internal/cyberimp/chest/nutriment/plus,
		/datum/job/coroner = /obj/item/organ/internal/cyberimp/eyes/hud/medical, //hes got a bone to pick with you
		/datum/job/librarian = /obj/item/organ/internal/cyberimp/brain/speech_translator, //dunno what to replace this with, but this is useless since no wingdings?
		/datum/job/detective = /obj/item/organ/internal/eyes/cybernetic/meson,
		/datum/job/doctor = /obj/item/organ/internal/cyberimp/arm/surgery,
		/datum/job/geneticist = /obj/item/organ/internal/alien/plasmavessel/hunter, //we don't care about implants, we have cancer.
		/datum/job/hop = /obj/item/organ/internal/eyes/cybernetic/shield,
		/datum/job/hos = /obj/item/organ/internal/cyberimp/brain/anti_stam, //not giving them thermals
		/datum/job/janitor = /obj/item/organ/internal/cyberimp/eyes/hud/jani,
		/datum/job/iaa = /obj/item/organ/internal/heart/cybernetic/upgraded,
		/datum/job/mime = /obj/item/organ/internal/cyberimp/brain/anti_stam, //...
		/datum/job/paramedic = /obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/datum/job/psychiatrist = /obj/item/organ/internal/heart/cybernetic/upgraded, //heart of gold. Or at least part gold
		/datum/job/qm = /obj/item/organ/internal/cyberimp/arm/telebaton,
		/datum/job/rd = /obj/item/organ/internal/cyberimp/arm/flash,
		/datum/job/roboticist = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic,
		/datum/job/scientist = /obj/item/organ/internal/ears/cybernetic,
		/datum/job/xenobiologist = /obj/item/organ/internal/cyberimp/arm/surgery,
		/datum/job/officer = /obj/item/organ/internal/cyberimp/eyes/hud/security,
		/datum/job/mining = /obj/item/organ/internal/eyes/cybernetic/meson,
		/datum/job/engineer = /obj/item/organ/internal/eyes/cybernetic/shield,
		/datum/job/virologist = /obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/datum/job/warden = /obj/item/organ/internal/cyberimp/arm/flash,
		/datum/job/judge = /obj/item/organ/internal/cyberimp/arm/telebaton,
		/datum/job/explorer = /obj/item/organ/internal/cyberimp/arm/toolset,
		/datum/job/nanotrasenrep = /obj/item/organ/internal/heart/cybernetic/upgraded,
		/datum/job/blueshield = /obj/item/organ/internal/cyberimp/arm/flash,
		/datum/job/nanotrasentrainer = /obj/item/organ/internal/heart/cybernetic/upgraded
	)

/datum/station_trait/cybernetic_revolution/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/cybernetic_revolution/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/cybernetic_type = job_to_cybernetic[job.type]
	if(!cybernetic_type)
		if(is_ai(spawned))
			var/mob/living/silicon/ai/ai = spawned
			ai.eyeobj.relay_speech = TRUE //surveillance upgrade. the ai gets cybernetics too.
		return
	var/obj/item/organ/internal/cybernetic = new cybernetic_type()
	INVOKE_ASYNC(cybernetic, TYPE_PROC_REF(/obj/item/organ/internal, insert), spawned, TRUE)

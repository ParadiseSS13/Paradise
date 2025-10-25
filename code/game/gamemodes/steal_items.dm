// Theft objectives.
//
// Separated into datums so we can prevent roles from getting certain objectives.

/datum/theft_objective
	var/name = "this objective is impossible, yell at a coder"
	var/typepath=/obj/effect/debugging
	var/list/protected_jobs = list()
	var/list/altitems = list()
	var/flags = 0
	var/location_override
	/// Do we have a special item we give to somewhen when they get this objective?
	var/special_equipment = null
	/// If a steal objective has forbidden jobs, and the forbidden jobs would not be in the possession of this item, set this to false
	var/job_possession = TRUE
	/// Any extra information about the objective
	var/extra_information = ""
	/// Do we overide naming to not say steal at the front?
	var/objective_name_overide = null

/datum/theft_objective/proc/check_completion(datum/mind/owner)
	if(!owner.current)
		return 0
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.get_contents()
	for(var/obj/I in all_items) //Check for items
		if(istype(I, typepath) && check_special_completion(I))
			return 1
	return 0

//This proc is to be used for not granting objectives if a special requirement other than job is not met.

/datum/theft_objective/proc/check_objective_conditions()
	return TRUE

/datum/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1

/datum/theft_objective/proc/on_hand_out_equipment(datum/objective/steal/our_objective)
	return

/datum/theft_objective/antique_laser_gun
	name = "the captain's antique laser gun"
	typepath = /obj/item/gun/energy/laser/captain
	protected_jobs = list("Captain")
	location_override = "the Captain's Office"

/datum/theft_objective/captains_modsuit
	name = "the captain's Magnate MODsuit"
	typepath = /obj/item/mod/control/pre_equipped/magnate
	protected_jobs = list("Captain")
	location_override = "the Captain's Office"

/datum/theft_objective/captains_saber
	name = "the captain's saber"
	typepath = /obj/item/melee/saber
	protected_jobs = list("Captain")
	location_override = "the Captain's Office"

/datum/theft_objective/hoslaser
	name = "the head of security's X-01 multiphase energy gun"
	typepath = /obj/item/gun/energy/gun/hos
	protected_jobs = list("Head Of Security")
	location_override = "the Head of Security's Office"

/datum/theft_objective/hand_tele
	name = "a hand teleporter"
	typepath = /obj/item/hand_tele
	protected_jobs = list("Captain", "Research Director", "Chief Engineer")
	location_override = "the AI Satellite, or the Captain's Office"

/datum/theft_objective/defib
	name = "the chief medical officer's advanced compact defibrillator"
	typepath = /obj/item/defibrillator/compact/advanced
	protected_jobs = list("Chief Medical Officer", "Paramedic")
	location_override = "the Chief Medical Officer's Office"

/datum/theft_objective/magboots
	name = "the chief engineer's advanced magnetic boots"
	typepath = /obj/item/clothing/shoes/magboots/advance
	protected_jobs = list("Chief Engineer")
	location_override = "the Chief Engineer's Office"

/datum/theft_objective/blueprints
	name = "the station blueprints"
	typepath = /obj/item/areaeditor/blueprints/ce
	protected_jobs = list("Chief Engineer")
	altitems = list(/obj/item/photo)
	location_override = "the Chief Engineer's Office"
	extra_information = "Obtaining a photograph of the blueprints is also an option."

/datum/theft_objective/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/areaeditor/blueprints/ce))
		return 1
	if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		if(P.blueprints)
			return 1
	return 0

/datum/theft_objective/capmedal
	name = "the medal of captaincy"
	typepath = /obj/item/clothing/accessory/medal/gold/captain
	protected_jobs = list("Captain")
	location_override = "the Captain's Office"

/datum/theft_objective/nukedisc
	name = "the nuclear authentication disk"
	typepath = /obj/item/disk/nuclear
	protected_jobs = list("Captain")
	location_override = "the Captain's Office"

/datum/theft_objective/nukedisc/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/disk/nuclear/training)) //Haha no
		return FALSE
	return TRUE

/datum/theft_objective/reactive
	name = "any type of reactive armor"
	typepath = /obj/item/clothing/suit/armor/reactive
	protected_jobs = list("Research Director", "Scientist", "Roboticist") //no one with protolathe access, who will often be handed a core
	location_override = "the Research Director's Office"

/datum/theft_objective/documents
	name = "any set of secret documents of any organization"
	typepath = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's
	location_override = "the Vault"
	protected_jobs = list("Quartermaster")
	job_possession = FALSE

/datum/theft_objective/hypospray
	name = "the chief medical officer's advanced hypospray"
	typepath = /obj/item/reagent_containers/hypospray/cmo
	protected_jobs = list("Chief Medical Officer")
	location_override = "the Chief Medical Officer's Office"

/datum/theft_objective/krav
	name = "the warden's krav maga martial arts gloves"
	typepath = /obj/item/clothing/gloves/color/black/krav_maga/sec
	protected_jobs = list("Head Of Security", "Warden")
	location_override = "the Warden's Office"

/datum/theft_objective/supermatter_sliver
	name = "a supermatter sliver"
	typepath = /obj/item/nuke_core/supermatter_sliver
	protected_jobs = list("Chief Engineer", "Station Engineer", "Life Support Specialist") //Unlike other steal objectives, all jobs in the department have easy access, and would not be noticed at all stealing this
	location_override = "Engineering. You can use the box and instructions provided to harvest the sliver"
	special_equipment = /obj/item/storage/box/syndie_kit/supermatter
	job_possession = FALSE //The CE / engineers / atmos techs do not carry around supermater slivers.

/datum/theft_objective/supermatter_sliver/check_objective_conditions() //If there is no supermatter, you don't get the objective. Yes, one could order it from cargo, but I don't think that is fair, especially if we get a map without a supermatter
	return !isnull(GLOB.main_supermatter_engine)

/datum/theft_objective/plutonium_core
	name = "the plutonium core from the station's nuclear device"
	typepath = /obj/item/nuke_core/plutonium
	location_override = "the Vault. You can use the box and instructions provided to remove the core, with some extra tools"
	special_equipment = /obj/item/storage/box/syndie_kit/nuke
	protected_jobs = list("Quartermaster")
	job_possession = FALSE

/datum/theft_objective/anomalous_particulate
	name = "Anomalous particulate."
	objective_name_overide = "Collect 3 clouds of anomalous particulate, and return with the PPPProcessor. Check your bag for further instructions"
	special_equipment = /obj/item/storage/box/syndie_kit/anomalous_particulate
	job_possession = FALSE

/datum/theft_objective/anomalous_particulate/on_hand_out_equipment(datum/objective/steal/our_objective)
	. = ..()
	var/our_chosen_owner = our_objective.get_owners()
	GLOB.anomaly_smash_track.add_tracked_mind(our_chosen_owner[1])

/datum/theft_objective/anomalous_particulate/check_special_completion(obj/item/I)
	if(!istype(I, /obj/item/ppp_processor))
		return FALSE
	var/obj/item/ppp_processor/did_we_process = I
	if(did_we_process.fully_processed_particulate)
		return TRUE

/datum/theft_objective/engraved_dusters
	name = "the quartermaster's engraved knuckledusters"
	typepath = /obj/item/melee/knuckleduster/nanotrasen
	protected_jobs = list("Quartermaster")
	location_override = "the Quartermaster's Cargo Office"

/datum/theft_objective/number
	var/min=0
	var/max=0
	var/step=1

	var/required_amount=0

/datum/theft_objective/number/New()
	if(min==max)
		required_amount=min
	else
		var/lower=min/step
		var/upper=min/step
		required_amount=rand(lower,upper)*step
	name = "[required_amount] [name]"

/datum/theft_objective/number/check_completion(datum/mind/owner)
	if(!owner.current)
		return 0
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.get_contents()
	var/found_amount=0.0
	for(var/obj/item/I in all_items)
		if(istype(I, typepath))
			found_amount += getAmountStolen(I)
	return found_amount >= required_amount

/datum/theft_objective/number/proc/getAmountStolen(obj/item/I)
	return I:amount

/datum/theft_objective/unique
	flags = THEFT_FLAG_UNIQUE

/datum/theft_objective/unique/docs_red
	name = "the \"Red\" secret documents"
	typepath = /obj/item/documents/syndicate/red
	special_equipment = /obj/item/documents/syndicate/blue
	location_override = "an EOC's possession"

/datum/theft_objective/unique/docs_blue
	name = "the \"Blue\" secret documents"
	typepath = /obj/item/documents/syndicate/blue
	special_equipment = /obj/item/documents/syndicate/red
	location_override = "an EOC's possession"

#undef THEFT_FLAG_SPECIAL
#undef THEFT_FLAG_UNIQUE

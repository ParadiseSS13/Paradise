// Theft objectives.
//
// Separated into datums so we can prevent roles from getting certain objectives.

#define THEFT_FLAG_SPECIAL 1//unused, maybe someone will use it some day, I'll leave it here for the children
#define THEFT_FLAG_UNIQUE 2

/datum/theft_objective
	var/name = "this objective is impossible, yell at a coder"
	var/typepath=/obj/effect/debugging
	var/list/protected_jobs = list()
	var/list/altitems = list()
	var/flags = 0
	var/location_override

/datum/theft_objective/proc/check_completion(var/datum/mind/owner)
	if(!owner.current)
		return 0
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.get_contents()
	for(var/obj/I in all_items) //Check for items
		if(istype(I, typepath) && check_special_completion(I))
			return 1
	return 0

/datum/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1

/datum/theft_objective/antique_laser_gun
	name = "the captain's antique laser gun"
	typepath = /obj/item/gun/energy/laser/captain
	protected_jobs = list("Captain")

/datum/theft_objective/captains_jetpack
	name = "the captain's deluxe jetpack"
	typepath = /obj/item/tank/jetpack/oxygen/captain
	protected_jobs = list("Captain")

/datum/theft_objective/captains_rapier
	name = "the captain's rapier"
	typepath = /obj/item/melee/rapier
	protected_jobs = list("Captain")

/datum/theft_objective/hoslaser
	name = "the head of security's recreated antique laser gun"
	typepath = /obj/item/gun/energy/gun/hos
	protected_jobs = list("Head Of Security")

/datum/theft_objective/hand_tele
	name = "a hand teleporter"
	typepath = /obj/item/hand_tele
	protected_jobs = list("Captain", "Research Director")

/datum/theft_objective/ai
	name = "a functional AI"
	typepath = /obj/item/aicard
	location_override = "AI Satellite. An intellicard for transportation can be found in Tech Storage, Science Department or manufactured"

datum/theft_objective/ai/check_special_completion(var/obj/item/aicard/C)
	if(..())
		for(var/mob/living/silicon/ai/A in C)
			if(istype(A, /mob/living/silicon/ai) && A.stat != 2) //See if any AI's are alive inside that card.
				return 1
	return 0

/datum/theft_objective/defib
	name = "a compact defibrillator"
	typepath = /obj/item/defibrillator/compact
	protected_jobs = list("Chief Medical Officer")

/datum/theft_objective/magboots
	name = "the chief engineer's advanced magnetic boots"
	typepath = /obj/item/clothing/shoes/magboots/advance
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/blueprints
	name = "the station blueprints"
	typepath = /obj/item/areaeditor/blueprints
	protected_jobs = list("Chief Engineer")
	altitems = list(/obj/item/photo)

/datum/objective_item/steal/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/areaeditor/blueprints))
		return 1
	if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		if(P.blueprints)
			return 1
	return 0

/datum/theft_objective/voidsuit
	name = "a nasa voidsuit"
	typepath = /obj/item/clothing/suit/space/nasavoid
	protected_jobs = list("Research Director")

/datum/theft_objective/capmedal
	name = "the medal of captaincy"
	typepath = /obj/item/clothing/accessory/medal/gold/captain
	protected_jobs = list("Captain")

/datum/theft_objective/nukedisc
	name = "the nuclear authentication disk"
	typepath = /obj/item/disk/nuclear
	protected_jobs = list("Captain")

/datum/theft_objective/reactive
	name = "the reactive teleport armor"
	typepath = /obj/item/clothing/suit/armor/reactive/teleport
	protected_jobs = list("Research Director")

/datum/theft_objective/steal/documents
	name = "any set of secret documents of any organization"
	typepath = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's

/datum/theft_objective/hypospray
	name = "the Chief Medical Officer's hypospray"
	typepath = /obj/item/reagent_containers/hypospray/CMO
	protected_jobs = list("Chief Medical Officer")

/datum/theft_objective/ablative
	name = "an ablative armor vest"
	typepath = /obj/item/clothing/suit/armor/laserproof
	protected_jobs = list("Head of Security", "Warden")

/datum/theft_objective/krav
	name = "the warden's krav maga martial arts gloves"
	typepath = /obj/item/clothing/gloves/color/black/krav_maga/sec
	protected_jobs = list("Head Of Security", "Warden")

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

/datum/theft_objective/number/check_completion(var/datum/mind/owner)
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

/datum/theft_objective/number/proc/getAmountStolen(var/obj/item/I)
	return I:amount

/datum/theft_objective/unique
	flags = THEFT_FLAG_UNIQUE

/datum/theft_objective/unique/docs_red
	name = "the \"Red\" secret documents"
	typepath = /obj/item/documents/syndicate/red

/datum/theft_objective/unique/docs_blue
	name = "the \"Blue\" secret documents"
	typepath = /obj/item/documents/syndicate/blue

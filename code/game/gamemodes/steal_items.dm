// Theft objectives.
//
// Separated into datums so we can prevent roles from getting certain objectives.

GLOBAL_LIST_INIT(potential_theft_objectives, subtypesof(/datum/theft_objective/highrisk))
GLOBAL_LIST_INIT(potential_theft_objectives_hard, subtypesof(/datum/theft_objective/hard))
GLOBAL_LIST_INIT(potential_theft_objectives_medium, subtypesof(/datum/theft_objective/medium))
GLOBAL_LIST_INIT(potential_theft_objectives_collect, subtypesof(/datum/theft_objective/collect) - /datum/theft_objective/collect/number - /datum/theft_objective/collect/number/name)

GLOBAL_LIST_INIT(ungibbable_items_types, get_ungibbable_items_types())

#define THEFT_FLAG_HIGHRISK 0
#define THEFT_FLAG_UNIQUE 	1
#define THEFT_FLAG_HARD 	2
#define THEFT_FLAG_MEDIUM 	3
#define THEFT_FLAG_COLLECT 	4

/proc/get_ungibbable_items_types()
	var/types = list()

	// Highrisk items
	for(var/highrisk_objective_type in subtypesof(/datum/theft_objective/highrisk))
		var/datum/theft_objective/highrisk_objective = highrisk_objective_type
		types += initial(highrisk_objective.typepath)

	// Cash objective
	types += /obj/item/stack/spacecash

	// Brains
	types += /obj/item/mmi/robotic_brain // Robotic and positronic
	types += /obj/item/organ/internal/brain // Regular brains
	types += /mob/living/simple_animal/diona // Possible diona brains

	return types

/datum/objective/proc/get_theft_list_objectives(var/type_theft_flag)
	switch(type_theft_flag)
		if(THEFT_FLAG_HIGHRISK)
			return GLOB.potential_theft_objectives
		if(THEFT_FLAG_HARD)
			return GLOB.potential_theft_objectives_hard
		if(THEFT_FLAG_MEDIUM)
			return GLOB.potential_theft_objectives_medium
		if(THEFT_FLAG_COLLECT)
			return GLOB.potential_theft_objectives_collect
		if(THEFT_FLAG_UNIQUE)
			return subtypesof(/datum/theft_objective/unique)
		else
			return GLOB.potential_theft_objectives

/datum/theft_objective
	var/name = "this objective is impossible, yell at a coder"
	var/obj/typepath=/obj/effect/debugging
	var/list/protected_jobs = list()
	var/list/altitems = list()
	var/flags = 0
	var/location_override

/datum/theft_objective/proc/check_completion(var/datum/mind/owner)
	if(!owner.current)
		return FALSE
	if(!isliving(owner.current))
		return FALSE
	var/list/all_items = owner.current.get_contents()
	for(var/obj/I in all_items) //Check for items
		if(istype(I, typepath) && check_special_completion(I))
			return TRUE
	return FALSE

/datum/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return TRUE



//==========================
//========Highrisk========
//==========================
/datum/theft_objective/highrisk
	flags = THEFT_FLAG_HIGHRISK

/datum/theft_objective/highrisk/antique_laser_gun
	name = "the captain's antique laser gun"
	typepath = /obj/item/gun/energy/laser/captain
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/captains_jetpack
	name = "the captain's deluxe jetpack"
	typepath = /obj/item/tank/jetpack/oxygen/captain
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/captains_rapier
	name = "the captain's rapier"
	typepath = /obj/item/melee/rapier
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/hoslaser
	name = "the head of security's X-01 multiphase energy gun"
	typepath = /obj/item/gun/energy/gun/hos
	protected_jobs = list("Head Of Security")

/datum/theft_objective/highrisk/hand_tele
	name = "a hand teleporter"
	typepath = /obj/item/hand_tele
	protected_jobs = list("Captain", "Research Director", "Chief Engineer")

/datum/theft_objective/highrisk/ai
	name = "a functional AI"
	typepath = /obj/item/aicard
	location_override = "AI Satellite. An intellicard for transportation can be found in Tech Storage, Science Department or manufactured"

/datum/theft_objective/highrisk/ai/check_special_completion(var/obj/item/aicard/C)
	if(..())
		for(var/mob/living/silicon/ai/A in C)
			if(istype(A, /mob/living/silicon/ai) && A.stat != 2) //See if any AI's are alive inside that card.
				return TRUE
	return FALSE

/datum/theft_objective/highrisk/defib
	name = "an advanced compact defibrillator"
	typepath = /obj/item/defibrillator/compact/advanced
	protected_jobs = list("Chief Medical Officer", "Paramedic")

/datum/theft_objective/highrisk/magboots
	name = "the chief engineer's advanced magnetic boots"
	typepath = /obj/item/clothing/shoes/magboots/advance
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/highrisk/blueprints
	name = "the station blueprints"
	typepath = /obj/item/areaeditor/blueprints/ce
	protected_jobs = list("Chief Engineer")
	altitems = list(/obj/item/photo)

/datum/objective_item/highrisk/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/areaeditor/blueprints/ce))
		return TRUE
	if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		if(P.blueprints)
			return TRUE
	return FALSE

/datum/theft_objective/highrisk/capmedal
	name = "the medal of captaincy"
	typepath = /obj/item/clothing/accessory/medal/gold/captain
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/nukedisc
	name = "the nuclear authentication disk"
	typepath = /obj/item/disk/nuclear
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/reactive
	name = "the reactive teleport armor"
	typepath = /obj/item/clothing/suit/armor/reactive/teleport
	protected_jobs = list("Research Director")

/datum/theft_objective/highrisk/documents
	name = "any set of secret documents of any organization"
	typepath = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's
	altitems = list(/obj/item/folder/documents)

/datum/objective_item/highrisk/documents/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/documents))
		return TRUE
	if(istype(I, /obj/item/folder/documents))
		if(!I.contents)
			return FALSE
		for(var/obj/item/content_item in I.contents)
			if(istype(content_item, /obj/item/documents))
				return TRUE
	return FALSE

/datum/theft_objective/highrisk/hypospray
	name = "the Chief Medical Officer's hypospray"
	typepath = /obj/item/reagent_containers/hypospray/CMO
	protected_jobs = list("Chief Medical Officer")

/datum/theft_objective/highrisk/ablative
	name = "an ablative armor vest"
	typepath = /obj/item/clothing/suit/armor/laserproof
	protected_jobs = list("Head of Security", "Warden")

/datum/theft_objective/highrisk/krav
	name = "the warden's krav maga martial arts gloves"
	typepath = /obj/item/clothing/gloves/color/black/krav_maga/sec
	protected_jobs = list("Head Of Security", "Warden")



//==========================
//==========Unique==========
//==========================
/datum/theft_objective/unique
	flags = THEFT_FLAG_UNIQUE

/datum/theft_objective/unique/docs_red
	name = "the \"Red\" secret documents"
	typepath = /obj/item/documents/syndicate/red

/datum/theft_objective/unique/docs_blue
	name = "the \"Blue\" secret documents"
	typepath = /obj/item/documents/syndicate/blue



//==========================
//========Hard Thief========
//==========================
/datum/theft_objective/hard
	flags = THEFT_FLAG_HARD
/datum/theft_objective/hard/capduck
	typepath = /obj/item/bikehorn/rubberducky/captain
	name = "любимую уточку капитана"
	protected_jobs = list("Captain")

/datum/theft_objective/hard/capspare
	typepath = /obj/item/card/id/captains_spare
	name = "запасную карту капитана с каюты"
	protected_jobs = list("Captain")

/datum/theft_objective/hard/goldcup
	typepath = /obj/item/reagent_containers/food/drinks/trophy/gold_cup
	name = "золотой кубок"

/datum/theft_objective/hard/belt_champion
	typepath = /obj/item/storage/belt/champion/wrestling/true
	name = "пояс Истинного Чемпиона"

/datum/theft_objective/hard/unica
	typepath = /obj/item/gun/projectile/revolver/mateba
	name = "Unica 6, авторевольвер"

/datum/theft_objective/hard/unica
	typepath = /obj/item/gun/projectile/revolver/detective
	name = ".38 Mars, заказной револьвер детектива"

/datum/theft_objective/hard/space_cap
	typepath = /obj/item/clothing/suit/space/captain
	name = "капитанский костюм для выхода в космос"

/datum/theft_objective/hard/magboots_cap
	typepath = /obj/item/clothing/shoes/magboots/security/captain
	name = "капитанские магбутсы"

/datum/theft_objective/hard/flask_cap
	typepath = /obj/item/reagent_containers/food/drinks/flask/gold
	name = "капитанскую золотую фляжку"



//==========================
//=======Medium Thief=======
//==========================
/datum/theft_objective/medium
	flags = THEFT_FLAG_MEDIUM
/datum/theft_objective/medium/sec_aviators
	typepath = /obj/item/clothing/glasses/hud/security/sunglasses/aviators
	name = "очки-авиаторы службы безопасности"
	protected_jobs = list("Head of Security", "Detective")

/datum/theft_objective/medium/space_ce
	typepath = /obj/item/clothing/suit/space/hardsuit/engine/elite
	name = "продвинутый хардсьют Главного Инженера"
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/medium/space_mime
	typepath = /obj/item/clothing/suit/space/eva/mime
	name = "космический костюм мима"
	protected_jobs = list("Mime")

/datum/theft_objective/medium/space_clown
	typepath = /obj/item/clothing/suit/space/eva/clown
	name = "космический костюм клоуна"
	protected_jobs = list("Clown")

/datum/theft_objective/medium/space_rd
	typepath = /obj/item/clothing/suit/space/hardsuit/rd
	name = "хардсьют директора исследований"
	protected_jobs = list("Research Director")

/datum/theft_objective/medium/space_bs
	typepath = /obj/item/clothing/suit/space/hardsuit/blueshield
	name = "хардсьют офицера \"Синего Щита\""
	protected_jobs = list("Blueshield")

/datum/theft_objective/medium/space_warden
	typepath = /obj/item/clothing/suit/space/hardsuit/security/warden
	name = "хардсьют смотрителя"
	protected_jobs = list("Warden")

/datum/theft_objective/medium/space_hos
	typepath = /obj/item/clothing/suit/space/hardsuit/security/hos
	name = "хардсьют главы службы безопасности"
	protected_jobs = list("Head of Security")

/datum/theft_objective/medium/rnd_logs_key
	typepath = /obj/item/paper/rnd_logs_key
	name = "подлинную бумагу RnD logs Decryption Key"
	protected_jobs = list("Research Director", "Captain")

/datum/theft_objective/medium/monitorkey
	typepath = /obj/item/paper/monitorkey
	name = "подлинную бумагу Monitor Decryption Key"
	protected_jobs = list("Research Director", "Captain", "Head of Security", "Chief Engineer", "Head of Personal")

/datum/theft_objective/medium/paper_rnd
	typepath = /obj/item/paper/safe_code
	name = "подлинную бумагу с кодами от сейфа"
	protected_jobs = list("Captain")

/datum/theft_objective/medium/tcommskey
	typepath = /obj/item/paper/tcommskey
	name = "подлинную бумагу с паролем от телекомов"
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/medium/yorick
	typepath = /obj/item/clothing/head/helmet/skull/Yorick
	name = "череп Йорика"


//==========================
//========Collection========
//==========================
/datum/theft_objective/collect
	name = ""
	flags = THEFT_FLAG_COLLECT
	typepath=null
	var/list/type_list = list()
	var/obj/item/subtype = null

	var/min=0
	var/max=0
	var/step=1
	var/required_amount=0
	var/list/wanted_items = list()

/datum/theft_objective/collect/New()
	if(min == max)
		required_amount = min
	else
		var/lower = min / step
		var/upper = max / step
		required_amount = rand(lower, upper) * step

	make_collection()

/datum/theft_objective/collect/proc/make_collection()
	if(subtype)
		type_list = subtypesof(subtype)

	if(!length(type_list))
		return

	var/list/possible_type_list = type_list.Copy()
	for(var/i=0, i < required_amount, i++)
		if(!length(possible_type_list))
			required_amount = i
			break

		var/obj/item/type_item = pick(possible_type_list)
		possible_type_list.Remove(type_item)
		wanted_items.Add(type_item)

		var/split_num = 2	//notes split
		if(i % split_num == 0)
			name += "<br>"
		name += "[initial(type_item.name)][i < required_amount-1 ? ", " : "."]"

/datum/theft_objective/collect/number/make_collection()
	wanted_items.Add(typepath)
	name = "[initial(typepath.name)] в количестве [required_amount] штук."

/datum/theft_objective/collect/check_completion(var/datum/mind/owner)
	if(!owner.current)
		return FALSE
	if(!isliving(owner.current))
		return FALSE
	if(!length(wanted_items))
		return TRUE
	var/collect_amount = 0
	var/list/all_items = owner.current.get_all_contents()
	for(var/obj/item/item in all_items)
		var/is_found = FALSE
		for(var/wanted_type in wanted_items)
			if(istype(item, wanted_type))
				is_found = TRUE
				break
		if(!is_found)
			continue
		collect_amount++

		duplicate_remove(item)
		if(!length(wanted_items))
			break

	return collect_amount >= required_amount

/datum/theft_objective/collect/proc/duplicate_remove(var/obj/item/item)
	wanted_items.Remove(item)
	return

/datum/theft_objective/collect/number/duplicate_remove(var/obj/item/item)
	return


//=======Collect Types=======
/datum/theft_objective/collect/figure
	min=6
	max=12
	step=3
	subtype = /obj/item/toy/figure

/datum/theft_objective/collect/mug
	min=3
	max=9
	step=3
	type_list = list(
		/obj/item/reagent_containers/food/drinks/mug/cap,
		/obj/item/reagent_containers/food/drinks/mug/hop,
		/obj/item/reagent_containers/food/drinks/mug/cmo,
		/obj/item/reagent_containers/food/drinks/mug/rd,
		/obj/item/reagent_containers/food/drinks/mug/hos,
		/obj/item/reagent_containers/food/drinks/mug/ce,
		/obj/item/reagent_containers/food/drinks/mug/eng,
		/obj/item/reagent_containers/food/drinks/mug/serv,
		/obj/item/reagent_containers/food/drinks/mug/sci,
		/obj/item/reagent_containers/food/drinks/mug/med,
	)

/datum/theft_objective/collect/zippo
	min=3
	max=6
	type_list = list(
		/obj/item/lighter/zippo/nt_rep,
		/obj/item/lighter/zippo/cap,
		/obj/item/lighter/zippo/hop,
		/obj/item/lighter/zippo/hos,
		/obj/item/lighter/zippo/ce,
		/obj/item/lighter/zippo/cmo,
		/obj/item/lighter/zippo/rd,
	)

/datum/theft_objective/collect/hats
	min=3
	max=6
	type_list = list(
		/obj/item/clothing/head/ntrep,
		/obj/item/clothing/head/caphat/parade,
		/obj/item/clothing/head/HoS,
		/obj/item/clothing/head/warden,
		/obj/item/clothing/head/beret/sec/warden,
		/obj/item/clothing/head/det_hat,
		/obj/item/clothing/head/beret/purple/rd,
		/obj/item/clothing/head/hopcap,
		/obj/item/clothing/head/powdered_wig,
		)

/datum/theft_objective/collect/clothes
	min=3
	max=6
	type_list = list(
		/obj/item/clothing/under/det,
		/obj/item/clothing/suit/storage/det_suit,
		/obj/item/clothing/under/rank/warden,
		/obj/item/clothing/suit/armor/vest/warden,
		/obj/item/clothing/under/rank/head_of_security,
		/obj/item/clothing/suit/armor/hos,
		/obj/item/clothing/suit/storage/labcoat/cmo,
		/obj/item/clothing/under/rank/chief_medical_officer,
		/obj/item/clothing/under/rank/research_director,
		/obj/item/clothing/under/rank/chief_engineer,
		/obj/item/clothing/suit/armor/vest/capcarapace,
		/obj/item/clothing/under/rank/captain,
		/obj/item/clothing/suit/hop_jacket,
		/obj/item/clothing/under/rank/ntrep,
		/obj/item/clothing/suit/storage/ntrep,
		/obj/item/clothing/under/rank/blueshield,
		/obj/item/clothing/suit/armor/vest/blueshield,
		/obj/item/clothing/suit/judgerobe,
		/obj/item/clothing/under/rank/clown,	//honk honk... ur panties my now
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/clothing/shoes/clown_shoes,
		/obj/item/clothing/under/mime,
		/obj/item/clothing/mask/gas/mime,
		/obj/item/clothing/under/rank/internalaffairs,
		/obj/item/clothing/suit/storage/internalaffairs,
		)

/datum/theft_objective/collect/encryption_keys
	min=3
	max=9
	step=3
	type_list = list(
		/obj/item/encryptionkey/headset_sec,
		/obj/item/encryptionkey/headset_iaa,
		/obj/item/encryptionkey/headset_medsec,
		/obj/item/encryptionkey/headset_eng,
		/obj/item/encryptionkey/headset_rob,
		/obj/item/encryptionkey/headset_med,
		/obj/item/encryptionkey/headset_sci,
		/obj/item/encryptionkey/headset_medsci,
		/obj/item/encryptionkey/heads/captain,
		/obj/item/encryptionkey/heads/rd,
		/obj/item/encryptionkey/heads/hos,
		/obj/item/encryptionkey/heads/ce,
		/obj/item/encryptionkey/heads/cmo,
		/obj/item/encryptionkey/heads/hop,
		/obj/item/encryptionkey/heads/ntrep,
		/obj/item/encryptionkey/heads/magistrate,
		/obj/item/encryptionkey/heads/blueshield,
		/obj/item/encryptionkey/headset_cargo,
		/obj/item/encryptionkey/headset_service,
		)


//=====Collection Number=====
/datum/theft_objective/collect/number/baton
	typepath = /obj/item/melee/baton
	min=4
	max=8

/datum/theft_objective/collect/number/laser
	typepath = /obj/item/gun/energy/laser
	min=3
	max=8

/datum/theft_objective/collect/number/dominator
	typepath = /obj/item/gun/energy/dominator
	min=3
	max=8

/datum/theft_objective/collect/number/wt550
	typepath = /obj/item/gun/projectile/automatic/wt550
	min=2
	max=6

/datum/theft_objective/collect/number/riot_armor
	typepath = /obj/item/clothing/suit/armor/riot
	min=2
	max=3

/datum/theft_objective/collect/number/riot_shield
	typepath = /obj/item/shield/riot
	min=2
	max=3

/datum/theft_objective/collect/number/bulletproof_armor
	typepath = /obj/item/clothing/suit/armor/bulletproof
	min=2
	max=3

/datum/theft_objective/collect/number/megaphone
	typepath = /obj/item/megaphone
	min=4
	max=7

/datum/theft_objective/collect/number/telescopic
	typepath = /obj/item/melee/classic_baton/telescopic
	min=3
	max=6

/datum/theft_objective/collect/number/sybil
	typepath = /obj/item/sibyl_system_mod
	min=4
	max=12
	step = 2

//=====Collection Number Type Name=====
/datum/theft_objective/collect/number/name
	name = ""

/datum/theft_objective/collect/number/name/make_collection()
	wanted_items.Add(typepath)
	name = "[name] в количестве [required_amount] штук."

/datum/theft_objective/collect/number/name/laser
	typepath = /obj/item/gun/energy/laser
	name = "любое оружие лазерного типа"
	min=3
	max=8

/datum/theft_objective/collect/number/name/automatic
	typepath = /obj/item/gun/projectile/automatic
	name = "любое оружие огнестрельного типа"
	min=2
	max=6

/datum/theft_objective/collect/number/name/armor
	typepath = /obj/item/clothing/suit/armor
	name = "любую нательную броню"
	min=2
	max=6

/datum/theft_objective/collect/number/name/medal
	typepath = /obj/item/clothing/accessory/medal
	name = "любых медалей"
	min=4
	max=10

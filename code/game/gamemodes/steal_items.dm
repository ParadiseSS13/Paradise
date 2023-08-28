// Theft objectives.
//
// Separated into datums so we can prevent roles from getting certain objectives.

GLOBAL_LIST_INIT(potential_theft_objectives, subtypesof(/datum/theft_objective/highrisk))
GLOBAL_LIST_INIT(potential_theft_objectives_hard, subtypesof(/datum/theft_objective/hard))
GLOBAL_LIST_INIT(potential_theft_objectives_medium, subtypesof(/datum/theft_objective/medium))
GLOBAL_LIST_INIT(potential_theft_objectives_structure, subtypesof(/datum/theft_objective/structure))
GLOBAL_LIST_INIT(potential_theft_objectives_animal, subtypesof(/datum/theft_objective/animal))
GLOBAL_LIST_INIT(potential_theft_objectives_collect, subtypesof(/datum/theft_objective/collect) - /datum/theft_objective/collect/number)

GLOBAL_LIST_INIT(ungibbable_items_types, get_ungibbable_items_types())


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


/proc/get_theft_targets_station(typepath, subtypes = TRUE, list/blacklist)
	var/list/typecache = list()
	typecache[typepath] = TRUE
	if(subtypes)
		typecache = typecacheof(typecache)
	. = list()

	var/list/stations_z = levels_by_trait(STATION_LEVEL)
	var/list/station_turfs = block(locate(1, 1, stations_z[1]), locate(world.maxx, world.maxy, stations_z[1]))

	for(var/turf/turf_check in station_turfs)
		if(ispath(typepath, /mob/living))
			var/list/turf_contents = turf_check.collect_all_atoms_of_type(/mob/living, blacklist)
			for(var/mob/living/mob_check in turf_contents)
				if(typecache[mob_check.type])
					. |= mob_check
				CHECK_TICK

		else if(ispath(typepath, /obj))
			var/list/turf_contents = turf_check.collect_all_atoms_of_type(/obj, blacklist)
			for(var/obj/obj_check in turf_contents)
				if(typecache[obj_check.type])
					. |= obj_check
				CHECK_TICK


/datum/theft_objective
	var/id
	var/name = "this objective is impossible, yell at a coder"
	var/atom/typepath = /obj/effect/debugging
	var/list/protected_jobs = list()
	var/list/altitems = list()
	var/flags = NONE
	var/location_override
	/// Do we have a special item we give to somewhen when they get this objective?
	var/special_equipment = null
	/// If a steal objective has forbidden jobs, and the forbidden jobs would not be in the possession of this item, set this to false
	var/job_possession = TRUE
	/// Range to a steal target if its not an item.
	var/range_distance = 2


/datum/theft_objective/proc/check_completion(list/owners)
	for(var/datum/mind/player in owners)
		if(!player.current)
			continue

		for(var/obj/item/item in player.current.GetAllContents())
			if((istype(item, typepath) || (item.type in altitems)) && check_special_completion(item))
				return TRUE

	return FALSE


/datum/theft_objective/proc/generate_explanation_text(datum/objective/steal/steal_objective)
	steal_objective.explanation_text = "Украсть [name]. Последнее местоположение было в [generate_location_text()]. "
	if(length(protected_jobs) && job_possession)
		steal_objective.explanation_text += "Также стоит проверить у [jointext(protected_jobs, ", ")]."


/datum/theft_objective/proc/generate_location_text()
	if(location_override)
		return location_override
	var/list/checks = get_theft_targets_station(typepath, subtypes = TRUE)
	for(var/atom/check in checks)
		return "[get_area(check)]"
	return "неизвестной зоне"


/**
 * This proc is to be used for not granting objectives if a special requirement other than job is not met.
 */
/datum/theft_objective/proc/check_objective_conditions()
	return TRUE


/**
 * For objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
 */
/datum/proc/check_special_completion(obj/item/I)
	return TRUE


//==========================
//========Highrisk========
//==========================
/datum/theft_objective/highrisk
	flags = THEFT_FLAG_HIGHRISK

/datum/theft_objective/highrisk/antique_laser_gun
	id = "cap_laser"
	name = "the captain's antique laser gun"
	typepath = /obj/item/gun/energy/laser/captain
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/captains_jetpack
	id = "cap_jetpack"
	name = "the captain's deluxe jetpack"
	typepath = /obj/item/tank/jetpack/oxygen/captain
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/captains_rapier
	id = "cap_rapier"
	name = "the captain's rapier"
	typepath = /obj/item/melee/rapier
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/hoslaser
	id = "hos_laser"
	name = "the head of security's X-01 multiphase energy gun"
	typepath = /obj/item/gun/energy/gun/hos
	protected_jobs = list("Head Of Security")

/datum/theft_objective/highrisk/hand_tele
	id = "hand_tele"
	name = "a hand teleporter"
	typepath = /obj/item/hand_tele
	protected_jobs = list("Captain", "Research Director", "Chief Engineer")

/datum/theft_objective/highrisk/ai
	id = "func_AI"
	name = "a functional AI"
	typepath = /obj/item/aicard
	location_override = "AI Satellite. An intellicard for transportation can be found in Tech Storage, Science Department or manufactured"

/datum/theft_objective/highrisk/ai/check_special_completion(obj/item/aicard/card)
	if(!istype(card))
		return FALSE
	for(var/mob/living/silicon/ai/ai in card)
		if(isAI(ai) && ai.stat != DEAD) //See if any AI's are alive inside that card.
			return TRUE
	return FALSE

/datum/theft_objective/highrisk/defib
	id = "chief_defib"
	name = "an advanced compact defibrillator"
	typepath = /obj/item/defibrillator/compact/advanced
	protected_jobs = list("Chief Medical Officer", "Paramedic")

/datum/theft_objective/highrisk/magboots
	id = "chief_magboots"
	name = "the chief engineer's advanced magnetic boots"
	typepath = /obj/item/clothing/shoes/magboots/advance
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/highrisk/blueprints
	id = "chief_blueprints"
	name = "the station blueprints"
	typepath = /obj/item/areaeditor/blueprints/ce
	protected_jobs = list("Chief Engineer")
	altitems = list(/obj/item/photo)


/datum/theft_objective/highrisk/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/areaeditor/blueprints/ce))
		return TRUE
	if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		if(P.blueprints)
			return TRUE
	return FALSE

/datum/theft_objective/highrisk/capmedal
	id = "captain_medal"
	name = "the medal of captaincy"
	typepath = /obj/item/clothing/accessory/medal/gold/captain
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/nukedisc
	id = "nuke_disc"
	name = "the nuclear authentication disk"
	typepath = /obj/item/disk/nuclear
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/reactive
	id = "reactive_armor"
	name = "the reactive teleport armor"
	typepath = /obj/item/clothing/suit/armor/reactive/teleport
	protected_jobs = list("Research Director")

/datum/theft_objective/highrisk/documents
	id = "secret_documents"
	name = "any set of secret documents of any organization"
	typepath = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's
	altitems = list(/obj/item/folder/documents)


/datum/theft_objective/highrisk/documents/check_special_completion(obj/item/I)
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
	id = "chief_hypospray"
	name = "the Chief Medical Officer's hypospray"
	typepath = /obj/item/reagent_containers/hypospray/CMO
	protected_jobs = list("Chief Medical Officer")

/datum/theft_objective/highrisk/ablative
	id = "ablative_armor"
	name = "an ablative armor vest"
	typepath = /obj/item/clothing/suit/armor/laserproof
	protected_jobs = list("Head of Security", "Warden")

/datum/theft_objective/highrisk/krav
	id = "krav_maga"
	name = "the warden's krav maga martial arts gloves"
	typepath = /obj/item/clothing/gloves/color/black/krav_maga/sec
	protected_jobs = list("Head Of Security", "Warden")

/datum/theft_objective/highrisk/supermatter_sliver
	id = "supermatter_sliver"
	name = "a supermatter sliver"
	typepath = /obj/item/nuke_core/supermatter_sliver
	protected_jobs = list("Chief Engineer", "Station Engineer", "Life Support Specialist") //Unlike other steal objectives, all jobs in the department have easy access, and would not be noticed at all stealing this
	location_override = "Engineering. You can use the box and instructions provided to harvest the sliver"
	special_equipment = /obj/item/storage/box/syndie_kit/supermatter
	job_possession = FALSE //The CE / engineers / atmos techs do not carry around supermater slivers.

/datum/theft_objective/highrisk/plutonium_core
	id = "plutonium_core"
	name = "the plutonium core from the stations nuclear device"
	typepath = /obj/item/nuke_core/plutonium
	location_override = "the Vault. You can use the box and instructions provided to remove the core, with some extra tools"
	special_equipment = /obj/item/storage/box/syndie_kit/nuke


//==========================
//==========Unique==========
//==========================
/datum/theft_objective/unique
	flags = THEFT_FLAG_UNIQUE

/datum/theft_objective/unique/docs_red
	id = "docs_red"
	name = "the \"Red\" secret documents"
	typepath = /obj/item/documents/syndicate/red

/datum/theft_objective/unique/docs_blue
	id = "docs_blue"
	name = "the \"Blue\" secret documents"
	typepath = /obj/item/documents/syndicate/blue


//==========================
//========Hard Thief========
//==========================
/datum/theft_objective/hard
	flags = THEFT_FLAG_HARD

/datum/theft_objective/hard/capduck
	id = "cap_duck"
	typepath = /obj/item/bikehorn/rubberducky/captain
	name = "любимую уточку капитана"
	protected_jobs = list("Captain")

/datum/theft_objective/hard/capspare
	id = "cap_spare"
	typepath = /obj/item/card/id/captains_spare
	name = "запасную карту капитана с каюты"
	protected_jobs = list("Captain")

/datum/theft_objective/hard/goldcup
	id = "goldcup"
	typepath = /obj/item/reagent_containers/food/drinks/trophy/gold_cup
	name = "золотой кубок"

/datum/theft_objective/hard/belt_champion
	id = "belt_champion"
	typepath = /obj/item/storage/belt/champion/wrestling/true
	name = "пояс Истинного Чемпиона"

/datum/theft_objective/hard/unica
	id = "rev_hos"
	typepath = /obj/item/gun/projectile/revolver/mateba
	name = "Unica 6, авторевольвер"

/datum/theft_objective/hard/detective
	id = "rev_dec"
	typepath = /obj/item/gun/projectile/revolver/detective
	name = ".38 Mars, заказной револьвер детектива"

/datum/theft_objective/hard/space_cap
	id = "cap_spacesuit"
	typepath = /obj/item/clothing/suit/space/captain
	name = "капитанский костюм для выхода в космос"

/datum/theft_objective/hard/magboots_cap
	id = "cap_magboots"
	typepath = /obj/item/clothing/shoes/magboots/security/captain
	name = "капитанские магбутсы"

/datum/theft_objective/hard/flask_cap
	id = "cap_flask"
	typepath = /obj/item/reagent_containers/food/drinks/flask/gold
	name = "капитанскую золотую фляжку"



//==========================
//=======Medium Thief=======
//==========================
/datum/theft_objective/medium
	flags = THEFT_FLAG_MEDIUM

/datum/theft_objective/medium/sec_aviators
	id = "sec_aviators"
	typepath = /obj/item/clothing/glasses/hud/security/sunglasses/aviators
	name = "очки-авиаторы службы безопасности"
	protected_jobs = list("Head of Security", "Detective")

/datum/theft_objective/medium/space_ce
	id = "space_ce"
	typepath = /obj/item/clothing/suit/space/hardsuit/engine/elite
	name = "продвинутый хардсьют Главного Инженера"
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/medium/space_mime
	id = "space_mime"
	typepath = /obj/item/clothing/suit/space/eva/mime
	name = "космический костюм мима"
	protected_jobs = list("Mime")

/datum/theft_objective/medium/space_clown
	id = "space_clown"
	typepath = /obj/item/clothing/suit/space/eva/clown
	name = "космический костюм клоуна"
	protected_jobs = list("Clown")

/datum/theft_objective/medium/space_rd
	id = "space_rd"
	typepath = /obj/item/clothing/suit/space/hardsuit/rd
	name = "хардсьют директора исследований"
	protected_jobs = list("Research Director")

/datum/theft_objective/medium/space_bs
	id = "space_bs"
	typepath = /obj/item/clothing/suit/space/hardsuit/blueshield
	name = "хардсьют офицера \"Синего Щита\""
	protected_jobs = list("Blueshield")

/datum/theft_objective/medium/space_warden
	id = "space_warden"
	typepath = /obj/item/clothing/suit/space/hardsuit/security/warden
	name = "хардсьют смотрителя"
	protected_jobs = list("Warden")

/datum/theft_objective/medium/space_hos
	id = "space_hos"
	typepath = /obj/item/clothing/suit/space/hardsuit/security/hos
	name = "хардсьют главы службы безопасности"
	protected_jobs = list("Head of Security")

/datum/theft_objective/medium/rnd_logs_key
	id = "rnd_logs_key"
	typepath = /obj/item/paper/rnd_logs_key
	name = "подлинную бумагу RnD logs Decryption Key"
	protected_jobs = list("Research Director", "Captain")

/datum/theft_objective/medium/monitorkey
	id = "monitorkey"
	typepath = /obj/item/paper/monitorkey
	name = "подлинную бумагу Monitor Decryption Key"
	protected_jobs = list("Research Director", "Captain", "Head of Security", "Chief Engineer", "Head of Personal")

/datum/theft_objective/medium/paper_rnd
	id = "paper_rnd"
	typepath = /obj/item/paper/safe_code
	name = "подлинную бумагу с кодами от сейфа"
	protected_jobs = list("Captain")

/datum/theft_objective/medium/tcommskey
	id = "tcommskey"
	typepath = /obj/item/paper/tcommskey
	name = "подлинную бумагу с паролем от телекомов"
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/medium/yorick
	id = "yorick"
	typepath = /obj/item/clothing/head/helmet/skull/Yorick
	name = "череп Йорика"


//==========================
//========Structures========
//==========================
/datum/theft_objective/structure
	flags = THEFT_FLAG_STRUCTURE


/datum/theft_objective/structure/check_completion(list/owners)
	for(var/datum/mind/player in owners)
		if(!player.current)
			continue

		for(var/obj/check in range(range_distance, get_turf(player.current)))
			if(istype(check, typepath))
				return TRUE

	return FALSE


/datum/theft_objective/structure/clown_statue
	id = "structure_clown"
	typepath = /obj/structure/statue/bananium/clown/unique
	name = "статую клоуна"
	protected_jobs = list("Clown", "Head of Personnel")

/datum/theft_objective/structure/mime_statue
	id = "structure_mime"
	typepath = /obj/structure/statue/tranquillite/mime/unique
	name = "статую мима"
	protected_jobs = list("Mime", "Head of Personnel")

/datum/theft_objective/structure/captain_toilet
	id = "structure_cap_toilet"
	typepath = /obj/structure/toilet/captain_toilet
	name = "унитаз капитана"

/datum/theft_objective/structure/nuclearbomb
	id = "structure_nuke_bomb"
	typepath = /obj/machinery/nuclearbomb
	name = "ядерную боеголовку"

//==========================
//==========Animals=========
//==========================
/datum/theft_objective/animal
	flags = THEFT_FLAG_ANIMAL


/datum/theft_objective/animal/check_completion(list/owners)
	for(var/datum/mind/player in owners)
		if(!player.current)
			continue

		for(var/mob/living/check in range(range_distance, get_turf(player.current)))
			if(istype(check, typepath) && check.stat != DEAD)
				return TRUE

		var/list/all_contents = player.current.GetAllContents()
		for(var/mob/living/animal in all_contents)
			if(istype(animal, typepath) && animal.stat != DEAD)
				return TRUE

	return FALSE


/datum/theft_objective/animal/ian
	id = "animal_ian"
	typepath = /mob/living/simple_animal/pet/dog/corgi/Ian
	name = "собаку по кличке Ян"
	protected_jobs = list("Head of Personnel")

/datum/theft_objective/animal/borgi
	id = "animal_borgi"
	typepath = /mob/living/simple_animal/pet/dog/corgi/borgi
	name = "собаку по кличке E-N"
	protected_jobs = list("Research Director", "Scientist", "Student Scientist", "Roboticist")

/datum/theft_objective/animal/psycho
	id = "animal_psycho"
	typepath = /mob/living/simple_animal/pet/dog/brittany/Psycho
	name = "собаку по кличке Перрито"
	protected_jobs = list("Psychiatrist", "Chief Medical Officer")

/datum/theft_objective/animal/security
	id = "animal_muhtar"
	typepath = /mob/living/simple_animal/pet/dog/security
	name = "собаку по кличке Мухтар"

/datum/theft_objective/animal/warden
	id = "animal_jule"
	typepath = /mob/living/simple_animal/pet/dog/security/warden
	name = "собаку по кличке Джульбарс"

/datum/theft_objective/animal/detective
	id = "animal_gavich"
	typepath = /mob/living/simple_animal/pet/dog/security/detective
	name = "собаку по кличке Гав-Гавыч"

/datum/theft_objective/animal/renault
	id = "animal_renault"
	typepath = /mob/living/simple_animal/pet/dog/fox/Renault
	name = "лису по кличке Renault"

/datum/theft_objective/animal/fenya
	id = "animal_fenya"
	typepath = /mob/living/simple_animal/pet/dog/fox/fennec/Fenya
	name = "лису по кличке Феня"

/datum/theft_objective/animal/floppa
	id = "animal_floppa"
	typepath = /mob/living/simple_animal/pet/cat/floppa
	name = "рысь по кличке Big Floppa"

/datum/theft_objective/animal/runtime
	id = "animal_runtime"
	typepath = /mob/living/simple_animal/pet/cat/Runtime
	name = "кота по кличке Runtime"
	protected_jobs = list("Chief Medical Officer")

/datum/theft_objective/animal/crusher
	id = "animal_crusher"
	typepath = /mob/living/simple_animal/pet/cat/birman/Crusher
	name = "кота по кличке Бедокур"
	protected_jobs = list("Mechanic", "Chief Engineer")

/datum/theft_objective/animal/paperwork
	id = "animal_paperwork"
	typepath = /mob/living/simple_animal/pet/sloth/paperwork
	name = "ленивца по кличке Paperwork"
	protected_jobs = list("Quartermaster", "Head of Personnel")

/datum/theft_objective/animal/slugcat
	id = "animal_slugcat"
	typepath = /mob/living/simple_animal/pet/slugcat/monk
	name = "слизнекота-монаха"
	protected_jobs = list("Research Director", "Scientist", "Student Scientist", "Roboticist")

/datum/theft_objective/animal/poly
	id = "animal_poly"
	typepath = /mob/living/simple_animal/parrot/Poly
	name = "попугая по кличке Поли"
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/animal/representative
	id = "animal_hamster_alex"
	typepath = /mob/living/simple_animal/mouse/hamster/Representative
	name = "хомяка по кличке Представитель Алексей"

/datum/theft_objective/animal/brain
	id = "animal_brain"
	typepath = /mob/living/simple_animal/mouse/rat/white/Brain
	name = "крысу по кличке Брейн"
	protected_jobs = list("Research Director")

/datum/theft_objective/animal/poppy
	id = "animal_poppy"
	typepath = /mob/living/simple_animal/possum/Poppy
	name = "опоссума по кличке Ключик"
	protected_jobs = list("Chief Engineer", "Station Engineer", "Life Support Specialist")


//==========================
//========Collection========
//==========================
/datum/theft_objective/collect
	name = ""
	flags = THEFT_FLAG_COLLECT
	typepath = null
	var/list/type_list = list()
	var/obj/item/subtype = null
	/// Whether our collection requires to steal n-amount of the same items or subtypes of these items
	var/steal_same_types = FALSE
	var/min = 0
	var/max = 0
	var/required_amount = 0
	var/list/wanted_items = list()


/datum/theft_objective/collect/New()
	if(min == max)
		required_amount = min
	else
		required_amount = rand(min, max)

	make_collection()


/datum/theft_objective/collect/proc/make_collection()
	if(subtype)
		type_list = subtypesof(subtype)

	if(!length(type_list))
		return

	var/list/possible_type_list = type_list.Copy()
	var/temp_name = "Собрать: "
	for(var/i in 1 to required_amount)
		if(!length(possible_type_list))
			required_amount = i
			break

		var/atom/item_typepath = pick_n_take(possible_type_list)
		wanted_items |= item_typepath

		if(i % 2 == 0)	//notes split
			temp_name += "<br>"
		temp_name += "[initial(item_typepath.name)][i < required_amount ? ", " : "."]"
	name = temp_name


/datum/theft_objective/collect/generate_explanation_text(datum/objective/steal/steal_objective)
	steal_objective.explanation_text = name


/datum/theft_objective/collect/check_completion(list/owners)
	if(!length(wanted_items))
		return TRUE

	var/collect_amount = 0
	var/list/temp_items = wanted_items.Copy()
	for(var/datum/mind/player in owners)
		if(!player.current)
			continue

		if(!length(temp_items))
			break

		for(var/obj/item/item in player.current.GetAllContents())
			var/is_found = FALSE
			for(var/wanted_type in temp_items)
				if(istype(item, wanted_type))
					if(!steal_same_types)
						temp_items -= wanted_type
					is_found = TRUE
					break

			if(!is_found)
				continue

			collect_amount++
			if(!length(temp_items))
				break

	return collect_amount >= required_amount


//=======Collect Types=======
/datum/theft_objective/collect/figure
	id = "collect_figure"
	min=6
	max=12
	subtype = /obj/item/toy/figure

/datum/theft_objective/collect/mug
	id = "collect_mug"
	min=3
	max=9
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
	id = "collect_zippo"
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
	id = "collect_hats"
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
	id = "collect_clothes"
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
	id = "collect_encryption_keys"
	min=3
	max=9
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
/datum/theft_objective/collect/number
	steal_same_types = TRUE


/datum/theft_objective/collect/number/make_collection()
	wanted_items |= typepath
	name = "Собрать: [name] в количестве [required_amount] штук[required_amount == 1 ? "и" : ""]."

/datum/theft_objective/collect/number/baton
	id = "collect_num_baton"
	typepath = /obj/item/melee/baton
	name = "оглушающие дубинки"
	min=4
	max=8

/datum/theft_objective/collect/number/laser
	id = "collect_num_laser"
	typepath = /obj/item/gun/energy/laser
	name = "лазерное оружие"
	min=3
	max=8

/datum/theft_objective/collect/number/dominator
	id = "collect_num_dominator"
	typepath = /obj/item/gun/energy/dominator
	name = "пистолеты Доминатор"
	min=3
	max=8

/datum/theft_objective/collect/number/wt550
	id = "collect_num_wt550"
	typepath = /obj/item/gun/projectile/automatic/wt550
	name = "пистолеты-пулемёты WT550"
	min=2
	max=6

/datum/theft_objective/collect/number/riot_armor
	id = "collect_num_riot_armor"
	typepath = /obj/item/clothing/suit/armor/riot
	name = "костюмы для подавления беспорядков"
	min=2
	max=3

/datum/theft_objective/collect/number/riot_shield
	id = "collect_num_riot_shield"
	typepath = /obj/item/shield/riot
	name = "щиты для подавления беспорядков"
	min=2
	max=3

/datum/theft_objective/collect/number/bulletproof_armor
	id = "collect_num_bulletproof_armor"
	typepath = /obj/item/clothing/suit/armor/bulletproof
	name = "пуленепробиваемые жилеты"
	min=2
	max=3

/datum/theft_objective/collect/number/megaphone
	id = "collect_num_megaphone"
	typepath = /obj/item/megaphone
	name = "громкоговорители"
	min=4
	max=7

/datum/theft_objective/collect/number/telescopic
	id = "collect_num_telescopic"
	typepath = /obj/item/melee/classic_baton/telescopic
	name = "телескопические дубинки"
	min=3
	max=6

/datum/theft_objective/collect/number/sybil
	id = "collect_num_sybil"
	typepath = /obj/item/sibyl_system_mod
	name = "системы Сибил"
	min=4
	max=12

/datum/theft_objective/collect/number/automatic
	id = "collect_num_automatic"
	typepath = /obj/item/gun/projectile/automatic
	name = "любое оружие огнестрельного типа"
	min=2
	max=6

/datum/theft_objective/collect/number/armor
	id = "collect_num_armor"
	typepath = /obj/item/clothing/suit/armor
	name = "любую нательную броню"
	min=2
	max=6

/datum/theft_objective/collect/number/medal
	id = "collect_num_medals"
	typepath = /obj/item/clothing/accessory/medal
	name = "любые медали"
	min=4
	max=10

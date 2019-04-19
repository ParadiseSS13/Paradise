//Food
/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	is_service = 1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue, access_weapons, access_mineral_storeroom)
	minimal_access = list(access_bar, access_maint_tunnels, access_weapons, access_mineral_storeroom)
	outfit = /datum/outfit/job/bartender

/datum/outfit/job/bartender
	name = "Bartender"
	jobtype = /datum/job/bartender

	uniform = /obj/item/clothing/under/rank/bartender
	suit = /obj/item/clothing/suit/armor/vest
	belt = /obj/item/storage/belt/bandolier/full
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/headset_service
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	pda = /obj/item/pda/bar
	backpack_contents = list(
		/obj/item/toy/russian_revolver = 1
	)

/datum/outfit/job/bartender/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.dna.SetSEState(SOBERBLOCK,1)
	genemutcheck(H, SOBERBLOCK, null, MUTCHK_FORCED)
	H.dna.default_blocks.Add(SOBERBLOCK)
	H.check_mutations = 1



/datum/job/chef
	title = "Chef"
	flag = CHEF
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	is_service = 1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue)
	minimal_access = list(access_kitchen, access_maint_tunnels)
	alt_titles = list("Cook","Culinary Artist","Butcher")
	outfit = /datum/outfit/job/chef

/datum/outfit/job/chef
	name = "Chef"
	jobtype = /datum/job/chef

	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/chefhat
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/chef



/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_flag = SUPPORT
	total_positions = 3
	spawn_positions = 2
	is_service = 1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue)
	minimal_access = list(access_hydroponics, access_morgue, access_maint_tunnels)
	alt_titles = list("Hydroponicist", "Botanical Researcher")
	outfit = /datum/outfit/job/hydro

/datum/outfit/job/hydro
	name = "Botanist"
	jobtype = /datum/job/hydro

	uniform = /obj/item/clothing/under/rank/hydroponics
	suit = /obj/item/clothing/suit/apron
	gloves = /obj/item/clothing/gloves/botanic_leather
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/headset_service
	suit_store = /obj/item/plant_analyzer
	pda = /obj/item/pda/botanist

	backpack = /obj/item/storage/backpack/botany
	satchel = /obj/item/storage/backpack/satchel_hyd
	dufflebag = /obj/item/storage/backpack/duffel/hydro



//Cargo
/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	is_supply = 1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)
	outfit = /datum/outfit/job/qm

/datum/outfit/job/qm
	name = "Quartermaster"
	jobtype = /datum/job/qm

	uniform = /obj/item/clothing/under/rank/cargo
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset/headset_cargo
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id/supply
	l_hand = /obj/item/clipboard
	pda = /obj/item/pda/quartermaster



/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_flag = SUPPORT
	total_positions = 2
	spawn_positions = 2
	is_supply = 1
	supervisors = "the quartermaster"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting, access_mineral_storeroom)
	outfit = /datum/outfit/job/cargo_tech

/datum/outfit/job/cargo_tech
	name = "Cargo Technician"
	jobtype = /datum/job/cargo_tech

	uniform = /obj/item/clothing/under/rank/cargotech
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/headset_cargo
	id = /obj/item/card/id/supply
	pda = /obj/item/pda/cargo



/datum/job/mining
	title = "Shaft Miner"
	flag = MINER
	department_flag = SUPPORT
	total_positions = 3
	spawn_positions = 3
	is_supply = 1
	supervisors = "the quartermaster"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_mining, access_mint, access_mining_station, access_mailsorting, access_maint_tunnels, access_mineral_storeroom)
	alt_titles = list("Spelunker")
	outfit = /datum/outfit/job/mining

/datum/outfit/job/mining
	name = "Shaft Miner"
	jobtype = /datum/job/mining

	uniform = /obj/item/clothing/under/rank/miner
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/workboots
	l_ear = /obj/item/radio/headset/headset_cargo/mining
	id = /obj/item/card/id/supply
	l_pocket = /obj/item/reagent_containers/food/pill/patch/styptic
	r_pocket = /obj/item/flashlight/seclite
	pda = /obj/item/pda/shaftminer
	backpack_contents = list(
		/obj/item/mining_voucher = 1,
		/obj/item/storage/bag/ore = 1
	)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng



//Griff //BS12 EDIT

/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	is_service = 1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_clown, access_theatre, access_maint_tunnels)
	minimal_access = list(access_clown, access_theatre, access_maint_tunnels)
	outfit = /datum/outfit/job/clown

/datum/outfit/job/clown
	name = "Clown"
	jobtype = /datum/job/clown

	uniform = /obj/item/clothing/under/rank/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/clown
	pda = /obj/item/pda/clown
	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/storage/fancy/crayons = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana = 1,
		/obj/item/instrument/bikehorn = 1
	)

	backpack = /obj/item/storage/backpack/clown
	satchel = /obj/item/storage/backpack/clown
	dufflebag = /obj/item/storage/backpack/duffel/clown

/datum/outfit/job/clown/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		mask = /obj/item/clothing/mask/gas/clown_hat/sexy
		uniform = /obj/item/clothing/under/rank/clown/sexy

/datum/outfit/job/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(ismachine(H))
		var/obj/item/organ/internal/cyberimp/brain/clown_voice/implant = new
		implant.insert(H)

	H.mutations.Add(CLUMSY)
	if(!ismachine(H))
		H.mutations.Add(COMIC)

//action given to antag clowns
/datum/action/innate/toggle_clumsy
	name = "Toggle Clown Clumsy"
	button_icon_state = "clown"

/datum/action/innate/toggle_clumsy/Activate()
	var/mob/living/carbon/human/H = owner
	H.mutations.Add(CLUMSY)
	active = TRUE
	background_icon_state = "bg_spell"
	UpdateButtonIcon()
	to_chat(H, "<span class='notice'>You start acting clumsy to throw suspicions off. Focus again before using weapons.</span>")

/datum/action/innate/toggle_clumsy/Deactivate()
	var/mob/living/carbon/human/H = owner
	H.mutations.Remove(CLUMSY)
	active = FALSE
	background_icon_state = "bg_default"
	UpdateButtonIcon()
	to_chat(H, "<span class='notice'>You focus and can now use weapons regularly.</span>")

/datum/job/mime
	title = "Mime"
	flag = MIME
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	is_service = 1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_mime, access_theatre, access_maint_tunnels)
	minimal_access = list(access_mime, access_theatre, access_maint_tunnels)
	outfit = /datum/outfit/job/mime

/datum/outfit/job/mime
	name = "Mime"
	jobtype = /datum/job/mime

	uniform = /obj/item/clothing/under/mime
	suit = /obj/item/clothing/suit/suspenders
	back = /obj/item/storage/backpack/mime
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/beret
	mask = /obj/item/clothing/mask/gas/mime
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/mime
	pda = /obj/item/pda/mime
	backpack_contents = list(
		/obj/item/toy/crayon/mime = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 1,
		/obj/item/cane = 1
	)

/datum/outfit/job/mime/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/sexymime
		suit = /obj/item/clothing/mask/gas/sexymime

/datum/outfit/job/mime/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		H.mind.miming = 1



/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	is_service = 1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_janitor, access_maint_tunnels)
	minimal_access = list(access_janitor, access_maint_tunnels)
	alt_titles = list("Custodial Technician")
	outfit = /datum/outfit/job/janitor

/datum/outfit/job/janitor
	name = "Janitor"
	jobtype = /datum/job/janitor

	uniform = /obj/item/clothing/under/rank/janitor
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/janitor


//More or less assistants
/datum/job/librarian
	title = "Librarian"
	flag = LIBRARIAN
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	is_service = 1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_library, access_maint_tunnels)
	minimal_access = list(access_library, access_maint_tunnels)
	alt_titles = list("Journalist")
	outfit = /datum/outfit/job/librarian

/datum/outfit/job/librarian
	name = "Librarian"
	jobtype = /datum/job/librarian

	uniform = /obj/item/clothing/under/suit_jacket/red
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/headset_service
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/barcodescanner
	l_hand = /obj/item/storage/bag/books
	pda = /obj/item/pda/librarian

/datum/job/barber
	title = "Barber"
	flag = BARBER
	department_flag = KARMA
	total_positions = 1
	spawn_positions = 1
	is_service = 1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	alt_titles = list("Hair Stylist","Beautician")
	access = list(access_maint_tunnels)
	minimal_access = list(access_maint_tunnels)
	outfit = /datum/outfit/job/barber

/datum/outfit/job/barber
	name = "Barber"
	jobtype = /datum/job/barber

	uniform = /obj/item/clothing/under/barber
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/headset_service
	backpack_contents = list(
		/obj/item/storage/box/lip_stick = 1,
		/obj/item/storage/box/barber = 1
	)

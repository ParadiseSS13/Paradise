/datum/outfit/job/bartender
	name = "Bartender"
	jobtype = /datum/job/bartender

	uniform = /obj/item/clothing/under/rank/civilian/bartender
	suit = /obj/item/clothing/suit/armor/vest
	belt = /obj/item/storage/belt/bandolier/full
	l_ear = /obj/item/radio/headset/headset_service
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	id = /obj/item/card/id/bartender
	pda = /obj/item/pda/bar
	backpack_contents = list(
		/obj/item/toy/russian_revolver = 1,
		/obj/item/eftpos = 1,
	)

/datum/outfit/job/bartender/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.dna.SetSEState(GLOB.soberblock, 1)
	singlemutcheck(H, GLOB.soberblock, MUTCHK_FORCED)
	H.dna.default_blocks.Add(GLOB.soberblock)
	H.check_mutations = 1

/datum/outfit/job/bartender/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_TABLE_LEAP, ROUNDSTART_TRAIT)
	ADD_TRAIT(H.mind, TRAIT_SLEIGHT_OF_HAND, ROUNDSTART_TRAIT)

/datum/outfit/job/chef
	name = "Chef"
	jobtype = /datum/job/chef

	uniform = /obj/item/clothing/under/rank/civilian/chef
	suit = /obj/item/clothing/suit/chef
	belt = /obj/item/storage/belt/chef
	head = /obj/item/clothing/head/chefhat
	l_ear = /obj/item/radio/headset/headset_service
	neck = /obj/item/clothing/neck/neckerchief/red
	id = /obj/item/card/id/chef
	pda = /obj/item/pda/chef
	backpack_contents = list(
		/obj/item/eftpos = 1,
	)

/datum/outfit/job/chef/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	var/datum/martial_art/cqc/under_siege/justacook = new
	justacook.teach(H) // requires mind
	ADD_TRAIT(H.mind, TRAIT_TABLE_LEAP, ROUNDSTART_TRAIT)
	ADD_TRAIT(H.mind, TRAIT_BUTCHER, JOB_TRAIT)

/datum/outfit/job/hydro
	name = "Botanist"
	jobtype = /datum/job/hydro

	uniform = /obj/item/clothing/under/rank/civilian/hydroponics
	suit = /obj/item/clothing/suit/apron
	belt = /obj/item/storage/belt/botany/full
	gloves = /obj/item/clothing/gloves/botanic_leather
	l_ear = /obj/item/radio/headset/headset_service
	l_pocket = /obj/item/storage/bag/plants/portaseeder
	r_pocket = /obj/item/storage/bag/plants
	pda = /obj/item/pda/botanist
	id = /obj/item/card/id/botanist
	backpack = /obj/item/storage/backpack/botany
	satchel = /obj/item/storage/backpack/satchel_hyd
	dufflebag = /obj/item/storage/backpack/duffel/hydro

/datum/outfit/job/hydro/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_GREEN_THUMB, JOB_TRAIT)


/datum/outfit/job/clown
	name = "Clown"
	jobtype = /datum/job/clown

	uniform = /obj/item/clothing/under/rank/civilian/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/clown
	pda = /obj/item/pda/clown
	backpack_contents = list(
		/obj/item/food/grown/banana = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/storage/fancy/crayons = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/drinks/bottle/bottleofbanana = 1,
		/obj/item/instrument/bikehorn = 1,
	)

	bio_chips = list(/obj/item/bio_chip/sad_trombone)

	backpack = /obj/item/storage/backpack/clown
	satchel = /obj/item/storage/backpack/satchel_clown
	dufflebag = /obj/item/storage/backpack/duffel/clown

/datum/outfit/job/clown/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BANANIUM_SHIPMENTS))
		backpack_contents += /obj/item/stack/sheet/mineral/bananium/fifty
	if(H.gender == FEMALE)
		mask = /obj/item/clothing/mask/gas/clown_hat/sexy
		uniform = /obj/item/clothing/under/rank/civilian/clown/sexy

/datum/outfit/job/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(ismachineperson(H))
		var/obj/item/organ/internal/cyberimp/brain/clown_voice/implant = new
		implant.insert(H)

	H.dna.SetSEState(GLOB.clumsyblock, TRUE)
	singlemutcheck(H, GLOB.clumsyblock, MUTCHK_FORCED)
	H.dna.default_blocks.Add(GLOB.clumsyblock)
	if(!ismachineperson(H))
		H.dna.SetSEState(GLOB.comicblock, TRUE)
		singlemutcheck(H, GLOB.comicblock, MUTCHK_FORCED)
		H.dna.default_blocks.Add(GLOB.comicblock)
	H.check_mutations = TRUE
	H.add_language("Clownish")
	H.AddComponent(/datum/component/slippery, H, 8 SECONDS, 100, 0, FALSE, TRUE, "slip", TRUE)

/datum/outfit/job/mime
	name = "Mime"
	jobtype = /datum/job/mime

	uniform = /obj/item/clothing/under/rank/civilian/mime
	suit = /obj/item/clothing/suit/suspenders
	back = /obj/item/storage/backpack/mime
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/beret
	mask = /obj/item/clothing/mask/gas/mime
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/mime
	pda = /obj/item/pda/mime
	backpack_contents = list(
		/obj/item/toy/crayon/mime = 1,
		/obj/item/reagent_containers/drinks/bottle/bottleofnothing = 1,
		/obj/item/cane = 1,
	)

	backpack = /obj/item/storage/backpack/mime
	satchel = /obj/item/storage/backpack/mime

/datum/outfit/job/mime/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_TRANQUILITE_SHIPMENTS))
		backpack_contents += /obj/item/stack/sheet/mineral/tranquillite/fifty
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/civilian/mime/sexy
		suit = /obj/item/clothing/mask/gas/sexymime

	if(visualsOnly)
		return

	H.DeleteComponent(/datum/component/footstep)

/datum/outfit/job/mime/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	H.mind.AddSpell(new /datum/spell/aoe/conjure/build/mime_wall(null))
	H.mind.AddSpell(new /datum/spell/mime/speak(null))
	H.mind.miming = TRUE

/datum/outfit/job/janitor
	name = "Janitor"
	jobtype = /datum/job/janitor

	uniform = /obj/item/clothing/under/rank/civilian/janitor
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/janitor
	pda = /obj/item/pda/janitor
	r_pocket = /obj/item/door_remote/janikeyring

/datum/outfit/job/janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	ADD_TRAIT(H, TRAIT_NEVER_MISSES_DISPOSALS, ROUNDSTART_TRAIT)

/datum/outfit/job/janitor/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_JANITOR, JOB_TRAIT)

/datum/outfit/job/librarian
	name = "Librarian"
	jobtype = /datum/job/librarian

	uniform = /obj/item/clothing/under/rank/civilian/librarian
	suit = /obj/item/clothing/suit/librarian
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/librarian
	pda = /obj/item/pda/librarian

/datum/outfit/job/librarian/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	for(var/la in GLOB.all_languages)
		var/datum/language/new_language = GLOB.all_languages[la]
		if(new_language.flags & (HIVEMIND|NOLIBRARIAN))
			continue
		H.add_language(la)

/datum/outfit/job/chaplain
	name = "Chaplain"
	jobtype = /datum/job/chaplain

	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/chaplain
	pda = /obj/item/pda/chaplain
	backpack_contents = list(
		/obj/item/camera/spooky = 1,
		/obj/item/nullrod = 1,
	)

/datum/outfit/job/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	if(visualsOnly)
		return

	INVOKE_ASYNC(src, PROC_REF(religion_pick), H)

/datum/outfit/job/chaplain/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_HOLY, ROUNDSTART_TRAIT)

/datum/outfit/job/chaplain/proc/religion_pick(mob/living/carbon/human/user)
	var/obj/item/storage/bible/B = new /obj/item/storage/bible(get_turf(user))
	B.customisable = TRUE // Only the initial bible is customisable
	user.put_in_l_hand(B)

	var/religion_name = "Christianity"
	var/new_religion = copytext(clean_input("You are the Chaplain. What name do you give your beliefs? Default is Christianity.", "Name change", religion_name, user), 1, MAX_NAME_LEN)

	if(!new_religion)
		new_religion = religion_name

	switch(lowertext(new_religion))
		if("christianity")
			B.name = "The Holy Bible"
		if("satanism")
			B.name = "The Unholy Bible"
		if("cthulu")
			B.name = "The Necronomicon"
		if("islam")
			B.name = "Quran"
		if("scientology")
			B.name = pick("The Biography of L. Ron Hubbard", "Dianetics")
		if("chaos")
			B.name = "The Book of Lorgar"
		if("imperium")
			B.name = "Uplifting Primer"
		if("toolboxia")
			B.name = "Toolbox Manifesto Robusto"
		if("science")
			B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
		else
			B.name = "The Holy Book of [new_religion]"
	SSblackbox.record_feedback("text", "religion_name", 1, "[new_religion]", 1)

	var/deity_name = "Space Jesus"
	var/new_deity = copytext(clean_input("Who or what do you worship? Default is Space Jesus.", "Name change", deity_name, user), 1, MAX_NAME_LEN)

	if(!length(new_deity) || (new_deity == "Space Jesus"))
		new_deity = deity_name
	B.deity_name = new_deity
	SSblackbox.record_feedback("text", "religion_deity", 1, "[new_deity]", 1)

	user.AddSpell(new /datum/spell/chaplain_bless(null))

	if(SSticker)
		SSticker.Bible_deity_name = B.deity_name

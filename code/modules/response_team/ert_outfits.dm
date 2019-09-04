/* ERT OUTFIT DATUMS */

/datum/outfit/job/centcom/response_team/imprint_idcard(mob/living/carbon/human/H)
	var/obj/item/card/id/W = H.wear_id
	if(!istype(W))
		return
	W.assignment = rt_assignment
	W.rank = W.assignment
	W.age = H.age
	W.sex = capitalize(H.gender)
	W.registered_name = H.real_name
	W.name = "[H.real_name]'s ID Card ([rt_job])"
	W.access = get_centcom_access(W.assignment)
	W.photo = get_id_photo(H)
	if(H.mind && H.mind.initial_account && H.mind.initial_account.account_number)
		W.associated_account_number = H.mind.initial_account.account_number

/datum/outfit/job/centcom/response_team/imprint_pda(mob/living/carbon/human/H)
	var/obj/item/pda/PDA = H.wear_pda
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = rt_assignment
		PDA.ownrank = rt_assignment
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"

/datum/outfit/job/centcom/response_team/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.job = rt_mob_job

//////////////////// COMMANDER ///////////////////

/datum/outfit/job/centcom/response_team/commander
	name = "RT Commander"
	rt_assignment = "Emergency Response Team Leader"
	rt_job = "Emergency Response Team Leader"
	rt_mob_job = "ERT Commander"

	uniform = /obj/item/clothing/under/rank/centcom_officer
	back = /obj/item/storage/backpack/ert/commander

	id = /obj/item/card/id/ert/commander

	l_pocket = /obj/item/pinpointer
	r_pocket = /obj/item/melee/classic_baton/telescopic

/datum/outfit/job/centcom/response_team/commander/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.rename_character(null, "[pick("Lieutenant", "Captain", "Major")] [pick(GLOB.last_names)]")
	H.age = rand(35,45)

/datum/outfit/job/centcom/response_team/commander/amber
	name = "RT Commander (Amber)"
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/color/black
	suit = /obj/item/clothing/suit/armor/vest/ert/command
	glasses = /obj/item/clothing/glasses/sunglasses

	belt = /obj/item/gun/energy/gun

	backpack_contents = list(
		/obj/item/clothing/head/helmet/ert/command = 1,
		/obj/item/clothing/mask/gas/sechailer = 1,
		/obj/item/restraints/handcuffs = 1,
		/obj/item/storage/lockbox/mindshield = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/job/centcom/response_team/commander/red
	name = "RT Commander (Red)"
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment
	)
	belt = /obj/item/gun/energy/gun/blueshield/pdw9

	backpack_contents = list(
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/gun/energy/ionrifle/carbine = 1,
		/obj/item/restraints/handcuffs = 1,
		/obj/item/clothing/shoes/magboots = 1,
		/obj/item/storage/lockbox/mindshield = 1
	)

/datum/outfit/job/centcom/response_team/commander/gamma
	name = "RT Commander (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/commander/gamma
	glasses = /obj/item/clothing/glasses/night
	suit_store = /obj/item/gun/energy/gun/blueshield/pdw9
	belt = /obj/item/gun/projectile/automatic/pistol/enforcer/lethal

	backpack_contents = list(
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/restraints/handcuffs = 1,
		/obj/item/storage/lockbox/mindshield = 1,
		/obj/item/gun/energy/ionrifle/carbine = 1,
		/obj/item/ammo_box/magazine/enforcer/lethal = 2
		)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stun,
		/obj/item/organ/internal/cyberimp/arm/flash
	)

//////////////////// SECURITY ///////////////////

/datum/outfit/job/centcom/response_team/security
	name = "RT Security"
	rt_job = "Emergency Response Team Officer"
	rt_mob_job = "ERT Security"
	uniform = /obj/item/clothing/under/rank/security
	back = /obj/item/storage/backpack/ert/security
	belt = /obj/item/storage/belt/security/response_team
	pda = /obj/item/pda/heads/ert/security
	id = /obj/item/card/id/ert/security

/datum/outfit/job/centcom/response_team/security/amber
	name = "RT Security (Amber)"
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/color/black
	suit = /obj/item/clothing/suit/armor/vest/ert/security
	suit_store = /obj/item/gun/energy/gun/advtaser
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

	r_hand = /obj/item/gun/energy/laser

	backpack_contents = list(
		/obj/item/clothing/head/helmet/ert/security = 1,
		/obj/item/clothing/mask/gas/sechailer = 1,
		/obj/item/storage/box/zipties = 1,
		/obj/item/storage/box/teargas = 1,
		/obj/item/flashlight/seclite = 1
	)

/datum/outfit/job/centcom/response_team/security/red
	name = "RT Security (Red)"

	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/color/black
	suit = /obj/item/clothing/suit/space/hardsuit/ert/security
	suit_store = /obj/item/gun/energy/gun/blueshield/pdw9
	glasses = /obj/item/clothing/glasses/sunglasses

	r_hand = /obj/item/gun/projectile/automatic/lasercarbine

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/flash,
		/obj/item/organ/internal/cyberimp/chest/nutriment,
		/obj/item/organ/internal/cyberimp/eyes/hud/security
	)

	backpack_contents = list(
		/obj/item/clothing/mask/gas/sechailer = 1,
		/obj/item/clothing/shoes/magboots = 1,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/storage/box/teargas = 1,
		/obj/item/grenade/flashbang = 1,
		/obj/item/ammo_box/magazine/laser = 2
	)

/datum/outfit/job/centcom/response_team/security/gamma
	name = "RT Security (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/security/gamma
	belt = /obj/item/storage/belt/security/response_team_gamma
	suit_store = /obj/item/gun/energy/gun/nuclear
	glasses = /obj/item/clothing/glasses/night
	l_pocket = /obj/item/restraints/legcuffs/bola/energy
	r_pocket = /obj/item/extinguisher/mini

	r_hand = /obj/item/gun/energy/immolator/multi

	backpack_contents = list(
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/whetstone = 1,
		/obj/item/storage/lockbox/t4 = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stun,
		/obj/item/organ/internal/cyberimp/arm/telebaton,
		/obj/item/organ/internal/cyberimp/chest/reviver
	)


//////////////////// ENGINEER ///////////////////

/datum/outfit/job/centcom/response_team/engineer
	name = "RT Engineer"
	rt_job = "Emergency Response Team Engineer"
	rt_mob_job = "ERT Engineering"
	back = /obj/item/storage/backpack/ert/engineer
	uniform = /obj/item/clothing/under/rank/engineer

	belt = /obj/item/storage/belt/utility/full/multitool
	pda = /obj/item/pda/heads/ert/engineering
	id = /obj/item/card/id/ert/engineering

/datum/outfit/job/centcom/response_team/engineer/amber
	name = "RT Engineer (Amber)"
	shoes = /obj/item/clothing/shoes/magboots
	gloves = /obj/item/clothing/gloves/color/yellow
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer
	suit_store = /obj/item/tank/emergency_oxygen/engi
	glasses = /obj/item/clothing/glasses/meson

	l_pocket = /obj/item/gun/energy/gun/mini
	r_pocket = /obj/item/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/clothing/mask/gas = 1,
		/obj/item/t_scanner = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/metal/fifty = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/job/centcom/response_team/engineer/red
	name = "RT Engineer (Red)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/storage/belt/utility/chief/full
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer/gamma
	suit_store = /obj/item/tank/emergency_oxygen/engi
	glasses = /obj/item/clothing/glasses/meson
	cybernetic_implants = list(
	 /obj/item/organ/internal/cyberimp/eyes/shield,
	 /obj/item/organ/internal/cyberimp/chest/nutriment
	)
	l_pocket = /obj/item/t_scanner/extended_range
	r_pocket = /obj/item/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/clothing/mask/gas = 1,
		/obj/item/rcd/preloaded = 1,
		/obj/item/rcd_ammo = 3,
		/obj/item/gun/energy/gun = 1
	)

/datum/outfit/job/centcom/response_team/engineer/gamma
	name = "RT Engineer (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/storage/belt/utility/chief/full
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer/gamma
	suit_store = /obj/item/gun/energy/gun/blueshield/pdw9
	glasses = /obj/item/clothing/glasses/meson/night

	l_pocket = /obj/item/t_scanner/extended_range
	r_pocket = /obj/item/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/rcd/combat = 1,
		/obj/item/rcd_ammo/large = 3
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stun,
		/obj/item/organ/internal/cyberimp/eyes/shield,
		/obj/item/organ/internal/cyberimp/arm/toolset
	)

//////////////////// MEDIC ///////////////////

/datum/outfit/job/centcom/response_team/medic
	name = "RT Medic"
	rt_job = "Emergency Response Team Medic"
	rt_mob_job = "ERT Medical"
	uniform = /obj/item/clothing/under/rank/medical
	back = /obj/item/storage/backpack/ert/medical
	pda = /obj/item/pda/heads/ert/medical
	id = /obj/item/card/id/ert/medic

/datum/outfit/job/centcom/response_team/medic/amber
	name = "RT Medic (Amber)"

	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/color/latex
	suit = /obj/item/clothing/suit/armor/vest/ert/medical
	suit_store = /obj/item/gun/energy/gun/mini
	glasses = /obj/item/clothing/glasses/hud/health

	belt = /obj/item/storage/belt/medical/surgery/loaded

	l_pocket = /obj/item/reagent_containers/hypospray/safety/ert
	r_pocket = /obj/item/melee/classic_baton/telescopic

	l_hand = /obj/item/defibrillator/loaded

	backpack_contents = list(
		/obj/item/clothing/head/helmet/ert/medical = 1,
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/storage/firstaid/adv = 1,
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/box/autoinjectors = 1,
		/obj/item/roller = 1,
		/obj/item/storage/pill_bottle/ert = 1,
		/obj/item/flashlight = 1,
		/obj/item/healthupgrade = 1,
		/obj/item/handheld_defibrillator = 1
	)

/datum/outfit/job/centcom/response_team/medic/red
	name = "RT Medic (Red)"
	rt_mob_job = "ERT Medical"
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	suit = /obj/item/clothing/suit/space/hardsuit/ert/medical
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	suit_store = /obj/item/gun/energy/gun
	cybernetic_implants = list(
	 /obj/item/organ/internal/cyberimp/arm/surgery,
	 /obj/item/organ/internal/cyberimp/chest/nutriment
	)
	belt = /obj/item/defibrillator/compact/loaded

	l_pocket = /obj/item/reagent_containers/hypospray/safety/ert
	r_pocket = /obj/item/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/storage/firstaid/toxin = 1,
		/obj/item/storage/firstaid/brute = 1,
		/obj/item/storage/firstaid/fire = 1,
		/obj/item/storage/box/autoinjectors = 1,
		/obj/item/roller = 1,
		/obj/item/clothing/shoes/magboots = 1,
		/obj/item/bodyanalyzer = 1,
		/obj/item/healthupgrade = 1,
		/obj/item/handheld_defibrillator = 1
	)

/datum/outfit/job/centcom/response_team/medic/gamma
	name = "RT Medic (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/medical/gamma
	glasses = /obj/item/clothing/glasses/night
	suit_store = /obj/item/gun/energy/gun/blueshield/pdw9

	belt = /obj/item/defibrillator/compact/loaded

	l_pocket = /obj/item/reagent_containers/hypospray/combat/nanites
	r_pocket = /obj/item/reagent_containers/hypospray/autoinjector

	backpack_contents = list(
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/bodyanalyzer/advanced = 1,
		/obj/item/extinguisher/mini = 1,
		/obj/item/roller = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/handheld_defibrillator = 1

		)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/surgery/l,
		/obj/item/organ/internal/cyberimp/arm/medibeam,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/obj/item/organ/internal/cyberimp/brain/anti_stun
	)

//////////////////// PARANORMAL ///////////////////

/datum/outfit/job/centcom/response_team/paranormal
	name = "RT Paranormal"
	rt_job = "Emergency Response Team Inquisitor"
	rt_mob_job = "ERT Paranormal"
	uniform = /obj/item/clothing/under/rank/chaplain
	back = /obj/item/storage/backpack/ert/security
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/radio/headset/ert/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	belt = /obj/item/storage/belt/security/response_team
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	backpack_contents = list(
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/storage/box/zipties = 1,
		/obj/item/flashlight/seclite = 1
		)

/datum/outfit/job/centcom/response_team/paranormal/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind)
		H.mind.isholy = TRUE

/datum/outfit/job/centcom/response_team/paranormal/amber
	name = "RT Paranormal (Amber)"
	suit = /obj/item/clothing/suit/armor/vest/ert/security/paranormal
	head = /obj/item/clothing/head/helmet/ert/security/paranormal
	suit_store = /obj/item/gun/energy/gun/advtaser
	r_pocket = /obj/item/nullrod

/datum/outfit/job/centcom/response_team/paranormal/red
	name = "RT Paranormal (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	suit_store = /obj/item/gun/energy/gun
	r_pocket = /obj/item/nullrod/ert
	glasses = /obj/item/clothing/glasses/sunglasses

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment
	)

/datum/outfit/job/centcom/response_team/paranormal/gamma
	name = "RT Paranormal (Gamma)"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	suit_store = /obj/item/gun/energy/gun/nuclear
	l_pocket = /obj/item/grenade/clusterbuster/holy
	shoes = /obj/item/clothing/shoes/magboots/advance
	glasses = /obj/item/clothing/glasses/night
	r_pocket = /obj/item/nullrod/ert

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stun
	)

//////////////////// JANITORIAL ///////////////////

/datum/outfit/job/centcom/response_team/janitorial
	name = "RT Janitor"
	rt_job = "Emergency Response Team Janitor"
	rt_mob_job = "ERT Janitor"
	uniform = /obj/item/clothing/under/color/purple
	back = /obj/item/storage/backpack/ert/janitor
	belt = /obj/item/storage/belt/janitor/full
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/galoshes
	l_ear = /obj/item/radio/headset/ert/alt
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	l_pocket = /obj/item/melee/classic_baton/telescopic
	backpack_contents = list(
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/storage/bag/trash = 1,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/holosign_creator = 1,
		/obj/item/flashlight = 1)

/datum/outfit/job/centcom/response_team/janitorial/amber
	name = "RT Janitor (Amber)"
	suit = /obj/item/clothing/suit/armor/vest/ert/janitor
	head = /obj/item/clothing/head/helmet/ert/janitor
	glasses = /obj/item/clothing/glasses/sunglasses

	r_hand = /obj/item/gun/energy/disabler

/datum/outfit/job/centcom/response_team/janitorial/red
	name = "RT Janitor (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/janitor
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

	r_pocket = /obj/item/scythe/tele
	l_pocket = /obj/item/gun/energy/gun/mini

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/advmop,
		/obj/item/organ/internal/cyberimp/chest/nutriment
	)

/datum/outfit/job/centcom/response_team/janitorial/gamma
	name = "RT Janitor (Gamma)"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/janitor/gamma
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/combat
	suit_store = /obj/item/gun/energy/gun
	l_pocket = /obj/item/grenade/clusterbuster/cleaner
	r_pocket = /obj/item/scythe/tele
	shoes = /obj/item/clothing/shoes/magboots/advance

	backpack_contents = list(
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/storage/bag/trash/bluespace = 1,
		/obj/item/reagent_containers/spray/cleaner = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/advmop
	)

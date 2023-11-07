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
	uniform = /obj/item/clothing/under/rank/centcom/ert/commander
	back = /obj/item/storage/backpack/ert/commander
	l_ear = /obj/item/radio/headset/ert/alt/commander
	id = /obj/item/card/id/ert/commander
	l_pocket = /obj/item/pinpointer
	r_pocket = /obj/item/melee/classic_baton/telescopic

/datum/outfit/job/centcom/response_team/commander/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.rename_character(null, "[pick("Lieutenant", "Captain", "Major")] [pick(GLOB.last_names)]")
	H.age = rand(35, 45)

/datum/outfit/job/centcom/response_team/commander/amber
	name = "RT Commander (Amber)"
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/armor/vest/ert/command
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer
	belt = /obj/item/gun/energy/gun

	backpack_contents = list(
		/obj/item/clothing/head/helmet/ert/command = 1,
		/obj/item/restraints/handcuffs = 1,
		/obj/item/storage/box/mindshield = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/job/centcom/response_team/commander/red
	name = "RT Commander (Red)"
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	belt = /obj/item/gun/energy/gun/blueshield/pdw9

	backpack_contents = list(
		/obj/item/camera_bug/ert = 1,
		/obj/item/door_remote/omni = 1,
		/obj/item/restraints/handcuffs = 1,
		/obj/item/clothing/shoes/magboots = 1,
		/obj/item/storage/box/mindshield = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/commander/gamma
	name = "RT Commander (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/elite
	back = /obj/item/mod/control/pre_equipped/responsory/commander
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	belt = /obj/item/gun/projectile/automatic/pistol/enforcer/lethal

	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/storage/box/mindshield = 1,
		/obj/item/camera_bug/ert = 1,
		/obj/item/door_remote/omni = 1,
		/obj/item/ammo_box/magazine/enforcer/lethal = 2,
		/obj/item/gun/energy/gun/blueshield/pdw9 = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/cyberimp/arm/flash
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

//////////////////// SECURITY ///////////////////

/datum/outfit/job/centcom/response_team/security
	name = "RT Security"
	rt_assignment = "Emergency Response Team Officer"
	rt_job = "Emergency Response Team Officer"
	rt_mob_job = "ERT Security"
	uniform = /obj/item/clothing/under/rank/centcom/ert/security
	back = /obj/item/storage/backpack/ert/security
	belt = /obj/item/storage/belt/security/response_team
	pda = /obj/item/pda/heads/ert/security
	id = /obj/item/card/id/ert/security

/datum/outfit/job/centcom/response_team/security/amber
	name = "RT Security (Amber)"
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/armor/vest/ert/security
	suit_store = /obj/item/gun/energy/disabler
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer
	l_hand = /obj/item/gun/energy/laser

	backpack_contents = list(
		/obj/item/clothing/head/helmet/ert/security = 1,
		/obj/item/storage/box/zipties = 1,
		/obj/item/storage/box/teargas = 1,
		/obj/item/flashlight/seclite = 1
	)

/datum/outfit/job/centcom/response_team/security/red
	name = "RT Security (Red)"
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/security
	suit_store = /obj/item/gun/energy/gun/blueshield/pdw9
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer
	l_hand = /obj/item/gun/projectile/automatic/lasercarbine

	backpack_contents = list(
		/obj/item/clothing/shoes/magboots = 1,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/grenade/flashbang = 2,
		/obj/item/ammo_box/magazine/laser/ert = 2
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/flash,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/security
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/security/gamma
	name = "RT Security (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/elite
	belt = /obj/item/storage/belt/security/response_team_gamma
	back = /obj/item/mod/control/pre_equipped/responsory/security
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	l_pocket = /obj/item/restraints/legcuffs/bola/energy
	r_pocket = /obj/item/extinguisher/mini
	l_hand = /obj/item/gun/energy/immolator/multi

	backpack_contents = list(
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/whetstone = 1,
		/obj/item/storage/box/breaching = 1,
		/obj/item/gun/energy/gun/nuclear = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/cyberimp/arm/telebaton,
		/obj/item/organ/internal/cyberimp/chest/reviver/hardened
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

//////////////////// ENGINEER ///////////////////

/datum/outfit/job/centcom/response_team/engineer
	name = "RT Engineer"
	rt_assignment = "Emergency Response Team Engineer"
	rt_job = "Emergency Response Team Engineer"
	rt_mob_job = "ERT Engineering"
	back = /obj/item/storage/backpack/ert/engineer
	uniform = /obj/item/clothing/under/rank/centcom/ert/engineer
	pda = /obj/item/pda/heads/ert/engineering
	id = /obj/item/card/id/ert/engineering
	belt = /obj/item/storage/belt/utility/chief/full

/datum/outfit/job/centcom/response_team/engineer/amber
	name = "RT Engineer (Amber)"
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer
	suit_store = /obj/item/tank/internals/emergency_oxygen/engi
	glasses = /obj/item/clothing/glasses/meson/engine
	mask = /obj/item/clothing/mask/gas
	l_pocket = /obj/item/gun/energy/gun/mini
	r_pocket = /obj/item/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/t_scanner = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/metal/fifty = 1,
		/obj/item/flashlight = 1,
		/obj/item/rpd = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/brain/wire_interface/hardened,
		/obj/item/organ/internal/eyes/cybernetic/shield
	)

/datum/outfit/job/centcom/response_team/engineer/red
	name = "RT Engineer (Red)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer/gamma
	suit_store = /obj/item/tank/internals/emergency_oxygen/engi
	glasses = /obj/item/clothing/glasses/meson/engine
	mask = /obj/item/clothing/mask/gas
	l_pocket = /obj/item/t_scanner
	r_pocket = /obj/item/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/rcd/preloaded = 1,
		/obj/item/rcd_ammo = 3,
		/obj/item/gun/energy/gun = 1,
		/obj/item/rpd = 1
	)

	cybernetic_implants = list(
	/obj/item/organ/internal/eyes/cybernetic/shield,
	/obj/item/organ/internal/cyberimp/chest/nutriment/hardened,
	/obj/item/organ/internal/cyberimp/brain/wire_interface/hardened
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/engineer/gamma
	name = "RT Engineer (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/elite
	back = /obj/item/mod/control/pre_equipped/responsory/engineer
	glasses = /obj/item/clothing/glasses/meson/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	l_pocket = /obj/item/t_scanner
	r_pocket = /obj/item/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/rcd/combat = 1,
		/obj/item/rcd_ammo/large = 3,
		/obj/item/gun/energy/gun/blueshield/pdw9 = 1,
		/obj/item/rpd = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/eyes/cybernetic/shield,
		/obj/item/organ/internal/cyberimp/arm/toolset,
		/obj/item/organ/internal/cyberimp/brain/wire_interface/hardened
	)

	implants = list(/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

//////////////////// MEDIC ///////////////////

/datum/outfit/job/centcom/response_team/medic
	name = "RT Medic"
	rt_assignment = "Emergency Response Team Medic"
	rt_job = "Emergency Response Team Medic"
	rt_mob_job = "ERT Medical"
	uniform = /obj/item/clothing/under/rank/centcom/ert/medical
	back = /obj/item/storage/backpack/ert/medical
	pda = /obj/item/pda/heads/ert/medical
	id = /obj/item/card/id/ert/medic

/datum/outfit/job/centcom/response_team/medic/amber
	name = "RT Medic (Amber)"
	head = /obj/item/clothing/head/helmet/ert/medical
	shoes = /obj/item/clothing/shoes/white
	suit = /obj/item/clothing/suit/armor/vest/ert/medical
	suit_store = /obj/item/gun/energy/gun/mini
	glasses = /obj/item/clothing/glasses/hud/health
	belt = /obj/item/storage/belt/medical/surgery/loaded
	l_pocket = /obj/item/reagent_containers/hypospray/safety/ert
	r_pocket = /obj/item/melee/classic_baton/telescopic
	l_hand = /obj/item/defibrillator/loaded

	backpack_contents = list(
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/storage/firstaid/ert_amber = 1,
		/obj/item/storage/box/autoinjectors = 1,
		/obj/item/roller/holo = 1,
		/obj/item/flashlight = 1,
		/obj/item/handheld_defibrillator = 1,
		/obj/item/soap/nanotrasen = 1
	)

/datum/outfit/job/centcom/response_team/medic/red
	name = "RT Medic (Red)"
	rt_mob_job = "ERT Medical"
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/hardsuit/ert/medical
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	suit_store = /obj/item/gun/energy/gun
	belt = /obj/item/defibrillator/compact/advanced/loaded
	l_pocket = /obj/item/reagent_containers/hypospray/safety/ert
	r_pocket = /obj/item/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/storage/firstaid/ert = 1,
		/obj/item/storage/box/autoinjectors = 1,
		/obj/item/roller/holo = 1,
		/obj/item/bodyanalyzer = 1,
		/obj/item/handheld_defibrillator = 1,
		/obj/item/storage/pill_bottle/ert_red = 1,
		/obj/item/storage/pill_bottle/patch_pack/ert = 1,
		/obj/item/soap/nanotrasen = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/surgery,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/medic/gamma
	name = "RT Medic (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/elite
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	back = /obj/item/mod/control/pre_equipped/responsory/medic
	belt = /obj/item/storage/belt/medical //No need for belt defib, they got the built in ones. This gives them some extra storage.
	l_pocket = /obj/item/reagent_containers/hypospray/combat/nanites
	r_pocket = /obj/item/reagent_containers/hypospray/autoinjector/epinephrine

	backpack_contents = list(
		/obj/item/bodyanalyzer/advanced = 1,
		/obj/item/storage/firstaid/ert = 1,
		/obj/item/extinguisher/mini = 1,
		/obj/item/roller/holo = 1,
		/obj/item/handheld_defibrillator = 1,
		/obj/item/storage/box/autoinjectors = 1,
		/obj/item/storage/pill_bottle/ert_gamma = 1,
		/obj/item/storage/pill_bottle/patch_pack/ert/gamma = 1,
		/obj/item/gun/energy/gun/blueshield/pdw9 = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/surgery/l,
		/obj/item/organ/internal/cyberimp/arm/medibeam,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

//////////////////// PARANORMAL ///////////////////

/datum/outfit/job/centcom/response_team/paranormal
	name = "RT Paranormal"
	rt_assignment = "Emergency Response Team Inquisitor"
	rt_job = "Emergency Response Team Inquisitor"
	rt_mob_job = "ERT Paranormal"
	uniform = /obj/item/clothing/under/rank/centcom/ert/chaplain
	back = /obj/item/storage/backpack/ert/security
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/radio/headset/ert/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	belt = /obj/item/storage/belt/security/response_team
	id = /obj/item/card/id/ert/paranormal
	pda = /obj/item/pda/heads/ert/paranormal

	backpack_contents = list(
		/obj/item/storage/box/zipties = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/storage/bible = 1
	)

/datum/outfit/job/centcom/response_team/paranormal/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(istype(H.mind))
		ADD_TRAIT(H.mind, TRAIT_HOLY, ROUNDSTART_TRAIT)

/datum/outfit/job/centcom/response_team/paranormal/amber
	name = "RT Paranormal (Amber)"
	suit = /obj/item/clothing/suit/armor/vest/ert/security/paranormal
	head = /obj/item/clothing/head/helmet/ert/security/paranormal
	suit_store = /obj/item/gun/energy/disabler
	r_pocket = /obj/item/nullrod

/datum/outfit/job/centcom/response_team/paranormal/red
	name = "RT Paranormal (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal
	suit_store = /obj/item/gun/energy/gun
	r_pocket = /obj/item/nullrod/ert
	glasses = /obj/item/clothing/glasses/sunglasses

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/paranormal/gamma
	name = "RT Paranormal (Gamma)"
	l_pocket = /obj/item/grenade/clusterbuster/holy
	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/chaplain
	shoes = /obj/item/clothing/shoes/magboots/elite
	glasses = /obj/item/clothing/glasses/night
	r_pocket = /obj/item/nullrod/ert

	backpack_contents = list(
		/obj/item/storage/box/zipties = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/gun/energy/gun/nuclear = 1,
		/obj/item/storage/bible = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

//////////////////// JANITORIAL ///////////////////

/datum/outfit/job/centcom/response_team/janitorial
	name = "RT Janitor"
	rt_assignment = "Emergency Response Team Janitor"
	rt_job = "Emergency Response Team Janitor"
	rt_mob_job = "ERT Janitor"
	uniform = /obj/item/clothing/under/rank/centcom/ert/janitor
	back = /obj/item/storage/backpack/ert/janitor
	belt = /obj/item/storage/belt/janitor/full
	shoes = /obj/item/clothing/shoes/galoshes/dry
	l_ear = /obj/item/radio/headset/ert/alt
	id = /obj/item/card/id/ert/janitorial
	pda = /obj/item/pda/heads/ert/janitor
	l_pocket = /obj/item/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/push_broom,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/melee/flyswatter = 1
	)

/datum/outfit/job/centcom/response_team/janitorial/amber
	name = "RT Janitor (Amber)"
	suit = /obj/item/clothing/suit/armor/vest/ert/janitor
	head = /obj/item/clothing/head/helmet/ert/janitor
	glasses = /obj/item/clothing/glasses/sunglasses
	r_pocket = /obj/item/flashlight/seclite
	suit_store = /obj/item/gun/energy/disabler

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/janitorial/advanced
	)

/datum/outfit/job/centcom/response_team/janitorial/red
	name = "RT Janitor (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/janitor
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	shoes = /obj/item/clothing/shoes/galoshes/dry/lightweight
	r_pocket = /obj/item/scythe/tele
	suit_store = /obj/item/gun/energy/gun

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/janitorial/advanced,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/janitorial/gamma
	name = "RT Janitor (Gamma)"
	glasses = /obj/item/clothing/glasses/night
	back = /obj/item/mod/control/pre_equipped/responsory/janitor
	r_pocket = /obj/item/scythe/tele
	shoes = /obj/item/clothing/shoes/magboots/elite

	backpack_contents = list(
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/grenade/clusterbuster/cleaner = 1,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/push_broom = 1,
		/obj/item/gun/energy/gun/nuclear = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/arm/janitorial/advanced,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened
	)

	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/death_alarm
	)

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


/datum/outfit/job/centcom/response_team
	name = "Response team"
	var/rt_assignment = "Emergency Response Team Member"
	var/rt_job = "This is a bug"
	var/rt_mob_job = "This is a bug" // The job set on the actual mob.
	allow_backbag_choice = FALSE
	allow_loadout = FALSE

	pda = /obj/item/pda/heads/ert
	id = /obj/item/card/id/ert
	l_ear = /obj/item/radio/headset/ert/alt
	box = /obj/item/storage/box/responseteam
	uniform = /obj/item/clothing/under/rank/centcom/sensor
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat

	implants = list(
		/obj/item/implant/death_alarm,
		/obj/item/implant/mindshield)

//////////////////// COMMANDER ///////////////////

/datum/outfit/job/centcom/response_team/commander
	name = "RT Commander"
	rt_assignment = "Emergency Response Team Leader"
	rt_job = "Emergency Response Team Leader"
	rt_mob_job = "ERT Commander"

	back = /obj/item/storage/backpack/ert/commander
	l_ear = /obj/item/radio/headset/ert/alt/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	belt = /obj/item/storage/belt/military/assault/ert

	id = /obj/item/card/id/ert/commander

	backpack_contents = list(/obj/item/pinpointer)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/telebaton,
		/obj/item/organ/internal/cyberimp/eyes/hud/security)

/datum/outfit/job/centcom/response_team/commander/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.rename_character(null, "[pick("Lieutenant", "Captain", "Major")] [pick(GLOB.last_names)]")
	H.age = rand(35,45)

/datum/outfit/job/centcom/response_team/commander/amber
	name = "RT Commander (Amber)"
	head = /obj/item/clothing/head/helmet/ert/command
	suit = /obj/item/clothing/suit/armor/vest/ert/command
	mask = /obj/item/clothing/mask/gas/sechailer

/datum/outfit/job/centcom/response_team/commander/red
	name = "RT Commander (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/commander
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	shoes = /obj/item/clothing/shoes/magboots

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened)

	backpack_contents = list(
		/obj/item/camera_bug/ert = 1,
		/obj/item/door_remote/omni = 1)

/datum/outfit/job/centcom/response_team/commander/gamma
	name = "RT Commander (Gamma)"
	back = /obj/item/mod/control/pre_equipped/responsory/commander
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat

	backpack_contents = list(
		/obj/item/camera_bug/ert = 1,
		/obj/item/door_remote/omni = 1,
		/obj/item/gun/projectile/automatic/pistol/enforcer/lethal = 1,
		/obj/item/ammo_box/magazine/enforcer/lethal = 2)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/cyberimp/arm/flash)

//////////////////// SECURITY ///////////////////

/datum/outfit/job/centcom/response_team/security
	name = "RT Security"
	rt_assignment = "Emergency Response Team Officer"
	rt_job = "Emergency Response Team Officer"
	rt_mob_job = "ERT Security"
	uniform = /obj/item/clothing/under/rank/security/officer/sensor
	mask = /obj/item/clothing/mask/gas/sechailer
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/ert/security
	pda = /obj/item/pda/heads/ert/security
	id = /obj/item/card/id/ert/security

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/telebaton)

/datum/outfit/job/centcom/response_team/security/amber
	name = "RT Security (Amber)"
	head = /obj/item/clothing/head/helmet/ert/security
	suit = /obj/item/clothing/suit/armor/vest/ert/security
	belt = /obj/item/storage/belt/security/response_team

	backpack_contents = list(
		/obj/item/flashlight/seclite = 1)

/datum/outfit/job/centcom/response_team/security/red
	name = "RT Security (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/security
	belt =/obj/item/storage/belt/military/assault/ert
	shoes = /obj/item/clothing/shoes/magboots

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/telebaton,
		/obj/item/organ/internal/cyberimp/arm/flash,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/security)

/datum/outfit/job/centcom/response_team/security/gamma
	name = "RT Security (Gamma)"
	belt =/obj/item/storage/belt/military/assault/ert
	back = /obj/item/mod/control/pre_equipped/responsory/security
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat

	backpack_contents = list(
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/whetstone = 1,
		/obj/item/storage/box/breaching = 1)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/telebaton,
		/obj/item/organ/internal/cyberimp/arm/flash,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/cyberimp/chest/reviver/hardened)

//////////////////// ENGINEER ///////////////////

/datum/outfit/job/centcom/response_team/engineer
	name = "RT Engineer"
	rt_assignment = "Emergency Response Team Engineer"
	rt_job = "Emergency Response Team Engineer"
	rt_mob_job = "ERT Engineering"
	back = /obj/item/storage/backpack/ert/engineer
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	belt = /obj/item/storage/belt/utility/full/multitool
	pda = /obj/item/pda/heads/ert/engineering
	id = /obj/item/card/id/ert/engineering

/datum/outfit/job/centcom/response_team/engineer/amber
	name = "RT Engineer (Amber)"
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer
	suit_store = /obj/item/tank/internals/emergency_oxygen/engi
	glasses = /obj/item/clothing/glasses/meson/engine
	mask = /obj/item/clothing/mask/gas
	cybernetic_implants = list(/obj/item/organ/internal/cyberimp/brain/wire_interface/hardened)

	backpack_contents = list(
		/obj/item/t_scanner = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/metal/fifty = 1,
		/obj/item/flashlight = 1)

/datum/outfit/job/centcom/response_team/engineer/red
	name = "RT Engineer (Red)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	belt = /obj/item/storage/belt/utility/chief/full
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer/gamma
	suit_store = /obj/item/tank/internals/emergency_oxygen/engi
	glasses = /obj/item/clothing/glasses/meson/engine
	mask = /obj/item/clothing/mask/gas
	cybernetic_implants = list(
	/obj/item/organ/internal/eyes/cybernetic/shield,
	/obj/item/organ/internal/cyberimp/chest/nutriment/hardened,
	/obj/item/organ/internal/cyberimp/brain/wire_interface/hardened
	)
	l_pocket = /obj/item/t_scanner

	backpack_contents = list(
		/obj/item/rcd/preloaded = 1,
		/obj/item/rcd_ammo = 3)

/datum/outfit/job/centcom/response_team/engineer/gamma
	name = "RT Engineer (Gamma)"
	back = /obj/item/mod/control/pre_equipped/responsory/engineer
	belt = /obj/item/storage/belt/utility/chief/full
	glasses = /obj/item/clothing/glasses/meson/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat

	l_pocket = /obj/item/t_scanner

	backpack_contents = list(
		/obj/item/rcd/combat = 1,
		/obj/item/rcd_ammo/large = 3)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/eyes/cybernetic/shield,
		/obj/item/organ/internal/cyberimp/arm/toolset,
		/obj/item/organ/internal/cyberimp/brain/wire_interface/hardened)

//////////////////// MEDIC ///////////////////

/datum/outfit/job/centcom/response_team/medic
	name = "RT Medic"
	rt_assignment = "Emergency Response Team Medic"
	rt_job = "Emergency Response Team Medic"
	rt_mob_job = "ERT Medical"
	uniform = /obj/item/clothing/under/rank/medical/doctor
	mask = /obj/item/clothing/mask/gas/sechailer
	back = /obj/item/storage/backpack/ert/medical
	pda = /obj/item/pda/heads/ert/medical
	id = /obj/item/card/id/ert/medic
	l_pocket = /obj/item/reagent_containers/hypospray/safety/ert

/datum/outfit/job/centcom/response_team/medic/amber
	name = "RT Medic (Amber)"
	head = /obj/item/clothing/head/helmet/ert/medical
	suit = /obj/item/clothing/suit/armor/vest/ert/medical
	belt = /obj/item/storage/belt/medical/surgery/loaded
	glasses = /obj/item/clothing/glasses/hud/health

	backpack_contents = list(
		/obj/item/storage/firstaid/ert_amber = 1,
		/obj/item/storage/box/autoinjectors = 1,
		/obj/item/roller/holo = 1,
		/obj/item/flashlight = 1,
		/obj/item/handheld_defibrillator = 1,
		/obj/item/soap/nanotrasen = 1,
		/obj/item/defibrillator/compact/advanced/loaded = 1)

/datum/outfit/job/centcom/response_team/medic/red
	name = "RT Medic (Red)"
	rt_mob_job = "ERT Medical"
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/hardsuit/ert/medical
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	belt = /obj/item/storage/belt/medical

	backpack_contents = list(
		/obj/item/storage/firstaid/ert = 1,
		/obj/item/storage/box/autoinjectors = 1,
		/obj/item/roller/holo = 1,
		/obj/item/bodyanalyzer = 1,
		/obj/item/handheld_defibrillator = 1,
		/obj/item/storage/pill_bottle/ert_red = 1,
		/obj/item/storage/pill_bottle/patch_pack/ert = 1,
		/obj/item/soap/nanotrasen = 1,
		/obj/item/defibrillator/compact/advanced/loaded = 1)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/surgery,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened)

/datum/outfit/job/centcom/response_team/medic/gamma
	name = "RT Medic (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	back = /obj/item/mod/control/pre_equipped/responsory/medic
	belt = /obj/item/storage/belt/medical

	backpack_contents = list(
		/obj/item/bodyanalyzer/advanced = 1,
		/obj/item/storage/firstaid/ert = 1,
		/obj/item/extinguisher/mini = 1,
		/obj/item/roller/holo = 1,
		/obj/item/handheld_defibrillator = 1,
		/obj/item/storage/box/autoinjectors = 1,
		/obj/item/storage/pill_bottle/ert_gamma = 1,
		/obj/item/storage/pill_bottle/patch_pack/ert/gamma = 1,
		/obj/item/reagent_containers/hypospray/combat/nanites = 1,
		/obj/item/reagent_containers/hypospray/autoinjector = 1)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/surgery/l,
		/obj/item/organ/internal/cyberimp/arm/medibeam,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened)

//////////////////// PARANORMAL ///////////////////

/datum/outfit/job/centcom/response_team/paranormal
	name = "RT Paranormal"
	rt_assignment = "Emergency Response Team Inquisitor"
	rt_job = "Emergency Response Team Inquisitor"
	rt_mob_job = "ERT Paranormal"
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	back = /obj/item/storage/backpack/ert/security
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	belt = /obj/item/storage/belt/security/response_team
	id = /obj/item/card/id/ert/paranormal
	pda = /obj/item/pda/heads/ert/paranormal
	backpack_contents = list(
		/obj/item/storage/box/zipties = 1,
		/obj/item/flashlight/seclite = 1)

/datum/outfit/job/centcom/response_team/paranormal/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind)
		H.mind.isholy = TRUE

/datum/outfit/job/centcom/response_team/paranormal/amber
	name = "RT Paranormal (Amber)"
	suit = /obj/item/clothing/suit/armor/vest/ert/security/paranormal
	head = /obj/item/clothing/head/helmet/ert/security/paranormal
	r_pocket = /obj/item/nullrod

/datum/outfit/job/centcom/response_team/paranormal/red
	name = "RT Paranormal (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal
	r_pocket = /obj/item/nullrod/ert
	glasses = /obj/item/clothing/glasses/sunglasses

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened)

/datum/outfit/job/centcom/response_team/paranormal/gamma
	name = "RT Paranormal (Gamma)"
	l_pocket = /obj/item/grenade/clusterbuster/holy
	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/chaplain
	glasses = /obj/item/clothing/glasses/night
	r_pocket = /obj/item/nullrod/ert

	backpack_contents = list(
		/obj/item/storage/box/zipties = 1,
		/obj/item/flashlight/seclite = 1)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened)

//////////////////// JANITORIAL ///////////////////

/datum/outfit/job/centcom/response_team/janitorial
	name = "RT Janitor"
	rt_assignment = "Emergency Response Team Janitor"
	rt_job = "Emergency Response Team Janitor"
	rt_mob_job = "ERT Janitor"
	uniform = /obj/item/clothing/under/color/purple/sensor
	back = /obj/item/storage/backpack/ert/janitor
	belt = /obj/item/storage/belt/janitor/full
	shoes = /obj/item/clothing/shoes/galoshes
	id = /obj/item/card/id/ert/janitorial
	pda = /obj/item/pda/heads/ert/janitor

	backpack_contents = list(
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/lightreplacer = 1,
		/obj/item/storage/bag/trash = 1,
		/obj/item/twohanded/push_broom,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/melee/flyswatter = 1)

/datum/outfit/job/centcom/response_team/janitorial/amber
	name = "RT Janitor (Amber)"
	suit = /obj/item/clothing/suit/armor/vest/ert/janitor
	head = /obj/item/clothing/head/helmet/ert/janitor
	glasses = /obj/item/clothing/glasses/sunglasses
	r_pocket = /obj/item/flashlight

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/advmop)

/datum/outfit/job/centcom/response_team/janitorial/red
	name = "RT Janitor (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/janitor
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

	r_pocket = /obj/item/scythe/tele

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/janitorial,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened)

/datum/outfit/job/centcom/response_team/janitorial/gamma
	name = "RT Janitor (Gamma)"
	glasses = /obj/item/clothing/glasses/night
	back = /obj/item/mod/control/pre_equipped/responsory/janitor
	r_pocket = /obj/item/scythe/tele

	backpack_contents = list(
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/grenade/clusterbuster/cleaner = 1,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/storage/bag/trash/bluespace = 1,
		/obj/item/lightreplacer/bluespace = 1,
		/obj/item/melee/flyswatter = 1)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/arm/advmop,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened)

// Extra ERT loadouts used in ert_manager.dm

/datum/loadout
	/// Admin-facing name of the loadout
	var/name
	/// Only commander/security gets these weapons
	var/list/security_only_weapons = list()
	/// Non-security (janitor, engineer, medic, paranormal) gets these weapons
	var/list/non_security_weapons = list()
	/// Everyone gets these items
	var/list/items = list()

/datum/loadout/agents
	name = "Agents"
	items = list(/obj/item/restraints/handcuffs)
	non_security_weapons = list(/obj/item/gun/energy/disabler, /obj/item/melee/classic_baton/telescopic)
	security_only_weapons = list(/obj/item/gun/energy/gun/blueshield/pdw9, /obj/item/gun/energy/gun, /obj/item/melee/baton)

/datum/loadout/blob
	name = "Blob"
	items = list(/obj/item/grenade/flashbang)
	non_security_weapons = list(/obj/item/gun/energy/gun/nuclear)
	security_only_weapons = list(/obj/item/gun/energy/gun/nuclear)

/datum/loadout/changelings
	name = "Changelings"
	items = list(/obj/item/shield/riot/tele)
	non_security_weapons = list(/obj/item/gun/energy/gun/nuclear, /obj/item/melee/classic_baton/telescopic)
	security_only_weapons = list(/obj/item/gun/energy/gun/nuclear, /obj/item/melee/baton)

/datum/loadout/cult
	name = "Cult"
	items = list(/obj/item/reagent_containers/food/drinks/bottle/holywater)
	non_security_weapons = list(/obj/item/melee/baton, /obj/item/gun/energy/disabler)
	security_only_weapons = list(/obj/item/gun/projectile/automatic/wt550, /obj/item/ammo_box/magazine/wt550m9, /obj/item/gun/energy/disabler, /obj/item/melee/baton)

/datum/loadout/terror_spiders
	name = "Terror Spiders"
	items = list(/obj/item/shield/riot/tele)
	non_security_weapons = list(/obj/item/gun/energy/gun/nuclear)
	security_only_weapons = list(/obj/item/gun/energy/gun/nuclear)

/datum/loadout/vampires
	name = "Vampires"
	items = list(/obj/item/restraints/handcuffs, /obj/item/clothing/glasses/sunglasses/blindfold)
	non_security_weapons = list(/obj/item/gun/energy/disabler, /obj/item/melee/classic_baton/telescopic)
	security_only_weapons = list(/obj/item/gun/energy/gun/blueshield/pdw9, /obj/item/gun/energy/gun, /obj/item/melee/baton)

/datum/loadout/xenomorphs
	name = "Xenomorphs"
	items = list(/obj/item/shield/riot/tele)
	non_security_weapons = list(/obj/item/gun/energy/gun/nuclear)
	security_only_weapons = list(/obj/item/gun/energy/immolator)

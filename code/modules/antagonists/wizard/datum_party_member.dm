/datum/antagonist/wizard/apprentice/partymember
	name = "Wizard Party Member"
	greeting_text = "<span class='danger'>You have been recruited as the Wizard's party member! \
		You are bound by magic contract to follow their orders and help them in accomplishing their goals.</span>"

/datum/antagonist/wizard/apprentice/greet()
	var/list/messages = list()
	. = messages
	if(owner && owner.current)
		messages.Add("<span class='userdanger'>You are a [class_type]!</span>")
		messages.Add(greeting_text)

/datum/antagonist/wizard/apprentice/partymember/give_objectives()
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.target = my_teacher.mind
	new_objective.explanation_text = "Protect and obey [my_teacher.real_name], your party leader."
	add_antag_objective(new_objective)

/datum/antagonist/wizard/apprentice/equip_wizard()
	if(!class_type)
		CRASH("/datum/antagonist/wizard/apprentice/partymember was never assigned a class_type")
	var/mob/living/carbon/human/new_wiz = owner.current

	var/list/messages = list()
	switch(class_type)
		if("Cleric")
			new_wiz.equipOutfit(/datum/outfit/wizard_summon/cleric)
			messages += "<b>You are equipped with an armored labcoat, a telescopic baton, a variety of medical supplies and a surgery tools implant. Keep your party healthy!</b>"
		if("Barbarian")
			new_wiz.equipOutfit(/datum/outfit/wizard_summon/barbarian)
			messages += "<b>You are equipped with fully fireproof armor, a fire axe, a whetstone, and a short range fire spray. Sharpen your axe, and charge at your enemies!</b>"
		if("Fighter")
			new_wiz.equipOutfit(/datum/outfit/wizard_summon/fighter)
			messages += "<b>You are equipped with reinforced riot armor and a variety of security gear including a stun baton, disabler and riot shotgun. Get in the fight!</b>"

	return messages

/datum/outfit/wizard_summon
	name = "Wizard ally (Do not use)"

	l_ear = /obj/item/radio/headset
	l_hand = /obj/item/teleportation_scroll/apprentice

/datum/outfit/wizard_summon/cleric
	name = "Wizard party member : Cleric"

	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/storage/labcoat/runed
	head = /obj/item/clothing/head/beret/med/runed
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	shoes = /obj/item/clothing/shoes/white
	glasses = /obj/item/clothing/glasses/hud/health
	belt = /obj/item/storage/belt/medical
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/melee/classic_baton/telescopic
	back = /obj/item/storage/backpack/medic

	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/storage/firstaid/doctor = 1,
		/obj/item/storage/firstaid/adv = 1,
		/obj/item/crowbar/power = 1,
		/obj/item/roller/holo = 1,
		/obj/item/handheld_defibrillator = 1,
		/obj/item/storage/pill_bottle/cleric = 1,
		/obj/item/storage/pill_bottle/patch_pack/cleric = 1
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/surgery
	)

/datum/outfit/wizard_summon/barbarian
	name = "Wizard party member : Barbarian"

	uniform = /obj/item/clothing/under/rank/engineering/atmospheric_technician
	suit = /obj/item/clothing/suit/fire/atmos/runed
	head = /obj/item/clothing/head/hardhat/atmos/runed
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/magboots/atmos
	glasses = /obj/item/clothing/glasses/meson/engine
	mask = /obj/item/clothing/mask/gas
	belt = /obj/item/storage/belt/utility/barbarian
	l_pocket = /obj/item/reagent_containers/spray/clf3
	r_pocket = /obj/item/whetstone
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	back = /obj/item/fireaxe

/datum/outfit/wizard_summon/fighter
	name = "Wizard party member : Fighter"

	uniform = /obj/item/clothing/under/rank/security/officer/corporate
	suit = /obj/item/clothing/suit/armor/riot/runed
	head = /obj/item/clothing/head/helmet/riot/runed
	l_ear = /obj/item/radio/headset/alt
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer
	belt = /obj/item/storage/belt/security/full
	l_pocket = /obj/item/flashlight/seclite
	suit_store = /obj/item/gun/projectile/shotgun/riot
	back = /obj/item/storage/backpack/security

	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/restraints/handcuffs = 1,
		/obj/item/crowbar/power = 1,
		/obj/item/restraints/legcuffs/bola/energy = 2,
		/obj/item/ammo_box/shotgun/beanbag = 2,
		/obj/item/ammo_box/shotgun/rubbershot = 2
	)

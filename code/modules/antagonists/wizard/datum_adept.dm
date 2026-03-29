/datum/antagonist/wizard/adept
	name = "Wizard Adept"
	special_role = SPECIAL_ROLE_WIZARD_ADEPT
	antag_hud_name = "wizard adept"
	antag_datum_blacklist = list(/datum/antagonist/wizard/construct, /datum/antagonist/wizard/apprentice)

	/// Potential offensive spell list
	var/list/offense_spells = list(
		/datum/spell/genetic/mutate,
		/datum/spell/blind,
		/datum/spell/fireball,
		/datum/spell/fireball/toolbox,
		/datum/spell/sacred_flame,
		/datum/spell/rod_form,
		/datum/spell/charge_up/bounce/lightning,
		/datum/spell/infinite_guns,
	)
	/// Potential defensive spell list
	var/list/defense_spells = list(
		/datum/spell/projectile/magic_missile,
		/datum/spell/emplosion/disable_tech,
		/datum/spell/forcewall,
		/datum/spell/aoe/conjure/timestop,
		/datum/spell/aoe/repulse,
		/datum/spell/rathens,
	)
	/// Potential mobility spell list
	var/list/mobility_spells = list(
		/datum/spell/turf_teleport/blink,
		/datum/spell/area_teleport/teleport,
		/datum/spell/ethereal_jaunt,
		/datum/spell/spacetime_dist,
		/datum/spell/aoe/knock,
	)
	/// Potential support spell list
	var/list/support_spells = list(
		/datum/spell/smoke,
		/datum/spell/disguise_self,
		/datum/spell/aoe/conjure/summon_cheese,
	)
	/// Potential support item list
	var/list/support_items = list(
		/obj/item/gun/magic/wand/resurrection,
		/obj/item/guardiancreator,
		/obj/item/tarot_generator/wizard,
		/obj/item/gun/magic/wand/fireball,
	)

/datum/antagonist/wizard/adept/greet()
	. = ..()
	. += SPAN_DANGER("You are an adept wizard! You are a fully trained wizard, ready to embark on one of your first journeys into the application of space magic!")

/datum/antagonist/wizard/adept/give_objectives()
	var/datum/objective/wizchaos/new_objective = new /datum/objective/wizchaos
	new_objective.explanation_text = "Distract, harass, and impede Nanotrasen's crew!"
	add_antag_objective(new_objective)

/datum/antagonist/wizard/adept/equip_wizard()
	var/mob/living/carbon/human/new_wiz = owner.current
	new_wiz.delete_equipment()
	new_wiz.equip_to_slot_or_del(new /obj/item/radio/headset(new_wiz), ITEM_SLOT_LEFT_EAR)
	new_wiz.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(new_wiz), ITEM_SLOT_JUMPSUIT)
	new_wiz.equip_to_slot_or_del(new /obj/item/storage/backpack(new_wiz), ITEM_SLOT_BACK)
	new_wiz.equip_to_slot_or_del(new /obj/item/teleportation_scroll/apprentice(new_wiz), ITEM_SLOT_RIGHT_POCKET)
	new_wiz.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(new_wiz), ITEM_SLOT_SHOES)
	new_wiz.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(new_wiz), ITEM_SLOT_OUTER_SUIT)
	new_wiz.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(new_wiz), ITEM_SLOT_HEAD)
	if(new_wiz.dna.species.speciesbox)
		new_wiz.equip_to_slot_or_del(new new_wiz.dna.species.speciesbox(new_wiz), ITEM_SLOT_IN_BACKPACK)
	else
		new_wiz.equip_to_slot_or_del(new /obj/item/storage/box/survival(new_wiz), ITEM_SLOT_IN_BACKPACK)
	if(isvox(new_wiz))
		new_wiz.equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox/respirator(new_wiz), ITEM_SLOT_MASK)
		new_wiz.equip_to_slot_or_del(new /obj/item/tank/internals/emergency_oxygen/double/vox(new_wiz), ITEM_SLOT_RIGHT_HAND)
		new_wiz.internal = new_wiz.r_hand

	var/datum/spell/offense = pick(offense_spells)
	new_wiz.mind.AddSpell(new offense(null))

	var/datum/spell/defense = pick(defense_spells)
	new_wiz.mind.AddSpell(new defense(null))

	var/datum/spell/mobility = pick(mobility_spells)
	new_wiz.mind.AddSpell(new mobility(null))

	if(pick(0, 1))
		var/datum/spell/support = pick(support_spells)
		new_wiz.mind.AddSpell(new support(null))
	else
		var/obj/item/support = pick(support_items)
		new_wiz.equip_to_slot_or_del(new support(new_wiz), ITEM_SLOT_IN_BACKPACK)

	new_wiz.rejuvenate()

/datum/antagonist/wizard/adept/add_owner_to_gamemode()
	SSticker.mode.adepts |= owner

/datum/antagonist/wizard/adept/remove_owner_from_gamemode()
	SSticker.mode.adepts -= owner

/datum/antagonist/wizard/adept/full_on_wizard()
	return FALSE

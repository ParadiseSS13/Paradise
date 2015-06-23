/datum/species/golem
	name = "Golem"

	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_golem.dmi'

	default_language = "Galactic Common"
	flags = NO_BREATHE | NO_PAIN | NO_BLOOD | NO_SCAN
	dietflags = DIET_OMNI		//golems can eat anything because they are magic or something
	reagent_tag = PROCESS_ORG

	blood_color = "#515573"
	flesh_color = "#137E8F"


	has_organ = list(
		"brain" = /obj/item/organ/brain/golem
		)

/datum/species/golem/handle_post_spawn(var/mob/living/carbon/human/H)
	if(H.mind)
		H.mind.assigned_role = "Golem"
		H.mind.special_role = "Golem"
	H.real_name = "adamantine golem ([rand(1, 1000)])"
	H.name = H.real_name
	H.equip_to_slot_or_del(new /obj/item/clothing/under/golem(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/golem(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/golem(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/golem(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/golem(H), slot_gloves)
	..()


////////Adamantine Golem stuff I dunno where else to put it

/obj/item/clothing/under/golem
	name = "adamantine skin"
	desc = "a golem's skin"
	icon_state = "golem"
	item_state = "golem"
	_color = "golem"
	has_sensor = 0
	flags = ABSTRACT | NODROP
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/golem
	name = "adamantine shell"
	desc = "a golem's thick outter shell"
	icon_state = "golem"
	item_state = "golem"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|HEAD
	slowdown = 1.0
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	flags = ONESIZEFITSALL | STOPSPRESSUREDMAGE | ABSTRACT | NODROP
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS | HEAD
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	armor = list(melee = 80, bullet = 20, laser = 20, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/shoes/golem
	name = "golem's feet"
	desc = "sturdy adamantine feet"
	icon_state = "golem"
	item_state = "golem"
	flags = NOSLIP | ABSTRACT | MASKINTERNALS | MASKCOVERSMOUTH | NODROP
	slowdown = SHOES_SLOWDOWN+1


/obj/item/clothing/mask/gas/golem
	name = "golem's face"
	desc = "the imposing face of an adamantine golem"
	icon_state = "golem"
	item_state = "golem"
	siemens_coefficient = 0
	unacidable = 1
	flags = ABSTRACT | NODROP


/obj/item/clothing/gloves/golem
	name = "golem's hands"
	desc = "strong adamantine hands"
	icon_state = "golem"
	item_state = null
	siemens_coefficient = 0
	flags = ABSTRACT | NODROP


/obj/item/clothing/head/space/golem
	icon_state = "golem"
	item_state = "dermal"
	_color = "dermal"
	name = "golem's head"
	desc = "a golem's head"
	unacidable = 1
	flags = STOPSPRESSUREDMAGE | ABSTRACT | NODROP
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	armor = list(melee = 80, bullet = 20, laser = 20, energy = 10, bomb = 0, bio = 0, rad = 0)
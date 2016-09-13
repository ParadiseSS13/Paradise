/datum/species/golem
	name = "Golem"
	name_plural = "Golems"

	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_golem.dmi'

	default_language = "Galactic Common"
	flags = NO_BREATHE | NO_BLOOD | RADIMMUNE | NOGUNS
	virus_immune = 1
	dietflags = DIET_OMNI		//golems can eat anything because they are magic or something
	reagent_tag = PROCESS_ORG

	unarmed_type = /datum/unarmed_attack/punch
	punchdamagelow = 5
	punchdamagehigh = 14
	punchstunthreshold = 11 //about 40% chance to stun

	warning_low_pressure = -1
	hazard_low_pressure = -1
	hazard_high_pressure = 999999999
	warning_high_pressure = 999999999

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 999999999
	heat_level_2 = 999999999
	heat_level_3 = 999999999
	heat_level_3_breathe = 999999999

	blood_color = "#515573"
	flesh_color = "#137E8F"
	slowdown = 3
	siemens_coeff = 0

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem
		)
	suicide_messages = list(
		"is crumbling into dust!",
		"is smashing their body apart!")

/datum/species/golem/handle_post_spawn(var/mob/living/carbon/human/H)
	if(H.mind)
		H.mind.assigned_role = "Golem"
		H.mind.special_role = SPECIAL_ROLE_GOLEM
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
	item_color = "golem"
	has_sensor = 0
	flags = ABSTRACT | NODROP
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/golem
	name = "adamantine shell"
	desc = "a golem's thick outter shell"
	icon_state = "golem"
	item_state = "golem"
	body_parts_covered = HEAD|UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES
	flags = ABSTRACT | NODROP | THICKMATERIAL
	flags_size = ONESIZEFITSALL
	armor = list(melee = 55, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/shoes/golem
	name = "golem's feet"
	desc = "sturdy adamantine feet"
	icon_state = "golem"
	item_state = "golem"
	flags = ABSTRACT | NODROP

/obj/item/clothing/mask/gas/golem
	name = "golem's face"
	desc = "the imposing face of an adamantine golem"
	icon_state = "golem"
	item_state = "golem"
	unacidable = 1
	flags = ABSTRACT | NODROP

/obj/item/clothing/gloves/golem
	name = "golem's hands"
	desc = "strong adamantine hands"
	icon_state = "golem"
	item_state = null
	flags = ABSTRACT | NODROP

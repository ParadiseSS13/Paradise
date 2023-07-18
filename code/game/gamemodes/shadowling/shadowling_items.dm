/obj/item/clothing/under/shadowling
	name = "blackened flesh"
	desc = "Black, chitinous skin with thin red veins."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_uniform"
	icon_override = "golem_s"
	origin_tech = null
	flags = ABSTRACT | NODROP
	has_sensor = FALSE
	displays_id = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF


/obj/item/clothing/suit/space/shadowling
	name = "chitin shell"
	desc = "Dark, semi-transparent shell. Protects against vacuum, but not against the light of the stars." //Still takes damage from spacewalking but is immune to space itself
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_suit"
	icon_override = "golem"
	body_parts_covered = FULL_BODY //Shadowlings are immune to space
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	slowdown = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	heat_protection = null //You didn't expect a light-sensitive creature to have heat resistance, did you?
	max_heat_protection_temperature = null
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 25, bio = 100, rad = 100, fire = 100, acid = 100)
	flags = ABSTRACT | NODROP | THICKMATERIAL | STOPSPRESSUREDMAGE


/obj/item/clothing/shoes/shadowling
	name = "chitin feet"
	desc = "Charred-looking feet. They have minature hooks that latch onto flooring."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_shoes"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = NOSLIP | ABSTRACT | NODROP


/obj/item/clothing/mask/gas/shadowling
	name = "chitin mask"
	desc = "A mask-like formation with slots for facial features. A red film covers the eyes."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_mask"
	origin_tech = null
	siemens_coefficient = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = ABSTRACT | NODROP
	flags_cover = MASKCOVERSEYES	//We don't need to cover mouth


/obj/item/clothing/gloves/shadowling
	name = "chitin hands"
	desc = "An electricity-resistant covering of the hands."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_gloves"
	origin_tech = null
	siemens_coefficient = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = ABSTRACT | NODROP


/obj/item/clothing/head/shadowling
	name = "chitin helm"
	desc = "A helmet-like enclosure of the head."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_helmet"
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	origin_tech = null
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = ABSTRACT | NODROP | STOPSPRESSUREDMAGE
	flags_cover = HEADCOVERSEYES	//We don't need to cover mouth


/obj/item/clothing/glasses/shadowling
	name = "crimson eyes"
	desc = "A shadowling's eyes. Very light-sensitive and can detect body heat through walls."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_glasses"
	origin_tech = null
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flash_protect = -1
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	flags = ABSTRACT | NODROP


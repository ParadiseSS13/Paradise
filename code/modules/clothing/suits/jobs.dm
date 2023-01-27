/*
 * Job related
 */
//Paramedic
/obj/item/clothing/suit/storage/paramedic
	name = "paramedic vest"
	desc = "A hazard vest used in the recovery of bodies."
	icon_state = "paramedic-vest"
	item_state = "paramedic-vest"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe,
	/obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/radio, /obj/item/tank/internals/emergency_oxygen,/obj/item/rad_laser)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 10, fire = 50, acid = 50)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/storage/paramedic_jacket
	name = "paramedic jacket"
	desc = "Standard issue paramedic jacket. Not that different from any other work apparel, except for the bright, reflective stripes"
	blood_overlay_type = "armor"
	icon_state = "paramedic_jacket_open"
	item_state = "paramedic_jacket_open"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe,
	/obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/radio, /obj/item/tank/internals/emergency_oxygen,/obj/item/rad_laser)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 10, fire = 50, acid = 50)
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

//Brig Physician
/obj/item/clothing/suit/storage/brigdoc
	name = "brig physician vest"
	desc = "A vest often worn by doctors caring for inmates."
	icon_state = "brigphysician-vest"
	item_state = "brigphysician-vest"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe,
	/obj/item/healthanalyzer, /obj/item/flashlight, \
	/obj/item/radio, /obj/item/tank/internals/emergency_oxygen,/obj/item/rad_laser)
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0, fire = 50, acid = 50)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

//Botanist
/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A basic blue apron."
	icon_state = "apron"
	item_state = "apron"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list(/obj/item/reagent_containers/spray/plantbgone,/obj/item/plant_analyzer,/obj/item/seeds,/obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/cultivator,/obj/item/reagent_containers/spray/pestspray,/obj/item/hatchet,/obj/item/storage/bag/plants)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

//Captain
/obj/item/clothing/suit/captunic
	name = "captain's parade tunic"
	desc = "Worn by a Captain to show their class."
	icon_state = "captunic"
	item_state = "bio_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/disk, /obj/item/stamp, /obj/item/reagent_containers/food/drinks/flask, /obj/item/melee, /obj/item/storage/lockbox/medal, /obj/item/flash, /obj/item/storage/box/matches, /obj/item/lighter, /obj/item/clothing/mask/cigarette, /obj/item/storage/fancy/cigarettes, /obj/item/tank/internals/emergency_oxygen)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/captunic/capjacket
	name = "captain's uniform jacket"
	desc = "A less formal jacket for everyday captain use."
	icon_state = "capjacket"
	item_state = "bio_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

//Chaplain
/obj/item/clothing/suit/hooded/chaplain_hoodie
	name = "chaplain hoodie"
	desc = "This suit says to you 'hush'!"
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

//Chaplain
/obj/item/clothing/suit/hooded/nun
	name = "nun robe"
	desc = "Maximum piety in this star system."
	icon_state = "nun"
	item_state = "nun"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/nun_hood
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

//Chaplain
/obj/item/clothing/suit/hooded/monk
	name = "monk robe"
	desc = "Wooden board not included."
	icon_state = "monkrobe"
	item_state = "monkrobe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/monk_hood
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/witchhunter
	name = "witchhunter garb"
	desc = "Dosen't weigh the same a a duck."
	icon_state = "witchhunter"
	item_state = "witchhunter"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

//Chef
/obj/item/clothing/suit/chef
	name = "chef's apron"
	desc = "An apron used by a high class chef."
	icon_state = "chef"
	item_state = "chef"
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list (/obj/item/kitchen/knife)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

//Chef
/obj/item/clothing/suit/chef/classic
	name = "classic chef's apron"
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	item_state = "apronchef"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list(/obj/item/kitchen/knife)

//Detective
/obj/item/clothing/suit/storage/det_suit
	name = "coat"
	desc = "An 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/reagent_containers/spray/pepper, /obj/item/flashlight, /obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/detective_scanner, /obj/item/taperecorder)
	armor = list("melee" = 25, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 45)
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

//Forensics
/obj/item/clothing/suit/storage/det_suit/forensics
	name = "jacket"
	desc = "A forensics technician jacket."
	item_state = "det_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/suit/storage/det_suit/forensics/red
	name = "red jacket"
	desc = "A red forensics technician jacket."
	icon_state = "forensics_red"

/obj/item/clothing/suit/storage/det_suit/forensics/blue
	name = "blue jacket"
	desc = "A blue forensics technician jacket."
	icon_state = "forensics_blue"

//Blueshield
/obj/item/clothing/suit/storage/blueshield
	name = "blueshield coat"
	desc = "NT deluxe ripoff. You finally have your own coat."
	icon_state = "blueshieldcoat"
	item_state = "blueshieldcoat"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite,/obj/item/melee/classic_baton/telescopic)
	armor = list(melee = 25, bullet = 10, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 45)
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/storage/blueshield/srt
	name = "SRT coat"
	desc = "Dark blue armored coat. Excellent defense against most types of damage."
	armor = list(melee = 45, bullet = 35, laser = 35, energy = 20, bomb = 50, rad = 40, fire = 40, acid = 90)

//Engineering
/obj/item/clothing/suit/storage/hazardvest
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard"
	item_state = "hazard"
	blood_overlay_type = "armor"
	allowed = list (/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcd, /obj/item/rpd)
	resistance_flags = NONE

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

//Lawyer
/obj/item/clothing/suit/storage/lawyer
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/storage/lawyer/blackjacket
	name = "black suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_black_open"
	item_state = "suitjacket_black_open"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/storage/lawyer/bluejacket
	name = "blue suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_blue_open"
	item_state = "suitjacket_blue_open"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/storage/lawyer/purpjacket
	name = "purple suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_purp"
	item_state = "suitjacket_purp"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

//Internal Affairs
/obj/item/clothing/suit/storage/internalaffairs
	name = "\improper Internal Affairs jacket"
	desc = "A smooth black jacket."
	icon_state = "ia_jacket_open"
	item_state = "ia_jacket_open"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/storage/ntrep
	name = "\improper Nanotrasen Representative jacket"
	desc = "A fancy black jacket; standard issue to Nanotrasen Representatives."
	icon_state = "ntrep"
	item_state = "ntrep"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS
	ignore_suitadjust = 0
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

//Medical
/obj/item/clothing/suit/storage/fr_jacket
	name = "first responder jacket"
	desc = "A high-visibility jacket worn by medical first responders."
	icon_state = "fr_jacket_open"
	item_state = "fr_jacket_open"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe,
	/obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/radio, /obj/item/tank/internals/emergency_oxygen,/obj/item/rad_laser)
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

//Mime
/obj/item/clothing/suit/suspenders
	name = "suspenders"
	desc = "They suspend the illusion of the mime's play."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	blood_overlay_type = "armor" //it's the less thing that I can put here

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/suspenders/nodrop
	flags = NODROP

// Surgeon
/obj/item/clothing/suit/apron/surgical
	name = "surgical apron"
	desc = "A sterile blue surgical apron."
	icon_state = "surgical"
	item_state = "surgical"
	allowed = list(/obj/item/scalpel, /obj/item/surgical_drapes, /obj/item/cautery, /obj/item/hemostat, /obj/item/retractor)

/obj/item/clothing/suit/hop_jacket
	name = "head of personnel's jacket"
	desc = "This is the head of personnel jacket"
	icon_state = "suitjacket_hop_open"
	item_state = "suitjacket_hop_open"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/hop_jacket/female
	icon_state = "suitjacket_hop_fem_open"
	item_state = "suitjacket_hop_fem_open"

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
	/obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/radio, /obj/item/tank/internals/emergency_oxygen)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 50, ACID = 50)

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
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
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/mantle/armor/captain
	name = "captain's cloak"
	desc = "An armor-plated piece of fashion for the ruling elite. Protect your upper half in style."
	icon_state = "capmantle"
	item_state = "capmantle"
	armor = list(MELEE = 50, BULLET = 35, LASER = 50, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)

//Chaplain
/obj/item/clothing/suit/hooded/chaplain_hoodie
	name = "chaplain hoodie"
	desc = "This suit says to you 'hush'!"
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
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
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

//Chaplain
/obj/item/clothing/suit/hooded/monk
	name = "monk robe"
	desc = "Wooden board not included."
	icon_state = "monkrobe"
	item_state = "monkrobe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/monk_hood
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/witchhunter
	name = "witchhunter garb"
	desc = "Dosen't weigh the same a a duck."
	icon_state = "witchhunter"
	item_state = "witchhunter"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)


	//Chef
/obj/item/clothing/suit/toggle/chef
	name = "chef's apron"


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
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
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

//Chief Engineer
/obj/item/clothing/suit/mantle/chief_engineer
	name = "chief engineer's mantle"
	desc = "A slick, authoritative cloak designed for the Chief Engineer."
	icon_state = "cemantle"
	item_state = "cemantle"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/rcd, /obj/item/rpd)

//Chief Medical Officer
/obj/item/clothing/suit/mantle/labcoat/chief_medical_officer
	name = "chief medical officer's mantle"
	desc = "An absorbent, clean cover found on the shoulders of the Chief Medical Officer."
	icon_state = "cmomantle"
	item_state = "cmomantle"

//Detective
/obj/item/clothing/suit/storage/det_suit
	name = "coat"
	desc = "An 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/reagent_containers/spray/pepper, /obj/item/flashlight, /obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/detective_scanner, /obj/item/taperecorder)
	armor = list(MELEE = 15, BULLET = 5, LASER = 15, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 0, ACID = 40)
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi'
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

/obj/item/clothing/suit/storage/det_suit/forensics/black
	name = "black jacket"
	desc = "A black forensics technician jacket."
	icon_state = "forensics_black"

//Blueshield
/obj/item/clothing/suit/storage/blueshield
	name = "blueshield's coat"
	desc = "NT deluxe ripoff. You finally have your own coat."
	icon_state = "blueshieldcoat"
	item_state = "blueshieldcoat"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite,/obj/item/melee/classic_baton/telescopic)
	armor = list(MELEE = 15, BULLET = 5, LASER = 15, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 0, ACID = 40)
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		)

//Hazard vests
/obj/item/clothing/suit/storage/hazardvest
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones. Designed for general use."
	icon = 'icons/obj/clothing/suits/utility.dmi'
	icon_state = "hazard_base"
	item_state = 'icons/mob/clothing/suits/utility.dmi'
	icon_override = 'icons/mob/clothing/suits/utility.dmi'
	blood_overlay_type = "armor"
	allowed = list (/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcd, /obj/item/rpd)
	resistance_flags = NONE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suits/utility.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suits/utility.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suits/utility.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suits/utility.dmi'
		)

/obj/item/clothing/suit/storage/hazardvest/staff
	name = "staff hazard vest"
	desc = "A high-visibilty vest used in work zones. Designed to easily identify station staff from visitors."
	icon_state = "hazard_staff"
	allowed = list(/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/paper, /obj/item/clipboard, /obj/item/analyzer, /obj/item/screwdriver, /obj/item/radio, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters, /obj/item/rcd, /obj/item/rpd, /obj/item/rcs, /obj/item/destTagger)

/obj/item/clothing/suit/storage/hazardvest/qm
	name = "warehouse supervisor hazard vest"
	desc = "A high-visibilty vest used in work zones. Designed to easily identify the supply supervisor."
	icon_state = "hazard_qm"
	allowed = list(/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/paper, /obj/item/clipboard, /obj/item/analyzer, /obj/item/screwdriver, /obj/item/radio, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters, /obj/item/rcs, /obj/item/destTagger, /obj/item/melee/baton, /obj/item/flashlight/seclite, /obj/item/melee/classic_baton/telescopic, /obj/item/melee/knuckleduster)

/obj/item/clothing/suit/storage/hazardvest/ce
	name = "foreman hazard vest"
	desc = "A high-visibility vest used in work zones. Designed to easily identify the engineering supervisor."
	icon_state = "hazard_ce"
	allowed = list(/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/paper, /obj/item/clipboard, /obj/item/analyzer, /obj/item/screwdriver, /obj/item/radio, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters, /obj/item/rcd, /obj/item/rpd, /obj/item/destTagger, /obj/item/melee/baton, /obj/item/flashlight/seclite, /obj/item/melee/classic_baton/telescopic)

//Internal Affairs
/obj/item/clothing/suit/storage/iaa
	desc = "A snappy dress jacket."
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO | ARMS
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi'
		)

/obj/item/clothing/suit/storage/iaa/blackjacket
	name = "black suit jacket"
	icon_state = "suitjacket_black_open"
	item_state = "suitjacket_black_open"
	ignore_suitadjust = FALSE
	suit_adjusted = TRUE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/storage/iaa/bluejacket
	name = "blue suit jacket"
	icon_state = "suitjacket_blue_open"
	item_state = "suitjacket_blue_open"
	ignore_suitadjust = FALSE
	suit_adjusted = TRUE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/storage/iaa/purplejacket
	name = "purple suit jacket"
	icon_state = "suitjacket_purple"
	item_state = "suitjacket_purple"

//Head of Security
/obj/item/clothing/suit/mantle/armor
	name = "armored shawl"
	desc = "A reinforced shawl, worn by the Head of Security. Do you dare take up their mantle?"
	icon_state = "hosmantle"
	item_state = "hosmantle"
	allowed = list(/obj/item/gun/energy, /obj/item/reagent_containers/spray/pepper, /obj/item/gun/projectile, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/flashlight/seclite, /obj/item/melee/classic_baton/telescopic, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	put_on_delay = 40
	resistance_flags = NONE

//Head of Personnel
/obj/item/clothing/suit/mantle/armor/hop
	name = "head of personnel's shawl"
	desc = "An armored shawl for the head of personnel. It's remarkably well kept."
	icon_state = "hopmantle"
	item_state = "hopmantle"
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/suit/hopcoat
	name = "head of personnel's coat"
	desc = "A big coat for the Head of Personnel who wants to make a fashion statement. Has armour woven within the fabric."
	icon_state = "hopcoat"
	item_state = "hopcoat"
	allowed = list(/obj/item/gun/energy, /obj/item/reagent_containers/spray/pepper, /obj/item/gun/projectile, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/flashlight/seclite, /obj/item/melee/classic_baton/telescopic, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi'
	)

//Quartermaster
/obj/item/clothing/suit/mantle/qm
	name = "quartermaster's mantle"
	desc = "An armored shawl for the quartermaster. Keeps the breeze from the vents away from your neck."
	icon_state = "qmmantle"
	item_state = "qmmantle"
	allowed = list(/obj/item/paper, /obj/item/clipboard, /obj/item/gun/energy/kinetic_accelerator, /obj/item/melee/baton, /obj/item/flashlight/seclite, /obj/item/melee/classic_baton/telescopic, /obj/item/melee/knuckleduster, /obj/item/rcs)
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/suit/qmcoat
	name = "quartermaster's coat"
	desc = "A brown trenchcoat to show the station you mean business. Has armor woven within the fabric."
	icon_state = "qmcoat"
	item_state = "qmcoat"
	allowed = list(/obj/item/paper, /obj/item/clipboard, /obj/item/gun/energy/kinetic_accelerator, /obj/item/melee/baton, /obj/item/flashlight/seclite, /obj/item/melee/classic_baton/telescopic, /obj/item/melee/knuckleduster, /obj/item/rcs)
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi'
	)

//Dignitaries
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
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		)

/obj/item/clothing/suit/magirobe
	name = "magistrate's robe"
	desc = "An opulent robe that commands authority. Issued only to licensed magistrates."
	icon_state = "magirobe"
	item_state = "magirobe"
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS
	allowed = list(/obj/item/storage/fancy/cigarettes, /obj/item/stack/spacecash, /obj/item/flash, /obj/item/gavelhammer)
	flags_inv = HIDEJUMPSUIT

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
	)

//Medical
/obj/item/clothing/suit/storage/fr_jacket
	name = "first responder jacket"
	desc = "A high-visibility jacket worn by medical first responders."
	icon_state = "fr_jacket_open"
	item_state = "fr_jacket_open"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe,
	/obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/radio, /obj/item/tank/internals/emergency_oxygen)
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

//Mime
/obj/item/clothing/suit/suspenders
	name = "suspenders"
	desc = "They suspend the illusion of the mime's play."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	blood_overlay_type = "armor" //it's the less thing that I can put here

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
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

//Research Director
/obj/item/clothing/suit/mantle/labcoat
	name = "research director's mantle"
	desc = "A tweed mantle, worn by the Research Director. Smells like science."
	icon_state = "rdmantle"
	item_state = "rdmantle"
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)

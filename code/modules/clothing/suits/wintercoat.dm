// MARK: Winter coat
/obj/item/clothing/suit/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon = 'icons/obj/clothing/suits/wintercoat.dmi'
	icon_state = "wintercoat"
	worn_icon = 'icons/mob/clothing/suits/wintercoat.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
	)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suits/wintercoat.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suits/wintercoat.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suits/wintercoat.dmi',
	)

/obj/item/clothing/head/hooded/winterhood
	name = "winter hood"
	desc = "A hood attached to a heavy winter jacket."
	icon = 'icons/obj/clothing/head/winterhood.dmi'
	icon_state = "winterhood"
	worn_icon = 'icons/mob/clothing/head/winterhood.dmi'
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags = BLOCKHAIR
	flags_inv = HIDEEARS
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head/winterhood.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head/winterhood.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head/winterhood.dmi',
	)

// MARK: Captain
/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	icon_state = "wintercoat_captain"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain
	insert_max = 3
	armor = list(MELEE = 15, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 0, ACID = 50)
	allowed = list(
		/obj/item/gun/energy,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/gun/projectile,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/flashlight/seclite,
		/obj/item/melee/classic_baton/telescopic,
	)

/obj/item/clothing/head/hooded/winterhood/captain
	icon_state = "winterhood_captain"

// MARK: Security
/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter coat"
	icon_state = "wintercoat_sec"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 20, ACID = 20)
	allowed = list(
		/obj/item/gun/energy,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/gun/projectile,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/flashlight/seclite,
		/obj/item/melee/classic_baton/telescopic,
	)

/obj/item/clothing/head/hooded/winterhood/security
	icon_state = "winterhood_sec"

// MARK: Medical
/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	icon_state = "wintercoat_med"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 40)
	allowed = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/applicator,
		/obj/item/healthanalyzer,
		/obj/item/flashlight/pen,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/storage/pill_bottle,
		/obj/item/paper,
		/obj/item/melee/classic_baton/telescopic, // wait what
	)

/obj/item/clothing/head/hooded/winterhood/medical
	icon_state = "winterhood_med"

// MARK: Science
/obj/item/clothing/suit/hooded/wintercoat/science
	name = "science winter coat"
	icon_state = "wintercoat_sci"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 0)
	allowed = list(
		/obj/item/analyzer,
		/obj/item/stack/medical,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/applicator,
		/obj/item/healthanalyzer,
		/obj/item/flashlight/pen,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/storage/pill_bottle,
		/obj/item/paper,
		/obj/item/melee/classic_baton/telescopic,
	)

/obj/item/clothing/head/hooded/winterhood/science
	icon_state = "winterhood_sci"

// MARK: Engineering
/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "wintercoat_engi"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 10, FIRE = 20, ACID = 40)
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/t_scanner,
		/obj/item/rcd,
		/obj/item/rpd,
	)

/obj/item/clothing/head/hooded/winterhood/engineering
	icon_state = "winterhood_engi"

// MARK: Atmospherics
/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "wintercoat_atmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos

/obj/item/clothing/head/hooded/winterhood/engineering/atmos
	icon_state = "winterhood_atmos"

// MARK: Hydroponics
/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "wintercoat_hydro"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro
	allowed = list(
		/obj/item/reagent_containers/spray,
		/obj/item/plant_analyzer,
		/obj/item/seeds,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/hatchet,
		/obj/item/storage/bag/plants,
	)

/obj/item/clothing/head/hooded/winterhood/hydro
	icon_state = "winterhood_hydro"

// MARK: Cargo
/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	icon_state = "wintercoat_cargo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		/obj/item/rcs,
		/obj/item/clipboard,
		/obj/item/envelope,
		/obj/item/storage/bag/mail,
		/obj/item/mail_scanner,
	)

/obj/item/clothing/head/hooded/winterhood/cargo
	icon_state = "winterhood_cargo"

// MARK: Mining
/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	icon_state = "wintercoat_miner"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/miner
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	allowed = list(
		/obj/item/pickaxe,
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/storage/bag/ore,
		/obj/item/gun/energy/kinetic_accelerator,
	)

/obj/item/clothing/head/hooded/winterhood/miner
	icon_state = "winterhood_miner"

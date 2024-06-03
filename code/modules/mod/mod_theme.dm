/// Global proc that sets up all MOD themes as singletons in a list and returns it.
/proc/setup_mod_themes()
	. = list()
	for(var/path in typesof(/datum/mod_theme))
		var/datum/mod_theme/new_theme = new path()
		.[path] = new_theme

/// MODsuit theme, instanced once and then used by MODsuits to grab various statistics.
/datum/mod_theme
	/// Theme name for the MOD.
	var/name = "BASE"
	/// Description added to the MOD.
	var/desc = "A civilian class suit by Cybersun Industries, doesn't offer much other than slightly quicker movement."
	/// Extended description on examine_more
	var/extended_desc = "A third-generation, modular civilian class suit by Cybersun Industries, \
		this suit is a staple across the galaxy for civilian applications. These suits are oxygenated, \
		spaceworthy, resistant to fire and chemical threats, and are immunized against everything between \
		a sneeze and a bioweapon. However, their combat applications are incredibly minimal due to the amount of \
		armor plating being installed by default, and their actuators only lead to slightly greater speed than industrial suits."
	/// Default skin of the MOD.
	var/default_skin = "standard"
	/// The slot this mod theme fits on
	var/slot_flags = SLOT_FLAG_BACK
	/// Armor shared across the MOD parts.
	var/obj/item/mod/armor/armor_type_1 = /obj/item/mod/armor/mod_theme
	/// the actual armor object placed in a datum as I am tired and I just want this to work
	var/obj/item/mod/armor/armor_type_2 = null
	/// Resistance flags shared across the MOD parts.
	var/resistance_flags = NONE
	/// Atom flags shared across the MOD parts.
	var/atom_flags = NONE
	/// Max heat protection shared across the MOD parts.
	var/max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	/// Max cold protection shared across the MOD parts.
	var/min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	/// Siemens shared across the MOD parts.
	var/siemens_coefficient = 0.5
	/// How much modules can the MOD carry without malfunctioning.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much battery power the MOD uses by just being on
	var/charge_drain = DEFAULT_CHARGE_DRAIN
	/// Slowdown of the MOD when not active.
	var/slowdown_inactive = 1.25
	/// Slowdown of the MOD when active.
	var/slowdown_active = 0.75
	/// Theme used by the MOD TGUI.
	var/ui_theme = "ntos"
	/// List of inbuilt modules. These are different from the pre-equipped suits, you should mainly use these for unremovable modules with 0 complexity.
	var/list/inbuilt_modules = list()
	/// Allowed items in the chestplate's suit storage.
	var/list/allowed_suit_storage = list()
	/// List of skins with their appropriate clothing flags.
	var/list/skins = list(
		"standard" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCKHAIR,
				SEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEYES,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"civilian" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEYES,
				UNSEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/// We don't want the civilian skin to apply to all modsuits, that causes issues.
/datum/mod_theme/standard
	name = "standard"


/datum/mod_theme/New()
	. = ..()
	armor_type_2 = new armor_type_1

/obj/item/mod/armor/mod_theme
	armor = list(MELEE = 15, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 25, FIRE = 33, ACID = 33)

/datum/mod_theme/engineering
	name = "engineering"
	desc = "An engineer-fit suit with heat and shock resistance. Cybersun Industries's classic."
	extended_desc = "A classic by Cybersun Industries, and surely their claim to fame. This model is an \
		improvement upon the first-generation prototype models from before the Void War, boasting an array of features. \
		The modular flexibility of the base design has been combined with a blast-dampening insulated inner layer and \
		a shock-resistant outer layer, making the suit nigh-invulnerable against even the extremes of high-voltage electricity. \
		However, the capacity for modification remains the same as civilian-grade suits."
	default_skin = "engineering"
	armor_type_1 = /obj/item/mod/armor/mod_theme_engineering
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 1.5
	slowdown_active = 0.75
	allowed_suit_storage = list(
		/obj/item/rcd,
		/obj/item/fireaxe,
	)
	skins = list(
		"engineering" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_engineering
	armor = list(MELEE = 20, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 30, RAD = 150, FIRE = INFINITY, ACID = 150) //Bomb armor bumped up a bit, as the modsuit describes it with blast-dampening

/datum/mod_theme/atmospheric
	name = "atmospheric"
	desc = "An atmospheric-resistant suit by Cybersun Industries, offering extreme heat resistance compared to the engineer suit."
	extended_desc = "A modified version of the Cybersun Industries industrial model. This one has been \
		augmented with the latest in heat-resistant alloys, paired with a series of advanced heatsinks. \
		Additionally, the materials used to construct this suit have rendered it extremely hardy against \
		corrosive gasses and liquids, useful in the world of pipes. \
		However, the capacity for modification remains the same as civilian-grade suits."
	default_skin = "atmospheric"
	armor_type_1 = /obj/item/mod/armor/mod_theme_atmospheric
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	siemens_coefficient = 0
	slowdown_inactive = 1.5
	slowdown_active = 0.75
	allowed_suit_storage = list(
		/obj/item/rcd,
		/obj/item/fireaxe/,
		/obj/item/rpd,
		/obj/item/t_scanner,
		/obj/item/analyzer
	)
	skins = list(
		"atmospheric" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_atmospheric
	armor = list(MELEE = 20, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 15, RAD = 15, FIRE = INFINITY, ACID = 150)

/datum/mod_theme/advanced
	name = "advanced"
	desc = "An advanced version of Cybersun Industries's classic suit, shining with a white, acid and fire resistant polish."
	extended_desc = "The flagship version of the Cybersun Industrie industrial model, and their latest product. \
		Combining all the features of their other industrial model suits inside, with blast resistance almost approaching \
		some EOD suits, the outside has been coated with a white polish rumored to be a corporate secret. \
		The paint used is almost entirely immune to corrosives, and certainly looks damn fine. \
		These come pre-installed with magnetic boots, using an advanced system to toggle them on or off as the user walks."
	default_skin = "advanced"
	armor_type_1 = /obj/item/mod/armor/mod_theme_advanced
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	siemens_coefficient = 0
	slowdown_inactive = 1
	slowdown_active = 0.45
	inbuilt_modules = list(/obj/item/mod/module/magboot/advanced)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/rcd,
		/obj/item/fireaxe,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/rpd,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/gun

	)
	skins = list(
		"advanced" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_advanced
	armor = list(MELEE = 35, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 50, RAD = INFINITY, FIRE = INFINITY, ACID = 150)

/datum/mod_theme/mining
	name = "mining"
	desc = "A Nanotrasen mining suit for on-site operations, fit with accreting ash armor and a sphere form."
	extended_desc = "A high-powered Nanotrasen-designed suit, based off the work of Cybersun Industries. \
		While initial designs were built for the rigors of asteroid mining, given blast resistance through inbuilt ceramics, \
		mining teams have since heavily tweaked the suit themselves with assistance from devices crafted by \
		destructive analysis of unknown technologies discovered on the Indecipheres mining sites, patterned off \
		their typical non-EVA exploration suits. The visor has been expanded to a system of seven arachnid-like cameras, \
		offering full view of the land and its soon-to-be-dead inhabitants. The armor plating has been trimmed down to \
		the bare essentials, geared far more for environmental hazards than combat against fauna; however, \
		this gives way to incredible protection against corrosives and thermal protection good enough for \
		traversing the hostile climate of scorching hot barren planets, molten, and volcanic worlds like Epsilon Eridanii II. \
		Instead, the suit is capable of using its' anomalous properties to attract and \
		carefully distribute layers of ash or ice across the surface; these layers are ablative, but incredibly strong. \
		However, all of this has proven to be straining on all Nanotrasen-approved cells, \
		so much so that it comes default fueled by equally-enigmatic plasma fuel rather than a simple recharge. \
		Additionally, the systems have been put to near their maximum load, allowing for far less customization than others."
	default_skin = "mining"
	armor_type_1 = /obj/item/mod/armor/mod_theme_mining
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_inactive = 1.5
	slowdown_active = 0.5
	allowed_suit_storage = list(
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/pickaxe,
		/obj/item/kinetic_crusher,
		/obj/item/stack/ore/plasma,
		/obj/item/storage/bag/ore,
		/obj/item/gun/energy/kinetic_accelerator,
	)
	inbuilt_modules = list(/obj/item/mod/module/ash_accretion, /obj/item/mod/module/sphere_transform)
	skins = list(
		"mining" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCKHAIR,

				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"asteroid" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_mining
	armor = list(MELEE = 30, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 50, RAD = 50, FIRE = 50, ACID = 50)

/datum/mod_theme/loader
	name = "loader"
	desc = "An unsealed experimental motorized harness manufactured by Scarborough Arms for quick and efficient munition supplies."
	extended_desc = "This powered suit is an experimental spinoff of in-atmosphere Engineering suits. \
		This fully articulated titanium exoskeleton is Scarborough Arms' suit of choice for their munition delivery men, \
		and what it lacks in EVA protection, it makes up for in strength and flexibility. The primary feature of \
		this suit are the two manipulator arms, carefully synchronized with the user's thoughts and \
		duplicating their motions almost exactly. These are driven by myomer, an artificial analog of muscles, \
		requiring large amounts of voltage to function; occasionally sparking under load with the sheer power of a \
		suit capable of lifting 250 tons. Even the legs in the suit have been tuned to incredible capacity, \
		the user being able to run at greater speeds for much longer distances and times than an unsuited equivalent. \
		A lot of people would say loading cargo is a dull job. You could not disagree more."
	default_skin = "loader"
	armor_type_1 = /obj/item/mod/armor/mod_theme_loader
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	siemens_coefficient = 0.25
	complexity_max = DEFAULT_MAX_COMPLEXITY - 5
	slowdown_inactive = 0.5
	slowdown_active = 0
	allowed_suit_storage = list()
	inbuilt_modules = list(/obj/item/mod/module/hydraulic, /obj/item/mod/module/clamp/loader, /obj/item/mod/module/magnet)
	skins = list(
		"loader" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL | BLOCKHAIR,

				SEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEYES,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
			),
			GAUNTLETS_FLAGS = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_loader
	armor = list(MELEE = 20, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 25, ACID = 25)

/datum/mod_theme/medical
	name = "medical"
	desc = "A lightweight suit by DeForest Medical Corporation, allows for easier movement."
	extended_desc = "A lightweight suit produced by the DeForest Medical Corporation and BioTech Solutions, based off the work of \
		Cybersun Industries. The latest in technology has been employed in this suit to render it immunized against \
		allergens, airborne toxins, and regular pathogens. The primary asset of this suit is the speed, \
		fusing high-powered servos and actuators with a carbon-fiber construction. While there's very little armor used, \
		it is incredibly acid-resistant. It is slightly more demanding of power than civilian-grade models, \
		and weak against fingers tapping the glass."
	default_skin = "medical"
	armor_type_1 = /obj/item/mod/armor/mod_theme_medical
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_inactive = 1
	slowdown_active = 0.45
	allowed_suit_storage = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
	)
	skins = list(
		"medical" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"corpsman" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_medical
	armor = list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 75, ACID = 150)

/datum/mod_theme/rescue
	name = "rescue"
	desc = "An advanced version of DeForest Medical Corporation's medical suit, designed for quick rescue of bodies from the most dangerous environments."
	extended_desc = "An upgraded, overtuned version of DeForest Medical Corporation's medical suit, with BioTech Solutions making heavy modifications. \
		designed for quick rescue of bodies from the most dangerous environments. The same advanced leg servos \
		as the base version are seen here, giving paramedics incredible speed, but the same servos are also in the arms. \
		Users are capable of quickly hauling even the heaviest crewmembers using this suit, \
		all while being entirely immune against chemical and thermal threats. \
		It is slightly more demanding of power than civilian-grade models, and weak against fingers tapping the glass."
	default_skin = "rescue"
	armor_type_1 = /obj/item/mod/armor/mod_theme_rescue
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	slowdown_inactive = 0.75
	slowdown_active = 0.25
	inbuilt_modules = list()
	allowed_suit_storage = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
		/obj/item/melee/classic_baton/telescopic,
	)
	skins = list(
		"rescue" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_rescue
	armor = list(MELEE = 20, BULLET = 20, LASER = 5, ENERGY = 5, BOMB = 10, RAD = 50, FIRE = 150, ACID = 150) //Extra melee / bullet armor for if they get caught in a fight. Of course, no laser armor.

/datum/mod_theme/research
	name = "research"
	desc = "A private military EOD suit by Aussec Armory, intended for explosive research. Bulky, but expansive."
	extended_desc = "A private military EOD suit by Aussec Armory, based off the work of Cybersun Industries. \
		This suit is intended for explosive research, built incredibly bulky and well-covering. \
		Featuring an inbuilt chemical scanning array, this suit uses two layers of plastitanium armor, \
		sandwiching an inert layer to dissipate kinetic energy into the suit and away from the user; \
		outperforming even the best conventional EOD suits. However, despite its immunity against even \
		missiles and artillery, all the explosive resistance is mostly working to keep the user intact, \
		not alive. The user will also find narrow doorframes nigh-impossible to surmount."
	default_skin = "research"
	armor_type_1 = /obj/item/mod/armor/mod_theme_research
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_inactive = 1.75
	slowdown_active = 1
	ui_theme = "changeling"
	inbuilt_modules = list(/obj/item/mod/module/reagent_scanner/advanced)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/hand_tele,
		/obj/item/storage/bag/bio,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/gun
	)
	skins = list(
		"research" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEYES,
				UNSEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_research
	armor = list(MELEE = 30, BULLET = 30, LASER = 5, ENERGY = 5, BOMB = INFINITY, RAD = 75, FIRE = 75, ACID = 150) //Slow balistic / explosive testing armor. Not laser testing however!

/datum/mod_theme/security
	name = "security"
	desc = "A Shellguard Munitions security suit, offering quicker speed at the cost of carrying capacity."
	extended_desc = "A Shellguard Munitions classic, this model of MODsuit has been designed for quick response to \
		hostile situations. These suits have been layered with plating worthy enough for fires or corrosive environments, \
		and come with composite cushioning and an advanced honeycomb structure underneath the hull to ensure protection \
		against broken bones or possible avulsions. The suit's legs have been given more rugged actuators, \
		allowing the suit to do more work in carrying the weight. However, the systems used in these suits are more than \
		a few years out of date, leading to an overall lower capacity for modules."
	default_skin = "security"
	armor_type_1 = /obj/item/mod/armor/mod_theme_security
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	slowdown_inactive = 1
	slowdown_active = 0.45
	ui_theme = "security"
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	skins = list(
		"security" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_security
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 25, RAD = 0, FIRE = 150, ACID = 150)

/datum/mod_theme/safeguard
	name = "safeguard"
	desc = "A Shellguard Munitions advanced security suit, offering greater speed and fire protection than the standard security model."
	extended_desc = "A Shellguard Munitions advanced security suit, and their latest model. This variant has \
		ditched the presence of a reinforced glass visor entirely, replacing it with a 'blast visor' utilizing a \
		small camera on the left side to display the outside to the user. The plating on the suit has been \
		dramatically increased, especially in the pauldrons, giving the wearer an imposing silhouette. \
		Heatsinks line the sides of the suit, and greater technology has been used in insulating it against \
		both corrosive environments and sudden impacts to the user's joints."
	default_skin = "safeguard"
	armor_type_1 = /obj/item/mod/armor/mod_theme_safeguard
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	slowdown_inactive = 0.75
	slowdown_active = 0.25
	ui_theme = "security"
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	skins = list(
		"safeguard" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEYES,
				UNSEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_safeguard
	armor = list(MELEE = 30, BULLET = 25, LASER = 25, ENERGY = 15, BOMB = 40, RAD = 25, FIRE = INFINITY, ACID = 150)

/datum/mod_theme/magnate
	name = "magnate"
	desc = "A fancy, very protective suit for Nanotrasen's captains. Shock, fire and acid-proof while also having a large capacity and high speed."
	extended_desc = "They say it costs four hundred thousand credits to run this MODsuit... for twelve seconds. \
		The Magnate suit is designed for protection, comfort, and luxury for Nanotrasen Captains. \
		The onboard air filters have been preprogrammed with an additional five hundred different fragrances that can \
		be pumped into the helmet, all of highly-endangered flowers. A bespoke Tralex mechanical clock has been placed \
		in the wrist, and the Magnate package comes with carbon-fibre cufflinks to wear underneath. \
		My God, it even has a granite trim. The double-classified paint that's been painstakingly applied to the hull \
		provides protection against shock, fire, and the strongest acids. Onboard systems employ meta-positronic learning \
		and bluespace processing to allow for a wide array of onboard modules to be supported, and only the best actuators \
		have been employed for speed. The resemblance to a Gorlex Marauder helmet is *purely* coincidental."
	default_skin = "magnate"
	armor_type_1 = /obj/item/mod/armor/mod_theme_magnate
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF // Theft targets should be hard to destroy
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_inactive = 0.75
	slowdown_active = 0.25
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee,
		/obj/item/gun,
	)
	skins = list(
		"magnate" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_magnate
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 15, BOMB = 15, RAD = 50, FIRE = INFINITY, ACID = 450) //On one hand this is quite strong, on the other hand energy hole / antagonists need to steal, and thus by extention use this.

/datum/mod_theme/praetorian
	name = "praetorian"
	desc = "A prototype of the Magnate-class suit issued to station Blueshields, still boasting exceptional protection worthy of an honor guard."
	extended_desc = "A prototype of the Magnate-class suit issued for use with the station Blueshields, \
		it boasts most of the exceptional protection of it's successor, while sacrificing some of the module capacity.\
		Most of the protection of the Magnate, with none of the comfort! The visor uses blue-light to obscure \
		the face of it's wearer, adding to it's imposing figure. Compared to the sleek and luxurious design \
		that came after it, this suit does nothing to hide it's purpose, the reinforced plating layered \
		over the insulated inner armor granting it protection against corrosive liquids, explosive blasts, \
		fires, electrical shocks, and contempt from the rest of the crew."
	default_skin = "praetorian"
	armor_type_1 = /obj/item/mod/armor/praetorian
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	slowdown_inactive = 0.75
	slowdown_active = 0.25
	allowed_suit_storage = list(
		/obj/item/gun,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/flashlight,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/kitchen/knife/combat
	)
	skins = list(
		"praetorian" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/praetorian
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 25, RAD = 0, FIRE = 150, ACID = 150) //Equivalent armor to Security MODsuits

/datum/mod_theme/cosmohonk
	name = "cosmohonk"
	desc = "A suit by Honk Ltd. Protects against low humor environments. Most of the tech went to lower the power cost."
	extended_desc = "The Cosmohonk MODsuit was originally designed for interstellar comedy in low-humor environments. \
		It utilizes tungsten electro-ceramic casing and chromium bipolars, coated in zirconium-boron paint underneath \
		a dermatiraelian subspace alloy. Despite the glaringly obvious optronic vacuum drive pedals, \
		this particular model does not employ manganese bipolar capacitor cleaners, thank the Honkmother. \
		All you know is that this suit is mysteriously power-efficient, and far too colorful for the Mime to steal."
	default_skin = "cosmohonk"
	armor_type_1 = /obj/item/mod/armor/mod_theme_cosmohonk
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.25
	slowdown_inactive = 1.75
	slowdown_active = 1.25
	allowed_suit_storage = list(
		/obj/item/bikehorn,
		/obj/item/grown/bananapeel,
		/obj/item/reagent_containers/spray/waterflower,
		/obj/item/instrument,
	)
	skins = list(
		"cosmohonk" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCKHAIR,

				SEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEYES,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_cosmohonk
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, RAD = 0, FIRE = 75, ACID = 50)

/datum/mod_theme/syndicate
	name = "syndicate"
	desc = "A suit designed by Gorlex Marauders, offering armor ruled illegal in most of Spinward Stellar."
	extended_desc = "An advanced combat suit adorned in a sinister crimson red color scheme, produced and manufactured \
		for special mercenary operations. The build is a streamlined layering consisting of shaped Plasteel, \
		and composite ceramic, while the under suit is lined with a lightweight Kevlar and durathread hybrid weave \
		to provide ample protection to the user where the plating doesn't, with an illegal onboard electric powered \
		ablative shield module to provide resistance against conventional energy firearms. \
		A small tag hangs off of it reading; 'Property of the Gorlex Marauders, with assistance from Cybersun Industries. \
		All rights reserved, tampering with suit will void warranty."
	default_skin = "syndicate"
	armor_type_1 = /obj/item/mod/armor/mod_theme_syndicate

	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 1
	slowdown_active = 0.5 //This is EVA mode slowdown. In combat mode, no slowdown.
	ui_theme = "syndicate"
	inbuilt_modules = list(/obj/item/mod/module/armor_booster)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/gun,
	)
	skins = list(
		"syndicate" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"honkerative" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_syndicate
	armor = list(MELEE = 15, BULLET = 20, LASER = 5, ENERGY = 5, BOMB = 35, RAD = INFINITY, FIRE = 50, ACID = 450)
	//melee = 40 with booster
	//bullet = 50
	//laser = 20 with booster
	//energy = //20 with booster, energy has always been an armor hole.
/datum/mod_theme/elite
	name = "elite"
	desc = "An elite suit upgraded by Cybersun Industries, offering upgraded armor values."
	extended_desc = "An evolution of the syndicate suit, featuring a bulkier build and a matte black color scheme, \
		this suit is only produced for high ranking Syndicate officers and elite strike teams. \
		It comes built with a secondary layering of ceramic and Kevlar into the plating providing it with \
		exceptionally better protection along with fire and acid proofing. A small tag hangs off of it reading; \
		'Property of the Gorlex Marauders, with assistance from Cybersun Industries. \
		All rights reserved, tampering with suit will void life expectancy.'"
	default_skin = "elite"
	armor_type_1 = /obj/item/mod/armor/mod_theme_elite
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 1
	slowdown_active = 0.5 //This is EVA mode slowdown. In combat mode, no slowdown.
	ui_theme = "syndicate"
	inbuilt_modules = list(/obj/item/mod/module/armor_booster)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/gun,
	)
	skins = list(
		"elite" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_elite
	armor = list(MELEE = 50, BULLET = 45, LASER = 35, ENERGY = 10, BOMB = 60, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	//melee = 50 // 75 with booster
	//bullet = 45 // 75 same as
	//laser = 35 //50 same as
	//energy = 15 // 25

/datum/mod_theme/prototype
	name = "prototype"
	desc = "A prototype modular suit powered by locomotives. While it is comfortable and has a big capacity, it remains very bulky and power-inefficient."
	extended_desc = "This is a prototype powered exoskeleton, a design not seen in hundreds of years, the first \
		post-void war era modular suit to ever be safely utilized by an operator. This ancient clunker is still functional, \
		though it's missing several modern-day luxuries from updated Cybersun Industries designs. \
		Primarily, the suit's myoelectric suit layer is entirely non-existant, and the servos do very little to \
		help distribute the weight evenly across the wearer's body, making it slow and bulky to move in. \
		The internal heads-up display is rendered in nearly unreadable cyan, as the visor suggests, \
		leaving the user unable to see long distances. However, the way the helmet retracts is pretty cool."
	default_skin = "prototype"
	armor_type_1 = /obj/item/mod/armor/mod_theme_prototype
	resistance_flags = FIRE_PROOF
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_inactive = 2
	slowdown_active = 0.95
	ui_theme = "hackerman"
	inbuilt_modules = list(/obj/item/mod/module/anomaly_locked/kinesis/prebuilt/prototype)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/t_scanner,
		/obj/item/rpd,
		/obj/item/rcd,
	)
	skins = list(
		"prototype" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEYES,
				UNSEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_prototype
	armor = list(MELEE = 20, BULLET = 5, LASER = 10, ENERGY = 10, BOMB = 50, RAD = 50, FIRE = 150, ACID = 150)

/datum/mod_theme/responsory
	name = "responsory"
	desc = "A high-speed rescue suit by Nanotrasen, intended for its' emergency response teams."
	extended_desc = "A streamlined suit of Nanotrasen design, these sleek black suits are only worn by \
		elite emergency response personnel to help save the day. While the slim and nimble design of the suit \
		cuts the ceramics and ablatives in it down, dropping the protection, \
		it keeps the wearer safe from the harsh void of space while sacrificing no speed whatsoever. \
		While wearing it you feel an extreme deference to darkness. "
	default_skin = "responsory"
	armor_type_1 = /obj/item/mod/armor/mod_theme_responsory

	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 0.5
	slowdown_active = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	skins = list(
		"responsory" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"inquisitory" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEYES,
				UNSEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/// This has no slowdown active, and no variation between levels. I am ASSUMING this will be gamma only.
/obj/item/mod/armor/mod_theme_responsory
	armor = list(MELEE = 40, BULLET = 25, LASER = 25, ENERGY = 20, BOMB = 25, RAD = INFINITY, FIRE = 200, ACID = 200)

/datum/mod_theme/apocryphal
	name = "apocryphal"
	desc = "A high-tech, only technically legal, armored suit created by a collaboration effort between Nanotrasen and Shellguard Munitions."
	extended_desc = "A bulky and only legal by technicality suit, this ominous black and red MODsuit is only worn by \
		Nanotrasen Black Ops teams. If you can see this suit, you fucked up. A collaborative joint effort between \
		Shellguard and Nanotrasen, the construction and modules gives the user robust protection against \
		anything that can be thrown at it, along with acute combat awareness tools for it's wearer. \
		Whether the wearer uses it or not is up to them. \
		There seems to be a little inscription on the wrist that reads; \'squiddie', d'aww."
	default_skin = "apocryphal"
	armor_type_1 = /obj/item/mod/armor/mod_theme_apocryphal
	resistance_flags = FIRE_PROOF | ACID_PROOF
	ui_theme = "malfunction"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 10
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/gun,
	)
	skins = list(
		"apocryphal" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCKHAIR,

				SEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEYES,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_apocryphal
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)

/datum/mod_theme/corporate
	name = "corporate"
	desc = "A fancy, high-tech suit for Nanotrasen's high ranking officers."
	extended_desc = "An even more costly version of the Magnate model, the corporate suit is a thermally insulated, \
		anti-corrosion coated suit for high-ranking CentCom Officers, deploying pristine protective armor and \
		advanced actuators, feeling practically weightless when turned on. Scraping the paint of this suit is \
		counted as a war-crime and reason for immediate execution in over fifty Nanotrasen space stations. \
		The resemblance to a Gorlex Marauder helmet is *purely* coincidental."
	default_skin = "corporate"
	armor_type_1 = /obj/item/mod/armor/mod_theme_corporate
	resistance_flags = FIRE_PROOF | ACID_PROOF

	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 0.5
	slowdown_active = 0
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	skins = list(
		"corporate" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_corporate
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)

/datum/mod_theme/debug
	name = "debug"
	desc = "Strangely nostalgic."
	extended_desc = "An advanced suit that has dual ion engines powerful enough to grant a humanoid flight. \
		Contains an internal self-recharging high-current capacitor for short, powerful bo- \
		Oh wait, this is not actually a flight suit. Fuck."
	default_skin = "debug"
	armor_type_1 = /obj/item/mod/armor/mod_theme_debug
	resistance_flags = FIRE_PROOF | ACID_PROOF

	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = 50
	siemens_coefficient = 0
	slowdown_inactive = 0.5
	slowdown_active = 0
	allowed_suit_storage = list(
		/obj/item/gun,
	)
	skins = list(
		"debug" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_debug
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)


/datum/mod_theme/administrative
	name = "administrative"
	desc = "A suit made of adminium. Who comes up with these stupid mineral names?"
	extended_desc = "Yeah, okay, I guess you can call that an event. What I consider an event is something actually \
		fun and engaging for the players- instead, most were sitting out, dead or gibbed, while the lucky few got to \
		have all the fun. If this continues to be a pattern for your \"events\" (Admin Abuse) \
		there will be an admin complaint. You have been warned."
	default_skin = "debug"
	armor_type_1 = /obj/item/mod/armor/mod_theme_administrative
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = 1000
	charge_drain = DEFAULT_CHARGE_DRAIN * 0
	siemens_coefficient = 0
	slowdown_inactive = 0
	slowdown_active = 0
	allowed_suit_storage = list(
		/obj/item/gun,
	)
	skins = list(
		"debug" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/// considering this should not be used, it's getting just DS armor, not infinity in everything.
/obj/item/mod/armor/mod_theme_administrative
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)

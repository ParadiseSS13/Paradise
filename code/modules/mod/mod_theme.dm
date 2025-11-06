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
	var/desc = "A basic civilian modsuit by Cybersun Industries. Environmentally sealed but doesn't offer much in the way of protection."
	/// Extended description on examine_more
	var/extended_desc = "Easily the most common civilian modsuit in the Sector today, the Cybersun Industries CS-11 'Wanderer' is a cheap, reliable, and lightweight EVA unit suited for all manner \
		of standard extravehicular tasks. As little more than a hard-shelled space suit, the Wanderer offers little in the way of remarkable features. Its thin armor panelling is rated for micrometeoroids and little \
		else, easily faltering before any dedicated melee, projectile, or energy weapon. Its mass-produced servo systems, while quite efficient, are also underpowered, leading to mildly reduced movement, \
		though this is somewhat offset by the suit's lightweight design. Today, the Wanderer is found nearly everywhere space travel occurs, as its low price tag and ease of use make it \
		perfect for small-time traders, frontier colonies, and other civilian spacecraft."
	/// Default skin of the MOD.
	var/default_skin = "standard"
	/// The slot this mod theme fits on
	var/slot_flags = ITEM_SLOT_BACK
	/// Armor shared across the MOD parts.
	var/obj/item/mod/armor/armor_type_1 = /obj/item/mod/armor/mod_theme
	/// the actual armor object placed in a datum as I am tired and I just want this to work
	var/obj/item/mod/armor/armor_type_2 = null
	/// Resistance flags shared across the MOD parts.
	var/resistance_flags = NONE
	/// Flag_2 flags to apply to the modsuit parts.
	var/flag_2_flags = NONE
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
	/// List of modifiers that we apply after applying new skin
	var/list/skin_modifiers = list()
	/// List of skins with their appropriate clothing flags.
	var/list/skins = list(
		"standard" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCKHAIR,
				SEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEARS | HIDEEYES,
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
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEARS |HIDEEYES,
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
	name = "'Wanderer' standard"


/datum/mod_theme/New()
	. = ..()
	armor_type_2 = new armor_type_1

/obj/item/mod/armor/mod_theme
	armor = list(MELEE = 15, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 25, FIRE = 33, ACID = 33)

/datum/mod_theme/engineering
	name = "'Spark' engineering"
	desc = "A standard industrial modsuit. Fire-resistant, shockproof, and fitted with lead insulation for additional radiation protection."
	extended_desc = "The flagship product of Cybersun Industries's industrial modsuit lineup, the CS-15 'Spark' is an EVA-capable engineering suit designed to provide personal protection in all manner of hostile work environments. \
		The double-insulated carapace renders the user immune to most electrical hazards, while an additional layer of lead plating massively reduces (but does not eliminate) radiation exposure from high-intensity sources, permitting work to be performed in \
		active radiological zones as long as exposure is properly managed. An inner layer of nomex provides some protection against exposure to the radiant heat of active fires, \
		but is not rated for full fire engulfment. It also offers some minor protection against low-grade explosive detonations."
	default_skin = "engineering"
	armor_type_1 = /obj/item/mod/armor/mod_theme_engineering
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 1.5
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	name = "'Canary' atmospheric"
	desc = "A reinforced atmospherics modsuit meant for extreme environments. Completely fireproof, but somewhat lacking in modification potential and power efficiency."
	extended_desc = "Developed from the popular 'Spark' chassis, the CS-16 'Canary' utility modsuit is specialised for use by atmospherics specialists. The outer carapace is made of highly insulating thermally-reflective composites \
		underlain with multiple layers of insulating fiberglass, which, in combination with a high-powered thermal regulation system, provides the user complete protection from even full engulfment inside a raging plasma fire. \
		The helmet contains integrated filtration systems that protect the user from sudden releases of harmful gasses, - a feature not present in the 'Spark' suit. \
		Cybersun Industries reminds users that this model features minimal radiation shielding - it is not suitable PPE for use in radiological hazard zones."
	default_skin = "atmospheric"
	armor_type_1 = /obj/item/mod/armor/mod_theme_atmospheric
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	siemens_coefficient = 0
	slowdown_inactive = 1.5
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	name = "'Daedalus' advanced"
	desc = "A highly advanced competitor to the standard engineering modsuit. Completely resistant to radiation, fire, and electricity, with improved conventional armor to boot. The paint gleams like freshly fallen snow."
	extended_desc = "A product of the bloated generosity of several prominent Nanotrasen executives and their desire to upstage Cybersun at their own game, the NA-20 'Daedalus' represents the peak of powered industrial protection. The thick, double-insulated plastitanium composite carapace offers complete protection from most electrical hazards \
		in addition to enhanced resistance against heavy impacts, mid-grade explosive detonations, and a slight resistance to directed energy blasts. An underlayer of lead overlain with depleted uranium offers unparalleled protection from even \
		the most intense radiation exposure, whilst the advanced thermal control system and thermally-reflective surface coating allows the suit to withstand full flame engulfment. The built-in magboots also feature advanced predictive algorithms \
		so that they can activate and deactivate as the user moves their feet, removing the heavy slogging motion caused by standard magboots. This entire package is supported by a combination of custom joint motors and pseudo-muscle bundles \
		that are capable of supporting the full weight of the suit and moving it just as fast as the user inside could without any encumbrance, making it so unobtrusive that many users feel absolutely no need to remove the suit, even at times when there's really no point in wearing it."
	default_skin = "advanced"
	armor_type_1 = /obj/item/mod/armor/mod_theme_advanced
	resistance_flags = FIRE_PROOF
	flag_2_flags = RAD_PROTECT_CONTENTS_2
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	name = "'Pioneer' mining"
	desc = "A Nanotrasen mining suit for extracting resources in even the harshest of environments. Highly mobile with decent protection against fire and melee attackers. Its external ports have been replaced by an opening on the upper chest which accepts plasma sheets to recharge its specialized plasma energy core."
	extended_desc = "A fairly recent innovation from Nanotrasen's research division, the NA-10 'Pioneer' is a rugged and reliable mining suit specialized for extraction operations in extreme conditions. \
		Incorporating a durable kevlar bodysuit under strategically placed armor panels, the Pioneer offers sound protection against melee attacks, while additional attachment points allow for specialized armor to be \
		attached at user discretion. As an extra protective measure against the vicious ash storms of Lavaland, an experimental ash accretion system has also been integrated, protecting the wearer with a shell of ablative ash. \
		This particular variant of the Pioneer has also been fitted with a specialized plasma-fueled energy core, allowing for surface miners to quickly recharge \
		even on long-term excursions, though this comes at the cost of greatly decreased maximum operating time. Today, this suit is most often used by Nanotrasen's extraction division in their endless quest for Plasma, though \
		several other prominent mining companies have purchased large stocks of the suit for their own operations."
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
	skin_modifiers = list(
		"asteroid" = MAKE_SPACEPROOF
	)
	skins = list(
		"mining" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCKHAIR,

				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	name = "'Heracles' loader"
	desc = "An unsealed industrial exoframe developed by Aussec Armory for munitions loading and heavy equipment transport. Incredible carrying capacity, but lackluster armor and modability."
	extended_desc = "Aussec Armory's first foray into the field of powered modsuits, the AX-05 'Heracles' was designed from the ground-up for transporting heavy equipment and munitions. Incorporating a suite \
		of exceptionally powerful hydraulic systems and myomer synth-muscle, the Heracles's two massive lifting arms are capable of carrying loads up to 250 tons without hampering mobility. \
		High-grade servomotors round out the package, ensuring complete freedom of movement even when transporting the largest of crates or artillery shells. Unfortunately, the Heracles is severely lacking \
		in the protection department, with only a simple steel outer shell that may deflect a crude melee weapon at most. The suit also entirely lacks environmental sealing, a point Aussec makes very clear \
		in their user agreement, while the immense space demands of the hydraulics drastically cut the suit's modification potential. Despite these shortcomings, the Heracles was a breakout success, and now \
		sees extensive use within the Trans-Solar Federation's logistics corps, and in loading bays across the Sector."
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

				SEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEARS | HIDEEYES,
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
	name = "'Apollo' medical"
	desc = "A lightweight medical modsuit. Environmentally sealed and acid-resistant but offering little else in the way of armor. Thankfully, the light materials and motors keep mobility high."
	extended_desc = "A lightweight medical suit produced by the DeForest Medical Corporation, the D-101 'Apollo' is a simple powered medical suit intended for recovering and treating \
		patients in environmentally risky zones, such as space stations, chemical facilities, and disease outbreak sites. Composed of a lightweight aluminum frame supporting a polymer & carbon fiber \
		outer shell, the Apollo maintains a surprisingly light weight that allows its underpowered and inefficient servomotors to easily keep the wearer operating at maximum speed. \
		This comes at a cost in protection, however, as while the Apollo's treated paneling offers excellent defense against biological and chemical agents, it is entirely ineffective against \
		any form of conventional attack or weapon. Today, the Apollo is an exceptionally common suit seen in medical bays across the Orion Arm, and is well-loved by EMTs and virologists \
		alike for its ease of use and movement."
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	name = "'Valkyrie' rescue"
	desc = "A next-generation medical suit for casualty care in even the most hostile of conditions. Fast, chemically sealed, and decently armored to boot."
	extended_desc = "A direct upgrade to the older Apollo line, the D-112 'Valkyrie' is an advanced medical modsuit produced by the DeForest Medical Corporation. Offering iterative improvement over earlier lines, \
		the Valkyrie uses improved servo systems and drive motors to deliver faster movement speed than the Apollo line, and it comes standard with a high-efficiency energy core which helps offset its otherwise outsized power draw. \
		The suit's armor has also seen large improvement, incorporating ballistic polymer impact panels in key areas, offering moderate protection against melee and projectile attacks, while a chemically-treated \
		aramid bodysuit provides near-complete safety against fire and caustic chemicals. For added protection in chemical and biological hazard zones, the helmet incorporates an integrated CBRN filtration system rated \
		to halt even the most virulent of chemical weapons or infectious diseases. Today, the Valkyrie is a mainstay of numerous corporate and governmental medical units across the Sector, though the high price tag means \
		that many less-funded medical practices continue to operate the Apollo series."
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	armor = list(MELEE = 20, BULLET = 20, LASER = 5, ENERGY = 5, BOMB = 10, RAD = 250, FIRE = 150, ACID = 150) //Extra melee / bullet armor for if they get caught in a fight. Of course, no laser armor.

/datum/mod_theme/research
	name = "'Minerva' research"
	desc = "A powered EOD suit produced by Aussec Armory. Absolutely unmatched explosive and acid protection, along with heavy conventional armor and high modding potential."
	extended_desc = "Developed following the surprising success of the 'Heracles' powerloader suit, the AX-1-0 'Minerva' was originally intended as a competitor to ongoing TSF trials for a new generation \
		of bomb-disposal armor. While the original design would fail to meet Federation maintenance standards, Aussec's board of directors saw sufficient potential in the suit to market it instead as a \
		heavy-duty research platform. Equipped with double-layered blast foam paneling encased in a durable plasteel outer carapace, the AX-1-0 offers outstanding protection against explosives and industrial chemicals, \
		and will even deflect some low-caliber ballistic rounds and melee weaponry. Unfortunately, underperforming heat dissipation materials mean that the suit offers little in the way of directed energy \
		protection. Today, the Minerva is most often seen in high-profile research laboratories, given its high price tag and maintenance requirements. Notably, Nanotrasen has purchased a significant number of the suits \
		for high-ranking science personnel, shipping most to the advanced testing labs of Epsilon Eridani."
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
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEARS | HIDEEYES,
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
	name = "'Takabara' security"
	desc = "An older-model Shellguard Munitions combat modsuit intended for corporate security forces. Decently armored and highly mobile, but somewhat lackluster in modification potential."
	extended_desc = "A fairly average private security modsuit, the SA-330 'Takabara' is a Shellguard Munitions workhorse, and a recognizable symbol of Nanotrasen corporate security. \
		Equipped with kevlar paneling in vital areas and ceramic strike plates in the chest and back, the Takabara offers sufficient protection to deter most petty criminals and improvised melee weapons, \
		though it stands little match in the face of gunfire or advanced melee weapons. An unconventional nomex underlayer and chemically treated plating provides deceptively high fire \
		and acid protection. While the suit is quite easy to maintain, the limitations of its last-gen design have gradually become more apparent, with easily-taxed servos and restrictive hardware that limits its modification potential. \
		Despite these flaws, the Takabara continues to see immense success in the private security market across the Sector largely due to its low price and ease of operation. In particular, Nanotrasen \
		remains a primary customer thanks to their deep ties with Shellguard and extensive security infrastructure."
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	name = "'Safeguard' bulwark"
	desc = "A current-gen suit of powered armor by Shellguard Munitions. Offers substantially improved protection over the base security modsuit, and is completely fireproof."
	extended_desc = "A fairly recent development by Shellguard Munitions, the SA-350 'Safeguard' modsuit is a largely iterative powered armor suit that builds off of and offers improvement \
		over the older Takabara series of corporate security suits. Expanding the ceramic and steel plating further provides significantly improved conventional defenses, while the addition of \
		an advanced temperature regulation system makes the Safeguard completely immune to extreme heat. The suit's internals were also enhanced, with improved servo systems for added mobility, \
		while the suit's updated computer hardware improves its overall modification potential. The most striking development, however, is the suit's overall bulkier and more intimidating appearance, incorporating \
		pronounced armored pauldrons and replacing the traditional eyeholes with a camera-equipped blank faceplate. Today, the Safeguard is most commonly seen in well-funded corporate security units, most \
		notably the Nanotrasen Corporation, which has purchased a large stock of the suits for high-ranking security personnel."
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
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEARS | HIDEEYES,
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
	name = "'Magnate' command"
	desc = "An advanced command modsuit developed by Nanotrasen for high-ranking corporate officers. Heavily armored, highly mobile, and plenty of space for modifications."
	extended_desc = "An in-house design by Nanotrasen R&D, the Magnate encases the user inside a shell of plastitanum alloy with an ablative surface coating, giving robust protection against ballistic and energy-based threats in equal measure, and granting respectable protection from corrosive substances as well. \
		An under-layer of ultra low-conductivity ceramic provides protection against the heat of raging fires and high intensity electrical discharges.\
		The use of custom articulation first utilized in the NA-20 'Daedalus' means that the Magnate will not encumber the user under most circumstances, allowing them to move freely despite the mass of the suit. \
		The over-engineered electrical and hydraulic systems also give it exceptional capacity for modification, allowing endless choice in how exactly a captain may wish to drain the resources of their robotics department. \
		Overall, the Magnate provides protection rivalled only by the 'Jaeger' MODsuit of Syndicate infamy. Nanotrasen's public relations department maintains that any resemblance to designs used by Gorlex are <b>purely</b> coincidental."
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	name = "'Praetorian' escort"
	desc = "A Nanotrasen refit of the Takabara modsuit line. Offers higher mobility than the base model, and comes with a snazzy blue-and-black paint job."
	extended_desc = "A licensed copy of the Shellguard Munitions 'Takabara' modsuit, the NA-35 'Praetorian' is specially issued to Nanotrasen Asset Protection's Blueshield Corps: \
		elite bodyguards charged with protecting Nanotrasen VIPs. As such, the suit's motor and weight distribution systems have seen a measure of improvement, to allow for the \
		Blueshields to more effectively respond to threats facing their charges. Beyond this and its stylish blue & black paint job, however, the Praetorian differs little \
		from its Shellguard roots, retaining its middling armor ratings and restrictive hardware. Even so, Nanotrasen is more than happy with the design, and has proceeded \
		with a full rollout of the suit to Blueshields across their corporate empire."
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	name = "'Cosmohonk' entertainer"
	desc = "A highly specialized modsuit for use by clowns across the Sector. Excellent power efficiency, godawful everything else."
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

				SEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEARS | HIDEEYES,
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
	name = "'Raider' blood-red syndicate"
	desc = "An intimidating suit of powered armor in Gorlex blood-red & black, primarily used by the Syndicate. Offers substantial protection in all areas, and looks great while doing so."
	extended_desc = "One of the Syndicate's most recognizable symbols, the CSC-22 'Raider' was commissioned by the Gorlex Marauders in conjunction with an unknown benefactor \
		some suspect to be Cybersun Industries, though the company vigorously denies this claim. The suit itself is purpose-built for fast-paced, high-intensity combat, and is armored to match. \
		Though offering substantial conventional armor with a durathread-kevlar underlayer overlaid with steel armor panels and ceramic strike plates, the Raider's most notable armor comes from its advanced Armor Booster in-built module. \
		Consisting of a miniaturized electromagnetic defense system and combat servomotors, the module allows the user to switch to 'Combat Mode' at the press of a button, massively improving movement speed and defense capability. \
		Unfortunately, doing so requires sacrificing EVA capability, as power is diverted from the environmental regulation systems, while auxiliary vents open to keep the EM defenses' motor cooled. \
		Today, the Raider is used almost exclusively by the Syndicate, and is the standard combat suit for their Nuclear Strike Teams. In particular, the Gorlex Marauders use the Raider as their standard assault suit, \
		and the mere sight of its blood-red plating is known to induce terror in most indepedent merchantmen."
	default_skin = "syndicate"
	armor_type_1 = /obj/item/mod/armor/mod_theme_syndicate
	flag_2_flags = RAD_PROTECT_CONTENTS_2
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	name = "'Jaeger' elite syndicate"
	desc = "A terrifying, jet-black suit of advanced power armor, used by the Syndicate's elite forces. Completely fireproof, and offers phenomenal protection in all areas."
	extended_desc = "Following the incredible success of the Raider-series combat modsuit, several other prominent mercenary and pirate groups began to look into procuring their own personal combat modsuits, most notably the mysterious Inner Circle PMC. \
		The resulting design, known as the CSC-25 'Jaeger', is one of the finest suits of powered armor ever devised, and a herald of imminent death for any opposed to the Inner Circle and the Syndicate. \
		Replacing the earlier steel and ceramic armor panels with a reinforced plastitanium-alloy carapace and strengthened sorbothane impact absorption panels over the traditional kevlar weave undersuit, the Jaeger offers massively improved \
		protection over the Raider, including complete immunity to extreme heat. The Armor Booster subsystem has seen similar improvements, increasing protection to such an extent that only armor-piercing rifle rounds can reliably penetrate the armor. \
		Even the suit's helmet has seen massive changes, replacing the iconic quad-camera faceplate with a polarized plasmaglass visor, and incorporating an advanced filtration system to counteract chemical attacks. \
		Altogether, the Jaeger offers some of the best personal protection in the Sector, and has a price tag to match. Only the wealthiest of Syndicate clients can even hope to purchase one of these suits, let alone outfit an entire company with them."
	default_skin = "elite"
	armor_type_1 = /obj/item/mod/armor/mod_theme_elite
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flag_2_flags = RAD_PROTECT_CONTENTS_2
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	name = "'Ogre' prototype"
	desc = "A prototype modular suit developed many years ago. Incredibly heavy, power inefficient, and lacking in protection. At the very least, it's easy to modify."
	extended_desc = "Quite possibly the first true modsuit ever created, the 'Ogre', as its mostly-faded ID label calls it, is a positively ancient mechanized suit that represents the very beginning of \
		the Sector's foray into powered modsuits. Naturally, such an elderly design lacks virtually all of the quality of life features seen in modsuits today. \
		The first-generation servodrives are woefully underpowered and exceptionally inefficient, leading to a ponderous top speed and an average battery life entirely \
		unsuited to extended EVA usage. As a technology testbed, the Ogre is also sorely lacking in armor protection, possessing little more than a steel carapace \
		more suited to deflecting micrometeoroids than any dedicated weaponry, though the treated underlayer does offer effective fire and chemical protection, at the cost of greatly \
		increased cancer risks after several hours of sustained use."
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
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEARS | HIDEEYES,
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
	name = "\improper 'Ward' responsory"
	desc = "A high-tech combat modsuit designed and produced by Nanotrasen. Well armored, environmentally sealed, and outfitted with all manner of useful gadgetry. \
		The pinnacle of corporate security hardware."
	extended_desc = "A streamlined suit of powered armor produced entirely in-house by the Nanotrasen Corporation, the NA-22 'Ward' rapid response suit is one of the finest combat modsuits available on the market today. \
		Equipped with a fire-resistant polybenzimidazole bodyglove and lightweight nano-polymer impact panels underneath a steel armored shell, the NA-22 offers reliable protection \
		while retaining combat mobility. Internally, the NA-22 comes pre-loaded with NTOS-11 on a five-year subscription, which enables unparallelled customization options in conjunction \
		with the Ward's unusually generous design specifications. Naturally, the NA-22 has a price tag to match its quality, and is thus only found within Nanotrasen's \
		personal response units, as well as among the wealthiest of Sector PMCs and mercenary groups."
	default_skin = "responsory"
	armor_type_1 = /obj/item/mod/armor/mod_theme_responsory

	resistance_flags = FIRE_PROOF
	flag_2_flags = RAD_PROTECT_CONTENTS_2
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEARS | HIDEEYES,
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
	name = "'Charon' absolver"
	desc = "A highly classified suit of powered armor used by {REDACTED}. Offers absolutely unmatched protection in all areas."
	extended_desc = "Developed in absolute secrecy via judicious use of black budgets and compartmentalized production, the NA-000 \
		'Charon' represents the absolute pinnacle of Nanotrasen armor development, and is easily one of the most powerful suits in the entire Sector. \
		Incorporating a durable plasteel-alloy outer shell overlaying a duraweave-nanomesh bodysuit, all protected by a prototype EM defense system, the \
		Charon offers physical protection that is unmatched by nearly every other modsuit existing in the Sector today. Despite this weight, advanced \
		servo and weight distribution systems allow the wearer to move as if unencumbered, while a custom-tuned high-efficiency power distribution system \
		means that the NA-000 has better mileage than most civilian modsuits. Today, less than a hundred of these mighty war machines exist, all of which \
		reside deep in the secure armories of Nanotrasen Asset Protection."
	default_skin = "apocryphal"
	armor_type_1 = /obj/item/mod/armor/mod_theme_apocryphal
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flag_2_flags = RAD_PROTECT_CONTENTS_2
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

				SEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEARS | HIDEEYES,
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
	desc = "A rare, extremely expensive modsuit used exclusively by Nanotrasen executives. Very few will get to see this suit, and fewer still will actually wear it."
	extended_desc = "An even more costly version of the Magnate model, the corporate suit is a thermally insulated, \
		anti-corrosion coated suit for high-ranking CentCom Officers, deploying pristine protective armor and \
		advanced actuators, feeling practically weightless when turned on. Scraping the paint of this suit is \
		counted as a war-crime and reason for immediate execution in over fifty Nanotrasen space stations. \
		The resemblance to a Gorlex Marauder helmet is *purely* coincidental."
	default_skin = "corporate"
	armor_type_1 = /obj/item/mod/armor/mod_theme_corporate
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flag_2_flags = RAD_PROTECT_CONTENTS_2
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	desc = "An admin-only modsuit that's strictly worse than the already existent administrative suit. Why does this even exist?"
	extended_desc = "nyoom"
	default_skin = "debug"
	armor_type_1 = /obj/item/mod/armor/mod_theme_debug
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flag_2_flags = RAD_PROTECT_CONTENTS_2
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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
	desc = "A completely game-breaking suit made of compressed admin abuse. Naturally, it's got bullshit stats, doesn't drain any power at all and... for fuck's sake, does it really need a thousand module slots?!"
	extended_desc = "someone go get the intern to write something here"
	default_skin = "debug"
	armor_type_1 = /obj/item/mod/armor/mod_theme_administrative
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flag_2_flags = RAD_PROTECT_CONTENTS_2
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
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
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

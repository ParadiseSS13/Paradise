/obj/item/nuclear_rod
	name = "Nuclear Control Rod"
	desc = "You shouldnt be seeing this. Contact a developer"
	icon = 'icons/obj/fission/rods.dmi'
	icon_state = "irradiated"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE
	/// How much durability is left before the rod is useless
	var/durability = 6000
	/// The maximum amount of durability for this rod. Used for percentage calculations
	var/max_durability = 6000
	/// How fast does this rod degrade? higher = faster
	var/degredation_speed = 1
	/// How much heat does this rod add by default
	var/heat_amount = 0
	/// How does this rod affect its neighbors heating
	var/heat_amp_mod = 1
	/// How much power does this rod add by default in watts
	var/power_amount = 0
	/// How does this rod affect its neighbors power production
	var/power_amp_mod = 1
	/// What type of radiation is emitted by this rod
	var/list/rad_type
	/// What special gas requirement does this rod need
	var/gas_requirement
	/// What items need to be adjacent to this rod for it to function properly
	var/list/adjacent_requirements = list()

/obj/item/nuclear_rod/fuel
	name = "nuclear fuel rod"
	desc = "This is a base item and should not be found. Alert a developer!"
	rad_type = ALPHA_RAD

/obj/item/nuclear_rod/fuel/uranium_238
	name = "Uranium 235 Fuel Rod"
	desc = "A standard fuel rod for most NGCR reactors. Has just barely enough Uranium 235 to be useful."
	heat_amount = 50
	power_amount = 15 KW
	heat_amp_mod = 1.8
	power_amp_mod = 1.1
	durability = 6000
	rad_type = BETA_RAD

/obj/item/nuclear_rod/fuel/weak_thorium
	name = "Weak Thorium Fuel Rod"
	desc = "A specialized fuel rod bred from uranium 238. This rod will last longer than normal, and wont generate as much heat."
	heat_amount = 50
	power_amount = 15 KW
	heat_amp_mod = 1.6
	power_amp_mod = 1.1
	durability = 10000
	rad_type = ALPHA_RAD
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/coolant,
		)

/obj/item/nuclear_rod/moderator
	name = "nuclear moderator rod"
	desc = "This is a base item and should not be found. Alert a developer!"
	icon_state = "normal"

/obj/item/nuclear_rod/moderator/heavy_water
	name = "Heavy Water Moderator"
	desc = "A basic moderation rod filled with a varint of water comprised of deuterium instead of hydrogen atoms."
	heat_amp_mod = 1.1
	power_amp_mod = 1.4
	durability = 6000

/obj/item/nuclear_rod/coolant
	name = "Nuclear Coolant rod"
	desc = "This is a base item and should not be found. Alert a developer!"
	icon_state = "bananium"

/obj/item/nuclear_rod/coolant/light_water
	name = "Light Water Circulator"
	desc = "A basic coolant rod that circulates distilled water through critical reactor components."
	heat_amount = -20
	heat_amp_mod = 1
	power_amount = -10 KW
	durability = 6000
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)




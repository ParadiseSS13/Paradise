/obj/item/nuclear_rod
	name = "Nuclear Control Rod"
	desc = "You shouldnt be seeing this. Contact a developer"
	icon = 'icons/obj/fission/rods.dmi'
	icon_state = "reactor_off"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE
	/// How much durability is left before the rod is useless
	var/durability = 1000
	/// The maximum amount of durability for this rod. Used for percentage calculations
	var/max_durability = 1000
	/// How fast does this rod degrade? higher = faster
	var/degredation_speed = 1
	/// How much heat does this rod add by default
	var/heat_amount = 0
	/// How does this rod affect its neighbors heating
	var/heat_amp_mod = 1
	/// The total amount of heat produced by this rod
	var/heat_total
	/// How much power does this rod add by default
	var/power_amount = 0
	/// How does this rod affect its neighbors power production
	var/power_amp_mod = 1
	/// The total amount of power produced by this rod
	var/power_total
	/// How much radiation does this rod emit when exposed
	var/rad_amount
	/// What type of radiation is emitted by this rod
	var/list/rad_type

/obj/item/nuclear_rod/fuel
	name = "uranium-238 fuel rod"
	desc = "A rod comprised of multiple small uranium pellets. It can be used to fuel a nuclear reactor, generating heat in the process."
	heat_amount = 50
	power_amount = 50
	rad_type = ALPHA_RAD

/obj/item/nuclear_rod/moderator
	name = "graphite moderator"
	desc = "A solid rod of compressed graphite. It can be used to amplify the reactivity of nearby fuel rods, generating much more heat."
	heat_amp_mod = 1.8
	power_amp_mod = 1.4

/obj/item/nuclear_rod/coolant
	name = "R-32 coolant rod"
	desc = "a sophisticated container of solid refridgerant, compacted into a dense rod. It can be used to help prevent reactors from overheating."
	heat_amount = -20
	heat_amp_mod = 0.8







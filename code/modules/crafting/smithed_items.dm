/obj/smithed_item
	name = "Debug smithed item"
	icon = 'icons/obj/smithing.dmi'
	icon_state = "debug"
	desc = "Debug smithed item. If you see this, notify the development team."
	/// The quality of the item
	var/datum/smith_quality/quality
	/// The material of the item
	var/datum/smith_material/material

/obj/smithed_item/Initialize(mapload)
	. = ..()
	if(!quality)
		return
	if(!material)
		return
	name = "[quality.name] [material.name] " + name

// Insets

/obj/smithed_item/insert
	name = "debug insert"
	icon_state = "insert"
	desc = "Debug insert. If you see this, notify the development team."
	/// Brute armor
	var/brute_armor = 0
	/// Burn armor
	var/burn_armor = 0
	/// Laser armor
	var/laser_armor = 0
	/// Movement speed
	var/movement_speed_mod = 0
	/// Heat insulation
	var/heat_insulation = 0
	/// Electrical insulation
	var/siemens_coeff = 0.0
	/// Radiation armor
	var/radiation_armor = 0

/obj/smithed_item/insert/ballistic
	name = "ballistic plate"
	desc = "A reinforced plate designed to stop small-caliber bullets and kinetic impacts."
	brute_armor = 10
	heat_insulation = 10

/obj/smithed_item/insert/thermal
	name = "thermal plate"
	desc = "A fragile plate designed to reduce heat exposure."
	brute_armor = -10
	burn_armor = 10
	heat_insulation = 10

/obj/smithed_item/insert/fireproofing
	name = "fireproofing plate"
	desc = "A heavy plate of asbestos designed to fireproof a user. A firefighter's godsend."
	burn_armor = 10
	movement_speed_mod = -0.5
	heat_insulation = 20

/obj/smithed_item/insert/reflective
	name = "reflective plate"
	desc = "A shiny plate that assists in laser deflection."
	burn_armor = -10
	laser_armor = 10
	siemens_coeff = -0.2

/obj/smithed_item/insert/rad_hazard
	name = "radiation hazard plate"
	desc = "A dense plate that can reduce a wearer's radiation exposure."
	heat_insulation = -10
	radiation_armor = 20

/obj/smithed_item/insert/rubberized
	name = "rubberized plate"
	desc = "A flexible plate that is resistant to electrical shocks."
	brute_armor = -10
	siemens_coeff = 0.2

/obj/smithed_item/insert/advanced
	name = "advanced armor mesh"
	desc = "An alloy mesh that can protect the wearer from most sources of damage."
	brute_armor = 10
	burn_armor = 10
	laser_armor = 10
	radiation_armor = 10
	movement_speed_mod = -0.5

/obj/smithed_item/insert/engineering
	name = "engineering mesh"
	desc = "An alloy mesh designed to assist in most work around electrical engines."
	brute_armor = -10
	burn_armor = 10
	radiation_armor = 10
	heat_insulation = 10
	siemens_coeff = 0.4
	movement_speed_mod = -0.5

/obj/smithed_item/insert/heavy
	name = "heavy duty plate"
	desc = "An advanced plate often used in SWAT gear. Heavy, yet durable."
	brute_armor = 20
	burn_armor = 10
	laser_armor = 10
	heat_insulation = 10
	siemens_coeff = -0.4
	movement_speed_mod = -1

/obj/smithed_item/insert/mobility
	name = "mobility mesh"
	desc = "An advanced alloy mesh that is both lightweight and invigorating to the wearer."
	brute_armor = -10
	burn_armor = -10
	laser_armor = -10
	heat_insulation = 10
	movement_speed_mod = 1

/obj/smithed_item/insert/admin
	name = "adminium mesh"
	desc = "A special mesh plate reserved exclusively for high-ranking central command personnel."
	brute_armor = 50
	burn_armor = 50
	laser_armor = 50
	radiation_armor = 50
	heat_insulation = 50
	movement_speed_mod = 2
	siemens_coeff = 1

// Tool Bits

/obj/smithed_item/tool_bit
	name = "Debug tool bit"
	icon_state = "bit"
	desc = "Debug tool bit. If you see this, notify the development team."
	/// Speed modifier
	var/speed_mod = 0
	/// Precision modifier
	var/precision_mod = 0
	/// Size modifier
	var/size_mod = 0
	/// Durability
	var/durability = 30
	/// The tool the bit is attached to
	var/obj/item/attached_tool

/obj/smithed_item/tool_bit/proc/break_bit()
	qdel(src)

/obj/smithed_item/tool_bit/speed
	name = "speed bit"
	desc = "A tool bit optimized for speed, at the cost of precision."
	speed_mod = -0.2
	precision_mod = -0.2

/obj/smithed_item/tool_bit/precision
	name = "precision bit"
	desc = "A tool bit optimized for precision, at the cost of speed."
	speed_mod = 0.2
	precision_mod = 0.2

/obj/smithed_item/tool_bit/heavy
	name = "heavy duty bit"
	desc = "A large, advanced tool bit that maximises speed."
	speed_mod = -0.4
	precision_mod = -0.4
	size_mod = 1
	durability = 40

/obj/smithed_item/tool_bit/surgical
	name = "surgical bit"
	desc = "An advanced tool bit that maximises precision."
	speed_mod = 0.4
	precision_mod = 0.6
	durability = 15

/obj/smithed_item/tool_bit/admin
	name = "adminium bit"
	desc = "A hyper-advanced bit restricted to central command officials."
	speed_mod = -1
	precision_mod = 1
	durability = 100

// Lenses

/obj/smithed_item/lense
	name = "Debug lense"
	icon_state = "lense"
	desc = "Debug lense. If you see this, notify the development team."
	/// Laser speed multiplier
	var/laser_speed_mult = 1.0
	/// Power draw multiplier
	var/power_mult = 1.0
	/// Damage multiplier
	var/damage_mult = 1.0
	/// Fire rate multiplier
	var/fire_rate_mult = 1.0
	/// Lense durability
	var/durability = 40
	/// The weapon the lense is attached to
	var/obj/item/gun/energy/attached_gun

/obj/smithed_item/lense/proc/break_lense()
	qdel(src)

/obj/smithed_item/lense/accelerator
	name = "accelerator lense"
	desc = "A lense that accelerates energy beams to a higher velocity, using some of its own energy to propel it."
	laser_speed_mult = 1.1
	damage_mult = 0.9

/obj/smithed_item/lense/speed
	name = "speed lense"
	desc = "A lense that cools the capacitors more efficiently, allowing for greater fire rate."
	fire_rate_mult = 1.15
	damage_mult = 0.9
	durability = 30

/obj/smithed_item/lense/amplifier
	name = "amplifier lense"
	desc = "A lense that increases the frequency of emitted beams, increasing their potency."
	power_mult = 1.1
	damage_mult = 1.1

/obj/smithed_item/lense/efficiency
	name = "efficiency lense"
	desc = "A lense that optimizes the number of shots an energy weapon can take before running dry."
	power_mult = 0.8
	damage_mult = 0.9
	durability = 80

/obj/smithed_item/lense/rapid
	name = "rapid lense"
	desc = "An advanced lense that bypasses the heat capacitor entirely, allowing for unprecedented fire rates of low-power emissions."
	fire_rate_mult = 1.5
	laser_speed_mult = 0.9
	damage_mult = 0.8
	durability = 60

/obj/smithed_item/lense/densifier
	name = "densifier lense"
	desc = "An advanced lense that keeps energy emissions in the barrel as long as possible, maximising impact at the cost of everything else."
	fire_rate_mult = 0.7
	laser_speed_mult = 0.7
	damage_mult = 1.4
	durability = 30

/obj/smithed_item/lense/velocity
	name = "velocity lense"
	desc = "An advanced lense that forces energy emissions from the barrel as fast as possible, accelerating them to ludicrous speed."
	laser_speed_mult = 1.5
	damage_mult = 0.8
	durability = 30

/obj/smithed_item/lense/admin
	name = "adminium lense"
	desc = "A hyper-advanced lense restricted to high-ranking central command officials."
	laser_speed_mult = 3
	damage_mult = 3
	fire_rate_mult = 3
	power_mult = 0.5
	durability = 300

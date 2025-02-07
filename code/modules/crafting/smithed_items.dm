/obj/item/smithing_cast
	name = "smithing cast"
	icon = 'icons/obj/smithing.dmi'
	icon_state = "debug"
	desc = "Debug smithing cast. If you see this, notify the development team."
	/// The selected final product of the item
	var/obj/item/selected_product
	/// Possible products of the item
	var/possible_products = list()

/obj/item/smithing_cast/Initialize(mapload)
	. = ..()
	populate_products()

/obj/item/smithing_cast/activate_self(mob/user)
	. = ..()
	if(!possible_products)
		return
	selected_product = tgui_input_list(user, "Select a product", src, possible_products)

/obj/item/smithing_cast/update_desc()
	return ..()

/obj/item/smithing_cast/proc/populate_products()
	return

/obj/item/smithing_cast/sheet
	name = "sheet cast"
	icon_state = "trim_cast"
	desc = "A cast for forging molten minerals into workable sheets."
	/// How many sheets are we smelting at any given operation?
	var/sheet_number = 1

/obj/item/smithing_cast/sheet/update_desc()
	desc = "[initial(desc)] It is currently configured to make [sheet_number] [selected_product][sheet_number == 1 ? "" : "s"]."
	return ..()

/obj/item/smithing_cast/sheet/populate_products()
	possible_products = list(/obj/item/stack/sheet/metal,
							/obj/item/stack/sheet/glass,
							/obj/item/stack/sheet/mineral/silver,
							/obj/item/stack/sheet/mineral/gold,
							/obj/item/stack/sheet/mineral/plasma,
							/obj/item/stack/sheet/plasmaglass,
							/obj/item/stack/sheet/plasteel,
							/obj/item/stack/sheet/mineral/plastitanium,
							/obj/item/stack/sheet/plastitaniumglass,
							/obj/item/stack/sheet/mineral/bananium,
							/obj/item/stack/sheet/mineral/tranquillite,
							/obj/item/stack/sheet/mineral/platinum,
							/obj/item/stack/sheet/mineral/palladium,
							/obj/item/stack/sheet/mineral/iridium,
							/obj/item/stack/tile/brass
							)

/obj/item/smithing_cast/sheet/AltClick(mob/user)
	. = ..()
	sheet_number = tgui_input_number(user, "Select an amount (1-50)", src, 1, 50, 1)

/obj/item/smithing_cast/component
	name = "component cast"
	desc = "Debug component cast. If you see this, notify the development team."
	/// The selected quality of the item
	var/datum/smith_quality/quality = /datum/smith_quality/standard
	/// The type of product
	var/product_type

/obj/item/smithing_cast/component/AltClick(mob/user)
	. = ..()
	quality = tgui_input_list(user, "Select a quality", src, (typesof(/datum/smith_quality) - list(/datum/smith_quality)))

/obj/item/smithing_cast/component/update_desc()
	desc = "[initial(desc)] It is currently configured to make [selected_product] at [quality]."
	return ..()

/obj/item/smithing_cast/component/populate_products()
	possible_products = (typesof(product_type) - list(product_type))

/obj/item/smithing_cast/component/insert_frame
	name = "insert frame cast"
	icon_state = "insert_frame_cast"
	desc = "A cast for creating insert frames."
	product_type = /obj/item/smithed_item/component/insert_frame

/obj/item/smithing_cast/component/insert_lining
	name = "insert lining cast"
	icon_state = "insert_lining_cast"
	desc = "A cast for creating insert linings."
	product_type = /obj/item/smithed_item/component/insert_lining

/obj/item/smithing_cast/component/bit_mount
	name = "bit mount cast"
	icon_state = "bit_mount_cast"
	desc = "A cast for creating bit mounts."
	product_type = /obj/item/smithed_item/component/bit_mount

/obj/item/smithing_cast/component/bit_head
	name = "bit head cast"
	icon_state = "bit_head_cast"
	desc = "A cast for creating bit heads."
	product_type = /obj/item/smithed_item/component/bit_head

/obj/item/smithing_cast/component/lense_frame
	name = "lense frame cast"
	icon_state = "lense_frame_cast"
	desc = "A cast for creating lense frames."
	product_type = /obj/item/smithed_item/component/lense_frame

/obj/item/smithing_cast/component/lense_focus
	name = "lense focus cast"
	icon_state = "lense_focus_cast"
	desc = "A cast for creating lense foci."
	product_type = /obj/item/smithed_item/component/lense_focus

/obj/item/smithing_cast/component/trim
	name = "trim cast"
	icon_state = "trim_cast"
	desc = "A cast for creating trims."
	product_type = /obj/item/smithed_item/component/trim

/obj/item/smithed_item
	name = "Debug smithed item"
	icon = 'icons/obj/smithing.dmi'
	icon_state = "debug"
	desc = "Debug smithed item. If you see this, notify the development team."
	/// The quality of the item
	var/datum/smith_quality/quality
	/// The material of the item
	var/datum/smith_material/material

/obj/item/smithed_item/Initialize(mapload)
	. = ..()
	if(!quality)
		return
	if(!material)
		name = "[quality.name] " + name
		return
	name = "[quality.name] [material.name] " + name

// Insets

/obj/item/smithed_item/insert
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

/obj/item/smithed_item/insert/Initialize(mapload)
	. = ..()
	brute_armor = initial(brute_armor) * quality.stat_mult
	burn_armor = initial(burn_armor) * quality.stat_mult
	laser_armor = initial(laser_armor) * quality.stat_mult
	movement_speed_mod = initial(movement_speed_mod) * quality.stat_mult
	heat_insulation = initial(heat_insulation) * quality.stat_mult
	siemens_coeff = initial(siemens_coeff) * quality.stat_mult
	radiation_armor = initial(radiation_armor) * quality.stat_mult

/obj/item/smithed_item/insert/ballistic
	name = "ballistic plate"
	desc = "A reinforced plate designed to stop small-caliber bullets and kinetic impacts."
	brute_armor = 10
	heat_insulation = 10

/obj/item/smithed_item/insert/thermal
	name = "thermal plate"
	desc = "A fragile plate designed to reduce heat exposure."
	brute_armor = -10
	burn_armor = 10
	heat_insulation = 10

/obj/item/smithed_item/insert/fireproofing
	name = "fireproofing plate"
	desc = "A heavy plate of asbestos designed to fireproof a user. A firefighter's godsend."
	burn_armor = 10
	movement_speed_mod = -0.5
	heat_insulation = 20

/obj/item/smithed_item/insert/reflective
	name = "reflective plate"
	desc = "A shiny plate that assists in laser deflection."
	burn_armor = -10
	laser_armor = 10
	siemens_coeff = -0.2

/obj/item/smithed_item/insert/rad_hazard
	name = "radiation hazard plate"
	desc = "A dense plate that can reduce a wearer's radiation exposure."
	heat_insulation = -10
	radiation_armor = 20

/obj/item/smithed_item/insert/rubberized
	name = "rubberized plate"
	desc = "A flexible plate that is resistant to electrical shocks."
	brute_armor = -10
	siemens_coeff = 0.2

/obj/item/smithed_item/insert/advanced
	name = "advanced armor mesh"
	desc = "An alloy mesh that can protect the wearer from most sources of damage."
	brute_armor = 10
	burn_armor = 10
	laser_armor = 10
	radiation_armor = 10
	movement_speed_mod = -0.5

/obj/item/smithed_item/insert/engineering
	name = "engineering mesh"
	desc = "An alloy mesh designed to assist in most work around electrical engines."
	brute_armor = -10
	burn_armor = 10
	radiation_armor = 10
	heat_insulation = 10
	siemens_coeff = 0.4
	movement_speed_mod = -0.5

/obj/item/smithed_item/insert/heavy
	name = "heavy duty plate"
	desc = "An advanced plate often used in SWAT gear. Heavy, yet durable."
	brute_armor = 20
	burn_armor = 10
	laser_armor = 10
	heat_insulation = 10
	siemens_coeff = -0.4
	movement_speed_mod = -1

/obj/item/smithed_item/insert/mobility
	name = "mobility mesh"
	desc = "An advanced alloy mesh that is both lightweight and invigorating to the wearer."
	brute_armor = -10
	burn_armor = -10
	laser_armor = -10
	heat_insulation = 10
	movement_speed_mod = 1

/obj/item/smithed_item/insert/admin
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

/obj/item/smithed_item/tool_bit
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

/obj/item/smithed_item/tool_bit/Initialize(mapload)
	. = ..()
	durability = initial(durability) * material.durability_mult
	size_mod = initial(size_mod) + material.size_mod
	speed_mod = initial(speed_mod) * quality.stat_mult
	precision_mod = initial(precision_mod) * quality.stat_mult

/obj/item/smithed_item/tool_bit/proc/break_bit()
	qdel(src)

/obj/item/smithed_item/tool_bit/speed
	name = "speed bit"
	desc = "A tool bit optimized for speed, at the cost of precision."
	speed_mod = -0.2
	precision_mod = -0.2

/obj/item/smithed_item/tool_bit/precision
	name = "precision bit"
	desc = "A tool bit optimized for precision, at the cost of speed."
	speed_mod = 0.2
	precision_mod = 0.2

/obj/item/smithed_item/tool_bit/heavy
	name = "heavy duty bit"
	desc = "A large, advanced tool bit that maximises speed."
	speed_mod = -0.4
	precision_mod = -0.4
	size_mod = 1
	durability = 40

/obj/item/smithed_item/tool_bit/surgical
	name = "surgical bit"
	desc = "An advanced tool bit that maximises precision."
	speed_mod = 0.4
	precision_mod = 0.6
	durability = 15

/obj/item/smithed_item/tool_bit/admin
	name = "adminium bit"
	desc = "A hyper-advanced bit restricted to central command officials."
	speed_mod = -1
	precision_mod = 1
	durability = 100

// Lenses

/obj/item/smithed_item/lense
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

/obj/item/smithed_item/lense/Initialize(mapload)
	. = ..()
	durability = initial(durability) * material.durability_mult
	power_mult = ((initial(power_mult) - 1) * quality.stat_mult) + 1
	damage_mult = ((initial(damage_mult) - 1) * quality.stat_mult) + 1
	laser_speed_mult = ((initial(laser_speed_mult) - 1) * quality.stat_mult) + 1
	fire_rate_mult = ((initial(fire_rate_mult) - 1) * quality.stat_mult) + 1

/obj/item/smithed_item/lense/proc/break_lense()
	qdel(src)

/obj/item/smithed_item/lense/accelerator
	name = "accelerator lense"
	desc = "A lense that accelerates energy beams to a higher velocity, using some of its own energy to propel it."
	laser_speed_mult = 1.1
	damage_mult = 0.9

/obj/item/smithed_item/lense/speed
	name = "speed lense"
	desc = "A lense that cools the capacitors more efficiently, allowing for greater fire rate."
	fire_rate_mult = 1.15
	damage_mult = 0.9
	durability = 30

/obj/item/smithed_item/lense/amplifier
	name = "amplifier lense"
	desc = "A lense that increases the frequency of emitted beams, increasing their potency."
	power_mult = 1.1
	damage_mult = 1.1

/obj/item/smithed_item/lense/efficiency
	name = "efficiency lense"
	desc = "A lense that optimizes the number of shots an energy weapon can take before running dry."
	power_mult = 0.8
	damage_mult = 0.9
	durability = 80

/obj/item/smithed_item/lense/rapid
	name = "rapid lense"
	desc = "An advanced lense that bypasses the heat capacitor entirely, allowing for unprecedented fire rates of low-power emissions."
	fire_rate_mult = 1.5
	laser_speed_mult = 0.9
	damage_mult = 0.8
	durability = 60

/obj/item/smithed_item/lense/densifier
	name = "densifier lense"
	desc = "An advanced lense that keeps energy emissions in the barrel as long as possible, maximising impact at the cost of everything else."
	fire_rate_mult = 0.7
	laser_speed_mult = 0.7
	damage_mult = 1.4
	durability = 30

/obj/item/smithed_item/lense/velocity
	name = "velocity lense"
	desc = "An advanced lense that forces energy emissions from the barrel as fast as possible, accelerating them to ludicrous speed."
	laser_speed_mult = 1.5
	damage_mult = 0.8
	durability = 30

/obj/item/smithed_item/lense/admin
	name = "adminium lense"
	desc = "A hyper-advanced lense restricted to high-ranking central command officials."
	laser_speed_mult = 3
	damage_mult = 3
	fire_rate_mult = 3
	power_mult = 0.5
	durability = 300

// Components

#define PART_PRIMARY 1
#define PART_SECONDARY 2
#define PART_TRIM 3

/obj/item/smithed_item/component
	name = "Debug smithed component"
	icon = 'icons/obj/smithing.dmi'
	icon_state = "debug"
	desc = "Debug smithed component part. If you see this, notify the development team."
	/// What type of part is it
	var/part_type
	/// What materials are required to make it
	var/material_cost = list()
	/// What is this a part of
	var/finished_product
	/// Is this component currently hot
	var/hot = TRUE
	/// How many times the component needs to be shaped to be considered ready
	var/hammer_time = 3

/obj/item/smithed_item/component/Initialize(mapload)
	. = ..()
	if(!quality)
		return
	hammer_time = ROUND_UP(initial(hammer_time) * quality.work_mult)
	for(var/material in material_cost)
		material = ROUND_UP(material * quality.material_mult)

/obj/item/smithed_item/component/proc/powerhammer()
	hammer_time--
	if(prob(50) || hammer_time <= 0)
		hot = FALSE

/obj/item/smithed_item/component/proc/heat_up()
	hot = TRUE

/obj/item/smithed_item/component/insert_frame
	name = "Debug insert frame"
	icon_state = "insert_frame"
	desc = "Debug smithed component part of an insert. If you see this, notify the development team."
	part_type = PART_PRIMARY

/obj/item/smithed_item/component/insert_frame/ballistic
	name = "ballistic insert frame"
	desc = "This is the primary component of a ballistic plate."
	material_cost = list(MAT_METAL = 10000)
	finished_product = /obj/item/smithed_item/insert/ballistic

/obj/item/smithed_item/component/insert_frame/thermal
	name = "thermal insert frame"
	desc = "This is the primary component of a thermal plate."
	material_cost = list(MAT_GOLD = 6000)
	finished_product = /obj/item/smithed_item/insert/thermal

/obj/item/smithed_item/component/insert_frame/fireproofing
	name = "fireproofing insert frame"
	desc = "This is the primary component of a fireproofing plate."
	material_cost = list(MAT_SILVER = 10000)
	finished_product = /obj/item/smithed_item/insert/fireproofing

/obj/item/smithed_item/component/insert_frame/reflective
	name = "reflective insert frame"
	desc = "This is the primary component of a reflective plate."
	material_cost = list(MAT_SILVER = 10000)
	finished_product = /obj/item/smithed_item/insert/reflective

/obj/item/smithed_item/component/insert_frame/rad_hazard
	name = "radiation hazard insert frame"
	desc = "This is the primary component of a radiation hazard plate."
	material_cost = list(MAT_GOLD = 6000)
	finished_product = /obj/item/smithed_item/insert/rad_hazard

/obj/item/smithed_item/component/insert_frame/rubberized
	name = "rubberized insert frame"
	desc = "This is the primary component of a rubberized plate."
	material_cost = list(MAT_PLASMA = 10000)
	finished_product = /obj/item/smithed_item/insert/rubberized

/obj/item/smithed_item/component/insert_frame/advanced
	name = "advanced insert frame"
	desc = "This is the primary component of a advanced armor mesh."
	material_cost = list(MAT_METAL = 10000, MAT_PLASMA = 10000)
	finished_product = /obj/item/smithed_item/insert/advanced

/obj/item/smithed_item/component/insert_frame/engineering
	name = "engineering insert frame"
	desc = "This is the primary component of a advanced engineering mesh."
	material_cost = list(MAT_GOLD = 10000, MAT_SILVER = 10000)
	finished_product = /obj/item/smithed_item/insert/engineering

/obj/item/smithed_item/component/insert_frame/heavy
	name = "heavy duty insert frame"
	desc = "This is the primary component of a advanced heavy duty plate."
	material_cost = list(MAT_TITANIUM = 20000, MAT_PLASMA = 20000)
	finished_product = /obj/item/smithed_item/insert/heavy

/obj/item/smithed_item/component/insert_frame/mobility
	name = "mobility mesh insert frame"
	desc = "This is the primary component of a advanced mobility mesh."
	material_cost = list(MAT_BLUESPACE = 4000)
	finished_product = /obj/item/smithed_item/insert/mobility

/obj/item/smithed_item/component/insert_lining
	name = "Debug insert lining"
	icon_state = "insert_lining"
	desc = "Debug smithed component part of an insert. If you see this, notify the development team."
	part_type = PART_SECONDARY

/obj/item/smithed_item/component/insert_lining/ballistic
	name = "ballistic insert lining"
	desc = "This is the secondary component of a ballistic plate."
	material_cost = list(MAT_METAL = 10000)
	finished_product = /obj/item/smithed_item/insert/ballistic

/obj/item/smithed_item/component/insert_lining/thermal
	name = "thermal insert lining"
	desc = "This is the secondary component of a thermal plate."
	material_cost = list(MAT_METAL = 10000)
	finished_product = /obj/item/smithed_item/insert/thermal

/obj/item/smithed_item/component/insert_lining/fireproofing
	name = "fireproofing insert lining"
	desc = "This is the secondary component of a fireproofing plate."
	material_cost = list(MAT_METAL = 10000, MAT_PLASMA = 10000)
	finished_product = /obj/item/smithed_item/insert/fireproofing

/obj/item/smithed_item/component/insert_lining/reflective
	name = "reflective insert lining"
	desc = "This is the secondary component of a reflective plate."
	material_cost = list(MAT_GOLD = 6000)
	finished_product = /obj/item/smithed_item/insert/reflective

/obj/item/smithed_item/component/insert_lining/rad_hazard
	name = "radiation hazard insert lining"
	desc = "This is the secondary component of a radiation hazard plate."
	material_cost = list(MAT_TITANIUM = 10000)
	finished_product = /obj/item/smithed_item/insert/rad_hazard

/obj/item/smithed_item/component/insert_lining/rubberized
	name = "rubberized insert lining"
	desc = "This is the secondary component of a rubberized plate."
	material_cost = list(MAT_PLASMA = 10000)
	finished_product = /obj/item/smithed_item/insert/rubberized

/obj/item/smithed_item/component/insert_lining/advanced
	name = "advanced insert lining"
	desc = "This is the secondary component of a advanced armor mesh."
	material_cost = list(MAT_TITANIUM = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/insert/advanced

/obj/item/smithed_item/component/insert_lining/engineering
	name = "engineering insert lining"
	desc = "This is the secondary component of a advanced engineering mesh."
	material_cost = list(MAT_TITANIUM = 10000, MAT_IRIDIUM = 2000)
	finished_product = /obj/item/smithed_item/insert/engineering

/obj/item/smithed_item/component/insert_lining/heavy
	name = "heavy duty insert lining"
	desc = "This is the secondary component of a advanced heavy duty plate."
	material_cost = list(MAT_TITANIUM = 10000, MAT_PLATINUM = 2000)
	finished_product = /obj/item/smithed_item/insert/heavy

/obj/item/smithed_item/component/insert_lining/mobility
	name = "mobility mesh insert lining"
	desc = "This is the secondary component of a advanced mobility mesh."
	material_cost = list(MAT_PALLADIUM = 2000)
	finished_product = /obj/item/smithed_item/insert/mobility

/obj/item/smithed_item/component/bit_mount
	name = "Debug bit mount"
	icon_state = "bit_mount"
	desc = "Debug smithed component part of a tool bit. If you see this, notify the development team."
	part_type = PART_PRIMARY

/obj/item/smithed_item/component/bit_mount/speed
	name = "speed bit mount"
	desc = "This is the primary component of a speed bit"
	material_cost = list(MAT_TITANIUM = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/speed

/obj/item/smithed_item/component/bit_mount/precision
	name = "precision bit mount"
	desc = "This is the primary component of a precision bit"
	material_cost = list(MAT_SILVER = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/precision

/obj/item/smithed_item/component/bit_mount/heavy
	name = "heavy duty bit mount"
	desc = "This is the primary component of a heavy duty bit"
	material_cost = list(MAT_TITANIUM = 8000, MAT_PLASMA = 8000)
	finished_product = /obj/item/smithed_item/tool_bit/heavy

/obj/item/smithed_item/component/bit_mount/surgical
	name = "surgical bit mount"
	desc = "This is the primary component of a surgical bit"
	material_cost = list(MAT_TITANIUM = 4000, MAT_PLASMA = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/surgical

/obj/item/smithed_item/component/bit_head
	name = "Debug bit head"
	icon_state = "bit_head"
	desc = "Debug smithed component part of a tool bit. If you see this, notify the development team."
	part_type = PART_SECONDARY

/obj/item/smithed_item/component/bit_head/speed
	name = "speed bit head"
	desc = "This is the secondary component of a speed bit"
	material_cost = list(MAT_METAL = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/speed

/obj/item/smithed_item/component/bit_head/precision
	name = "precision bit head"
	desc = "This is the secondary component of a precision bit"
	material_cost = list(MAT_METAL = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/precision

/obj/item/smithed_item/component/bit_head/heavy
	name = "heavy duty bit head"
	desc = "This is the secondary component of a heavy duty bit"
	material_cost = list(MAT_METAL = 8000, MAT_PLASMA = 8000)
	finished_product = /obj/item/smithed_item/tool_bit/heavy

/obj/item/smithed_item/component/bit_head/surgical
	name = "surgical bit head"
	desc = "This is the secondary component of a surgical bit"
	material_cost = list(MAT_METAL = 4000, MAT_PLASMA = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/surgical

/obj/item/smithed_item/component/lense_frame
	name = "Debug lense frame"
	icon_state = "lense_frame"
	desc = "Debug smithed component part of a laser lense. If you see this, notify the development team."
	part_type = PART_PRIMARY

/obj/item/smithed_item/component/lense_frame/accelerator
	name = "accelerator lense frame"
	desc = "This is the primary component of an accelerator lense."
	material_cost = list(MAT_TITANIUM = 4000)
	finished_product = /obj/item/smithed_item/lense/accelerator

/obj/item/smithed_item/component/lense_frame/speed
	name = "speed lense frame"
	desc = "This is the primary component of a speed lense."
	material_cost = list(MAT_METAL = 4000)
	finished_product = /obj/item/smithed_item/lense/speed

/obj/item/smithed_item/component/lense_frame/amplifier
	name = "amplifier lense frame"
	desc = "This is the primary component of an amplifier lense."
	material_cost = list(MAT_GOLD = 4000)
	finished_product = /obj/item/smithed_item/lense/amplifier

/obj/item/smithed_item/component/lense_frame/efficiency
	name = "efficiency lense frame"
	desc = "This is the primary component of an efficiency lense."
	material_cost = list(MAT_SILVER = 4000)
	finished_product = /obj/item/smithed_item/lense/efficiency

/obj/item/smithed_item/component/lense_frame/rapid
	name = "rapid lense frame"
	desc = "This is the primary component of an advanced rapid lense."
	material_cost = list(MAT_PALLADIUM = 2000)
	finished_product = /obj/item/smithed_item/lense/rapid

/obj/item/smithed_item/component/lense_frame/densifier
	name = "densifier lense frame"
	desc = "This is the primary component of an advanced densifier lense."
	material_cost = list(MAT_PLATINUM = 2000)
	finished_product = /obj/item/smithed_item/lense/densifier

/obj/item/smithed_item/component/lense_frame/velocity
	name = "velocity lense frame"
	desc = "This is the primary component of an advanced velocity lense."
	material_cost = list(MAT_BRASS = 30000)
	finished_product = /obj/item/smithed_item/lense/velocity

/obj/item/smithed_item/component/lense_focus
	name = "Debug lense focus"
	icon_state = "lense_focus"
	desc = "Debug smithed component part of a laser lense. If you see this, notify the development team."
	part_type = PART_SECONDARY

/obj/item/smithed_item/component/lense_focus/accelerator
	name = "accelerator lense focus"
	desc = "This is the secondary component of an accelerator lense."
	material_cost = list(MAT_METAL = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lense/accelerator

/obj/item/smithed_item/component/lense_focus/speed
	name = "speed lense focus"
	desc = "This is the secondary component of a speed lense."
	material_cost = list(MAT_PLASMA = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lense/speed

/obj/item/smithed_item/component/lense_focus/amplifier
	name = "amplifier lense focus"
	desc = "This is the secondary component of an amplifier lense."
	material_cost = list(MAT_TITANIUM = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lense/amplifier

/obj/item/smithed_item/component/lense_focus/efficiency
	name = "efficiency lense focus"
	desc = "This is the secondary component of an efficiency lense."
	material_cost = list(MAT_METAL = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lense/efficiency

/obj/item/smithed_item/component/lense_focus/rapid
	name = "rapid lense focus"
	desc = "This is the secondary component of an advanced rapid lense."
	material_cost = list(MAT_PLASMA = 10000, MAT_GLASS = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/lense/rapid

/obj/item/smithed_item/component/lense_focus/densifier
	name = "densifier lense focus"
	desc = "This is the secondary component of an advanced densifier lense."
	material_cost = list(MAT_PLASMA = 10000, MAT_GLASS = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/lense/densifier

/obj/item/smithed_item/component/lense_focus/velocity
	name = "velocity lense focus"
	desc = "This is the secondary component of an advanced velocity lense."
	material_cost = list(MAT_PLASMA = 10000, MAT_GLASS = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/lense/velocity

/obj/item/smithed_item/component/trim
	name = "Debug trim"
	icon_state = "trim"
	desc = "Debug smithed component part of any smithed item. If you see this, notify the development team."
	part_type = PART_TRIM

/obj/item/smithed_item/component/trim/metal
	name = "metal trim"
	desc = "Smithed component of any smithing item. Made of metal."
	material_cost = list(MAT_METAL = 10000)
	material = /datum/smith_material/metal

/obj/item/smithed_item/component/trim/silver
	name = "silver trim"
	desc = "Smithed component of any smithing item. Made of silver."
	material_cost = list(MAT_SILVER = 10000)
	material = /datum/smith_material/silver

/obj/item/smithed_item/component/trim/gold
	name = "gold trim"
	desc = "Smithed component of any smithing item. Made of gold."
	material_cost = list(MAT_GOLD = 10000)
	material = /datum/smith_material/gold

/obj/item/smithed_item/component/trim/plasma
	name = "plasma trim"
	desc = "Smithed component of any smithing item. Made of solid plasma."
	material_cost = list(MAT_PLASMA = 10000)
	material = /datum/smith_material/plasma

/obj/item/smithed_item/component/trim/titanium
	name = "titanium trim"
	desc = "Smithed component of any smithing item. Made of titanium."
	material_cost = list(MAT_TITANIUM = 10000)
	material = /datum/smith_material/titanium

/obj/item/smithed_item/component/trim/uranium
	name = "uranium trim"
	desc = "Smithed component of any smithing item. Made of uranium."
	material_cost = list(MAT_URANIUM = 10000)
	material = /datum/smith_material/uranium

/obj/item/smithed_item/component/trim/diamond
	name = "diamond trim"
	desc = "Smithed component of any smithing item. Made of diamond."
	material_cost = list(MAT_DIAMOND = 10000)
	material = /datum/smith_material/diamond

/obj/item/smithed_item/component/trim/bluespace
	name = "bluespace trim"
	desc = "Smithed component of any smithing item. Made of bluespace crystals."
	material_cost = list(MAT_BLUESPACE = 10000)
	material = /datum/smith_material/bluespace

/obj/item/smithed_item/component/trim/plasteel
	name = "plasteel trim"
	desc = "Smithed component of any smithing item. Made of plasteel."
	material_cost = list(MAT_METAL = 10000, MAT_PLASMA = 10000)
	material = /datum/smith_material/plasteel

/obj/item/smithed_item/component/trim/plastitanium
	name = "plastitanium trim"
	desc = "Smithed component of any smithing item. Made of plastitanium."
	material_cost = list(MAT_TITANIUM = 10000, MAT_PLASMA = 10000)
	material = /datum/smith_material/plastitanium

/obj/item/smithed_item/component/trim/iridium
	name = "iridium trim"
	desc = "Smithed component of any smithing item. Made of iridium."
	material_cost = list(MAT_IRIDIUM = 10000)
	material = /datum/smith_material/iridium

/obj/item/smithed_item/component/trim/palladium
	name = "palladium trim"
	desc = "Smithed component of any smithing item. Made of palladium."
	material_cost = list(MAT_PALLADIUM = 10000)
	material = /datum/smith_material/palladium

/obj/item/smithed_item/component/trim/platinum
	name = "platinum trim"
	desc = "Smithed component of any smithing item. Made of platinum."
	material_cost = list(MAT_PLATINUM = 10000)
	material = /datum/smith_material/platinum

/obj/item/smithed_item/component/trim/brass
	name = "brass trim"
	desc = "Smithed component of any smithing item. Made of brass."
	material_cost = list(MAT_BRASS = 10000)
	material = /datum/smith_material/brass

#undef PART_PRIMARY
#undef PART_SECONDARY
#undef PART_TRIM

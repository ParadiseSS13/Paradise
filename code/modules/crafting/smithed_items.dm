// MARK: Casts

/obj/item/smithing_cast
	name = "smithing cast"
	icon = 'icons/obj/smithing.dmi'
	icon_state = "debug"
	desc = "Debug smithing cast. If you see this, notify the development team."
	w_class = WEIGHT_CLASS_SMALL
	/// The selected final product of the item
	var/obj/item/selected_product
	/// Possible products of the item
	var/list/possible_products = list()
	/// How many products are we smelting at any given operation?
	var/amount_to_make = 1

	new_attack_chain = TRUE

/obj/item/smithing_cast/Initialize(mapload)
	. = ..()
	populate_products()

/obj/item/smithing_cast/examine(mob/user)
	. = ..()
	. += "It is currently configured to make [amount_to_make == 1 ? "a" : "[amount_to_make]"] [selected_product.name][amount_to_make == 1 ? "" : "s"]."
	. += "<span class='notice'>You can select the desired product by using [src] in your hand.</span>"

/obj/item/smithing_cast/activate_self(mob/user)
	. = ..()
	if(!possible_products)
		return
	var/list/product_names = list()
	var/product
	for(product in possible_products)
		var/obj/item/possible_product = product
		product_names[possible_product.name] = possible_product
	var/new_product = tgui_input_list(user, "Select a product", src, product_names)
	if(!new_product)
		selected_product = possible_products[1]
	else
		selected_product = product_names[new_product]

/obj/item/smithing_cast/update_desc()
	return ..()

/obj/item/smithing_cast/proc/populate_products()
	return

// MARK: Sheet Cast

/obj/item/smithing_cast/sheet
	name = "sheet cast"
	icon_state = "sheet_cast"
	desc = "A cast for forging molten minerals into workable sheets."

/obj/item/smithing_cast/sheet/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can change the amount of sheets smelted by alt-clicking [src].</span>"

/obj/item/smithing_cast/sheet/populate_products()
	possible_products = list(/obj/item/stack/sheet/metal,
							/obj/item/stack/sheet/glass,
							/obj/item/stack/sheet/mineral/silver,
							/obj/item/stack/sheet/mineral/gold,
							/obj/item/stack/sheet/mineral/plasma,
							/obj/item/stack/sheet/mineral/uranium,
							/obj/item/stack/sheet/mineral/diamond,
							/obj/item/stack/ore/bluespace_crystal/refined,
							/obj/item/stack/sheet/mineral/titanium,
							/obj/item/stack/sheet/plasmaglass,
							/obj/item/stack/sheet/titaniumglass,
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
	if(length(possible_products))
		selected_product = possible_products[1]

/obj/item/smithing_cast/sheet/AltClick(mob/user)
	. = ..()
	if(!Adjacent(user))
		return
	amount_to_make = tgui_input_number(user, "Select an amount (1-50)", src, 1, 50, 1)

// MARK: Component Cast

/obj/item/smithing_cast/component
	name = "component cast"
	desc = "Debug component cast. If you see this, notify the development team."
	/// The selected quality of the item
	var/datum/smith_quality/quality = /datum/smith_quality
	/// The type of product
	var/product_type

/obj/item/smithing_cast/component/examine(mob/user)
	. = ..()
	. += "The current selected quality is [quality.name]."
	. += "<span class='notice'>You can change the quality of the product by alt-clicking [src].</span>"

/obj/item/smithing_cast/component/AltClick(mob/user)
	. = ..()
	if(!Adjacent(user))
		return
	var/list/quality_name_list = list()
	var/list/quality_type_list = typesof(/datum/smith_quality)
	var/quality_type
	for(quality_type in quality_type_list)
		var/datum/smith_quality/new_quality = quality_type
		quality_name_list[new_quality.name] = new_quality
	var/selected_quality = tgui_input_list(user, "Select a quality", src, quality_name_list)
	if(!selected_quality)
		quality = quality_type_list[1]
	else
		quality = quality_name_list[selected_quality]

/obj/item/smithing_cast/component/populate_products()
	possible_products = (typesof(product_type) - list(product_type))
	if(length(possible_products))
		selected_product = possible_products[1]

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

/obj/item/smithing_cast/component/lens_frame
	name = "lens frame cast"
	icon_state = "lens_frame_cast"
	desc = "A cast for creating lens frames."
	product_type = /obj/item/smithed_item/component/lens_frame

/obj/item/smithing_cast/component/lens_focus
	name = "lens focus cast"
	icon_state = "lens_focus_cast"
	desc = "A cast for creating lens foci."
	product_type = /obj/item/smithed_item/component/lens_focus

/obj/item/smithing_cast/component/trim
	name = "trim cast"
	icon_state = "trim_cast"
	desc = "A cast for creating trims."
	product_type = /obj/item/smithed_item/component/trim

// MARK: Misc casts

/obj/item/smithing_cast/misc
	name = "misc cast"
	icon_state = "insert_frame_cast"
	desc = "Debug cast. If you see this, notify the development team."

/obj/item/smithing_cast/misc/gun_frame
	name = "energy gun frame cast"
	icon_state = "insert_frame_cast"
	desc = "A cast for creating energy gun frames."
	selected_product = /obj/item/smithed_item/component/egun_frame

// MARK: Smithed Items

/obj/item/smithed_item
	name = "Debug smithed item"
	icon = 'icons/obj/smithing.dmi'
	icon_state = "debug"
	desc = "Debug smithed item. If you see this, notify the development team."
	w_class = WEIGHT_CLASS_SMALL
	/// The quality of the item
	var/datum/smith_quality/quality
	/// The material of the item
	var/datum/smith_material/material

	new_attack_chain = TRUE

/obj/item/smithed_item/Initialize(mapload)
	. = ..()
	set_name()

/obj/item/smithed_item/update_name()
	. = ..()
	set_name()

/obj/item/smithed_item/proc/on_attached(mob/user, obj/item/target)
	return

/obj/item/smithed_item/proc/on_detached(mob/user)
	return

/obj/item/smithed_item/proc/set_stats()
	return

/obj/item/smithed_item/proc/set_name()
	if(!quality)
		return
	if(!material)
		name = "[quality.name] " + name
		return
	name = "[quality.name] [material.name] [initial(name)]"

// MARK: Inserts

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
	/// Explosive armor
	var/explosive_armor = 0
	/// Movement speed
	var/movement_speed_mod = 0
	/// Used in the mobility insert - does this negate slowdown
	var/no_more_slowdown = FALSE
	/// Heat insulation
	var/heat_insulation = 0
	/// Electrical insulation
	var/siemens_coeff = 0.0
	/// Radiation armor
	var/radiation_armor = 0
	/// The suit the insert is attached to
	var/obj/item/clothing/suit/attached_suit

/obj/item/smithed_item/insert/set_stats()
	brute_armor = initial(brute_armor) * quality.stat_mult * material.brute_armor_mult
	burn_armor = initial(burn_armor) * quality.stat_mult * material.burn_armor_mult
	laser_armor = initial(laser_armor) * quality.stat_mult * material.laser_armor_mult
	explosive_armor = initial(explosive_armor) * quality.stat_mult * material.explosive_armor_mult
	movement_speed_mod = initial(movement_speed_mod) * quality.stat_mult * material.movement_speed_mod
	heat_insulation = initial(heat_insulation) * quality.stat_mult * material.heat_insulation_mult
	siemens_coeff = initial(siemens_coeff) * quality.stat_mult * material.siemens_coeff_mult
	radiation_armor = initial(radiation_armor) * quality.stat_mult * material.radiation_armor_mult
	armor = new /datum/armor(brute_armor, brute_armor, laser_armor, laser_armor, explosive_armor, radiation_armor, burn_armor, 0, 0)

/obj/item/smithed_item/insert/on_attached(obj/item/clothing/suit/target)
	if(!istype(target))
		return
	attached_suit = target
	attached_suit.armor = attached_suit.armor.attachArmor(armor)
	attached_suit.slowdown -= movement_speed_mod
	attached_suit.siemens_coefficient -= siemens_coeff
	attached_suit.min_cold_protection_temperature -= heat_insulation
	attached_suit.max_heat_protection_temperature += heat_insulation
	if(no_more_slowdown)
		attached_suit.slowdown = 0

/obj/item/smithed_item/insert/on_detached(mob/user)
	attached_suit.armor = attached_suit.armor.detachArmor(armor)
	if(no_more_slowdown)
		attached_suit.slowdown = initial(attached_suit.slowdown)
	attached_suit.slowdown += movement_speed_mod
	attached_suit.siemens_coefficient += siemens_coeff
	attached_suit.min_cold_protection_temperature += heat_insulation
	attached_suit.max_heat_protection_temperature -= heat_insulation
	attached_suit.inserts -= src
	attached_suit = null

/obj/item/smithed_item/insert/ballistic
	name = "ballistic plate"
	desc = "A reinforced plate designed to stop small-caliber bullets and kinetic impacts."
	brute_armor = 10
	explosive_armor = 10
	heat_insulation = -10

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
	movement_speed_mod = -0.2
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
	explosive_armor = 10
	radiation_armor = 10
	movement_speed_mod = -0.2

/obj/item/smithed_item/insert/engineering
	name = "engineering mesh"
	desc = "An alloy mesh designed to assist in most work around electrical engines."
	brute_armor = -10
	burn_armor = 10
	radiation_armor = 10
	heat_insulation = 10
	explosive_armor = 10
	siemens_coeff = 0.4
	movement_speed_mod = -0.2

/obj/item/smithed_item/insert/heavy
	name = "heavy duty plate"
	desc = "An advanced plate often used in SWAT gear. Heavy, yet durable."
	brute_armor = 20
	burn_armor = 10
	laser_armor = 10
	explosive_armor = 10
	heat_insulation = 10
	siemens_coeff = -0.4
	movement_speed_mod = -0.4

/obj/item/smithed_item/insert/mobility
	name = "mobility mesh"
	desc = "An advanced alloy mesh that is both lightweight and invigorating to the wearer."
	brute_armor = -5
	burn_armor = -5
	laser_armor = -5
	heat_insulation = 10
	no_more_slowdown = TRUE

/obj/item/smithed_item/insert/admin
	name = "adminium mesh"
	desc = "A special mesh plate reserved exclusively for high-ranking central command personnel."
	brute_armor = 50
	burn_armor = 50
	laser_armor = 50
	radiation_armor = 50
	heat_insulation = 50
	movement_speed_mod = 1
	siemens_coeff = 1
	quality = /datum/smith_quality/masterwork
	material = /datum/smith_material/platinum

// MARK: Tool Bits

/obj/item/smithed_item/tool_bit
	name = "Debug tool bit"
	icon_state = "bit"
	desc = "Debug tool bit. If you see this, notify the development team."
	/// Base Speed modifier
	var/base_speed_mod = 0
	/// Base Efficiency modifier
	var/base_efficiency_mod = 0
	/// Speed modifier
	var/speed_mod = 1.0
	/// Efficiency modifier
	var/efficiency_mod = 1.0
	/// Failure rate
	var/failure_rate = 0
	/// Size modifier
	var/size_mod = 0
	/// Durability
	var/durability = 90
	/// Max durability
	var/max_durability = 90
	/// The tool the bit is attached to
	var/obj/item/attached_tool

/obj/item/smithed_item/tool_bit/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(istype(target, /obj/item))
		SEND_SIGNAL(target, COMSIG_BIT_ATTACH, src, user)
		return ITEM_INTERACT_COMPLETE

/obj/item/smithed_item/tool_bit/set_stats()
	durability = initial(durability) * material.durability_mult
	max_durability = durability
	size_mod = initial(size_mod) + material.size_mod
	speed_mod = 1 + (base_speed_mod * quality.stat_mult * material.tool_speed_mult)
	failure_rate = initial(failure_rate) * quality.stat_mult * material.tool_failure_mult
	efficiency_mod = 1 + (base_efficiency_mod * quality.stat_mult * material.power_draw_mult)

/obj/item/smithed_item/tool_bit/on_attached(obj/item/target)
	if(!istype(target))
		return
	attached_tool = target
	attached_tool.w_class += size_mod
	attached_tool.toolspeed = attached_tool.toolspeed * speed_mod
	attached_tool.bit_failure_rate += failure_rate
	attached_tool.bit_efficiency_mod = attached_tool.bit_efficiency_mod * efficiency_mod

/obj/item/smithed_item/tool_bit/on_detached()
	attached_tool.toolspeed = attached_tool.toolspeed / speed_mod
	attached_tool.w_class -= size_mod
	attached_tool.bit_failure_rate -= failure_rate
	attached_tool.bit_efficiency_mod = attached_tool.bit_efficiency_mod / efficiency_mod
	attached_tool.attached_bits -= src
	attached_tool = null

/obj/item/smithed_item/tool_bit/examine(mob/user)
	. = ..()
	var/healthpercent = (durability/max_durability) * 100
	switch(healthpercent)
		if(80 to 100)
			. +=  "It looks pristine."
		if(60 to 79)
			. +=  "It looks slightly used."
		if(40 to 59)
			. +=  "It's seen better days."
		if(20 to 39)
			. +=  "It's been heavily used."
		if(0 to 19)
			. +=  "<span class='warning'>It's falling apart!</span>"

/obj/item/smithed_item/tool_bit/proc/damage_bit()
	durability--
	if(istype(attached_tool, /obj/item/rcd))
		durability--
	if(durability == 0)
		break_bit()

/obj/item/smithed_item/tool_bit/proc/break_bit()
	on_detached()
	qdel(src)

/obj/item/smithed_item/tool_bit/speed
	name = "speed bit"
	desc = "A tool bit optimized for speed, at the cost of efficiency."
	base_speed_mod = -0.2
	failure_rate = 5
	base_efficiency_mod = 0.1

/obj/item/smithed_item/tool_bit/efficiency
	name = "efficient bit"
	desc = "A tool bit optimized for efficiency, at the cost of speed."
	base_speed_mod = 0.2
	base_efficiency_mod = -0.25

/obj/item/smithed_item/tool_bit/balanced
	name = "balanced bit"
	desc = "A tool bit that's fairly balanced in all aspects."
	base_speed_mod = -0.1
	failure_rate = 2
	base_efficiency_mod = -0.1

/obj/item/smithed_item/tool_bit/heavy
	name = "heavy duty bit"
	desc = "A large, advanced tool bit that maximises speed."
	base_speed_mod = -0.4
	failure_rate = 10
	base_efficiency_mod = 0.25
	size_mod = 1
	durability = 120

/obj/item/smithed_item/tool_bit/economical
	name = "economical bit"
	desc = "An advanced tool bit that maximises efficiency."
	base_speed_mod = 0.4
	base_efficiency_mod = -0.45
	durability = 60

/obj/item/smithed_item/tool_bit/advanced
	name = "advanced bit"
	desc = "An advanced tool bit that's fairly balanced in all aspects."
	base_speed_mod = -0.25
	failure_rate = 2
	base_efficiency_mod = -0.3

/obj/item/smithed_item/tool_bit/admin
	name = "adminium bit"
	desc = "A hyper-advanced bit restricted to central command officials."
	speed_mod = -1
	efficiency_mod = 1
	durability = 300
	quality = /datum/smith_quality/masterwork
	material = /datum/smith_material/platinum

// MARK: Lenses

/obj/item/smithed_item/lens
	name = "Debug lens"
	icon_state = "lens"
	desc = "Debug lens. If you see this, notify the development team."
	/// Base laser speed multiplier
	var/base_laser_speed_mult = 0
	/// Base power draw multiplier
	var/base_power_mult = 0
	/// Base damage multiplier
	var/base_damage_mult = 0
	/// Base fire rate multiplier
	var/base_fire_rate_mult = 0
	/// Laser speed multiplier after construction
	var/laser_speed_mult = 1
	/// Power draw multiplier after construction
	var/power_mult = 1
	/// Damage multiplier after construction
	var/damage_mult = 1
	/// Fire rate multiplier after construction
	var/fire_rate_mult = 1
	/// lens durability
	var/durability = 40
	/// Max durability
	var/max_durability = 40
	/// The weapon the lens is attached to
	var/obj/item/gun/energy/attached_gun

/obj/item/smithed_item/lens/set_stats()
	durability = initial(durability) * material.durability_mult
	max_durability = durability
	power_mult = 1 + (base_power_mult * quality.stat_mult * material.power_draw_mult)
	damage_mult = 1 + (base_damage_mult * quality.stat_mult * material.projectile_damage_multiplier)
	laser_speed_mult = 1 + (base_laser_speed_mult * quality.stat_mult * material.projectile_speed_mult)
	fire_rate_mult = 1 + (base_fire_rate_mult * quality.stat_mult * material.fire_rate_multiplier)

/obj/item/smithed_item/lens/on_attached(obj/item/gun/energy/target)
	if(!istype(target))
		return
	attached_gun = target
	attached_gun.fire_delay = attached_gun.fire_delay / fire_rate_mult
	for(var/obj/item/ammo_casing/energy/casing in attached_gun.ammo_type)
		casing.e_cost = casing.e_cost * power_mult
		casing.lens_damage_multiplier = casing.lens_damage_multiplier * damage_mult
		casing.lens_speed_multiplier = casing.lens_speed_multiplier / laser_speed_mult

/obj/item/smithed_item/lens/on_detached()
	attached_gun.fire_delay = attached_gun.fire_delay * fire_rate_mult
	for(var/obj/item/ammo_casing/energy/casing in attached_gun.ammo_type)
		casing.e_cost = casing.e_cost / power_mult
		casing.lens_damage_multiplier = casing.lens_damage_multiplier / damage_mult
		casing.lens_speed_multiplier = casing.lens_speed_multiplier * laser_speed_mult
	attached_gun.current_lens = null
	attached_gun = null

/obj/item/smithed_item/lens/examine(mob/user)
	. = ..()
	var/healthpercent = (durability/max_durability) * 100
	switch(healthpercent)
		if(80 to 100)
			. +=  "It looks pristine."
		if(60 to 79)
			. +=  "It looks slightly used."
		if(40 to 59)
			. +=  "It's seen better days."
		if(20 to 39)
			. +=  "It's been heavily used."
		if(0 to 19)
			. +=  "<span class='warning'>It's falling apart!</span>"

/obj/item/smithed_item/lens/proc/damage_lens()
	durability--
	if(durability <= 0)
		break_lens()

/obj/item/smithed_item/lens/proc/break_lens()
	on_detached()
	qdel(src)

/obj/item/smithed_item/lens/accelerator
	name = "accelerator lens"
	desc = "A lens that accelerates energy beams to a higher velocity, using some of its own energy to propel it."
	base_laser_speed_mult = 0.1
	base_damage_mult = -0.1

/obj/item/smithed_item/lens/speed
	name = "speed lens"
	desc = "A lens that cools the capacitors more efficiently, allowing for greater fire rate."
	base_fire_rate_mult = 0.15
	base_damage_mult = -0.1
	durability = 30

/obj/item/smithed_item/lens/amplifier
	name = "amplifier lens"
	desc = "A lens that increases the frequency of emitted beams, increasing their potency."
	base_power_mult = 0.2
	base_damage_mult = 0.1

/obj/item/smithed_item/lens/efficiency
	name = "efficiency lens"
	desc = "A lens that optimizes the number of shots an energy weapon can take before running dry."
	base_power_mult = -0.2
	base_damage_mult = -0.1
	durability = 80

/obj/item/smithed_item/lens/rapid
	name = "rapid lens"
	desc = "An advanced lens that bypasses the heat capacitor entirely, allowing for unprecedented fire rates of low-power emissions."
	base_fire_rate_mult = 0.5
	base_laser_speed_mult = -0.1
	base_damage_mult = -0.2
	durability = 60

/obj/item/smithed_item/lens/densifier
	name = "densifier lens"
	desc = "An advanced lens that keeps energy emissions in the barrel as long as possible, maximising impact at the cost of everything else."
	base_fire_rate_mult = -0.4
	base_laser_speed_mult = -0.4
	base_damage_mult = 0.4
	durability = 30

/obj/item/smithed_item/lens/velocity
	name = "velocity lens"
	desc = "An advanced lens that forces energy emissions from the barrel as fast as possible, accelerating them to ludicrous speed."
	base_laser_speed_mult = 0.5
	base_damage_mult = -0.2
	durability = 30

/obj/item/smithed_item/lens/admin
	name = "adminium lens"
	desc = "A hyper-advanced lens restricted to high-ranking central command officials."
	laser_speed_mult = 5
	damage_mult = 5
	fire_rate_mult = 5
	power_mult = -0.5
	durability = 3000
	quality = /datum/smith_quality/masterwork
	material = /datum/smith_material/platinum

// MARK: Random Spawners
/obj/item/smithed_item/random
	name = "random smithed item"
	desc = "If you see me please contact development because I should not exist."
	/// Weighted list of possible item qualities
	var/list/smithed_item_qualities = list(
		/datum/smith_quality = 9,
		/datum/smith_quality/improved = 1
	)
	/// Weighted list of possible item materials
	var/list/smithed_item_materials = list(
		/datum/smith_material/metal = 40,
		/datum/smith_material/silver = 10,
		/datum/smith_material/gold = 5,
		/datum/smith_material/plasma = 10,
		/datum/smith_material/titanium = 5,
		/datum/smith_material/uranium = 3,
		/datum/smith_material/brass = 15
	)
	/// List of possible item types
	var/list/smithed_type_list = list(
		/obj/item/smithed_item/insert/ballistic,
		/obj/item/smithed_item/insert/thermal,
		/obj/item/smithed_item/insert/fireproofing,
		/obj/item/smithed_item/insert/reflective,
		/obj/item/smithed_item/insert/rad_hazard,
		/obj/item/smithed_item/insert/rubberized,
		/obj/item/smithed_item/tool_bit/speed,
		/obj/item/smithed_item/tool_bit/balanced,
		/obj/item/smithed_item/tool_bit/efficiency,
		/obj/item/smithed_item/lens/accelerator,
		/obj/item/smithed_item/lens/speed,
		/obj/item/smithed_item/lens/amplifier,
		/obj/item/smithed_item/lens/efficiency
	)

/obj/item/smithed_item/random/Initialize(mapload)
	. = ..()
	var/picked_type =  pick(smithed_type_list)
	var/obj/item/smithed_item/new_item = new picked_type(src.loc)
	new_item.quality = pickweight(smithed_item_qualities)
	new_item.material = pickweight(smithed_item_materials)
	new_item.set_stats()
	new_item.update_appearance(UPDATE_NAME)
	qdel(src)

/obj/item/smithed_item/random/insert
	name = "random smithed insert"
	smithed_type_list = list(
		/obj/item/smithed_item/insert/ballistic,
		/obj/item/smithed_item/insert/thermal,
		/obj/item/smithed_item/insert/fireproofing,
		/obj/item/smithed_item/insert/reflective,
		/obj/item/smithed_item/insert/rad_hazard,
		/obj/item/smithed_item/insert/rubberized
	)

/obj/item/smithed_item/random/bit
	name = "random smithed tool bit"
	smithed_type_list = list(
		/obj/item/smithed_item/tool_bit/speed,
		/obj/item/smithed_item/tool_bit/balanced,
		/obj/item/smithed_item/tool_bit/efficiency
	)

/obj/item/smithed_item/random/lens
	name = "random smithed lens"
	smithed_type_list = list(
		/obj/item/smithed_item/lens/accelerator,
		/obj/item/smithed_item/lens/speed,
		/obj/item/smithed_item/lens/amplifier,
		/obj/item/smithed_item/lens/efficiency
	)

// MARK: Components

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
	/// What is this a part of
	var/finished_product
	/// Is this component currently hot
	var/hot = TRUE
	/// How many times the component needs to be shaped to be considered ready
	var/hammer_time = 3

/obj/item/smithed_item/component/update_icon_state()
	. = ..()
	if(hot)
		icon_state = "[initial(icon_state)]_hot"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/smithed_item/component/proc/powerhammer()
	hammer_time--
	if(prob(50) || hammer_time <= 0)
		hot = FALSE
		update_icon(UPDATE_ICON_STATE)

/obj/item/smithed_item/component/proc/heat_up()
	hot = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/item/smithed_item/component/examine(mob/user)
	. = ..()
	if(hammer_time)
		. += "It is incomplete. It looks like it needs [hammer_time] more cycles in the power hammer."
	else
		. += "It is complete."
	if(hot)
		. +="<span class='warning'>It is glowing hot!</span>"

/obj/item/smithed_item/component/attack_hand(mob/user)
	if(!hot)
		return ..()
	if(burn_check(user))
		burn_user(user)
		return
	return ..()

/obj/item/smithed_item/component/proc/set_worktime()
	if(!quality)
		return
	hammer_time = ROUND_UP(initial(hammer_time) * quality.work_mult)

/obj/item/smithed_item/component/proc/burn_check(mob/user)
	if(!hot)
		return FALSE
	var/burn_me = TRUE
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return TRUE
	if(H.gloves)
		var/obj/item/clothing/gloves/G = H.gloves
		if(G.max_heat_protection_temperature)
			burn_me = !(G.max_heat_protection_temperature > 360)

	if(!burn_me ||  HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS))
		return FALSE
	return TRUE

/obj/item/smithed_item/component/proc/burn_user(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	to_chat(user, "<span class='warning'>You burn your hand as you try to pick up [src]!</span>")
	var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_hand")
	if(affecting.receive_damage(0, 10)) // 10 burn damage
		H.UpdateDamageIcon()
	H.updatehealth()

// MARK: Insert Components

/obj/item/smithed_item/component/insert_frame
	name = "Debug insert frame"
	icon_state = "insert_frame"
	desc = "Debug smithed component part of an insert. If you see this, notify the development team."
	part_type = PART_PRIMARY

/obj/item/smithed_item/component/insert_frame/ballistic
	name = "ballistic insert frame"
	desc = "This is the primary component of a ballistic plate."
	materials = list(MAT_METAL = 10000)
	finished_product = /obj/item/smithed_item/insert/ballistic

/obj/item/smithed_item/component/insert_frame/thermal
	name = "thermal insert frame"
	desc = "This is the primary component of a thermal plate."
	materials = list(MAT_GOLD = 6000)
	finished_product = /obj/item/smithed_item/insert/thermal

/obj/item/smithed_item/component/insert_frame/fireproofing
	name = "fireproofing insert frame"
	desc = "This is the primary component of a fireproofing plate."
	materials = list(MAT_SILVER = 10000)
	finished_product = /obj/item/smithed_item/insert/fireproofing

/obj/item/smithed_item/component/insert_frame/reflective
	name = "reflective insert frame"
	desc = "This is the primary component of a reflective plate."
	materials = list(MAT_SILVER = 10000)
	finished_product = /obj/item/smithed_item/insert/reflective

/obj/item/smithed_item/component/insert_frame/rad_hazard
	name = "radiation hazard insert frame"
	desc = "This is the primary component of a radiation hazard plate."
	materials = list(MAT_GOLD = 6000)
	finished_product = /obj/item/smithed_item/insert/rad_hazard

/obj/item/smithed_item/component/insert_frame/rubberized
	name = "rubberized insert frame"
	desc = "This is the primary component of a rubberized plate."
	materials = list(MAT_PLASMA = 10000)
	finished_product = /obj/item/smithed_item/insert/rubberized

/obj/item/smithed_item/component/insert_frame/advanced
	name = "advanced insert frame"
	desc = "This is the primary component of a advanced armor mesh."
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 10000)
	finished_product = /obj/item/smithed_item/insert/advanced

/obj/item/smithed_item/component/insert_frame/engineering
	name = "engineering insert frame"
	desc = "This is the primary component of a advanced engineering mesh."
	materials = list(MAT_GOLD = 10000, MAT_SILVER = 10000)
	finished_product = /obj/item/smithed_item/insert/engineering

/obj/item/smithed_item/component/insert_frame/heavy
	name = "heavy duty insert frame"
	desc = "This is the primary component of a advanced heavy duty plate."
	materials = list(MAT_TITANIUM = 20000, MAT_PLASMA = 20000)
	finished_product = /obj/item/smithed_item/insert/heavy

/obj/item/smithed_item/component/insert_frame/mobility
	name = "mobility mesh insert frame"
	desc = "This is the primary component of a advanced mobility mesh."
	materials = list(MAT_BLUESPACE = 4000)
	finished_product = /obj/item/smithed_item/insert/mobility

/obj/item/smithed_item/component/insert_lining
	name = "Debug insert lining"
	icon_state = "insert_lining"
	desc = "Debug smithed component part of an insert. If you see this, notify the development team."
	part_type = PART_SECONDARY

/obj/item/smithed_item/component/insert_lining/ballistic
	name = "ballistic insert lining"
	desc = "This is the secondary component of a ballistic plate."
	materials = list(MAT_METAL = 10000)
	finished_product = /obj/item/smithed_item/insert/ballistic

/obj/item/smithed_item/component/insert_lining/thermal
	name = "thermal insert lining"
	desc = "This is the secondary component of a thermal plate."
	materials = list(MAT_METAL = 10000)
	finished_product = /obj/item/smithed_item/insert/thermal

/obj/item/smithed_item/component/insert_lining/fireproofing
	name = "fireproofing insert lining"
	desc = "This is the secondary component of a fireproofing plate."
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 10000)
	finished_product = /obj/item/smithed_item/insert/fireproofing

/obj/item/smithed_item/component/insert_lining/reflective
	name = "reflective insert lining"
	desc = "This is the secondary component of a reflective plate."
	materials = list(MAT_GOLD = 6000)
	finished_product = /obj/item/smithed_item/insert/reflective

/obj/item/smithed_item/component/insert_lining/rad_hazard
	name = "radiation hazard insert lining"
	desc = "This is the secondary component of a radiation hazard plate."
	materials = list(MAT_TITANIUM = 10000)
	finished_product = /obj/item/smithed_item/insert/rad_hazard

/obj/item/smithed_item/component/insert_lining/rubberized
	name = "rubberized insert lining"
	desc = "This is the secondary component of a rubberized plate."
	materials = list(MAT_PLASMA = 10000)
	finished_product = /obj/item/smithed_item/insert/rubberized

/obj/item/smithed_item/component/insert_lining/advanced
	name = "advanced insert lining"
	desc = "This is the secondary component of a advanced armor mesh."
	materials = list(MAT_TITANIUM = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/insert/advanced

/obj/item/smithed_item/component/insert_lining/engineering
	name = "engineering insert lining"
	desc = "This is the secondary component of a advanced engineering mesh."
	materials = list(MAT_TITANIUM = 10000, MAT_IRIDIUM = 2000)
	finished_product = /obj/item/smithed_item/insert/engineering

/obj/item/smithed_item/component/insert_lining/heavy
	name = "heavy duty insert lining"
	desc = "This is the secondary component of a advanced heavy duty plate."
	materials = list(MAT_TITANIUM = 10000, MAT_PLATINUM = 2000)
	finished_product = /obj/item/smithed_item/insert/heavy

/obj/item/smithed_item/component/insert_lining/mobility
	name = "mobility mesh insert lining"
	desc = "This is the secondary component of a advanced mobility mesh."
	materials = list(MAT_PALLADIUM = 2000)
	finished_product = /obj/item/smithed_item/insert/mobility

// MARK: Bit Components

/obj/item/smithed_item/component/bit_mount
	name = "Debug bit mount"
	icon_state = "bit_mount"
	desc = "Debug smithed component part of a tool bit. If you see this, notify the development team."
	part_type = PART_PRIMARY

/obj/item/smithed_item/component/bit_mount/speed
	name = "speed bit mount"
	desc = "This is the primary component of a speed bit"
	materials = list(MAT_TITANIUM = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/speed

/obj/item/smithed_item/component/bit_mount/efficiency
	name = "efficiency bit mount"
	desc = "This is the primary component of an efficiency bit"
	materials = list(MAT_SILVER = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/efficiency

/obj/item/smithed_item/component/bit_mount/balanced
	name = "balanced bit mount"
	desc = "This is the primary component of an balanced bit."
	materials = list(MAT_TITANIUM = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/balanced

/obj/item/smithed_item/component/bit_mount/heavy
	name = "heavy duty bit mount"
	desc = "This is the primary component of a heavy duty bit."
	materials = list(MAT_TITANIUM = 8000, MAT_PLASMA = 8000)
	finished_product = /obj/item/smithed_item/tool_bit/heavy

/obj/item/smithed_item/component/bit_mount/economical
	name = "economical bit mount"
	desc = "This is the primary component of an economical bit."
	materials = list(MAT_TITANIUM = 4000, MAT_PLASMA = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/economical

/obj/item/smithed_item/component/bit_mount/advanced
	name = "advanced bit mount"
	desc = "This is the primary component of an advanced bit."
	materials = list(MAT_TITANIUM = 4000, MAT_PLASMA = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/advanced

/obj/item/smithed_item/component/bit_head
	name = "Debug bit head"
	icon_state = "bit_head"
	desc = "Debug smithed component part of a tool bit. If you see this, notify the development team."
	part_type = PART_SECONDARY

/obj/item/smithed_item/component/bit_head/speed
	name = "speed bit head"
	desc = "This is the secondary component of a speed bit."
	materials = list(MAT_METAL = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/speed

/obj/item/smithed_item/component/bit_head/efficiency
	name = "efficiency bit head"
	desc = "This is the secondary component of an efficiency bit."
	materials = list(MAT_METAL = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/efficiency

/obj/item/smithed_item/component/bit_head/balanced
	name = "balanced bit head"
	desc = "This is the secondary component of a balanced bit."
	materials = list(MAT_BRASS = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/balanced

/obj/item/smithed_item/component/bit_head/heavy
	name = "heavy duty bit head"
	desc = "This is the secondary component of a heavy duty bit."
	materials = list(MAT_METAL = 8000, MAT_PLASMA = 8000)
	finished_product = /obj/item/smithed_item/tool_bit/heavy

/obj/item/smithed_item/component/bit_head/economical
	name = "economical bit head"
	desc = "This is the secondary component of an economical bit."
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/economical

/obj/item/smithed_item/component/bit_head/advanced
	name = "advanced bit head"
	desc = "This is the secondary component of an advanced bit."
	materials = list(MAT_METAL = 4000, MAT_PLATINUM = 4000)
	finished_product = /obj/item/smithed_item/tool_bit/advanced

// MARK: Lens Compnents

/obj/item/smithed_item/component/lens_frame
	name = "Debug lens frame"
	icon_state = "lens_frame"
	desc = "Debug smithed component part of a laser lens. If you see this, notify the development team."
	part_type = PART_PRIMARY

/obj/item/smithed_item/component/lens_frame/accelerator
	name = "accelerator lens frame"
	desc = "This is the primary component of an accelerator lens."
	materials = list(MAT_TITANIUM = 4000)
	finished_product = /obj/item/smithed_item/lens/accelerator

/obj/item/smithed_item/component/lens_frame/speed
	name = "speed lens frame"
	desc = "This is the primary component of a speed lens."
	materials = list(MAT_METAL = 4000)
	finished_product = /obj/item/smithed_item/lens/speed

/obj/item/smithed_item/component/lens_frame/amplifier
	name = "amplifier lens frame"
	desc = "This is the primary component of an amplifier lens."
	materials = list(MAT_GOLD = 4000)
	finished_product = /obj/item/smithed_item/lens/amplifier

/obj/item/smithed_item/component/lens_frame/efficiency
	name = "efficiency lens frame"
	desc = "This is the primary component of an efficiency lens."
	materials = list(MAT_SILVER = 4000)
	finished_product = /obj/item/smithed_item/lens/efficiency

/obj/item/smithed_item/component/lens_frame/rapid
	name = "rapid lens frame"
	desc = "This is the primary component of an advanced rapid lens."
	materials = list(MAT_PALLADIUM = 2000)
	finished_product = /obj/item/smithed_item/lens/rapid

/obj/item/smithed_item/component/lens_frame/densifier
	name = "densifier lens frame"
	desc = "This is the primary component of an advanced densifier lens."
	materials = list(MAT_PLATINUM = 2000)
	finished_product = /obj/item/smithed_item/lens/densifier

/obj/item/smithed_item/component/lens_frame/velocity
	name = "velocity lens frame"
	desc = "This is the primary component of an advanced velocity lens."
	materials = list(MAT_BRASS = 30000)
	finished_product = /obj/item/smithed_item/lens/velocity

/obj/item/smithed_item/component/lens_focus
	name = "Debug lens focus"
	icon_state = "lens_focus"
	desc = "Debug smithed component part of a laser lens. If you see this, notify the development team."
	part_type = PART_SECONDARY

/obj/item/smithed_item/component/lens_focus/accelerator
	name = "accelerator lens focus"
	desc = "This is the secondary component of an accelerator lens."
	materials = list(MAT_METAL = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lens/accelerator

/obj/item/smithed_item/component/lens_focus/speed
	name = "speed lens focus"
	desc = "This is the secondary component of a speed lens."
	materials = list(MAT_PLASMA = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lens/speed

/obj/item/smithed_item/component/lens_focus/amplifier
	name = "amplifier lens focus"
	desc = "This is the secondary component of an amplifier lens."
	materials = list(MAT_TITANIUM = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lens/amplifier

/obj/item/smithed_item/component/lens_focus/efficiency
	name = "efficiency lens focus"
	desc = "This is the secondary component of an efficiency lens."
	materials = list(MAT_METAL = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lens/efficiency

/obj/item/smithed_item/component/lens_focus/rapid
	name = "rapid lens focus"
	desc = "This is the secondary component of an advanced rapid lens."
	materials = list(MAT_PLASMA = 10000, MAT_GLASS = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/lens/rapid

/obj/item/smithed_item/component/lens_focus/densifier
	name = "densifier lens focus"
	desc = "This is the secondary component of an advanced densifier lens."
	materials = list(MAT_PLASMA = 10000, MAT_GLASS = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/lens/densifier

/obj/item/smithed_item/component/lens_focus/velocity
	name = "velocity lens focus"
	desc = "This is the secondary component of an advanced velocity lens."
	materials = list(MAT_PLASMA = 10000, MAT_GLASS = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/lens/velocity

// MARK: Trims

/obj/item/smithed_item/component/trim
	name = "Debug trim"
	icon_state = "trim"
	desc = "Debug smithed component part of any smithed item. If you see this, notify the development team."
	part_type = PART_TRIM

/obj/item/smithed_item/component/trim/set_name()
	if(!quality)
		return
	name = "[quality.name] " + name
	return

/obj/item/smithed_item/component/trim/metal
	name = "metal trim"
	desc = "Smithed component of any smithing item. Made of metal."
	materials = list(MAT_METAL = 10000)
	material = /datum/smith_material/metal

/obj/item/smithed_item/component/trim/silver
	name = "silver trim"
	desc = "Smithed component of any smithing item. Made of silver."
	materials = list(MAT_SILVER = 10000)
	material = /datum/smith_material/silver

/obj/item/smithed_item/component/trim/gold
	name = "gold trim"
	desc = "Smithed component of any smithing item. Made of gold."
	materials = list(MAT_GOLD = 10000)
	material = /datum/smith_material/gold

/obj/item/smithed_item/component/trim/plasma
	name = "plasma trim"
	desc = "Smithed component of any smithing item. Made of solid plasma."
	materials = list(MAT_PLASMA = 10000)
	material = /datum/smith_material/plasma

/obj/item/smithed_item/component/trim/titanium
	name = "titanium trim"
	desc = "Smithed component of any smithing item. Made of titanium."
	materials = list(MAT_TITANIUM = 10000)
	material = /datum/smith_material/titanium

/obj/item/smithed_item/component/trim/uranium
	name = "uranium trim"
	desc = "Smithed component of any smithing item. Made of uranium."
	materials = list(MAT_URANIUM = 10000)
	material = /datum/smith_material/uranium

/obj/item/smithed_item/component/trim/diamond
	name = "diamond trim"
	desc = "Smithed component of any smithing item. Made of diamond."
	materials = list(MAT_DIAMOND = 10000)
	material = /datum/smith_material/diamond

/obj/item/smithed_item/component/trim/bluespace
	name = "bluespace trim"
	desc = "Smithed component of any smithing item. Made of bluespace crystals."
	materials = list(MAT_BLUESPACE = 10000)
	material = /datum/smith_material/bluespace

/obj/item/smithed_item/component/trim/plasteel
	name = "plasteel trim"
	desc = "Smithed component of any smithing item. Made of plasteel."
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 10000)
	material = /datum/smith_material/plasteel

/obj/item/smithed_item/component/trim/plastitanium
	name = "plastitanium trim"
	desc = "Smithed component of any smithing item. Made of plastitanium."
	materials = list(MAT_TITANIUM = 10000, MAT_PLASMA = 10000)
	material = /datum/smith_material/plastitanium

/obj/item/smithed_item/component/trim/iridium
	name = "iridium trim"
	desc = "Smithed component of any smithing item. Made of iridium."
	materials = list(MAT_IRIDIUM = 10000)
	material = /datum/smith_material/iridium

/obj/item/smithed_item/component/trim/palladium
	name = "palladium trim"
	desc = "Smithed component of any smithing item. Made of palladium."
	materials = list(MAT_PALLADIUM = 10000)
	material = /datum/smith_material/palladium

/obj/item/smithed_item/component/trim/platinum
	name = "platinum trim"
	desc = "Smithed component of any smithing item. Made of platinum."
	materials = list(MAT_PLATINUM = 10000)
	material = /datum/smith_material/platinum

/obj/item/smithed_item/component/trim/brass
	name = "brass trim"
	desc = "Smithed component of any smithing item. Made of brass."
	materials = list(MAT_BRASS = 10000)
	material = /datum/smith_material/brass

// MARK: Energy Gun Frame
/obj/item/smithed_item/component/egun_frame
	name = "energy gun frame"
	desc = "Smithed component of an energy gun."
	materials = list(MAT_TITANIUM = 10000, MAT_PLASMA = 10000)

#undef PART_PRIMARY
#undef PART_SECONDARY
#undef PART_TRIM

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
	/// Heat insulation
	var/heat_insulation = 0
	/// Electrical insulation
	var/siemens_coeff = 0.0
	/// Radiation armor
	var/radiation_armor = 0
	/// The suit the insert is attached to
	var/obj/item/clothing/suit/attached_suit

/obj/item/smithed_item/insert/set_stats()
	..()
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
	attached_suit.insert_slowdown -= movement_speed_mod
	attached_suit.slowdown = initial(attached_suit.slowdown) + attached_suit.insert_slowdown
	if(attached_suit.mobility_meshed)
		attached_suit.slowdown = 0
	attached_suit.siemens_coefficient -= siemens_coeff
	attached_suit.min_cold_protection_temperature -= heat_insulation
	attached_suit.max_heat_protection_temperature += heat_insulation

/obj/item/smithed_item/insert/on_detached(mob/user)
	attached_suit.armor = attached_suit.armor.detachArmor(armor)
	attached_suit.insert_slowdown += movement_speed_mod
	attached_suit.slowdown = initial(attached_suit.slowdown) + attached_suit.insert_slowdown
	if(attached_suit.mobility_meshed)
		attached_suit.slowdown = 0
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
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/insert/thermal
	name = "thermal plate"
	desc = "A fragile plate designed to reduce heat exposure."
	brute_armor = -10
	burn_armor = 10
	heat_insulation = 10
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/insert/fireproofing
	name = "fireproofing plate"
	desc = "A heavy plate of asbestos designed to fireproof a user. A firefighter's godsend."
	burn_armor = 10
	movement_speed_mod = -1
	heat_insulation = 20
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/insert/reflective
	name = "reflective plate"
	desc = "A shiny plate that assists in laser deflection."
	burn_armor = -10
	laser_armor = 10
	siemens_coeff = -0.2
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/insert/rad_hazard
	name = "radiation hazard plate"
	desc = "A dense plate that can reduce a wearer's radiation exposure."
	heat_insulation = -10
	radiation_armor = 20
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/insert/rubberized
	name = "rubberized plate"
	desc = "A flexible plate that is resistant to electrical shocks."
	brute_armor = -10
	siemens_coeff = 0.2
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/insert/advanced
	name = "advanced armor mesh"
	desc = "An alloy mesh that can protect the wearer from most sources of damage."
	brute_armor = 10
	burn_armor = 10
	laser_armor = 10
	explosive_armor = 10
	radiation_armor = 10
	movement_speed_mod = -1

/obj/item/smithed_item/insert/engineering
	name = "engineering mesh"
	desc = "An alloy mesh designed to assist in most work around electrical engines."
	brute_armor = -10
	burn_armor = 10
	radiation_armor = 10
	heat_insulation = 10
	explosive_armor = 10
	siemens_coeff = 0.4
	movement_speed_mod = -1

/obj/item/smithed_item/insert/heavy
	name = "heavy duty plate"
	desc = "An advanced plate often used in SWAT gear. Heavy, yet durable."
	brute_armor = 20
	burn_armor = 10
	laser_armor = 10
	explosive_armor = 10
	heat_insulation = 10
	siemens_coeff = -0.4
	movement_speed_mod = -1.5

/obj/item/smithed_item/insert/mobility
	name = "mobility mesh"
	desc = "An advanced alloy mesh that is both lightweight and invigorating to the wearer."
	brute_armor = -5
	burn_armor = -5
	laser_armor = -5
	heat_insulation = 10
	/// Attached suit slowdown when the mobility mesh was applied
	var/initial_slowdown = 0

/obj/item/smithed_item/insert/mobility/on_attached(obj/item/clothing/suit/target)
	. = ..()
	attached_suit.mobility_meshed = TRUE
	attached_suit.slowdown = 0

/obj/item/smithed_item/insert/mobility/on_detached(mob/user)
	attached_suit.mobility_meshed = FALSE
	. = ..()


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

/obj/item/smithed_item/insert/AltClick(mob/user, modifiers)
	if(!HAS_TRAIT(user.mind, TRAIT_SMITH))
		return
	if(do_after_once(user, 3 SECONDS, target = src, allow_moving = TRUE, must_be_held = TRUE))
		var/compiled_message = "<span class='notice'>\
		You determine the following properties on [src]: <br>\
		Brute Armor mod: [brute_armor] <br>\
		Burn Armor mod: [burn_armor] <br>\
		Laser Armor mod: [laser_armor] <br>\
		Explosive Resistance mod: [explosive_armor] <br>\
		Movement Speed mod: [movement_speed_mod] <br>\
		Heat Insulation mod: [heat_insulation] <br>\
		Siemens Coefficient mod: [siemens_coeff] <br>\
		Radiation Resistance mod: [radiation_armor] <br>\
		</span>"
		to_chat(user, compiled_message)

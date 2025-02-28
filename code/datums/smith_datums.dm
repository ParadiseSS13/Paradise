// Quality

/datum/smith_quality
	var/name = "standard"
	/// How much does this quality improve stats?
	var/stat_mult = 1.0
	/// How many more materials does this quality require?
	var/material_mult = 1.0
	/// How much extra work is needed to produce this quality?
	var/work_mult = 1.0

/datum/smith_quality/improved
	name = "improved"
	stat_mult = 1.25
	material_mult = 1.5
	work_mult = 2.0

/datum/smith_quality/enhanced
	name = "enhanced"
	stat_mult = 1.5
	material_mult = 2.0
	work_mult = 3.0

/datum/smith_quality/superior
	name = "superior"
	stat_mult = 1.75
	material_mult = 3.0
	work_mult = 4.5

/datum/smith_quality/masterwork
	name = "masterwork"
	stat_mult = 2.0
	material_mult = 4.0
	work_mult = 6.0

// Materials

#define MAJOR_MATERIAL_BUFF 1.2
#define MINOR_MATERIAL_BUFF 1.1
#define MINOR_MATERIAL_DEBUFF 0.9
#define MAJOR_MATERIAL_DEBUFF 0.8

/datum/smith_material
	var/name = "Boring Debug"
	/// Brute armor multiplier
	var/brute_armor_mult = 1.0
	/// Burn armor multiplier
	var/burn_armor_mult = 1.0
	/// Laser armor multiplier
	var/laser_armor_mult = 1.0
	/// Explosive armor multiplier
	var/explosive_armor_mult = 1.0
	/// Movement speed modifier
	var/movement_speed_mod = 0
	/// Heat insulation multiplier
	var/heat_insulation_mult = 1.0
	/// Electrical insulation multiplier
	var/siemens_coeff_mult = 1.0
	/// Radiation insulation multiplier
	var/radiation_armor_mult = 1.0
	/// Tool speed multiplier
	var/tool_speed_mult = 1.0
	/// Tool precision multiplier
	var/tool_failure_mult = 1.0
	/// How much larger does a bit with this material make it?
	var/size_mod = 0
	/// Projectile speed multiplier
	var/projectile_speed_mult = 1.0
	/// Power draw multiplier
	var/power_draw_mult = 1.0
	/// Projectile damage multiplier
	var/projectile_damage_multiplier = 1.0
	/// Fire rate multiplier
	var/fire_rate_multiplier = 1.0
	/// Multiplier for tool uses and lens uses.
	var/durability_mult = 1.0

/datum/smith_material/metal
	name = "metal"
	brute_armor_mult = MINOR_MATERIAL_BUFF
	burn_armor_mult = MINOR_MATERIAL_DEBUFF
	explosive_armor_mult = MINOR_MATERIAL_BUFF
	movement_speed_mod = MINOR_MATERIAL_BUFF
	radiation_armor_mult = MINOR_MATERIAL_BUFF
	tool_failure_mult = MINOR_MATERIAL_BUFF
	fire_rate_multiplier = MINOR_MATERIAL_DEBUFF
	durability_mult = MINOR_MATERIAL_BUFF

/datum/smith_material/silver
	name = "silver"
	laser_armor_mult = MINOR_MATERIAL_BUFF
	heat_insulation_mult = MINOR_MATERIAL_BUFF
	siemens_coeff_mult = MINOR_MATERIAL_DEBUFF
	tool_failure_mult = MINOR_MATERIAL_DEBUFF
	power_draw_mult = MINOR_MATERIAL_DEBUFF
	projectile_damage_multiplier = MINOR_MATERIAL_DEBUFF

/datum/smith_material/gold
	name = "gold"
	burn_armor_mult = MINOR_MATERIAL_BUFF
	movement_speed_mod = MINOR_MATERIAL_BUFF
	heat_insulation_mult = MINOR_MATERIAL_BUFF
	siemens_coeff_mult = MINOR_MATERIAL_DEBUFF
	radiation_armor_mult = MAJOR_MATERIAL_BUFF
	tool_speed_mult = MINOR_MATERIAL_BUFF
	tool_failure_mult = MINOR_MATERIAL_DEBUFF
	size_mod = 1
	fire_rate_multiplier = MINOR_MATERIAL_BUFF
	durability_mult = MINOR_MATERIAL_DEBUFF

/datum/smith_material/plasma
	name = "plasma"
	burn_armor_mult = MAJOR_MATERIAL_DEBUFF
	explosive_armor_mult = MINOR_MATERIAL_BUFF
	siemens_coeff_mult = MINOR_MATERIAL_BUFF
	tool_speed_mult = MINOR_MATERIAL_BUFF
	projectile_damage_multiplier = MINOR_MATERIAL_BUFF
	durability_mult = MINOR_MATERIAL_DEBUFF

/datum/smith_material/titanium
	name = "titanium"
	brute_armor_mult = MINOR_MATERIAL_BUFF
	burn_armor_mult = MINOR_MATERIAL_DEBUFF
	laser_armor_mult = MINOR_MATERIAL_BUFF
	heat_insulation_mult = MINOR_MATERIAL_BUFF
	tool_failure_mult = MINOR_MATERIAL_DEBUFF
	tool_speed_mult = MINOR_MATERIAL_BUFF
	projectile_speed_mult = MINOR_MATERIAL_BUFF
	power_draw_mult = MINOR_MATERIAL_DEBUFF
	fire_rate_multiplier = MINOR_MATERIAL_DEBUFF

/datum/smith_material/uranium
	name = "uranium"
	burn_armor_mult = MINOR_MATERIAL_BUFF
	laser_armor_mult = MINOR_MATERIAL_BUFF
	explosive_armor_mult = MINOR_MATERIAL_BUFF
	movement_speed_mod = MINOR_MATERIAL_BUFF
	siemens_coeff_mult = MINOR_MATERIAL_BUFF
	radiation_armor_mult = MAJOR_MATERIAL_DEBUFF
	tool_speed_mult = MINOR_MATERIAL_BUFF
	tool_failure_mult = MINOR_MATERIAL_DEBUFF
	size_mod = 1
	projectile_speed_mult = MINOR_MATERIAL_BUFF
	power_draw_mult = MINOR_MATERIAL_DEBUFF
	fire_rate_multiplier = MINOR_MATERIAL_DEBUFF
	durability_mult = MINOR_MATERIAL_BUFF
	/// Radioactive, woah
	var/radiation_amount = 15

/datum/smith_material/diamond
	name = "diamond"
	brute_armor_mult = MAJOR_MATERIAL_BUFF
	burn_armor_mult = MINOR_MATERIAL_BUFF
	explosive_armor_mult = MINOR_MATERIAL_BUFF
	siemens_coeff_mult = MAJOR_MATERIAL_BUFF
	tool_failure_mult = MINOR_MATERIAL_DEBUFF
	durability_mult = MAJOR_MATERIAL_BUFF

/datum/smith_material/bluespace
	name = "bluespace"
	laser_armor_mult = MAJOR_MATERIAL_BUFF
	explosive_armor_mult = MINOR_MATERIAL_BUFF
	movement_speed_mod = MINOR_MATERIAL_DEBUFF
	heat_insulation_mult = MINOR_MATERIAL_BUFF
	siemens_coeff_mult = MINOR_MATERIAL_BUFF
	radiation_armor_mult = MINOR_MATERIAL_DEBUFF
	tool_speed_mult = MAJOR_MATERIAL_BUFF
	power_draw_mult = MAJOR_MATERIAL_BUFF
	projectile_damage_multiplier = MAJOR_MATERIAL_BUFF

/datum/smith_material/plasteel
	name = "plasteel"
	brute_armor_mult = MINOR_MATERIAL_BUFF
	burn_armor_mult = MINOR_MATERIAL_BUFF
	laser_armor_mult = MINOR_MATERIAL_BUFF
	explosive_armor_mult = MINOR_MATERIAL_BUFF
	movement_speed_mod = MAJOR_MATERIAL_BUFF
	heat_insulation_mult = MINOR_MATERIAL_DEBUFF
	tool_speed_mult = MINOR_MATERIAL_BUFF
	size_mod = 2
	power_draw_mult = MAJOR_MATERIAL_BUFF
	projectile_damage_multiplier = MINOR_MATERIAL_BUFF
	fire_rate_multiplier = MINOR_MATERIAL_BUFF
	durability_mult = MAJOR_MATERIAL_BUFF

/datum/smith_material/plastitanium
	name = "plastitanium"
	brute_armor_mult = MINOR_MATERIAL_BUFF
	burn_armor_mult = MINOR_MATERIAL_BUFF
	laser_armor_mult = MAJOR_MATERIAL_BUFF
	explosive_armor_mult = MINOR_MATERIAL_BUFF
	movement_speed_mod = MINOR_MATERIAL_BUFF
	heat_insulation_mult = MINOR_MATERIAL_DEBUFF
	radiation_armor_mult = MINOR_MATERIAL_BUFF
	tool_speed_mult = MINOR_MATERIAL_BUFF
	size_mod = 1
	projectile_speed_mult = MINOR_MATERIAL_BUFF
	power_draw_mult = MAJOR_MATERIAL_BUFF
	fire_rate_multiplier = MINOR_MATERIAL_BUFF
	durability_mult = MAJOR_MATERIAL_BUFF

/datum/smith_material/iridium
	name = "iridium"
	brute_armor_mult = MINOR_MATERIAL_BUFF
	burn_armor_mult = MINOR_MATERIAL_BUFF
	laser_armor_mult = MINOR_MATERIAL_BUFF
	movement_speed_mod = MINOR_MATERIAL_BUFF
	heat_insulation_mult = MINOR_MATERIAL_DEBUFF
	radiation_armor_mult = MINOR_MATERIAL_BUFF
	tool_speed_mult = MINOR_MATERIAL_BUFF
	size_mod = -1
	projectile_speed_mult = MINOR_MATERIAL_BUFF
	power_draw_mult = MINOR_MATERIAL_BUFF
	projectile_damage_multiplier = MINOR_MATERIAL_BUFF
	durability_mult = MINOR_MATERIAL_BUFF

/datum/smith_material/palladium
	name = "palladium"
	brute_armor_mult = MINOR_MATERIAL_BUFF
	burn_armor_mult = MINOR_MATERIAL_BUFF
	laser_armor_mult = MINOR_MATERIAL_DEBUFF
	explosive_armor_mult = MINOR_MATERIAL_DEBUFF
	heat_insulation_mult = MINOR_MATERIAL_BUFF
	siemens_coeff_mult = MINOR_MATERIAL_BUFF
	radiation_armor_mult = MINOR_MATERIAL_BUFF
	tool_speed_mult = MINOR_MATERIAL_BUFF
	size_mod = -1
	power_draw_mult = MINOR_MATERIAL_DEBUFF
	projectile_damage_multiplier = MINOR_MATERIAL_DEBUFF
	durability_mult = MINOR_MATERIAL_BUFF

/datum/smith_material/platinum
	name = "platinum"
	brute_armor_mult = MINOR_MATERIAL_BUFF
	burn_armor_mult = MINOR_MATERIAL_BUFF
	laser_armor_mult = MINOR_MATERIAL_BUFF
	explosive_armor_mult = MINOR_MATERIAL_DEBUFF
	movement_speed_mod = MINOR_MATERIAL_DEBUFF
	heat_insulation_mult = MINOR_MATERIAL_DEBUFF
	siemens_coeff_mult = MINOR_MATERIAL_DEBUFF
	tool_failure_mult = MINOR_MATERIAL_DEBUFF
	size_mod = -1
	projectile_damage_multiplier = MINOR_MATERIAL_BUFF
	power_draw_mult = MINOR_MATERIAL_BUFF
	durability_mult = MINOR_MATERIAL_BUFF

/datum/smith_material/brass
	name = "brass"
	brute_armor_mult = MINOR_MATERIAL_DEBUFF
	burn_armor_mult = MINOR_MATERIAL_DEBUFF
	laser_armor_mult = MAJOR_MATERIAL_BUFF
	explosive_armor_mult = MINOR_MATERIAL_DEBUFF
	movement_speed_mod = MINOR_MATERIAL_DEBUFF
	heat_insulation_mult = MINOR_MATERIAL_DEBUFF
	siemens_coeff_mult = MINOR_MATERIAL_DEBUFF
	radiation_armor_mult = MINOR_MATERIAL_BUFF
	tool_speed_mult = MINOR_MATERIAL_BUFF
	tool_failure_mult = MINOR_MATERIAL_DEBUFF
	projectile_speed_mult = MINOR_MATERIAL_DEBUFF
	power_draw_mult = MAJOR_MATERIAL_DEBUFF
	fire_rate_multiplier = MINOR_MATERIAL_DEBUFF
	durability_mult = MINOR_MATERIAL_DEBUFF

#undef MAJOR_MATERIAL_BUFF
#undef MINOR_MATERIAL_BUFF
#undef MINOR_MATERIAL_DEBUFF
#undef MAJOR_MATERIAL_DEBUFF

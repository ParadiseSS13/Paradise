// Quality

/datum/smith_quality
	var/name = "Boring Debug"
	/// How much does this quality improve stats?
	var/stat_mult = 1.0
	/// How many more materials does this quality require?
	var/material_mult = 1.0
	/// How much extra work is needed to produce this quality?
	var/work_mult = 1.0

/datum/smith_quality/standard
	name = "Standard"
	stat_mult = 1.0
	material_mult = 1.0
	work_mult = 1.0

/datum/smith_quality/improved
	name = "Improved"
	stat_mult = 1.25
	material_mult = 1.5
	work_mult = 2.0

/datum/smith_quality/enhanced
	name = "Enhanced"
	stat_mult = 1.5
	material_mult = 2.0
	work_mult = 3.0

/datum/smith_quality/superior
	name = "Superior"
	stat_mult = 1.75
	material_mult = 3.0
	work_mult = 4.5

/datum/smith_quality/masterwork
	name = "Masterwork"
	stat_mult = 2.0
	material_mult = 4.0
	work_mult = 6.0

// Materials

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
	/// Movement speed multiplier
	var/movement_speed_mult = 1.0
	/// Heat insulation multiplier
	var/heat_insulation_mult = 1.0
	/// Electrical insulation multiplier
	var/siemens_coeff_mult = 1.0
	/// Radiation insulation multiplier
	var/radiation_armor_mult = 1.0
	/// Tool speed multiplier
	var/tool_speed_mult = 1.0
	/// Tool precision multiplier
	var/tool_precision_mult = 1.0
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
	/// Multiplier for tool uses and lense uses.
	var/durability_mult = 1.0

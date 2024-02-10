#define ARMORID "armor-[melee]-[bullet]-[laser]-[energy]-[bomb]-[rad]-[fire]-[acid]-[magic]"

/proc/getArmor(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, rad = 0, fire = 0, acid = 0, magic = 0)
	. = locate(ARMORID)
	if(!.)
		. = new /datum/armor(melee, bullet, laser, energy, bomb, rad, fire, acid, magic)

/datum/armor
	var/melee
	var/bullet
	var/laser
	var/energy
	var/bomb
	var/rad
	var/fire
	var/acid
	var/magic

/datum/armor/New(melee_value = 0, bullet_value = 0, laser_value = 0, energy_value = 0, bomb_value = 0, rad_value = 0, fire_value = 0, acid_value = 0, magic_value = 0)
	melee = melee_value
	bullet = bullet_value
	laser = laser_value
	energy = energy_value
	bomb = bomb_value
	rad = rad_value
	fire = fire_value
	acid = acid_value
	magic = magic_value
	tag = ARMORID

/datum/armor/proc/modifyRating(melee_value = 0, bullet_value = 0, laser_value = 0, energy_value = 0, bomb_value = 0, rad_value = 0, fire_value = 0, acid_value = 0, magic_value = 0)
	return getArmor(melee + melee_value, bullet + bullet_value, laser + laser_value, energy + energy_value, bomb + bomb_value, rad + rad_value, fire + fire_value, acid + acid_value, magic + magic_value)

/datum/armor/proc/modifyAllRatings(modifier = 0)
	return getArmor(melee + modifier, bullet + modifier, laser + modifier, energy + modifier, bomb + modifier, rad + modifier, fire + modifier, acid + modifier, magic + modifier)

/datum/armor/proc/setRating(melee_value, bullet_value, laser_value, energy_value, bomb_value, rad_value, fire_value, acid_value, magic_value)
	return getArmor((isnull(melee_value) ? melee : melee_value),\
					(isnull(bullet_value) ? bullet : bullet_value),\
					(isnull(laser_value) ? laser : laser_value),\
					(isnull(energy_value) ? energy : energy_value),\
					(isnull(bomb_value) ? bomb : bomb_value),\
					(isnull(rad_value) ? rad : rad_value),\
					(isnull(fire_value) ? fire : fire_value),\
					(isnull(acid_value) ? acid : acid_value),\
					(isnull(magic_value) ? magic : magic_value))

/datum/armor/proc/getRating(rating)
	return vars[rating]

/datum/armor/proc/getList()
	return list(MELEE = melee, BULLET = bullet, LASER = laser, ENERGY = energy, BOMB = bomb, RAD = rad, FIRE = fire, ACID = acid, MAGIC = magic)

/datum/armor/proc/attachArmor(datum/armor/AA)
	return getArmor(melee + AA.melee, bullet + AA.bullet, laser + AA.laser, energy + AA.energy, bomb + AA.bomb, rad + AA.rad, fire + AA.fire, acid + AA.acid, magic + AA.magic)

/datum/armor/proc/detachArmor(datum/armor/AA)
	return getArmor(melee - AA.melee, bullet - AA.bullet, laser - AA.laser, energy - AA.energy, bomb - AA.bomb, rad - AA.rad, fire - AA.fire, acid - AA.acid, magic - AA.magic)

/datum/armor/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, tag))
		return FALSE
	. = ..()
	tag = ARMORID // update tag in case armor values were edited

#undef ARMORID

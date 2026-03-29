/obj/structure/blob/shield
	name = "strong blob"
	icon_state = "blob_shield"
	max_integrity = 150
	brute_resist = 0.25
	explosion_block = 3
	atmosblock = TRUE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 90, ACID = 90)

/obj/structure/blob/shield/core

/obj/structure/blob/shield/check_integrity()
	var/old_compromised_integrity = compromised_integrity
	if(obj_integrity < max_integrity * 0.5)
		compromised_integrity = TRUE
	else
		compromised_integrity = FALSE
	if(old_compromised_integrity != compromised_integrity)
		update_state()
		update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)

/obj/structure/blob/shield/update_state()
	if(compromised_integrity)
		atmosblock = FALSE
	else
		atmosblock = TRUE
	recalculate_atmos_connectivity()

/obj/structure/blob/shield/update_name()
	. = ..()
	if(compromised_integrity)
		name = "weakened [initial(name)]"
	else
		name = initial(name)

/obj/structure/blob/shield/update_desc()
	. = ..()
	if(compromised_integrity)
		desc = "A wall of twitching tendrils."
	else
		desc = initial(desc)

/obj/structure/blob/shield/update_icon_state()
	if(compromised_integrity)
		icon_state = "[initial(icon_state)]_damaged"
	else
		icon_state = initial(icon_state)

/obj/structure/blob/shield/CanPass(atom/movable/mover, border_dir)
	return istype(mover) && mover.checkpass(PASSBLOB)

/obj/structure/blob/shield/reflective
	name = "reflective blob"
	desc = "A solid wall of slightly twitching tendrils with a reflective glow."
	icon_state = "blob_glow"
	max_integrity = 100
	brute_resist = 0.5
	explosion_block = 2
	point_return = 9
	flags_ricochet = RICOCHET_SHINY

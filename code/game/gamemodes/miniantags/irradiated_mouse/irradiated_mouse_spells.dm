/datum/spell/irradiated_mouse_spell/
	action_background_icon_state = "bg_irradiated_mouse"
	clothes_req = FALSE
	base_cooldown = 5 SECONDS

/datum/spell/irradiated_mouse_spell/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/irradiated_mouse_spell/proc/has_upgrades(mob/living/basic/mouse/irradiated_mouse/user)
	if(!user.available_upgrades)
		to_chat(user, SPAN_WARN("You dont have any available upgrades"))
		return FALSE
	return TRUE

/datum/spell/irradiated_mouse_spell/upgrade_radiation
	name = "Upgrade Radiation"
	desc = "Upgrade the amount of radiation you emit. You will start producing radioactive sludge at level 3."
	action_icon_state = "irradiated_mouse_radiation"

/datum/spell/irradiated_mouse_spell/upgrade_radiation/cast(list/targets, mob/living/basic/mouse/irradiated_mouse/user)
	. = ..()
	if(!has_upgrades(user))
		return

	user.available_upgrades--
	user.upgrade_radiation()
	if(user.radiation_upgrades > user.level_cap)
		user.RemoveSpell(user.upgrade_radiation_spell)
		user.produce_radioactive_sludge = TRUE

/datum/spell/irradiated_mouse_spell/upgrade_speed
	name = "Upgrade Speed"
	desc = "Upgrade your speed. You will become semi-transparent at level 3."
	action_icon_state = "irradiated_mouse_speed"

/datum/spell/irradiated_mouse_spell/upgrade_speed/cast(list/targets, mob/living/basic/mouse/irradiated_mouse/user)
	. = ..()
	if(!has_upgrades(user))
		return

	user.available_upgrades--
	user.upgrade_speed()
	if(user.speed_upgrades > user.level_cap)
		user.RemoveSpell(user.upgrade_speed_spell)

/datum/spell/irradiated_mouse_spell/upgrade_damage
	name = "Upgrade Damage"
	desc = "Upgrade your damage. You will become able to damage walls and windows at level 3."
	action_icon_state = "irradiated_mouse_damage"

/datum/spell/irradiated_mouse_spell/upgrade_damage/cast(list/targets, mob/living/basic/mouse/irradiated_mouse/user)
	. = ..()
	if(!has_upgrades(user))
		return

	user.available_upgrades--
	user.upgrade_damage()
	if(user.damage_upgrades > user.level_cap)
		user.RemoveSpell(user.upgrade_damage_spell)

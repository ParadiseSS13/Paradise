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
	desc = "Upgrade the amount and type of radiation you contaminate humans with."
	action_icon_state = "irradiated_mouse_radiation"

/datum/spell/irradiated_mouse_spell/upgrade_radiation/cast(list/targets, mob/living/basic/mouse/irradiated_mouse/user)
	. = ..()
	if(!has_upgrades(user))
		return

	to_chat(user, SPAN_NOTICE("You upgrade your the amount of radiation you give off."))

	user.available_upgrades--
	user.upgrade_radiation()
	if(user.radiation_upgrades == user.level_cap)
		user.RemoveSpell(user.upgrade_radiation_spell)

/datum/spell/irradiated_mouse_spell/upgrade_speed
	name = "Upgrade Speed"
	desc = "Upgrade your speed. You will begin forming after-images at maximum level."
	action_icon_state = "irradiated_mouse_speed"

/datum/spell/irradiated_mouse_spell/upgrade_speed/cast(list/targets, mob/living/basic/mouse/irradiated_mouse/user)
	. = ..()
	if(!has_upgrades(user))
		return

	to_chat(user, SPAN_NOTICE("You upgrade your speed."))

	user.available_upgrades--
	user.upgrade_speed()
	if(user.speed_upgrades == user.level_cap)
		user.RemoveSpell(user.upgrade_speed_spell)
		to_chat(user, SPAN_NOTICE("You feel like the wind."))

/datum/spell/irradiated_mouse_spell/upgrade_damage
	name = "Upgrade Damage"
	desc = "Upgrade your damage. You will become able to damage walls and windows at maximum level"
	action_icon_state = "irradiated_mouse_damage"

/datum/spell/irradiated_mouse_spell/upgrade_damage/cast(list/targets, mob/living/basic/mouse/irradiated_mouse/user)
	. = ..()
	if(!has_upgrades(user))
		return

	to_chat(user, SPAN_NOTICE("You upgrade your damage."))

	user.available_upgrades--
	user.upgrade_damage()
	if(user.damage_upgrades == user.level_cap)
		user.RemoveSpell(user.upgrade_damage_spell)
		to_chat(user, SPAN_NOTICE("You feel much stronger."))

/datum/spell/mouse_sludge_ejection
	name = "Eject Radioactive Sludge"
	desc = "Partially liquify your fur"
	action_icon = 'icons/effects/effects.dmi'
	action_icon_state = "greenglow"
	action_background_icon_state = "bg_irradiated_mouse"
	clothes_req = FALSE
	base_cooldown = 3 MINUTES

/datum/spell/mouse_sludge_ejection/cast(list/targets, mob/user)
	. = ..()
	if(!isturf(user.loc)) // No making sludge from pipes.
		revert_cast()
		return
	to_chat(user, SPAN_NOTICE("You shed part of your fur into a semi-liquid puddle on the floor!"))
	new /obj/effect/decal/cleanable/radioactive_sludge(get_turf(user))
	var/turf/turf = get_turf(user)
	contaminate_target(turf, user, 500, GAMMA_RAD)

/datum/spell/mouse_sludge_ejection/create_new_targeting()
	return new /datum/spell_targeting/self

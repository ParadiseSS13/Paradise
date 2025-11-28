//Preset for spells
/datum/action/spell_action
	background_icon_state = "bg_spell"
	var/recharge_text_color = "#FFFFFF"

/datum/action/spell_action/New(Target)
	..()
	var/datum/spell/S = target
	S.action = src
	name = S.name
	desc = S.desc
	button_icon = S.action_icon
	button_icon_state = S.action_icon_state
	background_icon = S.action_background_icon
	background_icon_state = S.action_background_icon_state
	build_all_button_icons()

/datum/action/spell_action/Destroy()
	var/datum/spell/S = target
	S.action = null
	return ..()

/datum/action/spell_action/should_draw_cooldown()
	var/datum/spell/S = target
	return S.cooldown_handler.should_draw_cooldown()

/datum/action/spell_action/Trigger(left_click)
	if(!..())
		return FALSE
	if(target)
		var/datum/spell/spell = target
		spell.Click()
		return TRUE

/datum/action/spell_action/AltTrigger()
	if(target)
		var/datum/spell/spell = target
		spell.AltClick(usr)
		return TRUE

/datum/action/spell_action/IsAvailable(show_message = TRUE)
	if(!target)
		return FALSE
	var/datum/spell/spell = target

	if(owner)
		return spell.can_cast(owner, TRUE, show_message)
	return FALSE

/datum/action/spell_action/apply_unavailable_effect(atom/movable/screen/movable/action_button/button)
	var/datum/spell/S = target
	if(!istype(S))
		return ..()

	unavailable_effect = mutable_appearance('icons/mob/screen_white.dmi', icon_state = "template")
	unavailable_effect.appearance_flags = RESET_COLOR | RESET_ALPHA
	unavailable_effect.color = "#000000"
	unavailable_effect.plane = FLOAT_PLANE + 1
	unavailable_effect.alpha = S.cooldown_handler.get_cooldown_alpha()

	// Make a holder for the charge text
	var/image/count_down_holder = mutable_appearance('icons/effects/effects.dmi', icon_state = "nothing", appearance_flags = RESET_COLOR | RESET_ALPHA)
	var/text = S.cooldown_handler.cooldown_info()
	count_down_holder.maptext_y = 4
	count_down_holder.maptext = "<div style=\"font-size:6pt;color:[recharge_text_color];font:'Small Fonts';text-align:center;\" valign=\"bottom\">[text]</div>"
	unavailable_effect.add_overlay(count_down_holder)

	button.overlays |= unavailable_effect

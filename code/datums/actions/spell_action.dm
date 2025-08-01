//Preset for spells
/datum/action/spell_action
	button_background_icon_state = "bg_spell"
	var/recharge_text_color = "#FFFFFF"

/datum/action/spell_action/New(Target)
	..()
	var/datum/spell/S = target
	S.action = src
	name = S.name
	desc = S.desc
	button_overlay_icon = S.action_icon
	button_background_icon = S.action_background_icon
	button_overlay_icon_state = S.action_icon_state
	button_background_icon_state = S.action_background_icon_state
	UpdateButtons()


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

/datum/action/spell_action/IsAvailable()
	if(!target)
		return FALSE
	var/datum/spell/spell = target

	if(owner)
		return spell.can_cast(owner, show_message = TRUE)
	return FALSE

/datum/action/spell_action/apply_unavailable_effect(atom/movable/screen/movable/action_button/button)
	var/datum/spell/S = target
	if(!istype(S))
		return ..()

	var/alpha = S.cooldown_handler.get_cooldown_alpha()

	var/image/img = image('icons/mob/screen_white.dmi', icon_state = "template")
	img.alpha = alpha
	img.appearance_flags = RESET_COLOR | RESET_ALPHA
	img.color = "#000000"
	img.plane = FLOAT_PLANE + 1
	button.add_overlay(img)
	// Make a holder for the charge text
	var/image/count_down_holder = image('icons/effects/effects.dmi', icon_state = "nothing")
	count_down_holder.plane = FLOAT_PLANE + 1.1
	var/text = S.cooldown_handler.cooldown_info()
	count_down_holder.maptext = "<div style=\"font-size:6pt;color:[recharge_text_color];font:'Small Fonts';text-align:center;\" valign=\"bottom\">[text]</div>"
	button.add_overlay(count_down_holder)

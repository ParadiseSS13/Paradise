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
	var/datum/spell/spell = target
	if(!istype(spell))
		return

	var/text = spell.cooldown_handler.cooldown_info()

	button.cut_overlay(button.unavailable_image)
	var/mutable_appearance/ma = mutable_appearance(
		icon = 'icons/mob/screen_white.dmi',
		icon_state = "template",
		plane = FLOAT_PLANE + 1,
		alpha = spell.cooldown_handler.get_cooldown_alpha(),
		appearance_flags = RESET_COLOR | RESET_ALPHA,
		color = "#000000"
	)
	button.unavailable_image = new
	button.unavailable_image.appearance = ma

	// Make a holder for the charge text, and yes this needs to be a separate overlay on our overlay
	var/image/count_down_holder = mutable_appearance('icons/effects/effects.dmi', icon_state = "nothing", appearance_flags = RESET_COLOR | RESET_ALPHA)
	count_down_holder.maptext_y = 4 // bump up off the bottom border
	count_down_holder.maptext = "<div style=\"font-size:6pt;color:[recharge_text_color];font:'Small Fonts';text-align:center;\" valign=\"bottom\">[text]</div>"
	button.unavailable_image.overlays += count_down_holder
	button.add_overlay(button.unavailable_image)

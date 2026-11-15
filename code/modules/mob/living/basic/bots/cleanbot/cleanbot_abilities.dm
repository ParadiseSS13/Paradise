/datum/action/cooldown/mob_cooldown/bot
	background_icon_state = "bg_tech_blue"
	overlay_icon_state = "bg_tech_blue_border"
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/bot/IsAvailable(show_message)
	. = ..()
	if(!.)
		return FALSE
	if(!isbot(owner))
		return TRUE
	var/mob/living/basic/bot/bot_owner = owner
	if(bot_owner.bot_mode_flags & BOT_MODE_ON)
		return TRUE
	return FALSE

/datum/action/cooldown/mob_cooldown/bot/foam
	name = "Foam"
	desc = "Spread foam all around you!"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "mfoam"
	cooldown_time = 20 SECONDS
	click_to_activate = FALSE
	///range of the foam to spread
	var/foam_range = 2

/datum/action/cooldown/mob_cooldown/bot/foam/Activate(mob/living/firer, atom/target)
	owner.visible_message(SPAN_DANGER("[owner] whirs and bubbles violently, before releasing a plume of froth!"))
	new /obj/effect/particle_effect/foam(get_turf(owner))
	StartCooldown()
	return TRUE

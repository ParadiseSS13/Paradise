/datum/spell/pointed/projectile/moon_parade
	name = "Lunar parade"
	desc = "This unleashes the parade, making everyone in its way join it and suffer hallucinations."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "moon_parade"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/cosmic_energy.ogg'
	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "L'N'R P'RAD"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	//active_msg = "You prepare to make them join the parade!"
	//deactive_msg = "You stop the music and halt the parade... for now."
	cast_range = 12
	//projectile_type = /obj/item/projectile/moon_parade


/obj/item/projectile/moon_parade
	name = "Lunar parade"
	icon_state = "lunar_parade"
	damage = 0
	damage_type = BURN
	speed = 0.2
	range = 75
	ricochets_max = 40
	ricochet_chance = 500
	ricochet_incidence_leeway = 0
	//projectile_piercing = PASSMOB|PASSVEHICLE
	///looping sound datum for our projectile.
	var/datum/looping_sound/moon_parade/soundloop
	// A list of the people we hit
	var/list/mobs_hit = list()

//QWERTODO: THIS NEEDS A LOT OF REFACTORING / JURRY RIGGING


/datum/spell/pointed/projectile/furious_steel
	name = "Furious Steel"
	desc = "Summon three silver blades which orbit you. \
		While orbiting you, these blades will protect you from from attacks, but will be consumed on use. \
		Additionally, you can click to fire the blades at a target, dealing damage and causing bleeding."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "furious_steel"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/weapons/guillotine.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 60 SECONDS
	invocation = "F'LSH'NG S'LV'R!"
	invocation_type = INVOCATION_SHOUT

	spell_requirements = NONE

	//active_msg = "You summon forth three blades of furious silver."
	//deactive_msg = "You conceal the blades of furious silver."
	//cast_range = 20
//	projectile_type = /obj/item/projectile/floating_blade
//	projectile_amount = 3

	///Effect of the projectile that surrounds us while the spell is active
	var/projectile_effect = /obj/effect/floating_blade
	/// A ref to the status effect surrounding our heretic on activation.
	var/datum/status_effect/protective_blades/blade_effect

//qwertodo: another 99 errors, begone til it compiles


/datum/spell/alien_spell/neurotoxin
	name = "Neurotoxin spit"
	desc = "This ability allows you to fire some neurotoxin. Knocks down anyone you hit, applying a small amount of stamina damage as well."
	base_cooldown = 3 SECONDS
	plasma_cost = 50
	selection_activated_message		= "<span class='notice'><B>Your prepare some neurotoxin!</B></span>"
	selection_deactivated_message	= "<span class='notice'><B>You swallow your prepared neurotoxin.</B></span>"
	var/neurotoxin_type = /obj/item/projectile/bullet/neurotoxin
	action_icon_state = "alien_neurotoxin_0"

/datum/spell/alien_spell/neurotoxin/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/datum/spell/alien_spell/neurotoxin/update_spell_icon()
	if(!action)
		return
	action.button_icon_state = "alien_neurotoxin_[active]"
	action.build_all_button_icons()

/datum/spell/alien_spell/neurotoxin/cast(list/targets, mob/living/carbon/user)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // A little aimbot is fine
	if(!istype(U) || !istype(T))
		return FALSE

	var/obj/item/projectile/bullet/neurotoxin/neurotoxin = new neurotoxin_type(user.loc)
	neurotoxin.current = get_turf(user)
	neurotoxin.original = target
	neurotoxin.firer = user
	neurotoxin.preparePixelProjectile(target, user)
	neurotoxin.fire()
	user.newtonian_move(get_dir(U, T))

	return TRUE

/datum/spell/alien_spell/neurotoxin/death_to_xenos
	desc = "This ability allows you to fire some neurotoxin. Knocks aliens down."
	neurotoxin_type = /obj/item/projectile/bullet/anti_alien_toxin
	base_cooldown = 2 SECONDS

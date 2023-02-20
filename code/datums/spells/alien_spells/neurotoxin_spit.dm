/obj/effect/proc_holder/spell/alien_spell/neurotoxin
	name = "Neurotoxin spit"
	desc = "This ability allows you to fire some neurotoxin. Knocks down anyone you hit, applies a small amount of stamina damage as well."
	base_cooldown = 5 SECONDS
	plasma_cost = 50
	selection_activated_message		= "<span class='notice'><B>Your prepare some neurotoxin!</B></span>"
	selection_deactivated_message	= "<span class='notice'><B>You swallow your prepared neurotoxin.</B></span>"
	var/neurotoxin_type = /obj/item/projectile/bullet/neurotoxin
	action_icon_state = "alien_neurotoxin_0"
	active = FALSE

/obj/effect/proc_holder/spell/alien_spell/neurotoxin/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/alien_spell/neurotoxin/update_icon_state()
	if(!action)
		return
	action.button_icon_state = "alien_neurotoxin_[active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/alien_spell/neurotoxin/cast(list/targets, mob/living/carbon/user)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // A little aimbot is fine
	if(!istype(U) || !istype(T))
		return FALSE

	var/obj/item/projectile/bullet/neurotoxin/neurotoxin = new neurotoxin_type(user.loc)
	neurotoxin.current = get_turf(user)
	neurotoxin.original = target
	neurotoxin.firer = user
	neurotoxin.preparePixelProjectile(target, get_turf(target), user)
	neurotoxin.fire()
	user.newtonian_move(get_dir(U, T))

	return TRUE

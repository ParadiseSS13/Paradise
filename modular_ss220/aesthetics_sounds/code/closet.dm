/obj/structure/closet
	var/list/togglelock_sound = list(
		'modular_ss220/aesthetics_sounds/sound/lock_1.ogg',
		'modular_ss220/aesthetics_sounds/sound/lock_2.ogg',
		'modular_ss220/aesthetics_sounds/sound/lock_3.ogg'
		)

/obj/structure/closet/secure_closet/togglelock(mob/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
		return
	. = ..()
	if(!opened && !broken && !(user.loc == src) && allowed(user))
		playsound(loc, pick(togglelock_sound), 10, TRUE, -3)

/obj/structure/closet/crate/secure/togglelock(mob/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
		return
	. = ..()
	if(!opened && !broken && !(user.loc == src) && allowed(user))
		playsound(loc, pick(togglelock_sound), 10, TRUE, -3)
